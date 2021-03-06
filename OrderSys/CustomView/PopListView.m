//
//  PopView.m
//  OrderSys
//
//  Created by Macx on 15/8/19.
//  Copyright (c) 2015年 北京星辰万合. All rights reserved.
//

#import "PopListView.h"

/**
 * 自定义弹出列表窗
 **/
@implementation PopListView

@synthesize delegate;

- (instancetype)initWithFrame:(CGRect)frame withShowView:(UILabel *) showView withArray:(NSArray *) datas withBackgroundColor:(UIColor *) backColor
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor = backColor;
        [self.layer setCornerRadius:5.0];
        _showView = showView;
        _datas = datas;
        
        [self addTypesLabels];
    }
    return self;
}

//添加列表项
- (void) addTypesLabels {
    for(int i=0; i<[_datas count]; i++) {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0.5+(ROW_HEIGHT + 0.5) * i, self.frame.size.width, ROW_HEIGHT)];
        UIView *divider = [[UIView alloc] initWithFrame:CGRectMake(20, ROW_HEIGHT * (i+1), self.frame.size.width - 40, 0.5)];
        divider.backgroundColor = [UIColor whiteColor];
        label.textAlignment = NSTextAlignmentCenter;
        label.text = [_datas objectAtIndex:i];
        label.textColor = [UIColor whiteColor];
        label.userInteractionEnabled = YES;
        label.tag = i;
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickTypesLabels:)];
        [label addGestureRecognizer:singleTap];
        [self addSubview:label];
        if (i != [_datas count] - 1) {
            [self addSubview:divider];
        }
    }
}

//类型选择事件
-(void)clickTypesLabels:(id)sender{
    UIGestureRecognizer *gesture = (UIGestureRecognizer*)sender;
    NSInteger tag = [gesture view].tag;
    _type = tag;
    if (_showView != nil) {
        _showView.text = [_datas objectAtIndex:tag];
    }
    [self setHidden:YES];
    [delegate clickItem:tag];
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
