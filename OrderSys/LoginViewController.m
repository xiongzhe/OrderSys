//
//  LoginViewController.m
//  OrderSys
//
//  Created by Macx on 15/8/21.
//  Copyright (c) 2015年 北京星辰万合. All rights reserved.
//

#import "LoginViewController.h"
#import "ViewController.h"
#import "WHInterfaceUtil.h"
#import "UIViewController+HUD.h"
#import "CommonUtil.h"
#import "SecretUtil.h"
#import "NotifyClient.h"
#import "AppDelegate.h"
#import "LoginInfo.h"
#import "GlobeVars.h"

#define TF_HEIGHT 40 * WIDTH_RATE

/**
 * 登录页面
 **/
@interface LoginViewController ()<UITextFieldDelegate>

@property (nonatomic, retain) UITextField *unameTf;
@property (nonatomic, retain) UITextField *pswTf;

@end

@implementation LoginViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        //背景图片
        UIImageView *bg = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
        [bg setImage:[UIImage imageNamed:@"login"]];
        [self.view addSubview:bg];
        
        CGFloat top = 120;
        if (IS_IPHONE_4_OR_LESS) {
            top = 120;
        } else if(IS_IPHONE_5) {
            top = 150;
        } else if(IS_IPHONE_6) {
            top = 180;
        } else {
            top = 280;
        }
        
        //用户名
        UIView *unameView = [[UIView alloc] initWithFrame:CGRectMake(60 * WIDTH_RATE, top, SCREEN_WIDTH - 120 * WIDTH_RATE, TF_HEIGHT)];
        unameView.backgroundColor = [UIColor whiteColor];
        unameView.backgroundColor = RGBColor(100, 100, 100, 0.8);
        unameView.layer.cornerRadius = 5;
        _unameTf = [[UITextField alloc] initWithFrame:CGRectMake(10, 0, unameView.frame.size.width - 20, unameView.frame.size.height)];
        [_unameTf setClearButtonMode:UITextFieldViewModeWhileEditing];//右侧删除按钮
        _unameTf.textColor = [UIColor whiteColor];
        _unameTf.delegate = self;
        _unameTf.text = @"aaa";
        _unameTf.keyboardType = UIKeyboardAppearanceDefault;
        _unameTf.returnKeyType = UIReturnKeyDone;
        [unameView addSubview:_unameTf];
        [self.view addSubview:unameView];
        
        //密码
        UIView *pswView = [[UIView alloc] initWithFrame:CGRectMake(60 * WIDTH_RATE, unameView.frame.origin.y + unameView.frame.size.height + 7 * HEIGHT_RATE, SCREEN_WIDTH - 120 * WIDTH_RATE, TF_HEIGHT)];
        pswView.backgroundColor = [UIColor whiteColor];
        pswView.backgroundColor = RGBColor(100, 100, 100, 0.8);
        pswView.layer.cornerRadius = 5;
        _pswTf = [[UITextField alloc] initWithFrame:CGRectMake(10, 0, pswView.frame.size.width - 20, pswView.frame.size.height)];
        [_pswTf setClearButtonMode:UITextFieldViewModeWhileEditing];//右侧删除按钮
        _pswTf.textColor = [UIColor whiteColor];
        _pswTf.delegate = self;
        _pswTf.text = @"123456";
        _pswTf.keyboardType = UIKeyboardAppearanceDefault;
        _pswTf.returnKeyType = UIReturnKeyDone;
        [pswView addSubview:_pswTf];
        [self.view addSubview:pswView];
        
        //登录按钮
        UIButton *loginButton = [[UIButton alloc] initWithFrame:CGRectMake(pswView.frame.origin.x + 20 * WIDTH_RATE, pswView.frame.origin.y + pswView.frame.size.height + 7 * HEIGHT_RATE, pswView.frame.size.width - 40 * WIDTH_RATE, TF_HEIGHT)];
        [loginButton setTitle:@"登录" forState:UIControlStateNormal];
        [loginButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        loginButton.backgroundColor = [UIColor redColor];
        loginButton.layer.cornerRadius = 8;
        [loginButton addTarget:self action:@selector(clickLogin:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:loginButton];
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
}


//登录事件
-(IBAction)clickLogin:(id)sender {
    [self showHudInView:self.view hint:@"正在登录"];
    NSString *unameStr = _unameTf.text;
    NSString *pwdStr = _pswTf.text;
    
//    dispatch_async(dispatch_queue_create("getclass", DISPATCH_QUEUE_CONCURRENT), ^(){
//        
//        NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithCapacity:0];
//        [params setValue:@1 forKey:@"version"];
//        [params setValue:@1 forKey:@"system"];
//        [params setValue:unameStr forKey:@"uname"];
//        [params setValue:pwdStr forKey:@"pwd"];
//        
//        NSDictionary *dics = [WHInterfaceUtil loginWithUrl:@"AboutRestaurant.asmx" urlValue:@"http://service.xingchen.com/login" withParams:params];
//        
//        if (dics!=nil) {
//            LoginInfo *loginInfo = [[LoginInfo alloc] init];
//            NSArray *role = [dics objectForKey:@"Role"];
//            loginInfo.roles = role;
//            loginInfo.rid = [dics objectForKey:@"RId"];
//            loginInfo.uid = [dics objectForKey:@"Uid"];
//            loginInfo.token = [dics objectForKey:@"Token"];
//            
//            for (int i=0;i<sizeof(gLoginRespToken);i++){
//                gLoginRespToken[i] =[[loginInfo.token objectAtIndex:(i)] integerValue] ;
//            }
//        
//            AppDelegate *app = [[UIApplication sharedApplication] delegate];
//            app.loginInfo = loginInfo;
//            
//            dispatch_async(dispatch_get_main_queue(), ^{
    
                [self hideHud];
                _window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
                _window.backgroundColor = [UIColor whiteColor];
                ViewController *root = [[ViewController alloc]init];
                UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:root];//先将root添加在navigation上
                [_window setRootViewController:nav];//navigation加在window上
                [_window makeKeyAndVisible];
//            });
//
//        } else {
//            dispatch_async(dispatch_get_main_queue(), ^{
//                [self hideHud];
//                [CommonUtil showAlert:@"登录失败"];
//            });
//        }
//    });
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
