//
//  DishesListViewController.m
//  OrderSys
//
//  Created by Macx on 15/8/12.
//  Copyright (c) 2015年 北京星辰万合. All rights reserved.
//

#import "DishesListViewController.h"
#import "DishesListTypeCell.h"
#import "DishesListTypeInfo.h"
#import "DishesListInfo.h"
#import "DishesListCell.h"
#import "DishSelectedViewController.h"
#import "UIViewController+HUD.h"
#import "WHInterfaceUtil.h"
#import "CommonUtil.h"
#import "BarNumInfo.h"

#define BOTTOM_HEIGHT IS_IPHONE && SCREEN_MAX_LENGTH >= 568.0 ? 80 : 60

/**
 * 顾客点餐列表
 **/
@interface DishesListViewController ()<UITableViewDataSource,UITableViewDelegate>

@property(nonatomic,retain) UITableView *typeTableView;//菜品类型列表
@property(nonatomic,retain) UITableView *dishTableView;//菜品列表

@property(nonatomic,retain) NSMutableArray *dataList;//所有菜品列表信息

@property(nonatomic,retain) NSMutableArray *typeList;//菜品类型列表
@property(nonatomic,retain) NSMutableDictionary *typeDic;
@property(nonatomic,retain) NSMutableArray *dataArray;//当前菜单类型中的所有菜品列表

@property(nonatomic,assign) NSInteger curTypeRow;//当前菜单类型

@property(nonatomic,retain) UILabel *totalLabel;//总价
@property(nonatomic,retain) UIButton *selectButton;//选好按钮
@property(nonatomic,assign) CGFloat total;//总价
@property(nonatomic,assign) NSInteger orderId;//订单id

@property(nonatomic,retain) NSMutableArray *selectList;//选中的菜品列表
@property(nonatomic,retain) NSMutableArray *preSelectList;//结账页面跳转传入的选中的菜品列表

@end

@implementation DishesListViewController

- (instancetype)initWithBarNum:(BarNumInfo *) barNumInfo withSelectedList:(NSMutableArray *) preSelectList withOrderId:(NSInteger) orderId
{
    self = [super init];
    if (self) {
        
        self.preSelectList = preSelectList;
        self.barNumInfo = barNumInfo;
        _curTypeRow = 0;
        _total = 0;
        _orderId = orderId;
        
        self.title = @"顾客点餐";
        //设置导航栏返回按钮
        UIBarButtonItem *backItem = [[UIBarButtonItem alloc] init];
        backItem.title = @"返回";
        self.navigationItem.backBarButtonItem = backItem;
        
        //类型列表
        UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH/3, SCREEN_HEIGHT - ROW_HEIGHT) style:UITableViewStylePlain];
        tableView.dataSource = self;
        tableView.delegate = self;
        tableView.backgroundColor = RGBColorWithoutAlpha(226, 229, 228);
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        self.typeTableView = tableView;
        [self.view addSubview:tableView];
        
        //菜品列表
        UITableView *tableView2 = [[UITableView alloc] initWithFrame:CGRectMake(tableView.frame.origin.x + tableView.frame.size.width, STATU_BAR_HEIGHT + NAV_HEIGHT, SCREEN_WIDTH * 2/3, SCREEN_HEIGHT - ROW_HEIGHT - STATU_BAR_HEIGHT - NAV_HEIGHT) style:UITableViewStylePlain];
        tableView2.dataSource = self;
        tableView2.delegate = self;
        tableView2.backgroundColor = [UIColor whiteColor];
        tableView2.separatorStyle = UITableViewCellSeparatorStyleNone;
        self.dishTableView = tableView2;
        [self.view addSubview:tableView2];
        
        //总价视图
        UIView *totalView = [[UIView alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT - ROW_HEIGHT, SCREEN_WIDTH, ROW_HEIGHT)];
        totalView.backgroundColor = RGBColorWithoutAlpha(221, 63, 60);
        [self.view addSubview:totalView];
        
        //总价
        _totalLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, totalView.frame.size.width/2, totalView.frame.size.height)];
        _totalLabel.font = [UIFont boldSystemFontOfSize:16.0];
        _totalLabel.text = @"共计￥0元";
        _totalLabel.textColor = [UIColor whiteColor];
        [totalView addSubview:_totalLabel];
        
        //选好按钮
        _selectButton = [[UIButton alloc] initWithFrame:CGRectMake(totalView.frame.size.width - 60 - 20, 5, 60, totalView.frame.size.height - 10)];
        [_selectButton setTitle:@"选好了" forState:UIControlStateNormal];
        [_selectButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        _selectButton.backgroundColor = [UIColor whiteColor];
        _selectButton.layer.cornerRadius = 2;
        [_selectButton addTarget:self action:@selector(clickSelect:) forControlEvents:UIControlEventTouchUpInside];
        [totalView addSubview:_selectButton];
        
        [self.view addSubview:totalView];
        
        //[self getData];
        [self getDishesData];
        
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
    if (tableView == _typeTableView) { //类型列表
        static NSString *CellWithIdentifier = @"TypeCell";
        DishesListTypeCell *cell = [tableView dequeueReusableCellWithIdentifier:CellWithIdentifier];
        NSUInteger row = [indexPath row];
        if (cell == nil) {
            cell = [[DishesListTypeCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:CellWithIdentifier withCellHeight:44];
        }
        DishesListTypeInfo *info = [_typeList objectAtIndex:row];
        cell.titleLabel.text = info.name;
        if (info.num > 0) {
            [cell.numLabel setHidden:NO];
            cell.numLabel.text = [NSString stringWithFormat:@"%d", (int)info.num];
        } else {
            [cell.numLabel setHidden:YES];
        }
        if (info.isSelect == 1) {
            cell.contentView.backgroundColor  = [UIColor whiteColor];
        } else {
            cell.contentView.backgroundColor = RGBColorWithoutAlpha(226, 229, 228);
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    } else { //菜单列表
        static NSString *CellWithIdentifier = @"DishCell";
        DishesListCell *cell = [tableView dequeueReusableCellWithIdentifier:CellWithIdentifier];
        NSUInteger row = [indexPath row];
        if (cell == nil) {
            cell = [[DishesListCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:CellWithIdentifier withCellHeight:44 * 7/4];
        }
        DishesListInfo *info = [_dataArray objectAtIndex:row];
        if (info.isOver == 1) { //是否售空
            [cell.overLabel setHidden:NO];
            cell.priceLabel.textColor = RGBColorWithoutAlpha(100, 100, 100);
        } else {
            [cell.overLabel setHidden:YES];
            cell.priceLabel.textColor = [UIColor redColor];
        }
        if (info.isCoupons == 1) { //优惠券
            [cell.couponsButton setHidden:NO];
        } else {
            [cell.couponsButton setHidden:YES];
        }
        [cell.image setImageWithPath:info.image];
        cell.nameLabel.text = info.name;
        cell.priceLabel.text = [NSString stringWithFormat:@"￥%@", info.price];
        cell.plusButton.tag = row;
        cell.busButton.tag = row;
        [cell.plusButton addTarget:self action:@selector(clickAdd:) forControlEvents:UIControlEventTouchUpInside];
        [cell.busButton addTarget:self action:@selector(clickBus:) forControlEvents:UIControlEventTouchUpInside];
        if (info.num > 0) {
            [cell.busButton setHidden:NO];
            [cell.numLabel setHidden:NO];
            cell.numLabel.text = [NSString stringWithFormat:@"%d", (int)info.num];
        } else {
            [cell.busButton setHidden:YES];
            [cell.numLabel setHidden:YES];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
}


//cell高度
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == _typeTableView) { //类型列表
        return 44;
    } else { //菜单列表
        return 44 * 7/4;
    }
}

//每个cell中显示多少行
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (tableView == _typeTableView) { //类型列表
        return [_typeList count];
    } else { //菜单列表
        return [_dataArray count];
    }
}

//列表点击事件
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSInteger row = indexPath.row;
    if (tableView == _typeTableView) { //类型列表
        if (_curTypeRow != row) {
            //菜单类型列表重载
            DishesListTypeInfo *info = [_typeList objectAtIndex:row];
            info.isSelect = 1;
            DishesListTypeInfo *preInfo = [_typeList objectAtIndex:_curTypeRow];
            preInfo.isSelect = 0;
            _curTypeRow = row;
            [_typeTableView reloadData];
            
            //菜单列表重载
            [self getDataArrayBySection:row];
            [_dishTableView reloadData];
        }
    } else { //菜单列表
        
    }
}


//添加
- (IBAction)clickAdd:(id)sender{
    UIButton *button = (UIButton *) sender;
    NSInteger index = button.tag;
    
    //重载菜单列表
    DishesListInfo *info = [_dataArray objectAtIndex:index];
    info.num += 1;
    [_dishTableView reloadData];
    //更新总价
    _total += [info.price floatValue];
    [self updateSelectView];
    //添加进选中列表
    if ([_selectList count] == 0) {
        [_selectList addObject:info];
    } else {
        DishesListInfo *dishInfo;
        BOOL isExistInfo = NO;//是否存在该菜品在选中列表中
        for (int i=0; i<[_selectList count]; i++) {
            dishInfo = [_selectList objectAtIndex:i];
            if (info.dishId == dishInfo.dishId) {
                isExistInfo = YES;
                break;
            } else {
                isExistInfo = NO;
            }
        }
        if (!isExistInfo) { //不存在则存进选中列表中
            [_selectList addObject:info];
        }
    }
    //重载类型列表
    DishesListTypeInfo *typeInfo;
    for (int i = 0 ; i < [_typeList count]; i ++) {
        typeInfo = [_typeList objectAtIndex:i];
        if ([typeInfo.name isEqualToString:info.typeName]) { //类型相同则修改对应的点餐份数
            typeInfo.num += 1;
        }
    }
    [_typeTableView reloadData];
}

//删除
- (IBAction)clickBus:(id)sender{
    UIButton *button = (UIButton *) sender;
    NSInteger index = button.tag;
    
    //重载菜单列表
    DishesListInfo *info = [_dataArray objectAtIndex:index];
    info.num -= 1;
    [_dishTableView reloadData];
    //更新总价
    _total -= [info.price floatValue];
    [self updateSelectView];
    //从选中列表中删除
    DishesListInfo *dishInfo;
    for (int i=0; i<[_selectList count]; i++) {
        dishInfo = [_selectList objectAtIndex:i];
        if (info.dishId == dishInfo.dishId && info.num == 0) {
            [_selectList removeObject:dishInfo];
        }
    }
    //重载类型列表
    DishesListTypeInfo *typeInfo;
    for (int i = 0 ; i < [_typeList count]; i ++) {
        typeInfo = [_typeList objectAtIndex:i];
        if ([typeInfo.name isEqualToString:info.typeName]) { //类型相同则修改对应的点餐份数
            typeInfo.num -= 1;
        }
    }
    [_typeTableView reloadData];
}



//选好了事件监听
-(IBAction)clickSelect:(id)sender {
    NSLog(@"选好");
    DishSelectedViewController *dishSelected = [[DishSelectedViewController alloc] initWithSelectedDishes:_selectList withTotal:_total withBarNum:_barNumInfo withOrderId:_orderId];
    [self.navigationController pushViewController:dishSelected animated:YES];
}


//获取菜单列表
-(void)getDishesData {
    
    [self showHudInView:self.view hint:@"正在加载"];
    self.selectList = [NSMutableArray arrayWithCapacity:0];
    self.dataList = [NSMutableArray arrayWithCapacity:0];
    self.typeList = [NSMutableArray arrayWithCapacity:0];
    self.typeDic = [[NSMutableDictionary alloc] initWithCapacity:1];
    
    dispatch_async(dispatch_queue_create("getclass", DISPATCH_QUEUE_CONCURRENT), ^(){
        NSString *param =[NSString stringWithFormat:@"%@", [WHInterfaceUtil longToJsonString:@"DeskNumber" withValue:_barNumInfo.barNum]];
        NSDictionary *dics = [WHInterfaceUtil noLoginWithUrl:@"AboutDishs.asmx" urlValue:@"http://service.xingchen.com/getDishTypeList" withParams:param];
        if (dics!=nil) {
            
            for (NSDictionary *key in dics) {
                NSMutableArray *arrayList = [NSMutableArray arrayWithCapacity:0];
                //类型列表
                DishesListTypeInfo *typeInfo = [[DishesListTypeInfo alloc] init];
                NSDictionary *dishes = [key objectForKey:@"Dishes"];
                typeInfo.typeId = [[key objectForKey:@"TypeId"] integerValue];
                typeInfo.name = [key objectForKey:@"TypeName"];
                typeInfo.num = 0;
                typeInfo.isSelect = 0;
                [_typeList addObject:typeInfo];
                
                //菜品列表
                for (NSDictionary *dish in dishes) {
                    DishesListInfo *info = [[DishesListInfo alloc] init];
                    info.typeId = [[dish objectForKey:@"TypeId"] integerValue];;
                    info.typeName = [dish objectForKey:@"TypeName"];;
                    info.price = [dish objectForKey:@"DishPrice"];
                    info.name = [dish objectForKey:@"DishName"];
                    info.image = [dish objectForKey:@"DishPic"];
                    info.dishId = [[dish objectForKey:@"DishId"] integerValue];
                    info.num = 0;
                    info.isCoupons = 0;
                    info.isOver = 0;
                    [arrayList addObject:info];
                }
                [_typeDic setObject:arrayList forKey:typeInfo.name];
            }
            
            //默认选中第一个菜品类型
            DishesListTypeInfo *typeInfo = [_typeList objectAtIndex:0];
            typeInfo.isSelect = 1;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self hideHud];
                
                [self getDataArrayBySection:_curTypeRow];
                [_dishTableView reloadData];
                [_typeTableView reloadData];
                [self updateSelectView];
            });
            
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self hideHud];
                [CommonUtil showAlert:@"获取数据失败"];
            });
        }
    });
}

//更新选中视图状态
-(void) updateSelectView{
    _totalLabel.text = [NSString stringWithFormat:@"共计￥%0.2f元", _total];
    if (_total > 0) {
        _selectButton.userInteractionEnabled = YES;
        [_selectButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        _selectButton.backgroundColor = [UIColor whiteColor];
    } else {
        _selectButton.userInteractionEnabled = NO;
        [_selectButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _selectButton.backgroundColor = RGBColorWithoutAlpha(200, 200, 200);
    }
}


//获取每个section中的列表
-(void)getDataArrayBySection:(NSInteger)section{
    DishesListTypeInfo *info = [_typeList objectAtIndex:section];
    _dataArray = [_typeDic objectForKey:info.name];
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
