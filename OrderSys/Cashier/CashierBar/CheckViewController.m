//
//  CheckViewController.m
//  OrderSys
//
//  Created by Macx on 15/7/30.
//  Copyright (c) 2015年 北京星辰万合. All rights reserved.
//

#import "CheckViewController.h"
#import "BarNumViewController.h"
#import "WHInterfaceUtil.h"
#import "UIViewController+HUD.h"
#import "CommonUtil.h"

/**
 * 结账
 **/
@interface CheckViewController ()<UITextFieldDelegate>

@property(nonatomic,retain) UIButton *confirmButton;//结账按钮
@property(nonatomic,retain) UIButton *savingsButton;//储值支付按钮
@property(nonatomic,retain) BarNumInfo *barNumInfo;
@property(nonatomic,assign) NSInteger discount;//折扣
@property(nonatomic,assign) NSInteger maling;//抹零
@property(nonatomic,assign) NSInteger orderId;//订单id
@property(nonatomic,retain) UITextField *rincomeTf;//实收
@property(nonatomic,retain) UITextField *changeTf;//找零
@property(nonatomic,retain) NSString *payWay;//支付方式 ByCash 现金   ByPrepay 预付款划帐
@property(nonatomic,assign) Byte *operaterSign;//操作签名

@end

@implementation CheckViewController

//订单信息可用实体类传，之后在做优化
- (instancetype)initWithRIncome:(int) rincome withBarNumInfo:(BarNumInfo *) barNumInfo withIsEnoughCard:(Boolean) IsEnoughCard withOrderId:(NSInteger) orderId withMaling:(Boolean) maling withDiscount:(NSInteger) discount
{
    self = [super init];
    if (self) {
        _barNumInfo = barNumInfo;
        _discount = discount;
        _maling = maling;
        _orderId = orderId;
        
        int x = arc4random() % 100;
        _operaterSign = [CommonUtil chineseToHex:[NSString stringWithFormat:@"%@%d",@"支付方式",x]];
        
        //设置导航栏
        self.title = [NSString stringWithFormat:@"%d台", (int)_barNumInfo.barNum];
        UIColor *color = [UIColor whiteColor];
        NSDictionary * dict=[NSDictionary dictionaryWithObject:color forKey:UITextAttributeTextColor];
        [UINavigationBar appearance] .titleTextAttributes = dict;
    
    
        //应收
        UIView *incomeView = [[UIView alloc] initWithFrame:CGRectMake(0, STATU_BAR_HEIGHT + NAV_HEIGHT + 10, SCREEN_WIDTH, ROW_HEIGHT)];
        incomeView.backgroundColor = [UIColor whiteColor];

        UILabel *incomeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 80, ROW_HEIGHT)];
        incomeLabel.backgroundColor = [UIColor clearColor];
        incomeLabel.textAlignment = NSTextAlignmentCenter;
        incomeLabel.text = @"应收:";
        incomeLabel.textColor = RGBColorWithoutAlpha(100, 100, 100);
        
        UITextField *incomeTf = [[UITextField alloc] initWithFrame:CGRectMake(incomeLabel.frame.origin.x + incomeLabel.frame.size.width, 8, incomeView.frame.size.width - incomeLabel.frame.origin.x - incomeLabel.frame.size.width - 10 - 35, incomeLabel.frame.size.height - 16)];
        incomeTf.backgroundColor = RGBColorWithoutAlpha(230, 230, 230);
        [incomeTf setClearButtonMode:UITextFieldViewModeWhileEditing];//右侧删除按钮
        incomeTf.text = [NSString stringWithFormat:@"%d", rincome];;
        incomeTf.userInteractionEnabled = YES;
        //设置键盘，使换行变为完成字样
        incomeTf.delegate = self;
        incomeTf.keyboardType = UIKeyboardAppearanceDefault;
        incomeTf.returnKeyType = UIReturnKeyDone;
        
        UILabel *yuan = [[UILabel alloc] initWithFrame:CGRectMake(incomeTf.frame.origin.x + incomeTf.frame.size.width + 5, 0, 20, incomeLabel.frame.size.height)];
        yuan.text = @"元";
        yuan.textColor = RGBColorWithoutAlpha(100, 100, 100);
        
        [incomeView addSubview:incomeLabel];
        [incomeView addSubview:incomeTf];
        [incomeView addSubview:yuan];

        //实收
        UIView *rincomeView = [[UIView alloc] initWithFrame:CGRectMake(0, incomeView.frame.origin.y + incomeView.frame.size.height + 10, SCREEN_WIDTH, ROW_HEIGHT)];
        rincomeView.backgroundColor = [UIColor whiteColor];
        
        UILabel *rincomeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 80, ROW_HEIGHT)];
        rincomeLabel.backgroundColor = [UIColor clearColor];
        rincomeLabel.textAlignment = NSTextAlignmentCenter;
        rincomeLabel.text = @"实收:";
        rincomeLabel.textColor = RGBColorWithoutAlpha(100, 100, 100);
        
        _rincomeTf = [[UITextField alloc] initWithFrame:CGRectMake(rincomeLabel.frame.origin.x + rincomeLabel.frame.size.width, 8, rincomeView.frame.size.width - rincomeLabel.frame.origin.x - rincomeLabel.frame.size.width - 10 - 35, rincomeLabel.frame.size.height - 16)];
        _rincomeTf.backgroundColor = RGBColorWithoutAlpha(230, 230, 230);
        [_rincomeTf setClearButtonMode:UITextFieldViewModeWhileEditing];//右侧删除按钮
        _rincomeTf.userInteractionEnabled = YES;
        //设置键盘，使换行变为完成字样
        _rincomeTf.delegate = self;
        _rincomeTf.keyboardType = UIKeyboardAppearanceDefault;
        _rincomeTf.returnKeyType = UIReturnKeyDone;
        
        UILabel *yuan2 = [[UILabel alloc] initWithFrame:CGRectMake(_rincomeTf.frame.origin.x + _rincomeTf.frame.size.width + 5, 0, 20, rincomeLabel.frame.size.height)];
        yuan2.text = @"元";
        yuan2.textAlignment = NSTextAlignmentCenter;
        yuan2.textColor = RGBColorWithoutAlpha(100, 100, 100);
        
        [rincomeView addSubview:rincomeLabel];
        [rincomeView addSubview:_rincomeTf];
        [rincomeView addSubview:yuan2];
        
        //找零
        UIView *changeView = [[UIView alloc] initWithFrame:CGRectMake(0, rincomeView.frame.origin.y + rincomeView.frame.size.height + 10, SCREEN_WIDTH, ROW_HEIGHT)];
        changeView.backgroundColor = [UIColor whiteColor];
        
        UILabel *changeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 80, ROW_HEIGHT)];
        changeLabel.backgroundColor = [UIColor clearColor];
        changeLabel.textAlignment = NSTextAlignmentCenter;
        changeLabel.text = @"找零:";
        changeLabel.textColor = RGBColorWithoutAlpha(100, 100, 100);
        
        _changeTf = [[UITextField alloc] initWithFrame:CGRectMake(changeLabel.frame.origin.x + changeLabel.frame.size.width, 8, changeView.frame.size.width - changeLabel.frame.origin.x - changeLabel.frame.size.width - 10 - 35, changeLabel.frame.size.height - 16)];
        _changeTf.backgroundColor = RGBColorWithoutAlpha(230, 230, 230);
        [_changeTf setClearButtonMode:UITextFieldViewModeWhileEditing];//右侧删除按钮
        _changeTf.userInteractionEnabled = YES;
        //设置键盘，使换行变为完成字样
        _changeTf.delegate = self;
        _changeTf.keyboardType = UIKeyboardAppearanceDefault;
        _changeTf.returnKeyType = UIReturnKeyDone;
        
        UILabel *yuan3 = [[UILabel alloc] initWithFrame:CGRectMake(_changeTf.frame.origin.x + _changeTf.frame.size.width + 5, 0, 20, changeLabel.frame.size.height)];
        yuan3.text = @"元";
        yuan3.textColor = RGBColorWithoutAlpha(100, 100, 100);
        
        [changeView addSubview:changeLabel];
        [changeView addSubview:_changeTf];
        [changeView addSubview:yuan3];
        
        //确认
        _confirmButton = [[UIButton alloc] initWithFrame:CGRectMake(40, SCREEN_HEIGHT - ROW_HEIGHT * 3, SCREEN_WIDTH - 80, ROW_HEIGHT - 10)];
        _confirmButton.layer.cornerRadius = 5;
        _confirmButton.backgroundColor = [UIColor redColor];
        [_confirmButton setTitle:@"确　认" forState:UIControlStateNormal];
        _confirmButton.titleLabel.textColor = [UIColor whiteColor];
        _confirmButton.tag = 0;
        [_confirmButton addTarget:self action:@selector(clickButtons:) forControlEvents:UIControlEventTouchUpInside];
        
        //储值支付
        _savingsButton = [[UIButton alloc] initWithFrame:CGRectMake(40, _confirmButton.frame.origin.y + _confirmButton.frame.size.height + 10, SCREEN_WIDTH - 80, ROW_HEIGHT - 10)];
        _savingsButton.layer.cornerRadius = 5;
        _savingsButton.backgroundColor = [UIColor redColor];
        [_savingsButton setTitle:@"储值支付" forState:UIControlStateNormal];
        _savingsButton.titleLabel.textColor = [UIColor whiteColor];
        _savingsButton.tag = 1;
        [_savingsButton addTarget:self action:@selector(clickButtons:) forControlEvents:UIControlEventTouchUpInside];


        
        [self.view addSubview:incomeView];
        [self.view addSubview:rincomeView];
        [self.view addSubview:changeView];
        [self.view addSubview:_confirmButton];
        [self.view addSubview:_savingsButton];
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


//确认事件
-(IBAction)clickButtons:(id)sender{
    UIButton *button = (UIButton *) sender;
    NSInteger tag = button.tag;
    switch (tag) {
        case 0:
            //确认
            _payWay = @"ByCash";
            break;
        case 1:
            //储蓄支付
            _payWay = @"预付款划帐";
            break;
        default:
            break;
    }
    [self checkOut];
}

//支付
- (void) checkOut {
    dispatch_async(dispatch_queue_create("getclass", DISPATCH_QUEUE_CONCURRENT), ^(){
        if (_maling == 1) {
            _maling = YES;
        } else {
            _maling = NO;
        }
        int received = [_rincomeTf.text integerValue];
        int oddChange = [_changeTf.text integerValue];
        NSString *param =[NSString stringWithFormat:@"%@,%@,%@,%@,%@,%@,%@,%@",
                          [WHInterfaceUtil longToJsonString:@"tId" withValue:_barNumInfo.barNum],
                          [WHInterfaceUtil longToJsonString:@"oId" withValue:_orderId],
                          [WHInterfaceUtil boolToJsonString:@"round" withValue:_maling],
                          [WHInterfaceUtil intToJsonString:@"discount" withValue:_discount],
                          [WHInterfaceUtil intToJsonString:@"received" withValue:received],
                          [WHInterfaceUtil intToJsonString:@"oddChange" withValue:oddChange],
                          [WHInterfaceUtil stringToJsonString:@"payWay" withValue:_payWay],
                          [WHInterfaceUtil byteArrayToJsonString:@"operaterSign" withValue:(char *)_operaterSign withLength:16]];
        NSDictionary *dics = [WHInterfaceUtil noLoginWithUrl:@"AboutBooking.asmx" urlValue:@"http://service.xingchen.com/finishBill" withParams:param];
        if (dics!=nil) {
            int isSuccess = [[dics objectForKey:@"IsSuccess"] integerValue];
            if (isSuccess == 1) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [CommonUtil showAlert:@"支付成功"];
                    [self.navigationController popToViewController: [self.navigationController.viewControllers objectAtIndex: ([self.navigationController.viewControllers count] -3)] animated:YES];
                });
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [CommonUtil showAlert:@"支付失败"];
                });
            }
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSLog(@"%@",@"获取数据失败");
            });
        }
    });
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
