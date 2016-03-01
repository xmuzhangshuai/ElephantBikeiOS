//
//  RechargeViewController.m
//  ElephantBike
//
//  Created by 黄杰锋 on 16/1/21.
//  Copyright © 2016年 黄杰锋. All rights reserved.
//

#import "RechargeViewController.h"
#import "UISize.h"
#import "MyTableViewCell.h"
#import "AppDelegate.h"

#define PAYLISTTABLEVIEW_WIDTH  SCREEN_WIDTH
#define PAYLISTTABLEVIEW_HEIGHT 0.18*SCREEN_HEIGHT
#define CONTAINERVIEW_WIDTH     SCREEN_WIDTH
#define CONTAINERVIEW_HEIGHT    SCREEN_HEIGHT*0.09
#define MONEYLABEL_WIDTH        SCREEN_WIDTH*0.3
#define MONEYLABEL_HEIGHT       SCREEN_HEIGHT*0.09
#define MONEYTF_WIDTH           0.7*SCREEN_WIDTH
#define MONEYTF_HEIGHT          MONEYLABEL_HEIGHT
#define NEXTBUTTON_WIDTH        COMMIT_WIDTH
#define NEXTBUTTON_HEIGHT       COMMIT_HEIGHT

@interface RechargeViewController () <UITableViewDataSource, UITableViewDelegate, NSURLConnectionDataDelegate>

@end

@implementation RechargeViewController {
    UITableView *payListTableView;
    UIView      *containerView;
    UILabel     *moneyLabel;
    UITextField *moneyTF;
    UIButton    *nextButton;
    
    NSArray     *payWay;
    NSArray     *wayDetails;
    
    UIView      *cover;
    
    NSUserDefaults *userDefaults;
    
    AppDelegate *MyAppDelegate;
}

- (void)UIInit {
    payListTableView    = [[UITableView alloc] init];
    containerView       = [[UIView alloc] init];
    moneyLabel          = [[UILabel alloc] init];
    moneyTF             = [[UITextField alloc] init];
    nextButton          = [[UIButton alloc] init];
    
    payWay              = @[@"微信支付", @"支付宝"];
    wayDetails          = @[@"推荐微信支付已绑定信用卡的用户使用", @"推荐已安装支付宝客户端的用户使用"];
    userDefaults        = [NSUserDefaults standardUserDefaults];
    MyAppDelegate       = [[UIApplication sharedApplication] delegate];
    
    [self NavigationInit];
    [self UILayout];
}

- (void)UILayout {
    NSLog(@"recharge:%f", STATUS_HEIGHT+NAVIGATIONBAR_HEIGHT+SAME_HEIGHT);
    payListTableView.frame = CGRectMake(0, STATUS_HEIGHT, PAYLISTTABLEVIEW_WIDTH, PAYLISTTABLEVIEW_HEIGHT*2);
    payListTableView.dataSource = self;
    payListTableView.delegate = self;
    payListTableView.scrollEnabled = NO;
    
    containerView.frame = CGRectMake(0, STATUS_HEIGHT+NAVIGATIONBAR_HEIGHT+SAME_HEIGHT*1.5+PAYLISTTABLEVIEW_HEIGHT, CONTAINERVIEW_WIDTH, CONTAINERVIEW_HEIGHT);
    containerView.layer.borderWidth = 1;
    containerView.layer.borderColor = [UIColor grayColor].CGColor;
    
    moneyLabel.frame = CGRectMake(0, 0, MONEYLABEL_WIDTH, MONEYLABEL_HEIGHT);
    moneyLabel.text = @"金额（元）";
    moneyLabel.textAlignment = NSTextAlignmentCenter;
    
    moneyTF.frame = CGRectMake(MONEYLABEL_WIDTH, 0, MONEYTF_WIDTH, MONEYTF_HEIGHT);
    moneyTF.placeholder = @"请输入金额";
    moneyTF.keyboardType = UIKeyboardTypeNumberPad;
    
    nextButton.frame = CGRectMake((SCREEN_WIDTH-NEXTBUTTON_WIDTH)/2, STATUS_HEIGHT+NAVIGATIONBAR_HEIGHT+SAME_HEIGHT*2+PAYLISTTABLEVIEW_HEIGHT+MONEYTF_HEIGHT, NEXTBUTTON_WIDTH, NEXTBUTTON_HEIGHT);
    [nextButton setTitle:@"下一步" forState:UIControlStateNormal];
    nextButton.backgroundColor = UICOLOR;
    nextButton.layer.cornerRadius = CORNERRADIUS;
    [nextButton addTarget:self action:@selector(recharge) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:payListTableView];
    [self.view addSubview:containerView];
    [containerView addSubview:moneyLabel];
    [containerView addSubview:moneyTF];
    [self.view addSubview:nextButton];
}

- (void)NavigationInit {
    self.navigationItem.title = @"钱包充值";
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"返回"] style:UIBarButtonItemStylePlain target:self action:@selector(back)];
    self.navigationItem.leftBarButtonItem = backButton;
}

#pragma mark - Button Event
- (void)back {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)recharge {
    //验证等待动画
    // 集成api  此处是膜
    cover = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    cover.alpha = 1;
    // 半黑膜
    UIView *containerView1 = [[UIView alloc] initWithFrame:CGRectMake(0.3*SCREEN_WIDTH, 0.4*SCREEN_HEIGHT, 0.4*SCREEN_WIDTH, 0.15*SCREEN_HEIGHT)];
    containerView1.backgroundColor = [UIColor blackColor];
    containerView1.alpha = 0.6;
    containerView1.layer.cornerRadius = CORNERRADIUS*2;
    [cover addSubview:containerView1];
    // 两个控件
    UIActivityIndicatorView *waitActivityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    waitActivityView.frame = CGRectMake(0.33*containerView1.frame.size.width, 0.1*containerView1.frame.size.width, 0.33*containerView1.frame.size.width, 0.4*containerView1.frame.size.height);
    [waitActivityView startAnimating];
    [containerView1 addSubview:waitActivityView];
    
    UILabel *hintMes = [[UILabel alloc] initWithFrame:CGRectMake(0, 0.7*containerView1.frame.size.height, containerView1.frame.size.width, 0.2*containerView1.frame.size.height)];
    hintMes.text = @"请稍后...";
    hintMes.textColor = [UIColor whiteColor];
    hintMes.textAlignment = NSTextAlignmentCenter;
    [containerView1 addSubview:hintMes];
    [self.view addSubview:cover];
    
    // 获取缓存数据
    NSString *phoneNumber = [userDefaults objectForKey:@"phoneNumber"];
    NSString *accessToken = [userDefaults objectForKey:@"accessToken"];
    
    // 异步请求服务器
    NSString *urlStr = [IP stringByAppendingString:@"ElephantBike/api/money/recharge"];
    NSURL *url = [NSURL URLWithString:urlStr];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10];
    NSString *dataStr = [NSString stringWithFormat:@"phone=%@&value=%@&access_token=%@", phoneNumber, moneyTF.text, accessToken];
    NSData *data = [dataStr dataUsingEncoding:NSUTF8StringEncoding];
    [request setHTTPBody:data];
    [request setHTTPMethod:@"POST"];
    [NSURLConnection connectionWithRequest:request delegate:self];
}

#pragma mark - 服务器返回
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [cover removeFromSuperview];
    NSDictionary *receiveJson = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
    NSString *status = receiveJson[@"status"];
    NSString *message = receiveJson[@"message"];
    if (status) {
        // 充值成功 跳转我的钱包页面 并且本地的金额加上来
        CGFloat balan = [MyAppDelegate.balance floatValue];
        CGFloat money = [moneyTF.text floatValue];
        balan += money;
        MyAppDelegate.balance = [NSString stringWithFormat:@"%f", balan];
        
        // 充值成功动画再做修改
        cover = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        cover.alpha = 1;
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"充值成功"]];
        imageView.center = cover.center;
        [cover addSubview:imageView];
        [self.view addSubview:cover];
        NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(dismissImageView) userInfo:nil repeats:NO];
        [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
        
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)dismissImageView {
    [cover removeFromSuperview];
}

#pragma mark - TableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"Cell";
    MyTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[MyTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    }
    cell.imageView.image = [UIImage imageNamed:[payWay objectAtIndex:indexPath.row]];
    //设置imaged大小
    CGSize itemSize = CGSizeMake(PAYLISTTABLEVIEW_HEIGHT/2*0.8, PAYLISTTABLEVIEW_HEIGHT/2*0.8);
    UIGraphicsBeginImageContext(itemSize);
    CGRect imageRect = CGRectMake(0.0, 0.0, itemSize.width, itemSize.height);
    [cell.imageView.image drawInRect:imageRect];
    cell.imageView.image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    cell.textLabel.text = [payWay objectAtIndex:indexPath.row];
    cell.detailTextLabel.text = [wayDetails objectAtIndex:indexPath.row];
    if (indexPath.row == 0) {
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"选中"]];
        cell.accessoryView =imageView;
    }else {
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"没选中"]];
        cell.accessoryView = imageView;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    MyTableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    NSArray *array = [tableView visibleCells];
    for (UITableViewCell *cell in array) {
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"没选中"]];
        cell.accessoryView = imageView;
    }
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"选中"]];
    cell.accessoryView =imageView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return PAYLISTTABLEVIEW_HEIGHT/2;
}

#pragma mark - TouchesBegin
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if ([moneyTF isFirstResponder]) {
        [moneyTF resignFirstResponder];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    [self UIInit];
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
