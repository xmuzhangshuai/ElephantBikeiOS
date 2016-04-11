//
//  PayViewController.m
//  ElephantBike
//
//  Created by 黄杰锋 on 16/1/19.
//  Copyright © 2016年 黄杰锋. All rights reserved.
//

#import "PayViewController.h"
#import "UISize.h"
#import "MyTableViewCell.h"

#import "InfoViewController.h"
#import "AppDelegate.h"
#import "MyURLConnection.h"
#import "ChargeViewController.h"
#import "QuestionDetailViewController.h"
#import "RechargeViewController.h"

#pragma mark - 微信支付
#import "WXApi.h"
#import <CommonCrypto/CommonDigest.h>
#import "WXApiObject.h"

/**
 *  支付宝支付
 **/
#import "AlipaySDK/AlipaySDK.h"

#define CHARGEVIEW_HEIGHT       0.16*SCREEN_HEIGHT
#define STATUSLABEL_WIDTH       0.33*SCREEN_WIDTH
#define STATUSLABEL_HEIGHT      0.2*CHARGEVIEW_HEIGHT
#define QUESTIONBUTTON_WIDTH    STATUSLABEL_HEIGHT
#define QUESTIONBUTTON_HEIGHT   QUESTIONBUTTON_WIDTH
#define TOTALPAYLABEL_WIDTH     0.25*SCREEN_WIDTH
#define TOTALPAYLABEL_HEIGHT    0.35*CHARGEVIEW_HEIGHT
#define MONEYLABEL_WIDTH        TOTALPAYLABEL_WIDTH
#define MONEYLABEL_HEIGHT       TOTALPAYLABEL_HEIGHT
#define TOTALTIME_WIDTH         TOTALPAYLABEL_WIDTH
#define TOTALTIME_HEIGHT        0.25*CHARGEVIEW_HEIGHT
#define TIMELABEL_WIDTH         TOTALTIME_WIDTH
#define TIMELABEL_HEIGHT        TOTALTIME_HEIGHT

#define PAYLISTTABLEVIEW_HEIGHT 0.27*SCREEN_HEIGHT
#define CONFIRMBUTTON_WIDTH     0.8*SCREEN_WIDTH
#define CONFIRMBUTTON_HEIGHT    0.056*SCREEN_HEIGHT



@interface PayViewController ()<UITableViewDataSource, UITableViewDelegate, InfoViewControllerDelegate, MyURLConnectionDelegate, ChargeViewControllerDelegate, QuestionViewControllerDelegate, UIAlertViewDelegate, WXApiDelegate, PayDelegate>

@end

@implementation PayViewController{
    UIView      *chargeView;
    UILabel     *statusLabel;
    UIButton    *questionButton;
    /** 增加大象会员的ImageView*/
    UIButton    *MemberImageView;
    UILabel *bikeLabel;
    UILabel *bikeNumber;
    
    /** 单车编号*/
    NSString *bikeNo;
    
    UILabel     *totalPayLabel;
    UILabel     *moneyLabel;
    UILabel     *totalTimeLabel;
    UILabel     *timeLabel;
    UILabel     *loseBikeLabel;
    UILabel     *loseBikeMoneyLabel;
    
    
    
    UITableView *payListTableView;
    UIButton    *confirmButton;
    UILabel     *hintMes;
    
    
    NSArray     *payWay;
    NSArray     *wayDetails;
    
    AppDelegate *myAppdelegate;
    
    NSUserDefaults *userDefaults;
    
    UIView      *waitCover;
    
    NSString    *_money;
    NSString    *_time;
    
    //侧面菜单
    InfoViewController          *infoViewController;
    UIView                      *cover;
    UISwipeGestureRecognizer    *leftSwipGestureRecognizer;
    
    BOOL        isConnect;
    
    NSString    *outTradeNO;        // 订单号
}

- (id)init {
    if(self == [super init]) {
        myAppdelegate = [[UIApplication sharedApplication] delegate];
        myAppdelegate.myDelegate = self;
        userDefaults = [NSUserDefaults standardUserDefaults];
        totalPayLabel       = [[UILabel alloc]init];
        moneyLabel          = [[UILabel alloc]init];
        totalTimeLabel      = [[UILabel alloc]init];
        timeLabel           = [[UILabel alloc]init];
        NSLog(@"init restart:%d", myAppdelegate.isRestart);
        if (!myAppdelegate.isEndPay && myAppdelegate.isRestart) {
            NSLog(@"之前未付款，重启app的");
            // 请求服务器 异步post
            // 先获取bikeid 然后通过bikeid获取使用的时长还是丢车费用
            
            // 请求服务器 异步post
            // 获取bikeid
            NSString *phoneNumber = [userDefaults objectForKey:@"phoneNumber"];
            BOOL isEndRiding = myAppdelegate.isEndRiding;
            NSString *isEndRidingStr = [NSString stringWithFormat:@"%d", isEndRiding];
            NSString *urlStr = [IP stringByAppendingString:@"/ElephantBike/api/bike/costandtime"];
            NSURL *url = [NSURL URLWithString:urlStr];
            NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10];
            NSString *dataStr = [NSString stringWithFormat:@"phone=%@&isfinish=%@", phoneNumber, isEndRidingStr];
            NSLog(@"phoneNumber:%@", phoneNumber);
            NSData *data = [dataStr dataUsingEncoding:NSUTF8StringEncoding];
            [request setHTTPBody:data];
            [request setHTTPMethod:@"POST"];
            MyURLConnection *connection = [[MyURLConnection alloc] MyConnectioin:request delegate:self andName:@"getCostAndTime"];
        }
        NSString *bikeno = [userDefaults objectForKey:@"bikeNo"];
        NSLog(@"缓存的bikeid:%@", bikeno);
        if ([bikeno isEqualToString:@""] || bikeno == nil) {
            NSString *phoneNumber = [userDefaults objectForKey:@"phoneNumber"];
            NSString *urlStr = [IP stringByAppendingString:@"/ElephantBike/api/bike/bikeidandpass"];
            NSURL *url = [NSURL URLWithString:urlStr];
            NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10];
            NSString *dataStr = [NSString stringWithFormat:@"phone=%@",phoneNumber];
            NSData *data = [dataStr dataUsingEncoding:NSUTF8StringEncoding];
            [request setHTTPBody:data];
            [request setHTTPMethod:@"POST"];
            MyURLConnection *connectionn = [[MyURLConnection alloc] MyConnectioin:request delegate:self andName:@"getBikeidAndPass"];
        }
    }
    return self;
}

- (void)UIInit {
    chargeView          = [[UIView alloc]init];
    statusLabel         = [[UILabel alloc]init];
    questionButton      = [[UIButton alloc]init];
    MemberImageView     = [[UIButton alloc] init];
    bikeLabel           = [[UILabel alloc] init];
    bikeNumber          = [[UILabel alloc] init];
    
    
    payListTableView    = [[UITableView alloc] init];
    confirmButton       = [[UIButton alloc] init];
    hintMes             = [[UILabel alloc] init];

    
    isConnect           = NO;
    
    payWay              = @[@"大象钱包", @"微信支付", @"支付宝"];
    wayDetails          = @[@"免密码支付，推荐懒人使用", @"推荐微信支付已绑定信用卡的用户使用", @"推荐已安装支付宝客户端的用户使用"];
    
    cover           = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    [self.navigationController.view addSubview:cover];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hiddenCover)];
    UISwipeGestureRecognizer *rightSwipeGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(hiddenCover)];
    rightSwipeGestureRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
    [cover addGestureRecognizer:tap];
    [cover addGestureRecognizer:rightSwipeGestureRecognizer];
    
    infoViewController = [[InfoViewController alloc] initWithFrame:CGRectMake((-1)*SCREEN_WIDTH, 0, SCREEN_WIDTH*0.8666, SCREEN_HEIGHT)];
    infoViewController.delegate = self;
    [self.navigationController.view addSubview:infoViewController.view];
    
    leftSwipGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(showMenu)];
    [self.view addGestureRecognizer:leftSwipGestureRecognizer];
    
    [self NavigationInit];
    [self UILayout];

}

- (void)UILayout {
    chargeView.frame = CGRectMake(0, STATUS_HEIGHT+NAVIGATIONBAR_HEIGHT, SCREEN_WIDTH, CHARGEVIEW_HEIGHT);
    chargeView.backgroundColor = UICOLOR;
    
    // statusLabel questionButton totalpaylabel -----timelabel
//    statusLabel.frame = CGRectMake(chargeView.center.x-STATUSLABEL_WIDTH/2-QUESTIONBUTTON_WIDTH/2, 0, STATUSLABEL_WIDTH, STATUSLABEL_HEIGHT);
    statusLabel.frame = CGRectMake(chargeView.center.x-STATUSLABEL_WIDTH/2, 0, STATUSLABEL_WIDTH, STATUSLABEL_HEIGHT);
    statusLabel.textAlignment = NSTextAlignmentCenter;
    statusLabel.textColor = [UIColor whiteColor];
    //    statusLabel.text = @"计费结束";
    NSMutableAttributedString *content = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"计费结束"]];
    [content addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"QingYuanMono" size:18] range:NSMakeRange(0, [content length])];
    statusLabel.attributedText = content;
    
    questionButton.frame = CGRectMake(statusLabel.center.x+STATUSLABEL_WIDTH/2-QUESTIONBUTTON_WIDTH/2, 0, QUESTIONBUTTON_WIDTH, QUESTIONBUTTON_HEIGHT);
    [questionButton setImage:[UIImage imageNamed:@"问号"] forState:UIControlStateNormal];
    [questionButton setImageEdgeInsets:UIEdgeInsetsMake(0, -QUESTIONBUTTON_WIDTH/2, 0, 0)];
    
    MemberImageView.frame = CGRectMake(0, 0, 0.19*SCREEN_WIDTH, 0.03*SCREEN_HEIGHT);
    MemberImageView.center = CGPointMake(0.5*SCREEN_WIDTH, 0.045*SCREEN_HEIGHT);
    MemberImageView.titleLabel.font = [UIFont fontWithName:@"QingYuanMono" size:10];
    MemberImageView.userInteractionEnabled = NO;
    //需要去判断，是否是会员
    if ([userDefaults objectForKey:@"isVip"]) {
        [MemberImageView setImage:[UIImage imageNamed:@"会员标识"] forState:UIControlStateNormal];
    }else {
        [MemberImageView setTitle:@"非大象会员" forState:UIControlStateNormal];
    }
    
    //单车编号位置变更
    bikeNumber.frame = CGRectMake(0.05*SCREEN_WIDTH, STATUSLABEL_HEIGHT, TOTALPAYLABEL_WIDTH, TOTALPAYLABEL_HEIGHT);
    //    bikeNumber.text = [NSString stringWithFormat:@"单车编号：%@",bikeNo];
    NSMutableAttributedString *bikeNumbercontent = [[NSMutableAttributedString alloc] initWithString:@"单车编号"];
    [bikeNumbercontent addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"QingYuanMono" size:13] range:NSMakeRange(0, [bikeNumbercontent length])];
    bikeNumber.textColor = [UIColor whiteColor];
    //    bikeNumber.backgroundColor = [UIColor redColor];
    bikeNumber.attributedText = bikeNumbercontent;
    
    bikeLabel.frame = CGRectMake(SCREEN_WIDTH-MONEYLABEL_WIDTH-0.05*SCREEN_WIDTH, STATUSLABEL_HEIGHT, MONEYLABEL_WIDTH, MONEYLABEL_HEIGHT);
    bikeLabel.textAlignment = NSTextAlignmentRight;
    bikeLabel.textColor = [UIColor whiteColor];
    bikeNo = [userDefaults objectForKey:@"bikeNo"];
    NSMutableAttributedString *bikeLabelcontent = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@", bikeNo]];
    [bikeLabelcontent addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"QingYuanMono" size:13] range:NSMakeRange(0, [bikeLabelcontent length])];
    bikeLabel.attributedText = bikeLabelcontent;
    

    //    totalPayLabel.frame = CGRectMake(0.05*SCREEN_WIDTH, STATUSLABEL_HEIGHT, TOTALPAYLABEL_WIDTH, TOTALPAYLABEL_HEIGHT);
    totalPayLabel.frame = CGRectMake(0.05*SCREEN_WIDTH, 0.1*SCREEN_HEIGHT, TOTALPAYLABEL_WIDTH, TOTALPAYLABEL_HEIGHT);
    totalPayLabel.textAlignment = NSTextAlignmentLeft;
    totalPayLabel.font = [UIFont systemFontOfSize:15];
    totalPayLabel.textColor = [UIColor whiteColor];
    NSMutableAttributedString *totalPayLabelcontent = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"费用总计"]];
    [totalPayLabelcontent addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"QingYuanMono" size:20] range:NSMakeRange(0, [totalPayLabelcontent length])];
    totalPayLabel.attributedText = totalPayLabelcontent;
    
    
    moneyLabel.frame = CGRectMake(SCREEN_WIDTH-MONEYLABEL_WIDTH-0.05*SCREEN_WIDTH, 0.1*SCREEN_HEIGHT, MONEYLABEL_WIDTH, MONEYLABEL_HEIGHT);
    moneyLabel.textAlignment = NSTextAlignmentRight;
    moneyLabel.font = [UIFont fontWithName:@"QingYuanMono" size:20];
    moneyLabel.textColor = [UIColor whiteColor];
    
    
    totalTimeLabel.frame = CGRectMake(0.05*SCREEN_WIDTH, STATUSLABEL_HEIGHT+TOTALTIME_HEIGHT, TOTALTIME_WIDTH, TOTALTIME_HEIGHT);
    totalTimeLabel.textAlignment = NSTextAlignmentLeft;
    totalTimeLabel.font = [UIFont systemFontOfSize:12];
    totalTimeLabel.textColor = [UIColor whiteColor];
    //    totalTimeLabel.text = @"使用时长：";
    NSMutableAttributedString *totalTimeLabelcontent = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"使用时长"]];
    [totalTimeLabelcontent addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"QingYuanMono" size:13] range:NSMakeRange(0, [totalTimeLabelcontent length])];
    totalTimeLabel.attributedText = totalTimeLabelcontent;
    
    
    
    
    timeLabel.frame = CGRectMake(SCREEN_WIDTH-TIMELABEL_WIDTH-0.05*SCREEN_WIDTH, STATUSLABEL_HEIGHT+TOTALTIME_HEIGHT, TIMELABEL_WIDTH, TIMELABEL_HEIGHT);
    timeLabel.textAlignment = NSTextAlignmentRight;
    timeLabel.textColor = [UIColor whiteColor];
    timeLabel.font = [UIFont fontWithName:@"QingYuanMono" size:13];
    
    payListTableView.frame = CGRectMake(0, 0.3*SCREEN_HEIGHT, SCREEN_WIDTH, PAYLISTTABLEVIEW_HEIGHT);
    payListTableView.dataSource = self;
    payListTableView.delegate = self;
    payListTableView.scrollEnabled = NO;
    [payListTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    payListTableView.layer.borderWidth = 1;
    payListTableView.layer.borderColor = [UIColor grayColor].CGColor;
    
    confirmButton.frame = CGRectMake(0.1*SCREEN_WIDTH, 0.7*SCREEN_HEIGHT, CONFIRMBUTTON_WIDTH, CONFIRMBUTTON_HEIGHT);
    confirmButton.layer.cornerRadius = CORNERRADIUS;
    confirmButton.backgroundColor = UICOLOR;
    [confirmButton setTitle:@"确认支付" forState:UIControlStateNormal];
    confirmButton.titleLabel.font = [UIFont fontWithName:@"QingYuanMono" size:14];
    [confirmButton addTarget:self action:@selector(QRCodeScanView) forControlEvents:UIControlEventTouchUpInside];
    
    hintMes.frame = CGRectMake(0.05*SCREEN_WIDTH, 0.7*SCREEN_HEIGHT+CONFIRMBUTTON_HEIGHT, CONFIRMBUTTON_WIDTH, CONFIRMBUTTON_HEIGHT);
    hintMes.text = @"任何支付问题，请联系客服：400-123-123";
    hintMes.textAlignment = NSTextAlignmentCenter;
    hintMes.textColor = [UIColor grayColor];
    hintMes.font = [UIFont fontWithName:@"QingYuanMono" size:10];
    
    cover.backgroundColor = [UIColor blackColor];
    cover.alpha = 0.0;
    cover.hidden = YES;
    
    [self.view addSubview:chargeView];
    [chargeView addSubview:statusLabel];
    [chargeView addSubview:questionButton];
    [chargeView addSubview:MemberImageView];
    [chargeView addSubview:bikeNumber];
    [chargeView addSubview:bikeLabel];
    [chargeView addSubview:totalPayLabel];
    [chargeView addSubview:moneyLabel];
    [self.view addSubview:payListTableView];
    [self.view addSubview:confirmButton];
    [self.view addSubview:hintMes];

    [chargeView addSubview:totalTimeLabel];
    [chargeView addSubview:timeLabel];
    
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showSuccess) name:@"paySuccess" object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showFail) name:@"payFail" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeMemberStatus) name:@"isVip" object:nil];
}

- (void)NavigationInit {
    UIImageView *titleImageView = [[UIImageView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2-30, STATUS_HEIGHT, 0.1013*SCREEN_WIDTH, 0.042*SCREEN_HEIGHT)];
    titleImageView.image = [UIImage imageNamed:@"LOGO"];
    titleImageView.contentMode = UIViewContentModeScaleToFill;
    self.navigationItem.titleView = titleImageView;
    UIBarButtonItem *infoButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"个人中心"] style:UIBarButtonItemStylePlain target:self action:@selector(information)];
    infoButton.tintColor = [UIColor grayColor];
    self.navigationItem.leftBarButtonItem = infoButton;
}

#pragma mark - Button Event
- (void)QRCodeScanView {
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
        // 点击付款，应该先从服务器获取余额 然后付款
        NSString *phoneNumber = [userDefaults objectForKey:@"phoneNumber"];
        // 在登录了的情况下 去服务器获取余额
        NSString *urlStr = [IP stringByAppendingString:@"/ElephantBike/api/money/balance"];
        NSURL *url = [NSURL URLWithString:urlStr];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10];
        NSString *dataStr = [NSString stringWithFormat:@"phone=%@", phoneNumber];
        NSData *data = [dataStr dataUsingEncoding:NSUTF8StringEncoding];
        [request setHTTPBody:data];
        [request setHTTPMethod:@"POST"];
        MyURLConnection *connection = [[MyURLConnection alloc] MyConnectioin:request delegate:self andName:@"balance"];
    }else if (indexPath.row == 1) {
        if (myAppdelegate.isMissing) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"您的单车已丢失，请使用大象单车" delegate:nil cancelButtonTitle:@"知道了" otherButtonTitles:nil, nil];
            [alertView show];
        }else {
            // 微信支付
            // 请求api 获取预付单
            myAppdelegate.isWXPay = YES;
            NSString *phoneNumber = [userDefaults objectForKey:@"phoneNumber"];
            NSString *bikeno = [userDefaults objectForKey:@"bikeNo"];
            NSString *urlStr = [IP stringByAppendingString:@"/ElephantBike/api/pay/wxpayorder"];
            NSURL *url = [NSURL URLWithString:urlStr];
            NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10];
            NSString *dataStr = [NSString stringWithFormat:@"phone=%@&totalfee=%@&bikeid=%@", phoneNumber, _money, bikeno];
            NSData *data = [dataStr dataUsingEncoding:NSUTF8StringEncoding];
            [request setHTTPBody:data];
            [request setHTTPMethod:@"POST"];
            MyURLConnection *connection = [[MyURLConnection alloc] MyConnectioin:request delegate:self andName:@"getPrepay"];
        }
    }else {
        if (myAppdelegate.isMissing) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"您的单车已丢失，请使用大象单车" delegate:nil cancelButtonTitle:@"知道了" otherButtonTitles:nil, nil];
            [alertView show];
        }else {
            //支付宝
            // 异步请求服务器
            myAppdelegate.isWXPay = NO;
            NSString *phoneNumber = [userDefaults objectForKey:@"phoneNumber"];
            NSString *bikeno = [userDefaults objectForKey:@"bikeNo"];
            NSString *urlStr = [IP stringByAppendingString:@"/ElephantBike/api/pay/alipaypay"];
            NSURL *url = [NSURL URLWithString:urlStr];
            NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10];
            NSString *dataStr = [NSString stringWithFormat:@"phone=%@&totalfee=%@&bikeid=%@&subject=%@&body=%@", phoneNumber, _money, bikeno, @"大象单车订单付款", @"多少钱"];
            NSData *data = [dataStr dataUsingEncoding:NSUTF8StringEncoding];
            [request setHTTPBody:data];
            [request setHTTPMethod:@"POST"];
            MyURLConnection *connection = [[MyURLConnection alloc] MyConnectioin:request delegate:self andName:@"getAlipay"];
        }
    }
}

#pragma mark - 服务器返回
- (void)MyConnection:(MyURLConnection *)connection didReceiveData:(NSData *)data {
    NSDictionary *receiveJson = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
    if ([connection.name isEqualToString:@"pay"]) {
        NSString *status = receiveJson[@"status"];
        NSString *message = receiveJson[@"message"];
        [waitCover removeFromSuperview];
        if ([status isEqualToString:@"success"]) {
            myAppdelegate.isEndPay = YES;
            // 付款成功
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
            hintMes1.text = @"付款成功";
            hintMes1.textColor = [UIColor whiteColor];
            hintMes1.textAlignment = NSTextAlignmentCenter;
            [containerView addSubview:hintMes1];
            [self.view addSubview:waitCover];
            // 显示时间
            
            isConnect = YES;
            // 付费成功 跳转扫描页面 并且对本地的balance扣除相应的金额
            NSIndexPath *indexPath = [payListTableView indexPathForSelectedRow];
            if (indexPath.row == 0) {
                CGFloat balan = [myAppdelegate.balance floatValue];
                CGFloat money = [_money floatValue];
                balan -= money;
                myAppdelegate.balance = [NSString stringWithFormat:@"%.2f", balan];
                [userDefaults setObject:myAppdelegate.balance forKey:@"balance"];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"balanceUpdate" object:nil];
                NSLog(@"扣除相应金额");
            }
            NSTimer *gotoQRScanTimer = [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(gotoQRScan) userInfo:nil repeats:NO];
        }else {
            NSLog(@"付款失败：%@",message);
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"付款失败" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alert show];
        }
    }else if ([connection.name isEqualToString:@"getCostAndTime"]) {
        NSString *status = receiveJson[@"status"];
        NSString *money = receiveJson[@"cost"];
        NSString *time = receiveJson[@"usedtime"];
//        NSString *pass = receiveJson[@"pass"];  //在支付页面解锁密码没有用
        if ([status isEqualToString:@"success"]) {
            isConnect = YES;
            if ([time isEqualToString:@""]) {
                myAppdelegate.isMissing = YES;
                totalPayLabel.text = @"费用总计:";
                //增加取两位判断
                CGFloat moneyNum = [money floatValue];
                money = [NSString stringWithFormat:@"%.2f", moneyNum];
                
                NSString *temp = [@"￥" stringByAppendingString:money];
                moneyLabel.text = temp;
                totalTimeLabel.text = @"单车丢失赔偿金:";
                NSString *temp1 = [@"￥" stringByAppendingString:money];
                timeLabel.text = temp1;
            }else {
                myAppdelegate.isMissing = NO;
                _money = money;
                _time = time;
                NSString *temp = [@"￥" stringByAppendingString:_money];
                moneyLabel.text = temp;
                timeLabel.text = _time;
                NSLog(@"未付款获得金额赋值");
            }
            NSString *bikeno = [userDefaults objectForKey:@"bikeNo"];
            if (!bikeno) {
                NSString *phoneNumber = [userDefaults objectForKey:@"phoneNumber"];
                NSString *urlStr = [IP stringByAppendingString:@"/ElephantBike/api/bike/bikeidandpass"];
                NSURL *url = [NSURL URLWithString:urlStr];
                NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10];
                NSString *dataStr = [NSString stringWithFormat:@"phone=%@",phoneNumber];
                NSData *data = [dataStr dataUsingEncoding:NSUTF8StringEncoding];
                [request setHTTPBody:data];
                [request setHTTPMethod:@"POST"];
                MyURLConnection *connectionn = [[MyURLConnection alloc] MyConnectioin:request delegate:self andName:@"getBikeidAndPass"];
            }
        }
    }else if ([connection.name isEqualToString:@"balance"]) {
        NSString *status = receiveJson[@"status"];
        NSString *balance = receiveJson[@"balance"];
        NSLog(@"balance:%@", balance);
        NSLog(@"shouldPaymoney:%@", _money);
        if ([status isEqualToString:@"success"]) {
            isConnect = YES;
            [userDefaults setObject:balance forKey:@"balance"];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"balanceUpdate" object:nil];
            CGFloat shouldPayMoney = [_money floatValue];
            CGFloat havaMoney = [balance floatValue];
            if (havaMoney > shouldPayMoney) {
                // 付款api
                // 从本地拿取accessToken
                userDefaults = [NSUserDefaults standardUserDefaults];
                NSString *accessToken = [userDefaults objectForKey:@"accessToken"];
                // 从本地拿取bikeNo
                NSString *bikeno = [userDefaults objectForKey:@"bikeNo"];
                NSLog(@"balance bikeno:%@", bikeno);
                // 从本地拿取电话
                NSString *phoneNumber = [userDefaults objectForKey:@"phoneNumber"];
                // 判断选择了哪一种支付方式
                NSIndexPath *indexPath = [payListTableView indexPathForSelectedRow];
                NSInteger selectPayWayNumber = indexPath.row;
                NSString *isMissngStr = [NSString stringWithFormat:@"%d", myAppdelegate.isMissing];
                NSLog(@"ismissing:%@ bikeid:%@", isMissngStr, bikeno);
                
                NSString *urlStr = [IP stringByAppendingString:@"/ElephantBike/api/money/returnpay"];
                NSURL *url = [NSURL URLWithString:urlStr];
                NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10];
                NSString *dataStr = [NSString stringWithFormat:@"bikeid=%@&phone=%@&paymode=%@&access_token=%@&ismissing=%@", bikeno, phoneNumber, [payWay objectAtIndex:selectPayWayNumber],  accessToken, isMissngStr];
                NSData *data = [dataStr dataUsingEncoding:NSUTF8StringEncoding];
                [request setHTTPBody:data];
                [request setHTTPMethod:@"POST"];
                MyURLConnection *connectionn = [[MyURLConnection alloc] MyConnectioin:request delegate:self andName:@"pay"];
            }else {
                [waitCover removeFromSuperview];
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"余额不足，请充值" delegate:self cancelButtonTitle:@"去充值" otherButtonTitles:@"取消", nil];
                alertView.tag = 0;
                [alertView show];
                // 余额不足
            }
        }
        
    }else if ([connection.name isEqualToString:@"getPrepay"]) {
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
            outTradeNO = receiveJson[@""];
            NSLog(@"appid:%@\npartnerid:%@\nprepayid:%@\npackage:%@\nonceStr:%@\ntimestamp:%d\nsign:%@", request.openID, request.partnerId, request.prepayId, request.package, request.nonceStr, (unsigned int)request.timeStamp, request.sign);
            [WXApi sendReq:request];
        }else {
            NSLog(@"预付单没有收到");
        }
    }else if ([connection.name isEqualToString:@"getBikeidAndPass"]) {
        NSString *status = receiveJson[@"status"];
        NSString *bikeno = receiveJson[@"bikeid"];
        if ([status isEqualToString:@"success"]) {
            [userDefaults setObject:bikeno forKey:@"bikeNo"];
            bikeLabel.text = bikeno;
            NSLog(@"getbikeidandpass bikeno:%@", bikeno);
        }
    }else if ([connection.name isEqualToString:@"wxcheck"]) {
        NSString *status = receiveJson[@"status"];
        NSLog(@"%@", status);
        [waitCover removeFromSuperview];
        if ([status isEqualToString:@"success"]) {
            // 付款成功
            myAppdelegate.isEndPay = YES;
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
            hintMes1.text = @"付款成功";
            hintMes1.textColor = [UIColor whiteColor];
            hintMes1.textAlignment = NSTextAlignmentCenter;
            [containerView addSubview:hintMes1];
            [self.view addSubview:waitCover];
            // 显示时间
            NSTimer *gotoQRScanTimer = [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(gotoQRScan) userInfo:nil repeats:NO];
        }else {
            // 付款失败
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"付款失败，请重试" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alertView show];
        }
    }else if([connection.name isEqualToString:@"getAlipay"]) {
        NSString *appScheme = @"alisdkdemo";
        
        NSString *param = receiveJson[@"param"];
        NSString *sign = receiveJson[@"sign"];
        NSString *sign_type = receiveJson[@"sign_type"];
        outTradeNO = receiveJson[@"out_trade_no"];
        
        NSString *orderString = nil;
        orderString = [NSString stringWithFormat:@"%@&sign=\"%@\"&sign_type=\"%@\"", param,  sign, sign_type];
        
        [[AlipaySDK defaultService] payOrder:orderString fromScheme:appScheme callback:^(NSDictionary *resultDic) {
            NSLog(@"result=%@", resultDic);
        }];
    }else if ([connection.name isEqualToString:@"alipaycheck"]) {
        NSString *status = receiveJson[@"status"];
        NSLog(@"%@", status);
        [waitCover removeFromSuperview];
        if ([status isEqualToString:@"success"]) {
            // 付款成功
            myAppdelegate.isEndPay = YES;
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
            hintMes1.text = @"付款成功";
            hintMes1.textColor = [UIColor whiteColor];
            hintMes1.textAlignment = NSTextAlignmentCenter;
            [containerView addSubview:hintMes1];
            [self.view addSubview:waitCover];
            // 显示时间
            NSTimer *gotoQRScanTimer = [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(gotoQRScan) userInfo:nil repeats:NO];
        }else {
            // 付款失败
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"付款失败，请重试" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alertView show];
        }
    }
}
// 链接超时 需要提醒用户
- (void)MyConnection:(MyURLConnection *)connection didFailWithError:(NSError *)error {
    isConnect = YES;
    [waitCover removeFromSuperview];
    // 收到验证码  进行提示
    waitCover = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    waitCover.alpha = 1;
    // 半黑膜
    UIView *containerView = [[UIView alloc] initWithFrame:CGRectMake(0.3*SCREEN_WIDTH, 0.4*SCREEN_HEIGHT, 0.4*SCREEN_WIDTH, 0.15*SCREEN_HEIGHT)];
    containerView.backgroundColor = [UIColor blackColor];
    containerView.alpha = 0.8;
    containerView.layer.cornerRadius = CORNERRADIUS*2;
    [cover addSubview:containerView];
    // 一个控件
    UILabel *hintMes1 = [[UILabel alloc] initWithFrame:CGRectMake(0, 0.4*containerView.frame.size.height, containerView.frame.size.width, 0.2*containerView.frame.size.height)];
    hintMes1.text = @"您的网络忙，请重试";
    hintMes1.textColor = [UIColor whiteColor];
    hintMes1.textAlignment = NSTextAlignmentCenter;
    [containerView addSubview:hintMes1];
    [self.view addSubview:waitCover];
    // 显示时间
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(removeView) userInfo:nil repeats:NO];
    [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
    NSLog(@"网络超时");
}

#pragma mark - 私有方法

- (void)stopRequest {
    if (!isConnect) {
        [waitCover removeFromSuperview];
        // 收到验证码  进行提示
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
        hintMes1.text = @"无法连接服务器";
        hintMes1.textColor = [UIColor whiteColor];
        hintMes1.textAlignment = NSTextAlignmentCenter;
        [containerView addSubview:hintMes1];
        [self.view addSubview:waitCover];
        // 显示时间
        NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(removeView) userInfo:nil repeats:NO];
        [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
    }
    isConnect = NO;
}

- (void)removeView {
    [waitCover removeFromSuperview];
}


- (void)hiddenCover {
    [self hiddenMenu];
    [UIView animateWithDuration:0.25 animations:^{
        cover.alpha = 0.0;
    }];
    cover.hidden = YES;
}

- (void)information {
    [self showMenu];
}

- (void)showMenu {
    CGRect infoView = infoViewController.view.frame;
    infoView.origin.x += SCREEN_WIDTH;
    // 动画
    cover.hidden = NO;
    [UIView animateWithDuration:0.4f
                          delay:0.0f
         usingSpringWithDamping:1.0
          initialSpringVelocity:4.0
                        options: UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         infoViewController.view.frame = infoView;
                         cover.alpha = 0.6;
                     }
                     completion:^(BOOL finished){
                     }];
    [UIView commitAnimations];
}

- (void)hiddenMenu {
    CGRect infoView = infoViewController.view.frame;
    infoView.origin.x -= SCREEN_WIDTH;
    // 动画
    cover.hidden = YES;
    [UIView animateWithDuration:0.6f
                          delay:0.05f
         usingSpringWithDamping:1.0
          initialSpringVelocity:4.0
                        options: UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         infoViewController.view.frame = infoView;
                         cover.alpha = 0;
                     }
                     completion:^(BOOL finished){
                     }];
    [UIView commitAnimations];
    
}

- (void)gotoQRScan {
    [waitCover removeFromSuperview];
    [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:0] animated:YES];
}

- (void)showSuccess {
//    // 付款api
//    // 从本地拿取accessToken
//    userDefaults = [NSUserDefaults standardUserDefaults];
//    NSString *accessToken = [userDefaults objectForKey:@"accessToken"];
//    // 从本地拿取bikeNo
//    NSString *bikeNo = [userDefaults objectForKey:@"bikeNo"];
//    // 从本地拿取电话
//    NSString *phoneNumber = [userDefaults objectForKey:@"phoneNumber"];
//                    NSLog(@"returnpay:%@", phoneNumber);
//    // 判断选择了哪一种支付方式
//    NSIndexPath *indexPath = [payListTableView indexPathForSelectedRow];
//    NSInteger selectPayWayNumber = indexPath.row;
//    NSString *isMissngStr = [NSString stringWithFormat:@"%d", myAppdelegate.isMissing];
//    NSLog(@"ismissing:%@", isMissngStr);
//    
//    NSString *urlStr = [IP stringByAppendingString:@"/ElephantBike/api/money/returnpay"];
//    NSURL *url = [NSURL URLWithString:urlStr];
//    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10];
//    NSString *dataStr = [NSString stringWithFormat:@"bikeid=%@&phone=%@&paymode=%@&access_token=%@&ismissing=%@", bikeNo, phoneNumber, [payWay objectAtIndex:selectPayWayNumber],  accessToken, isMissngStr];
//    NSData *data = [dataStr dataUsingEncoding:NSUTF8StringEncoding];
//    [request setHTTPBody:data];
//    [request setHTTPMethod:@"POST"];
//    MyURLConnection *connectionn = [[MyURLConnection alloc] MyConnectioin:request delegate:self andName:@"pay"];
    
    NSLog(@"showsuccess");
}
/*
- (void)showFail {
    NSLog(@"showfail");
    [waitCover removeFromSuperview];
    myAppdelegate.isEndPay = NO;
    // 付款失败
    waitCover = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    waitCover.alpha = 1;
    // 半黑膜
    UIView *containerView = [[UIView alloc] initWithFrame:CGRectMake(0.3*SCREEN_WIDTH, 0.4*SCREEN_HEIGHT, 0.4*SCREEN_WIDTH, 0.15*SCREEN_HEIGHT)];
    containerView.backgroundColor = [UIColor blackColor];
    containerView.alpha = 0.8;
    containerView.layer.cornerRadius = CORNERRADIUS*2;
    [cover addSubview:containerView];
    // 一个控件
    UILabel *hintMes1 = [[UILabel alloc] initWithFrame:CGRectMake(0, 0.4*containerView.frame.size.height, containerView.frame.size.width, 0.2*containerView.frame.size.height)];
    hintMes1.text = @"付款失败";
    hintMes1.textColor = [UIColor whiteColor];
    hintMes1.textAlignment = NSTextAlignmentCenter;
    [containerView addSubview:hintMes1];
    [self.view addSubview:waitCover];
    // 显示时间
    
    NSTimer *gotoQRScanTimer = [NSTimer timerWithTimeInterval:2 target:self selector:@selector(removeView) userInfo:nil repeats:NO];
    [[NSRunLoop mainRunLoop] addTimer:gotoQRScanTimer forMode:NSDefaultRunLoopMode];
}
*/
- (void)changeMemberStatus {
    if (![userDefaults boolForKey:@"isVip"]) {
        [MemberImageView setTitle:@"" forState:UIControlStateNormal];
        [MemberImageView setImage:[UIImage imageNamed:@"会员标识"] forState:UIControlStateNormal];
    }
}

#pragma mark - InfoViewControllerDelegate
- (void)getNextViewController:(id)nextViewController {
    [self hiddenMenu];
    cover.hidden = YES;
    [self.navigationController pushViewController:nextViewController animated:YES];
}

- (void)removeFromSuperView {
    [self hiddenCover];
    // 收到验证码  进行提示
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
    hintMes1.text = @"退出成功";
    hintMes1.textColor = [UIColor whiteColor];
    hintMes1.textAlignment = NSTextAlignmentCenter;
    [containerView addSubview:hintMes1];
    [self.view addSubview:waitCover];
    // 显示时间
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(removeViewThenToLogin) userInfo:nil repeats:NO];
    [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)removeViewThenToLogin   {
    [waitCover removeFromSuperview];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

#pragma mark - ChargeViewControllerDelegate
- (void)getMoney:(NSString *)money andTime:(NSString *)time {
    _money = money;
    _time  = time;
    NSString *temp = [@"￥" stringByAppendingString:_money];
    moneyLabel.text = temp;
    timeLabel.text = _time;
}

#pragma mark - QuestionViewControllerDelegate
- (void)getMoney:(NSString *)money andTime:(NSString *)time andIsLose:(BOOL)isLose{
    // 丢失的话 label 会变
    CGFloat moneyNumber = [money floatValue];
    money = [NSString stringWithFormat:@"%.2f", moneyNumber];
    if (isLose) {
        _money = money;
        _time = time;
        NSLog(@"money:%@", money);
        totalPayLabel.text = @"费用总计:";
        NSString *temp = [@"￥" stringByAppendingString:money];
        moneyLabel.text = temp;
        totalTimeLabel.text = @"单车丢失赔偿金:";
        NSString *temp1 = [@"￥" stringByAppendingString:money];
        timeLabel.text = temp1;
    }else {
        _money = money;
        _time = time;
        NSLog(@"delegate里面的——money:%@", _money);
        NSString *temp = [@"￥" stringByAppendingString:_money];
        moneyLabel.text = temp;
        timeLabel.text = _time;
        NSLog(@"ques delegate");
    }
}

#pragma mark - TableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return  1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"Cell";
    MyTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[MyTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    }
    if (indexPath.row == 0) {
        cell.imageView.image = [UIImage imageNamed:@"绿色LOGO"];
    }else {
        cell.imageView.image = [UIImage imageNamed:[payWay objectAtIndex:indexPath.row]];
    }
    //设置imaged大小
    CGSize itemSize = CGSizeMake(PAYLISTTABLEVIEW_HEIGHT/3*0.8, PAYLISTTABLEVIEW_HEIGHT/3*0.8);
    UIGraphicsBeginImageContext(itemSize);
    CGRect imageRect = CGRectMake(0.0, 0.0, itemSize.width, itemSize.height);
    [cell.imageView.image drawInRect:imageRect];
    cell.imageView.image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    cell.textLabel.text = [payWay objectAtIndex:indexPath.row];
    cell.textLabel.font = [UIFont fontWithName:@"QingYuanMono" size:18];
    cell.detailTextLabel.text = [wayDetails objectAtIndex:indexPath.row];
    cell.detailTextLabel.font = [UIFont fontWithName:@"QingYuanMono" size:12];
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
    return PAYLISTTABLEVIEW_HEIGHT/3;
}

#pragma mark - alertView Delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == 0) {
        if (buttonIndex == 0) {
            RechargeViewController *rechargeViewController = [[RechargeViewController alloc] init];
            [self.navigationController pushViewController:rechargeViewController animated:YES];
        }
    }
}


#pragma mark - 返回app时调用接口判断是否支付成功
- (void)isWXPay {
//    [waitCover removeFromSuperview];
    NSString *urlStr = [IP stringByAppendingString:@"/ElephantBike/api/pay/wxorderquery"];
    NSURL *url = [NSURL URLWithString:urlStr];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10];
    NSString *phoneNumber = [userDefaults objectForKey:@"phoneNumber"];
    NSString *dataStr = [NSString stringWithFormat:@"phone=%@", phoneNumber];
    NSData *data = [dataStr dataUsingEncoding:NSUTF8StringEncoding];
    [request setHTTPBody:data];
    [request setHTTPMethod:@"POST"];
    MyURLConnection *connectionn = [[MyURLConnection alloc] MyConnectioin:request delegate:self andName:@"wxcheck"];
    NSLog(@"返回支付结果payview");
}

- (void)isAliPay {
    NSString *urlStr = [IP stringByAppendingString:@"/ElephantBike/api/pay/alipayquery"];
    NSURL *url = [NSURL URLWithString:urlStr];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10];
    NSString *dataStr = [NSString stringWithFormat:@"out_trade_no=%@", outTradeNO];
    NSData *data = [dataStr dataUsingEncoding:NSUTF8StringEncoding];
    [request setHTTPBody:data];
    [request setHTTPMethod:@"POST"];
    MyURLConnection *connectionn = [[MyURLConnection alloc] MyConnectioin:request delegate:self andName:@"alipaycheck"];
    NSLog(@"返回支付结果payview");
}



#pragma mark - lifeCycle
- (void)viewWillAppear:(BOOL)animated {
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = BACKGROUNDCOLOR;
    [self UIInit];
    myAppdelegate.isMoneyView = YES;
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    myAppdelegate.isMoneyView = NO;
    if (myAppdelegate.isEndPay) {
        [userDefaults setObject:@"" forKey:@"bikeNo"];
    }
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
