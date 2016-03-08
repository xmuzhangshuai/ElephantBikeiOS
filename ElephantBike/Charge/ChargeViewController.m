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

#pragma mark - 百度地图
#import <BaiduMapAPI_Location/BMKLocationComponent.h>
/* 实现左侧菜单页面跳转 */
#import "InfoViewController.h"
#import "AppDelegate.h"

#define CHARGEVIEW_HEIGHT       0.16*SCREEN_HEIGHT
#define STATUSLABEL_WIDTH       0.33*SCREEN_WIDTH
#define STATUSLABEL_HEIGHT      0.4*CHARGEVIEW_HEIGHT
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

#define BUTTOMVIEW_HEIGHT       0.16*SCREEN_HEIGHT
#define HINTMESBUTTOM_WIDTH     SAME_WIDTH
#define HINTMESBUTTOM_HEIGHT    0.33*BUTTOMVIEW_HEIGHT
#define RETURNBIKE_WIDTH        0.35*SCREEN_WIDTH
#define RETURNBIKE_HEIGHT       0.6*BUTTOMVIEW_HEIGHT
#define RESTOREBIKE_WIDTH       RETURNBIKE_WIDTH
#define RESTOREBIKE_HEIGHT      RETURNBIKE_HEIGHT

#define BIKENUMBER_HEIGHT       0.33*CHARGEVIEW_HEIGHT
#define BIKENUMBER_WIDTH        0.5*SCREEN_WIDTH
#define PASSWORDMES_HEIGHT      BIKENUMBER_HEIGHT
#define PASSWORDMES_WIDTH       BIKENUMBER_WIDTH
#define PASSWORDNUMBER_WIDTH    SAME_WIDTH
#define PASSWORDNUMBER_HEIGHT   0.66*BUTTOMVIEW_HEIGHT
#define HINTMES_HEIGHT          0.5*BIKENUMBER_HEIGHT
#define HINTMES_WIDTH           0.5*SCREEN_WIDTH
#define HAVEQUESTION_HEIGHT     HINTMES_HEIGHT*2
#define HAVEQUESTION_WIDTH      PASSWORDMES_WIDTH

#define WRONGPSWINTERVAL        10

@interface ChargeViewController () <InfoViewControllerDelegate, QRCodeScanViewControllerDelegate, MyURLConnectionDelegate, BMKLocationServiceDelegate>

@end

@implementation ChargeViewController {
    UIView      *chargeView;
    UILabel     *statusLabel;
    UIButton    *questionButton;
    UILabel     *totalPayLabel;
    UILabel     *moneyLabel;
    UILabel     *totalTimeLabel;
    UILabel     *timeLabel;
    
    UILabel     *bikeNumber;
    UILabel     *passwordMes;
    UIView      *passwordNumberView;
    HJFScrollNumberView *passwordNumber;
    UILabel     *hintMes;
    UIButton    *haveQuestion;  // button+image?
    
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
            NSString *urlStr = [IP stringByAppendingString:@"/ElephantBike/api/bike/bikeidandpass"];
            NSURL *url = [NSURL URLWithString:urlStr];
            NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10];
            NSString *dataStr = [NSString stringWithFormat:@"phone=%@", phoneNumber];
            NSData *data = [dataStr dataUsingEncoding:NSUTF8StringEncoding];
            [request setHTTPBody:data];
            [request setHTTPMethod:@"POST"];
//            MyURLConnection *connection = [[MyURLConnection alloc] MyConnectioin:request delegate:self andName:@"getBikeNoAndPass"];
            NSData *receiveData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
            NSDictionary *receiveJson = [NSJSONSerialization JSONObjectWithData:receiveData options:NSJSONReadingMutableLeaves error:nil];
            NSString *status = receiveJson[@"status"];
            NSString *bikeNO = receiveJson[@"bikeid"];
            NSString *pass = receiveJson[@"pass"];
            if ([status isEqualToString:@"success"]) {
                isConnect = YES;
                bikeNo = bikeNO;
                // 讲单车编号写入缓存
                [userDefaults setObject:bikeNO forKey:@"bikeNo"];
                unlockPassword = pass;
            }

        }
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
        containerView.alpha = 0.6;
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
    questionButton  = [[UIButton alloc]init];
    totalPayLabel   = [[UILabel alloc]init];
    moneyLabel      = [[UILabel alloc]init];
    totalTimeLabel  = [[UILabel alloc]init];
    timeLabel       = [[UILabel alloc]init];
    
    bikeNumber      = [[UILabel alloc]init];
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
    
    infoViewController = [[InfoViewController alloc] initWithFrame:CGRectMake((-1)*SCREEN_WIDTH, 0, SCREEN_WIDTH*0.8, SCREEN_HEIGHT)];
    infoViewController.delegate = self;
    [self.navigationController.view addSubview:infoViewController.view];
    
    leftSwipGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(showMenu)];
    [self.view addGestureRecognizer:leftSwipGestureRecognizer];


    
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
    UIImageView *titleImageView = [[UIImageView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2-30, STATUS_HEIGHT, 60, NAVIGATIONBAR_HEIGHT)];
    titleImageView.image = [UIImage imageNamed:@"大象图标"];
    titleImageView.contentMode = UIViewContentModeScaleToFill;
    self.navigationItem.titleView = titleImageView;
    
    UIBarButtonItem *infoButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"个人资料"] style:UIBarButtonItemStylePlain target:self action:@selector(information)];
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
    float containerAlpha = 1.0f;
    [UIView animateWithDuration:0.4f
                          delay:0.0f
         usingSpringWithDamping:1.0
          initialSpringVelocity:4.0
                        options: UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         infoViewController.view.frame = infoView;
                         [self.navigationController.view setAlpha: containerAlpha];
                         cover.alpha = 0.6;
                     }
                     completion:^(BOOL finished){
                     }];
    [UIView commitAnimations];
    cover.hidden = NO;
}

- (void)hiddenMenu {
    cover.hidden = YES;
    CGRect infoView = infoViewController.view.frame;
    infoView.origin.x -= SCREEN_WIDTH;
    // 动画
    float containerAlpha = 1.0f;
    [UIView animateWithDuration:0.6f
                          delay:0.05f
         usingSpringWithDamping:1.0
          initialSpringVelocity:4.0
                        options: UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         infoViewController.view.frame = infoView;
                         [self.navigationController.view setAlpha: containerAlpha];
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

- (void)UILayout {
    chargeView.frame = CGRectMake(0, STATUS_HEIGHT+NAVIGATIONBAR_HEIGHT, SCREEN_WIDTH, CHARGEVIEW_HEIGHT);
    chargeView.backgroundColor = UICOLOR;
    
    // statusLabel questionButton totalpaylabel -----timelabel
    statusLabel.frame = CGRectMake(chargeView.center.x-STATUSLABEL_WIDTH/2-QUESTIONBUTTON_WIDTH/2, 0, STATUSLABEL_WIDTH, STATUSLABEL_HEIGHT);
    statusLabel.textAlignment = NSTextAlignmentCenter;
    statusLabel.textColor = [UIColor whiteColor];
    statusLabel.text = @"正在计费中";
    
    questionButton.frame = CGRectMake(statusLabel.center.x+STATUSLABEL_WIDTH/2-QUESTIONBUTTON_WIDTH/2, 0, QUESTIONBUTTON_WIDTH, QUESTIONBUTTON_HEIGHT);
    [questionButton setImage:[UIImage imageNamed:@"问号按钮"] forState:UIControlStateNormal];
    [questionButton addTarget:self action:@selector(CalcWay) forControlEvents:UIControlEventTouchUpInside];
    
    totalPayLabel.frame = CGRectMake(0.05*SCREEN_WIDTH, STATUSLABEL_HEIGHT, TOTALPAYLABEL_WIDTH, TOTALPAYLABEL_HEIGHT);
    totalPayLabel.textAlignment = NSTextAlignmentLeft;
    totalPayLabel.font = [UIFont systemFontOfSize:15];
    totalPayLabel.textColor = [UIColor whiteColor];
    totalPayLabel.text = @"费用总计：";
    
    moneyLabel.frame = CGRectMake(SCREEN_WIDTH-MONEYLABEL_WIDTH-0.05*SCREEN_WIDTH, STATUSLABEL_HEIGHT, MONEYLABEL_WIDTH, MONEYLABEL_HEIGHT);
    moneyLabel.textAlignment = NSTextAlignmentRight;
    moneyLabel.font = [UIFont systemFontOfSize:15];
    moneyLabel.textColor = [UIColor whiteColor];
    moneyLabel.text = @"￥00.56";
    
    totalTimeLabel.frame = CGRectMake(0.05*SCREEN_WIDTH, STATUSLABEL_HEIGHT+TOTALTIME_HEIGHT, TOTALTIME_WIDTH, TOTALTIME_HEIGHT);
    totalTimeLabel.textAlignment = NSTextAlignmentLeft;
    totalTimeLabel.font = [UIFont systemFontOfSize:12];
    totalTimeLabel.textColor = [UIColor whiteColor];
    totalTimeLabel.text = @"使用时长：";
    
    timeLabel.frame = CGRectMake(SCREEN_WIDTH-TIMELABEL_WIDTH-0.05*SCREEN_WIDTH, STATUSLABEL_HEIGHT+TOTALTIME_HEIGHT, TIMELABEL_WIDTH, TIMELABEL_HEIGHT);
    timeLabel.textAlignment = NSTextAlignmentRight;
    timeLabel.font = [UIFont systemFontOfSize:12];
    timeLabel.textColor = [UIColor whiteColor];
    timeLabel.text = @"00:00:10:00";
    
    bikeNumber.frame = CGRectMake(SCREEN_WIDTH/4, NAVIGATIONBAR_HEIGHT+STATUS_HEIGHT+CHARGEVIEW_HEIGHT+MARGIN, BIKENUMBER_WIDTH, BIKENUMBER_HEIGHT);
    bikeNumber.text = [NSString stringWithFormat:@"单车编号：%@",bikeNo];
    bikeNumber.clipsToBounds = YES;
    bikeNumber.font = [UIFont systemFontOfSize:13];
    bikeNumber.textAlignment = NSTextAlignmentCenter;
    bikeNumber.layer.borderColor = [UIColor grayColor].CGColor;
    bikeNumber.layer.borderWidth = 1;
    bikeNumber.layer.cornerRadius = CORNERRADIUS;
    bikeNumber.backgroundColor = [UIColor colorWithRed:0.900 green:0.900 blue:0.900 alpha:1.000];
    
    passwordMes.frame = CGRectMake(self.view.center.x-PASSWORDMES_WIDTH/2, NAVIGATIONBAR_HEIGHT+STATUS_HEIGHT+CHARGEVIEW_HEIGHT+MARGIN*2, PASSWORDMES_WIDTH, PASSWORDMES_HEIGHT);
    passwordMes.text = @"解锁密码";
    passwordMes.textAlignment = NSTextAlignmentCenter;
    
    passwordNumberView.frame = CGRectMake(0.1*SCREEN_WIDTH, NAVIGATIONBAR_HEIGHT+STATUS_HEIGHT+CHARGEVIEW_HEIGHT+PASSWORDMES_HEIGHT+MARGIN*2, PASSWORDNUMBER_WIDTH, PASSWORDNUMBER_HEIGHT);
    passwordNumberView.layer.borderWidth = 1;
    passwordNumberView.layer.borderColor = [UIColor grayColor].CGColor;
    passwordNumberView.backgroundColor = [UIColor colorWithRed:0.900 green:0.900 blue:0.900 alpha:1.000];
    
    passwordNumber.frame = CGRectMake(PASSWORDNUMBER_WIDTH/4, PASSWORDNUMBER_HEIGHT/4, PASSWORDNUMBER_WIDTH/2, PASSWORDNUMBER_HEIGHT/2);
    passwordNumber.numberSize = 4;
    passwordNumber.digitFont = [UIFont systemFontOfSize:30];
    [passwordNumber didConfigFinish];
    // 该密码就是第一次的解锁密码
    if (!myAppDelegate.isEndRiding) {
        [passwordNumber setNumber:[unlockPassword integerValue] withAnimationType:HJFScrollNumberAnimationTypeRand animationTime:2];
    }else {
        [passwordNumber setNumber:[unlockPassword integerValue] withAnimationType:HJFScrollNumberAnimationTypeRand animationTime:2];// 该密码是willappear中获取到的解锁密码 也就是上一次获取到的解锁密码
    }
    
    hintMes.frame = CGRectMake(self.view.center.x-HINTMES_WIDTH/2, NAVIGATIONBAR_HEIGHT+STATUS_HEIGHT+CHARGEVIEW_HEIGHT+PASSWORDMES_HEIGHT+MARGIN*4+PASSWORDMES_HEIGHT, HINTMES_WIDTH, HINTMES_HEIGHT);
    hintMes.textAlignment = NSTextAlignmentCenter;
    hintMes.font = [UIFont systemFontOfSize:10];
    hintMes.text = @"将四位数字密码输入车锁即可开锁";
    
    haveQuestion.frame = CGRectMake(self.view.center.x-HAVEQUESTION_WIDTH/2, SCREEN_HEIGHT-BUTTOMVIEW_HEIGHT-MARGIN, HAVEQUESTION_WIDTH, HAVEQUESTION_HEIGHT);
    [haveQuestion setImage:[UIImage imageNamed:@"遇到问题"] forState:UIControlStateNormal];
    [haveQuestion addTarget:self action:@selector(questionBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    
    buttomView.frame = CGRectMake(0, SCREEN_HEIGHT-BUTTOMVIEW_HEIGHT, SCREEN_WIDTH, BUTTOMVIEW_HEIGHT);
    buttomView.backgroundColor = [UIColor colorWithRed:0.900 green:0.900 blue:0.900 alpha:1.000];
    
    hintMesButtom.frame = CGRectMake(0.1*SCREEN_WIDTH, 0, HINTMESBUTTOM_WIDTH, HINTMESBUTTOM_HEIGHT);
    hintMesButtom.font = [UIFont systemFontOfSize:10];
    hintMesButtom.numberOfLines = 2;
    hintMesButtom.text = @"小提示：请将单车骑回校内再点击”换车结账“，如果在校外锁车后，点击”恢复单车“可重新解锁";
    
    returnBike.frame = CGRectMake(0.1*SCREEN_WIDTH, HINTMESBUTTOM_HEIGHT, RETURNBIKE_WIDTH, RETURNBIKE_HEIGHT);
    returnBike.backgroundColor = UICOLOR;
    returnBike.layer.cornerRadius = CORNERRADIUS;
    [returnBike setTitle:@"还车结账" forState:UIControlStateNormal];
    returnBike.tintColor = [UIColor whiteColor];
    [returnBike addTarget:self action:@selector(inputReturnPassword) forControlEvents:UIControlEventTouchUpInside];
    
    restoreBike.frame = CGRectMake(SCREEN_WIDTH-RESTOREBIKE_WIDTH-0.1*SCREEN_WIDTH, HINTMESBUTTOM_HEIGHT, RESTOREBIKE_WIDTH, RESTOREBIKE_HEIGHT);
    restoreBike.backgroundColor = UICOLOR;
    restoreBike.layer.cornerRadius = CORNERRADIUS;
    [restoreBike setTitle:@"恢复单车" forState:UIControlStateNormal];
    restoreBike.tintColor = [UIColor whiteColor];
    [restoreBike addTarget:self action:@selector(inputRestorePassword) forControlEvents:UIControlEventTouchUpInside];
    
    cover.backgroundColor = [UIColor blackColor];
    cover.alpha = 0.6;
    cover.hidden = YES;

    
    [self.view addSubview:chargeView];
    [chargeView addSubview:statusLabel];
    [chargeView addSubview:questionButton];
    [chargeView addSubview:totalPayLabel];
    [chargeView addSubview:moneyLabel];
    [chargeView addSubview:totalTimeLabel];
    [chargeView addSubview:timeLabel];
    
    [self.view addSubview:bikeNumber];
    [self.view addSubview:passwordMes];
    [self.view addSubview:passwordNumberView];
    [passwordNumberView addSubview:passwordNumber];
    [self.view addSubview:hintMes];
    [self.view addSubview:haveQuestion];
    [self.view addSubview:buttomView];
    [buttomView addSubview:hintMesButtom];
    [buttomView addSubview:returnBike];
    [buttomView addSubview:restoreBike];
    
    returnBike.enabled = YES;
    restoreBike.enabled = NO;
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
        containerView.alpha = 0.6;
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
        NSString *urlStr = [IP stringByAppendingString:@"/ElephantBike/api/pass/returncode"];
        NSURL *url = [NSURL URLWithString:urlStr];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10];
        NSString *dataStr = [NSString stringWithFormat:@"bikeid=%@&pass=%@&phone=%@", bikeNo, password, phoneNumber];
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
        containerView.alpha = 0.6;
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
        NSString *urlStr = [IP stringByAppendingString:@"/ElephantBike/api/pass/returncode"];
        NSURL *url = [NSURL URLWithString:urlStr];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10];
        NSString *dataStr = [NSString stringWithFormat:@"bikeid=%@&pass=%@&phone=%@", bikeNo, password, phoneNumber];
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
    NSString *finallyTime = [NSString stringWithFormat:@"%d:%d:%d:%d", day, hour, minute, second];
    timeLabel.text = finallyTime;
}

#pragma mark - 服务器返回
- (void)MyConnection:(MyURLConnection *)connection didReceiveData:(NSData *)data {
    // 服务器有返回，先将等待动画去掉
    [errorCover removeFromSuperview];
    
    if ([connection.name isEqualToString:@"returnBike"]) {
        // 解析json
        NSDictionary *receiveJson = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
        NSString *status = receiveJson[@"status"];
        NSString *message = receiveJson[@"message"];
        
        //服务器要返回时密码错误还是不在校园内 后面再添加
        // 密码验证成功
        if ([status isEqualToString:@"success"]) {
            isConnect = YES;
            // 请求服务器 异步post
            // 密码正确 请求位置是否正确
            NSString *phoneNumber = [userDefaults objectForKey:@"phoneNumber"];
            NSString *urlStr = [IP stringByAppendingString:@"/ElephantBike/api/bike/bikelocation"];
            NSURL *url = [NSURL URLWithString:urlStr];
            NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10];
            NSString *dataStr = [NSString stringWithFormat:@"phone=%@&bikeid=%@&location=%@", phoneNumber, bikeNo, bikePosition];
            NSData *data = [dataStr dataUsingEncoding:NSUTF8StringEncoding];
            [request setHTTPBody:data];
            [request setHTTPMethod:@"POST"];
            MyURLConnection *connection = [[MyURLConnection alloc] MyConnectioin:request delegate:self andName:@"location"];
            
//            isFinish = YES;
//            NSString *isFinishStr = [NSString stringWithFormat:@"%d", isFinish];
//            myAppDelegate.isMissing = NO;
//            myAppDelegate.isEndRiding = YES;
//            isConnect = YES;
//            // 请求服务器 异步post
//            NSString *accessToken = [userDefaults objectForKey:@"accessToken"];
//            NSString *phoneNumber = [userDefaults objectForKey:@"phoneNumber"];
//            NSString *urlStr = [IP stringByAppendingString:@"/ElephantBike/api/money/bikefee"];
//            NSURL *url = [NSURL URLWithString:urlStr];
//            NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10];
//            NSString *dataStr = [NSString stringWithFormat:@"phone=%@&bikeid=%@&access_token=%@&isfinish=%@", phoneNumber, bikeNo, accessToken, isFinishStr];
//            NSData *data = [dataStr dataUsingEncoding:NSUTF8StringEncoding];
//            [request setHTTPBody:data];
//            [request setHTTPMethod:@"POST"];
//            MyURLConnection *connection = [[MyURLConnection alloc] MyConnectioin:request delegate:self andName:@"getMoney"];
        }else {
            wrongPSWCount++;
            if (wrongPSWCount == 3) {
                thirdOrFive = 1;
            }else if (wrongPSWCount > 5) {
                thirdOrFive = 2;
            }
            if (thirdOrFive == 0) {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"密码错误，请重试" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                [alertView show];
            }else if (thirdOrFive == 1) {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"密码错误，请三分钟后重试" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                [alertView show];
                NSTimer *timer3 = [NSTimer timerWithTimeInterval:WRONGPSWINTERVAL target:self selector:@selector(PSWWrongMessage3Return) userInfo:nil repeats:NO];
                [[NSRunLoop mainRunLoop] addTimer:timer3 forMode:NSDefaultRunLoopMode];
                // 限制三分钟不能输入密码
                [returnBike removeTarget:self action:@selector(inputReturnPassword) forControlEvents:UIControlEventTouchUpInside];
                [returnBike addTarget:self action:@selector(PSWWrongMessage3) forControlEvents:UIControlEventTouchUpInside];
                thirdOrFive = 0;
            }else if (thirdOrFive == 2) {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"密码错误，请五分钟后重试" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                [alertView show];
                NSTimer *timer5 = [NSTimer timerWithTimeInterval:WRONGPSWINTERVAL target:self selector:@selector(PSWWrongMessage5Return) userInfo:nil repeats:NO];
                [[NSRunLoop mainRunLoop] addTimer:timer5 forMode:NSDefaultRunLoopMode];
                // 限制三分钟不能输入密码
                [returnBike removeTarget:self action:@selector(inputReturnPassword) forControlEvents:UIControlEventTouchUpInside];
                [returnBike addTarget:self action:@selector(PSWWrongMessage5) forControlEvents:UIControlEventTouchUpInside];
                thirdOrFive = 0;
            }
        }
    }else if ([connection.name isEqualToString:@"restoreBike"]) {
        // 解析json
        NSDictionary *receiveJson = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
        NSString *status = receiveJson[@"status"];
        NSString *message = receiveJson[@"message"];
        
        //服务器要返回时密码错误还是不在校园内 后面再添加
        
        if ([status isEqualToString:@"success"]) {
            isConnect = YES;
            returnBike.enabled = YES;
            restoreBike.enabled = NO;
            
            // 显示返回的新的解锁密码
        }else {
            wrongPSWCount1++;
            if (wrongPSWCount1 == 3) {
                thirdOrFive = 1;
            }else if (wrongPSWCount1 > 5) {
                thirdOrFive = 2;
            }
            if (thirdOrFive == 0) {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"密码错误，请重试" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                [alertView show];
            }else if (thirdOrFive == 1) {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"密码错误，请三分钟后重试" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                [alertView show];
                NSTimer *timer3 = [NSTimer timerWithTimeInterval:WRONGPSWINTERVAL target:self selector:@selector(PSWWrongMessage3Return1) userInfo:nil repeats:NO];
                [[NSRunLoop mainRunLoop] addTimer:timer3 forMode:NSDefaultRunLoopMode];
                // 限制三分钟不能输入密码
                [restoreBike removeTarget:self action:@selector(inputRestorePassword) forControlEvents:UIControlEventTouchUpInside];
                [restoreBike addTarget:self action:@selector(PSWWrongMessage3) forControlEvents:UIControlEventTouchUpInside];
                thirdOrFive = 0;
            }else if (thirdOrFive == 2) {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"密码错误，请五分钟后重试" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                [alertView show];
                NSTimer *timer5 = [NSTimer timerWithTimeInterval:WRONGPSWINTERVAL target:self selector:@selector(PSWWrongMessage5Return1) userInfo:nil repeats:NO];
                [[NSRunLoop mainRunLoop] addTimer:timer5 forMode:NSDefaultRunLoopMode];
                // 限制三分钟不能输入密码
                [restoreBike removeTarget:self action:@selector(inputRestorePassword) forControlEvents:UIControlEventTouchUpInside];
                [restoreBike addTarget:self action:@selector(PSWWrongMessage5) forControlEvents:UIControlEventTouchUpInside];
                thirdOrFive = 0;
            }
        }
    }else if ([connection.name isEqualToString:@"askForMoney"]) {
        // 解析json
        NSDictionary *receiveJson = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
        NSString *status = receiveJson[@"status"];
        NSString *fee = receiveJson[@"fee"];
        NSString *time = receiveJson[@"time"];
        NSLog(@"%@", status);
        NSLog(@"%@", fee);
        NSLog(@"%@", time);
        
        //服务器要返回时密码错误还是不在校园内 后面再添加
        
        if ([status isEqualToString:@"success"]) {
            isConnect = YES;
            moneyLabel.text = fee;
            timeLabel.text = time;
            
            countTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(setTimeAndMoney) userInfo:nil repeats:YES];
            [[NSRunLoop mainRunLoop] addTimer:countTimer forMode:NSDefaultRunLoopMode];
            // 更新钱数和使用时间
            // 设置timer 对获取到的使用时长计数
            // 可以设置一个60秒的timer 就计时用
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
            hintMes1.text = @"获取不到数据";
            hintMes1.textColor = [UIColor whiteColor];
            hintMes1.textAlignment = NSTextAlignmentCenter;
            [containerView addSubview:hintMes1];
            
            [self.view addSubview:errorCover];
            
            // 时间、金钱数不动
            
            // 显示时间
            NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(removeView) userInfo:nil repeats:NO];
            [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
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
            returnBike.enabled = NO;
            restoreBike.enabled = YES;
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"您没有把车停在有效范围内" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alertView show];
        }
    }else if ([connection.name isEqualToString:@"getMoney"]) {
        NSDictionary *receiveJson = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
        NSString *status = receiveJson[@"status"];
        NSString *money = receiveJson[@"fee"];
        NSString *time = receiveJson[@"time"];
        if ([status isEqualToString:@"success"]) {
            [errorCover removeFromSuperview];
            isConnect = YES;
            PayViewController *payViewController = [[PayViewController alloc] init];
            self.delegate = payViewController;
            [self.delegate getMoney:money andTime:time];
            [self.navigationController pushViewController:payViewController animated:YES];
        }else {
            // 还车失败 请重试
        }
    }else if ([connection.name isEqualToString:@"getBikeNoAndPass"]) {
        
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
    containerView.alpha = 0.6;
    containerView.layer.cornerRadius = CORNERRADIUS*2;
    [errorCover addSubview:containerView];
    // 一个控件
    UILabel *hintMes1 = [[UILabel alloc] initWithFrame:CGRectMake(0, 0.4*containerView.frame.size.height, containerView.frame.size.width, 0.2*containerView.frame.size.height)];
    hintMes1.text = @"无法连接网络";
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
    QuestionViewController *questionViewController = [[QuestionViewController alloc] init];
    [self.navigationController pushViewController:questionViewController animated:YES];
}

- (void)CalcWay {
    CalcWayViewController *calcWayViewController = [[CalcWayViewController alloc] init];
    [self.navigationController pushViewController:calcWayViewController animated:YES];
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
