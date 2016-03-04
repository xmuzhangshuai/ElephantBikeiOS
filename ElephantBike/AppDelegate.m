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

@interface AppDelegate () <MyURLConnectionDelegate>

@property (nonatomic, strong) UINavigationController    *navigationgController;
@property (nonatomic, strong) QRCodeScanViewController  *qRCodeScanViewController;
@end

@implementation AppDelegate {
    BMKMapManager   *_mapManager;
    NSUserDefaults  *userDefaults;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
//    初始状态
    self.isIdentify = NO;
    self.isFreeze = NO;
    self.isEndPay = YES;
    self.isEndRiding = YES;
    self.isRestart = NO;
    self.isMissing = NO;
    self.isUpload = NO;

    
    self.balance = @"";
    userDefaults = [NSUserDefaults standardUserDefaults];
    if (![userDefaults boolForKey:@"everLaunched"]) {
        [userDefaults setBool:NO forKey:@"isLogin"];
        [userDefaults setBool:YES forKey:@"everLaunched"];
    }
    self.isLogin = [userDefaults boolForKey:@"isLogin"];
    self.isRestart = NO;
    NSLog(@"%d", self.isLogin);
    if (self.isLogin) {
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
        NSData *receiveData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
        if (receiveData == nil) {
            NSLog(@"send request failed:");
        }else {
            NSDictionary *receive = [NSJSONSerialization JSONObjectWithData:receiveData options:NSJSONReadingMutableLeaves error:nil];
            NSString *status = receive[@"status"];
            NSString *receiveBalance = receive[@"balance"];
            if (status) {
                self.balance = receiveBalance;
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
                }else {
                    NSDictionary *receive = [NSJSONSerialization JSONObjectWithData:receiveData options:NSJSONReadingMutableLeaves error:nil];
                    NSString *status = receive[@"status"];
                    NSString *isFrozen = receive[@"isfrozen"];
                    NSString *isFinish = receive[@"isfinish"];
                    NSString *isPay = receive[@"ispay"];
                    if ([status isEqualToString:@"success"]) {
                        if ([isFrozen isEqualToString:@"-1"]) {
                            self.isFreeze = true;
                            self.isIdentify = true;
                        }else if([isFrozen isEqualToString:@"0"]) {
                            self.isFreeze = false;
                            self.isIdentify = false;
                        }else if([isFrozen isEqualToString:@"1"]) {
                            self.isFreeze = false;
                            self.isIdentify = YES;
                            NSLog(@"已经身份认证%d", self.isIdentify);
                        }else {
                            self.isUpload = YES;
                        }
                        if ([isFinish isEqualToString:@"1"]) {
                            self.isEndRiding = false;
                            self.isRestart = YES;
                        }
                        if ([isPay isEqualToString:@"1"]) {
                            self.isEndPay = false;
                            self.isRestart = YES;
                        }
                        NSLog(@"骑行结束：%d 付款：%d 重启：%d", self.isEndRiding, self.isEndPay, self.isRestart);
                    }
                    // 设置相应页面的跳转，正常情况 跳转扫描页面，其他分三种情况
                    // 该判断放到qrcontroller
                }
            }
        }
    }
    
    // 请求服务器
    


    
    // 百度模块
    _mapManager = [[BMKMapManager alloc] init];
    BOOL ret = [_mapManager start:@"jR2M4PEO3DL9TRFHIGQgi81p" generalDelegate:nil];
    if (!ret) {
        NSLog(@"无法定位");
    }
    
    _qRCodeScanViewController = [[QRCodeScanViewController alloc] init];
    
    _navigationgController = [[UINavigationController alloc] initWithRootViewController:_qRCodeScanViewController];
    
    _window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    [_window setRootViewController:_navigationgController];
    _window.backgroundColor = [UIColor whiteColor];
    [_window makeKeyAndVisible];
    
    [NSThread sleepForTimeInterval:2];
    
    return YES;
}

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
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
