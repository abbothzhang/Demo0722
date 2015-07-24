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

@interface DemoViewController ()

@end

@implementation DemoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor yellowColor];
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] initWithCapacity:3];
    TBMirrorSkuModel *skuModel = [[TBMirrorSkuModel alloc] init];
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

    
    CGRect horiViewFrame = CGRectMake(0, self.view.frame.size.height - 189, self.view.frame.size.width, 189);
    TBMirrorSkuView *horiView = [[TBMirrorSkuView alloc] initWithFrame:horiViewFrame];
    horiView.backgroundColor = [UIColor whiteColor];
    [horiView setData:dic];
    [self.view addSubview:horiView];
}





@end
