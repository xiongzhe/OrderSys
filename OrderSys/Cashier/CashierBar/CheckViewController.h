//
//  CheckViewController.h
//  OrderSys
//
//  Created by Macx on 15/7/30.
//  Copyright (c) 2015年 北京星辰万合. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BarNumInfo.h"

@interface CheckViewController : UIViewController

- (instancetype)initWithRIncome:(int) rincome withBarNumInfo:(BarNumInfo *) barNumInfo withIsEnoughCard:(Boolean) IsEnoughCard withOrderId:(NSInteger) orderId withMaling:(Boolean) maling withDiscount:(NSInteger) discount;

@end
