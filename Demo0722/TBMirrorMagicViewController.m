//
//  TBMagicMirrorViewController.m
//  TBMirror
//
//  Created by albert on 15/3/26.
//  Copyright (c) 2015年 Taobao.com. All rights reserved.
//

#import "TBMirrorMagicViewController.h"
#import "TBNavigator.h"

#import <WindVane/WindVane.h>
#import "TBIconFont.h"
#import "TBUserTrackHelper.h"
#import "TBShareContent.h"
#import "TBShareServiceProtocol.h"
#import "TBMContainer.h"
#import "TBMirrorNetworkUtil.h"
#import "TBHint.h"
#import "UIColor+Hex.h"
#import "TBMirrorNetworkParam.h"
#import "TBMirrorNetWorkManager.h"
#import "TBMirrorPlugin.h"
#import "MirrorBeautyModel.h"
#import <UT/UT.h>
#import "TBMirrorConfigCenter.h"

#import "HUDActivityView.h"
#import "TBMirrorSavePhotoViewController.h"
#import "MirrorViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "HUDActivityView.h"

#import "MBProgressHUD.h"



#define TBMIRROR_USERDEFAULT_SUPPORTMAKEUP      @"TBMIRROR_USERDEFAULT_SUPPORTMAKEUP5"

@interface TBMirrorMagicViewController ()<MirrorViewControllerDelegate,UIAlertViewDelegate>{
    
}

//下载时候使用到的view
@property (nonatomic,strong) UIView                     *bgView;
@property (nonatomic,strong) UIProgressView             *progressView;
@property (nonatomic,strong) UILabel                    *progerssTipsLabel;
@property (nonatomic,strong) UILabel                    *progerssLabel;
@property (nonatomic,strong) UIButton                   *cancelBtn;

//init时候外部传进来的相关变量
@property (nonatomic,strong) NSString                   *viewControllerUrl;
@property (nonatomic) TBMirrorCosmeticType                makeUpType;
@property (nonatomic,strong) NSString                   *webViewUrl;
@property (nonatomic) double                            wvWebViewHeightRatio;
@property (nonatomic) double                            wvWebViewHeight;

//hud
@property (nonatomic,strong) HUDActivityView            *hudView;
@property (nonatomic,strong) UIView                     *hudBg;
@property (nonatomic,strong) MBProgressHUD              *mbHud;
//callback
@property (nonatomic,strong) WVJSBResponse              windVaneCallback;
@property (nonatomic,strong) MirrorShouldDoBlock shouldDownLoadFaceModelBlock;

//other
@property (nonatomic,strong) NSString                   *cacheKeyFaceModel;
@property (nonatomic,strong) MirrorViewController       *mirrorVC;
@property (nonatomic,strong) UIView                     *barView;
@property (nonatomic) BOOL                              isBeauty;
@property (nonatomic) BOOL                              webViewFold;




@end

@implementation TBMirrorMagicViewController


- (id)initWithNavigatorURL:(NSURL *)URL query:(NSDictionary *)query {
    
    _viewControllerUrl = [URL absoluteString];
    NSString *type = [query objectForKey:@"mode"];
    NSString *webViewUrl = [query objectForKey:@"url"];
    double height = 0.6;
    if ([[query allKeys] containsObject:@"height"]) {
        height = [[query objectForKey:@"height"] doubleValue];
    }
    TBMirrorCosmeticType drawType = [type intValue];//默认为渲染图片
    drawType = TBMirrorMakeUpTypeVideo;//目前只支持动态
    return [self initWithDrawType:drawType webViewUrl:webViewUrl height:height];
}

- (instancetype)initWithDrawType:(TBMirrorCosmeticType)type webViewUrl:(NSString *)webViewUrl height:(double)height{
    //参数检查
    if (!webViewUrl || !webViewUrl.length > 0) {
        return nil;
    }
    //height传比例0~1，如果大于1则height为1如果小于0则为0
    if (height > 1) {
        height = 1;
    }else if (height < 0){
        height = 0;
    }
    
    
    self = [super init];
    if (self) {
        _makeUpType = type;
        _webViewUrl = webViewUrl;
        _wvWebViewHeightRatio = height;
        _webViewFold = YES;
        _isBeauty = YES;
        
    }
    
    return self;
}



- (void)viewDidLoad {
    [super viewDidLoad];
    [self setTbNavibarHidden:YES];
    [self setUpHud];
    
    TBMirrorMagicViewController __weak *weakSelf = self;
    [MirrorViewController isSupportMakeUp:^(BOOL isSupport, NSDictionary *result, NSError *error) {
        TBMirrorMagicViewController __strong *strongSelf = weakSelf;
        if (isSupport) {
            [strongSelf setUpMirrorVCWithType:TBMirrorMakeUpTypeVideo];
            [strongSelf.mirrorVC initMakeUpModule];
            
            [strongSelf setUpNavBar];
            [strongSelf setUpWVWebView];
            
            //更新页面埋点页面名字
            [UT et_updateViewControllerPageName:strongSelf pageName:@"Page_Mirror"];
        }else{
            [strongSelf.tbNavigationController popViewControllerAnimated:YES];
            TBOpenURLFromTarget(@"http://h5.m.taobao.com/act/makeupError.html", nil);
        }
    }];
    
    
    
    
}

-(void)setUpHud{
    [self.view addSubview:self.hudBg];
    [self.hudBg addSubview:self.hudView];
    
    _mbHud = [[MBProgressHUD alloc] initWithView:self.hudBg];
    [self.hudBg addSubview:_mbHud];
    _mbHud.labelText = @"正在加载";
    _mbHud.mode = MBProgressHUDModeText;
    [_mbHud show:YES];
    
    
    
}


-(void)setUpNavBar{
    //initBackBtn
    UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 60*WITH_SCALE, 60*WITH_SCALE)];
    backButton.exclusiveTouch = YES;
    NSString * iconFontBack = [TBIconFont iconFontUnicodeWithName:@"back"];
    backButton.titleLabel.font = [TBIconFont iconFontWithSize:24*WITH_SCALE];
    [backButton setTitle:iconFontBack forState:UIControlStateNormal];
    UIColor *backBtnColor = [UIColor colorWithRed:255.0f/255.0f green:255.0f/255.0f blue:255.0f/255.0f alpha:1];
    [backButton setTitleColor:backBtnColor forState:UIControlStateNormal];
    //    [_backButton setBackgroundColor:[UIColor blackColor]];//test
    [backButton addTarget:self action:@selector(backBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    UIView *backBgView = [[UIView alloc] initWithFrame:CGRectMake(16*WITH_SCALE, 16*WITH_SCALE, 40*WITH_SCALE, 40*WITH_SCALE)];
    backBgView.layer.cornerRadius = backBgView.frame.size.height/2;
    backBgView.backgroundColor = [UIColor colorWithHex:0x000 alpha:0.3];
    backButton.center = CGPointMake(backBgView.frame.size.width/2, backBgView.frame.size.height/2);
    [backBgView addSubview:backButton];
    [self.view addSubview:backBgView];
    
    
    
    //initShareBtn
    UIButton *shareButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 60*WITH_SCALE, 80*WITH_SCALE)];
    shareButton.exclusiveTouch = YES;
    //    NSString * iconFontShare = [TBIconFont iconFontUnicodeWithName:@"down"];
    shareButton.titleLabel.font = [TBIconFont iconFontWithSize:24*WITH_SCALE];
    [shareButton setTitle:@"截图" forState:UIControlStateNormal];
    shareButton.titleLabel.font = [UIFont systemFontOfSize:16.f];
    UIColor *shareBtnColor = [UIColor colorWithRed:255.0f/255.0f green:255.0f/255.0f blue:255.0f/255.0f alpha:1];
    [shareButton setTitleColor:shareBtnColor forState:UIControlStateNormal];
    //    [_shareButton setBackgroundColor:[UIColor blackColor]];//test
    [shareButton addTarget:self action:@selector(shareBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    UIView *shareBgView = [[UIView alloc] initWithFrame:CGRectMake(self.view.frame.size.width-84*WITH_SCALE, 16*WITH_SCALE, 66*WITH_SCALE, 40*WITH_SCALE)];
    shareBgView.layer.cornerRadius = shareBgView.frame.size.height/2;
    shareBgView.backgroundColor = [UIColor colorWithHex:0x000 alpha:0.3];
    shareButton.center = CGPointMake(shareBgView.frame.size.width/2, shareBgView.frame.size.height/2);
    [shareBgView addSubview:shareButton];
    [self.view addSubview:shareBgView];
    
    
    
    //initFrontBackCameraBtn
    UIButton *cameraButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 60*WITH_SCALE, 80*WITH_SCALE)];
    cameraButton.exclusiveTouch = YES;
    NSString * iconFontCamera = [TBIconFont iconFontUnicodeWithName:@"camera_rotate"];
    cameraButton.titleLabel.font = [TBIconFont iconFontWithSize:24*WITH_SCALE];
    [cameraButton setTitle:iconFontCamera forState:UIControlStateNormal];
    UIColor *cameraBtnColor = [UIColor colorWithRed:255.0f/255.0f green:255.0f/255.0f blue:255.0f/255.0f alpha:1];
    [cameraButton setTitleColor:cameraBtnColor forState:UIControlStateNormal];
    //    [_cameraButton setBackgroundColor:[UIColor blackColor]];//test
    [cameraButton addTarget:self action:@selector(cameraBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    UIView *cameraBgView = [[UIView alloc] initWithFrame:CGRectMake(shareBgView.frame.origin.x - 56*WITH_SCALE, 16*WITH_SCALE, 40*WITH_SCALE, 40*WITH_SCALE)];
    cameraBgView.layer.cornerRadius = cameraBgView.frame.size.height/2;
    cameraBgView.backgroundColor = [UIColor colorWithHex:0x000 alpha:0.3];
    cameraButton.center = CGPointMake(cameraBgView.frame.size.width/2, cameraBgView.frame.size.height/2);
    [cameraBgView addSubview:cameraButton];
    [self.view addSubview:cameraBgView];
    
    
    
    
    //beautyBtn
    UIButton *beautyBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 60*WITH_SCALE, 80*WITH_SCALE)];
    beautyBtn.exclusiveTouch = YES;
    NSString * iconFontBeauty = [TBIconFont iconFontUnicodeWithName:@"magic"];
    beautyBtn.titleLabel.font = [TBIconFont iconFontWithSize:24*WITH_SCALE];
    [beautyBtn setTitle:iconFontBeauty forState:UIControlStateNormal];
    UIColor *beautyBtnColor = [UIColor colorWithRed:255.0f/255.0f green:255.0f/255.0f blue:255.0f/255.0f alpha:1];
    [beautyBtn setTitleColor:beautyBtnColor forState:UIControlStateNormal];
    //    [beautyBtn setBackgroundColor:[UIColor blackColor]];//test
    [beautyBtn addTarget:self action:@selector(beauty) forControlEvents:UIControlEventTouchUpInside];
    
    UIView *beautyBgView = [[UIView alloc] initWithFrame:CGRectMake(cameraBgView.frame.origin.x - 56*WITH_SCALE, 16*WITH_SCALE, 40*WITH_SCALE, 40*WITH_SCALE)];
    beautyBgView.layer.cornerRadius = beautyBgView.frame.size.height/2;
    beautyBgView.backgroundColor = [UIColor colorWithHex:0x000 alpha:0.3];
    beautyBtn.center = CGPointMake(beautyBgView.frame.size.width/2, beautyBgView.frame.size.height/2);
    [beautyBgView addSubview:beautyBtn];
    //    [self.view addSubview:beautyBgView];
    
    
    
    
    
    
}

-(BOOL)setUpMirrorVCWithType:(TBMirrorCosmeticType)makeUpType{
    switch (makeUpType) {
        case TBMirrorCosmeticTypePhoto:
            //TODO:静态图像上妆需要产品规划
            //            _mirrorVC = [MirrorViewController alloc] initWithImage:<#(UIImage *)#>
            break;
        case TBMirrorMakeUpTypeVideo:
        default:
            _mirrorVC = [[MirrorViewController alloc] initWithCameraPreset:AVCaptureSessionPreset640x480];
            
            break;
    }
    
    _mirrorVC.delegate = self;
    [self addChildViewController:_mirrorVC];
    _mirrorVC.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    [self.view addSubview:_mirrorVC.view];
    [_mirrorVC didMoveToParentViewController:self];
    return YES;
}

-(void)setUpWVWebView{
    //init WVWebView
    //将_wvWebViewHeight由比例转为高度
    _wvWebViewHeight = self.view.frame.size.height/2*_wvWebViewHeightRatio;
    CGRect webViewFrame = CGRectMake(0,self.view.frame.size.height+40*HEIGHT_SCALE,self.view.frame.size.width, _wvWebViewHeight);
    self.webView = [[WVWebView alloc] initWithFrame:webViewFrame];
    self.webView.backgroundColor = [UIColor clearColor];
    self.webView.alpha = 0.8;
    [self.webView loadURL:_webViewUrl];
    self.webView.isOpenLocalService = YES;
    self.webView.sourceViewController = self;
    [WVBasicUserConfig openWindVaneLog];
    [self.view addSubview:self.webView];
    
    //initBar
    _barView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, 40*HEIGHT_SCALE)];
    _barView.alpha = 0.6;
    _barView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:_barView];
    UIButton *arrowBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 60*WITH_SCALE)];
    arrowBtn.center = CGPointMake(_barView.frame.size.width/2, _barView.frame.size.height/2);
    arrowBtn.titleLabel.font = [TBIconFont iconFontWithSize:24*WITH_SCALE];
    NSString * iconFontUnFold = [TBIconFont iconFontUnicodeWithName:@"unfold"];
    [arrowBtn setTitle:iconFontUnFold forState:UIControlStateNormal];
    [arrowBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [arrowBtn addTarget:self action:@selector(arrowClick:) forControlEvents:UIControlEventTouchUpInside];
    [_barView addSubview:arrowBtn];
    [_barView bringSubviewToFront:arrowBtn];
    
}

-(void)setUpDownloadingView{
    //init downloading view
    _bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    _bgView.backgroundColor = [UIColor blackColor];
    _bgView.alpha = 0.5;
    [self.view addSubview:_bgView];
    
    _progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleBar];
    _progressView.frame = CGRectMake(60*WITH_SCALE, self.view.frame.size.height/2, self.view.frame.size.width - 120*WITH_SCALE, 8);
    _progressView.backgroundColor = [UIColor whiteColor];
    _progressView.progressTintColor = [UIColor colorWithHex:0xff9402 alpha:1.f];//todomark crash
    [self.view addSubview:_progressView];
    
    _progerssLabel = [[UILabel alloc] initWithFrame:CGRectMake(_progressView.frame.origin.x+_progressView.frame.size.width-33*WITH_SCALE, _progressView.frame.origin.y-20, 50, 20)];
    _progerssLabel.font = [UIFont systemFontOfSize:12];
    _progerssLabel.textColor = [UIColor whiteColor];
    _progerssLabel.backgroundColor = [UIColor clearColor];
    _progerssLabel.text = @"0%";
    [self.view addSubview:_progerssLabel];
    
    _progerssTipsLabel = [[UILabel alloc] initWithFrame:CGRectMake(_progressView.frame.origin.x, _progressView.frame.origin.y-20, 100, 20)];
    _progerssTipsLabel.font = [UIFont systemFontOfSize:12];
    _progerssTipsLabel.text = @"正在加载...";
    _progerssTipsLabel.textColor = [UIColor whiteColor];
    _progerssTipsLabel.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_progerssTipsLabel];
    
    _cancelBtn = [[UIButton alloc] initWithFrame:CGRectMake(_progressView.frame.origin.x+_progressView.frame.size.width+5*WITH_SCALE, _progressView.frame.origin.y, 20*WITH_SCALE, 8)];
    _cancelBtn.center = CGPointMake(_cancelBtn.center.x, _progressView.center.y);
    NSString *iconFontClose = [TBIconFont iconFontUnicodeWithName:@"round_close_fill"];
    _cancelBtn.titleLabel.font = [TBIconFont iconFontWithSize:20*WITH_SCALE];
    [_cancelBtn setTitle:iconFontClose forState:UIControlStateNormal];
    [_cancelBtn setTitleColor:[UIColor colorWithHex:0xff9402 alpha:1.f] forState:UIControlStateNormal];
    [_cancelBtn addTarget:self action:@selector(backBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_cancelBtn];
}



#pragma mark - public fun
//通过TBMirrorJSBridge获取到下载到本地的路径
//调用mirrorVC的makeUpWithModels将这个地址传给mirrorVC,mirrorVC开始做绘制
-(void)makeUpWithData:(NSDictionary *)data callback:(WVJSBResponse)callback{
    self.windVaneCallback = callback;
    [self.mbHud show:YES];
    //hud
    [self.hudView animateShowInView:self.hudBg];
    //    [_mirrorVC makeUpWithDict:data];
    [_mirrorVC makeUpWithDict:data materialType:MirrorMaterialTypeDefault];
    
    
    
    
    
    
    
    
}

#pragma mark - 埋点
- (NSDictionary *)dataForUserTrack {
    NSDictionary *pageData = nil;
    if (!pageData) {
        
        pageData = [[NSDictionary alloc]initWithObjectsAndKeys:@"Page_Mirror", @"_pageName_", nil];
        
    }
    return pageData;
}

#pragma mark - initParam 懒加载
-(HUDActivityView *)hudView{
    if (!_hudView) {
        _hudView = [[HUDActivityView alloc] initWithFrame:CGRectMake(0, 0, 150*WITH_SCALE, 150*WITH_SCALE) showTip:YES];
        _hudView.center = CGPointMake(self.hudBg.frame.size.width/2, 245*HEIGHT_SCALE);
        _hudView.textLabel.text = @"正在加载...";
    }
    return _hudView;
}

-(UIView *)hudBg{
    if (!_hudBg) {
        _hudBg = [[UIView alloc] initWithFrame:CGRectMake(0, 70, self.view.frame.size.width, self.view.frame.size.height-70)];
        _hudBg.backgroundColor = [UIColor blackColor];
    }
    return _hudBg;
}


#pragma mark - button click
-(void)backBtnClicked:(UIButton*)btn{
    [self.tbNavigationController popViewControllerAnimated:YES];
    
    // 释放childViewController
    if (_mirrorVC) {
        [_mirrorVC willMoveToParentViewController:nil];
        [_mirrorVC.view removeFromSuperview];
        [_mirrorVC removeFromParentViewController];
        _mirrorVC = nil;
    }
    
    [self clear];
}
-(void)cameraBtnClicked:(UIButton*)btn{
    [_mirrorVC switchCamera];
}

-(void)shareBtnClicked:(UIButton*)btn{
    //埋点
    [TBUserTrackHelper ctrlClicked:@"Button-Share" args:nil];
    
    //20150629这期分享组件暂时改成保存图，看使用效果
    //    TBShareContent* shareContent = [[TBShareContent alloc]init];
    //    // 加WeChat,url里面包含参数wxIsAvailable : 1 表示微信好友；2 表示微信朋友圈；其它表示两者都有
    //    if (_viewControllerUrl && _viewControllerUrl.length > 0) {
    //        NSString *query = [_viewControllerUrl componentsSeparatedByString:@"?"][1];
    //        _viewControllerUrl = [@"http://huodong.m.taobao.com/hd/5759.html?" stringByAppendingString:query];
    //        if ([_viewControllerUrl rangeOfString:@"weixinshare"].location == NSNotFound) {
    //            _viewControllerUrl = [_viewControllerUrl stringByAppendingString:@"&weixinshare=0"];
    //        }
    //    }
    //    shareContent.imageSource = [_mirrorVC getCosmeticImg];
    //    shareContent.url = [NSURL URLWithString:_viewControllerUrl];
    //    shareContent.shareScene = @"other";//todomark待确认
    //    shareContent.fromAppName = @"手机淘宝";
    //    shareContent.title = @"百变秒妆，魅力妆容立点即现";
    //    shareContent.description = @"一秒妆出千娇百媚，我正在玩手机淘宝百变秒妆，点我，变美从此刻开始!";
    //    shareContent.businessId = @"24";
    //
    //    id<TBShareServiceProtocol> obj = [[TBMContainer sharedContainer] serviceForName:kShareService];
    //    [obj shareWithViewController:self title:@"想告诉谁" content:shareContent delegate:nil];
    UIImage *image = [_mirrorVC getCosmeticImg];
    
    TBMirrorSavePhotoViewController *savePhotoVC = [[TBMirrorSavePhotoViewController alloc] initWithImg:image url:_viewControllerUrl];
    [self.tbNavigationController pushViewController:savePhotoVC animated:YES];
    
}


-(void)beauty{
    MirrorBeautyModel *whiteModel = [[MirrorBeautyModel alloc] init];
    whiteModel.beautyType = MirrorBeautyTypeWhite;
    MirrorBeautyModel *buffyingModel = [[MirrorBeautyModel alloc] init];
    buffyingModel.beautyType = MirrorBeautyTypeBuffing;
    
    NSDictionary *configDic = [[TBMirrorConfigCenter sharedInstance] getConfigGroup];
    float beauty_buffing_weight = [[configDic objectForKey:TBMIRROR_CONFIG_KEY_BEAUTY_BUFFING_WEIGHT] floatValue];
    float beauty_white_weght = [[configDic objectForKey:TBMIRROR_CONFIG_KEY_BEAUTY_WHITE_WEIGHT] floatValue];
    
    if (_isBeauty) {
        whiteModel.weight = beauty_white_weght;
        buffyingModel.weight = beauty_buffing_weight;
    }else{
        
        whiteModel.weight = 0.f;
        buffyingModel.weight = 0.f;
    }
    _isBeauty = !_isBeauty;
    
    NSArray *beautyArray = [[NSArray alloc] initWithObjects:buffyingModel,whiteModel, nil];
    [_mirrorVC beautyWithBeautyModels:beautyArray];
    
}



-(void)arrowClick:(UIButton*)arrowBtn{
    __weak __typeof(self) weakSelf = self;
    [UIView animateWithDuration:0.5f animations:^{
        __strong __typeof(self) strongSelf = weakSelf;
        if (strongSelf.webViewFold) {
            
            NSString * iconFontUnFold = [TBIconFont iconFontUnicodeWithName:@"unfold"];
            [arrowBtn setTitle:iconFontUnFold forState:UIControlStateNormal];
            
            strongSelf.webView.frame = CGRectMake(0, strongSelf.view.frame.size.height-strongSelf.wvWebViewHeight, strongSelf.view.frame.size.width, strongSelf.wvWebViewHeight);
            
            strongSelf.barView.frame = CGRectMake(0, strongSelf.view.frame.size.height-strongSelf.wvWebViewHeight-40*HEIGHT_SCALE, strongSelf.view.frame.size.width, 40*HEIGHT_SCALE);
            
            strongSelf.webViewFold = NO;
            
        }else{
            
            NSString * iconFontUnFold = [TBIconFont iconFontUnicodeWithName:@"fold"];
            [arrowBtn setTitle:iconFontUnFold forState:UIControlStateNormal];
            
            strongSelf.webView.frame = CGRectMake(0, strongSelf.view.frame.size.height, strongSelf.view.frame.size.width, strongSelf.wvWebViewHeight);
            strongSelf.barView.frame = CGRectMake(0, strongSelf.view.frame.size.height-40*HEIGHT_SCALE, strongSelf.view.frame.size.width, 40*HEIGHT_SCALE);
            
            strongSelf.webViewFold = YES;
        }
        
        
    }];
}

#pragma mark - funciton
-(BOOL)isSubViewAdded:(id)OneViewObject{
    for(UIView *view in self.view.subviews){
        if([view isKindOfClass:[OneViewObject class]] ){
            return YES;
        }
    }
    return NO;
}

//#pragma mark -
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.mirrorVC startCapturing];
}



//
-(void)viewWillDisappear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self.mirrorVC stopCapturing];
    
}

#pragma mark - UIAlertViewDelegate
// Called when a button is clicked. The view will be automatically dismissed after this call returns
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    switch (buttonIndex) {
        case 0://取消按钮
            [self.tbNavigationController popViewControllerAnimated:YES];
            if (self.shouldDownLoadFaceModelBlock) {
                self.shouldDownLoadFaceModelBlock(NO);
            }
            break;
        case 1:
        {
            //
            [self setUpDownloadingView];
            
            //下载文件
            if (self.shouldDownLoadFaceModelBlock) {
                self.shouldDownLoadFaceModelBlock(YES);
            }
        }
            break;
        default:
            break;
    }
    
}

#pragma mark - MirrorViewControllerDelegate

// 始化试妆模块接口将要开始下载算法包
- (void)initWillDownLoadFaceModelWithCallBack:(MirrorShouldDoBlock)shouldDoBolck{
    self.shouldDownLoadFaceModelBlock = shouldDoBolck;
    if ([TBMirrorNetworkUtil isWIFI]) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:@"首次使用需要下载约5MB的素材库，点击确定继续" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        alertView.tag = 0x2213;
        [alertView show];
        
    }
    else {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:@"首次使用需要下载约5MB的素材库，您当前处于非wifi环境，是否继续?" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        alertView.tag = 0x2213;
        [alertView show];
    }
}

// 调用初始化试妆模块接口，返回下载进度
- (void)initMakeUpModuleDidDownloadArithmeticSetProgress:(float)progress percentage:(NSInteger)percentage{
    _progerssLabel.text = [NSString stringWithFormat:@"%ld%@",(long)percentage,@"%"];
    _progressView.progress = progress;
}

// 调用初始化试妆模块接口，成功后调用此回调
- (void)initMakeUpModuleDidSuccess{
    //process download view
    [_progerssTipsLabel removeFromSuperview];
    [_progerssLabel removeFromSuperview];
    [_bgView removeFromSuperview];
    [_progressView removeFromSuperview];
    [_cancelBtn removeFromSuperview];
    
    [self initFinished];
}

// 调用初始化试妆模块接口，失败后调用此回调，error.code详见kMirrorMakeUpErrorType
- (void)initMakeUpModuleDidFailedWithError:(NSError *)error{
    //process download view
    [_progerssTipsLabel removeFromSuperview];
    [_progerssLabel removeFromSuperview];
    [_bgView removeFromSuperview];
    [_progressView removeFromSuperview];
    [_cancelBtn removeFromSuperview];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"加载失败，请重试" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    [alert show];
    
    [self initFailed:error.domain];
}



// 设置试妆参数成功，开始渲染
- (void)makeUpDidSuccess{
    [self.hudView animateToHide];
    [self.mbHud hide:YES];
    
    [TBHint toast:@"上妆成功" toView:self.view];
    if (self.windVaneCallback) {
        self.windVaneCallback(MSG_RET_SUCCESS,nil);
    }
    
}

// 设置试妆参数失败，返回错误信息，error.code详见kMirrorMakeUpErrorType
- (void)makeUpDidFailedWithError:(NSError *)error{
    [self.hudView animateToHide];
    [self.mbHud hide:YES];
    [TBHint toast:@"上妆失败" toView:self.view];
    
    TBMirrorResult *result = [[TBMirrorResult alloc] init];
    result.succeed = NO;
    result.errrorCode = [NSString stringWithFormat:@"%ld",error.code];
    result.errorMsg = error.domain;
    if (self.windVaneCallback) {
        self.windVaneCallback(MSG_RET_FAILED,[result toDic]);
    }
}

// 设置美颜参数成功，开始回调
- (void)beautyDidSuccess{
    
}

// 设置美颜参数失败，返回错误信息，error.code详见kMirrorMakeUpErrorType
- (void)beautyDidFailedWithError:(NSError *)error{
    
}



/////////////////////////////////////////////
-(void)initFinished{
    
    [self.view bringSubviewToFront:self.webView];
    //根据配置中心配置是否美颜
    NSDictionary *configDic = [[TBMirrorConfigCenter sharedInstance] getConfigGroup];
    if (configDic) {
        BOOL isBeauty = [[configDic objectForKey:TBMIRROR_CONFIG_KEY_BEAUTY_SWITCH] boolValue];
        if (isBeauty) {
            [self beauty];
            
        }
    }
    
    
    __weak __typeof(self) weakSelf = self;
    [UIView animateWithDuration:0.5f animations:^{
        __strong __typeof(weakSelf) strongSelf = weakSelf;
        CGRect webViewFrame = CGRectMake(0, strongSelf.view.frame.size.height-strongSelf.wvWebViewHeight, strongSelf.view.frame.size.width, strongSelf.wvWebViewHeight);
        strongSelf.webView.frame = webViewFrame;
        strongSelf.barView.frame = CGRectMake(0, strongSelf.view.frame.size.height-strongSelf.wvWebViewHeight-40*HEIGHT_SCALE, strongSelf.view.frame.size.width, 40*HEIGHT_SCALE);
        [strongSelf.view addSubview:strongSelf.barView];
        
        strongSelf.webViewFold = NO;
        
    }];
    
    switch (_makeUpType) {
        case TBMirrorCosmeticTypePhoto:{
            UIWindow *window = [[UIApplication sharedApplication].delegate window];
            [TBHint toast:@"加载完毕，赶快拍张美美的照片试试吧!" toView:window displaytime:3];
        }
            break;
        case TBMirrorMakeUpTypeVideo:
            [TBHint toast:@"加载完毕，镜头对着自己立马试试吧!" toView:self.view];
            break;
        default:
            break;
    }
    
    
}

-(void)initFailed:(NSString *)errorCode{
    NSString *msg;
    if ([TBMirrorNetworkUtil isWIFI]) {
        msg = @"亲，算法初始化失败，确定重新下载算法包吗?";
    }else{
        msg = @"亲，算法初始化失败，您现在处于非wifi环境，确定重新下载算法包吗?";
    }
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:msg delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        [alert show];
    });
}


#pragma mark - 内存回收

-(void)viewDidUnload{
    [self clear];
    [super viewDidUnload];
}

-(void)clear{
    
    _bgView = nil;
    _progressView = nil;
    _progerssTipsLabel = nil;
    _progerssLabel = nil;
    _cancelBtn = nil;
    
    if (![self isWebViewReleased]) {
        [self releaseWebView];
    }
    self.webView = nil;
    
    _cacheKeyFaceModel = nil;
    if (_mirrorVC) {
        [_mirrorVC willMoveToParentViewController:nil];
        [_mirrorVC.view removeFromSuperview];
        [_mirrorVC removeFromParentViewController];
        [_mirrorVC clear];
        _mirrorVC = nil;
    }
    _barView = nil;
    _windVaneCallback = nil;
    
}

-(void)dealloc{
    NSLog(@"TBMagicMirrorViewController dealloc!!!");
    [self clear];
    
}

@end
