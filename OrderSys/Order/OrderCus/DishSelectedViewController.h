//
//  DishSelectedViewController.h
//  OrderSys
//
//  Created by Macx on 15/8/14.
//  Copyright (c) 2015年 北京星辰万合. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BarNumInfo.h"

@interface DishSelectedViewController : UIViewController

@property (nonatomic, retain) BarNumInfo *barNumInfo; //台号

- (instancetype)initWithSelectedDishes:(NSMutableArray*) selectList withTotal:(CGFloat) total withBarNum:(BarNumInfo *) barNumInfo withOrderId:(NSInteger) orderId;

@end
