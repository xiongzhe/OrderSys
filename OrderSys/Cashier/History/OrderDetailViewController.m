//
//  orderDetailViewController.m
//  OrderSys
//
//  Created by Macx on 15/8/18.
//  Copyright (c) 2015年 北京星辰万合. All rights reserved.
//

#import "OrderDetailViewController.h"
#import "HisOrderInfo.h"
#import "DishCell.h"
#import "DishInfo.h"
#import "CommonUtil.h"
#import "WHInterfaceUtil.h"
#import "UIViewController+HUD.h"

/**
 * 收银管理历史订单详情页
 **/
@interface OrderDetailViewController ()<UIScrollViewDelegate,UITableViewDataSource,UITableViewDelegate>

@property(nonatomic,retain) NSMutableArray *dataList;
@property(nonatomic,retain) UITableView *myTableView;
@property(nonatomic,retain) UIScrollView *scrollView;
@property(nonatomic,retain) UIView *headView;

@property(nonatomic, retain) HisOrderInfo *hisOrderInfo;
@property(nonatomic, assign) NSInteger couponsMoney;//优惠金额

@end

@implementation OrderDetailViewController

- (instancetype)initWithHisOrderInfo:(HisOrderInfo *) hisOrderInfo
{
    self = [super init];
    if (self) {
        
        _hisOrderInfo = hisOrderInfo;
        
        self.title = @"历史订单";
        //设置导航栏返回按钮
        UIBarButtonItem *backItem = [[UIBarButtonItem alloc] init];
        backItem.title = @"返回";
        self.navigationItem.backBarButtonItem = backItem;
        //导航栏右侧搜索按钮
//        UIButton *searchButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, NAV_HEIGHT)];
//        [searchButton setImage:[UIImage imageNamed:@"select_yes"] forState:UIControlStateNormal];
//        searchButton.titleLabel.textColor = [UIColor whiteColor];
//        searchButton.backgroundColor = [UIColor clearColor];
//        searchButton.titleLabel.font = [UIFont boldSystemFontOfSize:14];
//        [searchButton addTarget:self action:@selector(clickSearch:) forControlEvents:UIControlEventTouchUpInside];
//        UIBarButtonItem *searchItem = [[UIBarButtonItem alloc] initWithCustomView:searchButton];
//        self.navigationItem.rightBarButtonItem = searchItem;
        
        
        //滚动视图
        _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, NAV_HEIGHT + STATU_BAR_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT)];
        
        //订单编号
        UIView *orderNumView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, ROW_HEIGHT - 10)];
        
        UILabel *orderNumLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, 80, orderNumView.frame.size.height)];
        orderNumLabel.text = @"订单编号:";
        orderNumLabel.textColor = RGBColorWithoutAlpha(100, 100, 100);
        orderNumLabel.font = [UIFont systemFontOfSize:15];
        orderNumLabel.backgroundColor = [UIColor clearColor];
        
        UILabel *orderNumText = [[UILabel alloc] initWithFrame:CGRectMake(orderNumLabel.frame.origin.x + orderNumLabel.frame.size.width, 0, orderNumView.frame.size.width - orderNumLabel.frame.origin.x - orderNumLabel.frame.size.width, orderNumLabel.frame.size.height)];
        orderNumText.text = hisOrderInfo.orderNum;
        orderNumText.font = [UIFont systemFontOfSize:15];
        orderNumText.textColor = RGBColorWithoutAlpha(100, 100, 100);
        orderNumText.backgroundColor = [UIColor clearColor];
        
        [orderNumView addSubview:orderNumLabel];
        [orderNumView addSubview:orderNumText];
        
        //订单时间
        UIView *orderTimeView = [[UIView alloc] initWithFrame:CGRectMake(0, orderNumView.frame.origin.y + orderNumView.frame.size.height, SCREEN_WIDTH, ROW_HEIGHT - 10)];
        orderTimeView.layer.borderWidth = 0.5;
        orderTimeView.layer.borderColor = RGBColorWithoutAlpha(200, 200, 200).CGColor;
        
        UILabel *orderTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, 80, orderTimeView.frame.size.height)];
        orderTimeLabel.text = @"订单时间:";
        orderTimeLabel.textColor = RGBColorWithoutAlpha(100, 100, 100);
        orderTimeLabel.font = [UIFont systemFontOfSize:15];
        orderTimeLabel.backgroundColor = [UIColor clearColor];
        
        UILabel *orderTimeText = [[UILabel alloc] initWithFrame:CGRectMake(orderTimeLabel.frame.origin.x + orderTimeLabel.frame.size.width, 0, orderTimeView.frame.size.width - orderTimeLabel.frame.origin.x - orderTimeLabel.frame.size.width, orderTimeLabel.frame.size.height)];
        orderTimeText.text = hisOrderInfo.orderTime;
        orderTimeText.textColor = RGBColorWithoutAlpha(100, 100, 100);
        orderTimeText.font = [UIFont systemFontOfSize:15];
        orderTimeText.backgroundColor = [UIColor clearColor];
        
        [orderTimeView addSubview:orderTimeLabel];
        [orderTimeView addSubview:orderTimeText];
        
        //菜单列表头标识
        _headView = [[UIView alloc] initWithFrame:CGRectMake(0, orderTimeView.frame.origin.y + orderTimeView.frame.size.height, SCREEN_WIDTH, ROW_HEIGHT - 10)];
        
        //菜品名称
        UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, (_headView.frame.size.width - 20) * 1/2, _headView.frame.size.height)];
        nameLabel.backgroundColor = [UIColor clearColor];
        nameLabel.textAlignment = NSTextAlignmentLeft;
        nameLabel.font = [UIFont systemFontOfSize:15.0];
        nameLabel.textColor = RGBColorWithoutAlpha(100, 100, 100);
        nameLabel.text = @"菜品名称";
        [_headView addSubview:nameLabel];
        
        //数量
        UILabel *numLabel = [[UILabel alloc] initWithFrame:CGRectMake(nameLabel.frame.origin.x + nameLabel.frame.size.width, 0, (_headView.frame.size.width - 20)  * 1/4 , _headView.frame.size.height)];
        numLabel.backgroundColor = [UIColor clearColor];
        numLabel.textAlignment = NSTextAlignmentCenter;
        numLabel.font = [UIFont systemFontOfSize:15.0];
        numLabel.textColor = RGBColorWithoutAlpha(100, 100, 100);
        numLabel.text = @"数量";
        [_headView addSubview:numLabel];
        
        //金额
        UILabel *moneyLabel = [[UILabel alloc] initWithFrame:CGRectMake(numLabel.frame.origin.x + numLabel.frame.size.width, 0, (_headView.frame.size.width - 20)  * 1/4, _headView.frame.size.height)];
        moneyLabel.backgroundColor = [UIColor clearColor];
        moneyLabel.textAlignment = NSTextAlignmentCenter;
        moneyLabel.font = [UIFont systemFontOfSize:15.0];
        moneyLabel.textColor = RGBColorWithoutAlpha(100, 100, 100);
        moneyLabel.text = @"金额";
        [_headView addSubview:moneyLabel];
        
        
        //菜单列表
        self.dataList = [NSMutableArray arrayWithCapacity:0];
        UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, _headView.frame.origin.y + _headView.frame.size.height, _scrollView.frame.size.width, 1 * 34) style:UITableViewStylePlain];
        tableView.dataSource = self;
        tableView.delegate = self;
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        tableView.scrollEnabled = NO;
        tableView.userInteractionEnabled = NO;
        self.myTableView = tableView;
        
        
        
        [_scrollView addSubview:orderNumView];
        [_scrollView addSubview:orderTimeView];
        [_scrollView addSubview:_headView];
        [_scrollView addSubview:tableView];
        
        
        [self setupPage:nil];
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
    
    UILabel *spendLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, 80, spendView.frame.size.height)];
    spendLabel.text = @"消费金额:";
    spendLabel.font = [UIFont systemFontOfSize:16];
    spendLabel.backgroundColor = [UIColor clearColor];
    spendLabel.textColor = RGBColorWithoutAlpha(100, 100, 100);
    
    UILabel *spendTf = [[UILabel alloc] initWithFrame:CGRectMake(spendLabel.frame.origin.x + spendLabel.frame.size.width, 8, spendView.frame.size.width - spendLabel.frame.origin.x - spendLabel.frame.size.width - 10 - 35, spendLabel.frame.size.height - 16)];
    spendTf.text = [NSString stringWithFormat:@"%0.1f元", _hisOrderInfo.total];
    spendTf.font = [UIFont systemFontOfSize:16];
    spendTf.backgroundColor = [UIColor clearColor];
    spendTf.textColor = RGBColorWithoutAlpha(100, 100, 100);
    
    [spendView addSubview:spendLabel];
    [spendView addSubview:spendTf];
    
    //优惠信息
    UIView *couponsView = [[UIView alloc] initWithFrame:CGRectMake(0, spendView.frame.origin.y + spendView.frame.size.height, SCREEN_WIDTH, ROW_HEIGHT)];
    
    UILabel *couponsLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, 80, spendView.frame.size.height)];
    couponsLabel.text = @"优惠金额:";
    couponsLabel.font = [UIFont systemFontOfSize:16];
    couponsLabel.backgroundColor = [UIColor clearColor];
    couponsLabel.textColor = RGBColorWithoutAlpha(100, 100, 100);
    
    UILabel *couponsTf = [[UILabel alloc] initWithFrame:CGRectMake(couponsLabel.frame.origin.x + couponsLabel.frame.size.width, 8, couponsView.frame.size.width - couponsLabel.frame.origin.x - couponsLabel.frame.size.width - 10 - 35, couponsLabel.frame.size.height - 16)];
    couponsTf.text = [NSString stringWithFormat:@"%d 元", _couponsMoney];
    couponsTf.font = [UIFont systemFontOfSize:16];
    couponsTf.backgroundColor = [UIColor clearColor];
    couponsTf.textColor = RGBColorWithoutAlpha(100, 100, 100);
    
    [couponsView addSubview:couponsLabel];
    [couponsView addSubview:couponsTf];

    [_scrollView addSubview:spendView];
    [_scrollView addSubview:couponsView];
    [self.view addSubview:_scrollView];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //设置导航栏返回按钮为白色
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    //设置背景颜色
    self.view.backgroundColor = RGBColorWithoutAlpha(226, 229, 228);
}

//点击搜索按钮事件
-(IBAction)clickSearch:(id)sender {
    NSLog(@"搜索事件");
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
    _scrollView.contentSize = CGSizeMake(SCREEN_WIDTH, SCREEN_HEIGHT + 10);
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

//获取数据
-(void)getData{
    [self showHudInView:self.view hint:@"正在加载"];
    dispatch_async(dispatch_queue_create("getclass", DISPATCH_QUEUE_CONCURRENT), ^(){
        NSString *param =[NSString stringWithFormat:@"%@",
                          [WHInterfaceUtil intToJsonString:@"billId" withValue:_hisOrderInfo.orderId]];
        NSDictionary *dics = [WHInterfaceUtil noLoginWithUrl:@"AboutBooking.asmx" urlValue:@"http://service.xingchen.com/getBillDetail" withParams:param];
        if (dics!=nil) {
            //优惠信息
            NSDictionary *BillProfile = [dics objectForKey:@"BillProfile"];
            _couponsMoney = [[BillProfile objectForKey:@"Discount"] integerValue];
            //菜单列表
            NSDictionary *BookDetailList = [dics objectForKey:@"BookDetailList"];
            DishInfo *dishInfo;
            for (NSDictionary *key in BookDetailList) {
                dishInfo = [[DishInfo alloc] init];
                dishInfo.dishName = [key objectForKey:@"DishName"];
                dishInfo.dishMoney = [NSString stringWithFormat:@"%d", [[key objectForKey:@"Amount"] integerValue]];
                dishInfo.dishNum = [[key objectForKey:@"DishCount"] integerValue];
                [_dataList addObject:dishInfo];
            }

            dispatch_async(dispatch_get_main_queue(), ^{
                [self hideHud];
                [_myTableView setFrame:CGRectMake(0, _headView.frame.origin.y + _headView.frame.size.height, _scrollView.frame.size.width, [_dataList count] * 34)];
                [self setView];
                [_myTableView reloadData];
            });
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self hideHud];
                [CommonUtil showAlert:@"获取数据失败"];
            });
        }
    });
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
