//
//  RecommendController.m
//  ElephantBike
//
//  Created by 黄杰锋 on 16/3/29.
//  Copyright © 2016年 黄杰锋. All rights reserved.
//

#import "RecommendController.h"
#import "UISize.h"


@interface RecommendController ()<UITableViewDelegate, UITableViewDataSource>

@end

@implementation RecommendController{
    UITableView *RecommendTableView;
    UILabel *dateLabel;
}

-(void)UIInit{
    /** 静态的 分组的节头会比较大*/
    RecommendTableView = [[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStylePlain];
    
    
    [self navigationInit];
    /** 解决了头部多出来的空白高度*/
//    self.automaticallyAdjustsScrollViewInsets = NO;
    [self UILayout];
}

-(void)navigationInit{
    self.navigationItem.title = @"活动中心";
    UIBarButtonItem *backBar = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"返回"] style:UIBarButtonItemStylePlain target:self action:@selector(backMenu)];
    self.navigationItem.leftBarButtonItem = backBar;
    backBar.tintColor = [UIColor grayColor];
    //设置导航栏字体
    [self.navigationController.navigationBar setTitleTextAttributes:
     @{NSFontAttributeName:[UIFont fontWithName:@"QingYuanMono" size:18],
       NSForegroundColorAttributeName:[UIColor blackColor]}];
    
}


-(void)UILayout{
    /** 留出导航栏的高度*/
    RecommendTableView .frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
//    RecommendTableView .center = CGPointMake(0.5*SCREEN_WIDTH, 0.5*SCREEN_HEIGHT);
    self.view.backgroundColor = [UIColor colorWithRed:240.0/255 green:240.0/255 blue:240.0/255 alpha:1];
    RecommendTableView .dataSource = self;
    RecommendTableView .delegate = self;
    RecommendTableView .scrollEnabled = YES;

    
    [self.view addSubview:RecommendTableView];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self UIInit];
    [self UILayout];

}

#pragma mark - 返回方法
-(void)backMenu{
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark - tableViewDelegate
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 10;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identity = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identity];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identity];
    }
    cell.textLabel.text = @"推荐有奖";
    
//    cell.textLabel.text = listArray[indexPath.section];
    cell.textLabel.font = [UIFont fontWithName:@"QingYuanMono" size:15];
    cell.textLabel.text = @"推荐有奖";
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}


#pragma Mark - 分区高度的设置
//设置分区头的高度
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
//    if (section == 0) {
//        return 12;
//    }
    return 20;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(nonnull NSIndexPath *)indexPath{
    return (0.50*SCREEN_HEIGHT-24)/4;
}

/** 节头的标题*/
-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{

    return @"2016-04-11";
}
/** 节头的视图*/
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    CGFloat sectionHeight = [self tableView:RecommendTableView heightForHeaderInSection:section];
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, sectionHeight)];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, sectionHeight)];
    label.font = [UIFont fontWithName:@"QingYuanMono" size:12];
    label.backgroundColor = [UIColor colorWithRed:240.0/255 green:240.0/255 blue:240.0/255 alpha:1];
    label.textColor = [UIColor colorWithRed:122.0/255 green:121.0/255 blue:121.0/255 alpha:1];
    
    NSString *sectionTitle = [self tableView:RecommendTableView titleForHeaderInSection:section];
    label.text = sectionTitle;
    label.textAlignment = NSTextAlignmentCenter;
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
