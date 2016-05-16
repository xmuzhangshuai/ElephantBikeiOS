//
//  MemberPayViewController.m
//  ElephantBike
//
//  Created by 黄杰锋 on 16/3/31.
//  Copyright © 2016年 黄杰锋. All rights reserved.
//

#import "MemberPayViewController.h"
#import "UISize.h"
#import "MyTableViewCell.h"
#import "OpenMemberViewController.h"
#import "AppDelegate.h"
#import "MyURLConnection.h"
#import "QRCodeScanViewController.h"
#import "ChargeViewController.h"
#import "PayViewController.h"

#pragma mark - 微信支付
#import "WXApi.h"
#import <CommonCrypto/CommonDigest.h>
#import "WXApiObject.h"

/**
 *  支付宝支付
 **/
#import "AlipaySDK/AlipaySDK.h"
#import "Order.h"
#import "DataSigner.h"
#import "APAuthV2Info.h"

#define ORDERDETAILVIEW_WIDTH  SCREEN_WIDTH
#define ORDERDETAILVIEW_HEIGHT 0.172*SCREEN_HEIGHT

#define ELEPHANTLOGO_WIDTH  0.243*SCREEN_WIDTH
#define ELEPHANTLOGO_HEIGHT 0.135*SCREEN_HEIGHT

#define ORDERNAME_WIDTH     SCREEN_WIDTH-0.348*SCREEN_WIDTH
#define ORDERNAME_HEIGHT    0.14*ORDERDETAILVIEW_HEIGHT

#define MEMBERVALID_WIDTH
#define MEMBERVALID_HEIGHT

#define PREVILEGE_WIDTH
#define PREVILEGE_HEIGHT




@interface MemberPayViewController ()<UITableViewDataSource, UITableViewDelegate, OpenMemberDelegate, MyURLConnectionDelegate, PayDelegate>

@end

@implementation MemberPayViewController{
    /** 订单详情View*/
    UIView *OrderDetailView;
    /** 大象图标*/
    UIImageView *ElephantLogo;
    /** 订单名称*/
    UILabel *OrderName;
    /** 金额*/
    UILabel *OrderMoney;
    /** 会员有效期*/
    UILabel *MemberValid;
    /** 特权*/
    UILabel *Previlege;
    /** 支付tableView*/
    UITableView *payListTableView;
    /** 确认按钮*/
    UIButton *confirmButton;
    /** 支付方式*/
    NSArray     *payWay;
    /** 支付详细介绍*/
    NSArray     *wayDetails;
    AppDelegate *myAppDelegate;
    NSUserDefaults *userDefaults;
    UIView      *waitCover;
    NSString    *money;
    NSString    *Month;
    NSString    *outTradeNO;    // 存放订单号（微信或支付宝
    NSString    *WXOutTradeNo;  // 微信订单号
}

- (id)init {
    if ([super init]) {
        myAppDelegate = [[UIApplication sharedApplication] delegate];
        myAppDelegate.myDelegate = self;
        userDefaults = [NSUserDefaults standardUserDefaults];
        OrderDetailView = [[UIView alloc] init];
        ElephantLogo = [[UIImageView alloc] init];
        OrderName = [[UILabel alloc] init];
        OrderMoney = [[UILabel alloc] init];
        MemberValid = [[UILabel alloc] init];
        Previlege = [[UILabel alloc] init];
        payListTableView = [[UITableView alloc] init];
        confirmButton = [[UIButton alloc] init];
        waitCover = [[UIView alloc] initWithFrame:self.view.bounds];
    }
    return self;
}

-(void)UIInit{
    
    [confirmButton addTarget:self action:@selector(confirmMember) forControlEvents:UIControlEventTouchUpInside];
    
    payWay              = @[@"微信支付", @"支付宝"];
    wayDetails          = @[@"推荐微信支付已绑定信用卡的用户使用", @"推荐已安装支付宝客户端的用户使用"];
    
    [self NavigationInit];
    
}

-(void)NavigationInit{
    self.navigationItem.title = @"订单详情";
    [self.navigationController.navigationBar setTitleTextAttributes:
     @{NSFontAttributeName:[UIFont fontWithName:@"QingYuanMono" size:18],
       NSForegroundColorAttributeName:[UIColor blackColor]}];
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"返回"] style:UIBarButtonItemStylePlain target:self action:@selector(backEvent)];
    leftItem.tintColor = [UIColor grayColor];
    self.navigationItem.leftBarButtonItem = leftItem;
    
}


-(void)UILayout{
    OrderDetailView.frame = CGRectMake(0, 0, SCREEN_WIDTH, 0.172*SCREEN_HEIGHT);
    OrderDetailView.center = CGPointMake(0.5*SCREEN_WIDTH, 0.2*SCREEN_HEIGHT);
    OrderDetailView.backgroundColor = [UIColor colorWithRed:255.0/255 green:255.0/255 blue:255.0/255 alpha:1];
    
    ElephantLogo.frame = CGRectMake(0.044*SCREEN_WIDTH, 0.1*ORDERDETAILVIEW_HEIGHT, 0.243*SCREEN_WIDTH, 0.787*ORDERDETAILVIEW_HEIGHT);
    ElephantLogo.image = [UIImage imageNamed:@"订单详情LOGO"];
    
    
//    261,52  750*230
    OrderName.frame = CGRectMake(0.348*SCREEN_WIDTH, 0.21*ORDERDETAILVIEW_HEIGHT, SCREEN_WIDTH-0.348*SCREEN_WIDTH, 0.14*ORDERDETAILVIEW_HEIGHT);
    //    OrderName.backgroundColor = [UIColor greenColor];
    OrderName.font = [UIFont fontWithName:@"QingYuanMono" size:13];
    
    OrderMoney.frame = CGRectMake(0.348*SCREEN_WIDTH, OrderName.frame.origin.y+ORDERNAME_HEIGHT, ORDERNAME_WIDTH, ORDERNAME_HEIGHT);
    OrderMoney.font = [UIFont fontWithName:@"QingYuanMono" size:13];
    
    
    
    MemberValid.frame = CGRectMake(0.348*SCREEN_WIDTH, OrderMoney.frame.origin.y+OrderMoney.frame.size.height, ORDERNAME_WIDTH, ORDERNAME_HEIGHT);
    MemberValid.font = [UIFont fontWithName:@"QingYuanMono" size:12];
    
    
    Previlege.frame = CGRectMake(0.348*SCREEN_WIDTH, MemberValid.frame.origin.y+MemberValid.frame.size.height, ORDERNAME_WIDTH, ORDERNAME_HEIGHT);
    Previlege.text = @"特权：使用单车享0元起步费";
    Previlege.font = [UIFont fontWithName:@"QingYuanMono" size:13];
    
    payListTableView.frame = CGRectMake(0, 0.3*SCREEN_HEIGHT, SCREEN_WIDTH, 0.18*SCREEN_HEIGHT);
    payListTableView.dataSource = self;
    payListTableView.delegate = self;
    payListTableView.scrollEnabled = NO;
    [payListTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    payListTableView.layer.borderWidth = 1;
    payListTableView.layer.borderColor = [UIColor grayColor].CGColor;
    
    confirmButton.frame = CGRectMake(0, 0, 0.8*SCREEN_WIDTH, 0.056*SCREEN_HEIGHT);
    confirmButton.center = CGPointMake(0.5*SCREEN_WIDTH, 0.557*SCREEN_HEIGHT);
    [confirmButton setTitle:@"确认" forState:UIControlStateNormal];
    confirmButton.titleLabel.font = [UIFont fontWithName:@"QingYuanMono" size:14];
    confirmButton.tintColor = [UIColor whiteColor];
    confirmButton.backgroundColor = [UIColor colorWithRed:112.0/255 green:177.0/255 blue:52.0/255 alpha:1];
    confirmButton.layer.masksToBounds = YES;
    confirmButton.layer.cornerRadius = 6;
    
    
    
    self.view.backgroundColor = [UIColor colorWithRed:240.0/255 green:240.0/255 blue:240.0/255 alpha:1];
    [self.view addSubview:OrderDetailView];
    [self.view addSubview:payListTableView];
    [self.view addSubview:confirmButton];
    [OrderDetailView addSubview:ElephantLogo];
    [OrderDetailView addSubview:OrderName];
    [OrderDetailView addSubview:OrderMoney];
    [OrderDetailView addSubview:MemberValid];
    [OrderDetailView addSubview:Previlege];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showSuccess) name:@"paySuccess" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showFail) name:@"payFail" object:nil];
    
}

#pragma mark - 返回按钮事件
-(void)backEvent{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - tableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return  1;
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
//    设置imaged大小87*87  750*120
//    CGSize itemSize = CGSizeMake(0.18*SCREEN_HEIGHT/3*0.8, 0.18*SCREEN_HEIGHT/3*0.8);
     CGSize itemSize = CGSizeMake(0.116*payListTableView.frame.size.width, 0.18*SCREEN_HEIGHT/2*0.727);
    UIGraphicsBeginImageContext(itemSize);
    CGRect imageRect = CGRectMake(0.0, 0.0, itemSize.width, itemSize.height);
    [cell.imageView.image drawInRect:imageRect];
    cell.imageView.image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
//    cell.textLabel.text = [payWay objectAtIndex:indexPath.row];
//    cell.textLabel.font = [UIFont fontWithName:@"QingYuanMono" size:16];
//    cell.detailTextLabel.text = [wayDetails objectAtIndex:indexPath.row];
//    cell.detailTextLabel.font = [UIFont fontWithName:@"QingYuanMono" size:10];
    cell.textLabel.numberOfLines = 0;
    /** 设置成统一的label*/
    NSString *temp = [[payWay objectAtIndex:indexPath.row] stringByAppendingString:@"\n"];
    NSString *lastTemp = [temp stringByAppendingString:[wayDetails objectAtIndex:indexPath.row]];
    NSMutableAttributedString *cellcontent = [[NSMutableAttributedString alloc] initWithString:lastTemp];
    cell.textLabel.font = [UIFont fontWithName:@"QingYuanMono" size:11];
    if ([temp isEqualToString:@"支付宝"]) {
        [cellcontent addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"QingYuanMono" size:17] range:NSMakeRange(0, 3)];
    }else {
        [cellcontent addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"QingYuanMono" size:17] range:NSMakeRange(0, 4)];
    }
    /** 设置 行间距*/
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setLineSpacing:6];
    [cellcontent addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [lastTemp length])];
    cell.textLabel.attributedText = cellcontent;
    
    if (indexPath.row == 0) {
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"选项选中打钩"]];
        cell.accessoryView =imageView;
    }else {
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"选项未选中打钩"]];
        cell.accessoryView = imageView;
    }
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
    return 0.18*SCREEN_HEIGHT/2;
}

#pragma mark - OpenMemberDelegate
- (void)getMonth:(NSString *)month {
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"yyyy-MM-dd"];
    NSDate *today = [NSDate date];
    NSString *now = [df stringFromDate:today];
    if ([month isEqualToString:@"0"]) {
        Month = @"1";
        [OrderName setText:[NSString stringWithFormat:@"名称: 大象单车会员卡（%d个月）", 1]];
//        OrderMoney.text = @"金额: 3:00元";
        NSString *OrderMoneyStr = @"金额: 3:00元";
        NSMutableAttributedString *OrderMoneyContent = [[NSMutableAttributedString alloc] initWithString:OrderMoneyStr];
        [OrderMoneyContent addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:112.0/255 green:177.0/255 blue:52.0/255 alpha:1] range:NSMakeRange(3, [OrderMoneyStr length]-3)];
        OrderMoney.attributedText = OrderMoneyContent;
        
        
        if ([userDefaults boolForKey:@"isVip"]) {
            MemberValid.text = [NSString stringWithFormat:@"有效期至：%@", [self dateFrom:myAppDelegate.deadLineDate time:1]];
        }else {
            MemberValid.text = [NSString stringWithFormat:@"有效期至：%@", [self dateFrom:now time:1]];
        }
        money = @"3";
    }else if ([month isEqualToString:@"1"]) {
        Month = @"3";
        [OrderName setText:[NSString stringWithFormat:@"名称: 大象单车会员卡（%d个月）", 3]];
//        OrderMoney.text = @"金额: 7:00元";
        NSString *OrderMoneyStr = @"金额: 7:00元";
        NSMutableAttributedString *OrderMoneyContent = [[NSMutableAttributedString alloc] initWithString:OrderMoneyStr];
        [OrderMoneyContent addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:112.0/255 green:177.0/255 blue:52.0/255 alpha:1] range:NSMakeRange(3, [OrderMoneyStr length]-3)];
        OrderMoney.attributedText = OrderMoneyContent;
        
        if ([userDefaults boolForKey:@"isVip"]) {
            MemberValid.text = [NSString stringWithFormat:@"有效期至：%@", [self dateFrom:myAppDelegate.deadLineDate time:3]];
        }else {
            MemberValid.text = [NSString stringWithFormat:@"有效期至：%@", [self dateFrom:now time:3]];
        }
        money = @"7";
    }else if ([month isEqualToString:@"2"]) {
        Month = @"6";
        [OrderName setText:[NSString stringWithFormat:@"名称: 大象单车会员卡（%d个月）", 6]];
//        OrderMoney.text = @"金额: 11:00元";
        NSString *OrderMoneyStr = @"金额: 11:00元";
        NSMutableAttributedString *OrderMoneyContent = [[NSMutableAttributedString alloc] initWithString:OrderMoneyStr];
        [OrderMoneyContent addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:112.0/255 green:177.0/255 blue:52.0/255 alpha:1] range:NSMakeRange(3, [OrderMoneyStr length]-3)];
        OrderMoney.attributedText = OrderMoneyContent;
        
        if ([userDefaults boolForKey:@"isVip"]) {
            MemberValid.text = [NSString stringWithFormat:@"有效期至：%@", [self dateFrom:myAppDelegate.deadLineDate time:6]];
        }else {
            MemberValid.text = [NSString stringWithFormat:@"有效期至：%@", [self dateFrom:now time:6]];
        }
        money = @"11";
    }else {
        Month = @"12";
        [OrderName setText:[NSString stringWithFormat:@"名称: 大象单车会员卡（%d个月）", 12]];
//        OrderMoney.text = @"金额: 18:00元";
        NSString *OrderMoneyStr = @"金额: 18:00元";
        NSMutableAttributedString *OrderMoneyContent = [[NSMutableAttributedString alloc] initWithString:OrderMoneyStr];
        [OrderMoneyContent addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:112.0/255 green:177.0/255 blue:52.0/255 alpha:1] range:NSMakeRange(3, [OrderMoneyStr length]-3)];
        OrderMoney.attributedText = OrderMoneyContent;
        if ([userDefaults boolForKey:@"isVip"]) {
            MemberValid.text = [NSString stringWithFormat:@"有效期至：%@", [self dateFrom:myAppDelegate.deadLineDate time:12]];
        }else {
            MemberValid.text = [NSString stringWithFormat:@"有效期至：%@", [self dateFrom:now time:12]];
        }
        money = @"18";
    }
}

#pragma  mark - 私有方法
-(void)confirmMember{
    
    // 异步post 需要显示菊花等待动画
    // 菊花等待动画
    // 集成api  此处是膜
    waitCover = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    waitCover.alpha = 1;
    // 半黑膜
    UIView *containerView = [[UIView alloc] initWithFrame:CGRectMake(0.3*SCREEN_WIDTH, 0.4*SCREEN_HEIGHT, 0.4*SCREEN_WIDTH, 0.15*SCREEN_HEIGHT)];
    containerView.backgroundColor = [UIColor blackColor];
    containerView.alpha = 0.8;
    containerView.layer.cornerRadius = CORNERRADIUS*2;
    [waitCover addSubview:containerView];
    // 两个控件
    UIActivityIndicatorView *waitActivityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    waitActivityView.frame = CGRectMake(0.33*containerView.frame.size.width, 0.1*containerView.frame.size.width, 0.33*containerView.frame.size.width, 0.4*containerView.frame.size.height);
    [waitActivityView startAnimating];
    [containerView addSubview:waitActivityView];
    
    UILabel *hintMes1 = [[UILabel alloc] initWithFrame:CGRectMake(0, 0.7*containerView.frame.size.height, containerView.frame.size.width, 0.2*containerView.frame.size.height)];
    hintMes1.text = @"请稍后...";
    hintMes1.textColor = [UIColor whiteColor];
    hintMes1.textAlignment = NSTextAlignmentCenter;
    [containerView addSubview:hintMes1];
    [self.view addSubview:waitCover];
    
    NSIndexPath *indexPath = [payListTableView indexPathForSelectedRow];
    if (indexPath.row == 0) {
        myAppDelegate.isWXPay = YES;
        // 微信支付
        // 请求api 获取预付单
        NSString *phoneNumber = [userDefaults objectForKey:@"phoneNumber"];
        NSString *urlStr = [IP stringByAppendingString:@"/api/pay/wxpayvip"];
        NSURL *url = [NSURL URLWithString:urlStr];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10];
        NSString *dataStr = [NSString stringWithFormat:@"phone=%@&month=%@", phoneNumber, Month];
        NSData *data = [dataStr dataUsingEncoding:NSUTF8StringEncoding];
        [request setHTTPBody:data];
        [request setHTTPMethod:@"POST"];
        myAppDelegate.isGoToPay = YES;
        MyURLConnection *connection = [[MyURLConnection alloc] MyConnectioin:request delegate:self andName:@"getPrepay"];
    }else if (indexPath.row == 1) {
        //支付宝
        // 异步请求服务器
        myAppDelegate.isWXPay = NO;
        NSString *phoneNumber = [userDefaults objectForKey:@"phoneNumber"];
        NSString *urlStr = [IP stringByAppendingString:@"/api/pay/alipayorder"];
        NSURL *url = [NSURL URLWithString:urlStr];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10];
        NSString *dataStr = [NSString stringWithFormat:@"phone=%@&month=%@&subject=%@&body=%@", phoneNumber, Month,  @"会员充值", @"大象单车会员卡"];
        NSData *data = [dataStr dataUsingEncoding:NSUTF8StringEncoding];
        [request setHTTPBody:data];
        [request setHTTPMethod:@"POST"];
        myAppDelegate.isGoToPay = YES;
        MyURLConnection *connection = [[MyURLConnection alloc] MyConnectioin:request delegate:self andName:@"getAlipay"];
    }
     /*
    // 默认支付成功 通知三个地方
    [[NSNotificationCenter defaultCenter] postNotificationName:@"isVip" object:nil];
    // 将本地isVip修改 然后回到之前的页面
    [userDefaults setBool:YES forKey:@"isVip"];
    if (myAppDelegate.isEndPay && myAppDelegate.isEndRiding) {
        for (UIViewController *temp in self.navigationController.viewControllers) {
            if ([temp isKindOfClass:[QRCodeScanViewController class]]) {
                [self.navigationController popToViewController:temp animated:YES];
            }
        }
    }else if (myAppDelegate.isEndRiding) {
        for (UIViewController *temp in self.navigationController.viewControllers) {
            if ([temp isKindOfClass:[PayViewController class]]) {
                [self.navigationController popToViewController:temp animated:YES];
            }
        }
    }else {
        for (UIViewController *temp in self.navigationController.viewControllers) {
            if ([temp isKindOfClass:[ChargeViewController class]]) {
                [self.navigationController popToViewController:temp animated:YES];
            }
        }
    }*/
}

#pragma mark - 服务器返回
- (void)MyConnection:(MyURLConnection *)connection didReceiveData:(NSData *)data {
    NSDictionary *receiveJson = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
    if ([connection.name isEqualToString:@"getPrepay"]) {
        NSString *status = receiveJson[@"status"];
        if ([status isEqualToString:@"success"]) {
            PayReq *request = [[PayReq alloc] init];
            request.openID = receiveJson[@"appid"];
            request.partnerId = receiveJson[@"partnerid"];
            request.prepayId= receiveJson[@"prepayid"];
            request.package = receiveJson[@"package"];
            request.nonceStr= receiveJson[@"noncestr"];
            request.timeStamp= [receiveJson[@"timestamp"] intValue];
            request.sign = receiveJson[@"sign"];
            WXOutTradeNo = receiveJson[@"out_trade_no"];
            NSLog(@"appid:%@\npartnerid:%@\nprepayid:%@\npackage:%@\nonceStr:%@\ntimestamp:%d\nsign:%@", request.openID, request.partnerId, request.prepayId, request.package, request.nonceStr, (unsigned int)request.timeStamp, request.sign);
            [WXApi sendReq:request];
        }else {
            NSLog(@"预付单没有收到");
        }
    }else if ([connection.name isEqualToString:@"wxcheck"]) {
        myAppDelegate.isGoToPay = NO;
        NSString *status = receiveJson[@"status"];
        NSLog(@"充值会员返回");
        NSLog(@"status:%@", status);
        if ([status isEqualToString:@"success"]) {
            [waitCover removeFromSuperview];
            [userDefaults setBool:YES forKey:@"isVip"];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"isVip" object:nil];
            // 将本地isVip修改 然后回到之前的页面
            
            
            // 充值成功动画再做修改
            waitCover = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
            waitCover.alpha = 1;
            // 半黑膜
            UIView *containerView1 = [[UIView alloc] initWithFrame:CGRectMake(0.3*SCREEN_WIDTH, 0.4*SCREEN_HEIGHT, 0.4*SCREEN_WIDTH, 0.15*SCREEN_HEIGHT)];
            containerView1.backgroundColor = [UIColor blackColor];
            containerView1.alpha = 0.8;
            containerView1.layer.cornerRadius = CORNERRADIUS*2;
            [waitCover addSubview:containerView1];
            UIImageView *success = [[UIImageView alloc] initWithFrame:CGRectMake(0.3*containerView1.frame.size.width, (containerView1.frame.size.height-0.4*containerView1.frame.size.width)/2, 0.4*containerView1.frame.size.width, 0.4*containerView1.frame.size.width)];
            [success setImage:[UIImage imageNamed:@"成功"]];
            success.contentMode = UIViewContentModeScaleToFill;
            [containerView1 addSubview:success];
            [self.view addSubview:waitCover];
        
            NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(removeView) userInfo:nil repeats:NO];
            [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
        }else {
            [waitCover removeFromSuperview];
            // 充值失败
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"充值失败，请重试" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alertView show];
        }
    }else if([connection.name isEqualToString:@"getAlipay"]) {
        NSString *appScheme = @"alisdkdemo";
        
        NSString *param = receiveJson[@"param"];
        NSString *sign = receiveJson[@"sign"];
        NSString *sign_type = receiveJson[@"sign_type"];
        outTradeNO = receiveJson[@"out_trade_no"];
        NSLog(@"out_trade_no:%@", outTradeNO);
        NSString *orderString = nil;
        orderString = [NSString stringWithFormat:@"%@&sign=\"%@\"&sign_type=\"%@\"", param,  sign, sign_type];
        
        NSArray *array = [[UIApplication sharedApplication] windows];
        UIWindow* win=[array objectAtIndex:0];
        [win setHidden:YES];
        [[AlipaySDK defaultService] payOrder:orderString fromScheme:appScheme callback:^(NSDictionary *resultDic) {
                            NSLog(@"result=%@", resultDic);
                            // 请求
            
        }];
//        NSURL * myURL_APP_A = [NSURL URLWithString:@"alipay.com"];
//        if (![[UIApplication sharedApplication] canOpenURL:myURL_APP_A]) {
//            [waitCover removeFromSuperview];
//            //如果没有安装支付宝客户端那么需要安装
//            UIAlertView *message = [[UIAlertView alloc]initWithTitle:@"提示信息" message:@"请先安装支付宝" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
//            [message show];
//        }else {
//            [[AlipaySDK defaultService] payOrder:orderString fromScheme:appScheme callback:^(NSDictionary *resultDic) {
//                NSLog(@"result=%@", resultDic);
//                // 请求
//                
//            }];
//        }
    }else if ([connection.name isEqualToString:@"alipaycheck"]) {
        myAppDelegate.isGoToPay = NO;
        NSString *status = receiveJson[@"status"];
        NSLog(@"%@", status);
        [waitCover removeFromSuperview];
        if ([status isEqualToString:@"success"]) {
            [userDefaults setBool:YES forKey:@"isVip"];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"isVip" object:nil];
            // 付款成功
            waitCover = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
            waitCover.alpha = 1;
            // 半黑膜
            UIView *containerView1 = [[UIView alloc] initWithFrame:CGRectMake(0.3*SCREEN_WIDTH, 0.4*SCREEN_HEIGHT, 0.4*SCREEN_WIDTH, 0.15*SCREEN_HEIGHT)];
            containerView1.backgroundColor = [UIColor blackColor];
            containerView1.alpha = 0.8;
            containerView1.layer.cornerRadius = CORNERRADIUS*2;
            [waitCover addSubview:containerView1];
            UIImageView *success = [[UIImageView alloc] initWithFrame:CGRectMake(0.3*containerView1.frame.size.width, (containerView1.frame.size.height-0.4*containerView1.frame.size.width)/2, 0.4*containerView1.frame.size.width, 0.4*containerView1.frame.size.width)];
            [success setImage:[UIImage imageNamed:@"成功"]];
            success.contentMode = UIViewContentModeScaleToFill;
            [containerView1 addSubview:success];
            [self.view addSubview:waitCover];
            // 显示时间
            NSTimer *gotoQRScanTimer = [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(removeView) userInfo:nil repeats:NO];
        }else {
            // 付款失败
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"付款失败，请重试" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alertView show];
        }
    }
}

- (void)MyConnection:(MyURLConnection *)connection didFailWithError:(NSError *)error {
    [waitCover removeFromSuperview];
    waitCover = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    waitCover.alpha = 1;
    // 半黑膜
    UIView *containerView = [[UIView alloc] initWithFrame:CGRectMake(0.3*SCREEN_WIDTH, 0.4*SCREEN_HEIGHT, 0.4*SCREEN_WIDTH, 0.15*SCREEN_HEIGHT)];
    containerView.backgroundColor = [UIColor blackColor];
    containerView.alpha = 0.8;
    containerView.layer.cornerRadius = CORNERRADIUS*2;
    [waitCover addSubview:containerView];
    // 一个控件
    UILabel *hintMes1 = [[UILabel alloc] initWithFrame:CGRectMake(0, 0.4*containerView.frame.size.height, containerView.frame.size.width, 0.2*containerView.frame.size.height)];
    hintMes1.text = @"请检查您的网络";
    hintMes1.textColor = [UIColor whiteColor];
    hintMes1.textAlignment = NSTextAlignmentCenter;
    [containerView addSubview:hintMes1];
    [self.view addSubview:waitCover];
    // 显示时间
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(removeCoverView) userInfo:nil repeats:NO];
    [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
}

- (void)removeCoverView {
    [waitCover removeFromSuperview];
}

- (void)gotoQRScan {
    [waitCover removeFromSuperview];
    [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:0] animated:YES];
}

#pragma mark - 返回app时调用接口判断是否支付成功
- (void)isWXPay {
    NSString *urlStr = [IP stringByAppendingString:@"/api/pay/wxorderquery"];
    NSURL *url = [NSURL URLWithString:urlStr];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10];
    NSString *phoneNumber = [userDefaults objectForKey:@"phoneNumber"];
    NSString *dataStr = [NSString stringWithFormat:@"out_trade_no=%@", WXOutTradeNo];
    NSData *data = [dataStr dataUsingEncoding:NSUTF8StringEncoding];
    [request setHTTPBody:data];
    [request setHTTPMethod:@"POST"];
    MyURLConnection *connectionn = [[MyURLConnection alloc] MyConnectioin:request delegate:self andName:@"wxcheck"];
    NSLog(@"返回支付结果memberpay");
}
- (void)isAliPay {
    NSString *urlStr = [IP stringByAppendingString:@"/api/pay/alipayquery"];
    NSURL *url = [NSURL URLWithString:urlStr];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10];
    NSString *dataStr = [NSString stringWithFormat:@"out_trade_no=%@", outTradeNO];
    NSData *data = [dataStr dataUsingEncoding:NSUTF8StringEncoding];
    [request setHTTPBody:data];
    [request setHTTPMethod:@"POST"];
    MyURLConnection *connectionn = [[MyURLConnection alloc] MyConnectioin:request delegate:self andName:@"alipaycheck"];
    NSLog(@"返回支付结果memberview");
}

- (NSString *)dateFrom:(NSString *)date time:(NSUInteger)time{
    NSArray *array = [date componentsSeparatedByString:@"-"];
    NSUInteger month = [[array objectAtIndex:1] intValue];
    NSUInteger year = [[array objectAtIndex:0] intValue];
    month += time;
    if (month > 12) {
        month -= 12;
        year += 1;
    }
    NSString *newMonth = [NSString stringWithFormat:@"%lu", (unsigned long)month];
    NSString *newYear = [NSString stringWithFormat:@"%lu", year];
    return [NSString stringWithFormat:@"%@-%@-%@", newYear, newMonth, [array objectAtIndex:2]];
}

- (void)showSuccess {

}

- (void)showFail {

}

- (void)removeView {
    [waitCover removeFromSuperview];
    if (myAppDelegate.isEndPay && myAppDelegate.isEndRiding) {
        for (UIViewController *temp in self.navigationController.viewControllers) {
            if ([temp isKindOfClass:[QRCodeScanViewController class]]) {
                [self.navigationController popToViewController:temp animated:YES];
            }
        }
    }else if (myAppDelegate.isEndRiding) {
        for (UIViewController *temp in self.navigationController.viewControllers) {
            if ([temp isKindOfClass:[PayViewController class]]) {
                [self.navigationController popToViewController:temp animated:YES];
            }
        }
    }else {
        for (UIViewController *temp in self.navigationController.viewControllers) {
            if ([temp isKindOfClass:[ChargeViewController class]]) {
                [self.navigationController popToViewController:temp animated:YES];
            }
        }
    }
}

#pragma mark - LifeCycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = BACKGROUNDCOLOR;
    [self UIInit];
    [self UILayout];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    myAppDelegate.isMoneyView = YES;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    myAppDelegate.isMoneyView = NO;
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
