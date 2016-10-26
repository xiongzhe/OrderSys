
//
//  BarOrderViewController.m
//  OrderSys
//
//  Created by Macx on 15/7/29.
//  Copyright (c) 2015年 北京星辰万合. All rights reserved.
//

#import "BarOrderViewController.h"
#import "DishCell.h"
#import "DishInfo.h"
#import "CheckViewController.h"
#import "ButtonView.h"
#import "CommonUtil.h"
#import "WHInterfaceUtil.h"
#import "UIViewController+HUD.h"
#import "OrderInfo.h"

/**
 * 收银管理订单页
 **/
@interface BarOrderViewController ()<UIScrollViewDelegate,UITextFieldDelegate,UITableViewDataSource,UITableViewDelegate>

@property(nonatomic,retain) NSMutableArray *dataList;
@property(nonatomic,retain) UITableView *myTableView;
@property(nonatomic,retain) BarNumInfo *barNumInfo;
@property(nonatomic,retain) UIScrollView *scrollView;
@property(nonatomic,retain) ButtonView *couponsButton;//优惠券勾选按钮
@property(nonatomic,retain) ButtonView *discountButton;//打折勾选按钮
@property(nonatomic,retain) ButtonView *malingButton;//抹零勾选按钮
@property(nonatomic,retain) UIButton *checkButton;//结账按钮
@property(nonatomic,retain) UILabel *orderNumText;//订单编号
@property(nonatomic,retain) UILabel *orderTimeText;//订单时间
@property(nonatomic,retain) UITextField *spendTf;//消费金额

@property(nonatomic,assign) int isDiscount; //是否点击了打折
@property(nonatomic,assign) int isMaling; //是否点击了抹零
@property(nonatomic,assign) int rIncome; //实际

@property(nonatomic,assign) NSInteger orderId; //订单id
@property(nonatomic,assign) NSInteger orderNo; //订单编号
@property(nonatomic,retain) NSString *orderTime; //订单时间
@property(nonatomic,assign) NSInteger orderReceivable; //订单金额
@property(nonatomic,assign) NSInteger isPromotion;//是否使用优惠券

@end

@implementation BarOrderViewController

- (instancetype)initWithBarNumInfo:(BarNumInfo *) barNumInfo
{
    self = [super init];
    if (self) {
        
        _isPromotion = 0;
        _isDiscount = 0;
        _isMaling = 0;
        _rIncome = 0;
        _barNumInfo = barNumInfo;
        
        //设置导航栏
        self.title = [NSString stringWithFormat:@"%d台", (int)_barNumInfo.barNum];
        UIColor *color = [UIColor whiteColor];
        NSDictionary * dict=[NSDictionary dictionaryWithObject:color forKey:UITextAttributeTextColor];
        [UINavigationBar appearance] .titleTextAttributes = dict;
        //设置导航栏返回按钮
        UIBarButtonItem *backItem = [[UIBarButtonItem alloc] init];
        backItem.title = @"返回";
        self.navigationItem.backBarButtonItem = backItem;
        //导航栏右侧打印按钮
        UIButton *printButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 50, NAV_HEIGHT)];
        [printButton setTitle:@"打印" forState:UIControlStateNormal];
        printButton.titleLabel.textColor = [UIColor whiteColor];
        printButton.backgroundColor = [UIColor clearColor];
        printButton.titleLabel.font = [UIFont boldSystemFontOfSize:16];
        [printButton addTarget:self action:@selector(clickPrint:) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:printButton];
        self.navigationItem.rightBarButtonItem = rightItem;
        
        //滚动视图
        _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, NAV_HEIGHT + STATU_BAR_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT)];
        
        //订单编号
        UIView *orderNumView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, ROW_HEIGHT - 10)];
        
        UILabel *orderNumLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, 80, orderNumView.frame.size.height)];
        orderNumLabel.text = @"订单编号:";
        orderNumLabel.textColor = RGBColorWithoutAlpha(100, 100, 100);
        orderNumLabel.font = [UIFont systemFontOfSize:15];
        orderNumLabel.backgroundColor = [UIColor clearColor];
        
        _orderNumText = [[UILabel alloc] initWithFrame:CGRectMake(orderNumLabel.frame.origin.x + orderNumLabel.frame.size.width, 0, orderNumView.frame.size.width - orderNumLabel.frame.origin.x - orderNumLabel.frame.size.width, orderNumLabel.frame.size.height)];
        _orderNumText.text = @"0000000000";
        _orderNumText.font = [UIFont systemFontOfSize:15];
        _orderNumText.textColor = RGBColorWithoutAlpha(100, 100, 100);
        _orderNumText.backgroundColor = [UIColor clearColor];
        
        [orderNumView addSubview:orderNumLabel];
        [orderNumView addSubview:_orderNumText];
        
        //订单时间
        UIView *orderTimeView = [[UIView alloc] initWithFrame:CGRectMake(0, orderNumView.frame.origin.y + orderNumView.frame.size.height, SCREEN_WIDTH, ROW_HEIGHT - 10)];
        orderTimeView.layer.borderWidth = 0.5;
        orderTimeView.layer.borderColor = RGBColorWithoutAlpha(200, 200, 200).CGColor;
        
        UILabel *orderTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, 80, orderTimeView.frame.size.height)];
        orderTimeLabel.text = @"订单时间:";
        orderTimeLabel.textColor = RGBColorWithoutAlpha(100, 100, 100);
        orderTimeLabel.font = [UIFont systemFontOfSize:15];
        orderTimeLabel.backgroundColor = [UIColor clearColor];
        
        _orderTimeText = [[UILabel alloc] initWithFrame:CGRectMake(orderTimeLabel.frame.origin.x + orderTimeLabel.frame.size.width, 0, orderTimeView.frame.size.width - orderTimeLabel.frame.origin.x - orderTimeLabel.frame.size.width, orderTimeLabel.frame.size.height)];
        _orderTimeText.text = @"2012-09-08 12:00:01";
        _orderTimeText.textColor = RGBColorWithoutAlpha(100, 100, 100);
        _orderTimeText.font = [UIFont systemFontOfSize:15];
        _orderTimeText.backgroundColor = [UIColor clearColor];
        
        [orderTimeView addSubview:orderTimeLabel];
        [orderTimeView addSubview:_orderTimeText];
        
        //菜单列表头标识
        UIView *headView = [[UIView alloc] initWithFrame:CGRectMake(0, orderTimeView.frame.origin.y + orderTimeView.frame.size.height, SCREEN_WIDTH, ROW_HEIGHT - 10)];
        
        //菜品名称
        UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, (headView.frame.size.width - 20) * 1/2, headView.frame.size.height)];
        nameLabel.backgroundColor = [UIColor clearColor];
        nameLabel.textAlignment = NSTextAlignmentLeft;
        nameLabel.font = [UIFont systemFontOfSize:15.0];
        nameLabel.textColor = RGBColorWithoutAlpha(100, 100, 100);
        nameLabel.text = @"菜品名称";
        [headView addSubview:nameLabel];
        
        //数量
        UILabel *numLabel = [[UILabel alloc] initWithFrame:CGRectMake(nameLabel.frame.origin.x + nameLabel.frame.size.width, 0, (headView.frame.size.width - 20)  * 1/4 , headView.frame.size.height)];
        numLabel.backgroundColor = [UIColor clearColor];
        numLabel.textAlignment = NSTextAlignmentCenter;
        numLabel.font = [UIFont systemFontOfSize:15.0];
        numLabel.textColor = RGBColorWithoutAlpha(100, 100, 100);
        numLabel.text = @"数量";
        [headView addSubview:numLabel];
        
        //金额
        UILabel *moneyLabel = [[UILabel alloc] initWithFrame:CGRectMake(numLabel.frame.origin.x + numLabel.frame.size.width, 0, (headView.frame.size.width - 20)  * 1/4, headView.frame.size.height)];
        moneyLabel.backgroundColor = [UIColor clearColor];
        moneyLabel.textAlignment = NSTextAlignmentCenter;
        moneyLabel.font = [UIFont systemFontOfSize:15.0];
        moneyLabel.textColor = RGBColorWithoutAlpha(100, 100, 100);
        moneyLabel.text = @"金额";
        [headView addSubview:moneyLabel];
        
        
        //菜单列表
        self.dataList = [NSMutableArray arrayWithCapacity:0];
        DishInfo *dishInfo;
        int num = 4;
        for (int i=0; i < num; i++) {
            dishInfo = [[DishInfo alloc] init];
            dishInfo.dishName = @"宫爆鸡丁";
            dishInfo.dishNum = 1;
            dishInfo.dishMoney = @"30.00";
            [self.dataList addObject:dishInfo];
        }
        UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, headView.frame.origin.y + headView.frame.size.height, _scrollView.frame.size.width, num * 34) style:UITableViewStylePlain];
        tableView.dataSource = self;
        tableView.delegate = self;
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        tableView.scrollEnabled = NO;
        tableView.userInteractionEnabled = NO;
        self.myTableView = tableView;
        
        [_scrollView addSubview:orderNumView];
        [_scrollView addSubview:orderTimeView];
        [_scrollView addSubview:headView];
        [_scrollView addSubview:tableView];
        
        [self getData];
    }
    return self;
}

//设置自适应视图
- (void) setView {
    //消费金额
    UIView *spendView = [[UIView alloc] initWithFrame:CGRectMake(0, _myTableView.frame.origin.y + _myTableView.frame.size.height, SCREEN_WIDTH, ROW_HEIGHT)];
    spendView.layer.borderWidth = 0.5;
    spendView.layer.borderColor = RGBColorWithoutAlpha(200, 200, 200).CGColor;
    spendView.backgroundColor = [UIColor whiteColor];
    
    UILabel *spendLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, 80, spendView.frame.size.height)];
    spendLabel.text = @"消费金额:";
    spendLabel.font = [UIFont systemFontOfSize:16];
    spendLabel.backgroundColor = [UIColor clearColor];
    spendLabel.textColor = RGBColorWithoutAlpha(100, 100, 100);
    
    _spendTf = [[UITextField alloc] initWithFrame:CGRectMake(spendLabel.frame.origin.x + spendLabel.frame.size.width, 8, spendView.frame.size.width - spendLabel.frame.origin.x - spendLabel.frame.size.width - 10 - 35, spendLabel.frame.size.height - 16)];
    _spendTf.backgroundColor = RGBColorWithoutAlpha(230, 230, 230);
    [_spendTf setClearButtonMode:UITextFieldViewModeWhileEditing];//右侧删除按钮
    _spendTf.userInteractionEnabled = YES;
    //设置键盘，使换行变为完成字样
    _spendTf.delegate = self;
    _spendTf.keyboardType = UIKeyboardAppearanceDefault;
    _spendTf.returnKeyType = UIReturnKeyDone;
    
    UILabel *yuan = [[UILabel alloc] initWithFrame:CGRectMake(_spendTf.frame.origin.x + _spendTf.frame.size.width + 5, 0, 20, spendLabel.frame.size.height)];
    yuan.text = @"元";
    yuan.textColor = RGBColorWithoutAlpha(100, 100, 100);
    
    [spendView addSubview:spendLabel];
    [spendView addSubview:_spendTf];
    [spendView addSubview:yuan];
    
    //优惠信息
    UILabel *couponsInfoLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, spendView.frame.origin.y + spendView.frame.size.height + 5, SCREEN_WIDTH, ROW_HEIGHT - 10)];
    couponsInfoLabel.text = @"优惠信息";
    couponsInfoLabel.font = [UIFont systemFontOfSize:14];
    couponsInfoLabel.backgroundColor = [UIColor clearColor];
    couponsInfoLabel.textColor = RGBColorWithoutAlpha(100, 100, 100);
    
    
    //优惠券
    UIView *couponsView = [[UIView alloc] initWithFrame:CGRectMake(0, couponsInfoLabel.frame.origin.y + couponsInfoLabel.frame.size.height, SCREEN_WIDTH, ROW_HEIGHT)];
    couponsView.layer.borderWidth = 0.5;
    couponsView.layer.borderColor = RGBColorWithoutAlpha(200, 200, 200).CGColor;
    couponsView.backgroundColor = [UIColor whiteColor];
    couponsView.userInteractionEnabled = YES;
    
    _couponsButton = [[ButtonView alloc] initWithFrame:CGRectMake(40, 10, 70, couponsView.frame.size.height - 20) withType:0 withTag:0 withTitle:@"优惠券"];
    [_couponsButton addTarget:self action:@selector(clickChoose:) forControlEvents:UIControlEventTouchUpInside];
    [_couponsButton setChooseType:0];
    [couponsView addSubview:_couponsButton];
    
    //打折
    UIView *dicountView = [[UIView alloc] initWithFrame:CGRectMake(0, couponsView.frame.origin.y + couponsView.frame.size.height, SCREEN_WIDTH, ROW_HEIGHT)];
    dicountView.backgroundColor = [UIColor whiteColor];
    dicountView.userInteractionEnabled = YES;
    dicountView.tag = 1;
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickChoose:)];
    [dicountView addGestureRecognizer:singleTap];
    
    _discountButton = [[ButtonView alloc] initWithFrame:CGRectMake(40, 10, 70, dicountView.frame.size.height - 20) withType:0 withTag:1 withTitle:@"打折"];
    [_discountButton addTarget:self action:@selector(clickChoose:) forControlEvents:UIControlEventTouchUpInside];
    if (_isDiscount == 0) {
        [_couponsButton setChooseType:0];
    } else{
        [_couponsButton setChooseType:1];
    }
    
    [dicountView addSubview:_discountButton];
    
    //抹零
    UIView *malingView = [[UIView alloc] initWithFrame:CGRectMake(0, dicountView.frame.origin.y + dicountView.frame.size.height, SCREEN_WIDTH, ROW_HEIGHT)];
    malingView.layer.borderWidth = 0.5;
    malingView.layer.borderColor = RGBColorWithoutAlpha(200, 200, 200).CGColor;
    malingView.backgroundColor = [UIColor whiteColor];
    malingView.userInteractionEnabled = YES;
    malingView.tag = 2;
    singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickChoose:)];
    [malingView addGestureRecognizer:singleTap];
    
    _malingButton = [[ButtonView alloc] initWithFrame:CGRectMake(40, 10, 70, dicountView.frame.size.height - 20) withType:0 withTag:2 withTitle:@"抹零"];
    [_malingButton addTarget:self action:@selector(clickChoose:) forControlEvents:UIControlEventTouchUpInside];
    if (_isMaling == 0) {
        [_malingButton setChooseType:0];
    } else{
        [_malingButton setChooseType:1];
    }
    
    [malingView addSubview:_malingButton];
    
    //结账
    _checkButton = [[UIButton alloc] initWithFrame:CGRectMake(40, malingView.frame.origin.y + malingView.frame.size.height + 20, SCREEN_WIDTH - 80, ROW_HEIGHT - 10)];
    _checkButton.layer.cornerRadius = 5;
    _checkButton.backgroundColor = [UIColor redColor];
    [_checkButton setTitle:@"结　账" forState:UIControlStateNormal];
    _checkButton.titleLabel.textColor = [UIColor whiteColor];
    [_checkButton addTarget:self action:@selector(clickCheck:) forControlEvents:UIControlEventTouchUpInside];
    
    

    [_scrollView addSubview:spendView];
    [_scrollView addSubview:couponsInfoLabel];
    [_scrollView addSubview:couponsView];
    [_scrollView addSubview:dicountView];
    [_scrollView addSubview:malingView];
    [_scrollView addSubview:_checkButton];
    [self.view addSubview:_scrollView];
    
    [self setupPage:nil];

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


//改变滚动视图的方法实现
- (void)setupPage:(id)sender {
    //设置委托
    self.scrollView.delegate = self;
    //设置背景颜色
    self.scrollView.backgroundColor = [UIColor clearColor];
    //设置取消触摸
    self.scrollView.canCancelContentTouches = NO;
    //设置滚动条类型
    self.scrollView.indicatorStyle = UIScrollViewIndicatorStyleWhite;
    //是否自动裁切超出部分
    self.scrollView.clipsToBounds = YES;
    //设置是否可以缩放
    self.scrollView.scrollEnabled = YES;
    //设置是否可以进行画面切换
    self.scrollView.pagingEnabled = NO;
    //设置在拖拽的时候是否锁定其在水平或者垂直的方向
    self.scrollView.directionalLockEnabled = YES;
    //隐藏滚动条设置（水平、跟垂直方向）
    self.scrollView.alwaysBounceHorizontal = NO;
    self.scrollView.alwaysBounceVertical = YES;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.showsVerticalScrollIndicator = NO;
    //设置滚动视图的位置
    _scrollView.contentSize = CGSizeMake(SCREEN_WIDTH, STATU_BAR_HEIGHT + NAV_HEIGHT + _checkButton.frame.origin.y + _checkButton.frame.size.height + 10);
}

//创建并设置每行显示的内容
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellWithIdentifier = @"Cell";
    DishCell *cell = [tableView dequeueReusableCellWithIdentifier:CellWithIdentifier];
    if (cell == nil) {
        cell = [[DishCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:CellWithIdentifier withCellHeight:34];
    }
    NSUInteger row = [indexPath row];
    DishInfo *info = [self.dataList objectAtIndex:row];
    cell.dishName.text = info.dishName;
    cell.dishNum.text = [NSString stringWithFormat:@"%d份", (int)info.dishNum];
    cell.dishMoney.text = info.dishMoney;
    cell.backgroundColor = RGBColorWithoutAlpha(226, 229, 228);
    return cell;
}

//内容分段
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

//cell高度
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 34;
}

//每个cell中显示多少行
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [_dataList count];
}

//列表点击事件
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
}


//勾选图标
-(IBAction)clickChoose:(id)sender{
    UIButton *button = (UIButton *) sender;
    NSInteger tag = button.tag;
    switch (tag) {
        case 1:
            if (_isDiscount == 0) {
                _isDiscount = 1;
                [self.discountButton setChooseType:1];
            } else{
                _isDiscount = 0;
                [self.discountButton setChooseType:0];
            }
            break;
        case 2:
            if (_isMaling == 0) {
                _isMaling = 1;
                [self.malingButton setChooseType:1];
            } else{
                _isMaling = 0;
                [self.malingButton setChooseType:0];
            }
            break;
        default:
            break;
    }
}

//结账
-(IBAction)clickCheck:(id)sender{
    [self checkOut];
}

//点击打印
-(IBAction)clickPrint:(id)sender {
    NSLog(@"打印");
}

//获取数据
-(void)getData{
    [self showHudInView:self.view hint:@"正在加载"];
    _dataList = [[NSMutableArray alloc] init];
    
    dispatch_async(dispatch_queue_create("getclass", DISPATCH_QUEUE_CONCURRENT), ^(){
        NSString *param =[NSString stringWithFormat:@"%@", [WHInterfaceUtil longToJsonString:@"tId" withValue:_barNumInfo.barNum]];
        NSDictionary *dics = [WHInterfaceUtil noLoginWithUrl:@"AboutBooking.asmx" urlValue:@"http://service.xingchen.com/getOrderByTable" withParams:param];
        if (dics!=nil) {
            _orderId = [[dics objectForKey:@"OrderId"] integerValue];
            _orderNo = [[dics objectForKey:@"OrderNo"] integerValue];
            _orderTime = [dics objectForKey:@"OrderTime"];
            _orderReceivable = [[dics objectForKey:@"Receivable"] floatValue]/100.0f;
            NSMutableDictionary *PromotionIds = [dics objectForKey:@"PromotionIds"];
            if ([PromotionIds count] >0) {
                _isPromotion = 1;
            }
            //菜单信息
            NSMutableDictionary *OrderDish = [dics objectForKey:@"OrderDish"];
            DishInfo *dishInfo;
            for (NSDictionary *key in OrderDish) {
                dishInfo = [[DishInfo alloc] init];
                dishInfo.dishName = [key objectForKey:@"DishName"];
                dishInfo.dishMoney = [NSString stringWithFormat:@"%d",[[key objectForKey:@"DishAmount"] integerValue]/100];
                dishInfo.dishNum = [[key objectForKey:@"DishCount"] integerValue];
                [_dataList addObject:dishInfo];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [self hideHud];
                [_myTableView reloadData];
                [self setView];
                _orderNumText.text = [NSString stringWithFormat:@"%d", _orderNo];
                _orderTimeText.text = _orderTime;
                _spendTf.text = [NSString stringWithFormat:@"%d", _orderReceivable];
                if (_isPromotion == 1) {
                    [_couponsButton setChooseType:1];
                }
                
            });
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self hideHud];
                [CommonUtil showAlert:@"获取数据失败"];
            });
        }
    });
}


//结账
- (void) checkOut {
    dispatch_async(dispatch_queue_create("getclass", DISPATCH_QUEUE_CONCURRENT), ^(){
        Boolean maling;
        if (_isMaling == 1) {
            maling = YES;
        } else {
            maling = NO;
        }
        NSInteger discount;
        if (_isDiscount == 1) { //时间来不及，先做一个点击即打5折的效果，方便先联调
            discount = 50;
        } else {
            discount = 100;
        }
        NSString *param =[NSString stringWithFormat:@"%@,%@,%@,%@",
                [WHInterfaceUtil longToJsonString:@"tId" withValue:_barNumInfo.barNum],
                [WHInterfaceUtil longToJsonString:@"oId" withValue:_orderId],
                [WHInterfaceUtil boolToJsonString:@"round" withValue:maling],
                [WHInterfaceUtil intToJsonString:@"discount" withValue:discount]];
        NSDictionary *dics = [WHInterfaceUtil noLoginWithUrl:@"AboutBooking.asmx" urlValue:@"http://service.xingchen.com/checkOrder" withParams:param];
        if (dics!=nil) {
            //long BillId = [[dics objectForKey:@"BillId"] longValue];
            _rIncome = [[dics objectForKey:@"Receivable"] integerValue]/100;
            Boolean IsEnoughCard = [[dics objectForKey:@"IsEnoughCard"] boolValue];
    
            dispatch_async(dispatch_get_main_queue(), ^{
                CheckViewController *check = [[CheckViewController alloc] initWithRIncome:_rIncome withBarNumInfo:_barNumInfo withIsEnoughCard:IsEnoughCard withOrderId:_orderId withMaling:maling withDiscount:discount];
                [self.navigationController pushViewController:check animated:YES];
            });
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

//***更改frame的值***//
//在UITextField 编辑之前调用方法
- (void)textFieldDidBeginEditing:(UITextField *)textField {
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
}
//在UITextField 编辑完成调用方法
- (void)textFieldDidEndEditing:(UITextField *)textField {
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
