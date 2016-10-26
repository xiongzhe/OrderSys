//
//  DishesListTypeInfo.h
//  OrderSys
//
//  Created by Macx on 15/8/13.
//  Copyright (c) 2015年 北京星辰万合. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DishesListTypeInfo : NSObject

@property(nonatomic,assign) NSInteger typeId; //菜品类型id
@property(nonatomic,retain) NSString *name; //菜名类型名
@property(nonatomic,assign) NSInteger num; //已点数量
@property(nonatomic,assign) NSInteger isSelect; //是否被选中 0 没选中 1 选中

@end
