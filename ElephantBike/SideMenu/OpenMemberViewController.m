//
//  OpenMemberViewController.m
//  ElephantBike
//
//  Created by 黄杰锋 on 16/3/24.
//  Copyright © 2016年 黄杰锋. All rights reserved.
//

#import "OpenMemberViewController.h"
#import "ElephantMemberViewController.h"
#import "InfoViewController.h"
#import "UISize.h"
#import "MemberPayViewController.h"
#import "AppDelegate.h"

@interface OpenMemberViewController ()<UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UILabel *MoneyLabel;
@property (weak, nonatomic) IBOutlet UILabel *deadTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *MemberNoLabel;

@end

@implementation OpenMemberViewController{
    UITableView *MemberTableView;
    //界面数据数组
    NSMutableArray *listArray;
    NSMutableArray *moneyArray;
    UIButton *OpenMemberBtn;
    NSString *memberMonth;
    NSUserDefaults *userDefaults;
    AppDelegate *myAppDelegate;
}

- (id)init {
    if (self = [super init]) {
        myAppDelegate = [[UIApplication sharedApplication] delegate];
        userDefaults = [NSUserDefaults standardUserDefaults];
        self.MemberStatus = [[NSString alloc] init];
        listArray = [[NSMutableArray alloc] initWithObjects:@"1个月大象会员",@"3个月大象会员", @"6个月大象会员", @"12个月大象会员", nil];
        moneyArray = [[NSMutableArray alloc] initWithObjects:@"￥3.00", @"￥7.00", @"￥11.00", @"￥18.00", nil];
        memberMonth = @"";
    }
    return self;
}


-(void)NavigationInit{
    self.navigationItem.title = self.MemberStatus;
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"返回"] style:UIBarButtonItemStylePlain target:self action:@selector(backElephantMember)];
    backButton.tintColor = [UIColor grayColor];
    self.navigationItem.leftBarButtonItem = backButton;
    [self.navigationController.navigationBar setTitleTextAttributes:
     @{NSFontAttributeName:[UIFont fontWithName:@"QingYuanMono" size:18],
       NSForegroundColorAttributeName:[UIColor blackColor]}];
    
}

-(void)UIInit{
    MemberTableView = [[UITableView alloc] init];
    /** 解决了头部多出来的空白高度*/
    self.automaticallyAdjustsScrollViewInsets = NO;
    OpenMemberBtn = [[UIButton alloc] init];
    [self UILayout];
    
}
-(void)UILayout{
  
    MemberTableView.frame = CGRectMake(0.048*SCREEN_WIDTH, 0.13*SCREEN_HEIGHT, 0.92*SCREEN_WIDTH, 0.335*SCREEN_HEIGHT);
//    MemberTableView.center = CGPointMake(0.5*SCREEN_WIDTH, 0.39*SCREEN_HEIGHT);
    self.view.backgroundColor = [UIColor colorWithRed:240.0/255 green:240.0/255 blue:240.0/255 alpha:1];
    MemberTableView.dataSource = self;
    MemberTableView.delegate = self;
    MemberTableView.scrollEnabled = NO;
    
    OpenMemberBtn.frame = CGRectMake(0, 0, 0.8*SCREEN_WIDTH, 0.06*SCREEN_HEIGHT);
    OpenMemberBtn.center = CGPointMake(0.50*SCREEN_WIDTH, 0.95*SCREEN_HEIGHT);
    OpenMemberBtn.backgroundColor = [UIColor colorWithRed:112.0/255 green:177.0/255 blue:52.0/255 alpha:1];

    OpenMemberBtn.layer.masksToBounds = YES;
    OpenMemberBtn.layer.cornerRadius = 6;
    //确认开通/会员续费的点击事件
    [OpenMemberBtn addTarget:self action:@selector(confirmToMember) forControlEvents:UIControlEventTouchUpInside];
    
    //判断，开通会员/还是会员续费
    if ([self.MemberStatus isEqualToString:@"开通会员"]) {
        [OpenMemberBtn setTitle:@"确认开通" forState:UIControlStateNormal];
    }else {
        [OpenMemberBtn setTitle:@"确认续费" forState:UIControlStateNormal];
    }
    
    
    [self.view addSubview:OpenMemberBtn];
    [self.view addSubview:MemberTableView];
}

#pragma mark - tableView
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 4;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentify = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentify];
    NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"OpenMemberCell" owner:self options:nil];
    if ([nib count] > 0) {
        self.customCell = [nib objectAtIndex:0];
        cell = self.customCell;
    }
    self.MemberNoLabel.font = [UIFont fontWithName:@"QingYuanMono" size:12];
    self.deadTimeLabel.font = [UIFont fontWithName:@"QingYuanMono" size:10];
    self.MemberNoLabel.text = listArray[indexPath.section];
    self.MoneyLabel.text = moneyArray[indexPath.section];
    
    /** 更改label的字体颜色*/
    NSMutableAttributedString *content = [[NSMutableAttributedString alloc] initWithString:self.MoneyLabel.text];
    [content addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"MicrosoftYaHei" size:18] range:NSMakeRange(0, [content length])];
    [content addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:242.0/255 green:139.0/255 blue:0/255 alpha:1] range:NSMakeRange(0, [content length])];
    self.MoneyLabel.attributedText = content;
    
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"yyyy-MM-dd"];
    NSString *today = [df stringFromDate:[NSDate date]];
    if (![userDefaults boolForKey:@"isVip"]) {
        if (indexPath.section == 0) {
            // 一个月后的日期
            self.deadTimeLabel.text = [NSString stringWithFormat:@"有效期至%@", [self dateFrom:today time:1]];
        }else if(indexPath.section == 1) {
            // 三个月后的日期
            self.deadTimeLabel.text = [NSString stringWithFormat:@"有效期至%@", [self dateFrom:today time:3]];
        }else if (indexPath.section == 2) {
            // 六个月后的日期
            self.deadTimeLabel.text = [NSString stringWithFormat:@"有效期至%@", [self dateFrom:today time:6]];
        }else if (indexPath.section == 3) {
            // 一年后的日期
            self.deadTimeLabel.text = [NSString stringWithFormat:@"有效期至%@", [self dateFrom:today time:12]];
        }
    }else {
        NSString *deadDate = myAppDelegate.deadLineDate;
        if (indexPath.section == 0) {
            // 原日期加一个月后的日期
            self.deadTimeLabel.text = [NSString stringWithFormat:@"有效期至%@", [self dateFrom:deadDate time:1]];
        }else if(indexPath.section == 1) {
            // 三个月后的日期
            self.deadTimeLabel.text = [NSString stringWithFormat:@"有效期至%@", [self dateFrom:deadDate time:3]];
        }else if (indexPath.section == 2) {
            // 六个月后的日期
            self.deadTimeLabel.text = [NSString stringWithFormat:@"有效期至%@", [self dateFrom:deadDate time:6]];
        }else if (indexPath.section == 3) {
            // 一年后的日期
            self.deadTimeLabel.text = [NSString stringWithFormat:@"有效期至%@", [self dateFrom:deadDate time:12]];
        }
    }
   
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.layer.borderWidth = 3;
    cell.layer.borderColor = [UIColor colorWithRed:112.0/255 green:177.0/255 blue:52.0/255 alpha:1].CGColor;
    cell.contentView.backgroundColor = [UIColor colorWithRed:255.0/255 green:255.0/255 blue:255.0/255 alpha:1];
    memberMonth = [NSString stringWithFormat:@"%ld", (long)indexPath.section];
}
-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.layer.borderColor = [UIColor whiteColor].CGColor;
    
}

#pragma mark - 分区高度的设置
//设置分区头的高度
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        return 0;
    }
    return 8;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(nonnull NSIndexPath *)indexPath{
//    return (0.514*SCREEN_HEIGHT-24)/4;
    return 0.073*SCREEN_HEIGHT;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = BACKGROUNDCOLOR;
    [self NavigationInit];
    [self UIInit];
}

#pragma mark - 返回到大象会员界面
-(void)backElephantMember{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - 点击跳转到付费页面
-(void)confirmToMember{
    if ([memberMonth isEqualToString:@""]) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"请选择充值月数" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alertView show];
    }else {
        MemberPayViewController *MemberPayController = [[MemberPayViewController alloc] init];
        self.delegate = MemberPayController;
        [self.delegate getMonth:memberMonth];
        [self.navigationController pushViewController:MemberPayController animated:YES];
    }
}

#pragma mark - 私有方法
- (NSString *)dateFrom:(NSString *)date time:(NSUInteger)time{
    NSArray *array = [date componentsSeparatedByString:@"-"];
    NSUInteger month = [[array objectAtIndex:1] intValue];
    NSUInteger year = [[array objectAtIndex:0] intValue];
    month += time;
    if (month > 12) {
        month -= 12;
        year += 1;
    }
    NSString *newMonth = [NSString stringWithFormat:@"%lu", (unsigned long)month];
    NSString *newYear = [NSString stringWithFormat:@"%lu", year];
    return [NSString stringWithFormat:@"%@-%@-%@", newYear, newMonth, [array objectAtIndex:2]];
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
