//
//  WXPayView.m
//  WXPayView
//
//  Created by apple on 16/1/6.
//  Copyright © 2016年 apple. All rights reserved.
//  微信红包支付界面模拟


#import "ModalPayView.h"
#import "InputPasswordView.h"

@interface ModalPayView()

@property (weak, nonatomic) IBOutlet InputPasswordView *inputView; // 密码输入框
@property (weak, nonatomic) IBOutlet UIView *lineView;
@property (weak, nonatomic) IBOutlet UILabel *titleName;

@property (weak, nonatomic) IBOutlet UILabel *hintMes;
@property (nonatomic,copy) WXPayViewCompletion completion;

@property (nonatomic,strong) UIView *cover;

@end

@implementation ModalPayView

- (instancetype)initWithTitle:(NSString *)titleName andHintMes:(NSString *)hintMes andCompletion:(WXPayViewCompletion)completion{

    self = [[[NSBundle mainBundle] loadNibNamed:@"ModalPayView" owner:nil options:nil] lastObject];

    if (self == nil) {
        return nil;
    }
    
    _completion = completion;
    _titleName.text = titleName;
    _hintMes.text = hintMes;
    
    [self setupContents];

    return self;
}

- (void)awakeFromNib{
    self.layer.cornerRadius = 10;

   // 默认6位
    self.inputView.places = 6;
}

- (void)setupContents{
    self.hintMes.numberOfLines = 0;
    self.hintMes.font = [UIFont systemFontOfSize:12];
    
    self.lineView.layer.borderWidth = 2;
    
    __weak typeof(self) weakSelf = self;
    self.inputView.WXInputViewDidCompletion = ^(NSString *text){
        if (weakSelf.completion) {
            weakSelf.completion(text);
        }
    };
}

- (void)setPlaces:(NSInteger)places{
    _places = places;
    self.inputView.places = places;
}

- (IBAction)exitButtonClicked {
    if (self.exitBtnClicked) {
        self.exitBtnClicked();
    }
}


- (void)show{
    
    UIWindow *window = [[UIApplication sharedApplication].windows lastObject];
    
//    [window addSubview:self.cover];
//    [window addSubview:self];
    
    self.transform = CGAffineTransformMakeScale(0.6, 0.6);
    self.alpha = 0;
    [UIView animateWithDuration:0.25 animations:^{
        self.transform = CGAffineTransformIdentity;
        self.cover.alpha = 1;
        self.alpha = 1;
    }];
    self.center = CGPointMake(window.center.x, (window.frame.size.height - 216) * 0.5);
    
    // 适配小屏幕
    if (window.frame.size.width == 320) {
        self.bounds = CGRectMake(0, 0, self.bounds.size.width * 0.9, self.bounds.size.height);
    }
    
    // 弹出键盘
    [self.inputView beginInput];
}

- (void)hidden{
    
    [UIView animateWithDuration:0.25 animations:^{
        self.transform = CGAffineTransformMakeScale(0.6, 0.6);
        self.alpha = 0;
        self.cover.alpha = 0;
    }completion:^(BOOL finished) {
        [self removeFromSuperview];
//        [self.cover removeFromSuperview];
    }];
    
    // 退下键盘
    [self.inputView endInput];
}

- (UIView *)cover{
    if (_cover == nil) {
        UIWindow *window = [[UIApplication sharedApplication].windows lastObject];
        _cover = [[UIView alloc] initWithFrame:window.bounds];
        CGFloat rgb = 83 / 255.0;
        _cover.backgroundColor = [UIColor colorWithRed:rgb green:rgb blue:rgb alpha:0.7];
        _cover.alpha = 0;
    }
    return _cover;
}


@end
