//
//  MeetQuestionViewController.m
//  ElephantBike
//
//  Created by 黄杰锋 on 16/3/28.
//  Copyright © 2016年 黄杰锋. All rights reserved.
//

#import "MeetQuestionViewController.h"
#import "UISize.h"
#import "QuestionDetailViewController.h"


@interface MeetQuestionViewController ()<UITableViewDataSource, UITableViewDelegate>

@end

@implementation MeetQuestionViewController{
    UITableView *QuestionTableView;
    UIButton *nextButton;
    NSMutableArray *listArray;
    
}

-(id)init{
    if (self = [super init]) {
        listArray = [[NSMutableArray alloc] initWithObjects:@"输入密码后无法开锁",@"在计费期间单车丢失", @"锁车后不显示还车密码或还车密码错误", @"不影响还车的损坏问题", nil];
    }
    return self;
}

-(void)NavigationInit{
    self.navigationItem.title = @"遇到问题";
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"返回"] style:UIBarButtonItemStylePlain target:self action:@selector(backMainView)];
    backButton.tintColor = [UIColor grayColor];
    self.navigationItem.leftBarButtonItem = backButton;
    [self.navigationController.navigationBar setTitleTextAttributes:
     @{NSFontAttributeName:[UIFont fontWithName:@"QingYuanMono" size:18],
       NSForegroundColorAttributeName:[UIColor blackColor]}];
}

-(void)UIInit{
    QuestionTableView = [[UITableView alloc] init];
    /** 解决了头部多出来的空白高度*/
    self.automaticallyAdjustsScrollViewInsets = NO;
    nextButton = [[UIButton alloc] init];
    [self UILayout];
    
}

-(void)UILayout{
//    QuestionTableView.frame = CGRectMake(0.049*SCREEN_WIDTH, 0.13*SCREEN_HEIGHT, 0.907*SCREEN_WIDTH, 0.517*SCREEN_HEIGHT);
    QuestionTableView.frame = CGRectMake(0.043*SCREEN_WIDTH, 0.13*SCREEN_HEIGHT, 0.91*SCREEN_WIDTH, 0.341*SCREEN_HEIGHT);
//    QuestionTableView.center = CGPointMake(0.5*SCREEN_WIDTH, 0.39*SCREEN_HEIGHT);
    self.view.backgroundColor = [UIColor colorWithRed:240.0/255 green:240.0/255 blue:240.0/255 alpha:1];
    QuestionTableView.dataSource = self;
    QuestionTableView.delegate = self;
    QuestionTableView.scrollEnabled = NO;
    
    nextButton.frame = CGRectMake(0, 0, 0.8*SCREEN_WIDTH, 0.06*SCREEN_HEIGHT);
    nextButton.center = CGPointMake(0.50*SCREEN_WIDTH, 0.95*SCREEN_HEIGHT);
    [nextButton setTitle:@"下一步" forState:UIControlStateNormal];
    nextButton.titleLabel.font = [UIFont fontWithName:@"QingYuanMono" size:15];
    nextButton.backgroundColor = [UIColor colorWithRed:112.0/255 green:177.0/255 blue:52.0/255 alpha:1];
    
    nextButton.layer.masksToBounds = YES;
    nextButton.layer.cornerRadius = 6;
    //确认开通/会员续费的点击事件
    [nextButton addTarget:self action:@selector(nextView) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:nextButton];
    [self.view addSubview:QuestionTableView];
}

#pragma mark - TableView方法
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 4;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentify = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentify];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentify];
    }
    cell.textLabel.text = listArray[indexPath.section];
    cell.textLabel.font = [UIFont fontWithName:@"QingYuanMono" size:15];
    cell.textLabel.textAlignment = NSTextAlignmentCenter;
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.layer.borderWidth = 3;
    cell.layer.borderColor = [UIColor colorWithRed:112.0/255 green:177.0/255 blue:52.0/255 alpha:1].CGColor;
    cell.contentView.backgroundColor = [UIColor colorWithRed:255.0/255 green:255.0/255 blue:255.0/255 alpha:1];
    
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
//    return (0.50*SCREEN_HEIGHT-24)/4;
    return 0.075*SCREEN_HEIGHT;
}



#pragma mark - nextButton方法
-(void)nextView{
    QuestionDetailViewController *questionDetail = [[QuestionDetailViewController alloc] init];
    NSIndexPath *indexPath = [QuestionTableView indexPathForSelectedRow];
    UITableViewCell *cell = [QuestionTableView cellForRowAtIndexPath:indexPath];
    questionDetail.QuestionName = cell.textLabel.text;
    [self.navigationController pushViewController:questionDetail animated:YES];
}
#pragma mark - backMainView方法
-(void)backMainView{
    [self.navigationController popViewControllerAnimated:YES];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    [self NavigationInit];
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
