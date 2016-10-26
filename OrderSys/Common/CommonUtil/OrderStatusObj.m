//
//  OrderStatusObj.m
//  OrderSys
//
//  Created by Macx on 15/8/29.
//  Copyright (c) 2015年 北京星辰万合. All rights reserved.
//

#import "OrderStatusObj.h"

@implementation OrderStatusObj

//Unconfirmed	0	未确认/空闲
//Booking	1	正在点餐
//Confirmed	2	确认
//Dish_Completed	3	配菜完成
//Send_Completed	4	送菜完成
//Checkout	5	已结帐
//RequireCheckout	6	申请结帐
//Lack_After_Dish_Completed	19	配菜完成,有菜品缺货
//Lack_After_Send_Completed	20	送菜完成,有菜品缺货
//Cancel	32	取消虚假订单

+ (NSInteger) getOrderStatusByRet:(NSString *) ret {
    if ([@"Unconfirmed" isEqualToString:ret]) {
        return 0;
    } else if ([@"Booking" isEqualToString:ret]) {
        return 1;
    } else if ([@"Confirmed" isEqualToString:ret]) {
        return 2;
    } else if ([@"Dish_Completed" isEqualToString:ret]) {
        return 3;
    } else if ([@"Send_Completed" isEqualToString:ret]) {
        return 4;
    } else if ([@"Checkout" isEqualToString:ret]) {
        return 5;
    } else if ([@"RequireCheckout" isEqualToString:ret]) {
        return 6;
    } else if ([@"Lack_After_Dish_Completed" isEqualToString:ret]) {
        return 19;
    } else if ([@"Lack_After_Send_Completed" isEqualToString:ret]) {
        return 20;
    } else if ([@"Cancel" isEqualToString:ret]) {
        return 32;
    } else {
        return 0;
    }
}

@end
