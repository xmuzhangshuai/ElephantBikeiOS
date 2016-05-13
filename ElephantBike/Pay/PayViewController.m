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
#import "ActivityDetailsViewController.h"
#import "ElephantMemberViewController.h"
#pragma mark - 微信支付
#import "WXApi.h"
#import <CommonCrypto/CommonDigest.h>
#import "WXApiObject.h"

#import "UIImageView+WebCache.h"

/**
 *  支付宝支付
 **/
#import "AlipaySDK/AlipaySDK.h"

#define CHARGEVIEW_HEIGHT       0.142*SCREEN_HEIGHT
#define STATUSLABEL_WIDTH       0.272*SCREEN_WIDTH
#define STATUSLABEL_HEIGHT      0.34*CHARGEVIEW_HEIGHT
#define QUESTIONBUTTON_WIDTH    0.068*SCREEN_WIDTH
#define QUESTIONBUTTON_HEIGHT   0.331*CHARGEVIEW_HEIGHT
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

#define CALCRULEVIEW_WIDTH      0.601*SCREEN_WIDTH
#define CALCRULEVIEW_HEIGHT     0.306*SCREEN_HEIGHT
#define CALCRULEVIEW_CENTER_X   0.5*SCREEN_WIDTH
#define CALCRULEVIEW_CENTER_Y   0.484*SCREEN_HEIGHT

#define CALCRULELABEL_WIDTH     CALCRULEVIEW_WIDTH
#define CALCRULELABEL_HEIGHT    0.193*SCREEN_HEIGHT
#define CALCRULELABEL_CENTER_Y  0.3575*SCREEN_HEIGHT

#define LABEL_WIDTH             CALCRULEVIEW_WIDTH
#define LABEL_HEIGHT            CALCRULEVIEW_HEIGHT/5
#define LABEL1_CENTER_Y         0.4*SCREEN_HEIGHT
#define LABEL2_CENTER_Y         0.47*SCREEN_HEIGHT
#define LABEL3_CENTER_Y         0.53*SCREEN_HEIGHT
#define CALCRULEBUTTON_CENTER_Y 0.59*SCREEN_HEIGHT
#define CALCRULEBUTTON_WIDTH    0.507*SCREEN_WIDTH
#define CALCRULEBUTTON_HEIGHT   0.0375*SCREEN_HEIGHT



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
    NSString    *WXOutTradeNo;      // 微信订单号
    
    // 计费规则模块
    UIView      *calcRuleView;  // 中间显示的白色view
    UILabel     *calcRuleLabel; // 计费规则label;
    UILabel     *label1;        // 第一个label
    UILabel     *addLabel1;     // 第一个加号label
    UILabel     *label2;        // 第二个label
    UILabel     *addLabel2;     // 第二个加号label
    UILabel     *label3;        // 第三个label
    UIButton    *calcRuleButton;    // 知道了button
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
            NSString *dataStr = [NSString stringWithFormat:@"phone=%@&isfinish=%@&access_token=%@", phoneNumber, isEndRidingStr, [userDefaults objectForKey:@"accessToken"]];
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
            NSString *urlStr = [IP stringByAppendingString:@"/ElephantBike/api/bike/bikeidandpass2"];
            NSURL *url = [NSURL URLWithString:urlStr];
            NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10];
            NSString *dataStr = [NSString stringWithFormat:@"phone=%@&access_token=%@",phoneNumber, [userDefaults objectForKey:@"accessToken"]];
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
    
    // 计费规则模块
    calcRuleView = [[UIView alloc] init];
    calcRuleLabel = [[UILabel alloc] init];
    label1 = [[UILabel alloc] init];
    label2 = [[UILabel alloc] init];
    label3 = [[UILabel alloc] init];
    addLabel1 = [[UILabel alloc] init];
    addLabel2 = [[UILabel alloc] init];
    calcRuleButton = [[UIButton alloc] init];

    
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
//    chargeView.center = CGPointMake(0.5*SCREEN_WIDTH, 0.1672*SCREEN_HEIGHT);
    
    // statusLabel questionButton totalpaylabel -----timelabel
//    statusLabel.frame = CGRectMake(chargeView.center.x-STATUSLABEL_WIDTH/2-QUESTIONBUTTON_WIDTH/2, 0, STATUSLABEL_WIDTH, STATUSLABEL_HEIGHT);
    if (iPhone5) {
        statusLabel.frame = CGRectMake(chargeView.center.x-STATUSLABEL_WIDTH/2-QUESTIONBUTTON_WIDTH/2+QUESTIONBUTTON_WIDTH/2, 0, 0.217*SCREEN_WIDTH, 0.238*chargeView.frame.size.height);
        statusLabel.center = CGPointMake(0.501*SCREEN_WIDTH, 0.25*chargeView.frame.size.height);
    }else {
        statusLabel.frame = CGRectMake(chargeView.center.x-STATUSLABEL_WIDTH/2-QUESTIONBUTTON_WIDTH/2+QUESTIONBUTTON_WIDTH/2, 0, 0.217*SCREEN_WIDTH, 0.238*chargeView.frame.size.height);
        statusLabel.center = CGPointMake(0.501*SCREEN_WIDTH, 0.15*chargeView.frame.size.height);
    }
    statusLabel.textAlignment = NSTextAlignmentCenter;
    statusLabel.textColor = [UIColor whiteColor];
    //    statusLabel.text = @"计费结束";
    
    
    NSMutableAttributedString *content = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"计费结束"]];
    if (iPhone5) {
        [content addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"QingYuanMono" size:17] range:NSMakeRange(0, [content length])];
    }else {
        [content addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"QingYuanMono" size:19] range:NSMakeRange(0, [content length])];
    }
    statusLabel.attributedText = content;
    
    
    
//    questionButton.frame = CGRectMake(statusLabel.center.x+STATUSLABEL_WIDTH/2-QUESTIONBUTTON_WIDTH/2, 0, QUESTIONBUTTON_WIDTH, QUESTIONBUTTON_HEIGHT);
    if (iPhone5) {
        questionButton.frame = CGRectMake(statusLabel.center.x+0.217*SCREEN_WIDTH*0.5-QUESTIONBUTTON_WIDTH/2, 0, QUESTIONBUTTON_WIDTH, QUESTIONBUTTON_HEIGHT);
        questionButton.center = CGPointMake(0.643*SCREEN_WIDTH, 0.267*chargeView.frame.size.height);
    }else{
        questionButton.frame = CGRectMake(statusLabel.center.x+0.217*SCREEN_WIDTH*0.5-QUESTIONBUTTON_WIDTH/2, 0, QUESTIONBUTTON_WIDTH, QUESTIONBUTTON_HEIGHT);
        questionButton.center = CGPointMake(0.643*SCREEN_WIDTH, 0.167*chargeView.frame.size.height);
    }
    [questionButton setImage:[UIImage imageNamed:@"问号"] forState:UIControlStateNormal];
    [questionButton setImageEdgeInsets:UIEdgeInsetsMake(0, -QUESTIONBUTTON_WIDTH/2, 0, 0)];
    [questionButton addTarget:self action:@selector(CalcWay) forControlEvents:UIControlEventTouchUpInside];
    
//    MemberImageView.frame = CGRectMake(0, 0, 0.19*SCREEN_WIDTH, 0.03*SCREEN_HEIGHT);
//    MemberImageView.center = CGPointMake(0.5*SCREEN_WIDTH, 0.045*SCREEN_HEIGHT);
    //会员图标的位置确定
    if (iPhone5) {
        MemberImageView.frame = CGRectMake(0, 0, 0.19*SCREEN_WIDTH, 0.03*SCREEN_HEIGHT);
        MemberImageView.center = CGPointMake(0.5*SCREEN_WIDTH, 0.065*SCREEN_HEIGHT);
    }else {
        MemberImageView.frame = CGRectMake(0, 0, 0.19*SCREEN_WIDTH, 0.03*SCREEN_HEIGHT);
        MemberImageView.center = CGPointMake(0.5*SCREEN_WIDTH, 0.052*SCREEN_HEIGHT);
    }
    
    
    MemberImageView.titleLabel.font = [UIFont fontWithName:@"QingYuanMono" size:10];
    MemberImageView.userInteractionEnabled = NO;
    //需要去判断，是否是会员
    if ([userDefaults boolForKey:@"isVip"]) {
        [MemberImageView setTitle:@"" forState:UIControlStateNormal];
        [MemberImageView setImage:[UIImage imageNamed:@"会员标识"] forState:UIControlStateNormal];
    }else {
        [MemberImageView setTitle:@"非大象会员" forState:UIControlStateNormal];
        [MemberImageView setImage:nil forState:UIControlStateNormal];
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
    totalPayLabel.frame = CGRectMake(0.05*SCREEN_WIDTH, 0.097*SCREEN_HEIGHT, TOTALPAYLABEL_WIDTH, TOTALPAYLABEL_HEIGHT);
    totalPayLabel.textAlignment = NSTextAlignmentLeft;
//    totalPayLabel.font = [UIFont systemFontOfSize:19];
    totalPayLabel.textColor = [UIColor whiteColor];
    NSMutableAttributedString *totalPayLabelcontent = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"费用总计"]];
    [totalPayLabelcontent addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"QingYuanMono" size:19] range:NSMakeRange(0, [totalPayLabelcontent length])];
    totalPayLabel.attributedText = totalPayLabelcontent;
    
    
    moneyLabel.frame = CGRectMake(SCREEN_WIDTH-MONEYLABEL_WIDTH-0.05*SCREEN_WIDTH, 0.1*SCREEN_HEIGHT, MONEYLABEL_WIDTH, MONEYLABEL_HEIGHT);
    moneyLabel.textAlignment = NSTextAlignmentRight;
    moneyLabel.font = [UIFont fontWithName:@"QingYuanMono" size:20];
    moneyLabel.textColor = [UIColor whiteColor];
    
    
    totalTimeLabel.frame = CGRectMake(0.05*SCREEN_WIDTH, 0.078*SCREEN_HEIGHT, TOTALTIME_WIDTH, TOTALTIME_HEIGHT);
    totalTimeLabel.textAlignment = NSTextAlignmentLeft;
//    totalTimeLabel.font = [UIFont systemFontOfSize:12];
    totalTimeLabel.textColor = [UIColor whiteColor];
    //    totalTimeLabel.text = @"使用时长：";
    NSMutableAttributedString *totalTimeLabelcontent = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"使用时长:"]];
    [totalTimeLabelcontent addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"QingYuanMono" size:13] range:NSMakeRange(0, [totalTimeLabelcontent length])];
    totalTimeLabel.attributedText = totalTimeLabelcontent;
    
    
    
    
    timeLabel.frame = CGRectMake(SCREEN_WIDTH-TIMELABEL_WIDTH-0.05*SCREEN_WIDTH, 0.078*SCREEN_HEIGHT, TIMELABEL_WIDTH, TIMELABEL_HEIGHT);
    timeLabel.textAlignment = NSTextAlignmentRight;
    timeLabel.textColor = [UIColor whiteColor];
    timeLabel.font = [UIFont fontWithName:@"QingYuanMono" size:11];
    
    payListTableView.frame = CGRectMake(0, 0.28*SCREEN_HEIGHT, SCREEN_WIDTH, PAYLISTTABLEVIEW_HEIGHT);
    payListTableView.dataSource = self;
    payListTableView.delegate = self;
    payListTableView.scrollEnabled = NO;
    [payListTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    payListTableView.layer.borderWidth = 1;
    payListTableView.layer.borderColor = [UIColor grayColor].CGColor;
    
    confirmButton.frame = CGRectMake(0.1*SCREEN_WIDTH, 0.63*SCREEN_HEIGHT, CONFIRMBUTTON_WIDTH, CONFIRMBUTTON_HEIGHT);
    confirmButton.layer.cornerRadius = CORNERRADIUS;
    confirmButton.backgroundColor = UICOLOR;
    [confirmButton setTitle:@"确认支付" forState:UIControlStateNormal];
    confirmButton.titleLabel.font = [UIFont fontWithName:@"QingYuanMono" size:14];
    if (iPhone6P) {
        confirmButton.titleLabel.font = [UIFont fontWithName:@"QingYuanMono" size:18];
    }
    [confirmButton addTarget:self action:@selector(QRCodeScanView) forControlEvents:UIControlEventTouchUpInside];
    
    hintMes.frame = CGRectMake(0.1*SCREEN_WIDTH, 0.63*SCREEN_HEIGHT+CONFIRMBUTTON_HEIGHT, CONFIRMBUTTON_WIDTH, CONFIRMBUTTON_HEIGHT);
    hintMes.text = @"任何支付问题，请联系客服：400-123-123";
    hintMes.textAlignment = NSTextAlignmentCenter;
    hintMes.textColor = [UIColor grayColor];
    hintMes.font = [UIFont fontWithName:@"QingYuanMono" size:12];
    
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
    
    // 计费规则模块
    calcRuleView.frame = CGRectMake(0,0, CALCRULEVIEW_WIDTH, CALCRULEVIEW_HEIGHT);
    calcRuleView.center = CGPointMake(CALCRULEVIEW_CENTER_X, CALCRULEVIEW_CENTER_Y);
    calcRuleView.clipsToBounds = YES;
    calcRuleView.layer.cornerRadius = CORNERRADIUS;
    calcRuleView.backgroundColor = [UIColor whiteColor];
    calcRuleView.hidden = YES;
    calcRuleView.layer.borderWidth = 1;
    calcRuleView.layer.borderColor = [UIColor blackColor].CGColor;
    [self.view addSubview:calcRuleView];
    
    calcRuleLabel.frame = CGRectMake(0, 0, CALCRULELABEL_WIDTH, CALCRULELABEL_HEIGHT);
    calcRuleLabel.center = CGPointMake(CALCRULEVIEW_CENTER_X, CALCRULELABEL_CENTER_Y);
    calcRuleLabel.text = @"计费规则";
    calcRuleLabel.textAlignment = NSTextAlignmentCenter;
    calcRuleLabel.font = [UIFont fontWithName:@"QingYuanMono" size:14];
    if (iPhone6P) {
        calcRuleLabel.font = [UIFont fontWithName:@"QingYuanMono" size:18];
    }
    calcRuleLabel.hidden = YES;
    [self.view addSubview:calcRuleLabel];
    
    label1.frame = CGRectMake(0, 0, LABEL_WIDTH, LABEL_HEIGHT);
    label1.center = CGPointMake(CALCRULEVIEW_CENTER_X, LABEL1_CENTER_Y);
    label1.textColor = [UIColor grayColor];
    label1.font = [UIFont fontWithName:@"QingYuanMono" size:12];
    if (iPhone6P) {
        label1.font = [UIFont fontWithName:@"QingYuanMono" size:16];
    }
    label1.textAlignment = NSTextAlignmentCenter;
    label1.numberOfLines = 2;
    NSMutableAttributedString *label1Attribute = [[NSMutableAttributedString alloc] initWithString:@"1 . 0 0 元 起 步 价\n(大 象 会 员 免 起 步 费)"];
    [label1Attribute addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle] range:NSMakeRange(16, 16)];
    [label1Attribute addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:NSMakeRange(16, 16)];
    [label1 setAttributedText:label1Attribute];
    label1.hidden = YES;
    label1.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(gotoMember)];
    [label1 addGestureRecognizer:tap];
    [self.view addSubview:label1];
    
    addLabel1.frame = CGRectMake(0, 0, 50, 50);
    addLabel1.center = CGPointMake(0.5*SCREEN_WIDTH, 0.5*SCREEN_HEIGHT);
    addLabel1.text = @"+";
    addLabel1.textAlignment = NSTextAlignmentCenter;
    addLabel1.font = [UIFont fontWithName:@"QingYuanMono" size:10];
    addLabel1.hidden = YES;
    [self.view addSubview:addLabel1];
    
    addLabel2.frame = CGRectMake(0, 0, 50, 50);
    addLabel2.center = CGPointMake(0.5*SCREEN_WIDTH, 0.4377*SCREEN_HEIGHT);
    addLabel2.text = @"+";
    addLabel2.textAlignment = NSTextAlignmentCenter;
    addLabel2.hidden = YES;
    [self.view addSubview:addLabel2];
    addLabel2.font = [UIFont fontWithName:@"QingYuanMono" size:10];
    label2.frame = CGRectMake(0, 0, LABEL_WIDTH, LABEL_HEIGHT);
    label2.center = CGPointMake(CALCRULEVIEW_CENTER_X, LABEL2_CENTER_Y);
    label2.textColor = [UIColor grayColor];
    label2.font = [UIFont fontWithName:@"QingYuanMono" size:12];
    if (iPhone6P) {
        label2.font = [UIFont fontWithName:@"QingYuanMono" size:16];
    }
    label2.textAlignment = NSTextAlignmentCenter;
    label2.numberOfLines = 2;
    label2.text = @"0 . 0 6 元 / 分 钟\n(6 0 分 钟 以 内 的 部 分)";
    label2.hidden = YES;
    [self.view addSubview:label2];
    
    label3.frame = CGRectMake(0, 0, LABEL_WIDTH, LABEL_HEIGHT);
    label3.center = CGPointMake(CALCRULEVIEW_CENTER_X, LABEL3_CENTER_Y);
    label3.textColor = [UIColor grayColor];
    label3.font = [UIFont fontWithName:@"QingYuanMono" size:12];
    if (iPhone6P) {
        label3.font = [UIFont fontWithName:@"QingYuanMono" size:16];
    }
    label3.textAlignment = NSTextAlignmentCenter;
    label3.numberOfLines = 2;
    label3.text = @"0 . 0 2 元 / 分 钟\n(超 过 6 0 分 钟 的 部 分)";
    label3.hidden = YES;
    [self.view addSubview:label3];
    
    calcRuleButton.frame = CGRectMake(0, 0, CALCRULEBUTTON_WIDTH, CALCRULEBUTTON_HEIGHT);
    calcRuleButton.center = CGPointMake(CALCRULEVIEW_CENTER_X, CALCRULEBUTTON_CENTER_Y);
    calcRuleButton.titleLabel.font = [UIFont fontWithName:@"QingYuanMono" size:10];
    calcRuleButton.layer.borderColor = [UIColor blackColor].CGColor;
    calcRuleButton.layer.borderWidth = 1;
    calcRuleButton.layer.cornerRadius = CORNERRADIUS;
    [calcRuleButton setTitle:@"知道了" forState:UIControlStateNormal];
    [calcRuleButton setTitleColor:[UIColor colorWithRed:150/255.0 green:150/255.0 blue:150/255.0 alpha:1.0] forState:UIControlStateNormal];
    calcRuleButton.hidden = YES;
    [calcRuleButton addTarget:self action:@selector(cancle) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:calcRuleButton];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeMemberStatus) name:@"isVip" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateMessage) name:@"updateMessage" object:nil];
}

- (void)NavigationInit {
    UIImageView *titleImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 0.1133*SCREEN_WIDTH, 0.0412*SCREEN_HEIGHT)];
    titleImageView.image = [UIImage imageNamed:@"LOGO"];
    titleImageView.contentMode = UIViewContentModeScaleAspectFit;
    
    UIView *view1 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0.1133*SCREEN_WIDTH, 0.0412*SCREEN_HEIGHT)];
    [view1 addSubview:titleImageView];
    self.navigationItem.titleView = view1;
    UIBarButtonItem *infoButton;
    if ([userDefaults boolForKey:@"isMessage"]) {
        infoButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"个人中心未读"] style:UIBarButtonItemStylePlain target:self action:@selector(information)];
    }else {
        infoButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"个人中心"] style:UIBarButtonItemStylePlain target:self action:@selector(information)];
    }
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
        NSString *dataStr = [NSString stringWithFormat:@"phone=%@&access_token=%@", phoneNumber, [userDefaults objectForKey:@"accessToken"]];
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
            NSString *dataStr = [NSString stringWithFormat:@"phone=%@&bikeid=%@&access_token=%@", phoneNumber, bikeno, [userDefaults objectForKey:@"accessToken"]];
            NSData *data = [dataStr dataUsingEncoding:NSUTF8StringEncoding];
            [request setHTTPBody:data];
            [request setHTTPMethod:@"POST"];
            myAppdelegate.isGoToPay = YES;
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
            NSString *dataStr = [NSString stringWithFormat:@"phone=%@&totalfee=%@&bikeid=%@&subject=%@&body=%@&access_token=%@", phoneNumber, _money, bikeno, @"大象单车订单付款", @"金额", [userDefaults objectForKey:@"accessToken"]];
            NSData *data = [dataStr dataUsingEncoding:NSUTF8StringEncoding];
            [request setHTTPBody:data];
            [request setHTTPMethod:@"POST"];
            myAppdelegate.isGoToPay = YES;
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
            UIImageView *success = [[UIImageView alloc] initWithFrame:CGRectMake(0.3*containerView.frame.size.width, (containerView.frame.size.height-0.4*containerView.frame.size.width)/2, 0.4*containerView.frame.size.width, 0.4*containerView.frame.size.width)];
            [success setImage:[UIImage imageNamed:@"成功"]];
            success.contentMode = UIViewContentModeScaleToFill;
            [containerView addSubview:success];
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
            if ([message rangeOfString:@"invalid token"].location != NSNotFound) {
                // 账号在别的地方登陆
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"您的身份验证已过期，请重新登录" delegate:self cancelButtonTitle:@"好的" otherButtonTitles:nil, nil];
                alertView.tag = 10;
                [alertView show];
            }else {
                NSLog(@"付款失败：%@",message);
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"付款失败" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                [alert show];
            }
        }
    }else if ([connection.name isEqualToString:@"getCostAndTime"]) {
        NSString *status = receiveJson[@"status"];
        NSString *money = receiveJson[@"cost"];
        NSString *time = receiveJson[@"usedtime"];
        NSString *message = receiveJson[@"message"];
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
                totalTimeLabel.text = @"使用时长:";
                NSString *temp1 = [@"￥" stringByAppendingString:time];
                timeLabel.text = temp1;
            }else {
                myAppdelegate.isMissing = NO;
                _money = money;
                _time = time;
                //增加取两位判断
                CGFloat moneyNum = [money floatValue];
                money = [NSString stringWithFormat:@"%.2f", moneyNum];
                
                NSString *temp = [@"￥" stringByAppendingString:money];
                moneyLabel.text = temp;
                timeLabel.text = _time;
                NSLog(@"未付款获得金额赋值");
            }
            NSString *bikeno = [userDefaults objectForKey:@"bikeNo"];
            if (!bikeno) {
                NSString *phoneNumber = [userDefaults objectForKey:@"phoneNumber"];
                NSString *urlStr = [IP stringByAppendingString:@"/ElephantBike/api/bike/bikeidandpass2"];
                NSURL *url = [NSURL URLWithString:urlStr];
                NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10];
                NSString *dataStr = [NSString stringWithFormat:@"phone=%@&access_token=%@",phoneNumber, [userDefaults objectForKey:@"accessToken"]];
                NSData *data = [dataStr dataUsingEncoding:NSUTF8StringEncoding];
                [request setHTTPBody:data];
                [request setHTTPMethod:@"POST"];
//                MyURLConnection *connectionn = [[MyURLConnection alloc] MyConnectioin:request delegate:self andName:@"getBikeidAndPass"];
            }
        }else {
            if ([message rangeOfString:@"invalid token"].location != NSNotFound) {
                // 账号在别的地方登陆
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"您的身份验证已过期，请重新登录" delegate:self cancelButtonTitle:@"好的" otherButtonTitles:nil, nil];
                alertView.tag = 10;
                [alertView show];
            }
        }
    }else if ([connection.name isEqualToString:@"balance"]) {
        NSString *status = receiveJson[@"status"];
        NSString *balance = receiveJson[@"balance"];
        NSString *message = receiveJson[@"message"];
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
        }else {
            if ([message rangeOfString:@"invalid token"].location != NSNotFound) {
                // 账号在别的地方登陆
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"您的身份验证已过期，请重新登录" delegate:self cancelButtonTitle:@"好的" otherButtonTitles:nil, nil];
                alertView.tag = 10;
                [alertView show];
            }
        }
    }else if ([connection.name isEqualToString:@"getPrepay"]) {
        NSString *status = receiveJson[@"status"];
        NSString *message = receiveJson[@"message"];
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
            if ([message rangeOfString:@"invalid token"].location != NSNotFound) {
                // 账号在别的地方登陆
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"您的身份验证已过期，请重新登录" delegate:self cancelButtonTitle:@"好的" otherButtonTitles:nil, nil];
                alertView.tag = 10;
                [alertView show];
            }
        }
    }else if ([connection.name isEqualToString:@"getBikeidAndPass"]) {
        NSString *status = receiveJson[@"status"];
        NSString *bikeno = receiveJson[@"bikeid"];
        NSString *message = receiveJson[@"message"];
        if ([status isEqualToString:@"success"]) {
            [userDefaults setObject:bikeno forKey:@"bikeNo"];
            bikeLabel.text = bikeno;
            NSLog(@"getbikeidandpass bikeno:%@", bikeno);
        }else {
            if ([message rangeOfString:@"invalid token"].location != NSNotFound) {
                // 账号在别的地方登陆
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"您的身份验证已过期，请重新登录" delegate:self cancelButtonTitle:@"好的" otherButtonTitles:nil, nil];
                alertView.tag = 10;
                [alertView show];
            }
        }
    }else if ([connection.name isEqualToString:@"wxcheck"]) {
        myAppdelegate.isGoToPay = NO;
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
            UIImageView *success = [[UIImageView alloc] initWithFrame:CGRectMake(0.3*containerView.frame.size.width, (containerView.frame.size.height-0.4*containerView.frame.size.width)/2, 0.4*containerView.frame.size.width, 0.4*containerView.frame.size.width)];
            [success setImage:[UIImage imageNamed:@"成功"]];
            success.contentMode = UIViewContentModeScaleToFill;
            [containerView addSubview:success];
            [self.view addSubview:waitCover];
            // 显示时间
            NSTimer *gotoQRScanTimer = [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(gotoQRScan) userInfo:nil repeats:NO];
        }else {
            // 付款失败
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"付款失败，请重试" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alertView show];
        }
    }else if([connection.name isEqualToString:@"getAlipay"]) {
        NSString *status = receiveJson[@"status"];
        NSString *message = receiveJson[@"message"];
        if ([status isEqualToString:@"success"]) {
            NSString *appScheme = @"alisdkdemo";
        
            NSString *param = receiveJson[@"param"];
            NSString *sign = receiveJson[@"sign"];
            NSString *sign_type = receiveJson[@"sign_type"];
            outTradeNO = receiveJson[@"out_trade_no"];
            
            NSString *orderString = nil;
            orderString = [NSString stringWithFormat:@"%@&sign=\"%@\"&sign_type=\"%@\"", param,  sign, sign_type];
            
            NSArray *array = [[UIApplication sharedApplication] windows];
            UIWindow* win=[array objectAtIndex:0];
            [win setHidden:YES];
            [[AlipaySDK defaultService] payOrder:orderString fromScheme:appScheme callback:^(NSDictionary *resultDic) {
                NSLog(@"result=%@", resultDic);
                // 请求
                
            }];
        }else {
            if ([message rangeOfString:@"invalid token"].location != NSNotFound) {
                // 账号在别的地方登陆
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"您的身份验证已过期，请重新登录" delegate:self cancelButtonTitle:@"好的" otherButtonTitles:nil, nil];
                alertView.tag = 10;
                [alertView show];
            }
        }
    }else if ([connection.name isEqualToString:@"alipaycheck"]) {
        myAppdelegate.isGoToPay = NO;
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
            UIImageView *success = [[UIImageView alloc] initWithFrame:CGRectMake(0.3*containerView.frame.size.width, (containerView.frame.size.height-0.4*containerView.frame.size.width)/2, 0.4*containerView.frame.size.width, 0.4*containerView.frame.size.width)];
            [success setImage:[UIImage imageNamed:@"成功"]];
            success.contentMode = UIViewContentModeScaleToFill;
            [containerView addSubview:success];
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
    hintMes1.text = @"请检查您的网络";
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
    if ([userDefaults boolForKey:@"isVip"]) {
        [MemberImageView setTitle:@"" forState:UIControlStateNormal];
        [MemberImageView setImage:[UIImage imageNamed:@"会员标识"] forState:UIControlStateNormal];
    }else {
        [MemberImageView setTitle:@"非大象会员" forState:UIControlStateNormal];
        [MemberImageView setImage:nil forState:UIControlStateNormal];
    }
}

- (void)updateMessage {
    UIBarButtonItem *infoButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"个人中心"] style:UIBarButtonItemStylePlain target:self action:@selector(information)];
    infoButton.tintColor = [UIColor grayColor];
    self.navigationItem.leftBarButtonItem = infoButton;
}

- (void)gotoMember {
    ElephantMemberViewController *openMemberViewController = [[ElephantMemberViewController alloc] init];
    [self.navigationController pushViewController:openMemberViewController animated:YES];
}
- (void)CalcWay {
    calcRuleView.hidden = NO;
    calcRuleLabel.hidden = NO;
    label1.hidden = NO;
    addLabel1.hidden = NO;
    label2.hidden = NO;
    addLabel2.hidden = NO;
    label3.hidden = NO;
    calcRuleButton.hidden = NO;
}

- (void)cancle {
    calcRuleView.hidden = YES;
    calcRuleLabel.hidden = YES;
    label1.hidden = YES;
    addLabel1.hidden = YES;
    addLabel2.hidden = YES;
    label2.hidden = YES;
    label3.hidden = YES;
    calcRuleButton.hidden = YES;
}

#pragma mark - InfoViewControllerDelegate
- (void)getNextViewController:(id)nextViewController {
    [self hiddenMenu];
    cover.hidden = YES;
    [self.navigationController pushViewController:nextViewController animated:YES];
}

- (void)removeFromSuperView {
    self.navigationItem.leftBarButtonItem.enabled = NO;
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
    self.navigationItem.leftBarButtonItem.enabled = YES;
    [waitCover removeFromSuperview];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

#pragma mark - ChargeViewControllerDelegate
- (void)getMoney:(NSString *)money andTime:(NSString *)time {
    _money = money;
    _time  = time;
    //增加取两位判断
    CGFloat moneyNum = [money floatValue];
    money = [NSString stringWithFormat:@"%.2f", moneyNum];
    
    NSString *temp = [@"￥" stringByAppendingString:money];
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
        totalTimeLabel.text = @"使用时长:";
        NSString *temp1 = [@"￥" stringByAppendingString:time];
        timeLabel.text = temp1;
    }else {
        _money = money;
        _time = time;
        NSLog(@"delegate里面的——money:%@", _money);
        //增加取两位判断
        CGFloat moneyNum = [money floatValue];
        money = [NSString stringWithFormat:@"%.2f", moneyNum];
        
        NSString *temp = [@"￥" stringByAppendingString:money];
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
        cell.imageView.image = [UIImage imageNamed:@"大象钱包"];
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
    
    NSString *temp = [[payWay objectAtIndex:indexPath.row] stringByAppendingString:@"\n"];
    NSString *lastTemp = [temp stringByAppendingString:[wayDetails objectAtIndex:indexPath.row]];
    NSMutableAttributedString *cellcontent = [[NSMutableAttributedString alloc] initWithString:lastTemp];
    
    cell.textLabel.font = [UIFont fontWithName:@"QingYuanMono" size:11];
    if ([[wayDetails objectAtIndex:indexPath.row] isEqualToString:@"支付宝"]) {
        [cellcontent addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"QingYuanMono" size:17] range:NSMakeRange(0, 3)];
    }else {
        [cellcontent addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"QingYuanMono" size:17] range:NSMakeRange(0, 4)];
    }
    /** 设置 行间距*/
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setLineSpacing:6];
    [cellcontent addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [lastTemp length])];
    
    cell.textLabel.attributedText = cellcontent;
    cell.textLabel.numberOfLines = 0;
    
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
    }else if (alertView.tag == 10) {
        myAppdelegate.isLogout = YES;
            // 退出登录
        myAppdelegate.isIdentify = NO;
        myAppdelegate.isFreeze = NO;
        myAppdelegate.isEndPay = YES;
        myAppdelegate.isEndRiding = YES;
        myAppdelegate.isRestart = NO;
        myAppdelegate.isMissing = NO;
        myAppdelegate.isUpload = NO;
        myAppdelegate.isLogin = NO;
        myAppdelegate.isLogout = YES;
        myAppdelegate.isLinked = YES;
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


#pragma mark - 返回app时调用接口判断是否支付成功
- (void)isWXPay {
//    [waitCover removeFromSuperview];
    NSString *urlStr = [IP stringByAppendingString:@"/ElephantBike/api/pay/wxorderquery"];
    NSURL *url = [NSURL URLWithString:urlStr];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10];
    NSString *phoneNumber = [userDefaults objectForKey:@"phoneNumber"];
    NSString *dataStr = [NSString stringWithFormat:@"out_trade_no=%@", WXOutTradeNo];
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

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = BACKGROUNDCOLOR;
    [self UIInit];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    myAppdelegate.isMoneyView = YES;
}

- (void)viewWillDisappear:(BOOL)animated {
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
