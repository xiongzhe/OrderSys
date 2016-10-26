//
//  FlowsTypeListObj.h
//  OrderSys
//
//  Created by Macx on 15/8/27.
//  Copyright (c) 2015年 北京星辰万合. All rights reserved.
//

#import <Foundation/Foundation.h>

//我的收入/支出类型列表
@interface FlowsTypeListObj : NSObject

+ (NSArray *) getTypeRetList;

+ (NSArray *)getTypeList;

+ (NSArray *)getTypeNumList;

@end
