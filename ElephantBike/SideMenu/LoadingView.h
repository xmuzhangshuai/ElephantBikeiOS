//
//  LoadingView.h
//  ElephantBike
//
//  Created by 黄杰锋 on 16/2/23.
//  Copyright © 2016年 黄杰锋. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoadingView : UIView

- (void)setRefreshStateNormal;

- (void)setRefreshStateLoading;

- (void)setRefreshStateLoose;

- (void)setRefreshStateNone;

@end
