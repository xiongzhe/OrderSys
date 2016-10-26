//
//  DishSelectedViewController.m
//  OrderSys
//
//  Created by Macx on 15/8/14.
//  Copyright (c) 2015年 北京星辰万合. All rights reserved.
//

#import "DishSelectedViewController.h"
#import "DishSelectedCell.h"
#import "DishesListInfo.h"
#import "CommonUtil.h"
#import "UIViewController+HUD.h"
#import "WHInterfaceUtil.h"
#import "BarNumInfo.h"
#import "JsonKit.h"

/**
 * 顾客点餐已选列表
 **/
@interface DishSelectedViewController ()<UITableViewDataSource,UITableViewDelegate>

@property(nonatomic,retain) UITableView *myTableView;//菜品类型列表
@property(nonatomic,retain) NSMutableArray *selectList;//选中的菜品列表
@property(nonatomic,assign) CGFloat total;//总价
@property(nonatomic,retain) UILabel *totalLabel;//总价
@property(nonatomic,retain) UIButton *selectButton;//选好按钮
@property(nonatomic,assign) NSInteger orderId; //订单id
@property(nonatomic,assign) Byte *operaterSign;//操作签名

@end

@implementation DishSelectedViewController

- (instancetype)initWithSelectedDishes:(NSMutableArray*) selectList withTotal:(CGFloat) total withBarNum:(BarNumInfo *) barNumInfo withOrderId:(NSInteger) orderId
{
    
    self = [super init];
    if (self) {
        
        int x = arc4random() % 100;
        _operaterSign = [CommonUtil chineseToHex:[NSString stringWithFormat:@"%@%d",@"操作签名",x]];
        _orderId = orderId;
        self.barNumInfo = barNumInfo;
        self.selectList = selectList;
        self.total = total;
        
        self.title = @"顾客点餐";
        //设置导航栏返回按钮
        UIBarButtonItem *backItem = [[UIBarButtonItem alloc] init];
        backItem.title = @"返回";
        self.navigationItem.backBarButtonItem = backItem;
        
        //菜单列表
        UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - ROW_HEIGHT) style:UITableViewStylePlain];
        tableView.dataSource = self;
        tableView.delegate = self;
        tableView.backgroundColor = RGBColorWithoutAlpha(226, 229, 228);
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        self.myTableView = tableView;
        [self.view addSubview:tableView];
        
        //总价视图
        UIView *totalView = [[UIView alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT - ROW_HEIGHT, SCREEN_WIDTH, ROW_HEIGHT)];
        totalView.backgroundColor = RGBColorWithoutAlpha(221, 63, 60);
        [self.view addSubview:totalView];
        
        //总价
        _totalLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, totalView.frame.size.width/2, totalView.frame.size.height)];
        _totalLabel.font = [UIFont boldSystemFontOfSize:16.0];
        _totalLabel.text = [NSString stringWithFormat:@"共计￥%0.2f元", _total];
        _totalLabel.textColor = [UIColor whiteColor];
        [totalView addSubview:_totalLabel];
        
        //选好按钮
        _selectButton = [[UIButton alloc] initWithFrame:CGRectMake(totalView.frame.size.width - 60 - 20, 5, 60, totalView.frame.size.height - 10)];
        [_selectButton setTitle:@"下单" forState:UIControlStateNormal];
        [_selectButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        _selectButton.backgroundColor = [UIColor whiteColor];
        _selectButton.layer.cornerRadius = 2;
        [_selectButton addTarget:self action:@selector(clickSelect:) forControlEvents:UIControlEventTouchUpInside];
        [totalView addSubview:_selectButton];
        
        [self.view addSubview:totalView];
        
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


//内容分段
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


//创建并设置每行显示的内容
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellWithIdentifier = @"DishCell";
    DishSelectedCell *cell = [tableView dequeueReusableCellWithIdentifier:CellWithIdentifier];
    NSUInteger row = [indexPath row];
    if (cell == nil) {
        cell = [[DishSelectedCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:CellWithIdentifier withCellHeight:80];
    }
    DishesListInfo *info = [_selectList objectAtIndex:row];
    [cell.image setImageWithPath:info.image];
    cell.nameLabel.text = info.name;
    cell.priceLabel.text = [NSString stringWithFormat:@"￥%@", info.price];
    cell.numLabel.text = [NSString stringWithFormat:@"*%d", (int)info.num];
    cell.totalLabel.text = [NSString stringWithFormat:@"￥%0.2f", [info.price floatValue] * info.num];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}


//cell高度
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80;
}

//每个cell中显示多少行
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [_selectList count];
}

//列表点击事件
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
   
}

//下单事件
-(IBAction)clickSelect:(id)sender {
    
    [self showHudInView:self.view hint:@"正在加载"];
    
    dispatch_async(dispatch_queue_create("getclass", DISPATCH_QUEUE_CONCURRENT), ^(){
        
        NSString *param = [NSString stringWithFormat:@"%@,%@", [self getOrder],[WHInterfaceUtil byteArrayToJsonString:@"operaterSign" withValue:(char *)_operaterSign withLength:16]];
        NSDictionary *dics = [WHInterfaceUtil noLoginWithUrl:@"AboutBooking.asmx" urlValue:@"http://service.xingchen.com/addOrder" withParams:param];
        if (dics!=nil) {
            NSInteger isSuccess = [[dics objectForKey:@"IsSuccess"] integerValue];
            if (isSuccess == 1) { //下单成功
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self hideHud];
                    [CommonUtil showAlert:@"亲，您已下单成功，后厨正在快马加鞭地给您配菜，可以在我的--我的订单找到本次订单查看上菜情况及结账。"];
                    [self.navigationController popToRootViewControllerAnimated:YES];
                });
            }
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self hideHud];
                [CommonUtil showAlert:@"下单失败"];
            });
        }
    });
}

//获取接口参数
-(NSString *) getOrder {
    NSMutableDictionary *Order = [[NSMutableDictionary alloc] init];
    [Order setObject:@(_orderId) forKey:@"OrderId"];
    [Order setObject:@(_barNumInfo.barNum) forKey:@"TableId"];
    [Order setObject:_barNumInfo.barName forKey:@"TableName"];
    [Order setObject:@0 forKey:@"From"];
    [Order setObject:@8 forKey:@"Persons"];
    NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:0];
    DishesListInfo *info;
    for (int i=0; i<[_selectList count]; i++) {
        info = [_selectList objectAtIndex:i];
        NSMutableDictionary *dishes = [[NSMutableDictionary alloc] initWithCapacity:0];
        [dishes setObject:[NSString stringWithFormat:@"%d", info.dishId] forKey:@"DishId"];
        [dishes setObject:[NSString stringWithFormat:@"%d", info.num] forKey:@"DishCount"];
        [dishes setObject:[NSString stringWithFormat:@"%d", [info.price integerValue]] forKey:@"DishPrice"];
        [dishes setObject:[NSString stringWithFormat:@"%d", [info.price integerValue] * info.num] forKey:@"DishAmount"];
        [array addObject:dishes];
    }
    [Order setObject:array forKey:@"OrderDish"];
    NSString *OrderParam = [NSString stringWithFormat:@"\"Order\":%@", [Order JSONString]];
    return OrderParam;
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
