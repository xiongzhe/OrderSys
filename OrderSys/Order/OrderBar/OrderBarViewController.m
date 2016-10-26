//
//  OrderBarViewController.m
//  OrderSys
//
//  Created by Macx on 15/8/12.
//  Copyright (c) 2015年 北京星辰万合. All rights reserved.
//

#import "OrderBarViewController.h"
#import "BarNumInfo.h"
#import "BarNumCell.h"
#import "DishesListViewController.h"
#import "DishingViewController.h"
#import "CommonUtil.h"
#import "SecretUtil.h"
#import "NotifyClient.h"
#import "AppDelegate.h"
#import "WHInterfaceUtil.h"
#import "UIViewController+HUD.h"
#import "OrderStatusObj.h"

#define NUMBER_ITEMS_ON_LOAD 15
#define COLLECTION_CELL_HEIGHT IS_IPHONE && SCREEN_MAX_LENGTH >= 568.0 ? 60 : 50

/**
 * 台号管理
 **/
@interface OrderBarViewController ()<UITabBarDelegate,UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout>
@property(nonatomic,retain) UIView *divideView;
@property(nonatomic,retain) NSMutableArray *data;
@property(nonatomic, retain) UICollectionView *collectionView;



@end

@implementation OrderBarViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        
        _divideView = [[UIView alloc] initWithFrame:CGRectMake(0, STATU_BAR_HEIGHT + NAV_HEIGHT, SCREEN_WIDTH, 1)];
        _divideView.backgroundColor = [UIColor clearColor];
        [self.view addSubview:_divideView];
        
        [self setupCollectionView];
        
        CGFloat unitWidth = (SCREEN_WIDTH - 40 - 6)/7;
        //注释视图
        UIView *notesView = [[UIView alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT - TABBAR_HEIGHT - 50, SCREEN_WIDTH, 50)];
        notesView.backgroundColor = [UIColor clearColor];
        
        UIImageView *oneImage = [[UIImageView alloc] initWithFrame:CGRectMake(20, 0, unitWidth *5/4, notesView.frame.size.height)];
        [oneImage setImage:[UIImage imageNamed:@"select_yes"]];
        [notesView addSubview:oneImage];
        
        UIImageView *twoImage = [[UIImageView alloc] initWithFrame:CGRectMake(oneImage.frame.origin.x + oneImage.frame.size.width + 2, 0, unitWidth *5/4, notesView.frame.size.height)];
        [twoImage setImage:[UIImage imageNamed:@"select_yes"]];
        [notesView addSubview:twoImage];
        
        UIImageView *threeImage = [[UIImageView alloc] initWithFrame:CGRectMake(twoImage.frame.origin.x + twoImage.frame.size.width + 2, 0, unitWidth *5/2, notesView.frame.size.height)];
        [threeImage setImage:[UIImage imageNamed:@"select_yes"]];
        [notesView addSubview:threeImage];
        
        UIImageView *fourImage = [[UIImageView alloc] initWithFrame:CGRectMake(threeImage.frame.origin.x + threeImage.frame.size.width + 2, 0, unitWidth * 2, notesView.frame.size.height)];
        [fourImage setImage:[UIImage imageNamed:@"select_yes"]];
        [notesView addSubview:fourImage];
        [self.view addSubview:notesView];
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


//创建collectionView
- (void) setupCollectionView {
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    [flowLayout setItemSize:CGSizeMake(COLLECTION_CELL_HEIGHT, COLLECTION_CELL_HEIGHT)];//设置cell的尺寸
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];//设置其布局方向
    flowLayout.sectionInset = UIEdgeInsetsMake(5, 5, 5, 5);//设置其边界
    
    //当你的cell设置大小后，一行多少个cell，由cell的宽度决定
    _collectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(20, _divideView.frame.origin.y + _divideView.frame.size.height + 10, SCREEN_WIDTH - 40, SCREEN_HEIGHT - STATU_BAR_HEIGHT - NAV_HEIGHT - TABBAR_HEIGHT - 50 - 10 * 2) collectionViewLayout:flowLayout];
    _collectionView.dataSource = self;
    _collectionView.delegate = self;
    _collectionView.backgroundColor = [UIColor clearColor];
    [_collectionView registerClass:[BarNumCell class] forCellWithReuseIdentifier:@"cell"];
    _collectionView.contentSize = CGSizeMake(SCREEN_WIDTH, SCREEN_HEIGHT * 2);
    _collectionView.alwaysBounceVertical = YES;
    _collectionView.showsVerticalScrollIndicator = NO;
    [_collectionView setHidden:YES];
    [self.view addSubview:_collectionView];
    
}


//获取数据
-(void)getData{
    if (_data == nil || [_data count] == 0) {
        [self showHudInView:self.view hint:@"正在加载"];
        self.data = [[NSMutableArray alloc] init];
        
        dispatch_async(dispatch_queue_create("getclass", DISPATCH_QUEUE_CONCURRENT), ^(){
            NSString *param =[NSString stringWithFormat:@"%@", [WHInterfaceUtil intToJsonString:@"status" withValue:0]];
            NSDictionary *dics = [WHInterfaceUtil noLoginWithUrl:@"AboutRestaurant.asmx" urlValue:@"http://service.xingchen.com/getTableList" withParams:param];
            if (dics!=nil) {
                BarNumInfo *info;
                // NSDictionary *tableDic;
                for (NSDictionary *key in dics) {
                    info = [[BarNumInfo alloc] init];
                    info.barNum = [[key objectForKey:@"TableId"] integerValue];
                    int isStopOrStart = [[key objectForKey:@"isStopOrStart"] integerValue];
                    if (isStopOrStart == 0) { // 停用
                        info.status = 100;
                    } else {
                        NSString *OrderStatus = [key objectForKey:@"OrderStatus"];
                        info.status = [OrderStatusObj getOrderStatusByRet:OrderStatus];
                    }
                    [_data addObject:info];
                }
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self hideHud];
                    [_collectionView reloadData];
                    [_collectionView setHidden:NO];
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


//collectionView的代理方法
#pragma mark - collectionView dataSource Or delegate
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return [_data count] + 1;
}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    BarNumCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    
    NSInteger row = indexPath.row;
    if (row == [_data count]) { //最后一个cell用添加按钮
        [cell.num setHidden:YES];
        [cell.status setHidden:YES];
        [cell.addImage setHidden:NO];
        cell.backgroundColor = [UIColor clearColor];
    } else {
        BarNumInfo *info = [_data objectAtIndex:row];
        NSInteger status = info.status;
        switch (status) {
            case 0: //未确认/空闲
                cell.backgroundColor = RGBColorWithoutAlpha(77, 188, 55);
                [cell.status setImage:[UIImage imageNamed:@"free"] forState:(UIControlStateNormal)];
                break;
            case 1: //正在点餐
                cell.backgroundColor = RGBColorWithoutAlpha(77, 188, 55);
                [cell.status setImage:[UIImage imageNamed:@"free"] forState:(UIControlStateNormal)];
                break;
            case 2: //确认
                cell.backgroundColor = RGBColorWithoutAlpha(49, 147, 215);
                [cell.status setImage:[UIImage imageNamed:@"unfinish"] forState:(UIControlStateNormal)];
                break;
            case 3: //配菜完成
                cell.backgroundColor = RGBColorWithoutAlpha(49, 147, 215);
                [cell.status setImage:[UIImage imageNamed:@"select_yes"] forState:(UIControlStateNormal)];
                break;
            case 4: //送菜完成
                cell.backgroundColor = RGBColorWithoutAlpha(49, 147, 215);
                [cell.status setImage:[UIImage imageNamed:@"seat"] forState:(UIControlStateNormal)];
                break;
            case 5: //已结帐
                cell.backgroundColor = RGBColorWithoutAlpha(77, 188, 55);
                [cell.status setImage:[UIImage imageNamed:@"free"] forState:(UIControlStateNormal)];
                break;
            case 6: //申请结帐
                cell.backgroundColor = RGBColorWithoutAlpha(152, 85, 248);
                [cell.status setImage:[UIImage imageNamed:@"check"] forState:(UIControlStateNormal)];
                break;
            case 19: //配菜完成,有菜品缺货
                break;
            case 20: //送菜完成,有菜品缺货
                break;
            case 32: //取消虚假订单
                break;
            case 100: //停用
                cell.backgroundColor = RGBColorWithoutAlpha(156, 156, 156);
                [cell.status setImage:[UIImage imageNamed:@"stop"] forState:(UIControlStateNormal)];
                break;
            default:
                break;
        }
        
        NSInteger num = info.barNum;
        cell.num.text = [NSString stringWithFormat:@"%d", (int)num];
        [cell.addImage setHidden:YES];
        [cell.num setHidden:NO];
        [cell.status setHidden:NO];
    }
   
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    NSInteger row = indexPath.row;
    if (row == [_data count]) { //是否是添加按钮
        [self addBar];
    } else {
        DishesListViewController *dishesList;
        DishingViewController *dishing;
        BarNumInfo *info = [_data objectAtIndex:row];
        NSMutableArray *selectList;
        NSInteger status = info.status;
        switch (status) {
            case 0: //未确认/空闲
                selectList = [NSMutableArray arrayWithCapacity:0];
                dishesList = [[DishesListViewController alloc] initWithBarNum:[_data objectAtIndex:row] withSelectedList:selectList withOrderId:-1];
                [self.navigationController pushViewController:dishesList animated:YES];
                break;
            case 1: //正在点餐
                selectList = [NSMutableArray arrayWithCapacity:0];
                dishesList = [[DishesListViewController alloc] initWithBarNum:[_data objectAtIndex:row] withSelectedList:selectList withOrderId:-1];
                [self.navigationController pushViewController:dishesList animated:YES];
                break;
            case 2: //确认
                dishing = [[DishingViewController alloc] initWithBarNum:[_data objectAtIndex:row]];
                [self.navigationController pushViewController:dishing animated:YES];
                break;
            case 3: //配菜完成
                dishing = [[DishingViewController alloc] initWithBarNum:[_data objectAtIndex:row]];
                [self.navigationController pushViewController:dishing animated:YES];
                break;
            case 4: //送菜完成
                dishing = [[DishingViewController alloc] initWithBarNum:[_data objectAtIndex:row]];
                [self.navigationController pushViewController:dishing animated:YES];
                break;
            case 5: //已结账
                selectList = [NSMutableArray arrayWithCapacity:0];
                dishesList = [[DishesListViewController alloc] initWithBarNum:[_data objectAtIndex:row] withSelectedList:selectList withOrderId:-1];
                [self.navigationController pushViewController:dishesList animated:YES];
                break;
            case 6: //申请结账
                dishing = [[DishingViewController alloc] initWithBarNum:[_data objectAtIndex:row]];
                [self.navigationController pushViewController:dishing animated:YES];
                break;
            case 100: //停用
                break;
            default:
                break;
        }
    }
}

//添加台号
-(void) addBar {
    dispatch_async(dispatch_queue_create("getclass", DISPATCH_QUEUE_CONCURRENT), ^(){
        NSDictionary *dics = [WHInterfaceUtil noLoginWithUrl:@"AboutRestaurant.asmx" urlValue:@"http://service.xingchen.com/addTable" withParams:nil];
        if (dics!=nil) {
            dispatch_async(dispatch_get_main_queue(), ^{
                BarNumInfo *info = [[BarNumInfo alloc] init];
                info.barNum = [_data count] + 1;
                info.status = 1;
                [_data insertObject:info atIndex:[_data count]];
                [_collectionView reloadData];
            });
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [CommonUtil showAlert:@"添加失败"];
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
