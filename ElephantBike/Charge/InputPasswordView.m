//
//  InputView.m
//  WXPayView
//
//  Created by apple on 16/1/6.
//  Copyright © 2016年 apple. All rights reserved.
//  密码输入框视图

#import "InputPasswordView.h"

// 中心符号圆点的大小
CGFloat const kWXInputViewSymbolWH = 8;

@interface InputPasswordView()

// 装着所有格子中间的那个占位圆点
@property (nonatomic,strong) NSMutableArray *symbolArr;

@property (nonatomic,strong) UITextField *textField;



@end

@implementation InputPasswordView

#pragma mark - 视图创建方法

// 代码创建输入框视图
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self == nil){
        return nil;
    }
    
    [self addNotification];
    
    return self;
}

// xib加载输入框视图
- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self == nil) {
        return nil;
    }
    
    [self addNotification];
    
    return self;
}

- (void)addNotification{
    // 回调键盘输入内容变化的通知
    [[NSNotificationCenter defaultCenter] addObserverForName:UITextFieldTextDidChangeNotification object:nil queue:nil usingBlock:^(NSNotification * note) {
        
        NSUInteger length = _textField.text.length;
        
        // 若正好输完，将text传给回调函数去判断 然后置为空
        if (length == self.places && self.WXInputViewDidCompletion) {
            self.WXInputViewDidCompletion(_textField.text);
            [_textField setText:@""];
        }
        
        if (length > self.places) {
            _textField.text = [_textField.text substringToIndex:self.places];
        }
        
        [_symbolArr enumerateObjectsUsingBlock:^(CAShapeLayer *symbol, NSUInteger idx, BOOL * stop) {
            
            symbol.hidden = idx < length ? NO : YES;
            
            NSString *password = _textField.text;
            if (password.length > self.places) {
                return;
            }
            
            for (int i = 0; i < self.symbolArr.count; i++)
            {
                UITextField *pwdTextField= [self.symbolArr objectAtIndex:i];
                
                for (int i = 0; i < self.symbolArr.count; i++) {
                    UITextField *pwdtextfield = [self.symbolArr objectAtIndex:i];
                    pwdtextfield.hidden = NO;
                }
                if (i < password.length) {
                    NSString *pwd = [password substringWithRange:NSMakeRange(i, 1)];
                    
                    pwdTextField.text = pwd;
                } else {
                    pwdTextField.text = nil;
                }
            }

        }];
    }];
}

- (void)setPlaces:(NSInteger)places{
    _places = places;
    for (int i = 0; i < places; i++)
    {
        UITextField *pwdTextField = [[UITextField alloc] init];
//        pwdTextField.layer.borderColor = [UIColor grayColor].CGColor;
        pwdTextField.enabled = YES;
        pwdTextField.textAlignment = NSTextAlignmentCenter;//居中
        pwdTextField.secureTextEntry = NO;//设置密码模式
        pwdTextField.layer.borderWidth = 0.5;
        pwdTextField.userInteractionEnabled = NO;
//        [self insertSubview:pwdTextField belowSubview:self.textField];
//        [self insertSubview:pwdTextField aboveSubview:self.textField];
        pwdTextField.hidden = NO;
        [self addSubview:pwdTextField];
        [self.symbolArr addObject:pwdTextField];
    }
    if (places > 0) {
        [self setupContents:places];
    }
}

#pragma mark - 视图内部布局相关
- (void)setupContents:(NSInteger)pages{
    
    self.layer.borderWidth = 1;
    self.layer.borderColor = [UIColor blackColor].CGColor;
    
    // 创建分割线
    for (int i = 0; i < pages - 1; i++) {
        UIView *line = [[UIView alloc] init];
        line.backgroundColor = [UIColor grayColor];
        [self addSubview:line];
    }
    
//    // 创建中心原点
//    for (int i = 0; i < pages; i++) {
//        CAShapeLayer *symbol = [CAShapeLayer layer];
//        symbol.fillColor = [UIColor blackColor].CGColor;
//        UIBezierPath *path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(0, 0, kWXInputViewSymbolWH, kWXInputViewSymbolWH)];
//        symbol.path = path.CGPath;
//        symbol.hidden = YES;
//        [self.layer addSublayer:symbol];
//        
//        // 将所有中心原点添加到数组中
//        [self.symbolArr addObject:symbol];
//    }
    
}

- (void)layoutSubviews{
    [super layoutSubviews];
    
    CGFloat lineX = 0;
    CGFloat lineY = 0;
    CGFloat lineW = 1;
    CGFloat lineH = self.frame.size.height;
    CGFloat margin = kWXInputViewSymbolWH * 0.5;

    CGFloat w = self.frame.size.width / self.places;
    
    for (int i = 0; i < self.places - 1; i++) {
        UIView *line = self.subviews[i];
        lineX = w * (i + 1);
        line.frame = CGRectMake(lineX, lineY, lineW, lineH);
    }
    
    
    for (int i = 0; i < self.symbolArr.count; i++) {
//        CAShapeLayer *circle = self.symbolArr[i];
//        circle.position = CGPointMake(w * (0.5 + i) - margin, self.frame.size.height * 0.5 - margin);
        UITextField *pwdTextField = [self.symbolArr objectAtIndex:i];
//        lineX = i * (w + margin);
        lineX = i * (self.frame.size.width/self.symbolArr.count);
        pwdTextField.frame = CGRectMake(lineX, lineY, w, lineH);
    }
    
}

#pragma mark - 共有方法
- (void)beginInput{
    if (_textField == nil) {
        
    }
    [self.textField becomeFirstResponder];
}

- (void)endInput{
    [self.textField resignFirstResponder];
}

#pragma mark - 懒加载
- (NSMutableArray *)symbolArr{
    if (_symbolArr == nil) {
        _symbolArr = [NSMutableArray array];
    }
    return _symbolArr;
}

-(UITextField *)textField{
    if (_textField == nil) {
                _textField = [[UITextField alloc] initWithFrame:[UIScreen mainScreen].bounds];
                _textField.keyboardType = UIKeyboardTypeNumberPad;
                _textField.hidden = YES;
                [self addSubview:_textField];
    }
    return _textField;
}


+ (instancetype)inputView{
    return [[self alloc] init];
}

#pragma mark - 视图销毁
- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
