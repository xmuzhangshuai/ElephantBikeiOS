//
//  AppDelegate.m
//  ElephantBike
//
//  Created by 黄杰锋 on 16/1/12.
//  Copyright © 2016年 黄杰锋. All rights reserved.
//

#import "AppDelegate.h"
#import "LoginViewController.h"
#import "InfoViewController.h"
#import "UISize.h"
#import "QRCodeScanViewController.h"
#import "MyURLConnection.h"
#import "ChargeViewController.h"
#import "PayViewController.h"

#pragma mark - 百度模块
#import <BaiduMapAPI_Base/BMKBaseComponent.h>

#pragma mark - 微信支付
#import "WXApi.h"

#pragma mark - 支付宝
#import <AlipaySDK/AlipaySDK.h>

@interface AppDelegate () <WXApiDelegate>

@property (nonatomic, strong) UINavigationController    *navigationgController;
@property (nonatomic, strong) QRCodeScanViewController  *qRCodeScanViewController;
@property (nonatomic, strong) PayViewController         *payViewController;
@end

@implementation AppDelegate {
    BMKMapManager   *_mapManager;
    NSUserDefaults  *userDefaults;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    // 微信支付 初始化
    [WXApi registerApp:@"wx4a480f3f5a6c4c6c" withDescription:@"ElephantBike1.0"];

//    初始状态
    self.isIdentify = NO;
    self.isFreeze = NO;
    self.isEndPay = YES;
    self.isEndRiding = YES;
    self.isRestart = NO;
    self.isMissing = NO;
    self.isUpload = NO;
    self.isActivity = NO;
    self.isLogout = NO;
    self.isLinked = YES;
    self.isMoneyView = NO;

    
    self.balance = @"";
    userDefaults = [NSUserDefaults standardUserDefaults];
    if (![userDefaults boolForKey:@"everLaunched"]) {
        [userDefaults setBool:NO forKey:@"isLogin"];
        [userDefaults setBool:YES forKey:@"everLaunched"];
        [userDefaults setBool:NO forKey:@"isVip"];
        [userDefaults setObject:@"" forKey:@"name"];
        [userDefaults setObject:@"" forKey:@"college"];
    }
    self.isLogin = [userDefaults boolForKey:@"isLogin"];
    NSLog(@"%d", self.isLogin);
    if (self.isLogin) {
        
//        self.balance = [userDefaults objectForKey:@"balance"];
//        self.isFreeze = [userDefaults boolForKey:@"isFreeze"];
//        self.isIdentify = [userDefaults boolForKey:@"isIdentify"];
//        self.isUpload = [userDefaults boolForKey:@"isUpload"];
//        self.isEndRiding = [userDefaults boolForKey:@"isEndRiding"];
//        self.isEndPay = [userDefaults boolForKey:@"isEndPay"];
//        if (self.isEndRiding == 0) {
//            self.isRestart = YES;
//        }
//        if (self.isEndPay == 0) {
//            self.isRestart = YES;
//        }
        
        // balance 部分
//        self.balance = [userDefaults objectForKey:@"balance"];
        
        // 已经登录
        
        // 可以设置一个变量，没有获取到该账户的数据就在qrcodeview页面提示，并且无法使用软件扫描。
        
        NSString *phoneNumber = [userDefaults objectForKey:@"phoneNumber"];
        // 在登录了的情况下 去服务器获取余额
        // 只能用同步post 不然的话余额获取会有问题
        NSString *urlStr = [IP stringByAppendingString:@"/ElephantBike/api/money/balance"];
        NSURL *url = [NSURL URLWithString:urlStr];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10];
        NSString *dataStr = [NSString stringWithFormat:@"phone=%@", phoneNumber];
        NSData *data = [dataStr dataUsingEncoding:NSUTF8StringEncoding];
        [request setHTTPBody:data];
        [request setHTTPMethod:@"POST"];
//        MyURLConnection *connection = [[MyURLConnection alloc] MyConnectioin:request delegate:self andName:@"balance"];
        NSError *error = nil;
        NSData *receiveData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:&error];
        if (receiveData == nil) {
            NSLog(@"send request failed:%@", error);
            self.isLinked = NO;
        }else {
            NSDictionary *receive = [NSJSONSerialization JSONObjectWithData:receiveData options:NSJSONReadingMutableLeaves error:nil];
            NSString *status = receive[@"status"];
            NSString *receiveBalance = receive[@"balance"];
            if ([status isEqualToString:@"success"]) {
                CGFloat tempBalance = [receiveBalance floatValue];
                self.balance = [NSString stringWithFormat:@"%.2f", tempBalance];
                //拿取本地缓存数据 只需手机和isLogin，和短信验证用的是一个api，不需要验证码
                NSString *phoneNumber = [userDefaults objectForKey:@"phoneNumber"];
                NSString *urlStr = [IP stringByAppendingString:@"/ElephantBike/api/user/login"];
                NSURL *url = [NSURL URLWithString:urlStr];
                NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
                NSString *dataStr = [NSString stringWithFormat:@"phone=%@&islogin=%d", phoneNumber, self.isLogin];
                NSData *data = [dataStr dataUsingEncoding:NSUTF8StringEncoding];
                [request setHTTPBody:data];
                [request setHTTPMethod:@"POST"];
                NSData *receiveData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
                if (receiveData == nil) {
                    NSLog(@"send request failed:");
                    self.isLinked = NO;
                }else {
                    NSDictionary *receive = [NSJSONSerialization JSONObjectWithData:receiveData options:NSJSONReadingMutableLeaves error:nil];
                    NSString *status = receive[@"status"];
                    NSString *isFrozen = receive[@"isfrozen"];
                    NSString *isFinish = receive[@"isfinish"];
                    NSString *isPay = receive[@"ispay"];
                    NSString *name = receive[@"name"];
                    NSString *college = receive[@"college"];
                    NSLog(@"isfrozen:%@", isFrozen);
                    if ([status isEqualToString:@"success"]) {
                        if ([isFrozen isEqualToString:@"-1"]) {
                            self.isFreeze = true;
                            self.isIdentify = true;
                        }else if([isFrozen isEqualToString:@"0"]) {
                            self.isFreeze = false;
                            self.isIdentify = false;
                        }else if([isFrozen isEqualToString:@"1"]) {
                            self.isFreeze = false;
                            self.isIdentify = true;
                            NSLog(@"已经身份认证%d", self.isIdentify);
                        }else {
                            self.isUpload = YES;
                            NSLog(@"isupload:yes");
                        }
                        if ([isFinish isEqualToString:@"1"]) {
                            self.isEndRiding = false;
                            self.isRestart = YES;
                        }
                        if ([isPay isEqualToString:@"1"]) {
                            self.isEndPay = false;
                            self.isRestart = YES;
                        }
                        [userDefaults setObject:name forKey:@"name"];
                        [userDefaults setObject:college forKey:@"college"];
                        NSLog(@"骑行结束：%d 付款：%d 重启：%d", self.isEndRiding, self.isEndPay, self.isRestart);
                    }
                    // 设置相应页面的跳转，正常情况 跳转扫描页面，其他分三种情况
                    // 该判断放到qrcontroller
                }
            }
        }
    }
        NSLog(@"请求活动");
    // 请求服务器
    // 判断是否有活动
    NSString *urlStr = [IP stringByAppendingString:@"/ElephantBike/api/act/topic"];
    NSURL *url = [NSURL URLWithString:urlStr];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    NSString *dataStr = [NSString stringWithFormat:@"type=%d", 1];
    NSData *data = [dataStr dataUsingEncoding:NSUTF8StringEncoding];
    [request setHTTPBody:data];
    [request setHTTPMethod:@"POST"];
    NSData *receiveData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    if (receiveData == nil) {
        NSLog(@"send request failed:");
//        self.isLinked = NO;
    }else {
        NSDictionary *receive = [NSJSONSerialization JSONObjectWithData:receiveData options:NSJSONReadingMutableLeaves error:nil];
        NSString *status = receive[@"status"];
        NSString *imageurl = receive[@"imageurl"];
        NSString *linkurl = receive[@"linkurl"];
        NSLog(@"status:%@", status);
        if ([status isEqualToString:@"success"]) {
            self.imageUrlShouYe = imageurl;
            self.linkUrlShouYe = linkurl;
            self.isActivity = YES;
        }
        NSLog(@"url:%@%@ activity:%d", self.imageUrlShouYe, self.linkUrlShouYe, self.isActivity);
    }

    // 百度模块
    _mapManager = [[BMKMapManager alloc] init];
    BOOL ret = [_mapManager start:@"jR2M4PEO3DL9TRFHIGQgi81p" generalDelegate:nil];
    if (!ret) {
        NSLog(@"无法定位");
    }
    _payViewController = [[PayViewController alloc] init];
    _qRCodeScanViewController = [[QRCodeScanViewController alloc] init];
    
    _navigationgController = [[UINavigationController alloc] initWithRootViewController:_qRCodeScanViewController];
    
    _window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    [_window setRootViewController:_navigationgController];
    _window.backgroundColor = [UIColor whiteColor];
    [_window makeKeyAndVisible];
    
    return YES;
}

#pragma mark - 微信支付代理设置
- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    return  [WXApi handleOpenURL:url delegate:self];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    if (!self.isWXPay) {
        if ([url.host isEqualToString:@"safepay"]) {
            //跳转支付宝钱包进行支付，处理支付结果
            [[AlipaySDK defaultService] processOrderWithPaymentResult:url standbyCallback:^(NSDictionary *resultDic) {
                NSLog(@"result = %@",resultDic);
            }];
        }
        return YES;
    }
    return  [WXApi handleOpenURL:url delegate:self];
}
// iOS9最新能用的 上面两个iOS9已经废弃
- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary*)options {
    return  [WXApi handleOpenURL:url delegate:self];
}
/*
- (void)onResp:(BaseResp *)resp {
    if ([resp isKindOfClass:[PayResp class]]) {
        PayResp *response = (PayResp *)resp;
        switch (response.errCode) {
            case WXSuccess:{
                NSLog(@"支付成功");
                [[NSNotificationCenter defaultCenter] postNotificationName:@"paySuccess" object:nil];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"rechargeSuccess" object:nil];
            }
                break;
            default: {
                NSLog(@"failed %d", response.errCode);
                NSLog(@"付款失败");
                [[NSNotificationCenter defaultCenter] postNotificationName:@"payFail" object:nil];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"rechargeFail" object:nil];
            }
                break;
        }
    }
}*/

#pragma mark - 支付宝代理
//- (BOOL)application:(UIApplication *)application
//            openURL:(NSURL *)url
//  sourceApplication:(NSString *)sourceApplication
//         annotation:(id)annotation {
//    
//    
//}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    
    // 调用一个代理方法，让支付页面去请求服务器看有没有支付成功
    if (self.isMoneyView) {
        NSLog(@"进入前台");
        if (self.isWXPay) {
            [self.myDelegate isWXPay];
        }else {
            [self.myDelegate isAliPay];
        }
    }
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
