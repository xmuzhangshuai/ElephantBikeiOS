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

#define PHONETF_X   0.1*SCREEN_WIDTH
#define PHONETF_Y   

#define PHONETF_WIDTH   0.62*SCREEN_WIDTH
#define PHONETF_HEIGHT  0.0562*SCREEN_HEIGHT
#define PHONETF_CENTER_X    0.41*SCREEN_WIDTH
#define PHONETF_CENTER_Y    0.1997*SCREEN_HEIGHT

#define VERIFYBUTTON_WIDTH  0.16*SCREEN_WIDTH
#define VERIFYBUTTON_HEIGHT 0.0562*SCREEN_HEIGHT
#define VERIFYBUTTON_CENTER_X   0.82*SCREEN_WIDTH

#define VERIFYTF_WIDTH  0.8*SCREEN_WIDTH
#define VERIFYTF_CENTER_Y   0.2762*SCREEN_HEIGHT

#define STARTBUTTON_CENTER_Y    0.352*SCREEN_HEIGHT

#define MESBUTTON_CENTER_Y       0.409*SCREEN_HEIGHT


@interface LoginViewController () <MyURLConnectionDelegate, UITextFieldDelegate>

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
    int             countDown;
    
    NSString    *previousTextFieldContent;
    UITextRange *previousSelection;
}


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
    self.view.backgroundColor = BACKGROUNDCOLOR;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [phoneTF becomeFirstResponder];
    [userDefaults setBool:NO forKey:@"isLogin"];
    MyAppDelegate.isLogout = NO;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    [countDownTime invalidate];

}

#pragma mark - Private Method
- (void)UIInit {
    phoneTF.frame = CGRectMake(0, 0, PHONETF_WIDTH, PHONETF_HEIGHT);
    phoneTF.center = CGPointMake(PHONETF_CENTER_X, PHONETF_CENTER_Y);
    phoneTF.placeholder = @"手机号";
    phoneTF.layer.cornerRadius = CORNERRADIUS;
    phoneTF.layer.borderColor = [UIColor grayColor].CGColor;
    phoneTF.layer.borderWidth = 1;
    phoneTF.borderStyle = UITextBorderStyleRoundedRect;
    phoneTF.keyboardType = UIKeyboardTypeNumberPad;
    phoneTF.font = [UIFont fontWithName:@"QingYuanMono" size:14];
    phoneTF.delegate = self;
    [phoneTF addTarget:self action:@selector(TextFieldChanged) forControlEvents:UIControlEventEditingChanged];
    
    verifyButton.frame = CGRectMake(0, 0, VERIFYBUTTON_WIDTH, VERIFYBUTTON_HEIGHT);
    verifyButton.center = CGPointMake(VERIFYBUTTON_CENTER_X, PHONETF_CENTER_Y);
    verifyButton.backgroundColor = [UIColor grayColor];
    verifyButton.layer.cornerRadius = CORNERRADIUS;
    verifyButton.enabled = false;
    [verifyButton setTitle:@"验证" forState:UIControlStateNormal];
    verifyButton.titleLabel.font = [UIFont fontWithName:@"QingYuanMono" size:14];
    [verifyButton addTarget:self action:@selector(buttonDidVerify) forControlEvents:UIControlEventTouchUpInside];
    
    verifyTF.frame = CGRectMake(0, 0, VERIFYTF_WIDTH, PHONETF_HEIGHT);
    verifyTF.center = CGPointMake(CENTER_X, VERIFYTF_CENTER_Y);
    verifyTF.layer.cornerRadius = CORNERRADIUS;
    verifyTF.layer.borderColor = [UIColor grayColor].CGColor;
    verifyTF.layer.borderWidth = 1;
    verifyTF.borderStyle = UITextBorderStyleRoundedRect;
    verifyTF.placeholder = @"验证码";
    verifyTF.font = [UIFont fontWithName:@"QingYuanMono" size:14];
    verifyTF.keyboardType = UIKeyboardTypeNumberPad;
    // 点击验证按钮后才出现 没收到？
    UIButton *rightButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, VERIFY_BUTTON_WIDTH*1.5, SAME_HEIGHT)];
    [rightButton setImage:[UIImage imageNamed:@"没收到验证码"] forState:UIControlStateNormal];
    verifyTF.rightView = rightButton;
    verifyTF.rightView.hidden = YES;
    rightButton.titleLabel.font = [UIFont fontWithName:@"QingYuanMono" size:8];
    [rightButton addTarget:self action:@selector(requestForCalling) forControlEvents:UIControlEventTouchUpInside];
    [verifyTF addTarget:self action:@selector(TextFieldChanged) forControlEvents:UIControlEventEditingChanged];
    
    startButton.frame = CGRectMake(0, 0, VERIFYTF_WIDTH, PHONETF_HEIGHT);
    startButton.center = CGPointMake(CENTER_X, STARTBUTTON_CENTER_Y);
    startButton.backgroundColor = [UIColor grayColor];
    startButton.layer.cornerRadius = CORNERRADIUS;
    startButton.enabled = false;
    [startButton setTitle:@"开始" forState:UIControlStateNormal];
    startButton.titleLabel.font = [UIFont fontWithName:@"QingYuanMono" size:14];
    [startButton addTarget:self action:@selector(buttonDidStart) forControlEvents:UIControlEventTouchUpInside];
    
    mesButton.frame = CGRectMake(0, 0, VERIFYTF_WIDTH, PHONETF_HEIGHT);
    mesButton.center = CGPointMake(CENTER_X, MESBUTTON_CENTER_Y);
    mesButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    mesButton.titleLabel.font = [UIFont fontWithName:@"QingYuanMono" size:10];
    NSMutableAttributedString *title = [[NSMutableAttributedString alloc] initWithString:@"点击“开始”，即表示您同意《法律声明及隐私政策》"];
    NSRange titleRnage = {13, [title length]-13};
    [title addAttribute:NSForegroundColorAttributeName value:UICOLOR range:titleRnage];
    [mesButton setAttributedTitle:title forState:UIControlStateNormal];
    [mesButton addTarget:self action:@selector(gotoLawView) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:phoneTF];
    [self.view addSubview:verifyButton];
    [self.view addSubview:verifyTF];
    [self.view addSubview:startButton];
    [self.view addSubview:mesButton];
    
    [self NavigationInit];
}

- (void)NavigationInit {
    self.navigationItem.title = @"验证手机";
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"返回"] style:UIBarButtonItemStylePlain target:self action:@selector(back)];
    backButton.tintColor = [UIColor grayColor];
    self.navigationItem.leftBarButtonItem = backButton;
    [self.navigationController.navigationBar setTitleTextAttributes:
     @{NSFontAttributeName:[UIFont fontWithName:@"QingYuanMono" size:18],
       NSForegroundColorAttributeName:[UIColor blackColor]}];
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
        [verifyButton setTitle:[NSString stringWithFormat:@"%d秒", countDown--] forState:UIControlStateNormal];
    }
}

#pragma mark - Button Event
#pragma mark - TextField Changed
- (void)TextFieldChanged {
    if (phoneTF.isFirstResponder) {
//        if ([phoneTF.text length] >= 13) {
//            phoneTF.text = [phoneTF.text substringWithRange:NSMakeRange(0, 13)];
//        }else if ([phoneTF.text length] == 3) {
//            phoneTF.text = [phoneTF.text stringByAppendingString:@" "];
//        }else if ([phoneTF.text length] == 8) {
//            phoneTF.text = [phoneTF.text stringByAppendingString:@" "];
//        }else if ([phoneTF.text length] == 4) {
//            if ([phoneTF.text rangeOfString:@" "].location != NSNotFound) {
//                phoneTF.text = [phoneTF.text substringWithRange:NSMakeRange(0, 3)];
//            }
//        }else if ([phoneTF.text length] == 9) {
//            phoneTF.text = [phoneTF.text substringWithRange:NSMakeRange(0, 8)];
//        }
//        if ([verifyButton.titleLabel.text isEqualToString:@"验证"]) {
//            if ([phoneTF.text isEqual:@""]) {
//                verifyButton.backgroundColor = [UIColor grayColor];
//            }else if ([self isMobileNumber:[phoneTF.text stringByReplacingOccurrencesOfString:@" " withString:@""]]){
//                verifyButton.backgroundColor = UICOLOR;
//                verifyButton.enabled = YES;
//            }
//        }
        NSUInteger targetCursorPosition =
        [phoneTF offsetFromPosition:phoneTF.beginningOfDocument
                           toPosition:phoneTF.selectedTextRange.start];
        // nStr表示不带空格的号码
        NSString* nStr = [phoneTF.text stringByReplacingOccurrencesOfString:@" " withString:@""];
        NSString* preTxt = [previousTextFieldContent stringByReplacingOccurrencesOfString:@" " withString:@""];
        
        char editFlag = 0;// 正在执行删除操作时为0，否则为1
        
        if (nStr.length <= preTxt.length) {
            editFlag = 0;
        }
        else {
            editFlag = 1;
        }
        
        // textField设置text
        if (nStr.length > 11)
        {
            phoneTF.text = previousTextFieldContent;
            phoneTF.selectedTextRange = previousSelection;
            return;
        }
        
        // 空格
        NSString* spaceStr = @" ";
        
        NSMutableString* mStrTemp = [NSMutableString new];
        int spaceCount = 0;
        if (nStr.length < 3 && nStr.length > -1)
        {
            spaceCount = 0;
        }else if (nStr.length < 7 && nStr.length >2)
        {
            spaceCount = 1;
            
        }else if (nStr.length < 12 && nStr.length > 6)
        {
            spaceCount = 2;
        }
        
        for (int i = 0; i < spaceCount; i++)
        {
            if (i == 0) {
                [mStrTemp appendFormat:@"%@%@", [nStr substringWithRange:NSMakeRange(0, 3)], spaceStr];
            }else if (i == 1)
            {
                [mStrTemp appendFormat:@"%@%@", [nStr substringWithRange:NSMakeRange(3, 4)], spaceStr];
            }else if (i == 2)
            {
                [mStrTemp appendFormat:@"%@%@", [nStr substringWithRange:NSMakeRange(7, 4)], spaceStr];
            }
        }
        
        if (nStr.length == 11)
        {
            [mStrTemp appendFormat:@"%@%@", [nStr substringWithRange:NSMakeRange(7, 4)], spaceStr];
        }
        
        if (nStr.length < 4)
        {
            [mStrTemp appendString:[nStr substringWithRange:NSMakeRange(nStr.length-nStr.length % 3, nStr.length % 3)]];
        }else if(nStr.length > 3)
        {
            NSString *str = [nStr substringFromIndex:3];
            [mStrTemp appendString:[str substringWithRange:NSMakeRange(str.length-str.length % 4,
                                                                       str.length % 4)]];
            if (nStr.length == 11)
            {
                [mStrTemp deleteCharactersInRange:NSMakeRange(13, 1)];
            }
        }
        
        phoneTF.text = mStrTemp;
        // textField设置selectedTextRange
        NSUInteger curTargetCursorPosition = targetCursorPosition;// 当前光标的偏移位置
        if (editFlag == 0)
        {
            //删除
            if (targetCursorPosition == 9 || targetCursorPosition == 4)
            {
                curTargetCursorPosition = targetCursorPosition - 1;
            }
        }
        else {
            //添加
            if (nStr.length == 8 || nStr.length == 4)
            {
                curTargetCursorPosition = targetCursorPosition + 1;
            }
        }
        
        UITextPosition *targetPosition = [phoneTF positionFromPosition:[phoneTF beginningOfDocument]
                                                                  offset:curTargetCursorPosition];
        [phoneTF setSelectedTextRange:[phoneTF textRangeFromPosition:targetPosition
                                                             toPosition :targetPosition]];
        
        if ([verifyButton.titleLabel.text isEqualToString:@"验证"]) {
            if ([phoneTF.text isEqual:@""]) {
                verifyButton.backgroundColor = [UIColor grayColor];
            }else if ([self isMobileNumber:[phoneTF.text stringByReplacingOccurrencesOfString:@" " withString:@""]]){
                verifyButton.backgroundColor = UICOLOR;
                verifyButton.enabled = YES;
            }
        }
    }else if(verifyTF.isFirstResponder){
        if ([verifyTF.text length] >= 6) {
            verifyTF.text = [verifyTF.text substringWithRange:NSMakeRange(0, 6)];
        }
        if ([verifyTF.text isEqual:@""]) {
            startButton.backgroundColor = [UIColor grayColor];
        }else if([self isVerifyNumber:verifyTF.text]){
            startButton.backgroundColor = UICOLOR;
            startButton.enabled = YES;
        }
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if (textField == phoneTF) {
        previousTextFieldContent = textField.text;
        previousSelection = textField.selectedTextRange;
    }
    
    return YES;
}


#pragma mark - VerifyButton TouchInside
- (void)buttonDidVerify {
    // 30秒后显示没收到
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:15 target:self selector:@selector(showTheMes) userInfo:nil repeats:NO];
    
    phoneNumber = [phoneTF.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    verifyButton.enabled = false; //摁下验证后显示倒计时 不可用按钮
    verifyTF.rightViewMode = UITextFieldViewModeAlways;
    verifyButton.backgroundColor = [UIColor grayColor];
    countDownTime = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timeChanged) userInfo:nil repeats:YES];  // 存在问题，当60s后会怎么样
    countDown = 60;
    [[NSRunLoop mainRunLoop] addTimer:countDownTime forMode:NSDefaultRunLoopMode];
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
    waitActivityView.frame = CGRectMake(0.33*containerView.frame.size.width, 0.1*containerView.frame.size.width, 0.33*containerView.frame.size.width, 0.4*containerView.frame.size.height);
    [waitActivityView startAnimating];
    [containerView addSubview:waitActivityView];
    
    UILabel *hintMes = [[UILabel alloc] initWithFrame:CGRectMake(0, 0.7*containerView.frame.size.height, containerView.frame.size.width, 0.2*containerView.frame.size.height)];
    hintMes.text = @"正在发送验证码";
    hintMes.textColor = [UIColor whiteColor];
    hintMes.textAlignment = NSTextAlignmentCenter;
    [containerView addSubview:hintMes];
    
    [self.view addSubview:cover];
    
    NSString *urlStr = [IP stringByAppendingString:@"/api/msg/sms"];
    NSURL *url = [NSURL URLWithString:urlStr];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    NSString *dataStr = [NSString stringWithFormat:@"phone=%@", phoneNumber];
    NSData *data = [dataStr dataUsingEncoding:NSUTF8StringEncoding];
    [request setHTTPBody:data];
    [request setHTTPMethod:@"POST"];
    MyURLConnection *connection = [[MyURLConnection alloc] MyConnectioin:request delegate:self andName:@"getNumber"];
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
        containerView.alpha = 0.8;
        containerView.layer.cornerRadius = CORNERRADIUS*2;
        [cover addSubview:containerView];
        // 一个控件
        UILabel *hintMes = [[UILabel alloc] initWithFrame:CGRectMake(0, 0.4*containerView.frame.size.height, containerView.frame.size.width, 0.2*containerView.frame.size.height)];
        hintMes.text = @"您的网络忙";
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
    if (![self isMobileNumber:phoneNumber]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"请输入正确的电话号码" delegate:self cancelButtonTitle:@"确认" otherButtonTitles:nil, nil];
        [alert show];
    }else if ([verifyTF.text length] != 6) {
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
        containerView.alpha = 0.8;
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

        // 请求服务器 异步post
        // 获取缓存的isLogin
        BOOL isLogin = [userDefaults boolForKey:@"isLogin"];
        NSString *urlStr = [IP stringByAppendingString:@"/api/user/login"];
        NSURL *url = [NSURL URLWithString:urlStr];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
        NSString *dataStr = [NSString stringWithFormat:@"phone=%@&islogin=%d&verify_code=%@", phoneNumber, isLogin, verifyTF.text];
        NSData *data = [dataStr dataUsingEncoding:NSUTF8StringEncoding];
        [request setHTTPBody:data];
        [request setHTTPMethod:@"POST"];
        MyURLConnection *connection = [[MyURLConnection alloc] MyConnectioin:request delegate:self andName:@"Login"];
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
        NSString *name = receiveJson[@"name"];
        NSString *college = receiveJson[@"college"];
        NSString *isVip = receiveJson[@"isvip"];
        NSNumber *ismessage = receiveJson[@"ismessage"];
        NSString *accessToken = receiveJson[@"access_token"];
        [userDefaults setObject:accessToken forKey:@"accessToken"];//缓存access_token
        if ([status isEqualToString:@"success"]) {
            MyAppDelegate.isLinked = YES;
            isConnect = YES;
            MyAppDelegate.isLogin = YES;
            // 将islogin写入本地缓存
            if ([isfrozen isEqualToString:@"-1"] || [isfrozen isEqualToString:@"3"]) {
                MyAppDelegate.isFreeze = true;
                MyAppDelegate.isIdentify = true;
                // 将状态写入本地缓存
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
            if (![name isEqualToString:@""]) {
                [userDefaults setObject:name forKey:@"name"];
            }
            if ([isVip isEqualToString:@"1"]) {
                [userDefaults setBool:YES forKey:@"isVip"];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"isVip" object:nil];
            }else {
                [userDefaults setBool:NO forKey:@"isVip"];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"isVip" object:nil];
            }
            if (![college isEqualToString:@""]) {
                [userDefaults setObject:college forKey:@"college"];
            }
            if ([ismessage intValue] != 0) {
                [userDefaults setBool:YES forKey:@"isMessage"];
            }
            // 优化部分
//            [userDefaults setBool:MyAppDelegate.isFreeze forKey:@"isFreeze"];
//            [userDefaults setBool:MyAppDelegate.isIdentify forKey:@"isIdentify"];
//            [userDefaults setBool:MyAppDelegate.isUpload forKey:@"isUpload"];
//            [userDefaults setBool:MyAppDelegate.isEndRiding forKey:@"isEndRiding"];
//            [userDefaults setBool:MyAppDelegate.isEndPay forKey:@"isEndPay"];
            [userDefaults setBool:true forKey:@"isLogin"];
            if (phoneNumber == nil) {
                phoneNumber = [phoneTF.text stringByReplacingOccurrencesOfString:@" " withString:@""];
            }
            [userDefaults setObject:phoneNumber forKey:@"phoneNumber"];
            // 通知个人信息页面 修改个人信息
            [[NSNotificationCenter defaultCenter] postNotificationName:@"updateInfo" object:nil];
            // 需要登陆的时候  登陆后请求服务器获取余额
            NSString *urlStr = [IP stringByAppendingString:@"/api/money/balance"];
            NSURL *url = [NSURL URLWithString:urlStr];
            NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10];
            NSString *dataStr = [NSString stringWithFormat:@"phone=%@&access_token=%@", phoneNumber, [userDefaults objectForKey:@"accessToken"]];
            NSData *data = [dataStr dataUsingEncoding:NSUTF8StringEncoding];
            [request setHTTPBody:data];
            [request setHTTPMethod:@"POST"];
            MyURLConnection *connection = [[MyURLConnection alloc] MyConnectioin:request delegate:self andName:@"balance"];
        }else {
            // 验证失败
            [cover removeFromSuperview];
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"验证失败，请重试" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alertView show];
        }
    }else if ([connection.name isEqualToString:@"balance"]) {
        NSString *status = receiveJson[@"status"];
        NSString *balance = receiveJson[@"balance"];
        if ([status isEqualToString:@"success"]) {
            NSLog(@"登陆成功，本地缓存电话：%@", [userDefaults objectForKey:@"phoneNumber"]);
            // 登陆成功
            [cover removeFromSuperview];
            // 登陆成功  进行提示
            cover = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
            cover.alpha = 1;
            // 半黑膜
            UIView *containerView = [[UIView alloc] initWithFrame:CGRectMake(0.3*SCREEN_WIDTH, 0.4*SCREEN_HEIGHT, 0.4*SCREEN_WIDTH, 0.15*SCREEN_HEIGHT)];
            containerView.backgroundColor = [UIColor blackColor];
            containerView.alpha = 0.8;
            containerView.layer.cornerRadius = CORNERRADIUS*2;
            [cover addSubview:containerView];
            // 一个控件
            //            UILabel *hintMes = [[UILabel alloc] initWithFrame:CGRectMake(0, 0.4*containerView.frame.size.height, containerView.frame.size.width, 0.2*containerView.frame.size.height)];
            //            hintMes.text = @"登陆成功";
            //            hintMes.textColor = [UIColor whiteColor];
            //            hintMes.textAlignment = NSTextAlignmentCenter;
            //            [containerView addSubview:hintMes];
            UIImageView *success = [[UIImageView alloc] initWithFrame:CGRectMake(0.3*containerView.frame.size.width, (containerView.frame.size.height-0.4*containerView.frame.size.width)/2, 0.4*containerView.frame.size.width, 0.4*containerView.frame.size.width)];
            [success setImage:[UIImage imageNamed:@"成功"]];
            success.contentMode = UIViewContentModeScaleToFill;
            [containerView addSubview:success];
            [self.view addSubview:cover];
            // 显示时间
            NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(removeViewThenToQR) userInfo:nil repeats:NO];
            [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
            
            isConnect = YES;
            MyAppDelegate.balance = balance;
            [userDefaults setObject:MyAppDelegate.balance forKey:@"balance"];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"balanceUpdate" object:nil];
        }
    }else if ([connection.name isEqualToString:@"getNumber"]) {
        NSString *status = receiveJson[@"status"];
        NSString *message = receiveJson[@"message"];
        NSLog(@"短信条数达到上限：%@", message);
        if ([status isEqualToString:@"success"]) {
            isConnect = YES;
            [cover removeFromSuperview];
            // 收到验证码  进行提示
            cover = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
            cover.alpha = 1;
            // 半黑膜
            UIView *containerView = [[UIView alloc] initWithFrame:CGRectMake(0.3*SCREEN_WIDTH, 0.4*SCREEN_HEIGHT, 0.4*SCREEN_WIDTH, 0.15*SCREEN_HEIGHT)];
            containerView.backgroundColor = [UIColor blackColor];
            containerView.alpha = 0.8;
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
            [verifyTF becomeFirstResponder];
        }else {
//            if ([message isEqualToString:@""]) {
//                // 不倒计时
//            }
            [cover removeFromSuperview];
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"您手机的当天验证次数已达上限" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alertView   show];
            [verifyButton setTitle:@"验证" forState:UIControlStateNormal];
            [countDownTime invalidate];
            verifyButton.backgroundColor = UICOLOR;
            verifyButton.enabled = YES;
        }
    }else if ([connection.name isEqualToString:@"requestForCalling"]) {
        [cover removeFromSuperview];
        NSString *status = receiveJson[@"status"];
        if ([status isEqualToString:@"success"]) {
            NSString *message = receiveJson[@"message"];
            [verifyTF becomeFirstResponder];
            // 收到验证码  进行提示
            cover = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
            cover.alpha = 1;
            // 半黑膜
            UIView *containerView = [[UIView alloc] initWithFrame:CGRectMake(0.3*SCREEN_WIDTH, 0.4*SCREEN_HEIGHT, 0.4*SCREEN_WIDTH, 0.15*SCREEN_HEIGHT)];
            containerView.backgroundColor = [UIColor blackColor];
            containerView.alpha = 0.8;
            containerView.layer.cornerRadius = CORNERRADIUS*2;
            [cover addSubview:containerView];
            // 一个控件
            UILabel *hintMes = [[UILabel alloc] initWithFrame:CGRectMake(0, 0.4*containerView.frame.size.height, containerView.frame.size.width, 0.2*containerView.frame.size.height)];
            hintMes.text = @"请求成功,请稍后";
            hintMes.textColor = [UIColor whiteColor];
            hintMes.textAlignment = NSTextAlignmentCenter;
            [containerView addSubview:hintMes];
            [self.view addSubview:cover];
            NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(removeView) userInfo:nil repeats:NO];
            [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
        }else {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"请求失败" delegate:nil cancelButtonTitle:@"知道了" otherButtonTitles:nil, nil];
            [alertView show];
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
    containerView.alpha = 0.8;
    containerView.layer.cornerRadius = CORNERRADIUS*2;
    [cover addSubview:containerView];
    // 一个控件
    UILabel *hintMes = [[UILabel alloc] initWithFrame:CGRectMake(0, 0.4*containerView.frame.size.height, containerView.frame.size.width, 0.2*containerView.frame.size.height)];
    hintMes.text = @"请检查您的网络";
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

- (void)removeViewThenToQR {
    [cover removeFromSuperview];
    if (!MyAppDelegate.isEndRiding) {
        ChargeViewController *chargeViewController = [[ChargeViewController alloc] init];
        [self.navigationController pushViewController:chargeViewController animated:YES];
    }else if (!MyAppDelegate.isEndPay) {
        // 跳到支付页面
        PayViewController *payViewController = [[PayViewController alloc] init];
        [self.navigationController pushViewController:payViewController animated:YES];
    }else {
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
}

#pragma mark - 私有方法
- (BOOL)isMobileNumber:(NSString *)mobileNum
{
    NSString *pattern = @"^1+[3578]+\\d{9}";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", pattern];
    BOOL isMatch = [pred evaluateWithObject:mobileNum];
    return isMatch;
}

- (BOOL)isVerifyNumber:(NSString *)verifyNum
{
    NSString *pattern = @"[0-9]{6}";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", pattern];
    BOOL isMatch = [pred evaluateWithObject:verifyNum];
    return isMatch;
}

- (void)requestForCalling {
    //验证 验证码是否正确。
    //验证等待动画
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
    waitActivityView.frame = CGRectMake(0.33*containerView.frame.size.width, 0.1*containerView.frame.size.width, 0.33*containerView.frame.size.width, 0.4*containerView.frame.size.height);
    [waitActivityView startAnimating];
    [containerView addSubview:waitActivityView];
    
    UILabel *hintMes = [[UILabel alloc] initWithFrame:CGRectMake(0, 0.7*containerView.frame.size.height, containerView.frame.size.width, 0.2*containerView.frame.size.height)];
    hintMes.text = @"请稍后...";
    hintMes.textColor = [UIColor whiteColor];
    hintMes.textAlignment = NSTextAlignmentCenter;
    [containerView addSubview:hintMes];
    
    [self.view addSubview:cover];
    
    NSString *urlStr = [IP stringByAppendingString:@"/api/msg/voicesms"];
    NSURL *url = [NSURL URLWithString:urlStr];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    NSString *dataStr = [NSString stringWithFormat:@"phone=%@", phoneNumber];
    NSData *data = [dataStr dataUsingEncoding:NSUTF8StringEncoding];
    [request setHTTPBody:data];
    [request setHTTPMethod:@"POST"];
    MyURLConnection *connection = [[MyURLConnection alloc] MyConnectioin:request delegate:self andName:@"requestForCalling"];
}

- (void)showTheMes {
    verifyTF.rightView.hidden = NO;
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
