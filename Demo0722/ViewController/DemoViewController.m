//
//  DemoViewController.m
//  Demo0722
//
//  Created by albert on 15/7/22.
//  Copyright (c) 2015年 alibaba. All rights reserved.
//

#import "DemoViewController.h"
#import "TBMirrorSkuView.h"
#import "TBMirrorSkuModel.h"
#import "ZHHint.h"
#import "TBMirrorItemModel.h"


@interface DemoViewController ()<TBMirrorSkuViewDelegate>

@end

@implementation DemoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor yellowColor];
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] initWithCapacity:3];
    TBMirrorSkuModel *skuModel = [[TBMirrorSkuModel alloc] init];
    //test
    skuModel.price = @"尺寸";//先暂时用作propName使用
    skuModel.cspuId = @"太阳镜";//先暂时用作sku
    
    NSArray *array1 = [[NSArray alloc] initWithObjects:skuModel,nil];
    NSArray *array2 = [[NSArray alloc] initWithObjects:skuModel,skuModel,nil];
    NSArray *array3 = [[NSArray alloc] initWithObjects:skuModel,skuModel,skuModel,skuModel,nil];
    [dic setObject:array1 forKey:@"oneasdfasfasf"];
    [dic setObject:array2 forKey:@"twoasdfasfasgasdgasdg"];
    [dic setObject:array3 forKey:@"threethreethreethreethreethree"];
//    [dic setObject:array1 forKey:@""];
//    [dic setObject:array2 forKey:@"two2"];
//    [dic setObject:array3 forKey:@"three2"];
//    [dic setObject:array1 forKey:@"one3"];
//    [dic setObject:array2 forKey:@"two3"];
//    [dic setObject:array3 forKey:@"three3"];
//    [dic setObject:array1 forKey:@"one4"];
//    [dic setObject:array2 forKey:@"two4"];
//    [dic setObject:array3 forKey:@"three4"];
    
    //mock data
    //tableview cell数据
        NSMutableArray<TBDetailSkuPropsValuesModel> *propValues1 = (NSMutableArray<TBDetailSkuPropsValuesModel>*)[[NSMutableArray alloc] initWithCapacity:3];
    for (int i = 0; i < 8; i++) {
        TBDetailSkuPropsValuesModel *propValueModel = [[TBDetailSkuPropsValuesModel alloc] init];
        propValueModel.valueId = [NSString stringWithFormat:@"11%d",i];
        propValueModel.name = [NSString stringWithFormat:@"11%d",i];//cell数据
        [propValues1 addObject:propValueModel];
    }
    
    NSMutableArray<TBDetailSkuPropsValuesModel> *propValues2 = (NSMutableArray<TBDetailSkuPropsValuesModel>*)[[NSMutableArray alloc] initWithCapacity:3];
    for (int i = 0; i < 6; i++) {
        TBDetailSkuPropsValuesModel *propValueModel = [[TBDetailSkuPropsValuesModel alloc] init];
        propValueModel.valueId = [NSString stringWithFormat:@"12%d",i];
        propValueModel.name = [NSString stringWithFormat:@"12%d",i];//cell数据
        [propValues2 addObject:propValueModel];
    }

    
    
    NSMutableArray<TBDetailSkuPropsModel> *skuProps = (NSMutableArray<TBDetailSkuPropsModel> *)[[NSMutableArray alloc] initWithCapacity:3];
    
    for (int i = 0; i < 2; i++) {
        //宝贝SKU对应的宝贝属性列表
    }
    
    TBDetailSkuPropsModel *propModel1 = [[TBDetailSkuPropsModel alloc] init];
    propModel1.propId = [NSString stringWithFormat:@"1%d",1];
    propModel1.values = propValues1;
    
    TBDetailSkuPropsModel *propModel2 = [[TBDetailSkuPropsModel alloc] init];
    propModel2.propId = [NSString stringWithFormat:@"1%d",1];
    propModel2.values = propValues2;

    [skuProps addObject:propModel1];
    [skuProps addObject:propModel2];

    

    
    //生成itemId
    TBMirrorItemModel *itemModel = [[TBMirrorItemModel alloc] init];
    itemModel.skuProps = skuProps;//zhmark
    
    
    
    
    
    
    CGRect horiViewFrame = CGRectMake(0, self.view.frame.size.height - 189, self.view.frame.size.width, 189);
    TBMirrorSkuView *horiView = [[TBMirrorSkuView alloc] initWithFrame:horiViewFrame];
    horiView.delegate = self;
    horiView.backgroundColor = [UIColor whiteColor];
//    [horiView setData:dic];
    [horiView setItemModel:itemModel];
    
    [self.view addSubview:horiView];
}

-(void)arrowBtnClicked:(BOOL)isFold{
    NSString *str = [NSString stringWithFormat:@"ifFold->%d",isFold];
    [ZHHint showToast:str];
}

-(void)buyBtnClicked{
    [ZHHint showToast:@"buyClicked"];
}



@end
