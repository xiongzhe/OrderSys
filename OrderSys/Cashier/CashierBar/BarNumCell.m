//
//  BarNumCell.m
//  OrderSys
//
//  Created by Macx on 15/7/30.
//  Copyright (c) 2015年 北京星辰万合. All rights reserved.
//

#import "BarNumCell.h"

@implementation BarNumCell


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        //桌号
        self.num = [[UILabel alloc] initWithFrame:CGRectMake(0.0, frame.size.height/2/4, frame.size.width, frame.size.height/2)];
        self.num.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
        self.num.textAlignment = NSTextAlignmentCenter;
        self.num.font = [UIFont boldSystemFontOfSize:18.0];
        self.num.textColor = [UIColor whiteColor];
        
        //状态
        self.status = [[UIButton alloc] initWithFrame:CGRectMake(0.0,self.num.frame.size.height, frame.size.width, frame.size.height/2)];
        self.status.userInteractionEnabled = NO;
        [self.status setImage:[UIImage imageNamed:@"select_yes"] forState:(UIControlStateNormal)];
        
        //添加按钮
        self.addImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        [self.addImage setImage:[UIImage imageNamed:@"add_gray"]];
        [self.addImage setHidden:YES];
        [self.contentView addSubview:self.addImage];

        
        [self.contentView addSubview:self.num];
        [self.contentView addSubview:self.status];
        [self.layer setMasksToBounds:YES];
        self.layer.cornerRadius = 8;
    }
    return self;
}

@end
