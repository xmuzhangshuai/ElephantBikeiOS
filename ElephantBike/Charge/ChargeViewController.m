//
//  ChargeViewController.m
//  ElephantBike
//
//  Created by 黄杰锋 on 16/1/15.
//  Copyright © 2016年 黄杰锋. All rights reserved.
//

#import "ChargeViewController.h"
#import "UISize.h"
#import "ModalPayView.h"
#import "QuestionViewController.h"
#import "PayViewController.h"
#import "CalcWayViewController.h"
#import "HJFScrollNumberView.h"
#import "QRCodeScanViewController.h"
#import "MyURLConnection.h"
#import "MeetQuestionViewController.h"
#import "ActivityDetailsViewController.h"
#import "ElephantMemberViewController.h"
#import "UIImageView+WebCache.h"

#pragma mark - 百度地图
#import <BaiduMapAPI_Location/BMKLocationComponent.h>
/* 实现左侧菜单页面跳转 */
#import "InfoViewController.h"
#import "AppDelegate.h"


//#define CHARGEVIEW_HEIGHT       0.16*SCREEN_HEIGHT
#define CHARGEVIEW_HEIGHT       0.142*SCREEN_HEIGHT

//#define STATUSLABEL_WIDTH       0.33*SCREEN_WIDTH
#define STATUSLABEL_WIDTH       0.272*SCREEN_WIDTH

#define STATUSLABEL_HEIGHT      0.34*CHARGEVIEW_HEIGHT
//#define QUESTIONBUTTON_WIDTH    STATUSLABEL_HEIGHT
#define QUESTIONBUTTON_WIDTH    0.068*SCREEN_WIDTH

//#define QUESTIONBUTTON_HEIGHT   QUESTIONBUTTON_WIDTH
#define QUESTIONBUTTON_HEIGHT   0.331*CHARGEVIEW_HEIGHT
#define TOTALPAYLABEL_WIDTH     0.25*SCREEN_WIDTH
#define TOTALPAYLABEL_HEIGHT    0.35*CHARGEVIEW_HEIGHT
#define MONEYLABEL_WIDTH        TOTALPAYLABEL_WIDTH
#define MONEYLABEL_HEIGHT       TOTALPAYLABEL_HEIGHT
#define TOTALTIME_WIDTH         TOTALPAYLABEL_WIDTH
#define TOTALTIME_HEIGHT        0.25*CHARGEVIEW_HEIGHT
#define TIMELABEL_WIDTH         TOTALTIME_WIDTH
#define TIMELABEL_HEIGHT        TOTALTIME_HEIGHT

#define BUTTOMVIEW_HEIGHT       0.135*SCREEN_HEIGHT
#define HINTMESBUTTOM_WIDTH     SAME_WIDTH
#define HINTMESBUTTOM_HEIGHT    0.5*BUTTOMVIEW_HEIGHT
#define RETURNBIKE_WIDTH        0.35*SCREEN_WIDTH
#define RETURNBIKE_HEIGHT       0.6*BUTTOMVIEW_HEIGHT
#define RESTOREBIKE_WIDTH       RETURNBIKE_WIDTH
#define RESTOREBIKE_HEIGHT      RETURNBIKE_HEIGHT

#define BIKENUMBER_HEIGHT       0.33*CHARGEVIEW_HEIGHT
#define BIKENUMBER_WIDTH        0.5*SCREEN_WIDTH
//#define PASSWORDMES_HEIGHT      BIKENUMBER_HEIGHT
#define PASSWORDMES_HEIGHT      0.07*SCREEN_HEIGHT
#define PASSWORDMES_WIDTH       0.5*SCREEN_WIDTH
//#define PASSWORDNUMBER_WIDTH    SAME_WIDTH
#define PASSWORDNUMBER_WIDTH    0.68*SCREEN_WIDTH
#define PASSWORDNUMBER_HEIGHT   0.66*BUTTOMVIEW_HEIGHT
#define HINTMES_HEIGHT          0.5*BIKENUMBER_HEIGHT
#define HINTMES_WIDTH           0.5*SCREEN_WIDTH
#define HAVEQUESTION_HEIGHT     HINTMES_HEIGHT*2
#define HAVEQUESTION_WIDTH      PASSWORDMES_WIDTH

#define WRONGPSWINTERVAL        10

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

@interface ChargeViewController () <InfoViewControllerDelegate, QRCodeScanViewControllerDelegate, MyURLConnectionDelegate, BMKLocationServiceDelegate, UIAlertViewDelegate>

@end

@implementation ChargeViewController {
    UIView      *chargeView;
    UILabel     *statusLabel;
    /** 会员图标*/
    UIButton    *MemberImageView;
    
    UIButton    *questionButton;
    UILabel     *totalPayLabel;
    UILabel     *moneyLabel;
    UILabel     *totalTimeLabel;
    UILabel     *timeLabel;
    
    UILabel     *bikeNumber;
    UILabel     *bikeLabel;
    UILabel     *passwordMes;
    UIView      *passwordNumberView;
    HJFScrollNumberView *passwordNumber;
    UILabel     *hintMes;
    UIButton    *haveQuestion;  // button+image?
    
    //预留的广告位
    UIImageView *AdImageView;
    
    UIView      *buttomView;
    UILabel     *hintMesButtom;
    UIButton    *returnBike;
    UIButton    *restoreBike;
    
    NSString    *bikeNo;
    NSString    *unlockPassword;
    NSString    *returnBikeNumber;
    NSString    *restoreBikeNumber;
    
    __block ModalPayView *view;
    UIView      *errorCover;
    
    NSUserDefaults *userDefaults;
    AppDelegate *myAppDelegate;
    
    //侧面菜单
    InfoViewController          *infoViewController;
    UIView                      *cover;
    UISwipeGestureRecognizer    *leftSwipGestureRecognizer;
    
    // 刷新金额和使用时长
    NSTimer *askForMoney;
    
    // 百度地图模块
    BMKLocationService  *_locSerview;
    NSString            *bikePosition;
    
    BOOL        isConnect;
    BOOL        isFinish;
    
    // 输入密码错误模块
    int         wrongPSWCount;  // 错误密码次数
    int         thirdOrFive;    // 三分钟还是五分钟 0 不用， 1 三分钟， 2 五分钟
    int         wrongPSWCount1; // 恢复单车
    
    // 计时模块
    NSTimer     *countTimer;
    
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
    if (self == [super init]) {
        myAppDelegate = [[UIApplication sharedApplication] delegate];
        userDefaults = [NSUserDefaults standardUserDefaults];
        passwordNumberView  = [[UIView alloc] init];
        if (!myAppDelegate.isEndRiding && myAppDelegate.isRestart) {
            // 请求服务器 异步post
            NSLog(@"bikeidandpass");
            NSString *phoneNumber = [userDefaults objectForKey:@"phoneNumber"];
            NSString *urlStr = [IP stringByAppendingString:@"/ElephantBike/api/bike/bikeidandpass2"];
            NSURL *url = [NSURL URLWithString:urlStr];
            NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10];
            NSString *dataStr = [NSString stringWithFormat:@"phone=%@&access_token=%@", phoneNumber, [userDefaults objectForKey:@"accessToken"]];
            NSData *data = [dataStr dataUsingEncoding:NSUTF8StringEncoding];
            [request setHTTPBody:data];
            [request setHTTPMethod:@"POST"];
//            MyURLConnection *connection = [[MyURLConnection alloc] MyConnectioin:request delegate:self andName:@"getBikeNoAndPass"];
            NSData *receiveData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
            NSDictionary *receiveJson = [NSJSONSerialization JSONObjectWithData:receiveData options:NSJSONReadingMutableLeaves error:nil];
            NSString *status = receiveJson[@"status"];
            NSString *bikeNO = receiveJson[@"bikeid"];
            NSString *pass = receiveJson[@"pass"];
            NSString *message = receiveJson[@"message"];
            if ([status isEqualToString:@"success"]) {
                isConnect = YES;
                bikeNo = bikeNO;
                // 讲单车编号写入缓存
                [userDefaults setObject:bikeNO forKey:@"bikeNo"];
                unlockPassword = pass;
            }else {
                if ([message rangeOfString:@"invalid token"].location != NSNotFound) {
                    // 账号在别的地方登陆
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"您的身份验证已过期，请重新登录" delegate:self cancelButtonTitle:@"好的" otherButtonTitles:nil, nil];
                    alertView.tag = 10;
                    [alertView show];
                }
            }
        }
        // 请求广告
        AdImageView     = [[UIImageView alloc] init];
        NSString *urlStr = [IP stringByAppendingString:@"/ElephantBike/api/act/topic"];
        NSURL *url = [NSURL URLWithString:urlStr];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
        NSString *dataStr = [NSString stringWithFormat:@"type=%d", 2];
        NSData *data = [dataStr dataUsingEncoding:NSUTF8StringEncoding];
        [request setHTTPBody:data];
        [request setHTTPMethod:@"POST"];
        MyURLConnection *connection = [[MyURLConnection alloc] MyConnectioin:request delegate:self andName:@"getAD"];
    }
    return self;
}

- (void)stopRequest {
    if (!isConnect) {
        [errorCover removeFromSuperview];
        // 收到验证码  进行提示
        errorCover = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        errorCover.alpha = 1;
        // 半黑膜
        UIView *containerView = [[UIView alloc] initWithFrame:CGRectMake(0.3*SCREEN_WIDTH, 0.4*SCREEN_HEIGHT, 0.4*SCREEN_WIDTH, 0.15*SCREEN_HEIGHT)];
        containerView.backgroundColor = [UIColor blackColor];
        containerView.alpha = 0.8;
        containerView.layer.cornerRadius = CORNERRADIUS*2;
        [errorCover addSubview:containerView];
        // 一个控件
        UILabel *hintMes1 = [[UILabel alloc] initWithFrame:CGRectMake(0, 0.4*containerView.frame.size.height, containerView.frame.size.width, 0.2*containerView.frame.size.height)];
        hintMes1.text = @"无法连接服务器";
        hintMes1.textColor = [UIColor whiteColor];
        hintMes1.textAlignment = NSTextAlignmentCenter;
        [containerView addSubview:hintMes1];
        [self.view addSubview:errorCover];
        // 显示时间
        NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(removeView) userInfo:nil repeats:NO];
        [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
    }
    isConnect = NO;
}

- (void)removeView {
    [errorCover removeFromSuperview];
}

- (void)UIInit {
    chargeView      = [[UIView alloc]init];
    statusLabel     = [[UILabel alloc]init];
    
    MemberImageView = [[UIButton alloc] init];
    
    questionButton  = [[UIButton alloc]init];
    totalPayLabel   = [[UILabel alloc]init];
    moneyLabel      = [[UILabel alloc]init];
    totalTimeLabel  = [[UILabel alloc]init];
    timeLabel       = [[UILabel alloc]init];
    
    bikeNumber      = [[UILabel alloc]init];
    bikeLabel       = [[UILabel alloc] init];
    passwordMes     = [[UILabel alloc]init];
    passwordNumber  = [[HJFScrollNumberView alloc]init];
    hintMes         = [[UILabel alloc]init];
    haveQuestion    = [[UIButton alloc]init];
    
    buttomView      = [[UIView alloc]init];
    hintMesButtom   = [[UILabel alloc]init];
    returnBike      = [[UIButton alloc]init];
    restoreBike     = [[UIButton alloc]init];
    
    isConnect       = NO;
    isFinish        = NO;
    
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

    // 计费规则模块
    calcRuleView = [[UIView alloc] init];
    calcRuleLabel = [[UILabel alloc] init];
    label1 = [[UILabel alloc] init];
    label2 = [[UILabel alloc] init];
    label3 = [[UILabel alloc] init];
    addLabel1 = [[UILabel alloc] init];
    addLabel2 = [[UILabel alloc] init];
    calcRuleButton = [[UIButton alloc] init];
    
    [self NavigationInit];
    [self UILayout];
    
    // 百度地图模块
    _locSerview = [[BMKLocationService alloc] init];
    _locSerview.delegate = self;
    [_locSerview startUserLocationService];
    
    // 错误密码次数模块
    wrongPSWCount = 0;
    thirdOrFive = 0;
    
    
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
    [UIView animateWithDuration:0.4f
                          delay:0.0f
         usingSpringWithDamping:1.0
          initialSpringVelocity:4.0
                        options: UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         infoViewController.view.frame = infoView;
                         cover.hidden = NO;
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
    [UIView animateWithDuration:0.4f
                          delay:0.0f
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
    errorCover = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    errorCover.alpha = 1;
    // 半黑膜
    UIView *containerView = [[UIView alloc] initWithFrame:CGRectMake(0.3*SCREEN_WIDTH, 0.4*SCREEN_HEIGHT, 0.4*SCREEN_WIDTH, 0.15*SCREEN_HEIGHT)];
    containerView.backgroundColor = [UIColor blackColor];
    containerView.alpha = 0.8;
    containerView.layer.cornerRadius = CORNERRADIUS*2;
    [errorCover addSubview:containerView];
    // 一个控件
    UILabel *hintMes1 = [[UILabel alloc] initWithFrame:CGRectMake(0, 0.4*containerView.frame.size.height, containerView.frame.size.width, 0.2*containerView.frame.size.height)];
    hintMes1.text = @"退出成功";
    hintMes1.textColor = [UIColor whiteColor];
    hintMes1.textAlignment = NSTextAlignmentCenter;
    [containerView addSubview:hintMes1];
    [self.view addSubview:errorCover];
    // 显示时间
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(removeViewThenToLogin) userInfo:nil repeats:NO];
    [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
}

- (void)removeViewThenToLogin {
    self.navigationItem.leftBarButtonItem.enabled = YES;
    [errorCover removeFromSuperview];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)UILayout {
    
    chargeView.frame = CGRectMake(0, STATUS_HEIGHT+NAVIGATIONBAR_HEIGHT, SCREEN_WIDTH, CHARGEVIEW_HEIGHT);
    chargeView.backgroundColor = UICOLOR;
//    chargeView.center = CGPointMake(0.5*SCREEN_WIDTH, 0.1672*SCREEN_HEIGHT);
    
    
    // statusLabel questionButton totalpaylabel -----timelabel
    //    statusLabel.frame = CGRectMake(chargeView.center.x-STATUSLABEL_WIDTH/2-QUESTIONBUTTON_WIDTH/2+QUESTIONBUTTON_WIDTH/2, 0, STATUSLABEL_WIDTH, STATUSLABEL_HEIGHT);
    if (iPhone5) {
        statusLabel.frame = CGRectMake(chargeView.center.x-STATUSLABEL_WIDTH/2-QUESTIONBUTTON_WIDTH/2+QUESTIONBUTTON_WIDTH/2, 0, STATUSLABEL_WIDTH, 0.238*chargeView.frame.size.height);
        statusLabel.center = CGPointMake(0.501*SCREEN_WIDTH, 0.25*chargeView.frame.size.height);
    }else {
        statusLabel.frame = CGRectMake(chargeView.center.x-STATUSLABEL_WIDTH/2-QUESTIONBUTTON_WIDTH/2+QUESTIONBUTTON_WIDTH/2, 0, STATUSLABEL_WIDTH, 0.238*chargeView.frame.size.height);
        statusLabel.center = CGPointMake(0.501*SCREEN_WIDTH, 0.15*chargeView.frame.size.height);
    }
    statusLabel.textAlignment = NSTextAlignmentCenter;
    statusLabel.textColor = [UIColor whiteColor];
    //    statusLabel.text = @"正在计费中";
    
    NSMutableAttributedString *content = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"正在计费中"]];
    if (iPhone5) {
        [content addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"QingYuanMono" size:17] range:NSMakeRange(0, [content length])];
    }else {
        [content addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"QingYuanMono" size:19] range:NSMakeRange(0, [content length])];
    }
    statusLabel.attributedText = content;


    //会员图标的位置确定
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
    //这里有一个判断，是否是大象会员，iamge是会员标识还是开通大象会员
    MemberImageView.userInteractionEnabled = NO;
    if ([userDefaults boolForKey:@"isVip"]) {
        [MemberImageView setTitle:@"" forState:UIControlStateNormal];
        [MemberImageView setImage:[UIImage imageNamed:@"会员标识"] forState:UIControlStateNormal];
    }else {
        [MemberImageView setTitle:@"非大象会员" forState:UIControlStateNormal];
        [MemberImageView setImage:nil forState:UIControlStateNormal];
    }
    
//    questionButton.frame = CGRectMake(statusLabel.center.x+STATUSLABEL_WIDTH/2-QUESTIONBUTTON_WIDTH/2, 0, QUESTIONBUTTON_WIDTH, QUESTIONBUTTON_HEIGHT);
    if (iPhone5) {
        questionButton.frame = CGRectMake(statusLabel.center.x+STATUSLABEL_WIDTH/2-QUESTIONBUTTON_WIDTH/2, 0, QUESTIONBUTTON_WIDTH, QUESTIONBUTTON_HEIGHT);
        questionButton.center = CGPointMake(0.666*SCREEN_WIDTH, 0.267*chargeView.frame.size.height);
    }else if(iPhone6P) {
        questionButton.frame = CGRectMake(statusLabel.center.x+STATUSLABEL_WIDTH/2-QUESTIONBUTTON_WIDTH/1.5, 0, QUESTIONBUTTON_WIDTH, QUESTIONBUTTON_HEIGHT);
        questionButton.center = CGPointMake(0.64*SCREEN_WIDTH, 0.167*chargeView.frame.size.height);
    }else{
        questionButton.frame = CGRectMake(statusLabel.center.x+STATUSLABEL_WIDTH/2-10, 0, QUESTIONBUTTON_WIDTH, QUESTIONBUTTON_HEIGHT);
        questionButton.center = CGPointMake(0.65*SCREEN_WIDTH, 0.167*chargeView.frame.size.height);
    }

    [questionButton setImage:[UIImage imageNamed:@"问号"] forState:UIControlStateNormal];
    [questionButton addTarget:self action:@selector(CalcWay) forControlEvents:UIControlEventTouchUpInside];
    
    
    //单车编号位置变更
    bikeNumber.frame = CGRectMake(0.05*SCREEN_WIDTH, STATUSLABEL_HEIGHT, TOTALPAYLABEL_WIDTH, TOTALPAYLABEL_HEIGHT);
    //    bikeNumber.text = [NSString stringWithFormat:@"单车编号：%@",bikeNo];
    NSMutableAttributedString *bikeNumbercontent = [[NSMutableAttributedString alloc] initWithString:@"单车编号"];
    [bikeNumbercontent addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"QingYuanMono" size:13] range:NSMakeRange(0, [bikeNumbercontent length])];
    bikeNumber.textColor = [UIColor whiteColor];
    bikeNumber.attributedText = bikeNumbercontent;

    bikeLabel.frame = CGRectMake(SCREEN_WIDTH-MONEYLABEL_WIDTH-0.05*SCREEN_WIDTH, STATUSLABEL_HEIGHT, MONEYLABEL_WIDTH, MONEYLABEL_HEIGHT);
    bikeLabel.textAlignment = NSTextAlignmentRight;
//    bikeLabel.font = [UIFont systemFontOfSize:15];
    bikeLabel.textColor = [UIColor whiteColor];
    NSMutableAttributedString *bikeLabelcontent = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@", bikeNo]];
    [bikeLabelcontent addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"QingYuanMono" size:13] range:NSMakeRange(0, [bikeLabelcontent length])];
    bikeLabel.attributedText = bikeLabelcontent;
    
    
    //    totalPayLabel.frame = CGRectMake(0.05*SCREEN_WIDTH, STATUSLABEL_HEIGHT, TOTALPAYLABEL_WIDTH, TOTALPAYLABEL_HEIGHT);
     totalPayLabel.frame = CGRectMake(0.05*SCREEN_WIDTH, 0.097*SCREEN_HEIGHT, TOTALPAYLABEL_WIDTH, TOTALPAYLABEL_HEIGHT);    totalPayLabel.textAlignment = NSTextAlignmentLeft;
    totalPayLabel.textColor = [UIColor whiteColor];
    totalPayLabel.text = @"费用总计";
    totalPayLabel.font = [UIFont fontWithName:@"QingYuanMono" size:19];
//    NSMutableAttributedString *totalPayLabelcontent = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"费用总计"]];
//    [totalPayLabelcontent addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"QingYuanMono" size:20] range:NSMakeRange(0, [totalPayLabelcontent length])];
//    totalPayLabel.attributedText = totalPayLabelcontent;
    
    
    moneyLabel.frame = CGRectMake(SCREEN_WIDTH-MONEYLABEL_WIDTH-0.05*SCREEN_WIDTH, 0.1*SCREEN_HEIGHT, MONEYLABEL_WIDTH, MONEYLABEL_HEIGHT);
    moneyLabel.textAlignment = NSTextAlignmentRight;
    moneyLabel.textColor = [UIColor whiteColor];
    moneyLabel.text = @"0.0";
    moneyLabel.font = [UIFont fontWithName:@"QingYuanMono" size:20];
    
    totalTimeLabel.frame = CGRectMake(0.05*SCREEN_WIDTH, 0.078*SCREEN_HEIGHT, TOTALTIME_WIDTH, TOTALTIME_HEIGHT);
    totalTimeLabel.textAlignment = NSTextAlignmentLeft;
    totalTimeLabel.textColor = [UIColor whiteColor];
    //    totalTimeLabel.text = @"使用时长：";
    NSMutableAttributedString *totalTimeLabelcontent = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"使用时长"]];
    [totalTimeLabelcontent addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"QingYuanMono" size:13] range:NSMakeRange(0, [totalTimeLabelcontent length])];
    totalTimeLabel.attributedText = totalTimeLabelcontent;

    
    timeLabel.frame = CGRectMake(SCREEN_WIDTH-TIMELABEL_WIDTH-0.05*SCREEN_WIDTH, 0.078*SCREEN_HEIGHT, TIMELABEL_WIDTH, TIMELABEL_HEIGHT);
    timeLabel.textAlignment = NSTextAlignmentRight;
    timeLabel.textColor = [UIColor whiteColor];
    timeLabel.font = [UIFont fontWithName:@"QingYuanMono" size:11];
    
//    bikeNumber.frame = CGRectMake(SCREEN_WIDTH/4, NAVIGATIONBAR_HEIGHT+STATUS_HEIGHT+CHARGEVIEW_HEIGHT+MARGIN, BIKENUMBER_WIDTH, BIKENUMBER_HEIGHT);
//    bikeNumber.text = [NSString stringWithFormat:@"单车编号：%@",bikeNo];
//    bikeNumber.clipsToBounds = YES;
//    bikeNumber.font = [UIFont systemFontOfSize:13];
//    bikeNumber.textAlignment = NSTextAlignmentCenter;
//    bikeNumber.layer.borderColor = [UIColor grayColor].CGColor;
//    bikeNumber.layer.borderWidth = 1;
//    bikeNumber.layer.cornerRadius = CORNERRADIUS;
//    bikeNumber.backgroundColor = [UIColor colorWithRed:0.900 green:0.900 blue:0.900 alpha:1.000];
    
    passwordMes.frame = CGRectMake(self.view.center.x-PASSWORDMES_WIDTH/2, 0.25*SCREEN_HEIGHT, PASSWORDMES_WIDTH, PASSWORDMES_HEIGHT);
    NSMutableAttributedString *passwordMescontent = [[NSMutableAttributedString alloc] initWithString:@"解锁密码"];
    [passwordMescontent addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"QingYuanMono" size:29] range:NSMakeRange(0, [passwordMescontent length])];
    if (iPhone6P) {
        [passwordMescontent addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"QingYuanMono" size:35] range:NSMakeRange(0, [passwordMescontent length])];
    }
    passwordMes.attributedText = passwordMescontent;
    passwordMes.textAlignment = NSTextAlignmentCenter;
    
    passwordNumberView.frame = CGRectMake(0.160*SCREEN_WIDTH, 0.25*SCREEN_HEIGHT+PASSWORDMES_HEIGHT, PASSWORDNUMBER_WIDTH, 0.098*SCREEN_HEIGHT);
    passwordNumberView.layer.borderWidth = 1;
    passwordNumberView.layer.borderColor = [UIColor grayColor].CGColor;
    passwordNumberView.backgroundColor = [UIColor colorWithRed:0.900 green:0.900 blue:0.900 alpha:1.000];
    
    passwordNumber.frame = CGRectMake(PASSWORDNUMBER_WIDTH/4+20, 5, PASSWORDNUMBER_WIDTH/2, PASSWORDNUMBER_HEIGHT/2);
    if (iPhone6P) {
        passwordNumber.frame = CGRectMake(PASSWORDNUMBER_WIDTH/4+20, 6, PASSWORDNUMBER_WIDTH/2, PASSWORDNUMBER_HEIGHT/2);
    }
    passwordNumber.numberSize = 5;
    passwordNumber.digitFont = [UIFont fontWithName:@"QingYuanMono" size:48];
    if (iPhone6P) {
        passwordNumber.digitFont = [UIFont fontWithName:@"QingYuanMono" size:58];
    }
    passwordNumber.splitSpaceWidth = 30;
    if (iPhone6P) {
        passwordNumber.splitSpaceWidth = 35;
    }
    [passwordNumber didConfigFinish];
    // 该密码就是第一次的解锁密码
    if (!myAppDelegate.isEndRiding) {
        [passwordNumber setNumber:[unlockPassword integerValue] withAnimationType:HJFScrollNumberAnimationTypeRand animationTime:2];
    }else {
        [passwordNumber setNumber:[unlockPassword integerValue] withAnimationType:HJFScrollNumberAnimationTypeRand animationTime:2];// 该密码是willappear中获取到的解锁密码 也就是上一次获取到的解锁密码
    }
    
    hintMes.frame = CGRectMake(self.view.center.x-HINTMES_WIDTH/2, 0.43*SCREEN_HEIGHT, HINTMES_WIDTH, HINTMES_HEIGHT);
    hintMes.textAlignment = NSTextAlignmentCenter;
    hintMes.font = [UIFont fontWithName:@"QingYuanMono" size:11];
    hintMes.textColor = [UIColor colorWithRed:80.0/255 green:79.0/255 blue:79.0/255 alpha:1];
    //    hintMes.text = @"将四位数字密码输入车锁即可开锁";
    NSMutableAttributedString *hintMescontent = [[NSMutableAttributedString alloc] initWithString:@"将五位数字密码输入车锁即可开锁"];
    [hintMescontent addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"QingYuanMono" size:10] range:NSMakeRange(0, [hintMescontent length])];
    hintMes.attributedText = hintMescontent;

    //预留的广告位
    AdImageView.frame = CGRectMake(0.165*SCREEN_WIDTH, 0.480*SCREEN_HEIGHT, 0.661*SCREEN_WIDTH, 0.322*SCREEN_HEIGHT);
    AdImageView.userInteractionEnabled = YES;
    UITapGestureRecognizer *activityDetails = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(gotoDetails)];
    [AdImageView addGestureRecognizer:activityDetails];
//    AdImageView.backgroundColor = [UIColor colorWithRed:112.0/255 green:177.0/255 blue:52.0/255 alpha:1];

    
     haveQuestion.frame = CGRectMake(self.view.center.x-HAVEQUESTION_WIDTH/2, 0.811*SCREEN_HEIGHT, HAVEQUESTION_WIDTH, HAVEQUESTION_HEIGHT);
    [haveQuestion setImage:[UIImage imageNamed:@"遇到问题"] forState:UIControlStateNormal];
    haveQuestion.titleLabel.font = [UIFont fontWithName:@"QingYuanMono" size:10];
    [haveQuestion addTarget:self action:@selector(questionBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    
    buttomView.frame = CGRectMake(0, SCREEN_HEIGHT-BUTTOMVIEW_HEIGHT, SCREEN_WIDTH, BUTTOMVIEW_HEIGHT);
    buttomView.backgroundColor = [UIColor colorWithRed:0.900 green:0.900 blue:0.900 alpha:1.000];
    
    hintMesButtom.frame = CGRectMake(0.1*SCREEN_WIDTH, 0, HINTMESBUTTOM_WIDTH, HINTMESBUTTOM_HEIGHT);
    hintMesButtom.center = CGPointMake(SCREEN_WIDTH/2, BUTTOMVIEW_HEIGHT/4);
//    hintMesButtom.font = [UIFont systemFontOfSize:10];
    hintMesButtom.numberOfLines = 2;
    NSString *hintMestr = @"小提示：请将单车骑回校内再点击“还车结账”，否则将会还车失败，如果在校外锁车后，点击“恢复单车”可以重新解锁。";
    NSMutableAttributedString *hintMesButtomcontent = [[NSMutableAttributedString alloc] initWithString:hintMestr];
    if (iPhone5) {
        [hintMesButtomcontent addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"QingYuanMono" size:9] range:NSMakeRange(0, [hintMestr length])];
    }else {
        [hintMesButtomcontent addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"QingYuanMono" size:10.5] range:NSMakeRange(0, [hintMestr length])];
    }
    hintMesButtom.textColor = [UIColor colorWithRed:80.0/255 green:79.0/255 blue:79.0/255 alpha:1];
    /** 修改行间距*/
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setLineSpacing:0.1*hintMesButtom.frame.size.height];
    [hintMesButtomcontent addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [hintMestr length])];
    
    hintMesButtom.attributedText = hintMesButtomcontent;
    returnBike.frame = CGRectMake(0.070*SCREEN_WIDTH, HINTMESBUTTOM_HEIGHT*1.2, 0.410*SCREEN_WIDTH, 0.056*SCREEN_HEIGHT);
    returnBike.center = CGPointMake(SCREEN_WIDTH/4, 3*BUTTOMVIEW_HEIGHT/4);
    returnBike.backgroundColor = UICOLOR;
    returnBike.layer.cornerRadius = CORNERRADIUS;
    [returnBike setTitle:@"还车结账" forState:UIControlStateNormal];
    returnBike.titleLabel.font = [UIFont fontWithName:@"QingYuanMono" size:14];
    returnBike.tintColor = [UIColor whiteColor];
    [returnBike addTarget:self action:@selector(inputReturnPassword) forControlEvents:UIControlEventTouchUpInside];
    
//    restoreBike.frame = CGRectMake(SCREEN_WIDTH-RESTOREBIKE_WIDTH-0.1*SCREEN_WIDTH, HINTMESBUTTOM_HEIGHT, RESTOREBIKE_WIDTH, RESTOREBIKE_HEIGHT);
    restoreBike.frame = CGRectMake(SCREEN_WIDTH-RESTOREBIKE_WIDTH-0.14*SCREEN_WIDTH, HINTMESBUTTOM_HEIGHT*1.2, 0.410*SCREEN_WIDTH, 0.056*SCREEN_HEIGHT);
    restoreBike.center = CGPointMake(3*SCREEN_WIDTH/4, 3*BUTTOMVIEW_HEIGHT/4);
    restoreBike.backgroundColor = UICOLOR;
    restoreBike.layer.cornerRadius = CORNERRADIUS;
    [restoreBike setTitle:@"恢复单车" forState:UIControlStateNormal];
    restoreBike.titleLabel.font = [UIFont fontWithName:@"QingYuanMono" size:14];
    restoreBike.tintColor = [UIColor whiteColor];
    [restoreBike addTarget:self action:@selector(inputRestorePassword) forControlEvents:UIControlEventTouchUpInside];
    
    cover.backgroundColor = [UIColor blackColor];
    cover.alpha = 0.6;
    cover.hidden = YES;

    
    [self.view addSubview:chargeView];
    [chargeView addSubview:statusLabel];
    //增加的大象会员图标
    [chargeView addSubview:MemberImageView];
    
    [chargeView addSubview:questionButton];
    [chargeView addSubview:totalPayLabel];
    [chargeView addSubview:moneyLabel];
    [chargeView addSubview:totalTimeLabel];
    [chargeView addSubview:timeLabel];
    [chargeView addSubview:bikeNumber];
    [chargeView addSubview:bikeLabel];
    
//    [self.view addSubview:bikeNumber];
    [self.view addSubview:AdImageView];
    [self.view addSubview:passwordMes];
    [self.view addSubview:passwordNumberView];
    [passwordNumberView addSubview:passwordNumber];
    [self.view addSubview:hintMes];
    [self.view addSubview:haveQuestion];
    [self.view addSubview:buttomView];
    [buttomView addSubview:hintMesButtom];
    [buttomView addSubview:returnBike];
    [buttomView addSubview:restoreBike];
    
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

- (void)eventInit {
    askForMoney = [NSTimer timerWithTimeInterval:60 target:self selector:@selector(requestForMoney) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:askForMoney forMode:NSDefaultRunLoopMode];
}

- (void)requestForMoney {
    // 请求时间时先把上一次的timer删除
    [countTimer invalidate];
    countTimer = nil;
    isFinish = NO;
    NSString *isFinishStr = [NSString stringWithFormat:@"%d", isFinish];
    NSString *phoneNumber = [userDefaults objectForKey:@"phoneNumber"];
    NSString *accessToken = [userDefaults objectForKey:@"accessToken"];
    NSString *urlStr = [IP stringByAppendingString:@"/ElephantBike/api/money/bikefee"];
    NSURL *url = [NSURL URLWithString:urlStr];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10];
    NSString *dataStr = [NSString stringWithFormat:@"phone=%@&bikeid=%@&access_token=%@&isfinish=%@", phoneNumber,bikeNo,accessToken, isFinishStr];
    NSData *data = [dataStr dataUsingEncoding:NSUTF8StringEncoding];
    [request setHTTPBody:data];
    [request setHTTPMethod:@"POST"];
    MyURLConnection *connection = [[MyURLConnection alloc] MyConnectioin:request delegate:self andName:@"askForMoney"];
}

#pragma mark - Button Event
- (void)inputReturnPassword {
    CGFloat rgb = 83 / 255.0;
    errorCover = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    errorCover.tag = 1;
    errorCover.backgroundColor = [UIColor colorWithRed:rgb green:rgb blue:rgb alpha:0.7];
    errorCover.alpha = 0;
    [self.navigationController.view addSubview:errorCover];

    __weak UIView       *weakErrorCover = [self.navigationController.view viewWithTag:1];
    
    view = [[ModalPayView alloc] initWithTitle:@"请输入还车密码" andHintMes:@"锁上车锁后，车锁的显示屏上会显示六位还车密码，如果显示屏没有显示密码，请摁下“显示”键" andCompletion:^(NSString *password) {
        [view hidden];
        [weakErrorCover removeFromSuperview];
        returnBikeNumber = password;
        // 等待验证动画
        // 集成api  此处是膜
        errorCover = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
//        errorCover.alpha = 1;
        // 半黑膜
        UIView *containerView = [[UIView alloc] initWithFrame:CGRectMake(0.3*SCREEN_WIDTH, 0.4*SCREEN_HEIGHT, 0.4*SCREEN_WIDTH, 0.15*SCREEN_HEIGHT)];
        containerView.backgroundColor = [UIColor blackColor];
        containerView.alpha = 0.8;
        containerView.layer.cornerRadius = CORNERRADIUS*2;
        [errorCover addSubview:containerView];
        // 两个控件
        UIActivityIndicatorView *waitActivityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        waitActivityView.frame = CGRectMake(0.33*containerView.frame.size.width, 0.1*containerView.frame.size.width, 0.33*containerView.frame.size.width, 0.4*containerView.frame.size.height);
        [waitActivityView startAnimating];
        [containerView addSubview:waitActivityView];
        
        UILabel *hintMes1 = [[UILabel alloc] initWithFrame:CGRectMake(0, 0.7*containerView.frame.size.height, containerView.frame.size.width, 0.2*containerView.frame.size.height)];
        hintMes1.text = @"正在验证，请稍后...";
        hintMes1.textColor = [UIColor whiteColor];
        hintMes1.textAlignment = NSTextAlignmentCenter;
        [containerView addSubview:hintMes1];
        [self.view addSubview:errorCover];
        
        // 取得手机号码
        NSString *phoneNumber = [userDefaults objectForKey:@"phoneNumber"];
        
        // 请求服务器 异步post
        NSString *urlStr = [IP stringByAppendingString:@"/ElephantBike/api/pass/returncode2"];
        NSURL *url = [NSURL URLWithString:urlStr];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10];
        NSString *dataStr = [NSString stringWithFormat:@"bikeid=%@&pass=%@&phone=%@&access_token=%@", bikeNo, password, phoneNumber, [userDefaults objectForKey:@"accessToken"]];
        NSData *data = [dataStr dataUsingEncoding:NSUTF8StringEncoding];
        [request setHTTPBody:data];
        [request setHTTPMethod:@"POST"];
        MyURLConnection *connection = [[MyURLConnection alloc] MyConnectioin:request delegate:self andName:@"returnBike"];
    }];
    
    __weak ModalPayView *weakView = view;
    view.exitBtnClicked = ^{ // 点击了退出按钮
        [weakView hidden];
        [weakErrorCover removeFromSuperview];
    };
    
    [errorCover addSubview:view];
    [view show];
    [UIView animateWithDuration:0.25 animations:^{
        errorCover.alpha = 1;
    }];
}

- (void)inputRestorePassword {
    CGFloat rgb = 83 / 255.0;
    errorCover = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    errorCover.tag = 1;
    errorCover.backgroundColor = [UIColor colorWithRed:rgb green:rgb blue:rgb alpha:0.7];
    errorCover.alpha = 0;
    [self.navigationController.view addSubview:errorCover];
    
    __weak UIView       *weakErrorCover = [self.navigationController.view viewWithTag:1];
    
    view = [[ModalPayView alloc] initWithTitle:@"请输入恢复密码" andHintMes:@"在车锁锁上的情况下，摁下“显示”键，车锁上的显示屏会显示六位恢复密码" andCompletion:^(NSString *password) {
        // do something
        [view hidden];
        [weakErrorCover removeFromSuperview];
        restoreBikeNumber = password;
        // 等待验证动画
        // 集成api  此处是膜
        errorCover = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        errorCover.alpha = 1;
        // 半黑膜
        UIView *containerView = [[UIView alloc] initWithFrame:CGRectMake(0.3*SCREEN_WIDTH, 0.4*SCREEN_HEIGHT, 0.4*SCREEN_WIDTH, 0.15*SCREEN_HEIGHT)];
        containerView.backgroundColor = [UIColor blackColor];
        containerView.alpha = 0.8;
        containerView.layer.cornerRadius = CORNERRADIUS*2;
        [errorCover addSubview:containerView];
        // 两个控件
        UIActivityIndicatorView *waitActivityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        waitActivityView.frame = CGRectMake(0.33*containerView.frame.size.width, 0.1*containerView.frame.size.width, 0.33*containerView.frame.size.width, 0.4*containerView.frame.size.height);
        [waitActivityView startAnimating];
        [containerView addSubview:waitActivityView];
        
        UILabel *hintMes1 = [[UILabel alloc] initWithFrame:CGRectMake(0, 0.7*containerView.frame.size.height, containerView.frame.size.width, 0.2*containerView.frame.size.height)];
        hintMes1.text = @"正在验证，请稍后...";
        hintMes1.textColor = [UIColor whiteColor];
        hintMes1.textAlignment = NSTextAlignmentCenter;
        [containerView addSubview:hintMes1];
        [self.view addSubview:errorCover];
        
        // 取得手机号码
        NSString *phoneNumber = [userDefaults objectForKey:@"phoneNumber"];
        
        // 请求服务器 异步post
        NSString *urlStr = [IP stringByAppendingString:@"/ElephantBike/api/pass/restorecode2"];
        NSURL *url = [NSURL URLWithString:urlStr];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10];
        NSString *dataStr = [NSString stringWithFormat:@"bikeid=%@&pass=%@&phone=%@&access_token=%@", bikeNo, password, phoneNumber, [userDefaults objectForKey:@"accessToken"]];
        NSData *data = [dataStr dataUsingEncoding:NSUTF8StringEncoding];
        [request setHTTPBody:data];
        [request setHTTPMethod:@"POST"];
        MyURLConnection *connection = [[MyURLConnection alloc] MyConnectioin:request delegate:self andName:@"restoreBike"];
    }];
    __weak ModalPayView *weakView = view;
    view.exitBtnClicked = ^{ // 点击了退出按钮
        [weakView hidden];
        [weakErrorCover removeFromSuperview];
    };
    
    [errorCover addSubview:view];
    [view show];
    [UIView animateWithDuration:0.25 animations:^{
        errorCover.alpha = 1;
    }];

}

#pragma mark - 不能输入密码提示
- (void)PSWWrongMessage3 {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"密码错误次数过多，请三分钟后重试" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [alertView show];
}

- (void)PSWWrongMessage3Return {
    [returnBike removeTarget:self action:@selector(PSWWrongMessage3) forControlEvents:UIControlEventTouchUpInside];
    [returnBike addTarget:self action:@selector(inputReturnPassword) forControlEvents:UIControlEventTouchUpInside];
}

- (void)PSWWrongMessage3Return1 {
    [restoreBike removeTarget:self action:@selector(PSWWrongMessage3) forControlEvents:UIControlEventTouchUpInside];
    [restoreBike addTarget:self action:@selector(inputRestorePassword) forControlEvents:UIControlEventTouchUpInside];
}

- (void)PSWWrongMessage5 {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"密码错误次数过多，请五分钟后重试" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [alertView show];
}

- (void)PSWWrongMessage5Return {
    [returnBike removeTarget:self action:@selector(PSWWrongMessage5) forControlEvents:UIControlEventTouchUpInside];
    [returnBike addTarget:self action:@selector(inputReturnPassword) forControlEvents:UIControlEventTouchUpInside];
}

- (void)PSWWrongMessage5Return1 {
    [restoreBike removeTarget:self action:@selector(PSWWrongMessage5) forControlEvents:UIControlEventTouchUpInside];
    [restoreBike addTarget:self action:@selector(inputRestorePassword) forControlEvents:UIControlEventTouchUpInside];
}

#pragma mark - 获取到金额和使用时长后的处理
- (void)setTimeAndMoney {
    NSArray *array = [timeLabel.text componentsSeparatedByString:@":"];
    int second = [[array objectAtIndex:3] intValue];
    int minute = [[array objectAtIndex:2] intValue];
    int hour = [[array objectAtIndex:1] intValue];
    int day = [[array objectAtIndex:0] intValue];
    second++;
    second %= 60;
    if ((second %= 60) == 0) {
        minute++;
        minute %= 60;
        if ((minute %= 60) == 0) {
            hour++;
            hour %= 24;
            if ((hour %= 24) == 0) {
                day++;
            }
        }
    }
    NSString *finallyTime = @"";
    if (day < 10) {
        finallyTime = [finallyTime stringByAppendingString:[NSString stringWithFormat:@"0%d:", day]];
    }else {
        finallyTime = [finallyTime stringByAppendingString:[NSString stringWithFormat:@"%d:", day]];
    }
    if (hour < 10) {
        finallyTime = [finallyTime stringByAppendingString:[NSString stringWithFormat:@"0%d:", hour]];
    }else {
        finallyTime = [finallyTime stringByAppendingString:[NSString stringWithFormat:@"%d:", hour]];
    }
    if (minute < 10) {
        finallyTime = [finallyTime stringByAppendingString:[NSString stringWithFormat:@"0%d:", minute]];
    }else {
        finallyTime = [finallyTime stringByAppendingString:[NSString stringWithFormat:@"%d:", minute]];
    }
    if (second < 10) {
        finallyTime = [finallyTime stringByAppendingString:[NSString stringWithFormat:@"0%d", second]];
    }else {
        finallyTime = [finallyTime stringByAppendingString:[NSString stringWithFormat:@"%d", second]];
    }
    timeLabel.text = finallyTime;
}

#pragma mark - 私有方法
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

- (void)gotoDetails {
    if (![myAppDelegate.linkUrlCharge isEqualToString:@""]) {
        myAppDelegate.ad = 3;
        ActivityDetailsViewController *activityDetailsViewController = [[ActivityDetailsViewController alloc] init];
        [self.navigationController pushViewController:activityDetailsViewController animated:YES];
    }
}

- (void)gotoMember {
    ElephantMemberViewController *openMemberViewController = [[ElephantMemberViewController alloc] init];
    [self.navigationController pushViewController:openMemberViewController animated:YES];
}

#pragma mark - 服务器返回
- (void)MyConnection:(MyURLConnection *)connection didReceiveData:(NSData *)data {
    // 服务器有返回，先将等待动画去掉
    if ([connection.name isEqualToString:@"returnBike"]) {
        // 解析json
        NSDictionary *receiveJson = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
        NSString *status = receiveJson[@"status"];
        NSString *message = receiveJson[@"message"];
        //服务器要返回时密码错误还是不在校园内 后面再添加
        // 密码验证成功
        [errorCover removeFromSuperview];
        if ([status isEqualToString:@"success"]) {
            NSLog(@"密码正确");
            isConnect = YES;
            // 请求服务器 异步post
            // 密码正确 请求位置是否正确
//            NSString *phoneNumber = [userDefaults objectForKey:@"phoneNumber"];
//            NSString *urlStr = [IP stringByAppendingString:@"/ElephantBike/api/bike/bikelocation"];
//            NSURL *url = [NSURL URLWithString:urlStr];
//            NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10];
//            NSString *dataStr = [NSString stringWithFormat:@"phone=%@&bikeid=%@&location=%@", phoneNumber, bikeNo, bikePosition];
//            NSData *data = [dataStr dataUsingEncoding:NSUTF8StringEncoding];
//            [request setHTTPBody:data];
//            [request setHTTPMethod:@"POST"];
//            MyURLConnection *connection = [[MyURLConnection alloc] MyConnectioin:request delegate:self andName:@"location"];
            
            isFinish = YES;
            NSString *isFinishStr = [NSString stringWithFormat:@"%d", isFinish];
            myAppDelegate.isMissing = NO;
            myAppDelegate.isEndRiding = YES;
            isConnect = YES;
            // 请求服务器 异步post
            NSString *accessToken = [userDefaults objectForKey:@"accessToken"];
            NSString *phoneNumber = [userDefaults objectForKey:@"phoneNumber"];
            NSString *urlStr = [IP stringByAppendingString:@"/ElephantBike/api/money/bikefee"];
            NSURL *url = [NSURL URLWithString:urlStr];
            NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10];
            NSString *dataStr = [NSString stringWithFormat:@"phone=%@&bikeid=%@&access_token=%@&isfinish=%@", phoneNumber, bikeNo, accessToken, isFinishStr];
            NSData *data = [dataStr dataUsingEncoding:NSUTF8StringEncoding];
            [request setHTTPBody:data];
            [request setHTTPMethod:@"POST"];
            MyURLConnection *connection = [[MyURLConnection alloc] MyConnectioin:request delegate:self andName:@"getMoney"];
        }else {
            if ([message rangeOfString:@"invalid token"].location != NSNotFound) {
                // 账号在别的地方登陆
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"您的身份验证已过期，请重新登录" delegate:self cancelButtonTitle:@"好的" otherButtonTitles:nil, nil];
                alertView.tag = 10;
                [alertView show];
                [askForMoney invalidate];
                askForMoney = nil;
            }else {
                wrongPSWCount++;
                if (wrongPSWCount == 3) {
                    thirdOrFive = 1;
                }else if (wrongPSWCount > 5) {
                    thirdOrFive = 2;
                }
                if (thirdOrFive == 0) {
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:message delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                    [alertView show];
                }else if (thirdOrFive == 1) {
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"密码错误，请三分钟后重试" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                    [alertView show];
                    NSTimer *timer3 = [NSTimer timerWithTimeInterval:WRONGPSWINTERVAL target:self selector:@selector(PSWWrongMessage3Return) userInfo:nil repeats:NO];
                    [[NSRunLoop mainRunLoop] addTimer:timer3 forMode:NSDefaultRunLoopMode];
                    // 限制三分钟不能输入密码
                    [returnBike removeTarget:self action:@selector(inputReturnPassword) forControlEvents:UIControlEventTouchUpInside];
                    [returnBike addTarget:self action:@selector(PSWWrongMessage3) forControlEvents:UIControlEventTouchUpInside];
                    thirdOrFive = 0;
                }else if (thirdOrFive == 2) {
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"密码错误，请五分钟后重试" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                    [alertView show];
                    NSTimer *timer5 = [NSTimer timerWithTimeInterval:WRONGPSWINTERVAL target:self selector:@selector(PSWWrongMessage5Return) userInfo:nil repeats:NO];
                    [[NSRunLoop mainRunLoop] addTimer:timer5 forMode:NSDefaultRunLoopMode];
                    // 限制三分钟不能输入密码
                    [returnBike removeTarget:self action:@selector(inputReturnPassword) forControlEvents:UIControlEventTouchUpInside];
                    [returnBike addTarget:self action:@selector(PSWWrongMessage5) forControlEvents:UIControlEventTouchUpInside];
                    thirdOrFive = 0;
                }

            }
        }
    }else if ([connection.name isEqualToString:@"restoreBike"]) {
        // 解析json
        NSDictionary *receiveJson = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
        NSString *status = receiveJson[@"status"];
        NSString *message = receiveJson[@"message"];
        NSString *pass = receiveJson[@"pass"];
        //服务器要返回时密码错误还是不在校园内 后面再添加
        [errorCover removeFromSuperview];
        if ([status isEqualToString:@"success"]) {
            isConnect = YES;
            [passwordNumber setNumber:[pass intValue] withAnimationType:HJFScrollNumberAnimationTypeRand animationTime:2];
            // 显示返回的新的解锁密码
        }else {
            if ([message rangeOfString:@"invalid token"].location != NSNotFound) {
                // 账号在别的地方登陆
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"您的身份验证已过期，请重新登录" delegate:self cancelButtonTitle:@"好的" otherButtonTitles:nil, nil];
                alertView.tag = 10;
                [alertView show];
                [askForMoney invalidate];
                askForMoney = nil;
            }else {
                wrongPSWCount1++;
                if (wrongPSWCount1 == 3) {
                    thirdOrFive = 1;
                }else if (wrongPSWCount1 > 5) {
                    thirdOrFive = 2;
                }
                if (thirdOrFive == 0) {
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:message delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                    [alertView show];
                }else if (thirdOrFive == 1) {
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"密码错误，请三分钟后重试" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                    [alertView show];
                    NSTimer *timer3 = [NSTimer timerWithTimeInterval:WRONGPSWINTERVAL target:self selector:@selector(PSWWrongMessage3Return1) userInfo:nil repeats:NO];
                    [[NSRunLoop mainRunLoop] addTimer:timer3 forMode:NSDefaultRunLoopMode];
                    // 限制三分钟不能输入密码
                    [restoreBike removeTarget:self action:@selector(inputRestorePassword) forControlEvents:UIControlEventTouchUpInside];
                    [restoreBike addTarget:self action:@selector(PSWWrongMessage3) forControlEvents:UIControlEventTouchUpInside];
                    thirdOrFive = 0;
                }else if (thirdOrFive == 2) {
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"密码错误，请五分钟后重试" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                    [alertView show];
                    NSTimer *timer5 = [NSTimer timerWithTimeInterval:WRONGPSWINTERVAL target:self selector:@selector(PSWWrongMessage5Return1) userInfo:nil repeats:NO];
                    [[NSRunLoop mainRunLoop] addTimer:timer5 forMode:NSDefaultRunLoopMode];
                    // 限制三分钟不能输入密码
                    [restoreBike removeTarget:self action:@selector(inputRestorePassword) forControlEvents:UIControlEventTouchUpInside];
                    [restoreBike addTarget:self action:@selector(PSWWrongMessage5) forControlEvents:UIControlEventTouchUpInside];
                    thirdOrFive = 0;
                }
            }
        }
    }else if ([connection.name isEqualToString:@"askForMoney"]) {
        // 解析json
        NSDictionary *receiveJson = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
        NSString *status = receiveJson[@"status"];
        NSString *message = receiveJson[@"message"];
        NSString *fee = receiveJson[@"fee"];
        NSString *time = receiveJson[@"time"];
        NSLog(@"%@", status);
        NSLog(@"%@", fee);
        NSLog(@"%@", time);
        
        //服务器要返回时密码错误还是不在校园内 后面再添加
        
        if ([status isEqualToString:@"success"]) {
            isConnect = YES;
            CGFloat feeNumber = [fee floatValue];
            moneyLabel.text = [NSString stringWithFormat:@"￥%.2f", feeNumber];
            timeLabel.text = time;
            
            countTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(setTimeAndMoney) userInfo:nil repeats:YES];
            [[NSRunLoop mainRunLoop] addTimer:countTimer forMode:NSDefaultRunLoopMode];
            // 更新钱数和使用时间
            // 设置timer 对获取到的使用时长计数
            // 可以设置一个60秒的timer 就计时用
        }else {
            if ([message rangeOfString:@"invalid token"].location != NSNotFound) {
                // 账号在别的地方登陆
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"您的身份验证已过期，请重新登录" delegate:self cancelButtonTitle:@"好的" otherButtonTitles:nil, nil];
                alertView.tag = 10;
                [alertView show];
                [askForMoney invalidate];
                askForMoney = nil;
            }else {
                // 集成api  此处是膜
                errorCover = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
                errorCover.alpha = 1;
                // 半黑膜
                UIView *containerView = [[UIView alloc] initWithFrame:CGRectMake(0.3*SCREEN_WIDTH, 0.4*SCREEN_HEIGHT, 0.4*SCREEN_WIDTH, 0.15*SCREEN_HEIGHT)];
                containerView.backgroundColor = [UIColor blackColor];
                containerView.alpha = 0.8;
                containerView.layer.cornerRadius = CORNERRADIUS*2;
                [errorCover addSubview:containerView];
                
                UILabel *hintMes1 = [[UILabel alloc] initWithFrame:CGRectMake(0, 0.4*containerView.frame.size.height, containerView.frame.size.width, 0.2*containerView.frame.size.height)];
                hintMes1.text = @"您的网络忙";
                hintMes1.textColor = [UIColor whiteColor];
                hintMes1.textAlignment = NSTextAlignmentCenter;
                [containerView addSubview:hintMes1];
                
                [self.view addSubview:errorCover];
                
                // 时间、金钱数不动
                
                // 显示时间
                NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(removeView) userInfo:nil repeats:NO];
                [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
            }
        }
    }else if ([connection.name isEqualToString:@"location"]) {
        NSDictionary *receiveJson = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
        NSString *status = receiveJson[@"status"];
        NSString *message = receiveJson[@"message"];
        if ([status isEqualToString:@"success"]) {
            myAppDelegate.isEndRiding = YES;
            isFinish = YES;
            NSString *isFinishStr = [NSString stringWithFormat:@"%d", isFinish];
            isConnect = YES;
            // 请求服务器 异步post
            NSString *accessToken = [userDefaults objectForKey:@"accessToken"];
            NSString *phoneNumber = [userDefaults objectForKey:@"phoneNumber"];
            NSString *urlStr = [IP stringByAppendingString:@"/ElephantBike/api/money/bikefee"];
            NSURL *url = [NSURL URLWithString:urlStr];
            NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10];
            NSString *dataStr = [NSString stringWithFormat:@"phone=%@&bikeid=%@&access_token=%@&isfinish=%@", phoneNumber, bikeNo, accessToken, isFinishStr];
            NSData *data = [dataStr dataUsingEncoding:NSUTF8StringEncoding];
            [request setHTTPBody:data];
            [request setHTTPMethod:@"POST"];
            MyURLConnection *connection = [[MyURLConnection alloc] MyConnectioin:request delegate:self andName:@"getMoney"];
        }else {
            
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"您没有把车停在有效范围内" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alertView show];
        }
    }else if ([connection.name isEqualToString:@"getMoney"]) {
        NSDictionary *receiveJson = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
        NSString *status = receiveJson[@"status"];
        NSString *money = receiveJson[@"fee"];
        NSString *time = receiveJson[@"time"];
        NSString *message = receiveJson[@"message"];
        if ([status isEqualToString:@"success"]) {
            NSLog(@"获取钱正确");
            [errorCover removeFromSuperview];
            isConnect = YES;
            PayViewController *payViewController = [[PayViewController alloc] init];
            self.delegate = payViewController;
            [self.delegate getMoney:money andTime:time];
            myAppDelegate.isEndPay = NO;
            [self.navigationController pushViewController:payViewController animated:YES];
        }else {
            if ([message rangeOfString:@"invalid token"].location != NSNotFound) {
                // 账号在别的地方登陆
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"您的身份验证已过期，请重新登录" delegate:self cancelButtonTitle:@"好的" otherButtonTitles:nil, nil];
                alertView.tag = 10;
                [alertView show];
                [askForMoney invalidate];
                askForMoney = nil;
            }else {
                // 还车失败 请重试
                NSLog(@"获取钱错误");
            }
        }
    }else if ([connection.name isEqualToString:@"getAD"]) {
        NSDictionary *receive = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
        NSString *status = receive[@"status"];
        NSString *imageurl = receive[@"imageurl"];
        NSString *linkurl = receive[@"linkurl"];
        NSLog(@"计费页面广告url:%@\n%@", imageurl, linkurl);
        if ([status isEqualToString:@"success"]) {
            myAppDelegate.imageUrlCharge = @"";
            myAppDelegate.linkUrlCharge = @"";
            NSString *temp = [IP stringByAppendingString:@"/"];
            myAppDelegate.imageUrlCharge = [temp stringByAppendingString:imageurl];
            if (![linkurl isEqualToString:@""]) {
                myAppDelegate.linkUrlCharge = linkurl;
            }
            [AdImageView sd_setImageWithURL:[NSURL URLWithString:myAppDelegate.imageUrlCharge]];
        }
    }
}

- (void)MyConnection:(MyURLConnection *)connection didFailWithError:(NSError *)error    {
    isConnect = YES;
    [errorCover removeFromSuperview];
    // 收到验证码  进行提示
    errorCover = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    errorCover.alpha = 1;
    // 半黑膜
    UIView *containerView = [[UIView alloc] initWithFrame:CGRectMake(0.3*SCREEN_WIDTH, 0.4*SCREEN_HEIGHT, 0.4*SCREEN_WIDTH, 0.15*SCREEN_HEIGHT)];
    containerView.backgroundColor = [UIColor blackColor];
    containerView.alpha = 0.8;
    containerView.layer.cornerRadius = CORNERRADIUS*2;
    [errorCover addSubview:containerView];
    // 一个控件
    UILabel *hintMes1 = [[UILabel alloc] initWithFrame:CGRectMake(0, 0.4*containerView.frame.size.height, containerView.frame.size.width, 0.2*containerView.frame.size.height)];
    hintMes1.text = @"请检查您的网络";
    hintMes1.textColor = [UIColor whiteColor];
    hintMes1.textAlignment = NSTextAlignmentCenter;
    [containerView addSubview:hintMes1];
    [self.view addSubview:errorCover];
    // 显示时间
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(removeView) userInfo:nil repeats:NO];
    [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
    NSLog(@"网络超时");
}

- (void)questionBtnClicked {
    //    QuestionViewController *questionViewController = [[QuestionViewController alloc] init];
    //    [self.navigationController pushViewController:questionViewController animated:YES];
    MeetQuestionViewController *meetQuestion = [[MeetQuestionViewController alloc] init];
    [self.navigationController pushViewController:meetQuestion animated:YES];
//    [passwordNumber setNumber:rand() withAnimationType:HJFScrollNumberAnimationTypeRand animationTime:2];
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

#pragma mark - QRCodeScanViewController Delegate
- (void)getBikeNO:(NSString *)bikeNO andPassword:(NSString *)password {
    bikeNo = bikeNO;
    unlockPassword = password;
    [passwordNumber setNumber:[unlockPassword integerValue] withAnimationType:HJFScrollNumberAnimationTypeRand animationTime:YES];
}

#pragma mark - 百度地图模块代理方法
// 获取经纬度 传给服务器
- (void)didUpdateBMKUserLocation:(BMKUserLocation *)userLocation {
    CGFloat latitude = userLocation.location.coordinate.latitude;
    CGFloat longitude = userLocation.location.coordinate.longitude;
        NSLog(@"didUpdateUserLocation lat %f,long %f",latitude,longitude);
    // 封装地理位置的两个数据
    NSDictionary *dictionary = [[NSDictionary alloc] initWithObjectsAndKeys:[NSString stringWithFormat:@"%f", userLocation.location.coordinate.longitude], @"lng", [NSString stringWithFormat:@"%f", userLocation.location.coordinate.latitude], @"lat", nil];
    NSData *data = [NSJSONSerialization dataWithJSONObject:dictionary options:NSJSONWritingPrettyPrinted error:nil];
    bikePosition = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    [_locSerview stopUserLocationService];
}


#pragma mark - Life Cycle
- (void)viewWillAppear:(BOOL)animated {
    
}

- (void)viewDidLoad {
    [self UIInit];
    [self eventInit];
    [self requestForMoney];
    self.view.backgroundColor = [UIColor whiteColor];

}

- (void)viewWillDisappear:(BOOL)animated {
    [askForMoney invalidate];
    askForMoney = nil;
}

@end
