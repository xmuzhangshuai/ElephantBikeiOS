//
//  AppDelegate.h
//  ElephantBike
//
//  Created by 黄杰锋 on 16/1/12.
//  Copyright © 2016年 黄杰锋. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "InfoViewController.h"

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
@property (nonatomic, strong) NSString *balance;    // 余额
@property (nonatomic) BOOL  isActivity; // 是否有活动
@property (nonatomic, strong) NSString *imageUrl;   // 图片链接
@property (nonatomic, strong) NSString *linkUrl;    // 内容链接

@end

