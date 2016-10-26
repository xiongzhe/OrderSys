//
//  UploadDishViewController.m
//  OrderSys
//
//  Created by Macx on 15/8/17.
//  Copyright (c) 2015年 北京星辰万合. All rights reserved.
//

#import "UploadDishViewController.h"
#import "OrderDishInfo.h"
#import "DBImageView.h"
#import "PopListView.h"
#import "DishTypeListObj.h"
#import "UIViewController+HUD.h"
#import "WHInterfaceUtil.h"
#import "CommonUtil.h"
#import "JSONKit.h"
#import "CommonInfo.h"

/**
 * 上传菜品页面
 **/
@interface UploadDishViewController ()<UIScrollViewDelegate,UITextFieldDelegate,UITextViewDelegate,UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate, PopClickDelegate>

@property(nonatomic, retain) UIScrollView *scrollView;
@property(nonatomic, retain) OrderDishInfo *orderDishInfo;
@property(nonatomic,retain) UILabel *typeText; //菜品所属分类
@property(nonatomic,retain) UIView *chooseView; //底部按钮视图
@property(nonatomic,retain) UITextView *contentTF; //菜品描述内容
@property(nonatomic,retain) PopListView *typesView; //类型选择布局
@property(nonatomic,assign) NSInteger editType; //编辑类型 0 编辑 1 完成
@property(nonatomic,retain) UIButton *editButton; //编辑按钮
@property(nonatomic,retain) UITextField *nameTf; //菜品名称
@property(nonatomic,retain) UITextField *priceTf; //菜品价格
@property(nonatomic,retain) UITextField *numTf; //菜品数量
@property(nonatomic,assign) NSInteger index; //当前菜品类型row
@property(nonatomic,retain) NSArray *dishTypes; //菜品类型列表
@property(nonatomic,retain) NSArray *dishTypeIds; //菜品类型id列表
@property(nonatomic,retain) DBImageView *image; //上传图片
@property(nonatomic,retain) UIActionSheet *sheet;
@property(nonatomic,retain) NSString* filePath; //图片2进制路径
@property(nonatomic,assign) NSInteger opType; //调用接口类型 0 上传 1 修改 2 下架

@end

@implementation UploadDishViewController

- (instancetype)initWithOrderDishInfo:(OrderDishInfo *) orderDishInfo
{
    self = [super init];
    if (self) {
        
        _orderDishInfo = orderDishInfo;
        _editType = 0;
        _dishTypes = [DishTypeListObj getTypeList];
        _dishTypeIds = [DishTypeListObj getTypeIdList];
        _index = 0;
        
        
        self.title = @"上传菜品";
        //设置导航栏返回按钮
        UIBarButtonItem *backItem = [[UIBarButtonItem alloc] init];
        backItem.title = @"返回";
        self.navigationItem.backBarButtonItem = backItem;
        
        _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
        
        //菜品所属分类
        UIView *typeView = [[UIView alloc] initWithFrame:CGRectMake(0, 10, SCREEN_WIDTH, ROW_HEIGHT)];
        typeView.backgroundColor = [UIColor whiteColor];
        typeView.layer.borderWidth = 0.5;
        typeView.layer.borderColor = RGBColorWithoutAlpha(226, 229, 228).CGColor;
        
        UILabel *typeLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, 80, ROW_HEIGHT)];
        typeLabel.backgroundColor = [UIColor clearColor];
        typeLabel.textAlignment = NSTextAlignmentLeft;
        typeLabel.font = [UIFont systemFontOfSize:16];
        typeLabel.text = @"所属分类";
        typeLabel.textColor = RGBColorWithoutAlpha(100, 100, 100);
        
        _typeText = [[UILabel alloc] initWithFrame:CGRectMake(typeLabel.frame.origin.x + typeLabel.frame.size.width, 5, typeView.frame.size.width - typeLabel.frame.origin.x - typeLabel.frame.size.width - 40, typeLabel.frame.size.height - 10)];
        _typeText.layer.cornerRadius = 5;
        _typeText.font = [UIFont systemFontOfSize:15.0];
        _typeText.textColor = RGBColorWithoutAlpha(100, 100, 100);
        _typeText.text = [_dishTypes objectAtIndex:orderDishInfo.TypeId];
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickType:)];
        [_typeText addGestureRecognizer:singleTap];
        
        [typeView addSubview:typeLabel];
        [typeView addSubview:_typeText];
        [_scrollView addSubview:typeView];
        
        
        //菜品名称
        UIView *nameView = [[UIView alloc] initWithFrame:CGRectMake(0, typeView.frame.origin.y + typeView.frame.size.height, SCREEN_WIDTH, ROW_HEIGHT)];
        nameView.backgroundColor = [UIColor whiteColor];
        
        UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, 80, nameView.frame.size.height)];
        nameLabel.backgroundColor = [UIColor clearColor];
        nameLabel.font = [UIFont systemFontOfSize:16];
        nameLabel.textAlignment = NSTextAlignmentLeft;
        nameLabel.text = @"菜品名称";
        nameLabel.textColor = RGBColorWithoutAlpha(100, 100, 100);
        
        _nameTf = [[UITextField alloc] initWithFrame:CGRectMake(nameLabel.frame.origin.x + nameLabel.frame.size.width, 8, nameView.frame.size.width - nameLabel.frame.origin.x - nameLabel.frame.size.width - 10 - 35, nameLabel.frame.size.height - 16)];
        _nameTf.borderStyle = UITextBorderStyleNone;
        _nameTf.backgroundColor = [UIColor whiteColor];
        _nameTf.font = [UIFont systemFontOfSize:15.0];
        _nameTf.textColor = RGBColorWithoutAlpha(100, 100, 100);
        [_nameTf setClearButtonMode:UITextFieldViewModeWhileEditing];//右侧删除按钮
        
        //设置键盘，使换行变为完成字样
        _nameTf.delegate = self;
        _nameTf.keyboardType = UIKeyboardAppearanceDefault;
        _nameTf.returnKeyType = UIReturnKeyDone;
        
        [nameView addSubview:nameLabel];
        [nameView addSubview:_nameTf];
        [_scrollView addSubview:nameView];
        
        
        //菜品价格
        UIView *priceView = [[UIView alloc] initWithFrame:CGRectMake(0, nameView.frame.origin.y + nameView.frame.size.height, SCREEN_WIDTH, ROW_HEIGHT)];
        priceView.backgroundColor = [UIColor whiteColor];
        priceView.layer.borderWidth = 0.5;
        priceView.layer.borderColor = RGBColorWithoutAlpha(226, 229, 228).CGColor;
        
        UILabel *priceLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, 80, priceView.frame.size.height)];
        priceLabel.backgroundColor = [UIColor clearColor];
        priceLabel.font = [UIFont systemFontOfSize:16];
        priceLabel.textAlignment = NSTextAlignmentLeft;
        priceLabel.text = @"菜品价格";
        priceLabel.textColor = RGBColorWithoutAlpha(100, 100, 100);
        
        _priceTf = [[UITextField alloc] initWithFrame:CGRectMake(priceLabel.frame.origin.x + priceLabel.frame.size.width, 8, priceView.frame.size.width - priceLabel.frame.origin.x - priceLabel.frame.size.width - 10 - 35, priceLabel.frame.size.height - 16)];
        _priceTf.backgroundColor = [UIColor whiteColor];
        _priceTf.borderStyle = UITextBorderStyleNone;
        _priceTf.font = [UIFont systemFontOfSize:15.0];
        _priceTf.textColor = RGBColorWithoutAlpha(100, 100, 100);
        [_priceTf setClearButtonMode:UITextFieldViewModeWhileEditing];//右侧删除按钮
        //设置键盘，使换行变为完成字样
        _priceTf.delegate = self;
        _priceTf.keyboardType = UIKeyboardAppearanceDefault;
        _priceTf.returnKeyType = UIReturnKeyDone;
        
        [priceView addSubview:priceLabel];
        [priceView addSubview:_priceTf];
        [_scrollView addSubview:priceView];
        
        //菜品数量
        UIView *numView = [[UIView alloc] initWithFrame:CGRectMake(0, priceView.frame.origin.y + priceView.frame.size.height, SCREEN_WIDTH, ROW_HEIGHT)];
        numView.backgroundColor = [UIColor whiteColor];
        
        UILabel *numLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, 80, numView.frame.size.height)];
        numLabel.backgroundColor = [UIColor clearColor];
        numLabel.font = [UIFont systemFontOfSize:16];
        numLabel.textAlignment = NSTextAlignmentLeft;
        numLabel.text = @"菜品数量";
        numLabel.textColor = RGBColorWithoutAlpha(100, 100, 100);
        
        _numTf = [[UITextField alloc] initWithFrame:CGRectMake(numLabel.frame.origin.x + numLabel.frame.size.width, 8, numView.frame.size.width - numLabel.frame.origin.x - numLabel.frame.size.width - 10 - 35, numLabel.frame.size.height - 16)];
        _numTf.backgroundColor = [UIColor whiteColor];
        _numTf.borderStyle = UITextBorderStyleNone;
        [_numTf setClearButtonMode:UITextFieldViewModeWhileEditing];//右侧删除按钮
        _numTf.placeholder = @"选填";
        _numTf.font = [UIFont systemFontOfSize:15.0];
        _numTf.textColor = RGBColorWithoutAlpha(100, 100, 100);
        //设置键盘，使换行变为完成字样
        _numTf.delegate = self;
        _numTf.keyboardType = UIKeyboardAppearanceDefault;
        _numTf.returnKeyType = UIReturnKeyDone;
        
        [numView addSubview:numLabel];
        [numView addSubview:_numTf];
        [_scrollView addSubview:numView];


        //上传菜品图片
        UIView *dishesImageView = [[UIView alloc] initWithFrame:CGRectMake(0, numView.frame.origin.y + numView.frame.size.height, SCREEN_WIDTH, ROW_HEIGHT * 3)];
        dishesImageView.backgroundColor = [UIColor whiteColor];
        dishesImageView.layer.borderWidth = 0.5;
        dishesImageView.layer.borderColor = RGBColorWithoutAlpha(226, 229, 228).CGColor;
        
        UILabel *dishImageLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, 120, dishesImageView.frame.size.height/3)];
        dishImageLabel.backgroundColor = [UIColor clearColor];
        dishImageLabel.font = [UIFont systemFontOfSize:16];
        dishImageLabel.textAlignment = NSTextAlignmentLeft;
        dishImageLabel.text = @"上传菜品图片";
        dishImageLabel.textColor = RGBColorWithoutAlpha(100, 100, 100);
        [dishesImageView addSubview:dishImageLabel];
        
        _image = [[DBImageView alloc] initWithFrame:CGRectMake(20,dishImageLabel.frame.origin.y + dishImageLabel.frame.size.height, dishesImageView.frame.size.height *2/3 - 10, dishesImageView.frame.size.height *2/3 - 10)];
        singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickImage:)];
        [_image addGestureRecognizer:singleTap];
        _image.contentMode=UIViewContentModeScaleAspectFit;
        [_image setImage:[UIImage imageNamed:@"photo"]];
        [dishesImageView addSubview:_image];
        [_scrollView addSubview:dishesImageView];
        
        //菜品介绍
        UIView *instrView = [[UIView alloc] initWithFrame:CGRectMake(0, dishesImageView.frame.origin.y + dishesImageView.frame.size.height, SCREEN_WIDTH, ROW_HEIGHT * 3)];
        instrView.backgroundColor = [UIColor whiteColor];
        
        UILabel *instrLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, 80, instrView.frame.size.height/3)];
        instrLabel.backgroundColor = [UIColor clearColor];
        instrLabel.font = [UIFont systemFontOfSize:16];
        instrLabel.textAlignment = NSTextAlignmentLeft;
        instrLabel.text = @"菜品介绍";
        instrLabel.textColor = RGBColorWithoutAlpha(100, 100, 100);
        
        _contentTF = [[UITextView alloc] initWithFrame:CGRectMake(20, instrLabel.frame.origin.y + instrLabel.frame.size.height, SCREEN_WIDTH - 40, instrView.frame.size.height *2/3 - 10)];
        _contentTF.font = [UIFont systemFontOfSize:14];
        _contentTF.text = @"选填"; 
        _contentTF.backgroundColor = [UIColor whiteColor];
        _contentTF.delegate = self;
        _contentTF.keyboardType = UIKeyboardAppearanceDefault;
        _contentTF.returnKeyType = UIReturnKeyDone;
        [instrView addSubview:_contentTF];
        [instrView addSubview:instrLabel];
        [_scrollView addSubview:instrView];
        
        
        //按钮视图
        _chooseView = [[UIView alloc] initWithFrame:CGRectMake(0, instrView.frame.origin.y + instrView.frame.size.height + 30, SCREEN_WIDTH, ROW_HEIGHT)];
        _chooseView.backgroundColor = [UIColor clearColor];
        
        //确认
        UIButton *confirmButton = [[UIButton alloc] initWithFrame:CGRectMake(40, 5, _scrollView.frame.size.width - 80, _chooseView.frame.size.height - 10)];
        [confirmButton setTitle:@"确认" forState:UIControlStateNormal];
        [confirmButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        confirmButton.backgroundColor = [UIColor redColor];
        confirmButton.layer.cornerRadius = 4;
        confirmButton.tag = 2;
        [confirmButton addTarget:self action:@selector(clickButtons:) forControlEvents:UIControlEventTouchUpInside];
        [_chooseView addSubview:confirmButton];
        
        CGFloat inset = SCREEN_WIDTH - 20 * 2 - 120 * 2;//按钮间隔
        //编辑
        _editButton = [[UIButton alloc] initWithFrame:CGRectMake(20, 5, 120, _chooseView.frame.size.height - 10)];
        [_editButton setTitle:@"编辑" forState:UIControlStateNormal];
        [_editButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _editButton.backgroundColor = [UIColor redColor];
        _editButton.layer.cornerRadius = 4;
        _editButton.tag = 0;
        [_editButton addTarget:self action:@selector(clickButtons:) forControlEvents:UIControlEventTouchUpInside];
        [_chooseView addSubview:_editButton];
        //结账
        UIButton *checkButton = [[UIButton alloc] initWithFrame:CGRectMake(_editButton.frame.origin.x + _editButton.frame.size.width + inset, 5, 120, _chooseView.frame.size.height - 10)];
        [checkButton setTitle:@"下架" forState:UIControlStateNormal];
        [checkButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        checkButton.backgroundColor = [UIColor redColor];
        checkButton.layer.cornerRadius = 4;
        checkButton.tag = 1;
        [checkButton addTarget:self action:@selector(clickButtons:) forControlEvents:UIControlEventTouchUpInside];
        [_chooseView addSubview:checkButton];
        [_scrollView addSubview:_chooseView];

        
        if (_orderDishInfo == nil) { //上传菜品页面
            _opType = 0;
            [confirmButton setHidden:NO];
            [_editButton setHidden:YES];
            [checkButton setHidden:YES];
            _typeText.userInteractionEnabled = YES;
            _typeText.text = [_dishTypes objectAtIndex:_index];
            _nameTf.userInteractionEnabled = YES;
            _priceTf.userInteractionEnabled = YES;
            _numTf.userInteractionEnabled = YES;
            _contentTF.userInteractionEnabled = YES;
            _nameTf.backgroundColor = RGBColorWithoutAlpha(230, 230, 230);
            _priceTf.backgroundColor = RGBColorWithoutAlpha(230, 230, 230);
            _numTf.backgroundColor = RGBColorWithoutAlpha(230, 230, 230);
            _contentTF.backgroundColor = RGBColorWithoutAlpha(226, 229, 228);
            _image.userInteractionEnabled = YES;
        } else { //编辑菜品页面
            _opType = 1;
            [confirmButton setHidden:YES];
            [_editButton setHidden:NO];
            [checkButton setHidden:NO];
            _typeText.userInteractionEnabled = NO;
            _nameTf.userInteractionEnabled = NO;
            _priceTf.userInteractionEnabled = NO;
            _numTf.userInteractionEnabled = NO;
            _contentTF.userInteractionEnabled = NO;
            _typeText.text = orderDishInfo.TypeName;
            _nameTf.text = orderDishInfo.DishName;
            _priceTf.text = [NSString stringWithFormat:@"%ld", [orderDishInfo.DishPrice longValue]];
            _numTf.text = [NSString stringWithFormat:@"%d", (int)orderDishInfo.DishCount];
            _contentTF.text = orderDishInfo.DishDesc;
            _image.userInteractionEnabled = NO;
            [_image setImageWithPath:orderDishInfo.DishPic];
        }
        
        //类型选择布局
        _typesView = [[PopListView alloc] initWithFrame:CGRectMake(typeView.frame.origin.x + _typeText.frame.origin.x + _typeText.frame.size.width/2,typeView.frame.origin.y + typeView.frame.size.height, _typeText.frame.size.width/2, 0.5+(ROW_HEIGHT + 0.5) * [_dishTypes count]) withShowView:(UILabel *)_typeText withArray:_dishTypes withBackgroundColor:RGBColor(60, 60, 60, 0.8)];
        _typesView.delegate = self;
        [_typesView setHidden:YES];
        [_scrollView addSubview:_typesView];
        [self.view addSubview:_scrollView];
        [self setupPage:nil];
        
        //底部弹出框
        _sheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"打开照相机", @"从手机相册获取", nil];
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
    _scrollView.contentSize = CGSizeMake(SCREEN_WIDTH, _chooseView.frame.origin.y + _chooseView.frame.size.height + 10);
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

//点击编辑、下架、确认按钮事件
-(IBAction)clickButtons:(id)sender {
    UIButton *button = (UIButton *) sender;
    NSInteger tag = button.tag;
    switch (tag) {
        case 0: //编辑
            if (_editType == 0) { //编辑
                _typeText.userInteractionEnabled = YES;
                _editType = 1;
                [_editButton setTitle:@"完成" forState:UIControlStateNormal];
                _nameTf.backgroundColor = RGBColorWithoutAlpha(230, 230, 230);
                _nameTf.userInteractionEnabled = YES;
                _priceTf.backgroundColor = RGBColorWithoutAlpha(230, 230, 230);
                _priceTf.userInteractionEnabled = YES;
                _numTf.backgroundColor = RGBColorWithoutAlpha(230, 230, 230);
                _numTf.userInteractionEnabled = YES;
                _contentTF.backgroundColor = RGBColorWithoutAlpha(226, 229, 228);
                _contentTF.userInteractionEnabled = YES;
                _image.userInteractionEnabled = YES;
            } else { //完成
                [self uploadDishToServer];
            }
            break;
        case 1: //下架
            _opType = 2;
            [self uploadDishToServer];
            break;
        case 2: //确认
            [self uploadDishToServer];
            break;
        default:
            break;
    }
}

//上传/修改菜品
-(void) uploadDishToServer {
    [self showHudInView:self.view hint:@"更新数据中"];
    
    dispatch_async(dispatch_queue_create("getclass", DISPATCH_QUEUE_CONCURRENT), ^(){
        NSString *method = @"addDish";//调用方法
        NSNumber *DishId;
        NSNumber *DishStatus;
        if (_opType == 0) { //上传
            method = @"addDish";
            DishId = [NSNumber numberWithInt:-1];
            DishStatus = [NSNumber numberWithInt:1];
        } else if (_opType == 1) { //编辑
            method = @"modifyDish";
            DishId = [NSNumber numberWithInt:_orderDishInfo.DishId];
            DishStatus = [NSNumber numberWithInt:1];
        } else {
            method = @"modifyDish";
            DishId = [NSNumber numberWithInt:_orderDishInfo.DishId];
            DishStatus = [NSNumber numberWithInt:0];
        }
        
        NSMutableDictionary *order = [[NSMutableDictionary alloc] initWithCapacity:0];
        [order setObject:DishId forKey:@"DishId"];
        [order setObject:[_dishTypeIds objectAtIndex:_index] forKey:@"TypeId"];
        [order setObject:[_dishTypes objectAtIndex:_index] forKey:@"TypeName"];
        [order setObject:_nameTf.text forKey:@"DishName"];
        [order setObject:[NSNumber numberWithInteger:[_priceTf.text integerValue]] forKey:@"DishPrice"];
        [order setObject:[NSNumber numberWithInteger:[_numTf.text integerValue]] forKey:@"DishCount"];
        [order setObject:@"http://baike.baidu.com/picture/1711243/1711243/0/500fd9f9d72a6059d91384b12c34349b033bba1e.html?fr=lemma&ct=single" forKey:@"DishPic"];
        [order setObject:_contentTF.text forKey:@"DishDesc"];
        [order setObject:DishStatus forKey:@"DishStatus"];
        NSString *param = [NSString stringWithFormat:@"\"Dishes\":%@", [order JSONString]];
        NSDictionary *dics = [WHInterfaceUtil noLoginWithUrl:@"AboutDishs.asmx" urlValue:[NSString stringWithFormat:@"%@%@", @"http://service.xingchen.com/", method] withParams:param];
        if (dics!=nil) {
            int isSuccess = [[dics objectForKey:@"IsSuccess"] integerValue];
            if (isSuccess == 1) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self hideHud];
                    [self.navigationController popViewControllerAnimated:YES];
                    [self showHintStr:1];
                });
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self hideHud];
                    [self showHintStr:0];
                });
            }
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self hideHud];
                [self showHintStr:0];
            });
        }
    });
}

//显示提示窗
-(void) showHintStr:(NSInteger) isSuccess {
    if (_opType == 0) {
        if (isSuccess == 1) { //成功
            [CommonUtil showAlert:@"上传成功"];
        } else {
            [CommonUtil showAlert:@"上传失败"];
        }
    } else if (_opType == 1) {
        if (isSuccess == 1) { //成功
            [CommonUtil showAlert:@"修改成功"];
        } else {
            [CommonUtil showAlert:@"修改失败"];
        }
    } else {
        if (isSuccess == 1) { //成功
            [CommonUtil showAlert:@"下架成功"];
        } else {
            [CommonUtil showAlert:@"下架失败"];
        }
    }
}

//点击图片事件
-(IBAction)clickImage:(id)sender {
    NSLog(@"点击图片事件");
    [_sheet showInView:self.view];
}

//UIActionSheet按钮监听
- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    NSLog(@"Button %d", (int)buttonIndex);
    switch (buttonIndex) {
        case 0: //照相机获取
            [self takePhoto];
            break;
        case 1: //从图库获取
            [self LocalPhoto];
            break;
        default:
            break;
    }
}


//开始拍照
-(void)takePhoto {
    UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypeCamera;
    if ([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera]){
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        [picker.navigationBar setTintColor:[UIColor whiteColor]];
        picker.delegate = self;
        //设置拍照后的图片可被编辑
        picker.allowsEditing = YES;
        picker.sourceType = sourceType;
        if ([[[UIDevice currentDevice] systemVersion] floatValue]>=8.0) {
            self.modalPresentationStyle=UIModalPresentationOverCurrentContext;
        }
        [self presentViewController:picker animated:YES completion:nil];
    } else {
        NSLog(@"模拟其中无法打开照相机,请在真机中使用");
    }
}

//打开本地相册
-(void)LocalPhoto {
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    [picker.navigationBar setTintColor:[UIColor whiteColor]];
    picker.delegate = self;
    //设置选择后的图片可被编辑
    picker.allowsEditing = YES;
    if ([[[UIDevice currentDevice] systemVersion] floatValue]>=8.0) {
        self.modalPresentationStyle=UIModalPresentationOverCurrentContext;
    }
    [self presentViewController:picker animated:YES completion:nil];
}

//当选择一张图片后进入这里
-(void)imagePickerController:(UIImagePickerController*)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    NSString *type = [info objectForKey:UIImagePickerControllerMediaType];
    //当选择的类型是图片
    if ([type isEqualToString:@"public.image"]) {
        //先把图片转成NSData
        UIImage* image = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
        
        //修改图片尺寸 进行压缩
        CGSize imagesize = image.size;
        CGFloat rate = 600.0/imagesize.height;
        imagesize.height = imagesize.height*rate;
        imagesize.width = imagesize.width*rate;
        image = [self imageWithImage:image scaledToSize:imagesize];
        
        NSData *data;
        if (UIImagePNGRepresentation(image) == nil) {
            data = UIImageJPEGRepresentation(image, 1.0);
        } else {
            data = UIImagePNGRepresentation(image);
        }
    
        //图片保存的路径 这里将图片放在沙盒的documents文件夹中
        NSString * DocumentsPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        //把刚刚图片转换的data对象拷贝至沙盒中 并保存为image.png
        [fileManager createDirectoryAtPath:DocumentsPath withIntermediateDirectories:YES attributes:nil error:nil];
        [fileManager createFileAtPath:[DocumentsPath stringByAppendingString:@"/image.png"] contents:data attributes:nil];
        //得到选择后沙盒中图片的完整路径
        _filePath = [[NSString alloc]initWithFormat:@"%@%@",DocumentsPath,  @"/image.png"];
        
        //关闭相册界面
        [picker dismissViewControllerAnimated:YES completion:nil];
        
        [_image setImage:image];
        
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    NSLog(@"您取消了选择图片");
    [picker dismissViewControllerAnimated:YES completion:nil];
}


//对图片尺寸进行压缩--
-(UIImage*)imageWithImage:(UIImage*)image scaledToSize:(CGSize)newSize {
    // Create a graphics image context
    UIGraphicsBeginImageContext(newSize);
    // Tell the old image to draw in this new context, with the desired
    // new size
    [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    // Get the new image from the context
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    // End the context
    UIGraphicsEndImageContext();
    // Return the new image.
    return newImage;
}

#pragma PopListView
-(void) clickItem:(NSInteger)index {
    _index = index;
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


//键盘收回事件，UITextView协议方法
-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    return YES;
}

//***更改frame的值***//
//在UITextField 编辑之前调用方法
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
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
    return YES;
}
//在UITextField 编辑完成调用方法
- (void)textViewDidEndEditing:(UITextView *)textView {
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

//隐藏软键盘
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [[self view] endEditing:YES];
}


//键盘收回事件，UITextField协议方法
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return NO;
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
