//
//  HJFdxdcAlertView.h
//  ElephantBike
//
//  Created by Hjf on 16/4/15.
//  Copyright © 2016年 黄杰锋. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol HJFALertviewDelegate<NSObject>
@optional
-(void)didClickButtonAtIndex:(NSUInteger)index;

@end

@interface HJFdxdcAlertView : UIView
@property (weak,nonatomic) id<HJFALertviewDelegate> delegate;
-(instancetype)initWithContent:(NSString *) content Image:(UIImage *)image CancelButton:(NSString *)cancelButton OkButton:(NSString *)okButton;
- (void)show;
@end
