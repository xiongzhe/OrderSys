//
//  AccountCell.m
//  OrderSys
//
//  Created by Macx on 15/7/31.
//  Copyright (c) 2015年 北京星辰万合. All rights reserved.
//

#import "AccountCell.h"

@implementation AccountCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        //MLButton
        self.button = [[MLButton alloc] initWithFrame: CGRectMake(0, 0, SCREEN_WIDTH/3 - 5, SCREEN_WIDTH/3)];
        self.button.isIgnoreTouchInTransparentPoint = YES;
        self.button.layer.borderWidth = 0.5;
        self.button.layer.borderColor = RGBColorWithoutAlpha(180, 180, 180).CGColor;
        self.button.backgroundColor = [UIColor clearColor];
        [self.button setTitle:@"北京通" forState:UIControlStateNormal];
        [self.button setTitleColor:RGBColorWithoutAlpha(100, 100, 100) forState:UIControlStateNormal];
        [self.button setImage:[UIImage imageNamed:@"select_yes"] forState:UIControlStateNormal];
        self.button.titleLabel.textAlignment = NSTextAlignmentCenter;
        self.button.titleLabel.font = [UIFont systemFontOfSize:16.0];
        self.button.imageView.contentMode = UIViewContentModeScaleToFill;
        [self.contentView addSubview:self.button];
        
        [self.layer setMasksToBounds:YES];
        self.layer.cornerRadius = 8;
    }
    return self;
}
@end
