//
//  InfoViewController.m
//  ElephantBike
//
//  Created by 黄杰锋 on 16/1/20.
//  Copyright © 2016年 黄杰锋. All rights reserved.
//

#import "InfoViewController.h"
#import "UISize.h"
#import "MyWalletViewController.h"
#import "IdentificationViewController.h"
#import "HelpViewController.h"
#import "AppDelegate.h"
#import "IdentityViewController.h"
#import "ElephantMemberViewController.h"
#import "RecommendController.h"
#import "ActivityDetailsViewController.h"
#import "UIImageView+WebCache.h"
#import "CustomIOSAlertView.h"
#import "HJFdxdcAlertView.h"


#define AVATARIMAGE_WIDTH               0.16*SCREEN_WIDTH
#define AVATARIMAGE_HEIGHT              AVATARIMAGE_WIDTH
#define NAMELABEL_WIDTH                 0.225*SCREEN_WIDTH
#define NAMELABEL_HEIGHT                0.6*AVATARIMAGE_HEIGHT
#define IDENTIFICATIONLABEL_WIDTH       (0.8*SCREEN_WIDTH-AVATARIMAGE_WIDTH)/5*4
#define IDENTIFICATIONLABEL_HEIGHT      0.4*AVATARIMAGE_HEIGHT
#define INFOTABLEVIEW_HEIGHT            0.25*SCREEN_HEIGHT
#define INFOTABLEVIEW_WIDTH             SCREEN_WIDTH*0.8
#define LOGOTABLEVIEW_WIDTH             0.3*SCREEN_WIDTH*0.8
#define LOGOTABLEVIEW_HEIGHT            LOGOTABLEVIEW_WIDTH

#define ELEPHANTMEMBER_WIDTH 0.2*SCREEN_WIDTH
#define ELEPAHNTMEMBER_HEIGHT 0.3*AVATARIMAGE_HEIGHT

@interface InfoViewController () <UITableViewDataSource, UITableViewDelegate, NSURLConnectionDataDelegate, UIAlertViewDelegate, HJFALertviewDelegate>

@end

@implementation InfoViewController{
//    UIImageView *avatarImage;
    UILabel     *nameLabel;
    UILabel     *identificationLabel;
    UITableView *infoTableView;
    UIImageView *logoImageView;
    UIImageView *avatarImage;
    NSArray     *listArray;
    
    /** 是否已开通大象会员*/
    UIButton *ElephantMemberButton;
    UIImageView *AdImageView;
    
    AppDelegate *myAppDelegate;
    NSUserDefaults *userDefaults;
    
    UILabel     *phoneNumberLabel;  // 电话label
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super init]) {
        self.view.frame = frame;
        NSLog(@"是否认证：%d", myAppDelegate.isIdentify);
        // 请求广告
        NSString *urlStr = [IP stringByAppendingString:@"/api/act/topic"];
        NSURL *url = [NSURL URLWithString:urlStr];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
        NSString *dataStr = [NSString stringWithFormat:@"type=%d", 3];
        NSData *data = [dataStr dataUsingEncoding:NSUTF8StringEncoding];
        [request setHTTPBody:data];
        [request setHTTPMethod:@"POST"];
        NSURLConnection *connection = [NSURLConnection connectionWithRequest:request delegate:self];
    }
    return self;
}

- (id)init {
    if (self = [super init]) {
        myAppDelegate           = [[UIApplication sharedApplication] delegate];
        // 请求广告
        NSString *urlStr = [IP stringByAppendingString:@"/api/act/topic"];
        NSURL *url = [NSURL URLWithString:urlStr];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
        NSString *dataStr = [NSString stringWithFormat:@"type=%d", 3];
        NSData *data = [dataStr dataUsingEncoding:NSUTF8StringEncoding];
        [request setHTTPBody:data];
        [request setHTTPMethod:@"POST"];
        NSURLConnection *connection = [NSURLConnection connectionWithRequest:request delegate:self];
    }
    return self;
}

#pragma mark - UIInit
- (void)UIInit {
    myAppDelegate           = [[UIApplication sharedApplication] delegate];
    avatarImage             = [[UIImageView alloc] init];
    nameLabel               = [[UILabel alloc] init];
    identificationLabel     = [[UILabel alloc] init];
    infoTableView           = [[UITableView alloc] init];
    logoImageView           = [[UIImageView alloc] init];
    
    userDefaults            = [NSUserDefaults standardUserDefaults];
    phoneNumberLabel        = [[UILabel alloc] init];
    
    /** 会员按钮*/
    ElephantMemberButton    = [[UIButton alloc] init];
    AdImageView             = [[UIImageView alloc] init];
    
    listArray               = @[@"我的钱包", @"身份认证", @"消息中心", @"使用指南", @"退出登录"];
    
    [self NavigationInit];
    [self UILayout];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(balanceUpdate) name:@"balanceUpdate" object:nil];
}

- (void)NavigationInit {

}

- (void)UILayout {
    avatarImage.frame = CGRectMake(0, 0, AVATARIMAGE_WIDTH, AVATARIMAGE_HEIGHT);
    avatarImage.center = CGPointMake(0.13*SCREEN_WIDTH, 0.11*SCREEN_HEIGHT);
    avatarImage.image = [UIImage imageNamed:@"头像"];
    avatarImage.contentMode = UIViewContentModeScaleAspectFit;
    // 将方形图片剪裁成圆的
//    avatarImage.layer.masksToBounds = YES;
//    avatarImage.layer.cornerRadius = AVATARIMAGE_WIDTH/2;
    
    
//    nameLabel.frame = CGRectMake(0.05*SCREEN_WIDTH+AVATARIMAGE_WIDTH, STATUS_HEIGHT*2, NAMELABEL_WIDTH, NAMELABEL_HEIGHT);
//    nameLabel.textAlignment = NSTextAlignmentLeft;
//    if (myAppDelegate.isIdentify) {
//        nameLabel.text = @"姓名";
//    }else if (myAppDelegate.isUpload) {
//        nameLabel.text = @"未认证";
//    }else {
//        nameLabel.text = @"请认证";
//    }

    nameLabel.frame = CGRectMake(0.23*SCREEN_WIDTH, 0.05*SCREEN_HEIGHT, NAMELABEL_WIDTH, NAMELABEL_HEIGHT);
    NSLog(@"identity:%d", myAppDelegate.isIdentify);
    if (myAppDelegate.isIdentify) {
        nameLabel.text = [userDefaults objectForKey:@"name"];
    }else {
        nameLabel.text = @"";
    }
    nameLabel.font = [UIFont fontWithName:@"QingYuanMono" size:14];
    if (iPhone6P) {
        nameLabel.font = [UIFont fontWithName:@"QingYuanMono" size:16];
    }
    nameLabel.textAlignment = NSTextAlignmentLeft;
    
    identificationLabel.frame = CGRectMake(0.23*SCREEN_WIDTH, 0.09*SCREEN_HEIGHT, IDENTIFICATIONLABEL_WIDTH, IDENTIFICATIONLABEL_HEIGHT);
    if (myAppDelegate.isIdentify) {
        identificationLabel.text = [NSString stringWithFormat:@"已认证：%@", [userDefaults objectForKey:@"college"]];
    }else {
        identificationLabel.text = @"未认证";
    }
    identificationLabel.font = [UIFont fontWithName:@"QingYuanMono" size:10];
    if (iPhone6P) {
        identificationLabel.font = [UIFont fontWithName:@"QingYuanMono" size:12];
    }
    identificationLabel.textAlignment = NSTextAlignmentLeft;
    
    /** 会员的按钮*/
    ElephantMemberButton.frame = CGRectMake(0.23*SCREEN_WIDTH, 0.125*SCREEN_HEIGHT, ELEPHANTMEMBER_WIDTH, ELEPAHNTMEMBER_HEIGHT);
    
    //设置条件，是否是会员
    if ([userDefaults boolForKey:@"isVip"]) {
        [ElephantMemberButton setImage:[UIImage imageNamed:@"会员标识"] forState:UIControlStateNormal];
    }else {
        [ElephantMemberButton setImage:[UIImage imageNamed:@"开通大象会员"] forState:UIControlStateNormal];
    }
    [ElephantMemberButton addTarget:self action:@selector(openElephantMember) forControlEvents:UIControlEventTouchUpInside];
    
    
//    NSString *phoneNumber = [userDefaults objectForKey:@"phoneNumber"];
//    phoneNumberLabel.frame = CGRectMake(0.05*SCREEN_WIDTH+AVATARIMAGE_WIDTH, STATUS_HEIGHT*2+NAMELABEL_HEIGHT+IDENTIFICATIONLABEL_HEIGHT, IDENTIFICATIONLABEL_WIDTH, IDENTIFICATIONLABEL_HEIGHT);
//    phoneNumberLabel.text = phoneNumber;
//    [self.view addSubview:phoneNumberLabel];
    
    infoTableView.frame = CGRectMake(0, 0.25*SCREEN_HEIGHT, INFOTABLEVIEW_WIDTH, INFOTABLEVIEW_HEIGHT);
    infoTableView.dataSource = self;
    infoTableView.delegate = self;
    infoTableView.scrollEnabled = NO;

    
    logoImageView.frame = CGRectMake(0, 0, 0.12*SCREEN_WIDTH, 0.042*SCREEN_HEIGHT);
    logoImageView.center = CGPointMake(0.5*0.8666*SCREEN_WIDTH, 0.822*SCREEN_HEIGHT);
    logoImageView.image = [UIImage imageNamed:@"LOGO"];
    logoImageView.contentMode = UIViewContentModeScaleAspectFit;
    
    //预留的广告位
    AdImageView.frame = CGRectMake(0.05*SCREEN_WIDTH, 0.87*SCREEN_HEIGHT, 0.75*SCREEN_WIDTH, 0.12*SCREEN_HEIGHT);
    AdImageView.layer.masksToBounds = YES;
    AdImageView.layer.cornerRadius = 5;
    AdImageView.userInteractionEnabled = YES;
    UITapGestureRecognizer *activityDetails = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(gotoDetails)];
    [AdImageView addGestureRecognizer:activityDetails];
    
    [self.view addSubview:avatarImage];
    [self.view addSubview:nameLabel];
    [self.view addSubview:identificationLabel];
    [self.view addSubview:ElephantMemberButton];
    [self.view addSubview:infoTableView];
    [self.view addSubview:logoImageView];
    [self.view addSubview:AdImageView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeMemberStatus) name:@"isVip" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateInfo) name:@"updateInfo" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateIdentify) name:@"updateIdentify" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateMessage) name:@"updateMessage" object:nil];
}

#pragma mark - 私有方法
/** 点击方法*/
-(void)openElephantMember{
    ElephantMemberViewController *ElephantMemberController = [[ElephantMemberViewController alloc] init];
    [self.delegate getNextViewController:ElephantMemberController];
}

- (void)balanceUpdate {
    UITableViewCell *cell = [infoTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    NSString *str = [@"余额:" stringByAppendingString:myAppDelegate.balance];
    NSString *str1 = [str stringByAppendingString:@"元"];
    cell.detailTextLabel.text = str1;
}

- (void)changeMemberStatus {
    if ([userDefaults boolForKey:@"isVip"]) {
        [ElephantMemberButton setImage:[UIImage imageNamed:@"会员标识"] forState:UIControlStateNormal];
    }else {
        [ElephantMemberButton setImage:[UIImage imageNamed:@"开通大象会员"] forState:UIControlStateNormal];
    }
}

- (void)updateInfo {
    if (myAppDelegate.isIdentify) {
        nameLabel.text = [userDefaults objectForKey:@"name"];
    }else {
        nameLabel.text = @"";
    }
    if (myAppDelegate.isIdentify) {
        identificationLabel.text = [NSString stringWithFormat:@"已认证：%@", [userDefaults objectForKey:@"college"]];
    }else {
        identificationLabel.text = @"未认证";
    }
}

- (void)updateIdentify {
    nameLabel.text = [userDefaults objectForKey:@"name"];
    identificationLabel.text = [NSString stringWithFormat:@"已认证：%@", [userDefaults objectForKey:@"college"]];
}

- (void)updateMessage {
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:2 inSection:0];
    UITableViewCell *cell = [infoTableView cellForRowAtIndexPath:indexPath];
    cell.detailTextLabel.text = @"";
}

- (void)gotoDetails {
    if (![myAppDelegate.linkUrlInfo isEqualToString:@""]) {
        myAppDelegate.ad = 2;
        ActivityDetailsViewController *activityDetailsViewController = [[ActivityDetailsViewController alloc] init];
        [self.delegate getNextViewController:activityDetailsViewController];
    }
}

#pragma mark - 服务器返回
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    NSDictionary *receive = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
    NSString *status = receive[@"status"];
    NSString *imageurl = receive[@"imageurl"];
    NSString *linkurl = receive[@"linkurl"];
    if ([status isEqualToString:@"success"]) {
        myAppDelegate.imageUrlInfo = @"";
        myAppDelegate.linkUrlInfo = @"";
        NSString *temp = [IP stringByAppendingString:@"/"];
        myAppDelegate.imageUrlInfo = [temp stringByAppendingString:imageurl];
        if (![linkurl isEqualToString:@""]) {
            myAppDelegate.linkUrlInfo = linkurl;
        }
        [AdImageView sd_setImageWithURL:[NSURL URLWithString:myAppDelegate.imageUrlInfo]];
    }
}

#pragma mark - TableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
    }
    cell.textLabel.text = [listArray objectAtIndex:indexPath.row];
    NSLog(@"indexpath.row:%ld", (long)indexPath.row);
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.font = [UIFont fontWithName:@"QingYuanMono" size:14];
    cell.detailTextLabel.font = [UIFont fontWithName:@"QingYuanMono" size:10];
    if (indexPath.row == 0) {
        NSString *str = [@"余额:" stringByAppendingString:myAppDelegate.balance];
        NSString *str1 = [str stringByAppendingString:@"元"];
        cell.detailTextLabel.text = str1;
    }
    if (indexPath.row == 2 && [userDefaults boolForKey:@"isMessage"]) {
        cell.detailTextLabel.text = @"您有新消息";
    }
    if (iPhone6P) {
        cell.textLabel.font = [UIFont fontWithName:@"QingYuanMono" size:16];
        cell.detailTextLabel.font = [UIFont fontWithName:@"QingYuanMono" size:12];
    }
    return cell;
}

// 字体
//-(UIFont*)customFont{
//    // 你的字体路径
//    NSString *fontPath = [[NSBundle mainBundle] pathForResource:@"晴圆等宽" ofType:@"ttc"];
//    NSURL *url = [NSURL fileURLWithPath:fontPath];
//    CGDataProviderRef fontDataProvider = CGDataProviderCreateWithURL((__bridge CFURLRef)url);
//    if (fontDataProvider == NULL)
//        return nil;
//    CGFontRef newFont = CGFontCreateWithDataProvider(fontDataProvider);
//    CGDataProviderRelease(fontDataProvider);
//    if (newFont == NULL) return nil;
//    NSString *fontName = (__bridge NSString *)CGFontCopyFullName(newFont);
//    NSLog(@"晴圆等宽：%@", fontName);
//    UIFont *font = [UIFont fontWithName:fontName size:12];
//    CGFontRelease(newFont);
//    return font;
//}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return  INFOTABLEVIEW_HEIGHT/5;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.row) {
        case 0:{
            MyWalletViewController *myWalletViewController = [[MyWalletViewController alloc] init];
            [self.delegate getNextViewController:myWalletViewController];
        }
            break;
        case 1:{
            //            IdentificationViewController *identificationViewController = [[IdentificationViewController alloc] init];
            IdentityViewController *identityViewController = [[IdentityViewController alloc] init];
            //            [self.delegate getNextViewController:identificationViewController];
                        [self.delegate getNextViewController:identityViewController];
        }
            break;
        case 2:{
//            RecommendViewController *recommendViewController = [[RecommendViewController alloc] init];
            //            [self.delegate getNextViewController:recommendViewController];
            RecommendController *recommendController = [[RecommendController alloc] init];
            [self.delegate getNextViewController:recommendController];        }
            break;
        case 3:{
            HelpViewController *helpViewController = [[HelpViewController alloc] init];
            [self.delegate getNextViewController:helpViewController];
        }
            break;
        case 4:{
            [self Logout];
        }
            break;
        default:
            break;
    }
}



#pragma mark - 退出方法
- (void)Logout {
    
    HJFdxdcAlertView *alertView = [[HJFdxdcAlertView alloc] initWithContent:@"您确定要退出登录？" Image:[UIImage imageNamed:@"退出的提醒"] CancelButton:@"取消" OkButton:@"确定"];
    alertView.delegate = self;
    [alertView show];
    
    
//    CustomIOSAlertView *alertView = [[CustomIOSAlertView alloc] initWithParentView:self.view];
//    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0.6*SCREEN_WIDTH, 0.2*SCREEN_HEIGHT)];
//    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 0.2*SCREEN_WIDTH, 0.2*SCREEN_WIDTH)];
//    imageView.center = CGPointMake(view.center.x, view.center.y*0.8);
//    [imageView setImage:[UIImage imageNamed:@"退出的提醒"]];
//    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, imageView.center.y+0.15*SCREEN_WIDTH, 0.6*SCREEN_WIDTH, 0.2*view.frame.size.height)];
//    [view addSubview:imageView];
//    [view addSubview:label];
//    label.text = @"是否退出登录";
//    label.font = [UIFont fontWithName:@"QingYuanMono" size:15];
//    if (iPhone6P) {
//        label.font = [UIFont fontWithName:@"QingYuanMono" size:18];
//    }
//    label.textAlignment = YES;
//    [alertView setContainerView:view];
//    [alertView setButtonTitles:[NSMutableArray arrayWithObjects:@"确定", @"取消", nil]];
//    [alertView setUseMotionEffects:YES];
//    [alertView setOnButtonTouchUpInside:^(CustomIOSAlertView *alertView, int buttonIndex) {
//        NSLog(@"Block: Button at position %d is clicked on alertView %d.", buttonIndex, (int)[alertView tag]);
//        if (buttonIndex == 0) {
//            // 退出登录
//            myAppDelegate.isIdentify = NO;
//            myAppDelegate.isFreeze = NO;
//            myAppDelegate.isEndPay = YES;
//            myAppDelegate.isEndRiding = YES;
//            myAppDelegate.isRestart = NO;
//            myAppDelegate.isMissing = NO;
//            myAppDelegate.isUpload = NO;
//            myAppDelegate.isLogin = NO;
//            myAppDelegate.isLogout = YES;
//            myAppDelegate.isLinked = YES;
//            [userDefaults setBool:NO forKey:@"isLogin"];
//            [userDefaults setBool:NO forKey:@"isVip"];
//            [userDefaults setObject:@"" forKey:@"name"];
//            [userDefaults setObject:@"" forKey:@"stunum"];
//            [userDefaults setObject:@"" forKey:@"college"];
//            [userDefaults setBool:NO forKey:@"isMessage"];
//            [[SDImageCache sharedImageCache] removeImageForKey:@"学生证" fromDisk:YES];
//            [self.delegate removeFromSuperView];
//            [self.navigationController popToRootViewControllerAnimated:YES];
//        }else {
//            [alertView close];
//        }
//    }];
//    [alertView show];
}
#pragma mark - alertViewDelegate
-(void)didClickButtonAtIndex:(NSUInteger)index{
    switch (index) {
        case 0:
            NSLog(@"Click Cancel");
            break;
        case 1:{
            // 退出登录
            myAppDelegate.isIdentify = NO;
            myAppDelegate.isFreeze = NO;
            myAppDelegate.isEndPay = YES;
            myAppDelegate.isEndRiding = YES;
            myAppDelegate.isRestart = NO;
            myAppDelegate.isMissing = NO;
            myAppDelegate.isUpload = NO;
            myAppDelegate.isLogin = NO;
            myAppDelegate.isLogout = YES;
            myAppDelegate.isLinked = YES;
            [userDefaults setBool:NO forKey:@"isLogin"];
            [userDefaults setBool:NO forKey:@"isVip"];
            [userDefaults setObject:@"" forKey:@"name"];
            [userDefaults setObject:@"" forKey:@"stunum"];
            [userDefaults setObject:@"" forKey:@"college"];
            [userDefaults setBool:NO forKey:@"isMessage"];
            [userDefaults setObject:@"" forKey:@"bikeNo"];
            [[SDImageCache sharedImageCache] removeImageForKey:@"学生证" fromDisk:YES];
            [self.delegate removeFromSuperView];
            [self.navigationController popToRootViewControllerAnimated:YES];
        }
            break;
        default:
            break;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    [self UIInit];
}

- (void)viewWillAppear:(BOOL)animated {
    NSArray *array = [infoTableView visibleCells];
    UITableViewCell *firstCell = [array firstObject];
    NSString *str = [@"余额:" stringByAppendingString:myAppDelegate.balance];
    NSString *str1 = [str stringByAppendingString:@"元"];
    firstCell.detailTextLabel.text = str1;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
