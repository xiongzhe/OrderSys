//
//  DishTypeListObj.h
//  OrderSys
//
//  Created by Macx on 15/8/26.
//  Copyright (c) 2015年 北京星辰万合. All rights reserved.
//

#import <Foundation/Foundation.h>

//菜品类型列表
@interface DishTypeListObj : NSObject

+ (void)setTypeList:(NSArray *)str;
+ (NSArray *)getTypeList;

+ (void)setTypeIdList:(NSArray *)str;
+ (NSArray *)getTypeIdList;

@end
