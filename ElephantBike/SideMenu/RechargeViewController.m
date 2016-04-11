//
//  RechargeViewController.m
//  ElephantBike
//
//  Created by 黄杰锋 on 16/1/21.
//  Copyright © 2016年 黄杰锋. All rights reserved.
//

#import "RechargeViewController.h"
#import "UISize.h"
#import "MyTableViewCell.h"
#import "AppDelegate.h"
#import "MyURLConnection.h"


#pragma mark - 微信支付
#import "WXApi.h"
#import <CommonCrypto/CommonDigest.h>
#import "WXApiObject.h"

#pragma mark - 支付宝
#import "AlipaySDK/AlipaySDK.h"
#import "Order.h"
#import "DataSigner.h"
#import "APAuthV2Info.h"

#define PAYLISTTABLEVIEW_WIDTH  SCREEN_WIDTH
#define PAYLISTTABLEVIEW_HEIGHT 0.176*SCREEN_HEIGHT
#define CONTAINERVIEW_WIDTH     SCREEN_WIDTH
#define CONTAINERVIEW_HEIGHT    SCREEN_HEIGHT*0.09
#define MONEYLABEL_WIDTH        SCREEN_WIDTH*0.3
#define MONEYLABEL_HEIGHT       SCREEN_HEIGHT*0.09
#define MONEYTF_WIDTH           0.7*SCREEN_WIDTH
#define MONEYTF_HEIGHT          MONEYLABEL_HEIGHT
#define NEXTBUTTON_WIDTH        0.8*SCREEN_WIDTH
#define NEXTBUTTON_HEIGHT       0.056*SCREEN_HEIGHT

@interface RechargeViewController () <UITableViewDataSource, UITableViewDelegate, MyURLConnectionDelegate, PayDelegate>

@end

@implementation RechargeViewController {
    UITableView *payListTableView;
    UIView      *containerView;
    UILabel     *moneyLabel;
    UITextField *moneyTF;
    UIButton    *nextButton;
    
    NSArray     *payWay;
    NSArray     *wayDetails;
    
    UIView      *cover;
    
    NSUserDefaults *userDefaults;
    
    AppDelegate *myAppdelegate;
    
    BOOL        isConnect;
    NSString    *outTradeNo;    // 支付宝订单号
}

- (void)UIInit {
    payListTableView    = [[UITableView alloc] init];
    containerView       = [[UIView alloc] init];
    moneyLabel          = [[UILabel alloc] init];
    moneyTF             = [[UITextField alloc] init];
    nextButton          = [[UIButton alloc] init];
    
    payWay              = @[@"微信支付", @"支付宝"];
    wayDetails          = @[@"推荐微信支付已绑定信用卡的用户使用", @"推荐已安装支付宝客户端的用户使用"];
    userDefaults        = [NSUserDefaults standardUserDefaults];
    myAppdelegate       = [[UIApplication sharedApplication] delegate];
    myAppdelegate.myDelegate = self;
    isConnect           = NO;
    
    [self NavigationInit];
    [self UILayout];
}

- (void)UILayout {
    payListTableView.frame = CGRectMake(0, STATUS_HEIGHT+NAVIGATIONBAR_HEIGHT+0.015*SCREEN_HEIGHT, PAYLISTTABLEVIEW_WIDTH, PAYLISTTABLEVIEW_HEIGHT);
    payListTableView.dataSource = self;
    payListTableView.delegate = self;
    payListTableView.scrollEnabled = NO;
    
    containerView.frame = CGRectMake(0, STATUS_HEIGHT+NAVIGATIONBAR_HEIGHT+0.015*2*SCREEN_HEIGHT+PAYLISTTABLEVIEW_HEIGHT, CONTAINERVIEW_WIDTH, CONTAINERVIEW_HEIGHT);
    containerView.layer.borderWidth = 1;
    containerView.layer.borderColor = [UIColor grayColor].CGColor;
    
    moneyLabel.frame = CGRectMake(0, 0, MONEYLABEL_WIDTH, MONEYLABEL_HEIGHT);
    moneyLabel.text = @"金额（元）";
    moneyLabel.font = [UIFont fontWithName:@"QingYuanMono" size:16];
    moneyLabel.textAlignment = NSTextAlignmentCenter;
    
    moneyTF.frame = CGRectMake(MONEYLABEL_WIDTH, 0, MONEYTF_WIDTH, MONEYTF_HEIGHT);
    [moneyTF addTarget:self action:@selector(TextFieldChanged) forControlEvents:UIControlEventEditingChanged];
    moneyTF.placeholder = @"请输入金额";
    moneyTF.font = [UIFont fontWithName:@"QingYuanMono" size:16];
    moneyTF.keyboardType = UIKeyboardTypeNumberPad;
    
    nextButton.frame = CGRectMake((SCREEN_WIDTH-NEXTBUTTON_WIDTH)/2, STATUS_HEIGHT+NAVIGATIONBAR_HEIGHT+SAME_HEIGHT*2+PAYLISTTABLEVIEW_HEIGHT+MONEYTF_HEIGHT, NEXTBUTTON_WIDTH, NEXTBUTTON_HEIGHT);
    nextButton.enabled = NO;
    nextButton.backgroundColor = [UIColor grayColor];
    [nextButton setTitle:@"下一步" forState:UIControlStateNormal];
    nextButton.titleLabel.font = [UIFont fontWithName:@"QingYuanMono" size:14];
    nextButton.layer.cornerRadius = CORNERRADIUS;
    [nextButton addTarget:self action:@selector(recharge) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:payListTableView];
    [self.view addSubview:containerView];
    [containerView addSubview:moneyLabel];
    [containerView addSubview:moneyTF];
    [self.view addSubview:nextButton];
    
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showSuccess) name:@"rechargeSuccess" object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showFail) name:@"rechargeFail" object:nil];
}

- (void)NavigationInit {
    self.navigationItem.title = @"钱包充值";
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"返回"] style:UIBarButtonItemStylePlain target:self action:@selector(back)];
    backButton.tintColor = [UIColor grayColor];
    self.navigationItem.leftBarButtonItem = backButton;
}

#pragma mark - Button Event
- (void)back {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)recharge {
    //验证等待动画
    // 集成api  此处是膜
    cover = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    cover.alpha = 1;
    // 半黑膜
    UIView *containerView1 = [[UIView alloc] initWithFrame:CGRectMake(0.3*SCREEN_WIDTH, 0.4*SCREEN_HEIGHT, 0.4*SCREEN_WIDTH, 0.15*SCREEN_HEIGHT)];
    containerView1.backgroundColor = [UIColor blackColor];
    containerView1.alpha = 0.8;
    containerView1.layer.cornerRadius = CORNERRADIUS*2;
    [cover addSubview:containerView1];
    // 两个控件
    UIActivityIndicatorView *waitActivityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    waitActivityView.frame = CGRectMake(0.33*containerView1.frame.size.width, 0.1*containerView1.frame.size.width, 0.33*containerView1.frame.size.width, 0.4*containerView1.frame.size.height);
    [waitActivityView startAnimating];
    [containerView1 addSubview:waitActivityView];
    
    UILabel *hintMes = [[UILabel alloc] initWithFrame:CGRectMake(0, 0.7*containerView1.frame.size.height, containerView1.frame.size.width, 0.2*containerView1.frame.size.height)];
    hintMes.text = @"请稍后...";
    hintMes.textColor = [UIColor whiteColor];
    hintMes.textAlignment = NSTextAlignmentCenter;
    [containerView1 addSubview:hintMes];
    [self.view addSubview:cover];
    
    [moneyTF resignFirstResponder];
    
    NSIndexPath *rechargeIndexPath = [payListTableView indexPathForSelectedRow];
    // 微信支付
    if (rechargeIndexPath.row == 0) {
        // 微信支付
        // 请求api 获取预付单
        myAppdelegate.isWXPay = YES;
        NSString *phoneNumber = [userDefaults objectForKey:@"phoneNumber"];
        NSString *urlStr = [IP stringByAppendingString:@"/ElephantBike/api/pay/wxpayorder"];
        NSURL *url = [NSURL URLWithString:urlStr];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10];
        NSString *dataStr = [NSString stringWithFormat:@"phone=%@&totalfee=%@", phoneNumber, moneyTF.text];
        NSData *data = [dataStr dataUsingEncoding:NSUTF8StringEncoding];
        [request setHTTPBody:data];
        [request setHTTPMethod:@"POST"];
        MyURLConnection *connection = [[MyURLConnection alloc] MyConnectioin:request delegate:self andName:@"getPrepay"];
    }else {
        // 支付宝
        // 支付宝充值成功，向服务器提交数据
        // 获取缓存数据
        myAppdelegate.isWXPay = NO;
        NSString *phoneNumber = [userDefaults objectForKey:@"phoneNumber"];
        
        // 异步请求服务器
        NSString *urlStr = [IP stringByAppendingString:@"/ElephantBike/api/pay/alipayrecharge"];
        NSURL *url = [NSURL URLWithString:urlStr];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10];
        NSString *dataStr = [NSString stringWithFormat:@"phone=%@&subject=%@&body=%@&totalfee=%@", phoneNumber, @"大象钱包充值", @"多少钱", moneyTF.text];
        NSData *data = [dataStr dataUsingEncoding:NSUTF8StringEncoding];
        [request setHTTPBody:data];
        [request setHTTPMethod:@"POST"];
        MyURLConnection *connection = [[MyURLConnection alloc] MyConnectioin:request delegate:self andName:@"getAlipay"];
    }
    
    
}

#pragma mark - 服务器返回
- (void)MyConnection:(MyURLConnection *)connection didReceiveData:(NSData *)data{
    [cover removeFromSuperview];
    NSDictionary *receiveJson = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
    NSString *status = receiveJson[@"status"];
    NSString *message = receiveJson[@"message"];
    if ([connection.name isEqualToString:@"getPrepay"]) {
        if ([status isEqualToString:@"success"]) {
            PayReq *request = [[PayReq alloc] init];
            request.openID = receiveJson[@"appid"];
            request.partnerId = receiveJson[@"partnerid"];
            request.prepayId= receiveJson[@"prepayid"];
            request.package = receiveJson[@"package"];
            request.nonceStr= receiveJson[@"noncestr"];
            request.timeStamp= [receiveJson[@"timestamp"] intValue];
            request.sign = receiveJson[@"sign"];
            NSLog(@"appid:%@\npartnerid:%@\nprepayid:%@\npackage:%@\nonceStr:%@\ntimestamp:%d\nsign:%@", request.openID, request.partnerId, request.prepayId, request.package, request.nonceStr, (unsigned int)request.timeStamp, request.sign);
            [WXApi sendReq:request];
        }else {
            NSLog(@"微信预付获取失败");
        }
    }else if ([connection.name isEqualToString:@"wxcheck"]) {
        NSLog(@"充值返回");
        NSLog(@"status:%@", status);
        if ([status isEqualToString:@"success"]) {
            // 充值成功 跳转我的钱包页面 并且本地的金额加上来
            CGFloat balan = [myAppdelegate.balance floatValue];
            CGFloat money = [moneyTF.text floatValue];
            balan += money;
            myAppdelegate.balance = [NSString stringWithFormat:@"%.2f", balan];
            [userDefaults setObject:myAppdelegate.balance forKey:@"balance"];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"balanceUpdate" object:nil];
            
            // 充值成功动画再做修改
            cover = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
            cover.alpha = 1;
            UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"充值成功"]];
            imageView.center = cover.center;
            [cover addSubview:imageView];
            [self.view addSubview:cover];
            NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(dismissImageView) userInfo:nil repeats:NO];
            [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
        }else {
            // 充值失败
            isConnect = YES;
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"充值失败，请重试" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alertView show];
        }
    }else if([connection.name isEqualToString:@"getAlipay"]) {
        NSString *appScheme = @"alisdkdemo";
        NSString *param = receiveJson[@"param"];
        NSString *sign = receiveJson[@"sign"];
        NSString *sign_type = receiveJson[@"sign_type"];
        outTradeNo = receiveJson[@"out_trade_no"];
        NSString *orderString = nil;
        orderString = [NSString stringWithFormat:@"%@&sign=\"%@\"&sign_type=\"%@\"", param,  sign, sign_type];
        
        [[AlipaySDK defaultService] payOrder:orderString fromScheme:appScheme callback:^(NSDictionary *resultDic) {
            NSLog(@"result=%@", resultDic);
        }];
    }else if ([connection.name isEqualToString:@"alipaycheck"]) {
        NSString *status = receiveJson[@"status"];
        NSLog(@"%@", status);
        [cover removeFromSuperview];
        if ([status isEqualToString:@"success"]) {
            // 充值成功 跳转我的钱包页面 并且本地的金额加上来
            CGFloat balan = [myAppdelegate.balance floatValue];
            CGFloat money = [moneyTF.text floatValue];
            balan += money;
            myAppdelegate.balance = [NSString stringWithFormat:@"%.2f", balan];
            [userDefaults setObject:myAppdelegate.balance forKey:@"balance"];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"balanceUpdate" object:nil];
            
            // 充值成功动画再做修改
            cover = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
            cover.alpha = 1;
            UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"充值成功"]];
            imageView.center = cover.center;
            [cover addSubview:imageView];
            [self.view addSubview:cover];
            NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(dismissImageView) userInfo:nil repeats:NO];
            [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
        }else {
            // 付款失败
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"充值失败，请重试" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alertView show];
        }
    }
}

- (void)MyConnection:(MyURLConnection *)connection didFailWithError:(NSError *)error {
    [cover removeFromSuperview];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"网络超时" delegate:nil cancelButtonTitle:@"知道了" otherButtonTitles:nil, nil];
    [alertView show];
}

- (void)stopRequest {
    if (!isConnect) {
        [cover removeFromSuperview];
        // 收到验证码  进行提示
        cover = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        cover.alpha = 1;
        // 半黑膜
        UIView *containerView1 = [[UIView alloc] initWithFrame:CGRectMake(0.3*SCREEN_WIDTH, 0.4*SCREEN_HEIGHT, 0.4*SCREEN_WIDTH, 0.15*SCREEN_HEIGHT)];
        containerView1.backgroundColor = [UIColor blackColor];
        containerView1.alpha = 0.8;
        containerView1.layer.cornerRadius = CORNERRADIUS*2;
        containerView1.backgroundColor = [UIColor whiteColor];
        [cover addSubview:containerView1];
        // 一个控件
        UILabel *hintMes = [[UILabel alloc] initWithFrame:CGRectMake(0, 0.4*containerView1.frame.size.height, containerView1.frame.size.width, 0.2*containerView1.frame.size.height)];
        hintMes.text = @"无法连接服务器";
        hintMes.textColor = [UIColor whiteColor];
        hintMes.textAlignment = NSTextAlignmentCenter;
        [containerView1 addSubview:hintMes];
        [self.view addSubview:cover];
        // 显示时间
        NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(removeView) userInfo:nil repeats:NO];
        [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
    }
    isConnect = NO;
}

- (void)removeView {
    [cover removeFromSuperview];
}



- (void)dismissImageView {
    [cover removeFromSuperview];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - TableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"Cell";
    MyTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[MyTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    }
    cell.imageView.image = [UIImage imageNamed:[payWay objectAtIndex:indexPath.row]];
    //设置imaged大小
    CGSize itemSize = CGSizeMake(PAYLISTTABLEVIEW_HEIGHT/2*0.8, PAYLISTTABLEVIEW_HEIGHT/2*0.8);
    UIGraphicsBeginImageContext(itemSize);
    CGRect imageRect = CGRectMake(0.0, 0.0, itemSize.width, itemSize.height);
    [cell.imageView.image drawInRect:imageRect];
    cell.imageView.image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    cell.textLabel.text = [payWay objectAtIndex:indexPath.row];
    cell.detailTextLabel.text = [wayDetails objectAtIndex:indexPath.row];
    if (indexPath.row == 0) {
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"选项选中打钩"]];
        cell.accessoryView =imageView;
    }else {
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"选项未选中打钩"]];
        cell.accessoryView = imageView;
    }
    cell.textLabel.font = [UIFont fontWithName:@"QingYuanMono" size:16];
    cell.detailTextLabel.font = [UIFont fontWithName:@"QingYuanMono" size:10];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    MyTableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    NSArray *array = [tableView visibleCells];
    for (UITableViewCell *cell in array) {
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"选项未选中打钩"]];
        cell.accessoryView = imageView;
    }
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"选项选中打钩"]];
    cell.accessoryView =imageView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return PAYLISTTABLEVIEW_HEIGHT/2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0;
}

#pragma mark - payDelegate
- (void)isWXPay {
    NSString *urlStr = [IP stringByAppendingString:@"/ElephantBike/api/pay/wxorderquery"];
    NSURL *url = [NSURL URLWithString:urlStr];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10];
    NSString *phoneNumber = [userDefaults objectForKey:@"phoneNumber"];
    NSString *dataStr = [NSString stringWithFormat:@"phone=%@", phoneNumber];
    NSData *data = [dataStr dataUsingEncoding:NSUTF8StringEncoding];
    [request setHTTPBody:data];
    [request setHTTPMethod:@"POST"];
    MyURLConnection *connectionn = [[MyURLConnection alloc] MyConnectioin:request delegate:self andName:@"wxcheck"];
    NSLog(@"返回支付结果recharge");
}

- (void)isAliPay {
    NSString *urlStr = [IP stringByAppendingString:@"/ElephantBike/api/pay/alipayquery"];
    NSURL *url = [NSURL URLWithString:urlStr];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10];
    NSString *dataStr = [NSString stringWithFormat:@"out_trade_no=%@", outTradeNo];
    NSData *data = [dataStr dataUsingEncoding:NSUTF8StringEncoding];
    [request setHTTPBody:data];
    [request setHTTPMethod:@"POST"];
    MyURLConnection *connectionn = [[MyURLConnection alloc] MyConnectioin:request delegate:self andName:@"alipaycheck"];
    NSLog(@"返回支付结果rechargeview");
}

#pragma mark - 私有方法
/*
- (void)showSuccess {
    [cover removeFromSuperview];
    myAppdelegate.isEndPay = YES;
    // 付款成功
    cover = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    cover.alpha = 1;
    // 半黑膜
    UIView *containerView1 = [[UIView alloc] initWithFrame:CGRectMake(0.3*SCREEN_WIDTH, 0.4*SCREEN_HEIGHT, 0.4*SCREEN_WIDTH, 0.15*SCREEN_HEIGHT)];
    containerView1.backgroundColor = [UIColor blackColor];
    containerView1.alpha = 0.8;
    containerView1.layer.cornerRadius = CORNERRADIUS*2;
    [cover addSubview:containerView1];
    // 一个控件
    UILabel *hintMes1 = [[UILabel alloc] initWithFrame:CGRectMake(0, 0.4*containerView1.frame.size.height, containerView1.frame.size.width, 0.2*containerView1.frame.size.height)];
    hintMes1.text = @"充值成功";
    hintMes1.textColor = [UIColor whiteColor];
    hintMes1.textAlignment = NSTextAlignmentCenter;
    [containerView1 addSubview:hintMes1];
    [self.view addSubview:cover];
    // 显示时间
    
    // 微信/支付宝充值成功，向服务器提交数据
    // 获取缓存数据
    NSString *phoneNumber = [userDefaults objectForKey:@"phoneNumber"];
    NSString *accessToken = [userDefaults objectForKey:@"accessToken"];
    
    // 异步请求服务器
    NSString *urlStr = [IP stringByAppendingString:@"/ElephantBike/api/money/recharge"];
    NSURL *url = [NSURL URLWithString:urlStr];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10];
    NSString *dataStr = [NSString stringWithFormat:@"phone=%@&value=%@&access_token=%@", phoneNumber, moneyTF.text, accessToken];
    NSData *data = [dataStr dataUsingEncoding:NSUTF8StringEncoding];
    [request setHTTPBody:data];
    [request setHTTPMethod:@"POST"];
    MyURLConnection *connection = [[MyURLConnection alloc] MyConnectioin:request delegate:self andName:@"recharge"];
}

- (void)showFail {
    [cover removeFromSuperview];
    myAppdelegate.isEndPay = YES;
    // 付款失败
    cover = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    cover.alpha = 1;
    // 半黑膜
    UIView *containerView1 = [[UIView alloc] initWithFrame:CGRectMake(0.3*SCREEN_WIDTH, 0.4*SCREEN_HEIGHT, 0.4*SCREEN_WIDTH, 0.15*SCREEN_HEIGHT)];
    containerView1.backgroundColor = [UIColor blackColor];
    containerView1.alpha = 0.8;
    containerView1.layer.cornerRadius = CORNERRADIUS*2;
    [cover addSubview:containerView1];
    // 一个控件
    UILabel *hintMes1 = [[UILabel alloc] initWithFrame:CGRectMake(0, 0.4*containerView1.frame.size.height, containerView1.frame.size.width, 0.2*containerView1.frame.size.height)];
    hintMes1.text = @"充值失败";
    hintMes1.textColor = [UIColor whiteColor];
    hintMes1.textAlignment = NSTextAlignmentCenter;
    [containerView1 addSubview:hintMes1];
    [self.view addSubview:cover];
    // 显示时间
    
    NSTimer *gotoQRScanTimer = [NSTimer timerWithTimeInterval:2 target:self selector:@selector(removeView) userInfo:nil repeats:NO];
    [[NSRunLoop mainRunLoop] addTimer:gotoQRScanTimer forMode:NSDefaultRunLoopMode];
}
*/
#pragma mark - TextField Changed
- (void)TextFieldChanged {
    if ([moneyTF.text isEqualToString:@""]) {
        nextButton.enabled = NO;
        nextButton.backgroundColor = [UIColor grayColor];
    }else {
        nextButton.enabled = YES;
        nextButton.backgroundColor = UICOLOR;
    }
}

#pragma mark - TouchesBegin
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if ([moneyTF isFirstResponder]) {
        [moneyTF resignFirstResponder];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = BACKGROUNDCOLOR;
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self UIInit];
    myAppdelegate.isMoneyView = YES;
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    myAppdelegate.isMoneyView = NO;
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
