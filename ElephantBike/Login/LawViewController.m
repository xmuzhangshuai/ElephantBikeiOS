//
//  LawViewController.m
//  ElephantBike
//
//  Created by 黄杰锋 on 16/2/2.
//  Copyright © 2016年 黄杰锋. All rights reserved.
//

#import "LawViewController.h"
#import "UISize.h"

@interface LawViewController () <UIWebViewDelegate>

@end

@implementation LawViewController {
    UIWebView *webView;
    UIView      *waitCover;
}

- (void)UIInit {
    webView = [[UIWebView alloc] init];
    
    [self UILayout];
    [self NavigationInit];
}

- (void)UILayout {
    webView.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    //    webView.backgroundColor = [UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1.0];
    webView.dataDetectorTypes = UIDataDetectorTypeAll;
    webView.delegate = self;
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://www.baidu.com"]];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [webView loadRequest:request];
    
    [self.view addSubview:webView];
}

- (void)NavigationInit {
    self.navigationItem.title = @"用户须知";
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"返回"] style:UIBarButtonItemStylePlain target:self action:@selector(back)];
    backButton.tintColor = [UIColor grayColor];
    [self.navigationController.navigationBar setTitleTextAttributes:
     @{NSFontAttributeName:[UIFont fontWithName:@"QingYuanMono" size:18],
       NSForegroundColorAttributeName:[UIColor blackColor]}];
    self.navigationItem.leftBarButtonItem = backButton;
}

#pragma mark - Button Event
- (void)back {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - uiwebviewdelegate
- (void)webViewDidStartLoad:(UIWebView *)webView {
    // 菊花等待动画
    // 集成api  此处是膜
    waitCover = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    waitCover.alpha = 1;
    // 半黑膜
    UIView *containerView = [[UIView alloc] initWithFrame:CGRectMake(0.3*SCREEN_WIDTH, 0.4*SCREEN_HEIGHT, 0.4*SCREEN_WIDTH, 0.15*SCREEN_HEIGHT)];
    containerView.backgroundColor = [UIColor blackColor];
    containerView.alpha = 0.8;
    containerView.layer.cornerRadius = CORNERRADIUS*2;
    [waitCover addSubview:containerView];
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
    [self.view addSubview:waitCover];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [waitCover removeFromSuperview];
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
