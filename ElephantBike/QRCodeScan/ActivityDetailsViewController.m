//
//  ActivityDetailsViewController.m
//  ElephantBike
//
//  Created by 黄杰锋 on 16/3/9.
//  Copyright © 2016年 黄杰锋. All rights reserved.
//

#import "ActivityDetailsViewController.h"
#import "UISize.h"
#import "AppDelegate.h"

@interface ActivityDetailsViewController () <UIWebViewDelegate>

@end

@implementation ActivityDetailsViewController {
    UIWebView *webView;
    AppDelegate *myAppDelegate;
    UIView      *waitCover;
}

- (id)init {
    if (self = [super init]) {
        webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
        myAppDelegate = [[UIApplication sharedApplication] delegate];
    }
    return self;
}

#pragma mark - uiwebviewdelegate
- (void)webViewDidStartLoad:(UIWebView *)webView {
//    // 菊花等待动画
//    // 集成api  此处是膜
//    waitCover = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
//    waitCover.alpha = 1;
//    // 半黑膜
//    UIView *containerView = [[UIView alloc] initWithFrame:CGRectMake(0.3*SCREEN_WIDTH, 0.4*SCREEN_HEIGHT, 0.4*SCREEN_WIDTH, 0.15*SCREEN_HEIGHT)];
//    containerView.backgroundColor = [UIColor blackColor];
//    containerView.alpha = 0.8;
//    containerView.layer.cornerRadius = CORNERRADIUS*2;
//    [waitCover addSubview:containerView];
//    // 两个控件
//    UIActivityIndicatorView *waitActivityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
//    waitActivityView.frame = CGRectMake(0.33*containerView.frame.size.width, 0.1*containerView.frame.size.width, 0.33*containerView.frame.size.width, 0.4*containerView.frame.size.height);
//    [waitActivityView startAnimating];
//    [containerView addSubview:waitActivityView];
//    
//    UILabel *hintMes = [[UILabel alloc] initWithFrame:CGRectMake(0, 0.7*containerView.frame.size.height, containerView.frame.size.width, 0.2*containerView.frame.size.height)];
//    hintMes.text = @"请稍后...";
//    hintMes.textColor = [UIColor whiteColor];
//    hintMes.textAlignment = NSTextAlignmentCenter;
//    [containerView addSubview:hintMes];
//    [self.view addSubview:waitCover];
//    [self.view addSubview:containerView];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
//    [waitCover removeFromSuperview];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    [waitCover removeFromSuperview];
    NSLog(@"网络请求失败");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    webView.dataDetectorTypes = UIDataDetectorTypeAll;
    webView.delegate = self ;
    NSURL *url;
    if (myAppDelegate.ad == 1) {
        url = [NSURL URLWithString:myAppDelegate.linkUrlShouYe];
    }else if(myAppDelegate.ad == 2){
        url = [NSURL URLWithString:myAppDelegate.linkUrlInfo];
    }else if(myAppDelegate.ad == 3){
        url = [NSURL URLWithString:myAppDelegate.linkUrlCharge];
    }
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [webView loadRequest:request];
    [self.view addSubview:webView];
    // Do any additional setup after loading the view.
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
