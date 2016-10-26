//
//  DishTypeListObj.m
//  OrderSys
//
//  Created by Macx on 15/8/26.
//  Copyright (c) 2015年 北京星辰万合. All rights reserved.
//

#import "DishTypeListObj.h"


static NSArray *typeList = nil;
static NSArray *typeIdList = nil;

@implementation DishTypeListObj

//菜品类型列表
+ (void)setTypeList:(NSArray *)dishTypeList
{
    typeList = dishTypeList;
}
+ (NSArray *)getTypeList
{
    return typeList;
}

//菜品类型id列表
+ (void)setTypeIdList:(NSArray *)dishTypeIdList
{
    typeIdList = dishTypeIdList;
}
+ (NSArray *)getTypeIdList
{
    return typeIdList;
}

@end
