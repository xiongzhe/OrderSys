//
//  EditCouponsViewController.m
//  OrderSys
//
//  Created by Macx on 15/8/6.
//  Copyright (c) 2015年 北京星辰万合. All rights reserved.
//

#import "EditCouponsViewController.h"
#import "ButtonView.h"
#import "PopTableCell.h"
#import "CouponsInfo.h"
#import "CouponsTypeListObj.h"
#import "UIViewController+HUD.h"
#import "WHInterfaceUtil.h"
#import "DishTypeListObj.h"
#import "CommonUtil.h"
#import "JSONKit.h"

/**
 * 编辑优惠券页面（编辑、创建）
 **/
@interface EditCouponsViewController ()<UITextFieldDelegate, UITableViewDataSource,UITableViewDelegate>

@property(nonatomic,retain) NSMutableArray *typeList;//菜品类型列表
@property(nonatomic,retain) NSMutableArray *typeIdList;//菜品类型id列表
@property (nonatomic,assign) NSInteger type; //页面类型 0 创建 1 编辑
@property(nonatomic,retain) UITextField *typeText; //收入类型
@property(nonatomic,retain) UITextField *dTypeText; //涉及菜品类型

@property(nonatomic,retain) NSArray *typesList; //菜品类型列表数据
@property(nonatomic,retain) UITableView *typesTableView;
@property(nonatomic,assign) CGFloat typesCellWidth; //typesTableView宽度
@property(nonatomic,retain) UITableView *dTypesTableView;
@property(nonatomic,assign) CGFloat dTypesCellWidth; //typesTableView宽度
@property(nonatomic,retain) CouponsInfo *couponsInfo;

@property(nonatomic,retain) UITextField *fullTf;//满
@property(nonatomic,retain) UITextField *jianTf;//减

@end

@implementation EditCouponsViewController

- (instancetype)initWithType:(NSInteger) type withCouponsInfo:(CouponsInfo *) couponsInfo
{
    self = [super init];
    if (self) {
        
        _couponsInfo = couponsInfo;
        
        //设置导航栏
        self.type = type;
        if (type == 0) {
            self.title = @"创建优惠券";
        } else {
            self.title = @"修改优惠券";
        }
        UIColor *color = [UIColor whiteColor];
        NSDictionary * dict=[NSDictionary dictionaryWithObject:color forKey:UITextAttributeTextColor];
        [UINavigationBar appearance] .titleTextAttributes = dict;
        //设置导航栏返回按钮
        UIBarButtonItem *backItem = [[UIBarButtonItem alloc] init];
        backItem.title = @"返回";
        self.navigationItem.backBarButtonItem = backItem;
        
        //类型选择
        UIView *typeView = [[UIView alloc] initWithFrame:CGRectMake(0, STATU_BAR_HEIGHT + NAV_HEIGHT + 10, SCREEN_WIDTH, ROW_HEIGHT)];
        typeView.backgroundColor = [UIColor whiteColor];
        typeView.userInteractionEnabled = YES;
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickTypes:)];
        [typeView addGestureRecognizer:singleTap];
        
        UILabel *typeLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, 80, ROW_HEIGHT)];
        typeLabel.backgroundColor = [UIColor clearColor];
        typeLabel.textAlignment = NSTextAlignmentLeft;
        typeLabel.textColor = RGBColorWithoutAlpha(100, 100, 100);
        typeLabel.font = [UIFont systemFontOfSize:15.0];
        typeLabel.text = @"优惠券类型";
        [typeView addSubview:typeLabel];
        
        _typeText = [[UITextField alloc] initWithFrame:CGRectMake(typeLabel.frame.origin.x + typeLabel.frame.size.width, 7, SCREEN_WIDTH - typeLabel.frame.origin.x - typeLabel.frame.size.width - 20, ROW_HEIGHT - 14)];
        _typeText.text = @"满减类";
        _typeText.textColor = RGBColorWithoutAlpha(100, 100, 100);
        _typeText.layer.cornerRadius = 2;
        _typeText.backgroundColor = RGBColorWithoutAlpha(226, 229, 228);
        _typeText.userInteractionEnabled = NO;
        
        UIButton *rightButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, _typeText.frame.size.height)];
        [rightButton setImage:[UIImage imageNamed:@"red_array"] forState:UIControlStateNormal];
        _typeText.rightView = rightButton;
        _typeText.rightViewMode = UITextFieldViewModeAlways;
        [typeView addSubview:_typeText];
        
        [self.view addSubview:typeView];
        
        //类型选择
        UIView *dTypeView = [[UIView alloc] initWithFrame:CGRectMake(0, typeView.frame.origin.y + typeView.frame.size.height + 10, SCREEN_WIDTH, ROW_HEIGHT)];
        dTypeView.backgroundColor = [UIColor whiteColor];
        dTypeView.userInteractionEnabled = YES;
        singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickDTypes:)];
        [dTypeView addGestureRecognizer:singleTap];
        
        UILabel *dTypeLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, 80, ROW_HEIGHT)];
        dTypeLabel.backgroundColor = [UIColor clearColor];
        dTypeLabel.textAlignment = NSTextAlignmentLeft;
        dTypeLabel.textColor = RGBColorWithoutAlpha(100, 100, 100);
        dTypeLabel.font = [UIFont systemFontOfSize:15.0];
        dTypeLabel.text = @"涉及菜品";
        [dTypeView addSubview:dTypeLabel];
        
        _dTypeText= [[UITextField alloc] initWithFrame:CGRectMake(dTypeLabel.frame.origin.x + dTypeLabel.frame.size.width, 7, SCREEN_WIDTH - dTypeLabel.frame.origin.x - dTypeLabel.frame.size.width - 20, ROW_HEIGHT - 14)];
        _dTypeText.textColor = RGBColorWithoutAlpha(100, 100, 100);
        _dTypeText.layer.cornerRadius = 2;
        _dTypeText.backgroundColor = RGBColorWithoutAlpha(226, 229, 228);
        _dTypeText.userInteractionEnabled = NO;
        
        UIButton *dRightButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, _dTypeText.frame.size.height)];
        [dRightButton setImage:[UIImage imageNamed:@"red_array"] forState:UIControlStateNormal];
        _dTypeText.rightView = dRightButton;
        _dTypeText.rightViewMode = UITextFieldViewModeAlways;
        [dTypeView addSubview:_dTypeText];
        
        [self.view addSubview:dTypeView];
        
        
        //优惠券金额
        UILabel *moneyLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, dTypeView.frame.origin.y + dTypeView.frame.size.height + 10, SCREEN_WIDTH, ROW_HEIGHT - 10)];
        moneyLabel.backgroundColor = [UIColor clearColor];
        moneyLabel.font = [UIFont systemFontOfSize:15.0];
        moneyLabel.textAlignment = NSTextAlignmentLeft;
        moneyLabel.textColor = RGBColorWithoutAlpha(100, 100, 100);
        moneyLabel.text = @"    优惠券金额";
        [self.view addSubview:moneyLabel];
        
        
        //满减类
        UIView *subView = [[UIView alloc] initWithFrame:CGRectMake(0, moneyLabel.frame.origin.y + moneyLabel.frame.size.height, SCREEN_WIDTH, ROW_HEIGHT + 10)];
        subView.backgroundColor = [UIColor whiteColor];
        
        UILabel *subLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 85, subView.frame.size.height - 20)];
        subLabel.backgroundColor = [UIColor clearColor];
        subLabel.textAlignment = NSTextAlignmentLeft;
        subLabel.textColor = RGBColorWithoutAlpha(100, 100, 100);
        subLabel.font = [UIFont systemFontOfSize:16.0];
        subLabel.text = @"满减类：满";
        [subView addSubview:subLabel];
        
        CGFloat TfWidth = (SCREEN_WIDTH - 85 - 10 * 2 - 20 * 2 - 5 * 3)/2;
        _fullTf = [[UITextField alloc] initWithFrame:CGRectMake(subLabel.frame.origin.x + subLabel.frame.size.width + 5, 10, TfWidth, subLabel.frame.size.height)];
        _fullTf.backgroundColor = RGBColorWithoutAlpha(230, 230, 230);
        _fullTf.borderStyle = UITextBorderStyleNone;
        _fullTf.layer.cornerRadius = 2;
        [_fullTf setClearButtonMode:UITextFieldViewModeWhileEditing];//右侧删除按钮
        _fullTf.text = [NSString stringWithFormat:@"%d", 200];
        _fullTf.userInteractionEnabled = YES;
        //设置键盘，使换行变为完成字样
        _fullTf.delegate = self;
        _fullTf.keyboardType = UIKeyboardAppearanceDefault;
        _fullTf.returnKeyType = UIReturnKeyDone;
        [subView addSubview:_fullTf];
        
        UILabel *jianLabel = [[UILabel alloc] initWithFrame:CGRectMake(_fullTf.frame.origin.x + _fullTf.frame.size.width + 5, 10, 20, subLabel.frame.size.height)];
        jianLabel.backgroundColor = [UIColor clearColor];
        jianLabel.textAlignment = NSTextAlignmentLeft;
        jianLabel.textColor = RGBColorWithoutAlpha(100, 100, 100);
        jianLabel.font = [UIFont systemFontOfSize:16.0];
        jianLabel.text = @"减";
        [subView addSubview:jianLabel];
        
        _jianTf = [[UITextField alloc] initWithFrame:CGRectMake(jianLabel.frame.origin.x + jianLabel.frame.size.width + 5, 10, TfWidth, subLabel.frame.size.height)];
        _jianTf.backgroundColor = RGBColorWithoutAlpha(230, 230, 230);
        _jianTf.borderStyle = UITextBorderStyleNone;
        _jianTf.layer.cornerRadius = 2;
        [_jianTf setClearButtonMode:UITextFieldViewModeWhileEditing];//右侧删除按钮
        _jianTf.text = [NSString stringWithFormat:@"%d", 20];
        _jianTf.userInteractionEnabled = YES;
        //设置键盘，使换行变为完成字样
        _jianTf.delegate = self;
        _jianTf.keyboardType = UIKeyboardAppearanceDefault;
        _jianTf.returnKeyType = UIReturnKeyDone;
        [subView addSubview:_jianTf];
        
        UILabel *yuanLabel = [[UILabel alloc] initWithFrame:CGRectMake(_jianTf.frame.origin.x + _jianTf.frame.size.width + 5, 10, 20, subLabel.frame.size.height)];
        yuanLabel.backgroundColor = [UIColor clearColor];
        yuanLabel.textAlignment = NSTextAlignmentLeft;
        yuanLabel.textColor = RGBColorWithoutAlpha(100, 100, 100);
        yuanLabel.font = [UIFont systemFontOfSize:16.0];
        yuanLabel.text = @"元";
        [subView addSubview:yuanLabel];
        [self.view addSubview:subView];
        
        
        //确认按钮
        UIButton *confirmButton = [[UIButton alloc] initWithFrame:CGRectMake(40, SCREEN_HEIGHT - ROW_HEIGHT *3/2, SCREEN_WIDTH - 80, ROW_HEIGHT - 10)];
        confirmButton.layer.cornerRadius = 5;
        confirmButton.backgroundColor = [UIColor redColor];
        [confirmButton setTitle:@"确　认" forState:UIControlStateNormal];
        confirmButton.titleLabel.textColor = [UIColor whiteColor];
        confirmButton.tag = 1;
        [confirmButton addTarget:self action:@selector(clickConfirm:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:confirmButton];
        
        //列表
        _typesCellWidth = _typeText.frame.size.width * 2/3;
        _typesTableView = [[UITableView alloc] initWithFrame:CGRectMake(_typeText.frame.origin.x + _typesCellWidth/2, typeView.frame.origin.y + typeView.frame.size.height, _typesCellWidth, ROW_HEIGHT * 5) style:UITableViewStylePlain];
        _typesTableView.dataSource = self;
        _typesTableView.delegate = self;
        _typesTableView.layer.cornerRadius = 5;
        [_typesTableView setHidden:YES];
        _typesTableView.backgroundColor = [UIColor clearColor];
        _typesTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [self.view addSubview:_typesTableView];
        
        //列表
        _dTypesCellWidth = _dTypeText.frame.size.width * 2/3;
        _dTypesTableView = [[UITableView alloc] initWithFrame:CGRectMake(_dTypeText.frame.origin.x + _dTypesCellWidth/2, dTypeView.frame.origin.y + dTypeView.frame.size.height, _dTypesCellWidth, ROW_HEIGHT * 5) style:UITableViewStylePlain];
        _dTypesTableView.dataSource = self;
        _dTypesTableView.delegate = self;
        _dTypesTableView.layer.cornerRadius = 5;
        [_dTypesTableView setHidden:YES];
        _dTypesTableView.backgroundColor = [UIColor clearColor];
        _dTypesTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [self.view addSubview:_dTypesTableView];

        
        _typesList = [CouponsTypeListObj getTypeList];
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


//创建并设置每行显示的内容
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == _typesTableView) {
        static NSString *CellWithIdentifier = @"TypeCell";
        PopTableCell *cell = [tableView dequeueReusableCellWithIdentifier:CellWithIdentifier];
        NSUInteger row = [indexPath row];
        if (cell == nil) {
            cell = [[PopTableCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:CellWithIdentifier withCellWidth:_typesCellWidth withCellHeight:44];
        }
        cell.nameLabel.text = [self.typesList objectAtIndex:row];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = [UIColor clearColor];
        cell.backgroundView = nil;
        return cell;
    } else {
        static NSString *CellWithIdentifier = @"TypeCell";
        PopTableCell *cell = [tableView dequeueReusableCellWithIdentifier:CellWithIdentifier];
        NSUInteger row = [indexPath row];
        if (cell == nil) {
            cell = [[PopTableCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:CellWithIdentifier withCellWidth:_typesCellWidth withCellHeight:44];
        }
        cell.nameLabel.text = [_typeList objectAtIndex:row];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = [UIColor clearColor];
        cell.backgroundView = nil;
        return cell;
    }
}

//内容分段
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

//cell高度
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44;
}

//每个cell中显示多少行
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (tableView == _typesTableView) {
         return [_typesList count];
    } else {
         return [_typeList count];
    }
}

//列表点击事件
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSInteger row = indexPath.row;
    if (tableView == _typesTableView) {
        [_typesTableView setHidden:YES];
        _typeText.text = [_typesList objectAtIndex:row];
    } else {
        [_dTypesTableView setHidden:YES];
        _dTypeText.text = [_typeList objectAtIndex:row];
    }
}



//点击类型事件
-(IBAction)clickTypes:(id)sender {
    [_dTypesTableView setHidden:YES];
    NSLog(@"选择优惠券类型");
    if (_typesTableView.isHidden) {
        [_typesTableView setHidden:NO];
    } else{
        [_typesTableView setHidden:YES];
    }
}

//点击涉及菜品类型事件
-(IBAction)clickDTypes:(id)sender {
    [_typesTableView setHidden:YES];
    NSLog(@"选择涉及菜品类型");
    if (_dTypesTableView.isHidden) {
        [_dTypesTableView setHidden:NO];
    } else{
        [_dTypesTableView setHidden:YES];
    }
}

//点击确认事件
-(IBAction)clickConfirm:(id)sender{
    NSLog(@"确认事件");
    [self appendCoupons];
}



//获取菜单列表
-(void)getDishesData {
    if (_typeList == nil || [_typeList count] == 0) {
        [self showHudInView:self.view hint:@"正在加载"];
        self.typeList = [NSMutableArray arrayWithCapacity:0];
        self.typeIdList = [NSMutableArray arrayWithCapacity:0];
        
        dispatch_async(dispatch_queue_create("getclass", DISPATCH_QUEUE_CONCURRENT), ^(){
            NSDictionary *dics = [WHInterfaceUtil noLoginWithUrl:@"AboutDishs.asmx" urlValue:@"http://service.xingchen.com/getDishTypeList" withParams:nil];
            if (dics!=nil) {
                
                for (NSDictionary *key in dics) {
                    //类型列表
                    NSString *typeName = [key objectForKey:@"TypeName"];
                    NSNumber *typeId = [key objectForKey:@"TypeId"];
                    [_typeList addObject:typeName];
                    [_typeIdList addObject:typeId];
                }
                [DishTypeListObj setTypeList:_typeList];
                [DishTypeListObj setTypeIdList:_typeIdList];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self hideHud];
                    [_dTypesTableView reloadData];
                });
                
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self hideHud];
                });
            }
        });
    }
}


//添加日程
-(void) appendCoupons {
    NSString *hint = @"";
    if (_type == 0) { //添加
        hint = @"添加";
    } else {
        hint = @"修改";
    }
    [self showHudInView:self.view hint:[NSString stringWithFormat:@"正在%@", hint]];
    dispatch_async(dispatch_queue_create("getclass", DISPATCH_QUEUE_CONCURRENT), ^(){
        NSString *method = @"";
        NSString *PromotionId = @"";
        if (_type == 0) { //添加
            PromotionId = @"-1";
            method = @"addPromotion";
        } else { //修改
            PromotionId = [NSString stringWithFormat:@"%d", _couponsInfo.PromotionId];
            method = @"modifySchedule";
        }
        NSMutableDictionary *sInfo = [[NSMutableDictionary alloc] initWithCapacity:0];
        [sInfo setObject:PromotionId forKey:@"PromotionId"];
        [sInfo setObject:@"Full_Cut" forKey:@"PromotionType"];
        [sInfo setObject:@"Use_Next" forKey:@"UseType"];
        [sInfo setObject:@"All" forKey:@"PromotionScope"];
        [sInfo setObject:@"Validate" forKey:@"PromotionStatus"];
        [sInfo setObject:_fullTf.text forKey:@"LowTrigger"];
        [sInfo setObject:_jianTf.text forKey:@"HighTrigger"];
        [sInfo setObject:[NSArray arrayWithObjects:_dTypeText.text, nil]forKey:@"WithDishTypeNames"];
        NSString *param = [NSString stringWithFormat:@"\"Promotion\":%@",[sInfo JSONString]];
        NSDictionary *dics = [WHInterfaceUtil noLoginWithUrl:@"AboutPromotion.asmx" urlValue:[NSString stringWithFormat:@"%@%@", @"http://service.xingchen.com/", method] withParams:param];
        if (dics!=nil) {
            int isSuccess = [[dics objectForKey:@"IsSuccess"] integerValue];
            if (isSuccess == 1) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.navigationController popViewControllerAnimated:YES];
                    [self hideHud];
                    [CommonUtil showAlert:[NSString stringWithFormat:@"%@成功", hint]];
                });
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self hideHud];
                    [CommonUtil showAlert:[NSString stringWithFormat:@"%@失败", hint]];
                });
            }
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self hideHud];
                [CommonUtil showAlert:[NSString stringWithFormat:@"%@失败", hint]];
            });
        }
    });
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
