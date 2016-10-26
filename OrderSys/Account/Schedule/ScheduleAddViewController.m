//
//  ScheduleAddViewController.m
//  OrderSys
//
//  Created by Macx on 15/8/10.
//  Copyright (c) 2015年 北京星辰万合. All rights reserved.
//

#import "ScheduleAddViewController.h"
#import "CLWeeklyCalendarView.h"
#import "UIViewController+HUD.h"
#import "CommonUtil.h"
#import "WHInterfaceUtil.h"
#import "ScheduleInfo.h"
#import "JSONKit.h"

#define PICKER_HEIGHT 50*HEIGHT_RATE
#define CONTENT_VIEW_HEIGHT IS_IPHONE && SCREEN_MAX_LENGTH >= 568.0 ? 150 : 90
#define CONTENT_TF_HEIGHT IS_IPHONE && SCREEN_MAX_LENGTH >= 568.0 ? 140 : 80

/**
 * 添加日程
 **/
@interface ScheduleAddViewController ()<CLWeeklyCalendarViewDelegate, UITextViewDelegate>

@property(nonatomic,retain) UILabel* monthLabel;
@property(nonatomic,strong) CLWeeklyCalendarView* calendarView;
@property(nonatomic,retain) UIDatePicker *datePicker;
@property(nonatomic,retain) UITextView *contentTF; //日程描述内容
@property(nonatomic,retain) NSDate *curDate;//当前日期
@property(nonatomic,retain) NSArray *monthArray;//月份
@property(nonatomic,retain) NSCalendar *calendar;
@property(nonatomic,retain) NSDateComponents *comps;
@property(nonatomic,assign) NSInteger unitFlag;
@property(nonatomic,retain) NSString *scheduleDate; //日程日期
@property(nonatomic,assign) NSInteger type; //0 添加日程 1 修改日程
@property(nonatomic,retain) ScheduleInfo *scheduleInfo;

@end

@implementation ScheduleAddViewController

- (instancetype)initWithScheduleInfo:(ScheduleInfo *) scheduleInfo
{
    self = [super init];
    if (self) {
        
        _scheduleInfo = scheduleInfo;
        _curDate = [NSDate date];
        _calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
        _comps = [[NSDateComponents alloc] init];
        _unitFlag = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSWeekdayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
        _comps = [_calendar components:_unitFlag fromDate:_curDate];
        _monthArray = @[@"一月",@"二月",@"三月",@"四月",@"五月",@"六月",@"七月",@"八月",@"九月",@"十月",@"十一月",@"十二月"];
        
        
        //设置导航栏
        UIColor *color = [UIColor whiteColor];
        NSDictionary * dict=[NSDictionary dictionaryWithObject:color forKey:UITextAttributeTextColor];
        [UINavigationBar appearance] .titleTextAttributes = dict;
        //设置导航栏返回按钮
        UIBarButtonItem *backItem = [[UIBarButtonItem alloc] init];
        backItem.title = @"返回";
        self.navigationItem.backBarButtonItem = backItem;
        
        
        //月份
        _monthLabel = [[UILabel alloc] initWithFrame:CGRectMake((SCREEN_WIDTH - 100)/2, STATU_BAR_HEIGHT + NAV_HEIGHT + 5, 100, ROW_HEIGHT - 15)];
        _monthLabel.layer.cornerRadius = 15;
        _monthLabel.backgroundColor = [UIColor redColor];
        _monthLabel.textColor = [UIColor whiteColor];
        _monthLabel.textAlignment = NSTextAlignmentCenter;
        _monthLabel.clipsToBounds = YES;
        [self.view addSubview:_monthLabel];
        [self updateMonth:[_comps month]];
        
        //日期选择
        _calendarView = [[CLWeeklyCalendarView alloc] initWithFrame:CGRectMake(0, self.monthLabel.frame.origin.y + self.monthLabel.frame.size.height + 5, SCREEN_WIDTH, 60)];
        _calendarView.delegate = self;
        [self.view addSubview:_calendarView];
        
        //时间选择
        _datePicker =[[UIDatePicker alloc] init];
        _datePicker.frame = CGRectMake(0, _calendarView.frame.origin.y + _calendarView.frame.size.height + 5, SCREEN_WIDTH, 20);
        [_datePicker setBackgroundColor:[UIColor whiteColor]];
        _datePicker.datePickerMode = UIDatePickerModeTime;
        //[_datePicker addTarget:self action:@selector(dateChanged:) forControlEvents:UIControlEventValueChanged];
        [self.view addSubview:_datePicker];
    
        //日程文本
        UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(0, _datePicker.frame.origin.y + _datePicker.frame.size.height + 5, SCREEN_WIDTH, CONTENT_VIEW_HEIGHT)];
        contentView.backgroundColor = [UIColor whiteColor];
        _contentTF = [[UITextView alloc] initWithFrame:CGRectMake(10, 5, SCREEN_WIDTH - 20, CONTENT_TF_HEIGHT)];
        _contentTF.font = [UIFont systemFontOfSize:14];
        _contentTF.backgroundColor = RGBColorWithoutAlpha(226, 229, 228);
        _contentTF.delegate = self;
        _contentTF.keyboardType = UIKeyboardAppearanceDefault;
        _contentTF.returnKeyType = UIReturnKeyDone;
        [contentView addSubview:_contentTF];
        [self.view addSubview:contentView];
        
        //完成
        UIButton *completeButton = [[UIButton alloc] initWithFrame:CGRectMake(40, contentView.frame.origin.y + contentView.frame.size.height + 10, SCREEN_WIDTH - 80, ROW_HEIGHT - 10)];
        [completeButton setTitle:@"完成" forState:UIControlStateNormal];
        completeButton.titleLabel.font = [UIFont systemFontOfSize:16.0];
        completeButton.layer.cornerRadius = 5;
        completeButton.backgroundColor = [UIColor redColor];
        [completeButton addTarget:self action:@selector(clickComplete:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:completeButton];
        
        if (scheduleInfo == nil) {
            self.title = @"添加日程";
            _contentTF.text = @"请输入日程";
            _contentTF.textColor = [UIColor grayColor];
            _type = 0;
        } else {
            self.title = @"修改日程";
            _contentTF.text = scheduleInfo.AlterMessage;
            _contentTF.textColor = [UIColor blackColor];
            _type = 1;
            _scheduleInfo = scheduleInfo;
        }
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //设置导航栏返回按钮为白色
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    //设置背景颜色
    self.view.backgroundColor = RGBColorWithoutAlpha(226, 229, 228);
    
}

#pragma mark - CLWeeklyCalendarViewDelegate
-(NSDictionary *)CLCalendarBehaviorAttributes {
    return
    @{
        CLCalendarWeekStartDay : @7,
        CLCalendarSelectedDatePrintColor : [UIColor whiteColor]
    };
}

-(void)firstDateForView:(NSDate *)date{
}

-(void)dailyCalendarViewDidSelect:(NSDate *)date {
    _curDate = date;
    _comps = [_calendar components:_unitFlag fromDate:_curDate];
    [self updateMonth:[_comps month]];
    _scheduleDate = [self getSelectedDateByDatePickerView];
}




//更新月份
-(void) updateMonth:(long) month {
    _monthLabel.text = [_monthArray objectAtIndex:month - 1];
}

//获取日期 日期由日历控件和pickerview的时分秒组成
-(NSString*)getSelectedDateByDatePickerView{
    NSDate *date = [_datePicker date];
    NSDateFormatter *localFormat = [self sharedDateFormatter];
    [localFormat setDateFormat:@"HH:mm:ss"];
    
    NSString *resultHourMinute = [localFormat stringFromDate:date];
    
    [localFormat setDateFormat:@"yyyy-MM-dd"];
    NSString *resultDate = [NSString stringWithFormat:@"%@ %@",[localFormat stringFromDate:_curDate],resultHourMinute];
    NSLog(@"%@", resultDate);
    return resultDate;
}

- (NSDateFormatter *)sharedDateFormatter {
    static NSDateFormatter *sharedFormatter = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        sharedFormatter = [[NSDateFormatter alloc] init];
        NSTimeZone* timeZone = [NSTimeZone defaultTimeZone];
        [sharedFormatter setTimeZone:timeZone];
    });
    return sharedFormatter;
}

//完成事件
-(IBAction)clickComplete:(id)sender {
    [self appendSchedule];
}


//添加日程
-(void) appendSchedule {
    NSString *hint = @"";
    if (_type == 0) { //添加
        hint = @"添加";
    } else {
        hint = @"修改";
    }
    [self showHudInView:self.view hint:[NSString stringWithFormat:@"正在%@", hint]];
    dispatch_async(dispatch_queue_create("getclass", DISPATCH_QUEUE_CONCURRENT), ^(){
        NSString *method = @"";
        NSString *ScheduleId = @"";
        if (_type == 0) { //添加
            ScheduleId = @"-1";
            method = @"appendSchedule";
        } else { //修改
            ScheduleId = [NSString stringWithFormat:@"%d", _scheduleInfo.ScheduleId];
            method = @"modifySchedule";
        }
        NSMutableDictionary *sInfo = [[NSMutableDictionary alloc] initWithCapacity:0];
        [sInfo setObject:ScheduleId forKey:@"ScheduleId"];
        [sInfo setObject:_contentTF.text forKey:@"AlterMessage"];
        [sInfo setObject:_scheduleDate forKey:@"AlertTime"];
        NSString *param = [NSString stringWithFormat:@"\"schedule\":%@",[sInfo JSONString]];
        NSDictionary *dics = [WHInterfaceUtil noLoginWithUrl:@"AboutSchedule.asmx" urlValue:[NSString stringWithFormat:@"%@%@", @"http://service.xingchen.com/", method] withParams:param];
        if (dics!=nil) {
            int isSuccess = [[dics objectForKey:@"IsSuccess"] integerValue];
            if (isSuccess == 1) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.navigationController popViewControllerAnimated:YES];
                    [self hideHud];
                    [CommonUtil showAlert:[NSString stringWithFormat:@"%@成功", hint]];
                });
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self hideHud];
                    [CommonUtil showAlert:[NSString stringWithFormat:@"%@失败", hint]];
                });
            }
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self hideHud];
                [CommonUtil showAlert:[NSString stringWithFormat:@"%@失败", hint]];
            });
        }
    });
}


//键盘收回事件，UITextView协议方法
-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    return YES;
}

//***更改frame的值***//
//在UITextField 编辑之前调用方法
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    //设置动画的名字
    [UIView beginAnimations:@"Animation" context:nil];
    //设置动画的间隔时间
    [UIView setAnimationDuration:0.20];
    //??使用当前正在运行的状态开始下一段动画
    [UIView setAnimationBeginsFromCurrentState: YES];
    //设置视图移动的位移
    self.view.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y - 200, self.view.frame.size.width, self.view.frame.size.height);
    //设置动画结束
    [UIView commitAnimations];
    return YES;
}
//在UITextField 编辑完成调用方法
- (void)textViewDidEndEditing:(UITextView *)textView {
    //设置动画的名字
    [UIView beginAnimations:@"Animation" context:nil];
    //设置动画的间隔时间
    [UIView setAnimationDuration:0.20];
    //??使用当前正在运行的状态开始下一段动画
    [UIView setAnimationBeginsFromCurrentState: YES];
    //设置视图移动的位移
    self.view.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y + 200, self.view.frame.size.width, self.view.frame.size.height);
    //设置动画结束
    [UIView commitAnimations];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
