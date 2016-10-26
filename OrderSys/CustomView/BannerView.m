//
//  BannerView.m
//  OrderSys
//
//  Created by Macx on 15/8/19.
//  Copyright (c) 2015年 北京星辰万合. All rights reserved.
//

#import "BannerView.h"

/**
 * 自定义点击通栏视图
 **/
@implementation BannerView

- (instancetype)initWithFrame:(CGRect)frame withImage:(NSString *) imageName withTitle:(NSString *) title withTitleEdgeInsets:(UIEdgeInsets) titleEdgeInsets withImageEdgeInsets:(UIEdgeInsets) imagEdgeInsets withButtonWidth:(CGFloat) buttonWidth
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        self.userInteractionEnabled = YES;
        
        UIButton *profitButton = [[UIButton alloc] initWithFrame:CGRectMake(10, 0, buttonWidth, ROW_HEIGHT)];
        profitButton.userInteractionEnabled = NO;
        [profitButton setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
        profitButton.titleLabel.font = [UIFont systemFontOfSize:16.0];
        [profitButton setTitle:title forState:UIControlStateNormal];
        [profitButton setTitleColor:RGBColorWithoutAlpha(100, 100, 100) forState:UIControlStateNormal];
        profitButton.titleEdgeInsets = titleEdgeInsets;
        profitButton.imageEdgeInsets = imagEdgeInsets;
        
        UIButton *profitButton1Button = [[UIButton alloc] initWithFrame:CGRectMake(frame.size.width - 40, 0, 40, frame.size.height)];
        [profitButton1Button setImage:[UIImage imageNamed:@"more_info_icon"] forState:UIControlStateNormal];
        profitButton1Button.userInteractionEnabled = NO;
        
        [self addSubview:profitButton];
        [self addSubview:profitButton1Button];
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
