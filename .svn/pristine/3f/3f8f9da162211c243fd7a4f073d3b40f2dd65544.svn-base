//
//  HisOrderCell.m
//  OrderSys
//
//  Created by Macx on 15/8/18.
//  Copyright (c) 2015年 北京星辰万合. All rights reserved.
//

#import "HisOrderCell.h"

/**
 * 历史订单列表cell
 **/
@implementation HisOrderCell

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
        
        CGFloat viewHeight = (cellHeight - 0.5 - 10 * 4)/3;
        
        //订单编号视图
        UIView *orderNumView = [[UIView alloc] initWithFrame:CGRectMake(0, 10, SCREEN_WIDTH, viewHeight)];
        //订单图片
        UIImageView *image = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 20, orderNumView.frame.size.height)];
        image.contentMode=UIViewContentModeScaleAspectFit;
        [image setImage:[UIImage imageNamed:@"baseinfo"]];
        [orderNumView addSubview:image];
        //订单编号标识
        UILabel *orderNumLabel = [[UILabel alloc] initWithFrame:CGRectMake(image.frame.origin.x + image.frame.size.width + 5, 0, 70, image.frame.size.height)];
        orderNumLabel.textAlignment = NSTextAlignmentLeft;
        orderNumLabel.textColor = RGBColorWithoutAlpha(100, 100, 100);
        orderNumLabel.backgroundColor = [UIColor clearColor];
        orderNumLabel.font = [UIFont systemFontOfSize:14];
        orderNumLabel.text = @"订单编号:";
        [orderNumView addSubview:orderNumLabel];
        //订单编号
        _orderLabel = [[UILabel alloc] initWithFrame:CGRectMake(orderNumLabel.frame.origin.x + orderNumLabel.frame.size.width + 5, 0, 90, image.frame.size.height)];
        _orderLabel.textAlignment = NSTextAlignmentLeft;
        _orderLabel.textColor = [UIColor redColor];
        _orderLabel.backgroundColor = [UIColor clearColor];
        _orderLabel.font = [UIFont systemFontOfSize:14];
        _orderLabel.text = @"1234567890";
        [orderNumView addSubview:_orderLabel];
        
        //订单时间视图
        UIView *orderTimeView = [[UIView alloc] initWithFrame:CGRectMake(0, orderNumView.frame.origin.y + orderNumView.frame.size.height + 10, SCREEN_WIDTH, orderNumView.frame.size.height)];
        //订单时间标识
        UILabel *orderTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(image.frame.origin.x + image.frame.size.width + 5, 0, 70, image.frame.size.height)];
        orderTimeLabel.textAlignment = NSTextAlignmentLeft;
        orderTimeLabel.textColor = RGBColorWithoutAlpha(100, 100, 100);
        orderTimeLabel.backgroundColor = [UIColor clearColor];
        orderTimeLabel.font = [UIFont systemFontOfSize:14];
        orderTimeLabel.text = @"订单时间:";
        [orderTimeView addSubview:orderTimeLabel];
        //订单时间
        _timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(orderNumLabel.frame.origin.x + orderNumLabel.frame.size.width + 5, 0, 90, image.frame.size.height)];
        _timeLabel.textAlignment = NSTextAlignmentLeft;
        _timeLabel.textColor = RGBColorWithoutAlpha(100, 100, 100);
        _timeLabel.backgroundColor = [UIColor clearColor];
        _timeLabel.font = [UIFont systemFontOfSize:14];
        _timeLabel.text = @"2015-08-02";
        [orderTimeView addSubview:_timeLabel];

        
        //订单就餐人数和金额视图
        UIView *numView = [[UIView alloc] initWithFrame:CGRectMake(0, orderTimeView.frame.origin.y + orderTimeView.frame.size.height + 10, SCREEN_WIDTH, orderNumView.frame.size.height)];
        //订单人数标识
        UILabel *numsLabel = [[UILabel alloc] initWithFrame:CGRectMake(image.frame.origin.x + image.frame.size.width + 5, 0, 70, image.frame.size.height)];
        numsLabel.textAlignment = NSTextAlignmentLeft;
        numsLabel.textColor = RGBColorWithoutAlpha(100, 100, 100);
        numsLabel.backgroundColor = [UIColor clearColor];
        numsLabel.font = [UIFont systemFontOfSize:14];
        numsLabel.text = @"就餐人数:";
        [numView addSubview:numsLabel];
        //订单时间
        _numLabel = [[UILabel alloc] initWithFrame:CGRectMake(orderNumLabel.frame.origin.x + orderNumLabel.frame.size.width + 5, 0, 90, image.frame.size.height)];
        _numLabel.textAlignment = NSTextAlignmentLeft;
        _numLabel.textColor = RGBColorWithoutAlpha(100, 100, 100);
        _numLabel.backgroundColor = [UIColor clearColor];
        _numLabel.font = [UIFont systemFontOfSize:14];
        _numLabel.text = @"2015-08-02";
        [numView addSubview:_numLabel];
        
        //订单金额
        _totalLabel = [[UILabel alloc] initWithFrame:CGRectMake(numView.frame.size.width - 70 - 20, 0, 70, image.frame.size.height)];
        _totalLabel.textAlignment = NSTextAlignmentLeft;
        _totalLabel.textColor = [UIColor redColor];
        _totalLabel.backgroundColor = [UIColor clearColor];
        _totalLabel.font = [UIFont systemFontOfSize:16];
        _totalLabel.text = @"￥256.00";
        [numView addSubview:_totalLabel];
        //订单金额标识
        UILabel *totalLabel = [[UILabel alloc] initWithFrame:CGRectMake(numView.frame.size.width - _totalLabel.frame.size.width - 20 - 35, 0, 35, image.frame.size.height)];
        totalLabel.textAlignment = NSTextAlignmentLeft;
        totalLabel.textColor = RGBColorWithoutAlpha(100, 100, 100);
        totalLabel.backgroundColor = [UIColor clearColor];
        totalLabel.font = [UIFont systemFontOfSize:14];
        totalLabel.text = @"金额:";
        [numView addSubview:totalLabel];
        
        
        [self.contentView addSubview:orderNumView];
        [self.contentView addSubview:orderTimeView];
        [self.contentView addSubview:numView];
        
        
        //分割线
        self.dividerView = [[UIView alloc] initWithFrame:CGRectMake(0, numView.frame.origin.y + numView.frame.size.height + 10, _width, 0.5)];
        self.dividerView.backgroundColor = RGBColor(235.0, 235.0, 235.0, 1.0);
        [self.contentView addSubview:self.dividerView];
        
        self.contentView.backgroundColor = [UIColor whiteColor];
    }
    return self;
}



@end
