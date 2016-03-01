//
//  RecommendViewController.m
//  ElephantBike
//
//  Created by 黄杰锋 on 16/1/20.
//  Copyright © 2016年 黄杰锋. All rights reserved.
//

#import "RecommendViewController.h"
#import "UISize.h"

#define GETMONEYLABEL_WIDTH     0.2*SCREEN_WIDTH
#define GETMONEYLABEL_HEIGHT    0.25*GETMONEYLABEL_WIDTH
#define IMAGEVIEW_WIDTH         0.5*SCREEN_WIDTH
#define IMAGEVIEW_HEIGHT        IMAGEVIEW_WIDTH
#define HINTMES_WIDTH           IMAGEVIEW_WIDTH
#define HINTMES_HEIGHT          0.25*HINTMES_WIDTH
#define SHAREBUTTON_WIDTH       COMMIT_WIDTH
#define SHAREBUTTON_HEIGHT      COMMIT_HEIGHT

@interface RecommendViewController ()

@end

@implementation RecommendViewController {
    UILabel     *getMoneyLabel;
    UIImageView *imageView;
    UILabel     *hintMes;
    UIButton    *shareButton;
}

- (void)UIInit {
    getMoneyLabel   = [[UILabel alloc] init];
    imageView       = [[UIImageView alloc] init];
    hintMes         = [[UILabel alloc] init];
    shareButton     = [[UIButton alloc] init];
    
    [self UILayout];
}

- (void)UILayout {
    getMoneyLabel.frame = CGRectMake(0.95*SCREEN_WIDTH-GETMONEYLABEL_WIDTH, STATUS_HEIGHT+NAVIGATIONBAR_HEIGHT+0.05*SCREEN_WIDTH, GETMONEYLABEL_WIDTH, GETMONEYLABEL_HEIGHT);
    getMoneyLabel.text = @"已获3元";
    getMoneyLabel.layer.borderColor = [UIColor grayColor].CGColor;
    getMoneyLabel.layer.borderWidth = 1;
    getMoneyLabel.layer.cornerRadius = CORNERRADIUS;
    
    imageView.frame = CGRectMake((SCREEN_WIDTH-IMAGEVIEW_WIDTH)/2, (STATUS_HEIGHT+NAVIGATIONBAR_HEIGHT)*2.5, IMAGEVIEW_WIDTH, IMAGEVIEW_HEIGHT);
    imageView.image = [UIImage imageNamed:@"赢取出行基金"];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    
    hintMes.frame = CGRectMake((SCREEN_WIDTH-HINTMES_WIDTH)/2, (STATUS_HEIGHT+NAVIGATIONBAR_HEIGHT)*2.5+IMAGEVIEW_HEIGHT, HINTMES_WIDTH, HINTMES_HEIGHT);
    hintMes.text = @"送给朋友5元出行大礼包\n自己也将获得3元储值奖励";
    hintMes.textAlignment = NSTextAlignmentCenter;
    hintMes.numberOfLines = 0;
    
    shareButton.frame = CGRectMake((SCREEN_WIDTH-SHAREBUTTON_WIDTH)/2, (STATUS_HEIGHT+NAVIGATIONBAR_HEIGHT)*2.5+IMAGEVIEW_HEIGHT+HINTMES_HEIGHT+SAME_HEIGHT, SHAREBUTTON_WIDTH, SHAREBUTTON_HEIGHT);
    [shareButton setTitle:@"分享给微信好友" forState:UIControlStateNormal];
    shareButton.backgroundColor = UICOLOR;
    shareButton.layer.cornerRadius = CORNERRADIUS;
    
    [self.view addSubview:getMoneyLabel];
    [self.view addSubview:imageView];
    [self.view addSubview:hintMes];
    [self.view addSubview:shareButton];
}

- (void)NavigationInit {
    self.navigationItem.title = @"推荐有奖";
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"返回"] style:UIBarButtonItemStylePlain target:self action:@selector(back)];
    self.navigationItem.leftBarButtonItem = backButton;
}

#pragma mark - Button Event
- (void)back {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1.0];
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
