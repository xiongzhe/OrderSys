//
//  OrderStatusObj.h
//  OrderSys
//
//  Created by Macx on 15/8/29.
//  Copyright (c) 2015年 北京星辰万合. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * 订单状态
 **/
@interface OrderStatusObj : NSObject

+ (NSInteger) getOrderStatusByRet:(NSString *) ret;

@end
