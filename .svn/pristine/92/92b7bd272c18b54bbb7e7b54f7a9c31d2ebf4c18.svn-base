//
//  IsNetworkUtil.m
//  Helper96156User
//
//  Created by Macx on 15/3/9.
//  Copyright (c) 2015年 北京星辰万合. All rights reserved.
//

#import "IsNetworkUtil.h"
#import "Reachability.h"

@implementation IsNetworkUtil


//判断是否有网
+ (BOOL)isNetworkReachable{
    BOOL isExistenceNetwork = YES;
    Reachability *r = [Reachability reachabilityWithHostName:@"www.baidu.com"];
    switch ([r currentReachabilityStatus]) {
        case NotReachable:
            isExistenceNetwork=NO;
            //   NSLog(@"没有网络");
            break;
        case ReachableViaWWAN:
            isExistenceNetwork=YES;
            //   NSLog(@"正在使用3G网络");
            break;
        case ReachableViaWiFi:
            isExistenceNetwork=YES;
            //  NSLog(@"正在使用wifi网络");
            break;
    }
    return isExistenceNetwork;
}


@end
