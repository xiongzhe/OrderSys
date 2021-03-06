//
//  BarCardViewController.m
//  OrderSys
//
//  Created by Macx on 15/8/18.
//  Copyright (c) 2015年 北京星辰万合. All rights reserved.
//

#import "BarCardViewController.h"
#import "DBImageView.h"
#import "CommonUtil.h"
#import "WHInterfaceUtil.h"
#import "UIViewController+HUD.h"

@interface BarCardViewController ()<UITextFieldDelegate>

@property(nonatomic, retain) NSString *imageUrl;
@property(nonatomic, retain) DBImageView *qrImage;
@property(nonatomic, retain) UITextField *numTf;

@end

/**
 * 收银管理储值管理页
 **/
@implementation BarCardViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        //储值金额视图
        UIView *numView = [[UILabel alloc] initWithFrame:CGRectMake(0, STATU_BAR_HEIGHT + NAV_HEIGHT + 10, SCREEN_WIDTH, ROW_HEIGHT)];
        numView.backgroundColor = [UIColor whiteColor];
        
        UIButton *phoneButton = [[UIButton alloc] initWithFrame:CGRectMake(0, STATU_BAR_HEIGHT + NAV_HEIGHT + 10, 40, numView.frame.size.height)];
        [phoneButton setImage:[UIImage imageNamed:@"select_yes"] forState:UIControlStateNormal];
        
        _numTf = [[UITextField alloc] initWithFrame:CGRectMake(phoneButton.frame.origin.x + phoneButton.frame.size.width + 5, STATU_BAR_HEIGHT + NAV_HEIGHT + 18, numView.frame.size.width - phoneButton.frame.origin.x - phoneButton.frame.size.width - 20, numView.frame.size.height - 16)];
        _numTf.backgroundColor = RGBColorWithoutAlpha(226, 229, 228);
        _numTf.borderStyle = UITextBorderStyleNone;
        [_numTf setClearButtonMode:UITextFieldViewModeWhileEditing];//右侧删除按钮
        _numTf.placeholder = @"输入储值金额";
        //设置键盘，使换行变为完成字样
        _numTf.delegate = self;
        _numTf.keyboardType = UIKeyboardAppearanceDefault;
        _numTf.returnKeyType = UIReturnKeyDone;
        
        [self.view addSubview:numView];
        [self.view addSubview:phoneButton];
        [self.view addSubview:_numTf];
        
        //生成二维码
        UIButton *qrButton = [[UIButton alloc] initWithFrame:CGRectMake(40, numView.frame.origin.y + numView.frame.size.height + 20, SCREEN_WIDTH - 80, ROW_HEIGHT - 10)];
        qrButton.layer.cornerRadius = 5;
        qrButton.backgroundColor = [UIColor redColor];
        [qrButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [qrButton setTitle:@"生成二维码" forState:UIControlStateNormal];
        [qrButton addTarget:self action:@selector(clickQr:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:qrButton];
        
        _qrImage = [[DBImageView alloc] initWithFrame:CGRectMake(40, qrButton.frame.origin.y + qrButton.frame.size.height + 10, SCREEN_WIDTH - 80, SCREEN_WIDTH - 80)];
        [_qrImage setHidden:YES];
        [self.view addSubview:_qrImage];
        

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


//获取二维码事件
-(IBAction)clickQr:(id)sender {
    if ([_numTf.text isEqualToString:@""]) {
        [self showAlert:@"请输入储值金额"];
    } else {
        [self getData];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//弹窗
- (void) showAlert:(NSString *) text{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:text delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [alert show];
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

//获取数据
-(void)getData{
    dispatch_async(dispatch_queue_create("getclass", DISPATCH_QUEUE_CONCURRENT), ^(){
        NSString *string = _numTf.text;
        NSString *param =[NSString stringWithFormat:@"%@", [WHInterfaceUtil intToJsonString:@"money" withValue:[string intValue]]];
        NSDictionary *dics = [WHInterfaceUtil noLoginWithUrl:@"AboutCustomer.asmx" urlValue:@"http://service.xingchen.com/storeMoney" withParams:param];
        if (dics!=nil) {
            _imageUrl = [dics objectForKey:@"QRImageUrl"];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [_qrImage setHidden:NO];
                [_qrImage setImageWithPath:_imageUrl];
                [[self view] endEditing:YES];
            });
            
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                //[CommonUtil showAlert:@"获取数据失败"];
            });
        }
    });
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
