//
//  AddRecordViewController.m
//  OrderSys
//
//  Created by Macx on 15/7/31.
//  Copyright (c) 2015年 北京星辰万合. All rights reserved.
//

#import "AddRecordViewController.h"
#import "PopListView.h"
#import "PopTableCell.h"
#import "DishTypeInfo.h"
#import "WHInterfaceUtil.h"
#import "UIViewController+HUD.h"
#import "CommonUtil.h"
#import "JsonKit.h"
#import "FlowsTypeListObj.h"

/**
 * 添加记录
 **/
@interface AddRecordViewController ()<UITextFieldDelegate,UITableViewDataSource,UITableViewDelegate>

@property(nonatomic,retain) UILabel *timeText;//时间
@property(nonatomic,retain) UIView *timePickerView; //时间选择器布局
@property(nonatomic,retain) UIButton *confirmButton; //时间选择器确定
@property(nonatomic,retain) UIButton *cancelButton; //时间选择器取消
@property(nonatomic,retain) UIDatePicker *datePicker; //日期选择器
@property(nonatomic,retain) UILabel *typeText; //收入/支出类型
@property(nonatomic,retain) NSArray *flowsTypes; //收入/支出类型列表
@property(nonatomic,retain) NSArray *flowsNumTypes; //收入/支出类型id列表
@property(nonatomic,retain) UITableView *typesTableView;
@property(nonatomic,assign) CGFloat typesCellWidth; //typesTableView宽度
@property(nonatomic,assign) NSInteger index; //当前收入/支出类型row
@property(nonatomic,retain) NSString *time; //当前日期
@property(nonatomic,retain) UITextField *nameTf;//收入名称
@property(nonatomic,retain) UITextField *moneyTf;//金额
@property(nonatomic,retain) NSDateFormatter *dateFormatter;

@end

@implementation AddRecordViewController

- (instancetype)initWithType:(int) type
{
    self = [super init];
    if (self) {
        
        self.type = type;
        _index = 0;
        _dateFormatter = [[NSDateFormatter alloc] init];
        [_dateFormatter setDateFormat: @"yyyy-MM-dd"];
        _time = [_dateFormatter stringFromDate:[NSDate date]];
        _flowsTypes = [FlowsTypeListObj getTypeList];
        _flowsNumTypes = [FlowsTypeListObj getTypeNumList];
        
        self.title = @"添加记录";
        //设置导航栏
        UIColor *color = [UIColor whiteColor];
        NSDictionary * dict=[NSDictionary dictionaryWithObject:color forKey:UITextAttributeTextColor];
        [UINavigationBar appearance] .titleTextAttributes = dict;
        //设置导航栏返回按钮
        UIBarButtonItem *backItem = [[UIBarButtonItem alloc] init];
        backItem.title = @"返回";
        self.navigationItem.backBarButtonItem = backItem;
        //导航栏右侧取消按钮
        UIButton *cancalButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 50, NAV_HEIGHT)];
        [cancalButton setTitle:@"取消" forState:UIControlStateNormal];
        cancalButton.titleLabel.textColor = [UIColor whiteColor];
        cancalButton.backgroundColor = [UIColor clearColor];
        cancalButton.titleLabel.font = [UIFont boldSystemFontOfSize:14];
        cancalButton.tag = 2;
        [cancalButton addTarget:self action:@selector(clickOperation:) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:cancalButton];
        self.navigationItem.rightBarButtonItem = rightItem;
        
        
        //收入/支出时间
        UIView *timeView = [[UIView alloc] initWithFrame:CGRectMake(0, STATU_BAR_HEIGHT + NAV_HEIGHT + 10, SCREEN_WIDTH, ROW_HEIGHT)];
        timeView.backgroundColor = [UIColor whiteColor];
        
        UILabel *timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, 80, ROW_HEIGHT)];
        timeLabel.backgroundColor = [UIColor clearColor];
        timeLabel.textAlignment = NSTextAlignmentLeft;
        timeLabel.font = [UIFont systemFontOfSize:16];
        timeLabel.textColor = RGBColorWithoutAlpha(100, 100, 100);
        
        _timeText = [[UILabel alloc] initWithFrame:CGRectMake(timeLabel.frame.origin.x + timeLabel.frame.size.width, 5, timeView.frame.size.width - timeLabel.frame.origin.x - timeLabel.frame.size.width - 40, timeLabel.frame.size.height - 10)];
        _timeText.backgroundColor = [UIColor whiteColor];
        _timeText.text = [NSString stringWithFormat:@"2010-01-01"];
        _timeText.textAlignment = NSTextAlignmentLeft;
        _timeText.userInteractionEnabled = YES;
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickTime:)];
        [_timeText addGestureRecognizer:singleTap];
        
        UIButton *timeButton = [[UIButton alloc] initWithFrame:CGRectMake(timeView.frame.size.width - 40, 0, 40, timeView.frame.size.height)];
        [timeButton setImage:[UIImage imageNamed:@"more_info_icon"] forState:UIControlStateNormal];
        timeButton.userInteractionEnabled = NO;
        
        [timeView addSubview:timeLabel];
        [timeView addSubview:_timeText];
        [timeView addSubview:timeButton];
        [self.view addSubview:timeView];
        
        
        //收入/支出类型
        UIView *typeView = [[UIView alloc] initWithFrame:CGRectMake(0, timeView.frame.origin.y + timeView.frame.size.height + 10, SCREEN_WIDTH, ROW_HEIGHT)];
        typeView.backgroundColor = [UIColor whiteColor];
        
        UILabel *typeLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, 80, ROW_HEIGHT)];
        typeLabel.backgroundColor = [UIColor clearColor];
        typeLabel.textAlignment = NSTextAlignmentLeft;
        typeLabel.font = [UIFont systemFontOfSize:16];
        typeLabel.textColor = RGBColorWithoutAlpha(100, 100, 100);
        
        _typeText = [[UILabel alloc] initWithFrame:CGRectMake(typeLabel.frame.origin.x + typeLabel.frame.size.width, 5, typeView.frame.size.width - typeLabel.frame.origin.x - typeLabel.frame.size.width - 40, typeLabel.frame.size.height - 10)];
        _typeText.text = [_flowsTypes objectAtIndex:0];
        _typeText.tag = 0;
        _typeText.userInteractionEnabled = YES;
        singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickType:)];
        [_typeText addGestureRecognizer:singleTap];
        
        UIButton *typeButton = [[UIButton alloc] initWithFrame:CGRectMake(typeView.frame.size.width - 40, 0, 40, typeView.frame.size.height)];
        [typeButton setImage:[UIImage imageNamed:@"more_info_icon"] forState:UIControlStateNormal];
        typeButton.userInteractionEnabled = NO;
        
        [typeView addSubview:typeLabel];
        [typeView addSubview:_typeText];
        [typeView addSubview:typeButton];
        [self.view addSubview:typeView];
        
        
        //收入/支出名称
        UIView *nameView = [[UIView alloc] initWithFrame:CGRectMake(0, typeView.frame.origin.y + typeView.frame.size.height + 10, SCREEN_WIDTH, ROW_HEIGHT)];
        nameView.backgroundColor = [UIColor whiteColor];
        
        UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, 80, nameView.frame.size.height)];
        nameLabel.backgroundColor = [UIColor clearColor];
        nameLabel.font = [UIFont systemFontOfSize:16];
        nameLabel.textAlignment = NSTextAlignmentLeft;
        nameLabel.textColor = RGBColorWithoutAlpha(100, 100, 100);
        
        _nameTf = [[UITextField alloc] initWithFrame:CGRectMake(nameLabel.frame.origin.x + nameLabel.frame.size.width, 8, nameView.frame.size.width - nameLabel.frame.origin.x - nameLabel.frame.size.width - 10 - 35, nameLabel.frame.size.height - 16)];
        _nameTf.backgroundColor = RGBColorWithoutAlpha(230, 230, 230);
        _nameTf.borderStyle = UITextBorderStyleNone;
        [_nameTf setClearButtonMode:UITextFieldViewModeWhileEditing];//右侧删除按钮
        _nameTf.userInteractionEnabled = YES;
        //设置键盘，使换行变为完成字样
        _nameTf.delegate = self;
        _nameTf.keyboardType = UIKeyboardAppearanceDefault;
        _nameTf.returnKeyType = UIReturnKeyDone;
        
        [nameView addSubview:nameLabel];
        [nameView addSubview:_nameTf];
        [self.view addSubview:nameView];
        
        //收入/支出金额
        UIView *moneyView = [[UIView alloc] initWithFrame:CGRectMake(0, nameView.frame.origin.y + nameView.frame.size.height + 10, SCREEN_WIDTH, ROW_HEIGHT)];
        moneyView.backgroundColor = [UIColor whiteColor];
        
        UILabel *moneyLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, 80, moneyView.frame.size.height)];
        moneyLabel.font = [UIFont systemFontOfSize:16];
        moneyLabel.backgroundColor = [UIColor clearColor];
        moneyLabel.textColor = RGBColorWithoutAlpha(100, 100, 100);
        
        _moneyTf = [[UITextField alloc] initWithFrame:CGRectMake(moneyLabel.frame.origin.x + moneyLabel.frame.size.width, 8, moneyView.frame.size.width - moneyLabel.frame.origin.x - moneyLabel.frame.size.width - 10 - 35, moneyLabel.frame.size.height - 16)];
        _moneyTf.backgroundColor = RGBColorWithoutAlpha(230, 230, 230);
        [_moneyTf setClearButtonMode:UITextFieldViewModeWhileEditing];//右侧删除按钮
        _moneyTf.userInteractionEnabled = YES;
        //设置键盘，使换行变为完成字样
        _moneyTf.delegate = self;
        _moneyTf.keyboardType = UIKeyboardAppearanceDefault;
        _moneyTf.returnKeyType = UIReturnKeyDone;
        
        UILabel *yuan = [[UILabel alloc] initWithFrame:CGRectMake(_moneyTf.frame.origin.x + _moneyTf.frame.size.width + 5, 0, 20, moneyLabel.frame.size.height)];
        yuan.text = @"元";
        yuan.textColor = RGBColorWithoutAlpha(100, 100, 100);
        
        [moneyView addSubview:moneyLabel];
        [moneyView addSubview:_moneyTf];
        [moneyView addSubview:yuan];
        [self.view addSubview:moneyView];
        
        //确认
        UIButton *confirmButton = [[UIButton alloc] initWithFrame:CGRectMake(40, SCREEN_HEIGHT - ROW_HEIGHT * 2, SCREEN_WIDTH - 80, ROW_HEIGHT - 10)];
        [confirmButton setTitle:@"确　认" forState:UIControlStateNormal];
        confirmButton.titleLabel.textColor = [UIColor whiteColor];
        confirmButton.backgroundColor = [UIColor redColor];
        confirmButton.titleLabel.font = [UIFont boldSystemFontOfSize:18];
        confirmButton.layer.cornerRadius = 5;
        confirmButton.tag = 1;
        [confirmButton addTarget:self action:@selector(clickOperation:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:confirmButton];

        
        //时间选择器布局
        _timePickerView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, 240)];
        _timePickerView.backgroundColor = [UIColor whiteColor];
        
        
        //确定按钮
        _confirmButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, _timePickerView.frame.size.width/2, 40)];
        _confirmButton.backgroundColor = RGBColor(240, 240, 240, 0.9);
        [_confirmButton setTitle:@"确定" forState:UIControlStateNormal];
        _confirmButton.userInteractionEnabled = YES;
        _confirmButton.titleLabel.textAlignment = NSTextAlignmentCenter;
        _confirmButton.titleLabel.font = [UIFont boldSystemFontOfSize:16.0];
        [_confirmButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        _confirmButton.tag = 3;
        [_confirmButton addTarget:self action:@selector(clickOperation:) forControlEvents:UIControlEventTouchUpInside];
        
        //取消按钮
        _cancelButton = [[UIButton alloc] initWithFrame:CGRectMake(_timePickerView.frame.size.width/2 + 1, 0, _timePickerView.frame.size.width/2, 40)];
        _cancelButton.backgroundColor = RGBColor(240, 240, 240, 0.9);
        [_cancelButton setTitle:@"取消" forState:UIControlStateNormal];
        _cancelButton.userInteractionEnabled = YES;
        _cancelButton.titleLabel.textAlignment = NSTextAlignmentCenter;
        _cancelButton.titleLabel.font = [UIFont boldSystemFontOfSize:16.0];
        [_cancelButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        _cancelButton.tag = 4;
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
        _timeText.text = [_dateFormatter stringFromDate:date];
        
        [_timePickerView addSubview:_confirmButton];
        [_timePickerView addSubview:_cancelButton];
        [_timePickerView addSubview:_datePicker];
        [self.view addSubview:_timePickerView];
        
        //类型列表
        _typesCellWidth = _typeText.frame.size.width;
        _typesTableView = [[UITableView alloc] initWithFrame:CGRectMake(typeView.frame.origin.x + _typeText.frame.origin.x, typeView.frame.origin.y + typeView.frame.size.height + 5, _typesCellWidth, ROW_HEIGHT * 5) style:UITableViewStylePlain];
        _typesTableView.dataSource = self;
        _typesTableView.delegate = self;
        _typesTableView.layer.cornerRadius = 5;
        [_typesTableView setHidden:YES];
        _typesTableView.backgroundColor = [UIColor clearColor];
        _typesTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [self.view addSubview:_typesTableView];
        
        //判断是否是我的收入和我的支出
        if (type == 0) {
            timeLabel.text = @"收入时间:";
            typeLabel.text = @"收入类型:";
            nameLabel.text = @"收入名称:";
            moneyLabel.text = @"收入金额:";
        } else {
            timeLabel.text = @"支出时间:";
            typeLabel.text = @"支出类型:";
            nameLabel.text = @"支出名称:";
            moneyLabel.text = @"支出金额:";
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//创建并设置每行显示的内容
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellWithIdentifier = @"TypeCell";
    PopTableCell *cell = [tableView dequeueReusableCellWithIdentifier:CellWithIdentifier];
    NSUInteger row = [indexPath row];
    if (cell == nil) {
        cell = [[PopTableCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:CellWithIdentifier withCellWidth:_typesCellWidth withCellHeight:44];
    }
    cell.nameLabel.text = [_flowsTypes objectAtIndex:row];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.backgroundColor = [UIColor clearColor];
    cell.backgroundView = nil;
    return cell;
}

//内容分段
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

//cell高度
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44;
}

//每个cell中显示多少行
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [_flowsTypes count];
}

//列表点击事件
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSInteger row = indexPath.row;
    [_typesTableView setHidden:YES];
    _index = row;
    _typeText.text = [_flowsTypes objectAtIndex:row];
}

//设置数据
- (void) setData {
    [self showHudInView:self.view hint:@"正在更新"];
    dispatch_async(dispatch_queue_create("getclass", DISPATCH_QUEUE_CONCURRENT), ^(){
        
        NSMutableDictionary *baseInfo = [[NSMutableDictionary alloc] initWithCapacity:0];
        [baseInfo setObject:_time forKey:@"Date"];
        [baseInfo setObject:[NSNumber numberWithInt:[[_flowsNumTypes objectAtIndex:_index] integerValue]] forKey:@"AccountType"];
        [baseInfo setObject:_moneyTf.text forKey:@"Money"];
        [baseInfo setObject:_nameTf.text forKey:@"Memo"];
        NSString *param = [NSString stringWithFormat:@"\"info\":%@,%@", [baseInfo JSONString], [WHInterfaceUtil intToJsonString:@"type" withValue:_type]];
    
        NSDictionary *dics = [WHInterfaceUtil noLoginWithUrl:@"AboutReport.asmx" urlValue:@"http://service.xingchen.com/addAccountStatInfo" withParams:param];
        if (dics!=nil) {
            int isSuccess = [[dics objectForKey:@"IsSuccess"] integerValue];
            if (isSuccess == 1) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self hideHud];
                    [CommonUtil showAlert:@"添加成功"];
                    [self.navigationController popViewControllerAnimated:YES];
                });
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self hideHud];
                    [CommonUtil showAlert:@"添加失败"];
                });
            }
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self hideHud];
                [CommonUtil showAlert:@"添加失败"];
            });
        }
    });
}

//时间选择事件
-(void)clickTime:(id)sender{
    [self popupView];
}

//点击类型按钮事件
-(IBAction)clickType:(id)sender{
    NSLog(@"选择收入/支出类型");
    if (_typesTableView.isHidden) {
        [_typesTableView setHidden:NO];
    } else{
        [_typesTableView setHidden:YES];
    }
}

//点击事件
-(IBAction)clickOperation:(id)sender{
    UIButton *button = (UIButton*)sender;
    NSInteger tag = button.tag;
    NSDate *date_one;
    switch (tag) {
        case 1:
            NSLog(@"确认事件");
            [self setData];
            break;
        case 2:
            NSLog(@"取消事件");
            [self.navigationController popViewControllerAnimated:YES];
            break;
        case 3:
            //日期选择确认按钮
            date_one = _datePicker.date;
            _time = [_dateFormatter stringFromDate:date_one];
            _timeText.text = _time;
            NSLog(@"%@", _time);
            [self popupView];
            break;
        case 4:
            //日期选择取消按钮
            [self popupView];
            break;
        default:
            break;
    }
}


//日期选择器动画
-(void) popupView {
    CGContextRef context = UIGraphicsGetCurrentContext();
    [UIView beginAnimations:@"start" context:context];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDuration:0.5];
    CGRect rect = _timePickerView.frame;
    if (rect.origin.y == self.view.frame.size.height) {
        rect.origin.y = rect.origin.y - _timePickerView.frame.size.height;
    }else{
        rect.origin.y = self.view.frame.size.height;
    }
    _timePickerView.frame = rect;
    
    [UIView commitAnimations];
}

//隐藏软键盘
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [[self view] endEditing:YES];
}


//键盘收回事件，UITextField协议方法
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return NO;
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
