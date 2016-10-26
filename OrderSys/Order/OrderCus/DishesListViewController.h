//
//  DishesListViewController.h
//  OrderSys
//
//  Created by Macx on 15/8/12.
//  Copyright (c) 2015年 北京星辰万合. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BarNumInfo.h"

@interface DishesListViewController : UIViewController

@property (nonatomic, retain) BarNumInfo *barNumInfo; //台号

- (instancetype)initWithBarNum:(BarNumInfo *) barNumInfo withSelectedList:(NSMutableArray *) selectList withOrderId:(NSInteger) orderId;

@end
