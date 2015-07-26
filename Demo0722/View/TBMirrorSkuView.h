//
//  HorizontalTableView.h
//  Demo0722
//
//  Created by albert on 15/7/22.
//  Copyright (c) 2015年 alibaba. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TBMirrorSkuViewDelegate <NSObject>

-(void)buyBtnClicked;

@end

@interface TBMirrorSkuView : UIView

@property (nonatomic,strong) id<TBMirrorSkuViewDelegate>            delegate;

-(void)setData:(NSDictionary *)data;

@end
