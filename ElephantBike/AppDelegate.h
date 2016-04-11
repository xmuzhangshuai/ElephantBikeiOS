//
//  AppDelegate.h
//  ElephantBike
//
//  Created by 黄杰锋 on 16/1/12.
//  Copyright © 2016年 黄杰锋. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "InfoViewController.h"

@protocol PayDelegate <NSObject>

@optional

- (void)isWXPay;
- (void)isAliPay;

@end

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic) BOOL  isLogin;    // 是否登陆
@property (nonatomic) BOOL  isIdentify;  // 是否身份认证
@property (nonatomic) BOOL  isFreeze;   // 是否冻结
@property (nonatomic) BOOL  isEndRiding;   // 是否结束骑行
@property (nonatomic) BOOL  isEndPay;   // 是否结束付费
@property (nonatomic) BOOL  isRestart;   // 是否是重启app后骑行未结束或未付款
@property (nonatomic) BOOL  isMissing;  // 是否丢失车辆
@property (nonatomic) BOOL  isUpload;   // 是否上传了照片
@property (nonatomic) BOOL  isLogout;   // 判断是否退出
@property (nonatomic) BOOL  isLinked;   // 判断是否读取到用户的数据
@property (nonatomic) BOOL  isMoneyView;    // 判断是否是支付或者充值页面
@property (nonatomic, strong) NSString *balance;    // 余额
@property (nonatomic) BOOL  isActivity; // 是否有活动
@property (nonatomic, strong) NSString *imageUrlShouYe;   // 图片链接
@property (nonatomic, strong) NSString *linkUrlShouYe;    // 内容链接
@property (nonatomic, strong) NSString *imageUrlInfo;   // 个人信息广告图片链接
@property (nonatomic, strong) NSString *linkUrlInfo;    //  个人信息广告内容链接
@property (nonatomic, strong) NSString *imageUrlCharge; // 计费页面广告图片链接
@property (nonatomic, strong) NSString *linkUrlCharge;  // 计费页面广告内容链接
@property (nonatomic, strong) NSString *deadLineDate;   // 会员到期日期
@property (nonatomic) BOOL  isWXPay;                    // 判断是微信还是支付宝

@property (nonatomic, weak) id<PayDelegate> myDelegate; // 代理

@end

