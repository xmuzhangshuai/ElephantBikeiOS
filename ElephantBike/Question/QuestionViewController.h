//
//  QuestionViewController.h
//  ElephantBike
//
//  Created by 黄杰锋 on 16/1/19.
//  Copyright © 2016年 黄杰锋. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol QuestionViewControllerDelegate <NSObject>

@optional
- (void)Freezed;
- (void)getMoney:(NSString *)money andTime:(NSString *)time andIsLose:(BOOL)isLose;

@end

@interface QuestionViewController : UIViewController
@property (weak, nonatomic) id<QuestionViewControllerDelegate>delegate;
@end
