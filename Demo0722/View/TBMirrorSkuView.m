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

#define TBMIRROR_CELL_HEIGHT                    78
#define TBMIRROR_TABLE_HEIGHT                   40
#define TBMIRROR_SKUVIEW_MARGIN_LEFT            12

#define WITH_SCALE                              1

@interface TBMirrorSkuView()<UITableViewDataSource,UITableViewDelegate>

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

//记录第一栏上一次点击的按钮
@property (nonatomic,strong) UILabel                   *fristTablePreClickBtn;






@end

@implementation TBMirrorSkuView


-(void)setData:(NSDictionary *)data{
    self.itemDic = data;
    self.fristTableArray = [self.itemDic allKeys];
    [self setUpView];

}


-(void)setUpView{
    [self addSubview:self.headView];
    self.headView.price = @"888";//test
    [self addSubview:self.fristPropNameLabel];
    [self addSubview:self.fristTableView];
//    [self addSubview:self.secondPropNameLabel];
//    [self addSubview:self.secondTableView];
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
//        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 49, 19)];
////        label.backgroundColor = [UIColor orangeColor];
//        label.text = title;
//        label.textAlignment = NSTextAlignmentCenter;
//        UIView *btnView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 50, 20)];
//        label.center = btnView.center;
//        [btnView addSubview:label];
//        btnView.center = CGPointMake(TBMIRROR_TABLE_HEIGHT/2,TBMIRROR_CELL_HEIGHT/2);
//        btnView.tag = 0x111;
//        btnView.backgroundColor = [UIColor redColor];
        
//        UIButton *propBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 66*WITH_SCALE, 27)];
//        propBtn.center = CGPointMake(TBMIRROR_CELL_HEIGHT/2,TBMIRROR_TABLE_HEIGHT/2);
//        propBtn.titleLabel.font = [UIFont systemFontOfSize:12];
//        [propBtn setTitle:title forState:UIControlStateNormal];
//        [propBtn setTitleColor:[UIColor colorWithHex:0x051b28] forState:UIControlStateNormal];
//        propBtn.backgroundColor = [UIColor colorWithHex:0xf5f5f5];
//        //设置边框
//        propBtn.layer.cornerRadius = 10.f;//圆角半径
//        propBtn.tag = 0x111;
        
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
        label.textColor = [UIColor colorWithHex:0x051b28];
        label.backgroundColor = [UIColor colorWithHex:0xf5f5f5];
        label.layer.cornerRadius = 10.f;
        label.layer.masksToBounds = YES;
        label.textAlignment = NSTextAlignmentCenter;
        label.tag = 0x111;
        
        [cell.contentView addSubview:label];
//        cell.contentView.backgroundColor = [UIColor orangeColor];
//        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.contentView.transform = CGAffineTransformMakeRotation(M_PI / 2);

        
        return cell;
    }else{
        
        static NSString *TBMIRROR_TABLE2_REUSE = @"TBMIRROR_TABLE2_REUSE";
        TBMirrorDetailTableCell *cell = [tableView dequeueReusableCellWithIdentifier:TBMIRROR_TABLE2_REUSE];
        if (cell == nil) {
            cell = [[TBMirrorDetailTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:TBMIRROR_TABLE2_REUSE];
        }
        
//        TBMirrorSkuModel *skuModel = [self.secondTableArray objectAtIndex:indexPath.row];
//        NSString *btnTitle = skuModel.name;
//        [cell.btn setTitle:btnTitle forState:UIControlStateNormal];
        
        return cell;
    }
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (tableView == self.fristTableView) {
        NSString *secondTableArrayKey = [self.fristTableArray objectAtIndex:indexPath.row];
        self.secondTableArray = [self.itemDic objectForKey:secondTableArrayKey];
        [self.secondTableView reloadData];
        TBMirrorDetailTableCell *cell = (TBMirrorDetailTableCell*)[tableView cellForRowAtIndexPath:indexPath];
        UILabel *propBtn = (UILabel*)[cell.contentView viewWithTag:0x111];
        propBtn.backgroundColor = [UIColor greenColor];
        if (_fristTablePreClickBtn == nil) {
            _fristTablePreClickBtn = propBtn;
        }else{
            _fristTablePreClickBtn.backgroundColor = [UIColor redColor];
            _fristTablePreClickBtn = propBtn;
        }
        

    }else{
       //上妆
        
    }

}

#pragma mark - getter
-(TBMirrorSkuViewHead *)headView{
    if (_headView == nil) {
        _headView = [[TBMirrorSkuViewHead alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 45)];
    }
    return _headView;
}

-(UILabel *)fristPropNameLabel{
    if (_fristPropNameLabel == nil) {
        CGFloat originY = self.headView.frame.origin.x + self.headView.frame.size.height+12;
        _fristPropNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(TBMIRROR_SKUVIEW_MARGIN_LEFT, originY, 200, 14)];
        _fristPropNameLabel.font = [UIFont systemFontOfSize:14.f];
        _fristPropNameLabel.textColor = [UIColor colorWithHex:0x051b28];
//        _fristPropNameLabel.backgroundColor = [UIColor greenColor];//test
        _fristPropNameLabel.text = @"款式";//test
    }
    return _fristPropNameLabel;
}

-(UILabel *)secondPropNameLabel{
    if (_secondPropNameLabel == nil) {
        CGFloat originY = self.fristTableView.frame.origin.x + self.fristTableView.frame.size.height+15;
        _secondPropNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(TBMIRROR_SKUVIEW_MARGIN_LEFT, originY, 200, 14)];
        _secondPropNameLabel.font = [UIFont systemFontOfSize:14.f];
        _secondPropNameLabel.textColor = [UIColor colorWithHex:0x051b28];
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
        _fristTableView.backgroundColor = [UIColor yellowColor];
        _fristTableView.showsVerticalScrollIndicator = NO;//隐藏滚动条
        _fristTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _fristTableView.transform = CGAffineTransformMakeRotation(-M_PI / 2);
    }
    return _fristTableView;
}

-(UITableView *)secondTableView{
    if (_secondTableView == nil) {
        _secondTableView = [[UITableView alloc] initWithFrame:CGRectMake(0,  160, self.frame.size.width, 80)];
        _secondTableView.dataSource = self;
        _secondTableView.delegate = self;
        _secondTableView.backgroundColor = [UIColor greenColor];
//        _secondTableView.transform = CGAffineTransformMakeRotation(-M_PI / 2);
    }
    return _secondTableView;
}

@end
