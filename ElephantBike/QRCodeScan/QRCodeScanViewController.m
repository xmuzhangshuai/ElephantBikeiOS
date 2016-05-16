//
//  QRCodeScanViewController.m
//  ElephantBike
//
//  Created by 黄杰锋 on 16/1/15.
//  Copyright © 2016年 黄杰锋. All rights reserved.
//

#import "QRCodeScanViewController.h"
#import "UISize.h"
#import "AVFoundation/AVFoundation.h"
#import "IdentificationViewController.h"
#import "ChargeViewController.h"
#import "InfoViewController.h"
#import "LoginViewController.h"
#import "PayViewController.h"
#import "AppDelegate.h"
#import "IdentityViewController.h"
#import "CustomIOSAlertView.h"

#import "HJFdxdcAlertView.h"


#import "UIImageView+WebCache.h"
#import "ActivityDetailsViewController.h"

@interface QRCodeScanViewController ()<AVCaptureMetadataOutputObjectsDelegate, InfoViewControllerDelegate, NSURLConnectionDataDelegate, UIAlertViewDelegate>
@end

@implementation QRCodeScanViewController{
    AVCaptureSession            *session;//输入输出的中间桥梁
    AVCaptureDevice             *device;
    int                         line_tag;
    AppDelegate                 *myDelegate;
    UIImageView                 *upView;
    UIImageView                 *downView;
    NSString                    *bikeNO;
    UIView                      *waitCover;
    AVCaptureMetadataOutput     *output;
    //侧面菜单
    InfoViewController          *infoViewController;
    UIView                      *cover;
    UISwipeGestureRecognizer    *leftSwipGestureRecognizer;
    //活动View
    UIImageView                 *discountImageView;
    // 关闭活动页面按钮
    UIButton                    *closeAdButton;
    // 缓存
    NSUserDefaults              *userDefaults;
    
    BOOL                        isConnect;
    
    AVCaptureVideoPreviewLayer  *layer;
    
    UILabel                     *msg;
    
    UIView                      *adView;
    
    UIButton *torchButton;
}

- (id)init {
    if (self = [super init]) {
        closeAdButton = [[UIButton alloc] init];
        userDefaults = [NSUserDefaults standardUserDefaults];
    }
    return self;
}


- (void)instanceDevice{
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
    line_tag = 1872637;
    //获取摄像设备
    device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    //创建输入流
    AVCaptureDeviceInput * input = [AVCaptureDeviceInput deviceInputWithDevice:device error:nil];
    //创建输出流
    output = [[AVCaptureMetadataOutput alloc]init];
//    [output  setRectOfInterest:CGRectMake((self.view.center.y-(SCREEN_WIDTH-60)/2), 30, 200/SCREEN_HEIGHT, 200/SCREEN_WIDTH)];
    //设置代理 在主线程里刷新
    
//    NSLog(@"up%f down%f", upView.frame.size.height, downView.frame.size.height);
//    [output setRectOfInterest:CGRectMake((downView.frame.size.height)/SCREEN_HEIGHT, 30/SCREEN_WIDTH, (SCREEN_WIDTH-60)/SCREEN_HEIGHT, (SCREEN_WIDTH-60)/SCREEN_WIDTH)];

    //初始化链接对象
    session = [[AVCaptureSession alloc]init];
    //高质量采集率
    [session setSessionPreset:AVCaptureSessionPresetHigh];
    if ([session canAddInput:input]) {
        [session addInput:input];
    }
    if ([session canAddOutput:output]) {
        [session addOutput:output];
        [output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    }
    layer = [AVCaptureVideoPreviewLayer layerWithSession:session];
    
    
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if(status == AVAuthorizationStatusAuthorized) {
//        [output setMetadataObjectTypes:[NSArray arrayWithObject:AVMetadataObjectTypeQRCode]]
//        ;
        [output setMetadataObjectTypes:[NSArray arrayWithObjects:AVMetadataObjectTypeEAN13Code, AVMetadataObjectTypeEAN8Code, AVMetadataObjectTypeCode128Code, nil]];
    } else {
        NSLog(@"没有camera权限"); // 弹窗提醒
    }

    
    layer.videoGravity=AVLayerVideoGravityResizeAspectFill;
    layer.frame=self.view.layer.bounds;
    [self.view.layer insertSublayer:layer atIndex:0];
    
    [self setOverlayPickerView];
    
    [session addObserver:self forKeyPath:@"running" options:NSKeyValueObservingOptionNew context:nil];
    
    //开始捕获
    if (myDelegate.isFreeze) {
        [session stopRunning];
        msg.text = @"您的账号已经被临时冻结，工作人员将尽快核实您反映的问题并解冻您的账户";
        [layer removeFromSuperlayer];
        self.view.backgroundColor = [UIColor blackColor];
    }else {
        [session startRunning];
    }
    
    isConnect = NO;
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context{
    if ([object isKindOfClass:[AVCaptureSession class]]) {
        BOOL isRunning = ((AVCaptureSession *)object).isRunning;
        if (isRunning) {
//            [self addAnimation];
        }else{
//            [self removeAnimation];
        }
    }
}


- (void)setOverlayPickerView
{
    //左侧的view
    UIImageView *leftView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 0.1666*SCREEN_WIDTH, SCREEN_HEIGHT)];
    leftView.alpha = 0.5;
    leftView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:leftView];
    //右侧的view
    UIImageView *rightView = [[UIImageView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-0.1666*SCREEN_WIDTH, 0, 0.1666*SCREEN_WIDTH, SCREEN_HEIGHT)];
    rightView.alpha = 0.5;
    rightView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:rightView];
    
    //最上部view
    upView = [[UIImageView alloc] initWithFrame:CGRectMake(0.1666*SCREEN_WIDTH, 0, SCREEN_WIDTH-0.1666*SCREEN_WIDTH*2, 0.2353*SCREEN_HEIGHT)];
    upView.alpha = 0.5;
    upView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:upView];
    
    //底部view
    downView = [[UIImageView alloc] initWithFrame:CGRectMake(0.1666*SCREEN_WIDTH, SCREEN_HEIGHT-0.6*SCREEN_HEIGHT, SCREEN_WIDTH-0.1666*SCREEN_WIDTH*2, 0.6*SCREEN_HEIGHT)];
    downView.alpha = 0.5;
    downView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:downView];
    
    // 限定二维码扫描范围  cgrectmake(Y,X,H,W) 右下角为起点
    [output setRectOfInterest:CGRectMake((upView.frame.size.height)/SCREEN_HEIGHT, 0.1666*SCREEN_WIDTH/SCREEN_WIDTH, 0.627*SCREEN_WIDTH/SCREEN_WIDTH, 0.627*SCREEN_WIDTH/SCREEN_WIDTH)];

    
    UIImageView *centerView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 0.6933*SCREEN_WIDTH, 0.180*SCREEN_HEIGHT)];
    centerView.center = CGPointMake(0.5*SCREEN_WIDTH, 0.316*SCREEN_HEIGHT);
    centerView.image = [UIImage imageNamed:@"扫描框"];
    centerView.contentMode = UIViewContentModeScaleToFill;
    centerView.backgroundColor = [UIColor clearColor];
    centerView.clipsToBounds = YES;
    [self.view addSubview:centerView];
    
    UIImageView *line = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH-60, 2)];
    line.center = centerView.center;
    line.image = [UIImage imageNamed:@"对齐线"];
    line.contentMode = UIViewContentModeScaleAspectFill;
    line.backgroundColor = [UIColor clearColor];
    [centerView addSubview:line];
    
    msg = [[UILabel alloc] initWithFrame:CGRectMake(0.1666*SCREEN_WIDTH, CGRectGetMinY(downView.frame), SCREEN_WIDTH-0.1666*SCREEN_WIDTH*2, 80)];
    
    msg.backgroundColor = [UIColor clearColor];
    msg.textColor = [UIColor whiteColor];
    msg.textAlignment = NSTextAlignmentCenter;
    msg.numberOfLines = 2;
    msg.text = @"将大象单车上的二维码放入框内获取开锁密码";
    msg.font = [UIFont fontWithName:@"QingYuanMono" size:17];
    if (iPhone5) {
        msg.font = [UIFont fontWithName:@"QingYuanMono" size:12];
    }
    [self.view addSubview:msg];
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc]initWithString:msg.text];;
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init];
    [paragraphStyle setLineSpacing:5];
    [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, msg.text.length)];
    
    msg.attributedText = attributedString;
    //调节高度
    CGSize size = CGSizeMake(SCREEN_WIDTH-0.1666*SCREEN_WIDTH*2, 500000);
    
    CGSize labelSize = [msg sizeThatFits:size];
    
//    UIButton *buttonTemp = [[UIButton alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT-100, SCREEN_WIDTH/2, 50)];
//    buttonTemp.backgroundColor = [UIColor clearColor];
//    buttonTemp.tintColor = [UIColor whiteColor];
//    [buttonTemp setTitle:@"计费页面" forState:UIControlStateNormal];
//    [buttonTemp addTarget:self action:@selector(gotoChargeView) forControlEvents:UIControlEventTouchUpInside];
////    [self.view addSubview:buttonTemp];
//    
//    UIButton *identifyButton = [[UIButton alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT-50, SCREEN_WIDTH/2, 50)];
//    identifyButton.backgroundColor = [UIColor clearColor];
//    identifyButton.tintColor = [UIColor whiteColor];
//    [identifyButton setTitle:@"验证页面" forState:UIControlStateNormal];
//    [identifyButton addTarget:self action:@selector(gotoIdentifyView) forControlEvents:UIControlEventTouchUpInside];
////    [self.view addSubview:identifyButton];
    
    torchButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 0.208*SCREEN_WIDTH, 0.208*SCREEN_WIDTH)];
    torchButton.center = CGPointMake(0.5*SCREEN_WIDTH, 0.7*SCREEN_HEIGHT);
//    UIWindow *window = [[UIApplication sharedApplication].windows lastObject];
//    if (window.frame.size.width == 320) {
//        torchButton.frame = CGRectMake((SCREEN_WIDTH-SCREEN_WIDTH/6)/2, SCREEN_HEIGHT-150/2, SCREEN_WIDTH/6, 100/2);
//        if (window.frame.size.width == 960) {
//            torchButton.frame = CGRectMake((SCREEN_WIDTH-SCREEN_WIDTH/6)/2, SCREEN_HEIGHT-100/2, SCREEN_WIDTH/6, 100/2);
//        }
//    }
    [torchButton setImage:[UIImage imageNamed:@"闪光灯未开启状态"] forState:UIControlStateNormal];
    torchButton.contentMode = UIViewContentModeScaleAspectFit;
    [torchButton addTarget:self action:@selector(torchSwitch) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:torchButton];
    
    
    cover = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    cover.backgroundColor = [UIColor blackColor];
    cover.alpha = 0.0;
    cover.hidden = YES;
    [self.navigationController.view addSubview:cover];
    [self.navigationController.view bringSubviewToFront:cover];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hiddenCover)];
    UISwipeGestureRecognizer *rightSwipeGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(hiddenCover)];
    rightSwipeGestureRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
    [cover addGestureRecognizer:tap];
    [cover addGestureRecognizer:rightSwipeGestureRecognizer];
    
    infoViewController = [[InfoViewController alloc] initWithFrame:CGRectMake((-1)*SCREEN_WIDTH, 0, SCREEN_WIDTH*0.8666, SCREEN_HEIGHT)];
    infoViewController.delegate = self;
    [self.navigationController.view addSubview:infoViewController.view];
    
    leftSwipGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(showCover)];
    [self.view addGestureRecognizer:leftSwipGestureRecognizer];
    
    discountImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 0.4*SCREEN_HEIGHT, 0.6*SCREEN_HEIGHT)];
    discountImageView.center = self.view.center;
    discountImageView.userInteractionEnabled = YES;
    UITapGestureRecognizer *activityDetails = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(gotoDetails)];
    [discountImageView addGestureRecognizer:activityDetails];
    
    closeAdButton.frame = CGRectMake(0, 0, 0.15*SCREEN_WIDTH, 0.15*SCREEN_WIDTH);
    closeAdButton.center = CGPointMake(0.5*SCREEN_WIDTH, 0.9*SCREEN_HEIGHT);
    [closeAdButton setImage:[UIImage imageNamed:@"首页广告的关闭键"] forState:UIControlStateNormal];
    [closeAdButton addTarget:self action:@selector(none) forControlEvents:UIControlEventTouchUpInside];
    
    
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
    NSLog(@"qr.ismessage:%d", [userDefaults boolForKey:@"isMessage"]);
    if ([userDefaults boolForKey:@"isMessage"]) {
        infoButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"个人中心未读"] style:UIBarButtonItemStylePlain target:self action:@selector(information)];
    }else {
        infoButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"个人中心"] style:UIBarButtonItemStylePlain target:self action:@selector(information)];
    }
    infoButton.tintColor = [UIColor grayColor];
    self.navigationItem.leftBarButtonItem = infoButton;
    // 若没有身份认证，显示，若已经身份认证，不显示
    NSLog(@"是否身份认证：%d", myDelegate.isIdentify);
}

#pragma mark - buttonEvent
// 身份认证
- (void)gotoIdentification {
    // 关闭闪光灯
    if (myDelegate.isLinked) {
        [device lockForConfiguration:nil];
        [device setTorchMode:AVCaptureTorchModeOff];
        [device unlockForConfiguration];
        if (myDelegate.isLogin) {
            //身份认证界面改正
            IdentityViewController *idViewController = [[IdentityViewController alloc] init];
            [self.navigationController pushViewController:idViewController animated:YES];
        }else {
            LoginViewController *loginViewController = [[LoginViewController alloc] init];
            [self.navigationController pushViewController:loginViewController animated:YES];
        }
    }else {
        LoginViewController *loginViewController = [[LoginViewController alloc] init];
        [self.navigationController pushViewController:loginViewController animated:YES];
    }
}
// 手机验证
- (void)gotoIdentifyView {
    [device lockForConfiguration:nil];
    [device setTorchMode:AVCaptureTorchModeOff];
    [device unlockForConfiguration];
    LoginViewController *loginViewController = [[LoginViewController alloc] init];
    [self.navigationController pushViewController:loginViewController animated:YES];
}
// 计费页面
- (void)gotoChargeView {
    // 关闭闪光灯
    [device lockForConfiguration:nil];
    [device setTorchMode:AVCaptureTorchModeOff];
    [device unlockForConfiguration];
    ChargeViewController *chargeViewContorller = [[ChargeViewController alloc]init];
    [self.navigationController pushViewController:chargeViewContorller animated:YES];
}
// 闪光灯开关
- (void)torchSwitch {
    if (device.torchMode == AVCaptureTorchModeOff) {
        if (![device hasTorch]) {
            NSLog(@"没有闪光灯");
        }else {
            [device lockForConfiguration:nil];
            [device setTorchMode:AVCaptureTorchModeOn];
            [device unlockForConfiguration];
            [torchButton setImage:[UIImage imageNamed:@"闪光灯开启状态"] forState:UIControlStateNormal];
        }
    }else if(device.torchMode == AVCaptureTorchModeOn) {
        [device lockForConfiguration:nil];
        [device setTorchMode:AVCaptureTorchModeOff];
        [device unlockForConfiguration];
        [torchButton setImage:[UIImage imageNamed:@"闪光灯未开启状态"] forState:UIControlStateNormal];
    }
    
}

- (void)showCover {
    if (myDelegate.isLogin) {
        [self showMenu];
    }
}

- (void)hiddenCover {
    [self hiddenMenu];
}

- (void)information {
    if (myDelegate.isLinked) {
        if (myDelegate.isLogin) {
            [self showMenu];
        }else {
            [self gotoIdentifyView];
        }
    }else {
        [self gotoIdentifyView];
    }
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
    if (infoViewController.view.frame.origin.x >= 0) {
        cover.hidden = YES;
        [UIView animateWithDuration:0.4f
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
}

- (void)gotoDetails {
    [cover removeFromSuperview];
    if (![myDelegate.linkUrlShouYe isEqualToString:@""]) {
        myDelegate.ad = 1;
        ActivityDetailsViewController *activityDetailsViewController = [[ActivityDetailsViewController alloc] init];
        [self.navigationController pushViewController:activityDetailsViewController animated:YES];
    }
}

- (void)none {
    [discountImageView removeFromSuperview];
    [closeAdButton removeFromSuperview];
    [session startRunning];
    if (myDelegate.isFreeze) {
        [session stopRunning];
        [layer removeFromSuperlayer];
        msg.text = @"您的账号已经被临时冻结，工作人员将尽快核实您反映的问题并解冻您的账户";
        self.view.backgroundColor = [UIColor blackColor];
    }
}

- (void)updateMessage {
    UIBarButtonItem *infoButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"个人中心"] style:UIBarButtonItemStylePlain target:self action:@selector(information)];
    infoButton.tintColor = [UIColor grayColor];
    self.navigationItem.leftBarButtonItem = infoButton;
}



#pragma mark - AVCaptureMetadataOutputObjectsDelegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection{
    if (metadataObjects.count>0) {
        [session stopRunning];
        [device lockForConfiguration:nil];
        [device setTorchMode:AVCaptureTorchModeOff];
        [device unlockForConfiguration];
        if (!myDelegate.isLogin) {
//            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"您还没有登陆" delegate:self cancelButtonTitle:@"去登陆" otherButtonTitles:nil, nil];
//            alertView.tag = 2;
//            [alertView show];
            LoginViewController *loginViewController = [[LoginViewController alloc] init];
            [self.navigationController pushViewController:loginViewController animated:YES];
        }else if (!myDelegate.isIdentify) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"您还没有身份认证" delegate:self cancelButtonTitle:@"去认证" otherButtonTitles:nil, nil];
            alertView.tag = 3;
            [alertView show];
        }else {
            AVMetadataMachineReadableCodeObject * metadataObject = [metadataObjects objectAtIndex :0];
            bikeNO = metadataObject.stringValue;
            [userDefaults setObject:bikeNO forKey:@"bikeNo"];
            NSLog(@"bikeid:%@    缓存的bikeNO是：%@", bikeNO, [userDefaults objectForKey:@"bikeNo"]);
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
            
            UILabel *hintMes = [[UILabel alloc] initWithFrame:CGRectMake(0, 0.7*containerView.frame.size.height, containerView.frame.size.width, 0.2*containerView.frame.size.height)];
            hintMes.text = @"请稍后...";
            hintMes.textColor = [UIColor whiteColor];
            hintMes.textAlignment = NSTextAlignmentCenter;
            [containerView addSubview:hintMes];
            [self.view addSubview:waitCover];
            
            // 请求服务器 异步post
            // 获取手机号码
            
            NSString *phoneNumber = [userDefaults objectForKey:@"phoneNumber"];
            // 请求
            NSString *urlStr = [IP stringByAppendingString:@"/api/pass/unlockcode2"];
            NSURL *url = [NSURL URLWithString:urlStr];
            NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10];
            NSString *dataStr = [NSString stringWithFormat:@"bikeid=%@&phone=%@&access_token=%@", bikeNO, phoneNumber, [userDefaults objectForKey:@"accessToken"]];
            NSData *data = [dataStr dataUsingEncoding:NSUTF8StringEncoding];
            [request setHTTPBody:data];
            [request setHTTPMethod:@"POST"];
            [NSURLConnection connectionWithRequest:request delegate:self];
        }
    }
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
        containerView.alpha = 0.8;
        containerView.layer.cornerRadius = CORNERRADIUS*2;
        [waitCover addSubview:containerView];
        // 一个控件
        UILabel *hintMes = [[UILabel alloc] initWithFrame:CGRectMake(0, 0.4*containerView.frame.size.height, containerView.frame.size.width, 0.2*containerView.frame.size.height)];
        hintMes.text = @"无法连接服务器";
        hintMes.textColor = [UIColor whiteColor];
        hintMes.textAlignment = NSTextAlignmentCenter;
        [containerView addSubview:hintMes];
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

#pragma mark - 服务器返回
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    // 移除等待动画
    [waitCover removeFromSuperview];
    
    NSDictionary *receiveJson = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
    NSString *status = receiveJson[@"status"];
    NSString *password = receiveJson[@"pass"];
    NSString *message = receiveJson[@"message"];
    NSLog(@"status:%@", status);
    if ([status isEqualToString:@"success"]) {
        isConnect = YES;
        ChargeViewController *chargeViewController = [[ChargeViewController alloc] init];
        self.delegate = chargeViewController;
        [self.delegate getBikeNO:bikeNO andPassword:password];
        myDelegate.isEndRiding = NO;
        [self.navigationController pushViewController:chargeViewController animated:YES];
    }else {
        if ([message rangeOfString:@"invalid token"].location != NSNotFound) {
            // 账号在别的地方登陆
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"您的身份验证已过期，请重新登录" delegate:self cancelButtonTitle:@"好的" otherButtonTitles:nil, nil];
            alertView.tag = 10;
            [alertView show];
        }else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:message delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            alert.tag = 1;
            [alert show];
        }
    }
}

#pragma mark - 服务器超时
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
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

#pragma mark - uialertview delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if(alertView.tag == 10) {
        // 别的设备登录
        myDelegate.isIdentify = NO;
        myDelegate.isFreeze = NO;
        myDelegate.isEndPay = YES;
        myDelegate.isEndRiding = YES;
        myDelegate.isRestart = NO;
        myDelegate.isMissing = NO;
        myDelegate.isUpload = NO;
        myDelegate.isLogin = NO;
        myDelegate.isLogout = YES;
        myDelegate.isLinked = YES;
        [userDefaults setBool:NO forKey:@"isLogin"];
        [userDefaults setBool:NO forKey:@"isVip"];
        [userDefaults setObject:@"" forKey:@"name"];
        [userDefaults setObject:@"" forKey:@"stunum"];
        [userDefaults setObject:@"" forKey:@"college"];
        [userDefaults setBool:NO forKey:@"isMessage"];
        [[SDImageCache sharedImageCache] removeImageForKey:@"学生证" fromDisk:YES];
        LoginViewController *loginViewController = [[LoginViewController alloc] init];
         NSLog(@"%d", [userDefaults boolForKey:@"isLogin"]);
        [self.navigationController pushViewController:loginViewController animated:YES];
    }else {
        if (alertView.tag == 1) {
            [session startRunning];
        }
        if (alertView.tag == 3){
            IdentityViewController *identificationViewController = [[IdentityViewController alloc] init];
            [self.navigationController pushViewController:identificationViewController animated:YES];
        }
    }
    
    
}

//- (void)addAnimation{
//    UIView *line = [self.view viewWithTag:line_tag];
//    line.hidden = NO;
//    CABasicAnimation *animation = [QRCodeScanViewController moveYTime:2 fromY:[NSNumber numberWithFloat:0] toY:[NSNumber numberWithFloat:0.627*SCREEN_WIDTH/2] rep:OPEN_MAX];
//    [line.layer addAnimation:animation forKey:@"LineAnimation"];
//}
//
//+ (CABasicAnimation *)moveYTime:(float)time fromY:(NSNumber *)fromY toY:(NSNumber *)toY rep:(int)rep
//{
//    CABasicAnimation *animationMove = [CABasicAnimation animationWithKeyPath:@"transform.translation.y"];
//    [animationMove setFromValue:fromY];
//    [animationMove setToValue:toY];
//    animationMove.duration = time;
//    animationMove.delegate = self;
//    animationMove.repeatCount  = rep;
//    animationMove.fillMode = kCAFillModeForwards;
//    animationMove.removedOnCompletion = NO;
//    animationMove.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
//    return animationMove;
//}
//
//- (void)removeAnimation{
//    UIView *line = [self.view viewWithTag:line_tag];
//    [line.layer removeAnimationForKey:@"LineAnimation"];
//    line.hidden = YES;
//}

#pragma mark - InfoViewControllerDelegate
- (void)getNextViewController:(id)nextViewController {
    [self hiddenCover];
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
    UILabel *hintMes = [[UILabel alloc] initWithFrame:CGRectMake(0, 0.4*containerView.frame.size.height, containerView.frame.size.width, 0.2*containerView.frame.size.height)];
    hintMes.text = @"退出成功";
    hintMes.textColor = [UIColor whiteColor];
    hintMes.textAlignment = NSTextAlignmentCenter;
    [containerView addSubview:hintMes];
    [self.view addSubview:waitCover];
    // 显示时间
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(removeViewThenToLogin) userInfo:nil repeats:NO];
    [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
}

- (void)removeViewThenToLogin {
    self.navigationItem.leftBarButtonItem.enabled = YES;
    [waitCover removeFromSuperview];
    if (!myDelegate.isIdentify) {
        UIBarButtonItem *rightButton = [[UIBarButtonItem alloc]initWithTitle:@"身份认证" style:UIBarButtonItemStylePlain target:self action:@selector(gotoIdentification)];
        rightButton.tintColor = [UIColor whiteColor];
        self.navigationItem.rightBarButtonItem = rightButton;
        self.navigationItem.rightBarButtonItem.tintColor = [UIColor whiteColor];
    }
    if (myDelegate.isLogout) {
        LoginViewController *loginViewController = [[LoginViewController alloc] init];
        [self.navigationController pushViewController:loginViewController animated:YES];
    }
    myDelegate.isLogout = NO;
}

#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor blackColor];
    [self instanceDevice];
    myDelegate = [[UIApplication sharedApplication] delegate];
}

- (void)viewWillAppear:(BOOL)animated {
    NSLog(@"qr.ismessage:%d", [userDefaults boolForKey:@"isMessage"]);
    [super viewWillAppear:animated];
    if (myDelegate.isFreeze) {
        [session stopRunning];
        [layer removeFromSuperlayer];
        msg.text = @"您的账号已经被临时冻结，工作人员将尽快核实您反映的问题并解冻您的账户";
        msg.font = [UIFont fontWithName:@"QingYuanMono" size:13];
        if (iPhone5) {
            msg.font = [UIFont fontWithName:@"QingYuanMono" size:12];
        }
        self.view.backgroundColor = [UIColor blackColor];
    }else {
        msg.text = @"将大象单车上的二维码放入框内获取开锁密码";
//        msg.text = @"您的账号已经被临时冻结，工作人员将尽快核实您反映的问题并解冻您的账户";
        [session startRunning];
    }
    [self NavigationInit];
    if (myDelegate.isRestart) {
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
        
        UILabel *hintMes = [[UILabel alloc] initWithFrame:CGRectMake(0, 0.7*containerView.frame.size.height, containerView.frame.size.width, 0.2*containerView.frame.size.height)];
        hintMes.text = @"请稍后...";
        hintMes.textColor = [UIColor whiteColor];
        hintMes.textAlignment = NSTextAlignmentCenter;
        [containerView addSubview:hintMes];
        [self.view addSubview:waitCover];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    NSLog(@"骑行结束：%d 付款：%d", myDelegate.isEndRiding, myDelegate.isEndPay);
    if (!myDelegate.isLinked) {
        [session stopRunning];
        [waitCover removeFromSuperview];
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"您的网络忙，未能获取用户状态,建议您重新登录" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alertView show];
    }else if (myDelegate.isUserPower) {
        [waitCover removeFromSuperview];
        if (!myDelegate.isEndRiding) {
            ChargeViewController *chargeViewController = [[ChargeViewController alloc] init];
            [self.navigationController pushViewController:chargeViewController animated:YES];
        }else if (!myDelegate.isEndPay) {
            // 跳到支付页面
            PayViewController *payViewController = [[PayViewController alloc] init];
            [self.navigationController pushViewController:payViewController animated:YES];
            NSLog(@"跳转付款页面");
        }else if (myDelegate.isActivity) {
            // 有活动则无法扫描
            [session stopRunning];
            myDelegate.isActivity = NO;
            NSLog(@"显示活动页面");
            // 显示活动页面
            NSString *temp = [IP stringByAppendingString:@"/"];
            NSString *imageurl;
            imageurl = [temp stringByAppendingString:myDelegate.imageUrlShouYe];
            NSString *linkurl;
            if (![myDelegate.linkUrlShouYe isEqualToString:@""]) {
                linkurl = [temp stringByAppendingString:myDelegate.linkUrlShouYe];
            }
            adView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
            UITapGestureRecognizer *noneTap = [[UITapGestureRecognizer alloc] init];
            [noneTap addTarget:self action:@selector(none)];
            [adView addGestureRecognizer:noneTap];
            adView.alpha = 0.8;
            adView.backgroundColor = [UIColor blackColor];
            NSLog(@"%@", imageurl);
            //            UIImage *activityImage = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:@"活动页面"];
            discountImageView.contentMode = UIViewContentModeScaleToFill;
            //            if (!activityImage) {
            __block UIActivityIndicatorView *activityIndicator;
            [discountImageView sd_setImageWithURL:[NSURL URLWithString:imageurl] placeholderImage:nil options:SDWebImageProgressiveDownload progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                if (!activityIndicator)
                {
                    [discountImageView addSubview:activityIndicator = [UIActivityIndicatorView.alloc initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite]];
                    activityIndicator.center = discountImageView.center;
                    [activityIndicator startAnimating];
                }
            } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                [activityIndicator removeFromSuperview];
                activityIndicator = nil;
                //                    [[SDImageCache sharedImageCache] storeImage:image forKey:@"活动页面" toDisk:YES];
            }];
            //            }else {
            //                [discountImageView setImage:activityImage];
            //            }
            //            [adView addSubview:discountImageView];
            //            [adView addSubview:closeAdButton];
            [self.view addSubview:discountImageView];
            [self.view addSubview:closeAdButton];
            //            [self.view addSubview:adView];
        }
        if (!myDelegate.isIdentify) {
            UIBarButtonItem *rightButton = [[UIBarButtonItem alloc]initWithTitle:@"身份认证" style:UIBarButtonItemStylePlain target:self action:@selector(gotoIdentification)];
            self.navigationItem.rightBarButtonItem = rightButton;
        }else {
            self.navigationItem.rightBarButtonItem = nil;
        }
        if (myDelegate.isLogout) {
            myDelegate.isLogout = NO;
            LoginViewController *loginViewController = [[LoginViewController alloc] init];
            [self.navigationController pushViewController:loginViewController animated:YES];
        }
    }else {
        // 账号在别的地方登陆
        myDelegate.isUserPower = YES;
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"您的身份验证已过期，请重新登录" delegate:self cancelButtonTitle:@"好的" otherButtonTitles:nil, nil];
        alertView.tag = 10;
        [alertView show];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [session stopRunning];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [torchButton setImage:[UIImage imageNamed:@"闪光灯未开启状态"] forState:UIControlStateNormal];
     NSLog(@"%d", [userDefaults boolForKey:@"isLogin"]);
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
