//
//  HJFdxdcAlertView.m
//  ElephantBike
//
//  Created by Hjf on 16/4/15.
//  Copyright © 2016年 黄杰锋. All rights reserved.
//
#import "UISize.h"
#import "HJFdxdcAlertView.h"
@interface HJFdxdcAlertView()

@property (strong,nonatomic)UIDynamicAnimator * animator;
@property (strong,nonatomic)UIView * alertview;
@property (strong,nonatomic)UIView * backgroundview;
@property (strong,nonatomic)NSString * content;
@property (strong,nonatomic)NSString * cancelButtonTitle;
@property (strong,nonatomic)NSString * okButtonTitle;
@property (strong,nonatomic)UIImage * image;
@end

@implementation HJFdxdcAlertView

#pragma mark - Gesture
-(void)click:(UITapGestureRecognizer *)sender{
    CGPoint tapLocation = [sender locationInView:self.backgroundview];
    CGRect alertFrame = self.alertview.frame;
    if (!CGRectContainsPoint(alertFrame, tapLocation)) {
        [self dismiss];
    }
}

#pragma mark -  private function
-(UIButton *)createButtonWithFrame:(CGRect)frame Title:(NSString *)title
{
    UIButton * button = [[UIButton alloc] initWithFrame:frame];
    button.titleLabel.textAlignment = NSTextAlignmentCenter;
    [button setTitle:title forState:UIControlStateNormal];
    button.titleLabel.textAlignment = NSTextAlignmentCenter;
    [button addTarget:self action:@selector(clickButton:) forControlEvents:UIControlEventTouchUpInside];
    [button setShowsTouchWhenHighlighted:YES];
    return button;
}

-(void)clickButton:(UIButton *)button{
    if ([self.delegate respondsToSelector:@selector(didClickButtonAtIndex:)]) {
        [self.delegate didClickButtonAtIndex:(button.tag -1)];
    }
    [self dismiss];
}
-(void)dismiss{
//    [self.animator removeAllBehaviors];
//    [UIView animateWithDuration:0.7 animations:^{
//        self.alpha = 0.0;
//        CGAffineTransform rotate = CGAffineTransformMakeRotation(0.9 * M_PI);
//        CGAffineTransform scale = CGAffineTransformMakeScale(0.1, 0.1);
//        self.alertview.transform = CGAffineTransformConcat(rotate, scale);
//    } completion:^(BOOL finished) {
        [self removeFromSuperview];
        self.alertview = nil;
//    }];
    
}
-(void)setUp{
    self.backgroundview = [[UIView alloc] initWithFrame:[[UIApplication sharedApplication] keyWindow].frame];
    self.backgroundview.backgroundColor = [UIColor blackColor];
    self.backgroundview.alpha = 0.4;
    [self addSubview:self.backgroundview];
    
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(click:)];
    [self.backgroundview addGestureRecognizer:tap];
    
    
//    self.alertview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, alertviewWidth, 250)];
    self.alertview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0.6667*SCREEN_WIDTH, 0.2248*SCREEN_HEIGHT)];
    self.alertview.layer.cornerRadius = CORNERRADIUS;
    UIView * keywindow = [[UIApplication sharedApplication] keyWindow];
    self.alertview.center = CGPointMake(CGRectGetMidX(keywindow.frame), -CGRectGetMidY(keywindow.frame));
    self.alertview.backgroundColor = [UIColor whiteColor];
    self.alertview.clipsToBounds = YES;
    
    [self addSubview:self.alertview];
    
    
    UILabel * titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,0,0.6667*SCREEN_WIDTH,0.121*0.2248*SCREEN_HEIGHT)];
    titleLabel.center = CGPointMake(0.5*0.6667*SCREEN_WIDTH, 0.5939*0.2248*SCREEN_HEIGHT);
    titleLabel.text = self.content;
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.alertview addSubview:titleLabel];
    
    UIImageView * imageview = [[UIImageView alloc] initWithFrame:CGRectMake(0,0, 0.1533*SCREEN_WIDTH,0.1533*SCREEN_WIDTH)];
    imageview.center = CGPointMake(0.5*0.6667*SCREEN_WIDTH, 0.3*0.2248*SCREEN_HEIGHT);
    imageview.contentMode = UIViewContentModeScaleToFill;
    imageview.image = self.image;
    imageview.layer.borderColor = [UIColor lightGrayColor].CGColor;
    [self.alertview addSubview:imageview];
    
//    UIButton *okButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 0.4*0.6667*SCREEN_WIDTH, 0.2424*0.2248*SCREEN_HEIGHT)];
    UIButton *okButton = [self createButtonWithFrame:CGRectMake(0, 0, 0.4*0.6667*SCREEN_WIDTH, 0.2424*0.2248*SCREEN_HEIGHT) Title:self.cancelButtonTitle];
    okButton.center = CGPointMake(0.3*0.6667*SCREEN_WIDTH, 0.8181*0.2248*SCREEN_HEIGHT);
    [okButton setTitleColor:[UIColor colorWithRed:160/255.0 green:160/255.0 blue:160/255.0 alpha:1.0] forState:UIControlStateNormal];
    okButton.clipsToBounds = YES;
    okButton.layer.cornerRadius = CORNERRADIUS;
    okButton.layer.borderWidth = 1;
    okButton.layer.borderColor = [UIColor colorWithRed:160/255.0 green:160/255.0 blue:160/255.0 alpha:1.0].CGColor;
    okButton.tag = 1;
    [self.alertview addSubview:okButton];
    
    UIButton *cancleButton = [self createButtonWithFrame:CGRectMake(0, 0, 0.4*0.6667*SCREEN_WIDTH, 0.2424*0.2248*SCREEN_HEIGHT) Title:self.okButtonTitle];
    cancleButton.center = CGPointMake(0.72*0.6667*SCREEN_WIDTH, 0.8181*0.2248*SCREEN_HEIGHT);
    cancleButton.backgroundColor = UICOLOR;
    cancleButton.clipsToBounds = YES;
    cancleButton.layer.cornerRadius = CORNERRADIUS;
    [self.alertview addSubview:cancleButton];
    cancleButton.tag = 2;
}
#pragma mark -  API
- (void)show {
    UIView * keywindow = [[UIApplication sharedApplication] keyWindow];
    [keywindow addSubview:self];
    self.animator = [[UIDynamicAnimator alloc] initWithReferenceView:self];
    UISnapBehavior * sanp = [[UISnapBehavior alloc] initWithItem:self.alertview snapToPoint:self.center];
    sanp.damping = 0.7;
    [self.animator addBehavior:sanp];
}

-(instancetype)initWithContent:(NSString *) content
                       Image:(UIImage *)image
                CancelButton:(NSString *)cancelButton
                    OkButton:(NSString *)okButton{
    if (self = [super initWithFrame:[[UIApplication sharedApplication] keyWindow].frame]) {
        self.content = content;
        self.image = image;
        self.cancelButtonTitle = cancelButton;
        self.okButtonTitle = okButton;
        
        [self setUp];
    }
    return self;
}

@end
