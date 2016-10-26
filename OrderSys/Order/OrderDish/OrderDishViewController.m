//
//  OrderDishViewController.m
//  OrderSys
//
//  Created by Macx on 15/8/12.
//  Copyright (c) 2015年 北京星辰万合. All rights reserved.
//

#import "OrderDishViewController.h"
#import "OrderDishCell.h"
#import "OrderDishInfo.h"
#import "UploadDishViewController.h"
#import "PopListView.h"
#import "UIViewController+HUD.h"
#import "WHInterfaceUtil.h"
#import "DishesListTypeInfo.h"
#import "CommonUtil.h"
#import "DishTypeListObj.h"


/**
 * 菜品管理
 **/
@interface OrderDishViewController ()<UITableViewDataSource,UITableViewDelegate,PopClickDelegate>

@property(nonatomic,retain) UITableView *myTableView;//菜品类型列表
@property(nonatomic,retain) NSMutableArray *typeList;//菜品类型列表
@property(nonatomic,retain) NSMutableArray *typeIdList;//菜品类型id列表
@property(nonatomic,retain) NSMutableDictionary *typeDic;
@property(nonatomic,retain) NSMutableArray *dataArray;//当前菜单类型中的所有菜品列表

@property(nonatomic,retain) PopListView *typesView; //类型选择布局
@property(nonatomic,retain) UITextField *typeText; //收入类型
@property(nonatomic,retain) UIView *typeView;

@property(nonatomic,assign) NSInteger dishType; //菜品类型
//@property(nonatomic,retain) NSArray *dishTypes; //菜品类型列表
@property(nonatomic,assign) NSInteger curTypeRow;//当前菜单类型

@end

@implementation OrderDishViewController

@synthesize delegate;

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        _curTypeRow = 0;
        
//        _dishTypes = [[NSArray alloc] initWithObjects:@"类型1",@"类型2",@"类型3",@"类型4", nil];
        
        //类型选择
        _typeView = [[UIView alloc] initWithFrame:CGRectMake(0, STATU_BAR_HEIGHT + NAV_HEIGHT, SCREEN_WIDTH, ROW_HEIGHT)];
        _typeView.backgroundColor = [UIColor whiteColor];
        _typeView.userInteractionEnabled = YES;
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickType:)];
        [_typeView addGestureRecognizer:singleTap];
        
        _typeText = [[UITextField alloc] initWithFrame:CGRectMake(40, 7, SCREEN_WIDTH - 80, ROW_HEIGHT - 14)];
        _typeText.textColor = RGBColorWithoutAlpha(100, 100, 100);
        _typeText.layer.cornerRadius = 2;
        _typeText.backgroundColor = RGBColorWithoutAlpha(226, 229, 228);
        _typeText.userInteractionEnabled = NO;
        
        UIButton *rightButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, _typeText.frame.size.height)];
        [rightButton setImage:[UIImage imageNamed:@"red_array"] forState:UIControlStateNormal];
        _typeText.rightView = rightButton;
        _typeText.rightViewMode = UITextFieldViewModeAlways;
        
        [_typeView addSubview:_typeText];
        [self.view addSubview:_typeView];
        
        
        //菜单列表
        UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, _typeView.frame.origin.y + _typeView.frame.size.height + 10, SCREEN_WIDTH, SCREEN_HEIGHT - ROW_HEIGHT - _typeView.frame.origin.y - _typeView.frame.size.height - 10) style:UITableViewStylePlain];
        tableView.dataSource = self;
        tableView.delegate = self;
        tableView.backgroundColor = RGBColorWithoutAlpha(226, 229, 228);
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        self.myTableView = tableView;
        [self.view addSubview:tableView];
 
    }
    return self;
}

//设置类型布局
- (void) setTypesView {
    //类型选择布局
    _typesView = [[PopListView alloc] initWithFrame:CGRectMake(_typeView.frame.origin.x + _typeText.frame.origin.x + _typeText.frame.size.width/2,_typeView.frame.origin.y + _typeView.frame.size.height + 5, _typeText.frame.size.width/2, 0.5+(ROW_HEIGHT + 0.5) * [_typeList count]) withShowView:(UILabel *)_typeText withArray:_typeList withBackgroundColor:RGBColor(60, 60, 60, 0.8)];
    [_typesView setDelegate:self];
    [_typesView setHidden:YES];
    [self.view addSubview:_typesView];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //设置导航栏返回按钮为白色
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    //设置背景颜色
    self.view.backgroundColor = RGBColorWithoutAlpha(226, 229, 228);
}


//点击类型按钮事件
-(IBAction)clickType:(id)sender{
    NSLog(@"选择类型");
    if (_typesView.isHidden) {
        [_typesView setHidden:NO];
    } else{
        [_typesView setHidden:YES];
    }
}


//内容分段
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


//创建并设置每行显示的内容
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellWithIdentifier = @"DishCell";
    OrderDishCell *cell = [tableView dequeueReusableCellWithIdentifier:CellWithIdentifier];
    int row = [indexPath row];
    if (cell == nil) {
        cell = [[OrderDishCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:CellWithIdentifier withCellHeight:80];
    }
    OrderDishInfo *info = [_dataArray objectAtIndex:row];
    [cell.image setImageWithPath:info.DishPic];
    cell.nameLabel.text = info.DishName;
    cell.priceLabel.text = [NSString stringWithFormat:@"￥%@", info.DishPrice];
    if (info.DishStatus) {
        [cell.shelfButton setImage:[UIImage imageNamed:@"select_yes"] forState:(UIControlStateNormal)];
    } else {
        [cell.shelfButton setImage:[UIImage imageNamed:@"select_no"] forState:(UIControlStateNormal)];
    }
    cell.editButton.tag = row;
    [cell.editButton addTarget:self action:@selector(clickDishEdit:) forControlEvents:UIControlEventTouchUpInside];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}


//cell高度
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80;
}

//每个cell中显示多少行
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [_dataArray count];
}

//列表点击事件
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSInteger row = indexPath.row;
    OrderDishInfo *orderDishInfo = [_dataArray objectAtIndex:row];
    
    //获取菜品详情代理方法
    [self.delegate getOrderDishInfo:orderDishInfo];
}


//编辑菜单
-(IBAction)clickDishEdit:(id)sender {
    UIButton *button = (UIButton *) sender;
    NSInteger row = button.tag;
    OrderDishInfo *orderDishInfo = [_dataArray objectAtIndex:(int)row];
    UploadDishViewController *uploadDish = [[UploadDishViewController alloc] initWithOrderDishInfo:orderDishInfo];
    [self.navigationController pushViewController:uploadDish animated:YES];
}

//获取菜单列表
-(void)getDishesData {
    if (_typeList == nil || [_typeList count] == 0) {
        [self showHudInView:self.view hint:@"正在加载"];
        self.typeList = [NSMutableArray arrayWithCapacity:0];
        self.typeIdList = [NSMutableArray arrayWithCapacity:0];
        self.typeDic = [[NSMutableDictionary alloc] initWithCapacity:1];
        
        dispatch_async(dispatch_queue_create("getclass", DISPATCH_QUEUE_CONCURRENT), ^(){
            NSDictionary *dics = [WHInterfaceUtil noLoginWithUrl:@"AboutDishs.asmx" urlValue:@"http://service.xingchen.com/getDishTypeList" withParams:nil];
            if (dics!=nil) {
                
                for (NSDictionary *key in dics) {
                    NSMutableArray *arrayList = [NSMutableArray arrayWithCapacity:0];
                    //类型列表
                    NSString *typeName = [key objectForKey:@"TypeName"];
                    NSNumber *typeId = [key objectForKey:@"TypeId"];
                    [_typeList addObject:typeName];
                    [_typeIdList addObject:typeId];
                    
                    //菜品列表
                    NSDictionary *dishes = [key objectForKey:@"Dishes"];
                    for (NSDictionary *dish in dishes) {
                        OrderDishInfo *info = [[OrderDishInfo alloc] init];
                        info.TypeId = [[dish objectForKey:@"TypeId"] integerValue];;
                        info.TypeName = [dish objectForKey:@"TypeName"];;
                        info.DishPrice = [dish objectForKey:@"DishPrice"];
                        info.DishName = [dish objectForKey:@"DishName"];
                        info.DishPic = [dish objectForKey:@"DishPic"];
                        info.DishId = [[dish objectForKey:@"DishId"] integerValue];
                        info.DishCount = [[dish objectForKey:@"DishCount"] integerValue];
                        info.DishDesc = [dish objectForKey:@"DishDesc"];
                        info.DishStatus = [[dish objectForKey:@"DishStatus"] integerValue];
                        [arrayList addObject:info];
                    }
                    [_typeDic setObject:arrayList forKey:typeName];
                }
                [DishTypeListObj setTypeList:_typeList];
                [DishTypeListObj setTypeIdList:_typeIdList];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self hideHud];
                    
                    _typeText.text = [_typeList objectAtIndex:0];
                    [self setTypesView];
                    [self getDataArrayBySection:_curTypeRow];
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
}

//获取每个section中的列表
-(void)getDataArrayBySection:(NSInteger)section{
    NSString *typeName = [_typeList objectAtIndex:section];
    _dataArray = [_typeDic objectForKey:typeName];
}


#pragma PopListView
-(void) clickItem:(NSInteger)index {
    [self getDataArrayBySection:_typesView.type];
    [_myTableView reloadData];
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
