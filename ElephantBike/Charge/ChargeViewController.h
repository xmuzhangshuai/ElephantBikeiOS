//
//  ChargeViewController.h
//  ElephantBike
//
//  Created by 黄杰锋 on 16/1/15.
//  Copyright © 2016年 黄杰锋. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UISize.h"

@protocol ChargeViewControllerDelegate <NSObject>

- (void)getMoney:(NSString *)money andTime:(NSString *)time;

@end

@interface ChargeViewController : UIViewController

@property (nonatomic, weak) id<ChargeViewControllerDelegate> delegate;

@end
