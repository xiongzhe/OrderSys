//
//  BasicInfoViewController.m
//  OrderSys
//
//  Created by Macx on 15/7/31.
//  Copyright (c) 2015年 北京星辰万合. All rights reserved.
//

#import "BasicInfoViewController.h"
#import "WHInterfaceUtil.h"
#import "UIViewController+HUD.h"
#import "CommonUtil.h"
#import "JsonKit.h"

/**
 * 基本信息
 **/
@interface BasicInfoViewController ()<UITextFieldDelegate>

@property (nonatomic, retain) UIButton *editButton;
@property (nonatomic, retain) UITextField *fixedTf;
@property (nonatomic, retain) UITextField *iniTf;
@property (nonatomic, retain) UITextField *monthTf;
@property (nonatomic, retain) UITextField *yearTf;

@property (nonatomic, assign) NSInteger type; //按钮状态 0 编辑 1 完成

@end

@implementation BasicInfoViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        //设置导航栏
        self.title = @"基本信息";
        UIColor *color = [UIColor whiteColor];
        NSDictionary * dict=[NSDictionary dictionaryWithObject:color forKey:UITextAttributeTextColor];
        [UINavigationBar appearance] .titleTextAttributes = dict;
        //设置导航栏返回按钮
        UIBarButtonItem *backItem = [[UIBarButtonItem alloc] init];
        backItem.title = @"返回";
        self.navigationItem.backBarButtonItem = backItem;
        //导航栏右侧编辑/完成按钮
        self.editButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 50, NAV_HEIGHT)];
        [self.editButton setTitle:@"编辑" forState:UIControlStateNormal];
        self.editButton.titleLabel.textColor = [UIColor whiteColor];
        self.editButton.backgroundColor = [UIColor clearColor];
        self.editButton.titleLabel.font = [UIFont boldSystemFontOfSize:16];
        [self.editButton addTarget:self action:@selector(clickEdit:) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:self.editButton];
        self.navigationItem.rightBarButtonItem = rightItem;
        
        //固定资产
        UIView *fixedView = [[UIView alloc] initWithFrame:CGRectMake(0, STATU_BAR_HEIGHT + NAV_HEIGHT + 10, SCREEN_WIDTH, ROW_HEIGHT)];
        fixedView.backgroundColor = [UIColor whiteColor];
        
        UILabel *fixedLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, 80, ROW_HEIGHT)];
        fixedLabel.backgroundColor = [UIColor clearColor];
        fixedLabel.textAlignment = NSTextAlignmentLeft;
        fixedLabel.text = @"固定资产:";
        fixedLabel.textColor = [UIColor blackColor];
        
        self.fixedTf = [[UITextField alloc] initWithFrame:CGRectMake(fixedLabel.frame.origin.x + fixedLabel.frame.size.width + 20, 5, fixedView.frame.size.width - fixedLabel.frame.origin.x - fixedLabel.frame.size.width - 70, fixedLabel.frame.size.height - 10)];
        self.fixedTf.backgroundColor = [UIColor whiteColor];
        self.fixedTf.borderStyle = UITextBorderStyleNone;
        [self.fixedTf setClearButtonMode:UITextFieldViewModeWhileEditing];//右侧删除按钮
        self.fixedTf.userInteractionEnabled = NO;
        //设置键盘，使换行变为完成字样
        self.fixedTf.delegate = self;
        self.fixedTf.keyboardType = UIKeyboardAppearanceDefault;
        self.fixedTf.returnKeyType = UIReturnKeyDone;
        
        UILabel *yuan1 = [[UILabel alloc] initWithFrame:CGRectMake(_fixedTf.frame.origin.x + _fixedTf.frame.size.width + 5, 0, 20, fixedView.frame.size.height)];
        yuan1.text = @"元";
        yuan1.textColor = RGBColorWithoutAlpha(100, 100, 100);
        
        [fixedView addSubview:fixedLabel];
        [fixedView addSubview:self.fixedTf];
        [fixedView addSubview:yuan1];
        [self.view addSubview:fixedView];
        
        
        //初始现金
        UIView *initView = [[UIView alloc] initWithFrame:CGRectMake(0, fixedView.frame.origin.y + fixedView.frame.size.height + 10, SCREEN_WIDTH, ROW_HEIGHT)];
        initView.backgroundColor = [UIColor whiteColor];
        
        UILabel *initLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, 80, ROW_HEIGHT)];
        initLabel.backgroundColor = [UIColor clearColor];
        initLabel.textAlignment = NSTextAlignmentLeft;
        initLabel.text = @"初始现金:";
        initLabel.textColor = [UIColor blackColor];
        
        self.iniTf = [[UITextField alloc] initWithFrame:CGRectMake(initLabel.frame.origin.x + initLabel.frame.size.width + 20, 5, initView.frame.size.width - initLabel.frame.origin.x - initLabel.frame.size.width - 70, initLabel.frame.size.height - 10)];
        self.iniTf.backgroundColor = [UIColor whiteColor];
        self.iniTf.borderStyle = UITextBorderStyleNone;
        [self.iniTf setClearButtonMode:UITextFieldViewModeWhileEditing];//右侧删除按钮
        self.iniTf.userInteractionEnabled = NO;
        //设置键盘，使换行变为完成字样
        self.iniTf.delegate = self;
        self.iniTf.keyboardType = UIKeyboardAppearanceDefault;
        self.iniTf.returnKeyType = UIReturnKeyDone;
        
        UILabel *yuan2 = [[UILabel alloc] initWithFrame:CGRectMake(_iniTf.frame.origin.x + _iniTf.frame.size.width + 5, 0, 20, initView.frame.size.height)];
        yuan2.text = @"元";
        yuan2.textColor = RGBColorWithoutAlpha(100, 100, 100);
        
        [initView addSubview:initLabel];
        [initView addSubview:self.iniTf];
        [initView addSubview:yuan2];
        [self.view addSubview:initView];

        
        //每月结算日
        UIView *monthView = [[UIView alloc] initWithFrame:CGRectMake(0, initView.frame.origin.y + initView.frame.size.height + 10, SCREEN_WIDTH, ROW_HEIGHT)];
        monthView.backgroundColor = [UIColor whiteColor];
        
        UILabel *monthLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, 90, ROW_HEIGHT)];
        monthLabel.backgroundColor = [UIColor clearColor];
        monthLabel.textAlignment = NSTextAlignmentLeft;
        monthLabel.text = @"每月结算日:";
        monthLabel.textColor = [UIColor blackColor];
        
        self.monthTf = [[UITextField alloc] initWithFrame:CGRectMake(monthLabel.frame.origin.x + monthLabel.frame.size.width + 20, 5, monthView.frame.size.width - monthLabel.frame.origin.x - monthLabel.frame.size.width - 70, monthLabel.frame.size.height - 10)];
        self.monthTf.backgroundColor = [UIColor whiteColor];
        self.monthTf.borderStyle = UITextBorderStyleNone;
        [self.monthTf setClearButtonMode:UITextFieldViewModeWhileEditing];//右侧删除按钮
        self.monthTf.userInteractionEnabled = NO;
        //设置键盘，使换行变为完成字样
        self.monthTf.delegate = self;
        self.monthTf.keyboardType = UIKeyboardAppearanceDefault;
        self.monthTf.returnKeyType = UIReturnKeyDone;
        
        UILabel *yuan3 = [[UILabel alloc] initWithFrame:CGRectMake(_monthTf.frame.origin.x + _monthTf.frame.size.width + 5, 0, 20, monthView.frame.size.height)];
        yuan3.text = @"元";
        yuan3.textColor = RGBColorWithoutAlpha(100, 100, 100);
        
        [monthView addSubview:monthLabel];
        [monthView addSubview:self.monthTf];
        [monthView addSubview:yuan3];
        [self.view addSubview:monthView];
        
        //年度结算日
        UIView *yearView = [[UIView alloc] initWithFrame:CGRectMake(0, monthView.frame.origin.y + monthView.frame.size.height + 10, SCREEN_WIDTH, ROW_HEIGHT)];
        yearView.backgroundColor = [UIColor whiteColor];
        
        UILabel *yearLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, 90, ROW_HEIGHT)];
        yearLabel.backgroundColor = [UIColor clearColor];
        yearLabel.textAlignment = NSTextAlignmentLeft;
        yearLabel.text = @"年度结算日:";
        yearLabel.textColor = [UIColor blackColor];
        
        self.yearTf = [[UITextField alloc] initWithFrame:CGRectMake(yearLabel.frame.origin.x + yearLabel.frame.size.width + 20, 5, yearView.frame.size.width - yearLabel.frame.origin.x - yearLabel.frame.size.width - 70, yearLabel.frame.size.height - 10)];
        self.yearTf.backgroundColor = [UIColor whiteColor];
        self.yearTf.borderStyle = UITextBorderStyleNone;
        [self.yearTf setClearButtonMode:UITextFieldViewModeWhileEditing];//右侧删除按钮
        self.yearTf.userInteractionEnabled = NO;
        //设置键盘，使换行变为完成字样
        self.yearTf.delegate = self;
        self.yearTf.keyboardType = UIKeyboardAppearanceDefault;
        self.yearTf.returnKeyType = UIReturnKeyDone;
        
        UILabel *yuan4 = [[UILabel alloc] initWithFrame:CGRectMake(_yearTf.frame.origin.x + _yearTf.frame.size.width + 5, 0, 20, yearView.frame.size.height)];
        yuan4.text = @"元";
        yuan4.textColor = RGBColorWithoutAlpha(100, 100, 100);
        
        [yearView addSubview:yearLabel];
        [yearView addSubview:self.yearTf];
        [yearView addSubview:yuan4];
        [self.view addSubview:yearView];
        
        [self getData];
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


//编辑/完成事件
-(IBAction)clickEdit:(id)sender{
    if (self.type == 0) { // 编辑
        _type = 1;
        [self.editButton setTitle:@"完成" forState:UIControlStateNormal];
        self.fixedTf.userInteractionEnabled = YES;
        self.iniTf.userInteractionEnabled = YES;
        self.monthTf.userInteractionEnabled = YES;
        self.yearTf.userInteractionEnabled = YES;
        self.fixedTf.backgroundColor = RGBColorWithoutAlpha(226, 229, 228);
        self.iniTf.backgroundColor = RGBColorWithoutAlpha(226, 229, 228);
        self.monthTf.backgroundColor = RGBColorWithoutAlpha(226, 229, 228);
        self.yearTf.backgroundColor = RGBColorWithoutAlpha(226, 229, 228);
    } else { // 完成
        [self setData];
        
    }
}


//获取数据
-(void)getData{
    [self showHudInView:self.view hint:@"正在加载"];
    dispatch_async(dispatch_queue_create("getclass", DISPATCH_QUEUE_CONCURRENT), ^(){
        NSDictionary *dics = [WHInterfaceUtil noLoginWithUrl:@"AboutRestaurant.asmx" urlValue:@"http://service.xingchen.com/getBaseInfo" withParams:nil];
        if (dics!=nil) {
            int Money = [[dics objectForKey:@"Money"] integerValue];
            int BalancePerMonth = [[dics objectForKey:@"BalancePerMonth"] integerValue];
            int BalancePerYear = [[dics objectForKey:@"BalancePerYear"] integerValue];
            int Assets = [[dics objectForKey:@"Assets"] integerValue];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self hideHud];
                _fixedTf.text = [NSString stringWithFormat:@"%d", Assets];
                _iniTf.text = [NSString stringWithFormat:@"%d", Money];
                _monthTf.text = [NSString stringWithFormat:@"%d", BalancePerMonth];
                _yearTf.text = [NSString stringWithFormat:@"%d", BalancePerYear];
            });
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self hideHud];
                [CommonUtil showAlert:@"获取数据失败"];
            });
        }
    });
}

//设置数据
- (void) setData {
    [self showHudInView:self.view hint:@"正在更新"];
    dispatch_async(dispatch_queue_create("getclass", DISPATCH_QUEUE_CONCURRENT), ^(){
        
        NSMutableDictionary *baseInfo = [[NSMutableDictionary alloc] initWithCapacity:0];
        [baseInfo setObject:_iniTf.text forKey:@"Money"];
        [baseInfo setObject:_monthTf.text forKey:@"BalancePerMonth"];
        [baseInfo setObject:_yearTf.text forKey:@"BalancePerYear"];
        [baseInfo setObject:_fixedTf.text forKey:@"Assets"];
        NSString *param = [NSString stringWithFormat:@"\"baseInfo\":%@", [baseInfo JSONString]];
    
        NSDictionary *dics = [WHInterfaceUtil noLoginWithUrl:@"AboutRestaurant.asmx" urlValue:@"http://service.xingchen.com/setupBaseInfo" withParams:param];
        if (dics!=nil) {
            int isSuccess = [[dics objectForKey:@"IsSuccess"] integerValue];
            if (isSuccess == 1) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self hideHud];
                    [CommonUtil showAlert:@"更新成功"];
                    [self.navigationController popViewControllerAnimated:YES];
                });
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self hideHud];
                    [CommonUtil showAlert:@"更新失败"];
                });
            }
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self hideHud];
                [CommonUtil showAlert:@"更新失败"];
            });
        }
    });
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
