//
//  BarNumInfo.h
//  OrderSys
//
//  Created by Macx on 15/7/29.
//  Copyright (c) 2015年 北京星辰万合. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BarNumInfo : NSObject

@property(nonatomic,assign) NSInteger barNum; //台号
@property(nonatomic,retain) NSString *barName; //台号名称
@property(nonatomic,assign) NSInteger status;   //餐台状态

@end
 