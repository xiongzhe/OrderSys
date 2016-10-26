//
//  HisOrderViewController.m
//  OrderSys
//
//  Created by Macx on 15/8/18.
//  Copyright (c) 2015年 北京星辰万合. All rights reserved.
//

#import "HisOrderViewController.h"
#import "HisOrderCell.h"
#import "HisOrderInfo.h"
#import "OrderDetailViewController.h"
#import "CommonUtil.h"
#import "WHInterfaceUtil.h"
#import "UIViewController+HUD.h"

/**
 * 收银管理历史订单页
 **/
@interface HisOrderViewController ()<UITableViewDataSource,UITableViewDelegate>

@property(nonatomic,retain) UITableView *myTableView;//订单列表
@property(nonatomic,retain) NSMutableArray *dataList;//订单数据列表

@end

@implementation HisOrderViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, STATU_BAR_HEIGHT + NAV_HEIGHT, SCREEN_WIDTH, 1)];
        [self.view addSubview:view];
        
        //菜单列表
        _dataList = [[NSMutableArray alloc] initWithCapacity:0];
        UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, view.frame.origin.y + view.frame.size.height, SCREEN_WIDTH, SCREEN_HEIGHT - STATU_BAR_HEIGHT - NAV_HEIGHT - TABBAR_HEIGHT - 1) style:UITableViewStylePlain];
        tableView.dataSource = self;
        tableView.delegate = self;
        tableView.backgroundColor = RGBColorWithoutAlpha(226, 229, 228);
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        self.myTableView = tableView;
        [self.view addSubview:tableView];
        
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


//内容分段
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


//创建并设置每行显示的内容
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellWithIdentifier = @"DishCell";
    HisOrderCell *cell = [tableView dequeueReusableCellWithIdentifier:CellWithIdentifier];
    NSUInteger row = [indexPath row];
    if (cell == nil) {
        cell = [[HisOrderCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:CellWithIdentifier withCellHeight:80];
    }
    HisOrderInfo *info = [_dataList objectAtIndex:row];
    cell.orderLabel.text = info.orderNum;
    cell.timeLabel.text = info.orderTime;
    cell.numLabel.text = [NSString stringWithFormat:@"%d人", (int)info.num];
    cell.totalLabel.text = [NSString stringWithFormat:@"￥%0.1f", info.total];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}


//cell高度
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80;
}

//每个cell中显示多少行
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [_dataList count];
}

//列表点击事件
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    HisOrderInfo *info = [_dataList objectAtIndex:indexPath.row];
    OrderDetailViewController *orderDetail = [[OrderDetailViewController alloc] initWithHisOrderInfo:info];
    [self.navigationController pushViewController:orderDetail animated:YES];
}


//获取数据
-(void)getData{
    dispatch_async(dispatch_queue_create("getclass", DISPATCH_QUEUE_CONCURRENT), ^(){
        NSString *param =[NSString stringWithFormat:@"%@,%@",
                          [WHInterfaceUtil intToJsonString:@"queryType" withValue:-3],
                          [WHInterfaceUtil boolToJsonString:@"isWeixin" withValue:NO]];
        NSDictionary *dics = [WHInterfaceUtil noLoginWithUrl:@"AboutBooking.asmx" urlValue:@"http://service.xingchen.com/queryHistoryBill" withParams:param];
        if (dics!=nil) {
            HisOrderInfo *info;
            for (NSDictionary *key in dics) {
                info = [[HisOrderInfo alloc] init];
                info.orderId = [[key objectForKey:@"BillId"] integerValue];
                info.orderNum = [NSString stringWithFormat:@"%ld", [[key objectForKey:@"SerialNumber"] longValue]];
                info.orderTime = [key objectForKey:@"CloseOffTime"];
                info.num = [[key objectForKey:@"Peoples"] integerValue];
                info.total = [[key objectForKey:@"ReceivableDiscount"] floatValue]/100.0f;
                [_dataList addObject:info];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [_myTableView reloadData];
            });
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSLog(@"获取失败");
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
