//
//  CommonUtil.h
//  OrderSys
//
//  Created by Macx on 15/8/19.
//  Copyright (c) 2015年 北京星辰万合. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CommonUtil : NSObject

+ (void) showAlert:(NSString *) text;

+ (CGFloat)getHeight:(NSString *) content withWidth:(CGFloat) width;

+(Byte *)chineseToHex:(NSString*)chineseStr;

@end
