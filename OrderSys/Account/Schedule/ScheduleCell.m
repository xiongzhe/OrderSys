//
//  ScheduleCell.m
//  OrderSys
//
//  Created by Macx on 15/8/11.
//  Copyright (c) 2015年 北京星辰万合. All rights reserved.
//

#import "ScheduleCell.h"

@implementation ScheduleCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier withCellHeight:(CGFloat) cellHeight{
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
        
        CGFloat height = cellHeight - 0.5;
        
        //时间
        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, SCREEN_WIDTH/4, height)];
        self.titleLabel.textColor = [UIColor colorWithWhite:.5 alpha:.5];
        self.titleLabel.font = [UIFont systemFontOfSize:14];
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:self.titleLabel];
        
        //内容
        self.contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(20+SCREEN_WIDTH/4, 0, SCREEN_WIDTH/4*3-30, height)];
        self.contentLabel.textColor =[UIColor colorWithWhite:.2 alpha:.9];
        self.contentLabel.font = [UIFont systemFontOfSize:14];
        [self.contentView addSubview:self.contentLabel];

        
        //分割线
        self.dividerView = [[UIView alloc] initWithFrame:CGRectMake(0, self.contentLabel.frame.origin.y + self.contentLabel.frame.size.height, _width, 0.5)];
        self.dividerView.backgroundColor = RGBColor(235.0, 235.0, 235.0, 1.0);
        [self.contentView addSubview:self.dividerView];
    }
    return self;
}

@end
