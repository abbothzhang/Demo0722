//
//  HorizontalTableView.m
//  Demo0722
//
//  Created by albert on 15/7/22.
//  Copyright (c) 2015年 alibaba. All rights reserved.
//

#import "TBMirrorSkuView.h"
#import "TBMirrorSkuModel.h"
#import "TBMirrorDetailTableCell.h"
#import "TBMirrorSkuViewHead.h"
#import "UIColor+Hex.h"

#define TBMIRROR_SKUVIEW_HEIGHT                 189
#define TBMIRROR_SKUVIEW_HEADER_HEIGHT          45

#define TBMIRROR_CELL_HEIGHT                    78
#define TBMIRROR_TABLE_HEIGHT                   40
#define TBMIRROR_SKUVIEW_MARGIN_LEFT            12

#define WITH_SCALE                              1

#define TBMIRROR_COLOR_ORANGE                   [UIColor colorWithHex:0xff5000]
#define TBMIRROR_COLOR_GRAY_LIGHT               [UIColor colorWithHex:0xf5f5f5]
#define TBMIRROR_COLOR_GRAY_DARK                [UIColor colorWithHex:0x051b28]


@interface TBMirrorSkuView()<UITableViewDataSource,UITableViewDelegate,TBMirrorSkuViewHeadDelegate>{
    CGFloat   TBMIRROR_SKUVIEW_UNFOLD_ORIGIN_Y;
}

//data
@property (nonatomic,strong) NSDictionary               *itemDic;
@property (nonatomic,strong) NSArray                    *fristTableArray;
@property (nonatomic,strong) NSArray                    *secondTableArray;

//view
@property (nonatomic,strong) TBMirrorSkuViewHead        *headView;
@property (nonatomic,strong) UILabel                    *fristPropNameLabel;//第一个属性名
@property (nonatomic,strong) UITableView                *fristTableView;
@property (nonatomic,strong) UILabel                    *secondPropNameLabel;//第二个属性名
@property (nonatomic,strong) UITableView                *secondTableView;

//记录第一栏上一次的点击
@property (nonatomic) NSInteger                        fristTablePreClickIndex;
@property (nonatomic,strong) UILabel                   *fristTablePreClickBtn;
//记录第二栏上一次的点击
@property (nonatomic) NSInteger                        secondTablePreClickIndex;
@property (nonatomic,strong) UILabel                   *secondTablePreClickBtn;






@end

@implementation TBMirrorSkuView


-(void)setData:(NSDictionary *)data{
    self.itemDic = data;
    self.fristTableArray = [self.itemDic allKeys];
    TBMIRROR_SKUVIEW_UNFOLD_ORIGIN_Y = self.frame.origin.y;
    self.frame = CGRectMake(0, TBMIRROR_SKUVIEW_UNFOLD_ORIGIN_Y, self.frame.size.width, TBMIRROR_SKUVIEW_HEIGHT);
    [self setUpView];

}


-(void)setUpView{
    [self addSubview:self.headView];
    self.headView.price = @"888";//test
    [self addSubview:self.fristPropNameLabel];
    [self addSubview:self.fristTableView];
    [self addSubview:self.secondPropNameLabel];
    [self addSubview:self.secondTableView];
}




#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (tableView == self.fristTableView) {
        return [self.itemDic count];
    }else{
        return [self.secondTableArray count];
    }
    
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    CGFloat cellHeight = TBMIRROR_CELL_HEIGHT;
    if (tableView == self.fristTableView) {
        NSString *title = [self.fristTableArray objectAtIndex:indexPath.row];
        CGRect labelFrame = CGRectMake(0, 0, 66*WITH_SCALE, 27);
        UILabel *label = [[UILabel alloc] initWithFrame:labelFrame];
        label.text = title;
        [label sizeToFit];
        if (label.frame.size.width > cellHeight) {
            cellHeight = label.frame.size.width+10;
        }
    }
    
    return cellHeight;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (tableView == self.fristTableView) {
        static NSString *TBMIRROR_TABLE1_REUSE = @"TBMIRROR_TABLE1_REUSE";
        TBMirrorDetailTableCell *cell = [tableView dequeueReusableCellWithIdentifier:TBMIRROR_TABLE1_REUSE];
        if (cell == nil) {
            cell = [[TBMirrorDetailTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:TBMIRROR_TABLE1_REUSE];
        }
        
        NSString *title = [self.fristTableArray objectAtIndex:indexPath.row];
//        cell remove
        NSArray *subViews = [cell.contentView subviews];
        for (UIView *subView in subViews) {
            [subView removeFromSuperview];
        }
        [cell.contentView addSubview:[self getCellLabelWithTitle:title indexPath:indexPath tableView:tableView]];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.contentView.transform = CGAffineTransformMakeRotation(M_PI / 2);
        
        
        return cell;
    }else{
        
        static NSString *TBMIRROR_TABLE2_REUSE = @"TBMIRROR_TABLE2_REUSE";
        TBMirrorDetailTableCell *cell = [tableView dequeueReusableCellWithIdentifier:TBMIRROR_TABLE2_REUSE];
        if (cell == nil) {
            cell = [[TBMirrorDetailTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:TBMIRROR_TABLE2_REUSE];
        }
        
        TBMirrorSkuModel *skuModel = [self.secondTableArray objectAtIndex:indexPath.row];
        NSString *title = skuModel.cspuId;
        
        NSArray *subViews = [cell.contentView subviews];
        for (UIView *subView in subViews) {
            [subView removeFromSuperview];
        }
        
        [cell.contentView addSubview:[self getCellLabelWithTitle:title indexPath:indexPath tableView:tableView]];
//        cell.contentView.backgroundColor = [UIColor orangeColor];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.contentView.transform = CGAffineTransformMakeRotation(M_PI / 2);
        
        return cell;
    }
}

-(UILabel*)getCellLabelWithTitle:(NSString *)title indexPath:(NSIndexPath *)indexPath tableView:(UITableView *)tableView{
    CGRect labelFrame = CGRectMake(0, 0, 66*WITH_SCALE, 27);
    UILabel *label = [[UILabel alloc] initWithFrame:labelFrame];
    label.text = title;
    label.center = CGPointMake(TBMIRROR_CELL_HEIGHT/2,TBMIRROR_TABLE_HEIGHT/2);
    [label sizeToFit];
    if (label.frame.size.width < 66*WITH_SCALE) {
        label.frame = labelFrame;
        label.center = CGPointMake(TBMIRROR_CELL_HEIGHT/2,TBMIRROR_TABLE_HEIGHT/2);
    }else{
        label.frame = CGRectMake(label.frame.origin.x, label.frame.origin.y, label.frame.size.width, 27);
    }
    
    label.font = [UIFont systemFontOfSize:12];
    label.textColor = TBMIRROR_COLOR_GRAY_DARK;
    label.backgroundColor = TBMIRROR_COLOR_GRAY_LIGHT;
    label.layer.cornerRadius = 10.f;
    label.layer.masksToBounds = YES;
    label.textAlignment = NSTextAlignmentCenter;
    label.tag = 111;
    
    //第一个默认选上
    NSInteger clickIndex;
    if (tableView == self.fristTableView) {
        clickIndex = _fristTablePreClickIndex;
    }else{
        clickIndex = _secondTablePreClickIndex;
    }
    
    if (indexPath.row == clickIndex) {
        label.textColor = [UIColor whiteColor];
        label.backgroundColor = TBMIRROR_COLOR_ORANGE;
        if (tableView == self.fristTableView) {
            _fristTablePreClickBtn = label;
        }else{
            _secondTablePreClickBtn = label;
        }

    }
    
    return label;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    TBMirrorDetailTableCell *cell = (TBMirrorDetailTableCell*)[tableView cellForRowAtIndexPath:indexPath];
    UILabel *propLabel = (UILabel*)[cell.contentView viewWithTag:111];
    
    //只要选中自己颜色，就是选中的样式
    propLabel.backgroundColor = TBMIRROR_COLOR_ORANGE;
    propLabel.textColor = [UIColor whiteColor];
    
    if (tableView == self.fristTableView) {
        //改变上一次点击的状态，如果上次和这次点击的是同一个label，那么不做处理
        //如果点击的不是自己，即这一次点击的是另一个按钮，那么要改变之前点击的那个按钮的状态
        _fristTablePreClickIndex = indexPath.row;
        if (_fristTablePreClickBtn == nil) {
            _fristTablePreClickBtn = propLabel;
        }
        if (propLabel != _fristTablePreClickBtn) {
            _fristTablePreClickBtn.backgroundColor = TBMIRROR_COLOR_GRAY_LIGHT;
            _fristTablePreClickBtn.textColor = TBMIRROR_COLOR_GRAY_DARK;
            _fristTablePreClickBtn = propLabel;

        }
        
        //设置secondTableView
        _secondTablePreClickIndex = 0;
        NSString *secondTableArrayKey = [self.fristTableArray objectAtIndex:indexPath.row];
        self.secondTableArray = [self.itemDic objectForKey:secondTableArrayKey];
        self.secondTableView = nil;
        [self.secondTableView removeFromSuperview];
        [self addSubview:self.secondTableView];
        //[self.secondTableView reloadData];//不能用reload，之前的view还在，通过viewWithTag取到的View不是当前的
        

    }else{
        //改变上一次点击的状态，如果上次和这次点击的是同一个label，那么不做处理
        //如果点击的不是自己，即这一次点击的是另一个按钮，那么要改变之前点击的那个按钮的状态
        _secondTablePreClickIndex = indexPath.row;
        if (_secondTablePreClickBtn == nil) {
            _secondTablePreClickBtn = propLabel;
        }
        if (propLabel != _secondTablePreClickBtn) {
            _secondTablePreClickBtn.backgroundColor = TBMIRROR_COLOR_GRAY_LIGHT;
            _secondTablePreClickBtn.textColor = TBMIRROR_COLOR_GRAY_DARK;
            _secondTablePreClickBtn = propLabel;
            
        }
        
        //上妆

        
    }

}

#pragma mark - TBMirrorSkuViewHeadDelegate
-(void)arrowBtnClicked:(BOOL)isFold{
    if (isFold) {
        TBMirrorSkuView __weak *weakSelf = self;
        [UIView animateWithDuration:0.5f animations:^{
           weakSelf.frame = CGRectMake(0, TBMIRROR_SKUVIEW_UNFOLD_ORIGIN_Y, self.frame.size.width, TBMIRROR_SKUVIEW_HEIGHT);

        }];
        
    }else{
        TBMirrorSkuView __weak *weakSelf = self;
        [UIView animateWithDuration:0.5f animations:^{
            CGFloat originY = TBMIRROR_SKUVIEW_UNFOLD_ORIGIN_Y + (TBMIRROR_SKUVIEW_HEIGHT - TBMIRROR_SKUVIEW_HEADER_HEIGHT);
            weakSelf.frame = CGRectMake(0,originY, self.frame.size.width, TBMIRROR_SKUVIEW_HEADER_HEIGHT);
        }];
        
    }
}

-(void)buyBtnClicked{
    if (self.delegate && [self.delegate respondsToSelector:@selector(buyBtnClicked)]) {
        [self.delegate buyBtnClicked];
    }
}

#pragma mark - getter
-(TBMirrorSkuViewHead *)headView{
    if (_headView == nil) {
        _headView = [[TBMirrorSkuViewHead alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, TBMIRROR_SKUVIEW_HEADER_HEIGHT)];
        _headView.delegate = self;
    }
    return _headView;
}

-(UILabel *)fristPropNameLabel{
    if (_fristPropNameLabel == nil) {
        CGFloat originY = self.headView.frame.origin.x + self.headView.frame.size.height+12;
        _fristPropNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(TBMIRROR_SKUVIEW_MARGIN_LEFT, originY, 200, 14)];
        _fristPropNameLabel.font = [UIFont systemFontOfSize:14.f];
        _fristPropNameLabel.textColor = TBMIRROR_COLOR_GRAY_DARK;
//        _fristPropNameLabel.backgroundColor = [UIColor greenColor];//test
        _fristPropNameLabel.text = @"款式";//test
    }
    return _fristPropNameLabel;
}

-(UILabel *)secondPropNameLabel{
    if (_secondPropNameLabel == nil) {
        CGFloat originY = self.fristTableView.frame.origin.y + self.fristTableView.frame.size.height+8;
        _secondPropNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(TBMIRROR_SKUVIEW_MARGIN_LEFT, originY, 200, 14)];
        _secondPropNameLabel.font = [UIFont systemFontOfSize:14.f];
        _secondPropNameLabel.textColor = TBMIRROR_COLOR_GRAY_DARK;
        _secondPropNameLabel.text = @"颜色";//test
    }
    return _secondPropNameLabel;
}

-(UITableView *)fristTableView{
    if (_fristTableView == nil) {
        _fristTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, TBMIRROR_TABLE_HEIGHT, self.frame.size.width-12)];
        _fristTableView.center = CGPointMake(self.frame.size.width/2, 75+TBMIRROR_TABLE_HEIGHT/2);
        _fristTableView.dataSource = self;
        _fristTableView.delegate = self;
//        _fristTableView.backgroundColor = [UIColor yellowColor];
        _fristTableView.showsVerticalScrollIndicator = NO;//隐藏滚动条
        _fristTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _fristTableView.transform = CGAffineTransformMakeRotation(-M_PI / 2);
        //默认第一个选中
        self.secondTableArray = [self.itemDic objectForKey:[self.fristTableArray objectAtIndex:0]];
    }
    return _fristTableView;
}

-(UITableView *)secondTableView{
    if (_secondTableView == nil) {
        _secondTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, TBMIRROR_TABLE_HEIGHT, self.frame.size.width-12)];
        _secondTableView.center = CGPointMake(self.frame.size.width/2, 141+TBMIRROR_TABLE_HEIGHT/2);
        _secondTableView.dataSource = self;
        _secondTableView.delegate = self;
//        _secondTableView.backgroundColor = [UIColor yellowColor];
        _secondTableView.showsVerticalScrollIndicator = NO;//隐藏滚动条
        _secondTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _secondTableView.transform = CGAffineTransformMakeRotation(-M_PI / 2);
        
    }
    return _secondTableView;
}

@end
