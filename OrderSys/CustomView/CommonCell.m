//
//  CommonCell.m
//  OrderSys
//
//  Created by Macx on 15/8/6.
//  Copyright (c) 2015年 北京星辰万合. All rights reserved.
//

#import "CommonCell.h"

/**
 * 公共列表cell
 **/
@implementation CommonCell

@synthesize oneLabel, twoLabel, threeLabel, fourLabel, dividerView;

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier withCellHeight:(CGFloat) cellHeight withPercentArray:(NSArray *) percents{
    if (WIDTH_RATE >1 && WIDTH_RATE < 1.5) {
        _width = 375.0;
    }else if(WIDTH_RATE>1.5){
        _width = 621.0;
    }else if(WIDTH_RATE ==1){
        _width = 320.0;
    }else{
        //_width = 100;
    }
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self){
        
        //1
        self.oneLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, (_width - 20) *[[percents objectAtIndex:0] floatValue], cellHeight - 0.5)];
        self.oneLabel.backgroundColor = [UIColor clearColor];
        self.oneLabel.textAlignment = NSTextAlignmentCenter;
        self.oneLabel.textColor = RGBColorWithoutAlpha(100, 100, 100);
        self.oneLabel.font = [UIFont systemFontOfSize:14.0];
        [self.contentView addSubview:self.oneLabel];
        
        //2
        self.twoLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.oneLabel.frame.origin.x + self.oneLabel.frame.size.width, 0, (_width - 20) *[[percents objectAtIndex:1] floatValue], self.oneLabel.frame.size.height)];
        self.twoLabel.backgroundColor = [UIColor clearColor];
        self.twoLabel.textAlignment = NSTextAlignmentCenter;
        self.twoLabel.textColor = RGBColorWithoutAlpha(100, 100, 100);
        self.twoLabel.font = [UIFont systemFontOfSize:14.0];
        self.twoLabel.text = @"时间";
        [self.contentView addSubview:self.twoLabel];
        
        //3
        self.threeLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.twoLabel.frame.origin.x + self.twoLabel.frame.size.width, 0, (_width - 20) *[[percents objectAtIndex:2] floatValue], self.oneLabel.frame.size.height)];
        self.threeLabel.backgroundColor = [UIColor clearColor];
        self.threeLabel.textAlignment = NSTextAlignmentCenter;
        self.threeLabel.textColor = RGBColorWithoutAlpha(100, 100, 100);
        self.threeLabel.font = [UIFont systemFontOfSize:14.0];
        self.threeLabel.text = @"类型";
        self.threeLabel.numberOfLines = 2;
        [self.contentView addSubview:self.threeLabel];
        
        //4
        self.fourLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.threeLabel.frame.origin.x + self.threeLabel.frame.size.width, 0, (_width - 20) *[[percents objectAtIndex:3] floatValue], self.oneLabel.frame.size.height)];
        self.fourLabel.backgroundColor = [UIColor clearColor];
        self.fourLabel.textAlignment = NSTextAlignmentCenter;
        self.fourLabel.textColor = [UIColor redColor];
        self.fourLabel.font = [UIFont boldSystemFontOfSize:15.0];
        self.fourLabel.text = @"金额";
        [self.contentView addSubview:self.fourLabel];
        
        //分割线
        self.dividerView = [[UIView alloc] initWithFrame:CGRectMake(0, self.fourLabel.frame.origin.y + self.fourLabel.frame.size.height, _width, 0.5)];
        self.dividerView.backgroundColor = RGBColor(235.0, 235.0, 235.0, 1.0);
        [self.contentView addSubview:self.dividerView];
    }
    return self;
}


@end
