//
//  OrderDishDelegate.h
//  OrderSys
//
//  Created by Macx on 15/8/26.
//  Copyright (c) 2015年 北京星辰万合. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * 菜品详情点击协议
 **/
@protocol OrderDishDelegate <NSObject>

- (void) getOrderDishInfo:(OrderDishInfo *) orderDishInfo;

@end
