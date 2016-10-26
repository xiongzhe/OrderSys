//
//  SecretUtil.m
//  OrderSys
//
//  Created by Macx on 15/8/21.
//  Copyright (c) 2015年 北京星辰万合. All rights reserved.
//

#import "SecretUtil.h"
#import "NotifyClient.h"

@implementation SecretUtil

//获取时间戳
+ (int) getTimestamp {
    return (int) ([[NSDate date] timeIntervalSince1970]*1000 / 1000) - 1262275200;
}

// 获取mac地址
+ (unsigned long long) getIMac {
    unsigned long long iMac = 1250999896491;
//    unsigned long long iMac = 0x0123456789abULL;
    return iMac;
}

@end
