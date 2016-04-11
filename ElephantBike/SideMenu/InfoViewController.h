//
//  InfoViewController.h
//  ElephantBike
//
//  Created by 黄杰锋 on 16/1/20.
//  Copyright © 2016年 黄杰锋. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol InfoViewControllerDelegate <NSObject>

- (void)getNextViewController:(id)nextViewController;
- (void)removeFromSuperView;

@end
@interface InfoViewController : UIViewController

- (instancetype)initWithFrame:(CGRect)frame;

@property (weak) id<InfoViewControllerDelegate>delegate;

@end

