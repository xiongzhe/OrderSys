//
//  CouponsViewController.m
//  OrderSys
//
//  Created by Macx on 15/8/6.
//  Copyright (c) 2015年 北京星辰万合. All rights reserved.
//

#import "CouponsViewController.h"
#import "CouponsCell.h"
#import "EditCouponsViewController.h"
#import "CouponsInfo.h"
#import "DishTypeInfo.h"
#import "CommonUtil.h"
#import "WHInterfaceUtil.h"
#import "UIViewController+HUD.h"
#import "CouponsTypeListObj.h"

/**
 * 优惠券管理首页
 **/
@interface CouponsViewController ()<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, retain) NSMutableArray *dataList;
@property (nonatomic, retain) UITableView *myTableView;

@end

@implementation CouponsViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        //设置导航栏
        self.title = @"优惠券管理";
        UIColor *color = [UIColor whiteColor];
        NSDictionary * dict=[NSDictionary dictionaryWithObject:color forKey:UITextAttributeTextColor];
        [UINavigationBar appearance] .titleTextAttributes = dict;
        //设置导航栏返回按钮
        UIBarButtonItem *backItem = [[UIBarButtonItem alloc] init];
        backItem.title = @"返回";
        self.navigationItem.backBarButtonItem = backItem;
        
        //导航栏右侧刷新按钮
        UIButton *createButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 60, NAV_HEIGHT)];
        [createButton setTitle:@"创建优惠券" forState:UIControlStateNormal];
        createButton.titleLabel.textColor = [UIColor whiteColor];
        createButton.backgroundColor = [UIColor clearColor];
        createButton.titleLabel.font = [UIFont boldSystemFontOfSize:12];
        [createButton addTarget:self action:@selector(clickCreate:) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:createButton];
        self.navigationItem.rightBarButtonItem = rightItem;
        
        //列表
        UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT) style:UITableViewStylePlain];
        // 设置tableView的数据源
        tableView.dataSource = self;
        // 设置tableView的委托
        tableView.delegate = self;
        // 设置tableView的背景图
        tableView.backgroundColor = [UIColor whiteColor];
        // 设置tableview分割线不显示
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        self.myTableView = tableView;
        [self.view addSubview:tableView];
        
        self.dataList = [NSMutableArray arrayWithCapacity:0];
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



//创建并设置每行显示的内容
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellWithIdentifier = @"Cell";
    CouponsCell *cell = [tableView dequeueReusableCellWithIdentifier:CellWithIdentifier];
    NSUInteger row = [indexPath row];
    CouponsInfo *info = [self.dataList objectAtIndex:row];
    //if (cell == nil) { //高度不一致，不能复用
        cell = [[CouponsCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:CellWithIdentifier withCellHeight:([self getHeight:info.dishTypeStr] + 75)];
    //}
    cell.dishesLabel.text = [NSString stringWithFormat:@"%@%@", info.dishTypeStr, @"\n\n"];
    if ([info.PromotionType isEqualToString:@"满减"]) {
        cell.nameLabel.text = info.PromotionType;
        cell.infoLabel.text = [NSString stringWithFormat:@"满%0.1f元减%0.1f元", info.LowTrigger, info.HighTrigger];
    } else if ([info.PromotionType isEqualToString:@"满折"]) {
        cell.nameLabel.text = info.PromotionType;
        cell.infoLabel.text = [NSString stringWithFormat:@"满%0.1f元打%d折", info.LowTrigger, info.DiscountRate];
    } else if ([info.PromotionType isEqualToString:@"无条件扣减"]) {
        cell.nameLabel.text = @"扣减";
        cell.infoLabel.text = [NSString stringWithFormat:@"扣减%0.1f元", info.DiscountAmount];
    } else if ([info.PromotionType isEqualToString:@"无条件打折"]) {
        cell.nameLabel.text = @"打折";
        cell.infoLabel.text = [NSString stringWithFormat:@"打%d折", info.DiscountRate];
    } else if ([info.PromotionType isEqualToString:@"买赠"]) {
        cell.nameLabel.text = info.PromotionType;
        cell.infoLabel.text = [NSString stringWithFormat:@"买%f份%@赠%d份%@", info.LowTrigger, info.BuyFoodName, info.PresentCount, info.PresentFoodName];
    } else if ([info.PromotionType isEqualToString:@"满赠"]) {
        cell.nameLabel.text = info.PromotionType;
        cell.infoLabel.text = [NSString stringWithFormat:@"满%0.1f元赠%@%d份", info.LowTrigger, info.PresentFoodName,info.PresentCount];
    }  else if ([info.PromotionType isEqualToString:@"无条件赠送"]) {
        cell.nameLabel.text = @"赠送";
        cell.infoLabel.text = [NSString stringWithFormat:@"赠%d份%@", info.PresentCount, info.PresentFoodName];
    }
    return cell;
}

//内容分段
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

//cell高度
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSUInteger row = [indexPath row];
    CouponsInfo *info = [self.dataList objectAtIndex:row];
    return ([self getHeight:info.dishTypeStr] + 75);
}

//每个cell中显示多少行
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [_dataList count];
}

//列表点击事件
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    EditCouponsViewController *editCoupons = [[EditCouponsViewController alloc] initWithType:1 withCouponsInfo:[_dataList objectAtIndex:indexPath.row]];
    [self.navigationController pushViewController:editCoupons animated:YES];
    //让点击背景色消失
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}



//获取字体展示高度
-(CGFloat)getHeight:(NSString *) content{
    CGFloat cellWidth;
    if (WIDTH_RATE >1 && WIDTH_RATE < 1.5) {
        cellWidth = 375.0;
    }else if(WIDTH_RATE>1.5){
        cellWidth = 621.0;
    }else if(WIDTH_RATE ==1){
        cellWidth = 320.0;
    }else{
        cellWidth = 320.0;
    }
    return [CommonUtil getHeight:content withWidth:cellWidth - 50];
}

//获取列表数据
-(void) getData {
    [_dataList removeAllObjects];
    dispatch_async(dispatch_queue_create("getclass", DISPATCH_QUEUE_CONCURRENT), ^(){
        NSString *param = [NSString stringWithFormat:@"%@,%@,%@",
                           [WHInterfaceUtil intToJsonString:@"type" withValue:0],
                           [WHInterfaceUtil intToJsonString:@"PageIndex" withValue:-1],
                           [WHInterfaceUtil intToJsonString:@"PageRecordCount" withValue:1000]];
        NSDictionary *dics = [WHInterfaceUtil noLoginWithUrl:@"AboutPromotion.asmx" urlValue:@"http://service.xingchen.com/getPromotionList" withParams:param];
        if (dics!=nil) {
            NSDictionary *Items = [dics objectForKey:@"Items"];
            CouponsInfo *info;
            NSMutableArray *a = [[NSMutableArray alloc] initWithCapacity:0];
            for (NSDictionary *key in Items) {
                info = [[CouponsInfo alloc] init];
                 [a addObject:[key objectForKey:@"PromotionType"]];
                NSString *PromotionType = [CouponsTypeListObj getTypeById:[key objectForKey:@"PromotionType"]];
                if (PromotionType == nil) {
                    continue;
                } else {
                    info.PromotionType = PromotionType;
                }
                info.PromotionId = [[key objectForKey:@"PromotionId"] integerValue];
                info.HighTrigger = [[key objectForKey:@"HighTrigger"] integerValue]/100.0f;
                info.LowTrigger = [[key objectForKey:@"LowTrigger"] integerValue]/100.0f;
                info.DiscountRate = [[key objectForKey:@"DiscountRate"] integerValue];
                info.DiscountAmount = [[key objectForKey:@"DiscountAmount"] integerValue]/100.0f;
                info.PresentFoodName = [key objectForKey:@"PresentFoodName"];
                info.PresentCount = [[key objectForKey:@"PresentCount"] integerValue];
                NSArray *array = [key objectForKey:@"WithDishTypeNames"];
                info.WithDishTypeNames = array;
                NSMutableString *string = [[NSMutableString alloc] init];
                for (int i=0; i<[array count]; i++) {
                    [string appendFormat:@"%@", [array objectAtIndex:i]];
                    if (i != [array count]) {
                        [string appendString:@"  "];
                    }
                }
                info.dishTypeStr = string;
                [_dataList addObject:info];
            }
            NSLog(@"22");
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.myTableView reloadData];
            });
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [CommonUtil showAlert:@"无优惠券记录"];
            });
        }
    });
}


//创建优惠券事件
-(IBAction)clickCreate:(id)sender {
    EditCouponsViewController *editCoupons = [[EditCouponsViewController alloc] initWithType:0 withCouponsInfo:nil];
    [self.navigationController pushViewController:editCoupons animated:YES];
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
