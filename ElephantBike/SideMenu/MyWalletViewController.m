//
//  MyWalletViewController.m
//  ElephantBike
//
//  Created by 黄杰锋 on 16/1/20.
//  Copyright © 2016年 黄杰锋. All rights reserved.
//

#import "MyWalletViewController.h"
#import "UISize.h"
#import "RechargeViewController.h"
#import "AppDelegate.h"
#import "LoadingView.h"

#define BALANCEIMAGEVIEW_WIDTH  0.25*SCREEN_WIDTH
#define BALANCEIMAGEVIEW_HEIGHT BALANCEIMAGEVIEW_WIDTH
#define BALANCELABEL_WIDTH      0.8*BALANCEIMAGEVIEW_WIDTH
#define BALANCELABEL_HEIGHT     0.33*BALANCEIMAGEVIEW_HEIGHT
#define HINTMES_WIDTH           0.55*SCREEN_WIDTH
#define HINTMES_HEIGHT          SAME_HEIGHT
#define RECHARGEBUTTON_WIDTH    0.4*HINTMES_WIDTH
#define RECHARGEBUTTON_HEIGHT   SAME_HEIGHT
#define BALANCEDETAILSLABEL_WIDTH   0.9*SCREEN_WIDTH
#define BALANCEDETAILSLABEL_HEIGHT  SAME_HEIGHT
#define DETAILSTABLEVIEW_WIDTH  0.9*SCREEN_WIDTH
#define DETAILSTABLEVIEW_HEIGHT 0.5*SCREEN_HEIGHT

@interface MyWalletViewController () <UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate, NSURLConnectionDataDelegate>

@end

@implementation MyWalletViewController {
    UIImageView *balanceImageView;
    UILabel     *balanceLabel;
    UILabel     *hintMes;
    UIButton    *rechargeButton;
    UILabel     *balanceDetailsLabel;
    UITableView *detailsTableView;
    AppDelegate *myAppDelegate;
    
    NSMutableArray *dataArray;  // 存放从服务器返回来的余额明细
    NSUserDefaults *userDefaults;
    CGFloat     cellHeight;
    int         page;
    LoadingView     *footView;
    BOOL        isNone;    // 判断是否还有余额明细的数据
}

- (void)UIInit {
    balanceImageView    = [[UIImageView alloc] init];
    balanceLabel        = [[UILabel alloc] init];
    hintMes             = [[UILabel alloc] init];
    rechargeButton      = [[UIButton alloc] init];
    balanceDetailsLabel = [[ UILabel alloc] init];
    detailsTableView    = [[UITableView alloc] init];
    myAppDelegate       = [[UIApplication sharedApplication] delegate];
    dataArray           = [[NSMutableArray alloc] init];
    userDefaults        = [NSUserDefaults standardUserDefaults];
    page                = 0;
    isNone              = NO;
    
    [self UILayout];
    [self NavigationInit];
}

- (void)EventInit {
    [self requestForData];
}

- (void)UILayout {
    balanceImageView.frame = CGRectMake((SCREEN_WIDTH-BALANCEIMAGEVIEW_WIDTH)/2, STATUS_HEIGHT*2+NAVIGATIONBAR_HEIGHT, BALANCEIMAGEVIEW_WIDTH, BALANCEIMAGEVIEW_HEIGHT);
    balanceImageView.image = [UIImage imageNamed:@"余额"];
    balanceImageView.contentMode = UIViewContentModeScaleAspectFit;
    
    balanceLabel.frame = CGRectMake((BALANCEIMAGEVIEW_WIDTH-BALANCELABEL_WIDTH)/2, 0.5*BALANCEIMAGEVIEW_HEIGHT, BALANCELABEL_WIDTH, BALANCELABEL_HEIGHT);
    balanceLabel.text = myAppDelegate.balance;
    balanceLabel.textAlignment = NSTextAlignmentCenter;
    balanceLabel.font = [UIFont systemFontOfSize:25];
    balanceLabel.textColor = [UIColor whiteColor];
    
    hintMes.frame = CGRectMake((SCREEN_WIDTH-HINTMES_WIDTH-RECHARGEBUTTON_WIDTH)/2, STATUS_HEIGHT*2+NAVIGATIONBAR_HEIGHT+BALANCEIMAGEVIEW_HEIGHT, HINTMES_WIDTH, HINTMES_HEIGHT);
    hintMes.text = @"使用大象钱包免密码快捷支付，";
    hintMes.textAlignment = NSTextAlignmentRight;
    hintMes.font = [UIFont systemFontOfSize:12];
    
    rechargeButton.frame = CGRectMake((SCREEN_WIDTH-HINTMES_WIDTH-RECHARGEBUTTON_WIDTH)/2+HINTMES_WIDTH, STATUS_HEIGHT*2+NAVIGATIONBAR_HEIGHT+BALANCEIMAGEVIEW_HEIGHT, RECHARGEBUTTON_WIDTH, RECHARGEBUTTON_HEIGHT);
    rechargeButton.titleLabel.textColor = UICOLOR;
    rechargeButton.titleLabel.textAlignment = NSTextAlignmentLeft;
    NSMutableAttributedString *title = [[NSMutableAttributedString alloc] initWithString:@"立即充值>"];
    NSRange titleRnage = {0, [title length]};
    [title addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle] range:titleRnage];
    [rechargeButton setAttributedTitle:title forState:UIControlStateNormal];
    rechargeButton.titleLabel.font = [UIFont systemFontOfSize:12];
    [rechargeButton addTarget:self action:@selector(RechargeView) forControlEvents:UIControlEventTouchUpInside];
    
    balanceDetailsLabel.frame = CGRectMake(0.05*SCREEN_WIDTH, STATUS_HEIGHT*3+NAVIGATIONBAR_HEIGHT+BALANCEIMAGEVIEW_HEIGHT+RECHARGEBUTTON_HEIGHT, BALANCEDETAILSLABEL_WIDTH, BALANCEDETAILSLABEL_HEIGHT);
    balanceDetailsLabel.text = @"—————————— 余额明细 ——————————";
    balanceDetailsLabel.textAlignment = NSTextAlignmentCenter;
    balanceDetailsLabel.font = [UIFont systemFontOfSize:12];
    if (SCREEN_WIDTH == 320) {
        balanceDetailsLabel.text = @"————————— 余额明细 —————————";
    }
    
    
    detailsTableView.frame = CGRectMake(0.05*SCREEN_WIDTH, STATUS_HEIGHT*3+NAVIGATIONBAR_HEIGHT+BALANCEIMAGEVIEW_HEIGHT+RECHARGEBUTTON_HEIGHT+BALANCEDETAILSLABEL_HEIGHT, DETAILSTABLEVIEW_WIDTH, DETAILSTABLEVIEW_HEIGHT);
    detailsTableView.dataSource = self;
    detailsTableView.delegate = self;
    
    footView = [[LoadingView alloc] initWithFrame:CGRectMake(0, 0, DETAILSTABLEVIEW_WIDTH, 50)];
    footView.backgroundColor = [UIColor grayColor];
    [footView setRefreshStateNone];
    if (dataArray.count > 0) {
        [footView setRefreshStateNormal];
    }
    detailsTableView.tableFooterView = footView;
    
    
    // 列表的位置添加一个等待菊花动画 把列表的加载放到服务器返回里面
    
    [self.view addSubview:balanceImageView];
    [balanceImageView addSubview:balanceLabel];
    [self.view addSubview:hintMes];
    [self.view addSubview:rechargeButton];
    [self.view addSubview:balanceDetailsLabel];
    [self.view addSubview:detailsTableView];
}

- (void)NavigationInit {
    self.navigationItem.title = @"我的钱包";
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"返回"] style:UIBarButtonItemStylePlain target:self action:@selector(back)];
    self.navigationItem.leftBarButtonItem = backButton;
}

#pragma mark - TableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
    }
    cell.textLabel.text = @"\n";
    cell.textLabel.numberOfLines = 0;
    cell.detailTextLabel.text = @"\nmoney";
    cell.detailTextLabel.textAlignment = NSTextAlignmentRight;
    cell.detailTextLabel.numberOfLines = 0;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cellHeight = cell.frame.size.height;
    return cell;
    /*****************
     解析服务器传回来的余额数据 赋给cell
     ********************/
}

#pragma mark - UIScrollDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView.contentOffset.y >= dataArray.count*cellHeight-DETAILSTABLEVIEW_HEIGHT+50){
        // 需要更多的数据
        if (dataArray.count >= 10 && isNone == NO) {
            [footView setRefreshStateLoose];
        }
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerat {
    if (scrollView.contentOffset.y <= dataArray.count*cellHeight-DETAILSTABLEVIEW_HEIGHT+50 && scrollView.contentOffset.y >= dataArray.count*cellHeight-DETAILSTABLEVIEW_HEIGHT+40) {
        if (dataArray.count >= 10 && isNone == NO) {
            [footView setRefreshStateLoading];
            NSLog(@"请求新数据");
            [self requestForData];
        }
        
    }
}

#pragma mark - 服务器请求
- (void)requestForData {
    NSString *phoneNumber = [userDefaults objectForKey:@"phoneNumber"];
    // 请求服务器 异步post
    NSString *urlStr = [IP stringByAppendingString:@"/ElephantBike/api/money/balancelist"];
    NSURL *url = [NSURL URLWithString:urlStr];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    NSString *dataStr = [NSString stringWithFormat:@"phone=%@&count=%d", phoneNumber, page];
    NSLog(@"%@", phoneNumber);
    NSData *data = [dataStr dataUsingEncoding:NSUTF8StringEncoding];
    [request setHTTPBody:data];
    [request setHTTPMethod:@"POST"];
    NSURLConnection *connection = [NSURLConnection connectionWithRequest:request delegate:self];
}

#pragma mark - 服务器返回数据
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    NSDictionary *receiveData = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
    NSString *status = receiveData[@"status"];
    if (status) {
        isNone = NO;
        if (page == 0) {
            dataArray = receiveData[@"data"];
            page++;
        }else {
            NSArray *array = receiveData[@"data"];
            [dataArray arrayByAddingObjectsFromArray:array];
        }
        [detailsTableView reloadData];
    }else {
        isNone = YES;
        [footView setRefreshStateNone];
    }
}

#pragma mark - Button Event
- (void)RechargeView {
    RechargeViewController *rechargeViewController = [[RechargeViewController alloc] init];
    [self.navigationController pushViewController:rechargeViewController animated:YES];
}

- (void)back {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    [self UIInit];
    [self EventInit];
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
