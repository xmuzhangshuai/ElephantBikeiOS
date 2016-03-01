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

#import "AppDelegate.h"

@interface QRCodeScanViewController ()<AVCaptureMetadataOutputObjectsDelegate, InfoViewControllerDelegate, NSURLConnectionDataDelegate, UIAlertViewDelegate>
@end

@implementation QRCodeScanViewController{
    AVCaptureSession            *session;//输入输出的中间桥梁
    AVCaptureDevice             *device;
    int                         line_tag;
    UILabel                     *freezeLabel;//冻结标签
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
    // 缓存
    NSUserDefaults              *userDefaults;
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
    AVCaptureVideoPreviewLayer * layer = [AVCaptureVideoPreviewLayer layerWithSession:session];
    
    
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if(status == AVAuthorizationStatusAuthorized) {
        [output setMetadataObjectTypes:[NSArray arrayWithObject:AVMetadataObjectTypeQRCode]];
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
        [upView addSubview:freezeLabel];
        [session stopRunning];
    }else {
        [session startRunning];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context{
    if ([object isKindOfClass:[AVCaptureSession class]]) {
        BOOL isRunning = ((AVCaptureSession *)object).isRunning;
        if (isRunning) {
            [self addAnimation];
        }else{
            [self removeAnimation];
        }
    }
}


- (void)setOverlayPickerView
{
    //左侧的view
    UIImageView *leftView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 30, SCREEN_HEIGHT)];
    leftView.alpha = 0.5;
    leftView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:leftView];
    //右侧的view
    UIImageView *rightView = [[UIImageView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-30, 0, 30, SCREEN_HEIGHT)];
    rightView.alpha = 0.5;
    rightView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:rightView];
    
    //最上部view
    upView = [[UIImageView alloc] initWithFrame:CGRectMake(30, 0, SCREEN_WIDTH-60, (self.view.center.y-(SCREEN_WIDTH-60)/2))];
    upView.alpha = 0.5;
    upView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:upView];
    
    //底部view
    downView = [[UIImageView alloc] initWithFrame:CGRectMake(30, (self.view.center.y+(SCREEN_WIDTH-60)/2), (SCREEN_WIDTH-60), (SCREEN_HEIGHT-(self.view.center.y-(SCREEN_WIDTH-60)/2)))];
    downView.alpha = 0.5;
    downView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:downView];
    
    // 限定二维码扫描范围  cgrectmake(Y,X,H,W) 右下角为起点
    [output setRectOfInterest:CGRectMake((upView.frame.size.height)/SCREEN_HEIGHT, 30/SCREEN_WIDTH, (SCREEN_WIDTH-60)/SCREEN_HEIGHT, (SCREEN_WIDTH-60)/SCREEN_WIDTH)];

    
    UIImageView *centerView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH-60, SCREEN_WIDTH-60)];
    centerView.center = self.view.center;
    centerView.image = [UIImage imageNamed:@"扫描框.png"];
    centerView.contentMode = UIViewContentModeScaleAspectFit;
    centerView.backgroundColor = [UIColor clearColor];
    centerView.clipsToBounds = YES;
    [self.view addSubview:centerView];
    
    UIImageView *line = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH-60, 2)];
    line.tag = line_tag;
    line.image = [UIImage imageNamed:@"扫描线.png"];
    line.contentMode = UIViewContentModeScaleAspectFill;
    line.backgroundColor = [UIColor clearColor];
    [centerView addSubview:line];
    
    UILabel *msg = [[UILabel alloc] initWithFrame:CGRectMake(30, CGRectGetMinY(downView.frame), SCREEN_WIDTH-60, 60)];
    msg.backgroundColor = [UIColor clearColor];
    msg.textColor = [UIColor whiteColor];
    msg.textAlignment = NSTextAlignmentCenter;
    msg.font = [UIFont systemFontOfSize:16];
    msg.numberOfLines = 2;
    msg.text = @"将大象单车上得二维码放入框内获取开锁密码";
    [self.view addSubview:msg];
    
    UIButton *buttonTemp = [[UIButton alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT-100, SCREEN_WIDTH/2, 50)];
    buttonTemp.backgroundColor = [UIColor clearColor];
    buttonTemp.tintColor = [UIColor whiteColor];
    [buttonTemp setTitle:@"计费页面" forState:UIControlStateNormal];
    [buttonTemp addTarget:self action:@selector(gotoChargeView) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:buttonTemp];
    
    UIButton *identifyButton = [[UIButton alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT-50, SCREEN_WIDTH/2, 50)];
    identifyButton.backgroundColor = [UIColor clearColor];
    identifyButton.tintColor = [UIColor whiteColor];
    [identifyButton setTitle:@"验证页面" forState:UIControlStateNormal];
    [identifyButton addTarget:self action:@selector(gotoIdentifyView) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:identifyButton];
    
    UIButton *torchButton = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2, SCREEN_HEIGHT-100, SCREEN_WIDTH/2, 100)];
    UIWindow *window = [[UIApplication sharedApplication].windows lastObject];
    if (window.frame.size.width == 320) {
        torchButton.frame = CGRectMake(SCREEN_WIDTH/2, SCREEN_HEIGHT-100/2, SCREEN_WIDTH/6, 100/2);
    }
    [torchButton setImage:[UIImage imageNamed:@"闪光灯"] forState:UIControlStateNormal];
    torchButton.contentMode = UIViewContentModeScaleAspectFit;
    [torchButton addTarget:self action:@selector(torchSwitch) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:torchButton];
    
    freezeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.25*upView.frame.size.width, 0.7*upView.frame.size.height, 0.5*upView.frame.size.width, upView.frame.size.height*0.25)];
    freezeLabel.text = @"账户冻结中";
    freezeLabel.textAlignment = NSTextAlignmentCenter;
    freezeLabel.textColor = [UIColor whiteColor];
    
    cover = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    cover.backgroundColor = [UIColor blackColor];
    cover.alpha = 0.0;
    cover.hidden = YES;
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
    
    discountImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.2*SCREEN_WIDTH, 0.3*SCREEN_HEIGHT, 0.6*SCREEN_WIDTH, 0.4*SCREEN_HEIGHT)];
}

- (void)NavigationInit {
    UIImageView *titleImageView = [[UIImageView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2-30, STATUS_HEIGHT, 60, NAVIGATIONBAR_HEIGHT)];
    titleImageView.image = [UIImage imageNamed:@"大象图标"];
    titleImageView.contentMode = UIViewContentModeScaleAspectFit;
    self.navigationItem.titleView = titleImageView;
    UIBarButtonItem *infoButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"个人资料"] style:UIBarButtonItemStylePlain target:self action:@selector(information)];
    self.navigationItem.leftBarButtonItem = infoButton;
    // 若没有身份认证，显示，若已经身份认证，不显示
    if (!myDelegate.isIdentify) {
        UIBarButtonItem *rightButton = [[UIBarButtonItem alloc]initWithTitle:@"身份认证" style:UIBarButtonItemStylePlain target:self action:@selector(gotoIdentification)];
        self.navigationItem.rightBarButtonItem = rightButton;
    }
}

#pragma mark - buttonEvent
// 身份认证
- (void)gotoIdentification {
    // 关闭闪光灯
    [device lockForConfiguration:nil];
    [device setTorchMode:AVCaptureTorchModeOff];
    [device unlockForConfiguration];
    if (myDelegate.isLogin) {
        IdentificationViewController *idViewController = [[IdentificationViewController alloc]init];
        [self.navigationController pushViewController:idViewController animated:YES];
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
        }
    }else if(device.torchMode == AVCaptureTorchModeOn) {
        [device lockForConfiguration:nil];
        [device setTorchMode:AVCaptureTorchModeOff];
        [device unlockForConfiguration];
    }
    
}

- (void)hiddenCover {
    [self hiddenMenu];
    [UIView animateWithDuration:0.25 animations:^{
        cover.alpha = 0.0;
    }];
    cover.hidden = YES;
}

- (void)information {
    if (myDelegate.isLogin) {
        [self showMenu];
    }else {
        [self gotoIdentifyView];
    }
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

#pragma mark - AVCaptureMetadataOutputObjectsDelegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection{
    if (metadataObjects.count>0) {
        [session stopRunning];
        [device lockForConfiguration:nil];
        [device setTorchMode:AVCaptureTorchModeOff];
        [device unlockForConfiguration];
        if (!myDelegate.isLogin) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"您还没有登陆" delegate:self cancelButtonTitle:@"去登陆" otherButtonTitles:nil, nil];
            alertView.tag = 2;
            [alertView show];
        }else if (!myDelegate.isIdentify) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"您还没有身份认证" delegate:self cancelButtonTitle:@"去认证" otherButtonTitles:nil, nil];
            alertView.tag = 3;
            [alertView show];
        }else {
            AVMetadataMachineReadableCodeObject * metadataObject = [metadataObjects objectAtIndex :0];
            bikeNO = metadataObject.stringValue;
            [userDefaults setObject:bikeNO forKey:@"bikeNo"];
            
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
            userDefaults = [NSUserDefaults standardUserDefaults];
            NSString *phoneNumber = [userDefaults objectForKey:@"phoneNumber"];
            // 请求
            NSString *urlStr = [IP stringByAppendingString:@"/ElephantBike/api/pass/unlockcode"];
            NSURL *url = [NSURL URLWithString:urlStr];
            NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10];
            NSString *dataStr = [NSString stringWithFormat:@"bikeid=%@&phone=%@", bikeNO, phoneNumber];
            NSData *data = [dataStr dataUsingEncoding:NSUTF8StringEncoding];
            [request setHTTPBody:data];
            [request setHTTPMethod:@"POST"];
            [NSURLConnection connectionWithRequest:request delegate:self];
        }
    }
}

#pragma mark - 服务器返回
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    // 移除等待动画
    [waitCover removeFromSuperview];
    
    NSDictionary *receiveJson = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
    NSString *status = receiveJson[@"status"];
    NSString *password = receiveJson[@"pass"];
    if ([status isEqualToString:@"success"]) {
        ChargeViewController *chargeViewController = [[ChargeViewController alloc] init];
        self.delegate = chargeViewController;
        [self.delegate getBikeNO:bikeNO andPassword:password];
        [self.navigationController pushViewController:chargeViewController animated:YES];
    }else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"不存在此单车" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        alert.tag = 1;
        [alert show];
    }
}

#pragma mark - uialertview delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == 1) {
        [session startRunning];
    }else if (alertView.tag == 2) {
        LoginViewController *loginViewController = [[LoginViewController alloc] init];
        [self.navigationController pushViewController:loginViewController animated:YES];
    }else if (alertView.tag == 3){
        IdentificationViewController *identificationViewController = [[IdentificationViewController alloc] init];
        [self.navigationController pushViewController:identificationViewController animated:YES];
    }
}

- (void)addAnimation{
    UIView *line = [self.view viewWithTag:line_tag];
    line.hidden = NO;
    CABasicAnimation *animation = [QRCodeScanViewController moveYTime:2 fromY:[NSNumber numberWithFloat:0] toY:[NSNumber numberWithFloat:SCREEN_WIDTH-60-2-30] rep:OPEN_MAX];
    [line.layer addAnimation:animation forKey:@"LineAnimation"];
}

+ (CABasicAnimation *)moveYTime:(float)time fromY:(NSNumber *)fromY toY:(NSNumber *)toY rep:(int)rep
{
    CABasicAnimation *animationMove = [CABasicAnimation animationWithKeyPath:@"transform.translation.y"];
    [animationMove setFromValue:fromY];
    [animationMove setToValue:toY];
    animationMove.duration = time;
    animationMove.delegate = self;
    animationMove.repeatCount  = rep;
    animationMove.fillMode = kCAFillModeForwards;
    animationMove.removedOnCompletion = NO;
    animationMove.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    return animationMove;
}

- (void)removeAnimation{
    UIView *line = [self.view viewWithTag:line_tag];
    [line.layer removeAnimationForKey:@"LineAnimation"];
    line.hidden = YES;
}

#pragma mark - InfoViewControllerDelegate
- (void)getNextViewController:(id)nextViewController {
    [self hiddenCover];
    [self.navigationController pushViewController:nextViewController animated:YES];
}



#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    [self instanceDevice];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self NavigationInit];
    myDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if (myDelegate.isFreeze) {
        [upView addSubview:freezeLabel];
        [session stopRunning];
    }else {
        [session startRunning];
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
