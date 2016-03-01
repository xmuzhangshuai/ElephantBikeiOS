//
//  ViewController.m
//  ElephantBike
//
//  Created by 黄杰锋 on 16/1/12.
//  Copyright © 2016年 黄杰锋. All rights reserved.
//

#import "ViewController.h"

#define SCREEN_WIDTH            [[UIScreen mainScreen] bounds].size.width
#define SCREEN_HEIGHT           [[UIScreen mainScreen] bounds].size.height
#define SAME_WIDTH              0.8*SCREEN_WIDTH
#define PHONE_TEXTFIELD_WIDTH   0.7*SCREEN_WIDTH
#define VERIFY_BUTTON_WIDTH     0.1*SCREEN_WIDTH
#define SAME_HEIGHT             0.05*SCREEN_HEIGHT

@interface ViewController ()
@end

@implementation ViewController{
    UITextField *phoneTF;
    UITextField *verifyTF;
    UIButton *verifyButton;
    UIButton *startButton;
    UILabel *mesLabel;
    UIBarButtonItem *backButton;
}

- (instancetype)init {
    if (self = [super init]) {
        phoneTF = [[UITextField alloc]init];
        verifyTF = [[UITextField alloc]init];
        verifyButton = [[UIButton alloc]init];
        startButton = [[UIButton alloc]init];
        mesLabel = [[UILabel alloc]init];
        backButton = [[UIBarButtonItem alloc]init];
    }
    return self;
}

- (void)dealloc {
    
}


#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    [self UIInit];
}

#pragma mark - Private Method
- (void)UIInit {
    phoneTF.frame = CGRectMake(0.1*SCREEN_WIDTH, 0.5*SAME_HEIGHT, PHONE_TEXTFIELD_WIDTH, SAME_HEIGHT);
    phoneTF.placeholder = @"手机号";
    phoneTF.layer.cornerRadius = 0.5;
    phoneTF.layer.borderColor = [UIColor blackColor].CGColor;
    phoneTF.borderStyle = UITextBorderStyleRoundedRect;
    phoneTF.backgroundColor = [UIColor blackColor];
    
    verifyButton.frame = CGRectMake(0.8*SCREEN_WIDTH, 0.5*SAME_HEIGHT, VERIFY_BUTTON_WIDTH, SAME_HEIGHT);
    verifyButton.backgroundColor = [UIColor greenColor];
    
    backButton.title = @"后退";
    self.navigationItem.leftBarButtonItem = backButton;
    self.navigationItem.title = @"验证手机";
    
    [self.view addSubview:phoneTF];
    [self.view addSubview:verifyButton];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
