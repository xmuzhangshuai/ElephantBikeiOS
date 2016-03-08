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
#import "QuestionViewController.h"
#import "RechargeViewController.h"

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

#define PAYLISTTABLEVIEW_HEIGHT 0.27*SCREEN_HEIGHT
#define CONFIRMBUTTON_WIDTH     0.9*SCREEN_WIDTH
#define CONFIRMBUTTON_HEIGHT    SAME_HEIGHT

@interface PayViewController ()<UITableViewDataSource, UITableViewDelegate, InfoViewControllerDelegate, MyURLConnectionDelegate, ChargeViewControllerDelegate, QuestionViewControllerDelegate, UIAlertViewDelegate>

@end

@implementation PayViewController{
    UIView      *chargeView;
    UILabel     *statusLabel;
    UIButton    *questionButton;
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
    
    UIView                      *waitCover;
    
    NSString    *_money;
    NSString    *_time;
    
    //侧面菜单
    InfoViewController          *infoViewController;
    UIView                      *cover;
    UISwipeGestureRecognizer    *leftSwipGestureRecognizer;
    
    BOOL        isConnect;
}

- (id)init {
    if(self == [super init]) {
        myAppdelegate = [[UIApplication sharedApplication] delegate];
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
            NSTimer *ChaoshiTime = [NSTimer timerWithTimeInterval:15 target:self selector:@selector(stopRequest) userInfo:nil repeats:NO];
            [[NSRunLoop mainRunLoop] addTimer:ChaoshiTime forMode:NSDefaultRunLoopMode];
        }

    }
    return self;
}

- (void)UIInit {
    chargeView          = [[UIView alloc]init];
    statusLabel         = [[UILabel alloc]init];
    questionButton      = [[UIButton alloc]init];
    
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
    
    infoViewController = [[InfoViewController alloc] initWithFrame:CGRectMake((-1)*SCREEN_WIDTH, 0, SCREEN_WIDTH*0.8, SCREEN_HEIGHT)];
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
    statusLabel.frame = CGRectMake(chargeView.center.x-STATUSLABEL_WIDTH/2-QUESTIONBUTTON_WIDTH/2, 0, STATUSLABEL_WIDTH, STATUSLABEL_HEIGHT);
    statusLabel.textAlignment = NSTextAlignmentCenter;
    statusLabel.textColor = [UIColor whiteColor];
    statusLabel.text = @"计费结束";
    
    questionButton.frame = CGRectMake(statusLabel.center.x+STATUSLABEL_WIDTH/2-QUESTIONBUTTON_WIDTH/2, 0, QUESTIONBUTTON_WIDTH, QUESTIONBUTTON_HEIGHT);
    [questionButton setImage:[UIImage imageNamed:@"问号按钮"] forState:UIControlStateNormal];
    
    totalPayLabel.frame = CGRectMake(0.05*SCREEN_WIDTH, STATUSLABEL_HEIGHT, TOTALPAYLABEL_WIDTH, TOTALPAYLABEL_HEIGHT);
    totalPayLabel.textAlignment = NSTextAlignmentLeft;
    totalPayLabel.font = [UIFont systemFontOfSize:15];
    totalPayLabel.textColor = [UIColor whiteColor];
    totalPayLabel.text = @"费用总计：";
    
    moneyLabel.frame = CGRectMake(SCREEN_WIDTH-MONEYLABEL_WIDTH-0.05*SCREEN_WIDTH, STATUSLABEL_HEIGHT, MONEYLABEL_WIDTH, MONEYLABEL_HEIGHT);
    moneyLabel.textAlignment = NSTextAlignmentRight;
    moneyLabel.font = [UIFont systemFontOfSize:15];
    moneyLabel.textColor = [UIColor whiteColor];
    
    
    totalTimeLabel.frame = CGRectMake(0.05*SCREEN_WIDTH, STATUSLABEL_HEIGHT+TOTALTIME_HEIGHT, TOTALTIME_WIDTH, TOTALTIME_HEIGHT);
    totalTimeLabel.textAlignment = NSTextAlignmentLeft;
    totalTimeLabel.font = [UIFont systemFontOfSize:12];
    totalTimeLabel.textColor = [UIColor whiteColor];
    totalTimeLabel.text = @"使用时长：";
    
    timeLabel.frame = CGRectMake(SCREEN_WIDTH-TIMELABEL_WIDTH-0.05*SCREEN_WIDTH, STATUSLABEL_HEIGHT+TOTALTIME_HEIGHT, TIMELABEL_WIDTH, TIMELABEL_HEIGHT);
    timeLabel.textAlignment = NSTextAlignmentRight;
    timeLabel.font = [UIFont systemFontOfSize:12];
    timeLabel.textColor = [UIColor whiteColor];
    
    payListTableView.frame = CGRectMake(0, 0.3*SCREEN_HEIGHT, SCREEN_WIDTH, PAYLISTTABLEVIEW_HEIGHT);
    payListTableView.dataSource = self;
    payListTableView.delegate = self;
    payListTableView.scrollEnabled = NO;
    [payListTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    payListTableView.layer.borderWidth = 1;
    payListTableView.layer.borderColor = [UIColor grayColor].CGColor;
    
    confirmButton.frame = CGRectMake(0.05*SCREEN_WIDTH, 0.7*SCREEN_HEIGHT, CONFIRMBUTTON_WIDTH, CONFIRMBUTTON_HEIGHT);
    confirmButton.layer.cornerRadius = CORNERRADIUS;
    confirmButton.backgroundColor = UICOLOR;
    [confirmButton setTitle:@"确认支付" forState:UIControlStateNormal];
    [confirmButton addTarget:self action:@selector(QRCodeScanView) forControlEvents:UIControlEventTouchUpInside];
    
    hintMes.frame = CGRectMake(0.05*SCREEN_WIDTH, 0.7*SCREEN_HEIGHT+CONFIRMBUTTON_HEIGHT, CONFIRMBUTTON_WIDTH, CONFIRMBUTTON_HEIGHT);
    hintMes.text = @"任何支付问题，请联系客服：400-123-123";
    hintMes.textAlignment = NSTextAlignmentCenter;
    hintMes.textColor = [UIColor grayColor];
    hintMes.font = [UIFont systemFontOfSize:10];
    
    cover.backgroundColor = [UIColor blackColor];
    cover.alpha = 0.0;
    cover.hidden = YES;
    
    [self.view addSubview:chargeView];
    [chargeView addSubview:statusLabel];
    [chargeView addSubview:questionButton];
    [chargeView addSubview:totalPayLabel];
    [chargeView addSubview:moneyLabel];
    [self.view addSubview:payListTableView];
    [self.view addSubview:confirmButton];
    [self.view addSubview:hintMes];

    [chargeView addSubview:totalTimeLabel];
    [chargeView addSubview:timeLabel];

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
    NSTimer *ChaoshiTime = [NSTimer timerWithTimeInterval:15 target:self selector:@selector(stopRequest) userInfo:nil repeats:NO];
    [[NSRunLoop mainRunLoop] addTimer:ChaoshiTime forMode:NSDefaultRunLoopMode];
}

#pragma mark - 服务器返回
- (void)MyConnection:(MyURLConnection *)connection didReceiveData:(NSData *)data {
    NSDictionary *receiveJson = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
    if ([connection.name isEqualToString:@"pay"]) {
        [waitCover removeFromSuperview];
        NSString *status = receiveJson[@"status"];
        NSString *message = receiveJson[@"message"];
        if ([status isEqualToString:@"success"]) {
            myAppdelegate.isEndPay = YES;
//            // 付款成功
//            waitCover = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
//            waitCover.alpha = 1;
//            // 半黑膜
//            UIView *containerView = [[UIView alloc] initWithFrame:CGRectMake(0.3*SCREEN_WIDTH, 0.4*SCREEN_HEIGHT, 0.4*SCREEN_WIDTH, 0.15*SCREEN_HEIGHT)];
//            containerView.backgroundColor = [UIColor blackColor];
//            containerView.alpha = 0.6;
//            containerView.layer.cornerRadius = CORNERRADIUS*2;
//            [cover addSubview:containerView];
//            // 一个控件
//            UILabel *hintMes1 = [[UILabel alloc] initWithFrame:CGRectMake(0, 0.4*containerView.frame.size.height, containerView.frame.size.width, 0.2*containerView.frame.size.height)];
//            hintMes1.text = @"付款成功";
//            hintMes1.textColor = [UIColor whiteColor];
//            hintMes1.textAlignment = NSTextAlignmentCenter;
//            [containerView addSubview:hintMes1];
//            [self.view addSubview:waitCover];
            // 显示时间
            
            isConnect = YES;
            // 付费成功 跳转扫描页面 并且对本地的balance扣除相应的金额
            CGFloat balan = [myAppdelegate.balance floatValue];
            CGFloat money = [_money floatValue];
            balan -= money;
            myAppdelegate.balance = [NSString stringWithFormat:@"%f", balan];
            [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:0] animated:YES];
        }else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"付款失败" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            alert.tag = 1;
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
        }
    }else if ([connection.name isEqualToString:@"balance"]) {
        NSString *status = receiveJson[@"status"];
        NSString *balance = receiveJson[@"balance"];
        NSLog(@"balance:%@", balance);
        NSLog(@"shouldPaymoney:%@", _money);
        if ([status isEqualToString:@"success"]) {
            isConnect = YES;
            CGFloat shouldPayMoney = [_money floatValue];
            CGFloat havaMoney = [balance floatValue];
            if (havaMoney > shouldPayMoney) {
                // 付款api
                // 从本地拿取accessToken
                userDefaults = [NSUserDefaults standardUserDefaults];
                NSString *accessToken = [userDefaults objectForKey:@"accessToken"];
                // 从本地拿取bikeNo
                NSString *bikeNo = [userDefaults objectForKey:@"bikeNo"];
                // 从本地拿取电话
                NSString *phoneNumber = [userDefaults objectForKey:@"phoneNumber"];
                // 判断选择了哪一种支付方式
                NSIndexPath *indexPath = [payListTableView indexPathForSelectedRow];
                NSInteger selectPayWayNumber = indexPath.row;
                NSString *isMissngStr = [NSString stringWithFormat:@"%d", myAppdelegate.isMissing];
                NSLog(@"ismissing:%@", isMissngStr);
                
                NSString *urlStr = [IP stringByAppendingString:@"/ElephantBike/api/money/returnpay"];
                NSURL *url = [NSURL URLWithString:urlStr];
                NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10];
                NSString *dataStr = [NSString stringWithFormat:@"bikeid=%@&phone=%@&paymode=%@&access_token=%@&ismissing=%@", bikeNo, phoneNumber, [payWay objectAtIndex:selectPayWayNumber],  accessToken, isMissngStr];
                NSData *data = [dataStr dataUsingEncoding:NSUTF8StringEncoding];
                [request setHTTPBody:data];
                [request setHTTPMethod:@"POST"];
                MyURLConnection *connectionn = [[MyURLConnection alloc] MyConnectioin:request delegate:self andName:@"pay"];
                NSTimer *ChaoshiTime = [NSTimer timerWithTimeInterval:15 target:self selector:@selector(stopRequest) userInfo:nil repeats:NO];
                [[NSRunLoop mainRunLoop] addTimer:ChaoshiTime forMode:NSDefaultRunLoopMode];
            }else {
                [waitCover removeFromSuperview];
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"余额不足，请充值" delegate:self cancelButtonTitle:@"去充值" otherButtonTitles:@"取消", nil];
                alertView.tag = 0;
                [alertView show];
                // 余额不足
            }
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
    containerView.alpha = 0.6;
    containerView.layer.cornerRadius = CORNERRADIUS*2;
    [cover addSubview:containerView];
    // 一个控件
    UILabel *hintMes1 = [[UILabel alloc] initWithFrame:CGRectMake(0, 0.4*containerView.frame.size.height, containerView.frame.size.width, 0.2*containerView.frame.size.height)];
    hintMes1.text = @"无法连接网络";
    hintMes1.textColor = [UIColor whiteColor];
    hintMes1.textAlignment = NSTextAlignmentCenter;
    [containerView addSubview:hintMes1];
    [self.view addSubview:waitCover];
    // 显示时间
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(removeView) userInfo:nil repeats:NO];
    [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
    NSLog(@"网络超时");
}

- (void)stopRequest {
    if (!isConnect) {
        [waitCover removeFromSuperview];
        // 收到验证码  进行提示
        waitCover = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        waitCover.alpha = 1;
        // 半黑膜
        UIView *containerView = [[UIView alloc] initWithFrame:CGRectMake(0.3*SCREEN_WIDTH, 0.4*SCREEN_HEIGHT, 0.4*SCREEN_WIDTH, 0.15*SCREEN_HEIGHT)];
        containerView.backgroundColor = [UIColor blackColor];
        containerView.alpha = 0.6;
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
    if (isLose) {
        totalPayLabel.text = @"费用总计:";
        NSString *temp = [@"￥" stringByAppendingString:money];
        moneyLabel.text = temp;
        totalTimeLabel.text = @"单车丢失赔偿金:";
        NSString *temp1 = [@"￥" stringByAppendingString:money];
        timeLabel.text = temp1;
    }else {
        _money = money;
        _time = time;
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
    cell.imageView.image = [UIImage imageNamed:[payWay objectAtIndex:indexPath.row]];
    //设置imaged大小
    CGSize itemSize = CGSizeMake(PAYLISTTABLEVIEW_HEIGHT/3*0.8, PAYLISTTABLEVIEW_HEIGHT/3*0.8);
    UIGraphicsBeginImageContext(itemSize);
    CGRect imageRect = CGRectMake(0.0, 0.0, itemSize.width, itemSize.height);
    [cell.imageView.image drawInRect:imageRect];
    cell.imageView.image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    cell.textLabel.text = [payWay objectAtIndex:indexPath.row];
    cell.detailTextLabel.text = [wayDetails objectAtIndex:indexPath.row];
    if (indexPath.row == 0) {
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"选中"]];
        cell.accessoryView =imageView;
    }else {
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"没选中"]];
        cell.accessoryView = imageView;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    MyTableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    NSArray *array = [tableView visibleCells];
    for (UITableViewCell *cell in array) {
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"没选中"]];
        cell.accessoryView = imageView;
    }
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"选中"]];
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

#pragma mark - lifeCycle
- (void)viewWillAppear:(BOOL)animated {
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    [self UIInit];
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
