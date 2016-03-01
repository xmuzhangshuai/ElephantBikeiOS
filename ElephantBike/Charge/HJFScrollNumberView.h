//
//  HJFScrollNumberView.h
//  ElephantBike
//
//  Created by 黄杰锋 on 16/2/16.
//  Copyright © 2016年 黄杰锋. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    HJFScrollNumberAnimationTypeNone,
    HJFScrollNumberAnimationTypeNormal,
    HJFScrollNumberAnimationTypeFromLast,
    HJFScrollNumberAnimationTypeRand,
    HJFScrollNumberAnimationTypeFast
} HJFScrollNumAnimationType;

@interface HJFScrollDigitView : UIView {
    CGFloat _oneDigitHeight;
}

@property (strong, nonatomic) UILabel   *numberLabel;
@property (strong, nonatomic) UIFont    *digitFont;
@property (nonatomic) NSUInteger        digit;

- (void)setDigitAndCommit:(NSUInteger)Digit;
- (void)setDigit:(NSUInteger)digit fromLast:(NSUInteger)last;
- (void)commitChange;
- (void)didConfigFinish;

@end

@interface HJFScrollNumberView : UIView {
    NSMutableArray *_numberViews;
}

@property (nonatomic) NSUInteger    numberSize;     //数字个数
@property (nonatomic) CGFloat       splitSpaceWidth;    //数字之间的空隙
@property (nonatomic) NSUInteger    numberValue;    //数字
@property (nonatomic, strong) UIFont    *digitFont;
@property (nonatomic, strong) NSArray   *numberViews;
@property (nonatomic, strong) UIColor   *digitColor;

- (void)setNumber:(NSUInteger)number withAnimationType:(HJFScrollNumAnimationType)type animationTime:(NSTimeInterval)time;
- (void)didConfigFinish;

@end
