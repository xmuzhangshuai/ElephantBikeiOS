//
//  ElephantMemberViewController.m
//  ElephantBike
//
//  Created by 黄杰锋 on 16/3/23.
//  Copyright © 2016年 黄杰锋. All rights reserved.
//

#import "ElephantMemberViewController.h"
#import "UISize.h"
#import "AppDelegate.h"
#import "InfoViewController.h"
#import "OpenMemberViewController.h"
#import "AppDelegate.h"

/** 宏定义设置UI高度宽度*/
#define MEMBERIMAGEVIEW_WIDTH 0.9*SCREEN_WIDTH
#define MEMBERIMAGEVIEW_HEIGHT 0.50*SCREEN_HEIGHT
#define NUMBERLABEL_WIDTH 0.46*SCREEN_WIDTH
#define NUMBERLABEL_HEIGHT 0.038*SCREEN_HEIGHT
#define DEADLINELABEL_WIDTH 0.68*SCREEN_WIDTH
#define DEADLINELABEL_HEIGHT 0.03*SCREEN_HEIGHT
#define OPENMEMBER_WIDTH 0.8*SCREEN_WIDTH
#define OPENMEMBER_HEIGHT 0.06*SCREEN_HEIGHT


@interface ElephantMemberViewController () <NSURLConnectionDataDelegate>

@end

@implementation ElephantMemberViewController{
    UIImageView *MemberImageView;
    UILabel *NumberLabel;
    UILabel *DeadLineLabel;
    UIButton *OpenMember;
    NSNumber *date;
    BOOL isOpenMember;
   
    NSUserDefaults *userDefaults;
    AppDelegate *myAppDelegate;
}

- (id)init {
    if ([super init]) {
        myAppDelegate = [[UIApplication sharedApplication] delegate];
        userDefaults = [NSUserDefaults standardUserDefaults];
        if ([userDefaults boolForKey:@"isVip"]) {
            NSString *urlStr = [IP stringByAppendingString:@"/ElephantBike/api/user/vipdate"];
            NSURL *url = [NSURL URLWithString:urlStr];
            NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10];
            NSString *dataStr = [NSString stringWithFormat:@"phone=%@", [userDefaults objectForKey:@"phoneNumber"]];
            NSData *data = [dataStr dataUsingEncoding:NSUTF8StringEncoding];
            [request setHTTPBody:data];
            [request setHTTPMethod:@"POST"];
            NSURLConnection *connection = [NSURLConnection connectionWithRequest:request delegate:self];
        }
    }
    return self;
}

-(void)UIinit{
    MemberImageView = [[UIImageView alloc] init];
    NumberLabel = [[UILabel alloc] init];
    DeadLineLabel = [[UILabel alloc] init];
    OpenMember = [[UIButton alloc] init];
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self UILayout];
    [self NavigationInit];
    
}
/** 页面布局*/
-(void)UILayout{
    MemberImageView.frame = CGRectMake(0, 0, MEMBERIMAGEVIEW_WIDTH, MEMBERIMAGEVIEW_HEIGHT);
    MemberImageView.center = CGPointMake(0.5*SCREEN_WIDTH, 0.373*SCREEN_HEIGHT);
    MemberImageView.backgroundColor = [UIColor whiteColor];
    MemberImageView.contentMode = UIViewContentModeScaleAspectFit;
    
    NumberLabel.frame = CGRectMake(0, 0, NUMBERLABEL_WIDTH, NUMBERLABEL_HEIGHT);
    NumberLabel.center = CGPointMake(0.45*SCREEN_WIDTH, 0.40*SCREEN_HEIGHT);
    /** 填写电话号码*/
    NumberLabel.textAlignment = NSTextAlignmentCenter;
    [NumberLabel setNumberOfLines:0];
//    NumberLabel.font = [UIFont systemFontOfSize:25];
    NumberLabel.font = [UIFont fontWithName:@"QingYuanMono" size:25];
    NumberLabel.textColor = [UIColor whiteColor];
    
    /** 到期时间*/
    DeadLineLabel.frame = CGRectMake(0.15*SCREEN_WIDTH, 0.20*SCREEN_WIDTH, DEADLINELABEL_WIDTH, DEADLINELABEL_HEIGHT);
    DeadLineLabel.center = CGPointMake(0.45*SCREEN_WIDTH, 0.45*SCREEN_HEIGHT);
    DeadLineLabel.textAlignment = NSTextAlignmentCenter;

    DeadLineLabel.font = [UIFont fontWithName:@"QingYuanMono" size:15];
    DeadLineLabel.textColor = [UIColor whiteColor];
    
    OpenMember.frame = CGRectMake(0, 0, OPENMEMBER_WIDTH, OPENMEMBER_HEIGHT);
    OpenMember.center = CGPointMake(0.51*SCREEN_WIDTH, 0.95*SCREEN_HEIGHT);
//    [OpenMember setImage:[UIImage imageNamed:@"开通会员"] forState:UIControlStateNormal];
    OpenMember.backgroundColor = [UIColor colorWithRed:112.0/255 green:177.0/255 blue:52.0/255 alpha:1];
    OpenMember.layer.masksToBounds = YES;
    OpenMember.layer.cornerRadius = 6;
    OpenMember.titleLabel.font = [UIFont fontWithName:@"QingYuanMono" size:15];
    [OpenMember addTarget:self action:@selector(OpenMemberView) forControlEvents:UIControlEventTouchUpInside];
    
#warning 判断逻辑 是否已开通会员，如果未开通会员显示开通会员，如果已开通，显示会员续费
    if (![userDefaults boolForKey:@"isVip"]) {
        MemberImageView.image = [UIImage imageNamed:@"不是大象会员页面"];
        [OpenMember setTitle:[NSString stringWithFormat:@"开通会员"] forState:UIControlStateNormal];
    }else {
        MemberImageView.image = [UIImage imageNamed:@"大象会员页面"];
        NumberLabel.text = [userDefaults objectForKey:@"phoneNumber"];
        DeadLineLabel.text = @"";
        [OpenMember setTitle:[NSString stringWithFormat:@"会员续费"] forState:UIControlStateNormal];
    }
    
    [self.view addSubview:MemberImageView];
    [self.view addSubview:OpenMember];
    [MemberImageView addSubview:NumberLabel];
    [MemberImageView addSubview:DeadLineLabel];
   
}

-(void)NavigationInit{
    UIBarButtonItem *BackButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"返回"] style:UIBarButtonItemStylePlain target:self action:@selector(BackView)];
    [BackButton setTintColor:[UIColor grayColor]];
    self.navigationItem.title = @"大象会员";
    self.navigationItem.leftBarButtonItem = BackButton;
    [self.navigationController.navigationBar setTitleTextAttributes:
     @{NSFontAttributeName:[UIFont fontWithName:@"QingYuanMono" size:18],
       NSForegroundColorAttributeName:[UIColor blackColor]}];
    
}

-(void)BackView{
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark - 添加跳转到开通会员/会员续费页面
-(void)OpenMemberView{
    OpenMemberViewController *OpenMemberController = [[OpenMemberViewController alloc] init];
    OpenMemberController.MemberStatus = OpenMember.titleLabel.text;
    [self.navigationController pushViewController:OpenMemberController animated:YES];
}

#pragma mark - 服务器返回
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    NSDictionary *receiveJson = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
    NSString *status = receiveJson[@"status"];
    if ([status isEqualToString:@"success"]) {
        NSString *vipdate = receiveJson[@"vipdate"];
        NSLog(@"会员到期：%@", vipdate);
        DeadLineLabel.text = [NSString stringWithFormat:@"您的会员将于%@到期", vipdate];
        myAppDelegate.deadLineDate = vipdate;
    }
}

#pragma mark - Life Cycle
- (void)viewDidLoad {
    self.view.backgroundColor = BACKGROUNDCOLOR;
    [super viewDidLoad];
    [self UIinit];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
   
}



@end
