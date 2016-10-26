//
//  ProfitInfoViewController.h
//  OrderSys
//
//  Created by Macx on 15/8/3.
//  Copyright (c) 2015年 北京星辰万合. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProfitInfoViewController : UIViewController

@property(nonatomic,assign) int type; // 0 收入分析 1 支出分析 2 毛利分析

- (instancetype)initWithType:(int)type withStime:(NSString *) stime withEtime:(NSString *) etime;

@end
