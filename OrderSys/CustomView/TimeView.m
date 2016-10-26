//
//  TimeView.m
//  OrderSys
//
//  Created by Macx on 15/8/3.
//  Copyright (c) 2015年 北京星辰万合. All rights reserved.
//

#import "TimeView.h"

/**
 * 自定义开始时间结束时间视图
 **/
@implementation TimeView

@synthesize stime, etime, delegate;

- (instancetype) initWithHeight:(CGFloat) height withViewController:(UIViewController *) viewController {
    
    self = [super init];
    if (self) {
        
        self.viewController = viewController;
        
        //开始时间
        UIView *stimeView = [[UIView alloc] initWithFrame:CGRectMake(0, height, SCREEN_WIDTH, ROW_HEIGHT * 3/4)];
        stimeView.backgroundColor = [UIColor clearColor];
        
        UILabel *stimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, 70, stimeView.frame.size.height)];
        stimeLabel.backgroundColor = [UIColor clearColor];
        stimeLabel.textAlignment = NSTextAlignmentLeft;
        stimeLabel.textColor = RGBColorWithoutAlpha(100, 100, 100);
        stimeLabel.font = [UIFont systemFontOfSize:15.0];
        stimeLabel.text = @"开始时间";
        
        _stimeText = [[UILabel alloc] initWithFrame:CGRectMake(stimeLabel.frame.origin.x + stimeLabel.frame.size.width + 5, 5, stimeView.frame.size.width - stimeLabel.frame.origin.x - stimeLabel.frame.size.width - 25, stimeLabel.frame.size.height - 10)];
        _stimeText.backgroundColor = RGBColorWithoutAlpha(226, 229, 228);
        _stimeText.layer.cornerRadius = 5;
        _stimeText.text = [NSString stringWithFormat:@"2010-01-01"];
        _stimeText.textColor = [UIColor grayColor];
        _stimeText.userInteractionEnabled = YES;
        _stimeText.font = [UIFont systemFontOfSize:15.0];
        _stimeText.tag = 0;
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickTime:)];
        [_stimeText addGestureRecognizer:singleTap];
        
        [stimeView addSubview:stimeLabel];
        [stimeView addSubview:_stimeText];
        [self.viewController.view addSubview:stimeView];
        
        //结束时间
        UIView *etimeView = [[UIView alloc] initWithFrame:CGRectMake(0, stimeView.frame.origin.y + stimeView.frame.size.height, SCREEN_WIDTH, stimeView.frame.size.height)];
        etimeView.backgroundColor = [UIColor clearColor];
        
        UILabel *etimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, 70, etimeView.frame.size.height)];
        etimeLabel.backgroundColor = [UIColor clearColor];
        etimeLabel.textAlignment = NSTextAlignmentLeft;
        etimeLabel.textColor = RGBColorWithoutAlpha(100, 100, 100);
        etimeLabel.font = [UIFont systemFontOfSize:15.0];
        etimeLabel.text = @"结束时间";
        
        _etimeText = [[UILabel alloc] initWithFrame:CGRectMake(etimeLabel.frame.origin.x + etimeLabel.frame.size.width + 5, 5, etimeView.frame.size.width - etimeLabel.frame.origin.x - etimeLabel.frame.size.width - 25, stimeLabel.frame.size.height - 10)];
        _etimeText.backgroundColor = RGBColorWithoutAlpha(226, 229, 228);
        _etimeText.layer.cornerRadius = 5;
        _etimeText.text = [NSString stringWithFormat:@"2010-01-01"];
        _etimeText.textColor = [UIColor grayColor];
        _etimeText.userInteractionEnabled = YES;
        _etimeText.font = [UIFont systemFontOfSize:15.0];
        _etimeText.tag = 1;
        singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickTime:)];
        [_etimeText addGestureRecognizer:singleTap];
        
        [etimeView addSubview:etimeLabel];
        [etimeView addSubview:_etimeText];
        stimeView.backgroundColor = [UIColor whiteColor];
        etimeView.backgroundColor = [UIColor whiteColor];
        [self.viewController.view addSubview:etimeView];
        
        self.bottomY = etimeView.frame.origin.y + etimeView.frame.size.height;
        
    }
    return self;
}


//设置日期控件
-(void) setTimePickerView{
    //时间选择器布局
    _timePickerView = [[UIView alloc] initWithFrame:CGRectMake(0, self.viewController.view.frame.size.height, self.viewController.view.frame.size.width, 240)];
    _timePickerView.backgroundColor = [UIColor whiteColor];
    
    //确定按钮
    _confirmButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, _timePickerView.frame.size.width/2, 40)];
    _confirmButton.backgroundColor = RGBColor(240, 240, 240, 0.9);
    [_confirmButton setTitle:@"确定" forState:UIControlStateNormal];
    _confirmButton.userInteractionEnabled = YES;
    _confirmButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    _confirmButton.titleLabel.font = [UIFont boldSystemFontOfSize:16.0];
    [_confirmButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    _confirmButton.tag = 0;
    [_confirmButton addTarget:self action:@selector(clickOperation:) forControlEvents:UIControlEventTouchUpInside];
    
    //取消按钮
    _cancelButton = [[UIButton alloc] initWithFrame:CGRectMake(_timePickerView.frame.size.width/2 + 1, 0, _timePickerView.frame.size.width/2, 40)];
    _cancelButton.backgroundColor = RGBColor(240, 240, 240, 0.9);
    [_cancelButton setTitle:@"取消" forState:UIControlStateNormal];
    _cancelButton.userInteractionEnabled = YES;
    _cancelButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    _cancelButton.titleLabel.font = [UIFont boldSystemFontOfSize:16.0];
    [_cancelButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    _cancelButton.tag = 1;
    [_cancelButton addTarget:self action:@selector(clickOperation:) forControlEvents:UIControlEventTouchUpInside];
    
    //初始日期选择控件
    _datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, _confirmButton.frame.size.height, _timePickerView.frame.size.width, _timePickerView.frame.size.height - _confirmButton.frame.size.height)];
    _datePicker.backgroundColor = RGBColor(250, 250, 250, 0.9);
    //日期模式
    [_datePicker setDatePickerMode:UIDatePickerModeDate];
    //最小日期
    NSDateFormatter *formatter_minDate = [[NSDateFormatter alloc] init];
    [formatter_minDate setDateFormat:@"yyyy-MM-dd"];
    NSDate *minDate = [formatter_minDate dateFromString:@"1900-01-01"];
    //最大日期
    NSDateFormatter *formatter_maxDate = [[NSDateFormatter alloc] init];
    [formatter_maxDate setDateFormat:@"yyyy-MM-dd"];
    NSDate *maxDate = [formatter_maxDate dateFromString:@"3000-01-01"];
    
    [_datePicker setMinimumDate:minDate];
    [_datePicker setMaximumDate:maxDate];
    
    //设置默认结束时间
    NSDate *date = _datePicker.date;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat: @"yyyy-MM-dd"];
    _stimeText.text = [dateFormatter stringFromDate:date];
    stime = [dateFormatter stringFromDate:date];
    _etimeText.text = [dateFormatter stringFromDate:date];
    etime = [dateFormatter stringFromDate:date];
    
    [_timePickerView addSubview:_confirmButton];
    [_timePickerView addSubview:_cancelButton];
    [_timePickerView addSubview:_datePicker];
    [self.viewController.view addSubview:_timePickerView];
}

//时间选择事件
-(void)clickTime:(id)sender{
    UIGestureRecognizer *gesture = (UIGestureRecognizer*)sender;
    NSInteger tag = [gesture view].tag;
    if(tag == 0){
        _timeType = 0;
    } else if(tag == 1){
        _timeType = 1;
    }
    [self popupView];
    [_timePickerView setHidden: NO];
}

//日期选择器动画
-(void) popupView {
    CGContextRef context = UIGraphicsGetCurrentContext();
    [UIView beginAnimations:@"start" context:context];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDuration:0.5];
    CGRect rect = _timePickerView.frame;
    if (rect.origin.y == self.viewController.view.frame.size.height) {
        rect.origin.y = rect.origin.y - _timePickerView.frame.size.height;
    }else{
        rect.origin.y = self.viewController.view.frame.size.height;
    }
    _timePickerView.frame = rect;
    
    [UIView commitAnimations];
}

//点击事件
-(IBAction)clickOperation:(id)sender{
    UIButton *button = (UIButton*)sender;
    NSInteger tag = button.tag;
    NSDate *date_one;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat: @"yyyy-MM-dd"];
    NSString *time;
    switch (tag) {
        case 0:
            //日期选择确认按钮
            date_one = _datePicker.date;
            time = [dateFormatter stringFromDate:date_one];
            if (_timeType == 0) {
                _stimeText.text = time;
                stime = [dateFormatter stringFromDate:date_one];
            } else {
                _etimeText.text = time;
                etime = [dateFormatter stringFromDate:date_one];
            }
            NSLog(@"%@", time);
            [self popupView];
            [delegate clickConfirm];
            break;
        case 1:
            //日期选择取消按钮
            [self popupView];
            break;
        default:
            break;
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
