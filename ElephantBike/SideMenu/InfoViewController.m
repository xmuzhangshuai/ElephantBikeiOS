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
#import "RecommendViewController.h"
#import "HelpViewController.h"
#import "AppDelegate.h"


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

@interface InfoViewController () <UITableViewDataSource, UITableViewDelegate>

@end

@implementation InfoViewController{
//    UIImageView *avatarImage;
    UILabel     *nameLabel;
    UILabel     *identificationLabel;
    UITableView *infoTableView;
    UIImageView *logoImageView;
    
    NSArray     *listArray;
    
    AppDelegate *myAppDelegate;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super init]) {
        self.view.frame = frame;
        nameLabel               = [[UILabel alloc] init];
        myAppDelegate           = [[UIApplication sharedApplication] delegate];
        NSLog(@"isupload:%d",myAppDelegate.isUpload);
        if (myAppDelegate.isIdentify) {
            nameLabel.text = @"姓名";
        }else if (myAppDelegate.isUpload) {
            nameLabel.text = @"未认证";
        }else {
            nameLabel.text = @"请登录";
        }
    }
    return self;
}

- (id)init {
    if (self = [super init]) {
        nameLabel               = [[UILabel alloc] init];
        myAppDelegate           = [[UIApplication sharedApplication] delegate];
        if (myAppDelegate.isIdentify) {
            nameLabel.text = @"姓名";
        }else if (myAppDelegate.isUpload) {
            nameLabel.text = @"未认证";
        }else {
            nameLabel.text = @"请登录";
        }
    }
    return self;
}

#pragma mark - UIInit
- (void)UIInit {
//    avatarImage             = [[UIImageView alloc] init];

    identificationLabel     = [[UILabel alloc] init];
    infoTableView           = [[UITableView alloc] init];
    logoImageView           = [[UIImageView alloc] init];
    

    
    listArray               = @[@"我的钱包", @"身份认证", @"推荐有奖", @"帮助"];
    
    [self NavigationInit];
    [self UILayout];
}

- (void)NavigationInit {

}

- (void)UILayout {
//    avatarImage.frame = CGRectMake(0.05*SCREEN_WIDTH, STATUS_HEIGHT*2, AVATARIMAGE_WIDTH, AVATARIMAGE_HEIGHT);
//    avatarImage.image = [UIImage imageNamed:@"头像"];
    /* 将方形图片剪裁成圆的
    avatarImage.layer.masksToBounds = YES;
    avatarImage.layer.cornerRadius = 50;
    */
    
    nameLabel.frame = CGRectMake(0.05*SCREEN_WIDTH, STATUS_HEIGHT*2, NAMELABEL_WIDTH, NAMELABEL_HEIGHT);
    nameLabel.textAlignment = NSTextAlignmentLeft;
    
    identificationLabel.frame = CGRectMake(0.05*SCREEN_WIDTH, STATUS_HEIGHT*2+NAMELABEL_HEIGHT, IDENTIFICATIONLABEL_WIDTH, IDENTIFICATIONLABEL_HEIGHT);
    identificationLabel.clipsToBounds = YES;
    identificationLabel.layer.cornerRadius = CORNERRADIUS*2;
    identificationLabel.backgroundColor = UICOLOR;
    identificationLabel.text = @"  ☑已认证:xxxxxx";
    identificationLabel.font = [UIFont systemFontOfSize:12];
    identificationLabel.textAlignment = NSTextAlignmentLeft;
    
    infoTableView.frame = CGRectMake(0, 0.33*SCREEN_HEIGHT, INFOTABLEVIEW_WIDTH, INFOTABLEVIEW_HEIGHT);
    infoTableView.dataSource = self;
    infoTableView.delegate = self;
    infoTableView.scrollEnabled = NO;
    
    logoImageView.frame = CGRectMake((SCREEN_WIDTH*0.8-LOGOTABLEVIEW_WIDTH)/2, SCREEN_HEIGHT-LOGOTABLEVIEW_HEIGHT, LOGOTABLEVIEW_WIDTH, LOGOTABLEVIEW_HEIGHT);
    logoImageView.image = [UIImage imageNamed:@"Logo"];
    logoImageView.contentMode = UIViewContentModeScaleAspectFit;
    
//    [self.view addSubview:avatarImage];
    [self.view addSubview:nameLabel];
    [self.view addSubview:identificationLabel];
    [self.view addSubview:infoTableView];
    [self.view addSubview:logoImageView];
}

#pragma mark - TableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
    }
    cell.textLabel.text = [listArray objectAtIndex:indexPath.row];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if (indexPath.row == 0) {
        NSString *str = [@"余额:" stringByAppendingString:myAppDelegate.balance];
        NSString *str1 = [str stringByAppendingString:@"元"];
        cell.detailTextLabel.text = str1;
    }
    if (indexPath.row == 2) {
        cell.detailTextLabel.text = @"享用车优惠";
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return  INFOTABLEVIEW_HEIGHT/4;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.row) {
        case 0:{
            MyWalletViewController *myWalletViewController = [[MyWalletViewController alloc] init];
            [self.delegate getNextViewController:myWalletViewController];
        }
            break;
        case 1:{
            IdentificationViewController *identificationViewController = [[IdentificationViewController alloc] init];
            [self.delegate getNextViewController:identificationViewController];
        }
            break;
        case 2:{
            RecommendViewController *recommendViewController = [[RecommendViewController alloc] init];
            [self.delegate getNextViewController:recommendViewController];
        }
            break;
        case 3:{
            HelpViewController *helpViewController = [[HelpViewController alloc] init];
            [self.delegate getNextViewController:helpViewController];
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
