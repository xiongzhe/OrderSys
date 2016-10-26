//
//  UIDevice.m
//  xzresource
//
//  Created by Macx on 15/6/23.
//  Copyright (c) 2015年 北京星辰万合. All rights reserved.
//

#import "UIDevice.h"



@implementation UIDevice (Resolutions)

+ (CGFloat) windowWidth {
    CGSize result = [[UIScreen mainScreen] bounds].size;
    result = CGSizeMake(result.width * [UIScreen mainScreen].scale, result.height * [UIScreen mainScreen].scale);
    return (result.width >= 640) ? result.width / 2 : result.width;
}

+ (CGFloat) windowHeight {
    CGSize result = [[UIScreen mainScreen] bounds].size;
    result = CGSizeMake(result.width * [UIScreen mainScreen].scale, result.height * [UIScreen mainScreen].scale);
    return (result.height >= 960) ? result.height / 2 : result.height;
}

@end
