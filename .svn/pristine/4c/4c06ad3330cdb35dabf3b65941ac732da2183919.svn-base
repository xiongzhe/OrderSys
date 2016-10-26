//
//  ListHeadView.m
//  OrderSys
//
//  Created by Macx on 15/8/5.
//  Copyright (c) 2015年 北京星辰万合. All rights reserved.
//

#import "ListHeadView.h"

/**
 * 自定义列表头标识视图
 **/
@implementation ListHeadView

- (instancetype)initWithFrame:(CGRect)frame withNamesArray:(NSArray *) names withPercentArray:(NSArray *) percents
{
    self = [super init];
    if (self) {
        
        [self setFrame:frame];
        self.layer.borderWidth = 0.5;
        self.layer.borderColor = RGBColorWithoutAlpha(226, 229, 228).CGColor;
        self.backgroundColor = RGBColorWithoutAlpha(226, 229, 228);
        
        //1
        UILabel *oneLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, (frame.size.width - 20) * [[percents objectAtIndex:0] floatValue], frame.size.height)];
        oneLabel.backgroundColor = [UIColor clearColor];
        oneLabel.textAlignment = NSTextAlignmentCenter;
        oneLabel.font = [UIFont systemFontOfSize:15.0];
        oneLabel.textColor = RGBColorWithoutAlpha(100, 100, 100);
        oneLabel.text = [names objectAtIndex:0];
        [self addSubview:oneLabel];
        
        //2
        UILabel *twoLabel = [[UILabel alloc] initWithFrame:CGRectMake(oneLabel.frame.origin.x + oneLabel.frame.size.width, 0, (frame.size.width - 20)  * [[percents objectAtIndex:1] floatValue], frame.size.height)];
        twoLabel.backgroundColor = [UIColor clearColor];
        twoLabel.textAlignment = NSTextAlignmentCenter;
        twoLabel.font = [UIFont systemFontOfSize:15.0];
        twoLabel.textColor = RGBColorWithoutAlpha(100, 100, 100);
        twoLabel.text = [names objectAtIndex:1];
        [self addSubview:twoLabel];
        
        //3
        UILabel *threeLabel = [[UILabel alloc] initWithFrame:CGRectMake(twoLabel.frame.origin.x + twoLabel.frame.size.width, 0, (frame.size.width - 20)  * [[percents objectAtIndex:2] floatValue], frame.size.height)];
        threeLabel.backgroundColor = [UIColor clearColor];
        threeLabel.textAlignment = NSTextAlignmentCenter;
        threeLabel.font = [UIFont systemFontOfSize:15.0];
        threeLabel.textColor = RGBColorWithoutAlpha(100, 100, 100);
        threeLabel.text = [names objectAtIndex:2];
        [self addSubview:threeLabel];
        
        //4
        UILabel *fourLabel = [[UILabel alloc] initWithFrame:CGRectMake(threeLabel.frame.origin.x + threeLabel.frame.size.width, 0, (frame.size.width - 20)  * [[percents objectAtIndex:3] floatValue], frame.size.height)];
        fourLabel.backgroundColor = [UIColor clearColor];
        fourLabel.textAlignment = NSTextAlignmentCenter;
        fourLabel.font = [UIFont systemFontOfSize:15.0];
        fourLabel.textColor = RGBColorWithoutAlpha(100, 100, 100);
        fourLabel.text = [names objectAtIndex:3];
        [self addSubview:fourLabel];
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
