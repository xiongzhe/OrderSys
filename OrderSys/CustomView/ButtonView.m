//
//  ButtonView.m
//  OrderSys
//
//  Created by Macx on 15/8/6.
//  Copyright (c) 2015年 北京星辰万合. All rights reserved.
//

#import "ButtonView.h"

/**
 * 自定义是否点击按钮
 **/
@implementation ButtonView

- (instancetype)initWithFrame:(CGRect)frame withType:(NSInteger) isChoose withTag:(NSInteger) tag withTitle:(NSString *) title {
    self = [super init];
    if (self) {
        
        self.isChoose = isChoose;
        
        [self setFrame:frame];
        [self setTitle:title forState:UIControlStateNormal];
        self.tag = tag;
        
        [self setChooseType:isChoose];
    }
    return self;
}

//设置当前按钮状态
- (void) setChooseType:(NSInteger) isChoose {
    if (isChoose == 0) { //未选中 文字灰色 边框红色 背景白色
        [self setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        self.titleLabel.font = [UIFont systemFontOfSize:16.0];
        self.layer.cornerRadius = 5;
        self.layer.borderColor = [UIColor redColor].CGColor;
        self.layer.borderWidth = 1;
        self.backgroundColor = [UIColor whiteColor];
    } else if (isChoose == 1) { //文字白色 无边框 背景红色
        [self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        self.titleLabel.font = [UIFont systemFontOfSize:16.0];
        self.layer.cornerRadius = 5;
        self.layer.borderWidth = 0;
        self.backgroundColor = [UIColor redColor];
    } else if (isChoose == 2) { // 文字红色 边框红色 背景白色
        [self setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        self.titleLabel.font = [UIFont systemFontOfSize:16.0];
        self.layer.cornerRadius = 5;
        self.layer.borderColor = [UIColor redColor].CGColor;
        self.layer.borderWidth = 1;
        self.backgroundColor = [UIColor whiteColor];
    } else { // 文字白色 无边框 背景灰色
        [self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        self.titleLabel.font = [UIFont systemFontOfSize:16.0];
        self.layer.cornerRadius = 5;
        self.layer.borderWidth = 0;
        self.backgroundColor = [UIColor grayColor];
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
