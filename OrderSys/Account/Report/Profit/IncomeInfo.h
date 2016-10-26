//
//  IncomeInfo.h
//  OrderSys
//
//  Created by Macx on 15/8/27.
//  Copyright (c) 2015年 北京星辰万合. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IncomeInfo : NSObject

@property(nonatomic,assign) NSInteger incomeId; //ID
@property(nonatomic,retain) NSString *Name; //名称
@property(nonatomic,retain) NSString *Time; //时间	时间或时长
@property(nonatomic,assign) NSInteger Money; //金额
@property(nonatomic,assign) NSInteger SalesVolume; //销量
@property(nonatomic,assign) double Ratio; //占比
@property(nonatomic,assign) NSInteger MoneyLunch; //中餐收入
@property(nonatomic,assign) NSInteger MoneyDinner; //晚餐收入
@property(nonatomic,assign) NSInteger Table; //桌号
@property(nonatomic,assign) NSInteger Rockover; //翻台次数

@end
