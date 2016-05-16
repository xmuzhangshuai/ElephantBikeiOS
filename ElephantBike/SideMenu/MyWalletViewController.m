//
//  MyWalletViewController.m
//  ElephantBike
//
//  Created by 黄杰锋 on 16/1/20.
//  Copyright © 2016年 黄杰锋. All rights reserved.
//

#import "MyWalletViewController.h"
#import "UISize.h"
#import "RechargeViewController.h"
#import "AppDelegate.h"
#import "LoadingView.h"
#import "MyURLConnection.h"
#import "UIImageView+WebCache.h"

#define BALANCEIMAGEVIEW_WIDTH  0.25*SCREEN_WIDTH
#define BALANCEIMAGEVIEW_HEIGHT BALANCEIMAGEVIEW_WIDTH
#define BALANCELABEL_WIDTH      1.5*BALANCEIMAGEVIEW_WIDTH
#define BALANCELABEL_HEIGHT     0.33*BALANCEIMAGEVIEW_HEIGHT
#define HINTMES_WIDTH           0.55*SCREEN_WIDTH
#define HINTMES_HEIGHT          SAME_HEIGHT
#define RECHARGEBUTTON_WIDTH    0.4*HINTMES_WIDTH
#define RECHARGEBUTTON_HEIGHT   SAME_HEIGHT
#define BALANCEDETAILSLABEL_WIDTH   0.9*SCREEN_WIDTH
#define BALANCEDETAILSLABEL_HEIGHT  SAME_HEIGHT
#define DETAILSTABLEVIEW_WIDTH  0.9*SCREEN_WIDTH
//#define DETAILSTABLEVIEW_HEIGHT 44*5
#define DETAILSTABLEVIEW_HEIGHT 0.057*SCREEN_HEIGHT*5+BALANCEDETAILSLABEL_HEIGHT

@interface MyWalletViewController () <UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate, MyURLConnectionDelegate, UIAlertViewDelegate>

@end

@implementation MyWalletViewController {
    UIImageView *balanceImageView;
    UILabel     *balanceLabel;
    UILabel     *hintMes;
    UIButton    *rechargeButton;
    UILabel     *balanceDetailsLabel;
    UITableView *detailsTableView;
    AppDelegate *myAppDelegate;
    
    NSMutableArray *dataArray;  // 存放从服务器返回来的余额明细
    NSUserDefaults *userDefaults;
    CGFloat     cellHeight;
    int         page;
    BOOL        isNone;    // 判断是否还有余额明细的数据
    UIView      *cover;
    UILabel     *yueLabel;  // 余额label
}

- (id)init {
    if (self = [super init]) {
        dataArray           = [[NSMutableArray alloc] init];
    }
    
    return self;
}

- (void)UIInit {
    balanceImageView    = [[UIImageView alloc] init];
    balanceLabel        = [[UILabel alloc] init];
    hintMes             = [[UILabel alloc] init];
    rechargeButton      = [[UIButton alloc] init];
    balanceDetailsLabel = [[ UILabel alloc] init];
    detailsTableView    = [[UITableView alloc] init];
    myAppDelegate       = [[UIApplication sharedApplication] delegate];
    userDefaults        = [NSUserDefaults standardUserDefaults];
    page                = 0;
    isNone              = NO;
    cover               = [[UIView alloc] init];
    yueLabel            = [[UILabel alloc] init];

    
    [self UILayout];
    [self NavigationInit];
}

- (void)EventInit {
    [self requestForData];
    [self requestForBalance];
}

- (void)UILayout {
    balanceImageView.frame = CGRectMake((SCREEN_WIDTH-BALANCEIMAGEVIEW_WIDTH)/2, STATUS_HEIGHT*2+NAVIGATIONBAR_HEIGHT, BALANCEIMAGEVIEW_WIDTH, BALANCEIMAGEVIEW_HEIGHT);
      balanceImageView.center = CGPointMake(0.499*SCREEN_WIDTH, 0.223*SCREEN_HEIGHT);
    balanceImageView.image = [UIImage imageNamed:@"余额框"];
    balanceImageView.contentMode = UIViewContentModeScaleAspectFit;
    
    yueLabel.frame = CGRectMake(0, 0, 100, 50);
    yueLabel.center = CGPointMake(0.5*BALANCEIMAGEVIEW_WIDTH, 0.25*BALANCEIMAGEVIEW_HEIGHT);
    yueLabel.text = @"余额";
    yueLabel.textColor = [UIColor whiteColor];
    yueLabel.textAlignment = NSTextAlignmentCenter;
    yueLabel.font = [UIFont fontWithName:@"QingYuanMono" size:15];
    [balanceImageView addSubview:yueLabel];
    
    balanceLabel.frame = CGRectMake((BALANCEIMAGEVIEW_WIDTH-BALANCELABEL_WIDTH)/2, 0.4*BALANCEIMAGEVIEW_HEIGHT, BALANCELABEL_WIDTH, BALANCELABEL_HEIGHT);
    balanceLabel.text = myAppDelegate.balance;
    balanceLabel.textAlignment = NSTextAlignmentCenter;
    balanceLabel.font = [UIFont fontWithName:@"QingYuanMono" size:25];
    balanceLabel.textColor = [UIColor whiteColor];
    
    hintMes.frame = CGRectMake((SCREEN_WIDTH-HINTMES_WIDTH-RECHARGEBUTTON_WIDTH)/2, 0.308*SCREEN_HEIGHT, HINTMES_WIDTH, HINTMES_HEIGHT);
    hintMes.text = @"使用大象钱包免密码快捷支付，";
    hintMes.textAlignment = NSTextAlignmentRight;
    if (iPhone5) {
        hintMes.font = [UIFont fontWithName:@"QingYuanMono" size:12];
    }else{
        hintMes.font = [UIFont fontWithName:@"QingYuanMono" size:13];
    }

    
    rechargeButton.frame = CGRectMake((SCREEN_WIDTH-HINTMES_WIDTH-RECHARGEBUTTON_WIDTH)/2+HINTMES_WIDTH-20, 0.308*SCREEN_HEIGHT, RECHARGEBUTTON_WIDTH, RECHARGEBUTTON_HEIGHT);
    rechargeButton.titleLabel.textColor = UICOLOR;
    rechargeButton.titleLabel.textAlignment = NSTextAlignmentLeft;
    NSMutableAttributedString *title = [[NSMutableAttributedString alloc] initWithString:@"立即充值>"];
    NSRange titleRnage = {0, [title length]};
    [title addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle] range:titleRnage];
    [rechargeButton setAttributedTitle:title forState:UIControlStateNormal];
    rechargeButton.titleLabel.font = [UIFont fontWithName:@"QingYuanMono" size:13];
    [rechargeButton addTarget:self action:@selector(RechargeView) forControlEvents:UIControlEventTouchUpInside];

//    
//    balanceDetailsLabel.frame = CGRectMake(0.05*SCREEN_WIDTH, STATUS_HEIGHT*3+NAVIGATIONBAR_HEIGHT+BALANCEIMAGEVIEW_HEIGHT+RECHARGEBUTTON_HEIGHT, BALANCEDETAILSLABEL_WIDTH, BALANCEDETAILSLABEL_HEIGHT);
//    balanceDetailsLabel.text = @"—————————— 余额明细 ——————————";
//    balanceDetailsLabel.textAlignment = NSTextAlignmentCenter;
//    balanceDetailsLabel.font = [UIFont fontWithName:@"QingYuanMono" size:10];
//    if (SCREEN_WIDTH == 320) {
//        balanceDetailsLabel.text = @"————————— 余额明细 —————————";
//    }
    
    
    detailsTableView.frame = CGRectMake(0.05*SCREEN_WIDTH, 0.3753*SCREEN_HEIGHT, DETAILSTABLEVIEW_WIDTH, DETAILSTABLEVIEW_HEIGHT);
    detailsTableView.dataSource = self;
    detailsTableView.delegate = self;
    detailsTableView.scrollEnabled = NO;
    detailsTableView.backgroundColor = [UIColor colorWithRed:240/255.0 green:240/255.0 blue:240/255.0 alpha:1.0];

    
//    footView = [[LoadingView alloc] initWithFrame:CGRectMake(0, 0, DETAILSTABLEVIEW_WIDTH, 50)];
//    [footView setRefreshStateWhite];
//    detailsTableView.tableFooterView = footView;
    
    // 列表的位置添加一个等待菊花动画 把列表的加载放到服务器返回里面
    
    

    
    [self.view addSubview:balanceImageView];
    [balanceImageView addSubview:balanceLabel];
    [self.view addSubview:hintMes];
    [self.view addSubview:rechargeButton];
    [self.view addSubview:balanceDetailsLabel];
    [self.view addSubview:detailsTableView];
}

- (void)NavigationInit {
    self.navigationItem.title = @"我的钱包";
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"返回"] style:UIBarButtonItemStylePlain target:self action:@selector(back)];
    backButton.tintColor = [UIColor grayColor];
    self.navigationItem.leftBarButtonItem = backButton;
    [self.navigationController.navigationBar setTitleTextAttributes:
     @{NSFontAttributeName:[UIFont fontWithName:@"QingYuanMono" size:18],
       NSForegroundColorAttributeName:[UIColor blackColor]}];
}

#pragma mark - TableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
    }
    NSDictionary *temp = [dataArray objectAtIndex:indexPath.row];
    NSNumber *feeNumber = temp[@"fee"];
    NSString *feeTime = temp[@"fee_time"];
    if ([feeNumber compare:[NSNumber numberWithInt:0]] == 1) {
        // 充值或奖励
        NSString *moneyMode = @"充值\n";
        NSString *payTime = [moneyMode stringByAppendingString:feeTime];
//        cell.textLabel.text = payTime;
        NSMutableAttributedString *payTimeContent = [[NSMutableAttributedString alloc] initWithString:payTime];
        NSMutableParagraphStyle *paragragraphStyle = [[NSMutableParagraphStyle alloc] init];
        [paragragraphStyle setLineSpacing:2];
        [payTimeContent addAttribute:NSParagraphStyleAttributeName value:paragragraphStyle range:NSMakeRange(0, [payTime length])];
        cell.textLabel.attributedText = payTimeContent;
        
        NSString *feeTemp = [NSString stringWithFormat:@"%@", feeNumber];
        cell.detailTextLabel.text = [@"\n" stringByAppendingString:feeTemp];
    }else {
        // 支出
        NSString *moneyMode = @"消费\n";
        NSString *payTime = [moneyMode stringByAppendingString:feeTime];
//        cell.textLabel.text = payTime;
        NSMutableAttributedString *payTimeContent = [[NSMutableAttributedString alloc] initWithString:payTime];
        /** 设置行间距*/
        NSMutableParagraphStyle *paragragraphStyle = [[NSMutableParagraphStyle alloc] init];
        [paragragraphStyle setLineSpacing:2];
        [payTimeContent addAttribute:NSParagraphStyleAttributeName value:paragragraphStyle range:NSMakeRange(0, [payTime length])];
        cell.textLabel.attributedText = payTimeContent;
        
        
        NSString *feeTemp = [NSString stringWithFormat:@"%@", feeNumber];
        cell.detailTextLabel.text = [@"\n" stringByAppendingString:feeTemp];
    }
    cell.textLabel.numberOfLines = 0;
    cell.detailTextLabel.numberOfLines = 0;
    cell.textLabel.font = [UIFont fontWithName:@"QingYuanMono" size:12];
    cell.detailTextLabel.font = [UIFont fontWithName:@"QingYuanMono" size:14];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cellHeight = cell.frame.size.height;
    
    cell.contentView.backgroundColor = [UIColor colorWithRed:240.0/255 green:240.0/255 blue:240.0/255 alpha:1];
    
    [tableView setSeparatorColor:[UIColor colorWithRed:165.0/255 green:165.0/255 blue:165.0/255 alpha:1]];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
   return 0.057*SCREEN_HEIGHT;
}

#pragma mark - 设置头视图
/** 设置section头视图*/
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, tableView.frame.size.height)];
    view.backgroundColor = [UIColor colorWithRed:240.0/255 green:240.0/255 blue:240.0/255 alpha:1];
    //    balanceDetailsLabel.frame = CGRectMake(0.05*SCREEN_WIDTH, STATUS_HEIGHT*3+NAVIGATIONBAR_HEIGHT+BALANCEIMAGEVIEW_HEIGHT+RECHARGEBUTTON_HEIGHT, BALANCEDETAILSLABEL_WIDTH, BALANCEDETAILSLABEL_HEIGHT);
    balanceDetailsLabel.frame = CGRectMake(0, 0.012*SCREEN_HEIGHT, BALANCEDETAILSLABEL_WIDTH, BALANCEDETAILSLABEL_HEIGHT);
    //    balanceDetailsLabel.numberOfLines = 0;
    balanceDetailsLabel.text = @"————————————  余额明细  ————————————";
    balanceDetailsLabel.textAlignment = NSTextAlignmentCenter;
    balanceDetailsLabel.font = [UIFont fontWithName:@"QingYuanMono" size:11];
    balanceDetailsLabel.textColor = [UIColor grayColor];
    if (SCREEN_WIDTH == 320) {
        balanceDetailsLabel.text = @"——————————  余额明细  ——————————";
    }
    if (iPhone6P) {
        balanceDetailsLabel.text = @"—————————————  余额明细  —————————————";
    }
    balanceDetailsLabel.tintColor = [UIColor colorWithRed:177.0/255 green:177.0/255 blue:177.0/255 alpha:1];
    [view addSubview:balanceDetailsLabel];
    return view;
}


-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return BALANCEDETAILSLABEL_HEIGHT;
}





#pragma mark - UIScrollDelegate
//- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
////    if (scrollView.contentOffset.y >= dataArray.count*cellHeight-DETAILSTABLEVIEW_HEIGHT+50){
//        // 需要更多的数据
////        if (dataArray.count >= 10 && isNone == NO) {
//    NSLog(@"y:%f", scrollView.contentOffset.y);
//    NSLog(@"dataarray.count:%d", dataArray.count);
//    NSLog(@"cellheight:%f", cellHeight);
//        if (scrollView.contentOffset.y > dataArray.count*cellHeight-DETAILSTABLEVIEW_HEIGHT+30 && scrollView.contentOffset.y < dataArray.count*cellHeight-DETAILSTABLEVIEW_HEIGHT+50) {
//            [footView setRefreshStateLoose];
//        }
////        }
////    }
//}

//- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerat {
//    if ( scrollView.contentOffset.y >= dataArray.count*cellHeight-DETAILSTABLEVIEW_HEIGHT+60) {
////        if (dataArray.count >= 10 && isNone == NO) {
//        NSLog(@"当前的state:%@", footView.state);
//            if ([footView.state isEqualToString:@"loose"] || [footView.state isEqualToString:@"none"]) {
//                [footView setRefreshStateLoading];
//                [self requestForData];
//        NSLog(@"动画");
//            }
////        }
//    }
//}

#pragma mark - 服务器请求
- (void)requestForData {
    NSString *phoneNumber = [userDefaults objectForKey:@"phoneNumber"];
    // 请求服务器 异步post
    NSString *urlStr = [IP stringByAppendingString:@"/api/money/balancelist"];
    NSURL *url = [NSURL URLWithString:urlStr];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    NSString *dataStr = [NSString stringWithFormat:@"phone=%@&count=%d&access_token=%@", phoneNumber, 0, [userDefaults objectForKey:@"accessToken"]];
    NSLog(@"phonenumber:%@", phoneNumber);
    NSData *data = [dataStr dataUsingEncoding:NSUTF8StringEncoding];
    [request setHTTPBody:data];
    [request setHTTPMethod:@"POST"];
    MyURLConnection *connection = [[MyURLConnection alloc] MyConnectioin:request delegate:self andName:@"getBalanceList"];
}

- (void)requestForBalance {
    NSString *phoneNumber = [userDefaults objectForKey:@"phoneNumber"];
    // 在登录了的情况下 去服务器获取余额
    // 只能用同步post 不然的话余额获取会有问题
    NSString *urlStr = [IP stringByAppendingString:@"/api/money/balance"];
    NSURL *url = [NSURL URLWithString:urlStr];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10];
    NSString *dataStr = [NSString stringWithFormat:@"phone=%@&access_token=%@", phoneNumber, [userDefaults objectForKey:@"accessToken"]];
    NSData *data = [dataStr dataUsingEncoding:NSUTF8StringEncoding];
    [request setHTTPBody:data];
    [request setHTTPMethod:@"POST"];
    MyURLConnection *connection = [[MyURLConnection alloc] MyConnectioin:request delegate:self andName:@"getBalance"];
}

#pragma mark - 服务器返回数据
- (void)MyConnection:(MyURLConnection *)connection didReceiveData:(NSData *)data {
    if ([connection.name isEqualToString:@"getBalanceList"]) {
        NSLog(@"收到数据");
        [cover removeFromSuperview];
        NSDictionary *receiveData = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
        NSString *status = receiveData[@"status"];
        NSString *message = receiveData[@"message"];
        NSArray *receiveArray = receiveData[@"data"];
        NSLog(@"receiveArray数据：%@", receiveArray);
        if ([status isEqualToString:@"success"]) {
            isNone = NO;
            if (page == 0) {
                dataArray = [NSMutableArray arrayWithArray:receiveArray];
                NSLog(@"page = 0 dataarray.count:%lu", (unsigned long)dataArray.count);
            }else {
                [dataArray addObjectsFromArray:receiveArray];
            }
            [detailsTableView reloadData];
            if (receiveArray.count == 10) {
            }
        }else {
            if ([message rangeOfString:@"invalid token"].location != NSNotFound) {
                // 账号在别的地方登陆
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"您的身份验证已过期，请重新登录" delegate:self cancelButtonTitle:@"好的" otherButtonTitles:nil, nil];
                alertView.tag = 10;
                [alertView show];
            }else {
               isNone = YES;
            }
        }
    }else if([connection.name isEqualToString:@"getBalance"]){
        NSDictionary *receiveData = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
        NSString *status = receiveData[@"status"];
        NSString *message = receiveData[@"message"];
        if ([status isEqualToString:@"success"]) {
            NSString *balance = receiveData[@"balance"];
            // 并且通知
            myAppDelegate.balance = [NSString stringWithFormat:@"%.2f", [balance floatValue]];
            balanceLabel.text = myAppDelegate.balance;
            [userDefaults setObject:myAppDelegate.balance forKey:@"balance"];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"balanceUpdate" object:nil];
        }else {
            if ([message rangeOfString:@"invalid token"].location != NSNotFound) {
                // 账号在别的地方登陆
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"您的身份验证已过期，请重新登录" delegate:self cancelButtonTitle:@"好的" otherButtonTitles:nil, nil];
                alertView.tag = 10;
                [alertView show];
            }
        }
    }
}

#pragma mark - 服务器超时
- (void)MyConnection:(MyURLConnection *)connection didFailWithError:(NSError *)error {
    [cover removeFromSuperview];
    cover = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    cover.alpha = 1;
    // 半黑膜
    UIView *containerView = [[UIView alloc] initWithFrame:CGRectMake(0.3*SCREEN_WIDTH, 0.4*SCREEN_HEIGHT, 0.4*SCREEN_WIDTH, 0.15*SCREEN_HEIGHT)];
    containerView.backgroundColor = [UIColor blackColor];
    containerView.alpha = 0.8;
    containerView.layer.cornerRadius = CORNERRADIUS*2;
    [cover addSubview:containerView];
    // 一个控件
    UILabel *hintMes1 = [[UILabel alloc] initWithFrame:CGRectMake(0, 0.4*containerView.frame.size.height, containerView.frame.size.width, 0.2*containerView.frame.size.height)];
    hintMes1.text = @"请检查您的网络";
    hintMes1.textColor = [UIColor whiteColor];
    hintMes1.textAlignment = NSTextAlignmentCenter;
    [containerView addSubview:hintMes1];
    [self.view addSubview:cover];
    // 显示时间
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(removeView) userInfo:nil repeats:NO];
    [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
    NSLog(@"网络超时");
}

- (void)removeView {
    [cover removeFromSuperview];
}

#pragma mark - alertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == 10) {
        myAppDelegate.isLogout = YES;
        // 退出登录
        myAppDelegate.isIdentify = NO;
        myAppDelegate.isFreeze = NO;
        myAppDelegate.isEndPay = YES;
        myAppDelegate.isEndRiding = YES;
        myAppDelegate.isRestart = NO;
        myAppDelegate.isMissing = NO;
        myAppDelegate.isUpload = NO;
        myAppDelegate.isLogin = NO;
        myAppDelegate.isLogout = YES;
        myAppDelegate.isLinked = YES;
        [userDefaults setBool:NO forKey:@"isLogin"];
        [userDefaults setBool:NO forKey:@"isVip"];
        [userDefaults setObject:@"" forKey:@"name"];
        [userDefaults setObject:@"" forKey:@"stunum"];
        [userDefaults setObject:@"" forKey:@"college"];
        [userDefaults setBool:NO forKey:@"isMessage"];
        [[SDImageCache sharedImageCache] removeImageForKey:@"学生证" fromDisk:YES];
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
}

#pragma mark - Button Event
- (void)RechargeView {
    RechargeViewController *rechargeViewController = [[RechargeViewController alloc] init];
    [self.navigationController pushViewController:rechargeViewController animated:YES];
}

- (void)back {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = BACKGROUNDCOLOR;
    [self UIInit];
    
}

- (void)viewWillAppear:(BOOL)animated {
    balanceLabel.text = myAppDelegate.balance;
}

- (void)viewDidAppear:(BOOL)animated {
    // 集成api  此处是膜
    cover = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    cover.alpha = 1;
    // 半黑膜
    UIView *containerView = [[UIView alloc] initWithFrame:CGRectMake(0.3*SCREEN_WIDTH, 0.4*SCREEN_HEIGHT, 0.4*SCREEN_WIDTH, 0.15*SCREEN_HEIGHT)];
    containerView.backgroundColor = [UIColor blackColor];
    containerView.alpha = 0.8;
    containerView.layer.cornerRadius = CORNERRADIUS*2;
    [cover addSubview:containerView];
    // 两个控件
    UIActivityIndicatorView *waitActivityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    waitActivityView.frame = CGRectMake(0.33*containerView.frame.size.width, 0.3*containerView.frame.size.width, 0.33*containerView.frame.size.width, 0.4*containerView.frame.size.height);
    [waitActivityView startAnimating];
    [containerView addSubview:waitActivityView];
    [self.view addSubview:cover];
    
    [self EventInit];
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
