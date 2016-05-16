//
//  RecommendController.m
//  ElephantBike
//
//  Created by 黄杰锋 on 16/3/29.
//  Copyright © 2016年 黄杰锋. All rights reserved.
//

#import "RecommendController.h"
#import "UISize.h"
#import "RecommendTableViewCell.h"
#import "AppDelegate.h"
#import "UIImageView+WebCache.h"


@interface RecommendController ()<UITableViewDelegate, UITableViewDataSource, NSURLConnectionDataDelegate, UIAlertViewDelegate>

@end

@implementation RecommendController{
    UITableView *RecommendTableView;
    NSUserDefaults *userDefaults;
    NSArray *dataArray;
    UIView *cover;
    CGFloat RealCellHeight;
    AppDelegate *myAppDelegate;
}

- (id)init {
    if (self = [super init]) {
        userDefaults = [NSUserDefaults standardUserDefaults];
        myAppDelegate = [[UIApplication sharedApplication] delegate];
        dataArray = [[NSArray alloc] init];
    }
    return self;
}

-(void)UIInit{
    /** 静态的 分组的节头会比较大*/
    RecommendTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 0.866*SCREEN_WIDTH, SCREEN_HEIGHT-64) style:UITableViewStyleGrouped];
    RecommendTableView.center = CGPointMake(0.5*SCREEN_WIDTH, 0.5*(SCREEN_HEIGHT-64));
    /** 解决了头部多出来的空白高度*/
//    self.automaticallyAdjustsScrollViewInsets = NO;
    [self UILayout];
}

-(void)navigationInit{
    self.navigationItem.title = @"消息中心";
    UIBarButtonItem *backBar = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"返回"] style:UIBarButtonItemStylePlain target:self action:@selector(backMenu)];
    self.navigationItem.leftBarButtonItem = backBar;
    backBar.tintColor = [UIColor grayColor];
    //设置导航栏字体
    [self.navigationController.navigationBar setTitleTextAttributes:
     @{NSFontAttributeName:[UIFont fontWithName:@"QingYuanMono" size:18],
       NSForegroundColorAttributeName:[UIColor blackColor]}];
}


-(void)UILayout{
    self.view.backgroundColor = [UIColor colorWithRed:240.0/255 green:240.0/255 blue:240.0/255 alpha:1];
    RecommendTableView .dataSource = self;
    RecommendTableView .delegate = self;
    RecommendTableView .scrollEnabled = YES;
    RecommendTableView.showsVerticalScrollIndicator = NO;
    [self.view addSubview:RecommendTableView];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = BACKGROUNDCOLOR;
    self.edgesForExtendedLayout = UIRectEdgeNone;
    [self navigationInit];
    [self requestForData];
    [userDefaults setBool:NO forKey:@"isMessage"];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"updateMessage" object:nil];
}

#pragma mark - 返回方法
-(void)backMenu{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - 请求消息中心数据
- (void)requestForData {
    // 集成api  此处是膜
    cover = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    cover.alpha = 1;
    // 半黑膜
    UIView *containerView = [[UIView alloc] initWithFrame:CGRectMake(0.3*SCREEN_WIDTH, 0.4*SCREEN_HEIGHT, 0.4*SCREEN_WIDTH, 0.15*SCREEN_HEIGHT)];
    containerView.backgroundColor = [UIColor blackColor];
    containerView.alpha = 0.8;
    containerView.layer.cornerRadius = CORNERRADIUS*2;
    [cover addSubview:containerView];
    // 两个控件
    UIActivityIndicatorView *waitActivityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    waitActivityView.frame = CGRectMake(0.33*containerView.frame.size.width, 0.1*containerView.frame.size.width, 0.33*containerView.frame.size.width, 0.4*containerView.frame.size.height);
    [waitActivityView startAnimating];
    [containerView addSubview:waitActivityView];
    
    UILabel *hintMes = [[UILabel alloc] initWithFrame:CGRectMake(0, 0.7*containerView.frame.size.height, containerView.frame.size.width, 0.2*containerView.frame.size.height)];
    hintMes.text = @"请稍后...";
    hintMes.textColor = [UIColor whiteColor];
    hintMes.textAlignment = NSTextAlignmentCenter;
    [containerView addSubview:hintMes];
    [self.view addSubview:cover];
    
    NSString *urlStr = [IP stringByAppendingString:@"/api/user/message"];
    NSURL *url = [NSURL URLWithString:urlStr];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    NSString *dataStr = [NSString stringWithFormat:@"phone=%@&access_token=%@", [userDefaults objectForKey:@"phoneNumber"], [userDefaults objectForKey:@"accessToken"]];
    NSData *data = [dataStr dataUsingEncoding:NSUTF8StringEncoding];
    [request setHTTPBody:data];
    [request setHTTPMethod:@"POST"];
    NSURLConnection *connection = [NSURLConnection connectionWithRequest:request delegate:self];
}

#pragma mark - 服务器返回
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    NSDictionary *receiveJson = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
    NSString *status = receiveJson[@"status"];
    NSString *message = receiveJson[@"message"];
    [cover removeFromSuperview];
    if ([status isEqualToString:@"success"]) {
        dataArray = receiveJson[@"data"];
        [self UIInit];
    }else {
        if ([message rangeOfString:@"invalid token"].location != NSNotFound) {
            // 账号在别的地方登陆
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"您的身份验证已过期，请重新登录" delegate:self cancelButtonTitle:@"好的" otherButtonTitles:nil, nil];
            alertView.tag = 10;
            [alertView show];
        }else {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"您还没有消息" delegate:nil cancelButtonTitle:@"好的" otherButtonTitles:nil, nil];
            [alertView show];
        }
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    [cover removeFromSuperview];
    cover = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    cover.alpha = 1;
    // 半黑膜
    UIView *containerView = [[UIView alloc] initWithFrame:CGRectMake(0.3*SCREEN_WIDTH, 0.4*SCREEN_HEIGHT, 0.4*SCREEN_WIDTH, 0.15*SCREEN_HEIGHT)];
    containerView.backgroundColor = [UIColor blackColor];
    containerView.alpha = 0.8;
    containerView.layer.cornerRadius = CORNERRADIUS*2;
    [cover addSubview:containerView];
    // 一个控件
    UILabel *hintMes1 = [[UILabel alloc] initWithFrame:CGRectMake(0, 0.4*containerView.frame.size.height, containerView.frame.size.width, 0.2*containerView.frame.size.height)];
    hintMes1.text = @"请检查您的网络";
    hintMes1.textColor = [UIColor whiteColor];
    hintMes1.textAlignment = NSTextAlignmentCenter;
    [containerView addSubview:hintMes1];
    [self.view addSubview:cover];
    // 显示时间
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(removeView) userInfo:nil repeats:NO];
    [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
}

- (void)removeView {
    [cover removeFromSuperview];
}

#pragma mark - tableViewDelegate
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return dataArray.count;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
//    static NSString *identity = @"Cell";
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identity];
//    if (cell == nil) {
//        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identity];
//    }
//    cell.textLabel.font = [UIFont fontWithName:@"QingYuanMono" size:12];
//    cell.textLabel.text = [dataArray objectAtIndex:indexPath.row][@"createtime"];
//    cell.detailTextLabel.text = [dataArray objectAtIndex:indexPath.row][@"content"];
//    cell.detailTextLabel.font = [UIFont fontWithName:@"QingYuanMono" size:20];
//    cell.detailTextLabel.numberOfLines = 0;
//    cell.selectionStyle = UITableViewCellSelectionStyleNone;
//    if ([[dataArray objectAtIndex:indexPath.row][@"state"] intValue] == 1) {
//        cell.detailTextLabel.textColor = [UIColor redColor];
//    }
    RecommendTableViewCell *cell = [RecommendTableViewCell cellWithTableView:tableView];
    cell.contentView.backgroundColor = [UIColor colorWithRed:255.0/255 green:255.0/255 blue:255.0/255 alpha:1];
    cell.layer.borderColor = [UIColor colorWithRed:166.0/255 green:147.0/255 blue:124.0/255 alpha:1].CGColor;
    cell.layer.borderWidth = 1;
    cell.userInteractionEnabled = NO;
    /** 设置不交互*/
    cell.layer.masksToBounds = YES;
    cell.layer.cornerRadius = 6;
    
    
    NSDictionary *dic = dataArray[indexPath.section];
    cell.RecommendNameLabel.text = dic[@"title"];
    cell.RecommendDateLabel.text = dic[@"createtime"];
    cell.RecommendDetailLabel.text = dic[@"content"];
    cell.contentStr = dic[@"content"];
//    cell.RecommendNameLabel.text = @"认证通过通知";
    cell.RecommendDetailLabel.text = cell.contentStr;
    
    
    NSMutableAttributedString * attributedString1 = [[NSMutableAttributedString alloc] initWithString:cell.contentStr];
    NSMutableParagraphStyle * paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    //    paragraphStyle.alignment = NSTextAlignmentJustified;
    [paragraphStyle setLineSpacing:5];
    [attributedString1 addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [cell.contentStr length])];
    cell.RecommendDetailLabel.attributedText = attributedString1;
    
    
    //    cell.RecommendDetailLabel.text = dataArray[indexPath.section];
    RealCellHeight = cell.cellHeight;
    
    return cell;
}

#pragma mark - alertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == 10) {
        myAppDelegate.isLogout = YES;
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
        [[SDImageCache sharedImageCache] removeImageForKey:@"学生证" fromDisk:YES];
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
}

#pragma Mark - 分区高度的设置
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return RealCellHeight;
    
}
//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
//    UILabel * tempLabel=[[UILabel alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, CGFLOAT_MAX)];
//    tempLabel.text = [dataArray objectAtIndex:indexPath.row][@"content"];
//    CGFloat height = [self labelheight:tempLabel].height;
//    return height+30;
//}

- (CGSize)labelheight:(UILabel *)detlabel

{
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    
    paragraphStyle.lineSpacing = 5;// 字体的行间距
    
    NSDictionary *attributes = @{
                                 
                                 NSFontAttributeName:[UIFont fontWithName:@"QingYuanMono" size:20],
                                 
                                 NSParagraphStyleAttributeName:paragraphStyle
                                 
                                 };
    
    CGSize size = CGSizeMake(SCREEN_WIDTH, 1000);
    
    CGSize contentactually = [detlabel.text boundingRectWithSize:size options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading) attributes:attributes context:nil].size;
    
    return contentactually;
    
}


//设置分区头的高度
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 35;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 3;
}


//-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(nonnull NSIndexPath *)indexPath{
//    return (0.50*SCREEN_HEIGHT-24)/4;
//}

//* 节头的标题
-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{

    return @"2016-04-11";
}
//* 节头的视图
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    CGFloat sectionHeight = [self tableView:RecommendTableView heightForHeaderInSection:section];
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, sectionHeight)];
//    view.backgroundColor = [UIColor redColor];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0.334*SCREEN_WIDTH, 0.026*SCREEN_HEIGHT)];
    label.center = CGPointMake(0.5*tableView.bounds.size.width, sectionHeight/2);
    label.font = [UIFont fontWithName:@"QingYuanMono" size:12];
    label.backgroundColor = [UIColor colorWithRed:215.0/255 green:215.0/255 blue:215.0/255 alpha:1];
    label.textColor = [UIColor colorWithRed:247.0/255 green:247.0/255 blue:247.0/255 alpha:1];
    label.layer.masksToBounds = YES;
    label.layer.cornerRadius = 6;
    label.layer.borderColor = [UIColor colorWithRed:215.0/255 green:215.0/255 blue:215.0/255 alpha:1].CGColor;
    NSString *sectionTitle = [self tableView:RecommendTableView titleForHeaderInSection:section];
    label.text = sectionTitle;
    label.textAlignment = NSTextAlignmentCenter;
//    label.backgroundColor = [UIColor blackColor];
    
    [view addSubview:label];
    
    return view;
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
