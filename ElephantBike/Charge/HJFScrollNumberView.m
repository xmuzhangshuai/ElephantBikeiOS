//
//  HJFScrollNumberView.m
//  ElephantBike
//
//  Created by 黄杰锋 on 16/2/16.
//  Copyright © 2016年 黄杰锋. All rights reserved.
//

#import "HJFScrollNumberView.h"

@implementation HJFScrollDigitView

- (void)setDigitAndCommit:(NSUInteger)Digit {
    self.numberLabel.text = [NSString stringWithFormat:@"%d", (int)Digit];
    CGRect rect = self.numberLabel.frame;
    rect.origin.y = 0;
    rect.size.height = _oneDigitHeight;
    self.numberLabel.numberOfLines = 1;
    self.numberLabel.frame = rect;
    self.digit = Digit;
}

- (void)setDigit:(NSUInteger)digit fromLast:(NSUInteger)last {
    if (digit == last) {
        [self setDigitAndCommit:digit];
        return;
    }
    NSMutableString *str = [NSMutableString stringWithFormat:@"%d", (int)last];
    int count = 1;
    if (digit > last) {
        for (int i = (int)last + 1; i < digit + 1; ++i) {
            ++count;
            [str appendFormat:@"\n%d", i];
        }
    } else {
        for (int i = (int)last + 1; i < 10; ++i) {
            ++count;
            [str appendFormat:@"\n%d", i];
        }
        for (int i = 0; i < digit + 1; ++i) {
            ++count;
            [str appendFormat:@"\n%d", i];
        }
    }
    self.numberLabel.text = str;
    self.numberLabel.numberOfLines = count;
    CGRect rect = self.numberLabel.frame;
    rect.origin.y = 0;
    rect.size.height = _oneDigitHeight * count;
    self.numberLabel.frame = rect;
    self.digit = digit;
}

- (void)commitChange {
    CGRect rect = self.numberLabel.frame;
    rect.origin.y = _oneDigitHeight - rect.size.height;
    self.numberLabel.frame = rect;
}

- (void)didConfigFinish{
    CGSize size = [@"4" sizeWithAttributes:@{NSFontAttributeName:self.digitFont}];
    _oneDigitHeight = size.height;
    
    CGRect rect = {{(self.frame.size.width - size.width) / 2, 0}, size};
    
    UIView *view = [[UIView alloc] initWithFrame:rect];
    view.backgroundColor = [UIColor clearColor];
    view.clipsToBounds = YES;
    rect.origin.x = 0;
    rect.origin.y = 0;
    self.numberLabel = [[UILabel alloc] initWithFrame:rect];
    self.numberLabel.font = self.digitFont;
    self.numberLabel.backgroundColor = [UIColor clearColor];
    [view addSubview:self.numberLabel];
    [self addSubview:view];
    [self setDigitAndCommit:self.digit];
}

@end

@implementation HJFScrollNumberView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initScrollNumView];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self initScrollNumView];
    }
    return self;
}

- (void)initScrollNumView {
    self.numberSize = 4;
    self.numberValue = 0;
    self.splitSpaceWidth = 2.0;
    self.digitFont = [UIFont systemFontOfSize:15];
}

- (void)setNumber:(NSUInteger)number withAnimationType:(HJFScrollNumAnimationType)type animationTime:(NSTimeInterval)time {
    for (int i = 0; i < self.numberSize; ++i) {
        HJFScrollDigitView *digitView = [_numberViews objectAtIndex:i];
        NSUInteger digit = [HJFScrollNumberView digitFromNumber:number withIndex:i];
        if (digit != [self digitIndex:i]) {
            switch (type) {
                case HJFScrollNumberAnimationTypeRand:
                [digitView setDigit:digit fromLast:digitView.digit];
                    break;
                default:
                    break;
            }
        }
    }
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:time];
    for (HJFScrollDigitView *digitView in _numberViews) {
        [digitView commitChange];
    }
    [UIView commitAnimations];
    self.numberValue = number;
}

+ (NSUInteger)digitFromNumber:(NSUInteger)number withIndex:(NSUInteger)index {
    NSUInteger num = number;
    for (int i = 0; i <index; ++i) {
        num /= 10;
    }
    return num%10;
}

- (NSUInteger)digitIndex:(NSUInteger)index {
    return [HJFScrollNumberView digitFromNumber:self.numberValue withIndex:index];
}

- (void)didConfigFinish {
    _numberViews = [[NSMutableArray alloc] initWithCapacity:self.numberSize];
    CGFloat allWidth = self.frame.size.width;
    CGFloat digitWidth = (allWidth - (self.numberSize + 1)*self.splitSpaceWidth)/self.numberSize;
    for (int i = 0; i < self.numberSize; ++i) {
        CGRect rect = {{allWidth - (digitWidth + self.splitSpaceWidth) * (i + 1), 0}, {(digitWidth, self.frame.size.height)}};
    
        HJFScrollDigitView *digitView = [[HJFScrollDigitView alloc] initWithFrame:rect];
        digitView.digitFont = self.digitFont;
        [digitView didConfigFinish];
        [digitView setDigitAndCommit:[self digitIndex:i]];
        if (self.digitColor != nil) {
            digitView.numberLabel.textColor = self.digitColor;
        }
        [_numberViews addObject:digitView];
        [self addSubview:digitView];
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
