//
//  LoginViewController.m
//  ElephantBike
//
//  Created by 黄杰锋 on 16/1/14.
//  Copyright © 2016年 黄杰锋. All rights reserved.
//

#import "LoginViewController.h"
#import "UISize.h"
#import "QRCodeScanViewController.h"
#import "LawViewController.h"
#import "AppDelegate.h"
#import "MyURLConnection.h"
#import "ChargeViewController.h"
#import "PayViewController.h"


@interface LoginViewController () <MyURLConnectionDelegate>

@end

@implementation LoginViewController{
    UITextField     *phoneTF;
    UITextField     *verifyTF;
    UIButton        *verifyButton;
    UIButton        *startButton;
    UILabel         *mesLabel;
    UIButton        *mesButton;
    UIView          *cover;
    NSTimer         *countDownTime;
    NSUserDefaults  *userDefaults;
    NSString        *phoneNumber;
    AppDelegate     *MyAppDelegate;
    BOOL            isConnect;
}
int countDown = 5;

- (instancetype)init {
    if (self = [super init]) {
        phoneTF         = [[UITextField alloc]init];
        verifyTF        = [[UITextField alloc]init];
        verifyButton    = [[UIButton alloc]init];
        startButton     = [[UIButton alloc]init];
        mesLabel        = [[UILabel alloc]init];
        mesButton       = [[UIButton alloc] init];
        userDefaults    = [NSUserDefaults standardUserDefaults];
        MyAppDelegate   = [[UIApplication sharedApplication] delegate];
        isConnect       = NO;
    }
    return self;
}


#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    [self UIInit];
    self.view.backgroundColor = [UIColor whiteColor];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [phoneTF becomeFirstResponder];
}

#pragma mark - Private Method
- (void)UIInit {
    phoneTF.frame = CGRectMake(0.1*SCREEN_WIDTH, 0.5*SAME_HEIGHT+STATUS_HEIGHT+NAVIGATIONBAR_HEIGHT, PHONE_TEXTFIELD_WIDTH, SAME_HEIGHT);
    phoneTF.placeholder = @"手机号";
    phoneTF.layer.cornerRadius = CORNERRADIUS;
    phoneTF.layer.borderColor = [UIColor grayColor].CGColor;
    phoneTF.layer.borderWidth = 1;
    phoneTF.borderStyle = UITextBorderStyleRoundedRect;
    phoneTF.keyboardType = UIKeyboardTypeNumberPad;
    [phoneTF addTarget:self action:@selector(TextFieldChanged) forControlEvents:UIControlEventEditingChanged];
    
    verifyButton.frame = CGRectMake(PHONE_TEXTFIELD_WIDTH+0.125*SCREEN_WIDTH, 0.5*SAME_HEIGHT+STATUS_HEIGHT+NAVIGATIONBAR_HEIGHT, VERIFY_BUTTON_WIDTH, SAME_HEIGHT);
    verifyButton.backgroundColor = [UIColor grayColor];
    verifyButton.layer.cornerRadius = CORNERRADIUS;
    verifyButton.enabled = false;
    [verifyButton setTitle:@"验证" forState:UIControlStateNormal];
    [verifyButton addTarget:self action:@selector(buttonDidVerify) forControlEvents:UIControlEventTouchUpInside];
    
    verifyTF.frame = CGRectMake(0.1*SCREEN_WIDTH, 1.725*SAME_HEIGHT+STATUS_HEIGHT+NAVIGATIONBAR_HEIGHT, SAME_WIDTH, SAME_HEIGHT);
    verifyTF.layer.cornerRadius = CORNERRADIUS;
    verifyTF.layer.borderColor = [UIColor grayColor].CGColor;
    verifyTF.layer.borderWidth = 1;
    verifyTF.borderStyle = UITextBorderStyleRoundedRect;
    verifyTF.placeholder = @"验证码";
    verifyTF.keyboardType = UIKeyboardTypeNumberPad;
    // 点击验证按钮后才出现 没收到？
    UIButton *rightButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, VERIFY_BUTTON_WIDTH*1.5, SAME_HEIGHT)];
    [rightButton setImage:[UIImage imageNamed:@"没收到验证码"] forState:UIControlStateNormal];
    verifyTF.rightView = rightButton;
    [verifyTF addTarget:self action:@selector(TextFieldChanged) forControlEvents:UIControlEventEditingChanged];
    
    startButton.frame = CGRectMake(0.1*SCREEN_WIDTH, 3*SAME_HEIGHT+STATUS_HEIGHT+NAVIGATIONBAR_HEIGHT, SAME_WIDTH, SAME_HEIGHT);
    startButton.backgroundColor = [UIColor grayColor];
    startButton.layer.cornerRadius = CORNERRADIUS;
    startButton.enabled = false;
    [startButton setTitle:@"开始" forState:UIControlStateNormal];
    [startButton addTarget:self action:@selector(buttonDidStart) forControlEvents:UIControlEventTouchUpInside];
    
    mesLabel.frame = CGRectMake(0.1*SAME_WIDTH, 4.125*SAME_HEIGHT+STATUS_HEIGHT+NAVIGATIONBAR_HEIGHT, SAME_WIDTH*0.5, SAME_HEIGHT);
    mesLabel.text = @"点击“开始”，即表示您同意";
    mesLabel.textAlignment = NSTextAlignmentRight;
    mesLabel.font = [UIFont systemFontOfSize:10];
    
    mesButton.frame = CGRectMake(0.1*SAME_WIDTH+SAME_WIDTH*0.5, 4.125*SAME_HEIGHT+STATUS_HEIGHT+NAVIGATIONBAR_HEIGHT, SAME_WIDTH*0.5, SAME_HEIGHT);
    mesButton.titleLabel.textAlignment = NSTextAlignmentLeft;
    mesButton.titleLabel.font = [UIFont systemFontOfSize:10];
    mesButton.titleLabel.textColor = UICOLOR;
    NSMutableAttributedString *title = [[NSMutableAttributedString alloc] initWithString:@"《法律声明及隐私政策》"];
    NSRange titleRnage = {0, [title length]};
    [title addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle] range:titleRnage];
    [mesButton setAttributedTitle:title forState:UIControlStateNormal];
    mesButton.titleLabel.font = [UIFont systemFontOfSize:12];
    [mesButton addTarget:self action:@selector(gotoLawView) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:phoneTF];
    [self.view addSubview:verifyButton];
    [self.view addSubview:verifyTF];
    [self.view addSubview:startButton];
    [self.view addSubview:mesLabel];
    [self.view addSubview:mesButton];
    
    [self NavigationInit];
}

- (void)NavigationInit {
    self.navigationItem.title = @"验证手机";
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"返回"] style:UIBarButtonItemStylePlain target:self action:@selector(back)];
    self.navigationItem.leftBarButtonItem = backButton;
}

- (void)timeChanged {
    if (countDown == 0) {
        [countDownTime invalidate];
        countDownTime = nil;
        countDown = 60;
        verifyButton.backgroundColor = UICOLOR;
        [verifyButton setTitle:@"验证" forState:UIControlStateNormal];
        verifyButton.enabled = true;
    }else {
        [verifyButton setTitle:[NSString stringWithFormat:@"%ds", countDown--] forState:UIControlStateNormal];
    }
}

#pragma mark - Button Event
#pragma mark - TextField Changed
- (void)TextFieldChanged {
    if (phoneTF.isFirstResponder) {
        if ([phoneTF.text isEqual:@""]) {
            verifyButton.backgroundColor = [UIColor grayColor];
        }else {
            verifyButton.backgroundColor = [UIColor colorWithRed:0.050 green:0.700 blue:0.050 alpha:1.000];
            verifyButton.enabled = YES;
        }
    }else if(verifyTF.isFirstResponder){
        if ([verifyTF.text isEqual:@""]) {
            startButton.backgroundColor = [UIColor grayColor];
        }else {
            startButton.backgroundColor = [UIColor colorWithRed:0.050 green:0.700 blue:0.050 alpha:1.000];
            startButton.enabled = YES;
        }
    }
}

#pragma mark - VerifyButton TouchInside
- (void)buttonDidVerify {
    if ([phoneTF.text length] != 11 ) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"请输入正确的电话号码" delegate:self cancelButtonTitle:@"确认" otherButtonTitles:nil, nil];
        [alert show];
    }else {
        phoneNumber = phoneTF.text;
        verifyButton.enabled = false; //摁下验证后显示倒计时 不可用按钮
        verifyTF.rightViewMode = UITextFieldViewModeAlways;
        verifyButton.backgroundColor = [UIColor grayColor];
        countDownTime = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timeChanged) userInfo:nil repeats:YES];  // 存在问题，当60s后会怎么样
        [[NSRunLoop mainRunLoop] addTimer:countDownTime forMode:NSDefaultRunLoopMode];
        // 集成api  此处是膜
        cover = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        cover.alpha = 1;
        // 半黑膜
        UIView *containerView = [[UIView alloc] initWithFrame:CGRectMake(0.3*SCREEN_WIDTH, 0.4*SCREEN_HEIGHT, 0.4*SCREEN_WIDTH, 0.15*SCREEN_HEIGHT)];
        containerView.backgroundColor = [UIColor blackColor];
        containerView.alpha = 0.6;
        containerView.layer.cornerRadius = CORNERRADIUS*2;
        [cover addSubview:containerView];
        // 两个控件
        UIActivityIndicatorView *waitActivityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        waitActivityView.frame = CGRectMake(0.33*containerView.frame.size.width, 0.1*containerView.frame.size.width, 0.33*containerView.frame.size.width, 0.4*containerView.frame.size.height);
        [waitActivityView startAnimating];
        [containerView addSubview:waitActivityView];
        
        UILabel *hintMes = [[UILabel alloc] initWithFrame:CGRectMake(0, 0.7*containerView.frame.size.height, containerView.frame.size.width, 0.2*containerView.frame.size.height)];
        hintMes.text = @"正在发送验证码";
        hintMes.textColor = [UIColor whiteColor];
        hintMes.textAlignment = NSTextAlignmentCenter;
        [containerView addSubview:hintMes];
        
        [self.view addSubview:cover];
        
        NSString *urlStr = [IP stringByAppendingString:@"/ElephantBike/api/msg/sms"];
        NSURL *url = [NSURL URLWithString:urlStr];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
        NSString *dataStr = [NSString stringWithFormat:@"phone=%@", phoneNumber];
        NSData *data = [dataStr dataUsingEncoding:NSUTF8StringEncoding];
        [request setHTTPBody:data];
        [request setHTTPMethod:@"POST"];
        MyURLConnection *connection = [[MyURLConnection alloc] MyConnectioin:request delegate:self andName:@"getNumber"];
        NSTimer *ChaoshiTime = [NSTimer timerWithTimeInterval:15 target:self selector:@selector(stopRequest) userInfo:nil repeats:NO];
        [[NSRunLoop mainRunLoop] addTimer:ChaoshiTime forMode:NSDefaultRunLoopMode];
    }
}

- (void)stopRequest {
    if (!isConnect) {
        [cover removeFromSuperview];
        // 收到验证码  进行提示
        cover = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        cover.alpha = 1;
        // 半黑膜
        UIView *containerView = [[UIView alloc] initWithFrame:CGRectMake(0.3*SCREEN_WIDTH, 0.4*SCREEN_HEIGHT, 0.4*SCREEN_WIDTH, 0.15*SCREEN_HEIGHT)];
        containerView.backgroundColor = [UIColor blackColor];
        containerView.alpha = 0.6;
        containerView.layer.cornerRadius = CORNERRADIUS*2;
        [cover addSubview:containerView];
        // 一个控件
        UILabel *hintMes = [[UILabel alloc] initWithFrame:CGRectMake(0, 0.4*containerView.frame.size.height, containerView.frame.size.width, 0.2*containerView.frame.size.height)];
        hintMes.text = @"无法连接服务器";
        hintMes.textColor = [UIColor whiteColor];
        hintMes.textAlignment = NSTextAlignmentCenter;
        [containerView addSubview:hintMes];
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

- (void)buttonDidStart {
    // 提交按钮
    if ([verifyTF.text length] != 6) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"请输入6位验证码" delegate:self cancelButtonTitle:@"确认" otherButtonTitles:nil, nil];
        [alert show];
    }else {
        //验证 验证码是否正确。
        //验证等待动画
        // 集成api  此处是膜
        cover = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        cover.alpha = 1;
        // 半黑膜
        UIView *containerView = [[UIView alloc] initWithFrame:CGRectMake(0.3*SCREEN_WIDTH, 0.4*SCREEN_HEIGHT, 0.4*SCREEN_WIDTH, 0.15*SCREEN_HEIGHT)];
        containerView.backgroundColor = [UIColor blackColor];
        containerView.alpha = 0.6;
        containerView.layer.cornerRadius = CORNERRADIUS*2;
        [cover addSubview:containerView];
        // 两个控件
        UIActivityIndicatorView *waitActivityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        waitActivityView.frame = CGRectMake(0.33*containerView.frame.size.width, 0.1*containerView.frame.size.width, 0.33*containerView.frame.size.width, 0.4*containerView.frame.size.height);
        [waitActivityView startAnimating];
        [containerView addSubview:waitActivityView];
        
        UILabel *hintMes = [[UILabel alloc] initWithFrame:CGRectMake(0, 0.7*containerView.frame.size.height, containerView.frame.size.width, 0.2*containerView.frame.size.height)];
        hintMes.text = @"请稍后...";
        hintMes.textColor = [UIColor whiteColor];
        hintMes.textAlignment = NSTextAlignmentCenter;
        [containerView addSubview:hintMes];
        
        [self.view addSubview:cover];
        // 显示时间
        NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(removeView) userInfo:nil repeats:NO];
        [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
        // 请求服务器 异步post
        // 获取缓存的isLogin
        BOOL isLogin = [userDefaults boolForKey:@"isLogin"];
        NSString *urlStr = [IP stringByAppendingString:@"/ElephantBike/api/user/login"];
        NSURL *url = [NSURL URLWithString:urlStr];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
        NSString *dataStr = [NSString stringWithFormat:@"phone=%@&islogin=%d&verify_code=%@", phoneTF.text, isLogin, verifyTF.text];
        NSData *data = [dataStr dataUsingEncoding:NSUTF8StringEncoding];
        [request setHTTPBody:data];
        [request setHTTPMethod:@"POST"];
        MyURLConnection *connection = [[MyURLConnection alloc] MyConnectioin:request delegate:self andName:@"Login"];
        NSTimer *ChaoshiTime = [NSTimer timerWithTimeInterval:15 target:self selector:@selector(stopRequest) userInfo:nil repeats:NO];
        [[NSRunLoop mainRunLoop] addTimer:ChaoshiTime forMode:NSDefaultRunLoopMode];
        
//        NSLog(@"%@", status);
//        NSLog(@"%@", isfrozen);
//        NSLog(@"%@", accessToken);
    }
}
#pragma mark - 服务器返回
- (void)MyConnection:(MyURLConnection *)connection didReceiveData:(NSData *)data {
    NSDictionary *receiveJson = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
    if ([connection.name isEqualToString:@"Login"]) {
        NSString *status = receiveJson[@"status"];
        NSString *isfrozen = receiveJson[@"isfrozen"];
        NSString *isFinish = receiveJson[@"isfinish"];
        NSString *isPay = receiveJson[@"ispay"];
        NSString *accessToken = receiveJson[@"access_token"];
        [userDefaults setValue:accessToken forKey:@"accessToken"];//缓存access_token
        if ([status isEqualToString:@"success"]) {
            isConnect = YES;
            if ([isfrozen isEqualToString:@"-1"]) {
                MyAppDelegate.isFreeze = true;
                MyAppDelegate.isIdentify = true;
            }else if([isfrozen isEqualToString:@"0"]) {
                MyAppDelegate.isFreeze = false;
                MyAppDelegate.isIdentify = false;
            }else if([isfrozen isEqualToString:@"1"]) {
                MyAppDelegate.isFreeze = false;
                MyAppDelegate.isIdentify = YES;
            }else {
                MyAppDelegate.isUpload = YES;
            }
            if ([isFinish isEqualToString:@"1"]) {
                MyAppDelegate.isEndRiding = false;
                MyAppDelegate.isRestart = YES;
            }
            if ([isPay isEqualToString:@"1"]) {
                MyAppDelegate.isEndPay = false;
                MyAppDelegate.isRestart = YES;
            }
            [userDefaults setBool:true forKey:@"isLogin"];
            [userDefaults setValue:phoneNumber forKey:@"phoneNumber"];
            // 需要登陆的时候  登陆后请求服务器获取余额
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
    }else if ([connection.name isEqualToString:@"balance"]) {
        NSString *status = receiveJson[@"status"];
        NSString *balance = receiveJson[@"balance"];
        if (status) {
            isConnect = YES;
            MyAppDelegate.balance = balance;
            if (!MyAppDelegate.isEndRiding) {
                ChargeViewController *chargeViewController = [[ChargeViewController alloc] init];
                [self.navigationController pushViewController:chargeViewController animated:YES];
            }else if (!MyAppDelegate.isEndPay) {
                // 跳到支付页面
                PayViewController *payViewController = [[PayViewController alloc] init];
                [self.navigationController pushViewController:payViewController animated:YES];
            }else {
                [self.navigationController popViewControllerAnimated:YES];
            }
        }
    }else if ([connection.name isEqualToString:@"getNumber"]) {
        NSString *status = receiveJson[@"status"];
        NSString *message = receiveJson[@"message"];
        if ([status isEqualToString:@"success"]) {
            isConnect = YES;
            [cover removeFromSuperview];
            // 收到验证码  进行提示
            cover = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
            cover.alpha = 1;
            // 半黑膜
            UIView *containerView = [[UIView alloc] initWithFrame:CGRectMake(0.3*SCREEN_WIDTH, 0.4*SCREEN_HEIGHT, 0.4*SCREEN_WIDTH, 0.15*SCREEN_HEIGHT)];
            containerView.backgroundColor = [UIColor blackColor];
            containerView.alpha = 0.6;
            containerView.layer.cornerRadius = CORNERRADIUS*2;
            [cover addSubview:containerView];
            // 一个控件
            UILabel *hintMes = [[UILabel alloc] initWithFrame:CGRectMake(0, 0.4*containerView.frame.size.height, containerView.frame.size.width, 0.2*containerView.frame.size.height)];
            hintMes.text = @"已发送";
            hintMes.textColor = [UIColor whiteColor];
            hintMes.textAlignment = NSTextAlignmentCenter;
            [containerView addSubview:hintMes];
            [self.view addSubview:cover];
            // 显示时间
            NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(removeView) userInfo:nil repeats:NO];
            [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
            NSLog(@"收到验证码");
        }
    }
}

- (void)MyConnection:(MyURLConnection *)connection didFailWithError:(NSError *)error {
    isConnect = YES;
    [cover removeFromSuperview];
    // 收到验证码  进行提示
    cover = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    cover.alpha = 1;
    // 半黑膜
    UIView *containerView = [[UIView alloc] initWithFrame:CGRectMake(0.3*SCREEN_WIDTH, 0.4*SCREEN_HEIGHT, 0.4*SCREEN_WIDTH, 0.15*SCREEN_HEIGHT)];
    containerView.backgroundColor = [UIColor blackColor];
    containerView.alpha = 0.6;
    containerView.layer.cornerRadius = CORNERRADIUS*2;
    [cover addSubview:containerView];
    // 一个控件
    UILabel *hintMes = [[UILabel alloc] initWithFrame:CGRectMake(0, 0.4*containerView.frame.size.height, containerView.frame.size.width, 0.2*containerView.frame.size.height)];
    hintMes.text = @"无法连接网络";
    hintMes.textColor = [UIColor whiteColor];
    hintMes.textAlignment = NSTextAlignmentCenter;
    [containerView addSubview:hintMes];
    [self.view addSubview:cover];
    // 显示时间
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(removeView) userInfo:nil repeats:NO];
    [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
    NSLog(@"网络超时");
}

- (void)back {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)gotoLawView {
    LawViewController *lawViewController = [[LawViewController alloc] init];
    [self.navigationController pushViewController:lawViewController animated:YES];
}

#pragma mark - TouchesBegin
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if ([phoneTF isFirstResponder]) {
        [phoneTF resignFirstResponder];
    }else if([verifyTF isFirstResponder]) {
        [verifyTF resignFirstResponder];
    }
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
