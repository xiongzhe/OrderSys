//
//  ScheduleInfo.h
//  OrderSys
//
//  Created by Macx on 15/8/11.
//  Copyright (c) 2015年 北京星辰万合. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ScheduleInfo : NSObject

@property(nonatomic,assign) NSInteger ScheduleId; //日程Id
@property(nonatomic,assign) NSInteger UserId; //UserId
@property(nonatomic,retain) NSString *AlertTime; //日期、时间
@property(nonatomic,retain) NSString *AlterMessage; //内容

@end
