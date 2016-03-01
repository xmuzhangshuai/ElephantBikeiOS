//
//  QRCodeScanViewController.h
//  ElephantBike
//
//  Created by 黄杰锋 on 16/1/15.
//  Copyright © 2016年 黄杰锋. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol QRCodeScanViewControllerDelegate <NSObject>

- (void)getBikeNO:(NSString *)bikeNO andPassword:(NSString *)password;

@end

@interface QRCodeScanViewController : UIViewController
@property (weak, nonatomic)id<QRCodeScanViewControllerDelegate> delegate;

@end
