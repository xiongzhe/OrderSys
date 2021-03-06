//
//  HisOrderInfo.h
//  OrderSys
//
//  Created by Macx on 15/8/18.
//  Copyright (c) 2015年 北京星辰万合. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HisOrderInfo : NSObject

@property(nonatomic,assign) NSInteger orderId; //订单id
@property(nonatomic,retain) NSString *orderNum; //订单编号
@property(nonatomic,retain) NSString *orderTime; //订单编号
@property(nonatomic,assign) NSInteger num; //就餐人数
@property(nonatomic,assign) CGFloat total; //金额

@end
