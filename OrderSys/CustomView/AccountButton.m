//
//  AccountButton.m
//  OrderSys
//
//  Created by Macx on 15/8/7.
//  Copyright (c) 2015年 北京星辰万合. All rights reserved.
//

#import "AccountButton.h"

/**
 * 自定义账户管理首页按钮
 **/
@implementation AccountButton

- (id)initWithFrame:(CGRect)frame withName:(NSString *) name withImage:(NSString *) image withTag:(NSInteger) tag
{
    self = [super initWithFrame:frame];
    
    if (self) {
        self.layer.borderWidth = 0.5;
        self.layer.borderColor = RGBColorWithoutAlpha(220, 220, 220).CGColor;
        self.backgroundColor = [UIColor clearColor];
        [self setTitle:name forState:UIControlStateNormal];
        [self setTitleColor:RGBColorWithoutAlpha(100, 100, 100) forState:UIControlStateNormal];
        [self setImage:[UIImage imageNamed:image] forState:UIControlStateNormal];
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        self.titleLabel.font = [UIFont systemFontOfSize:16.0];
        self.imageView.contentMode = UIViewContentModeScaleToFill;
        self.tag = tag;
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
