//
//  RecommendTableViewCell.h
//  ElephantBike
//
//  Created by king_hm on 16/4/15.
//  Copyright © 2016年 黄杰锋. All rights reserved.
//

#import <UIKit/UIKit.h>

//@class RecommendCellFrame;

@interface RecommendTableViewCell : UITableViewCell

/** 设置cell视图上的布局 位置*/
//@property (nonatomic, strong)RecommendCellFrame *RecommendCellFrame;

/** 设置消息的名称*/
@property (nonatomic, strong)UILabel *RecommendNameLabel;
/** 设置分割线*/
@property (nonatomic, strong)UIView *RecommendLineView;
/** 设置消息日期*/
@property (nonatomic, strong)UILabel *RecommendDateLabel;
/** 设置消息内容*/
@property (nonatomic, strong)UILabel *RecommendDetailLabel;


/** 设置返回cell高度的属性*/
@property (nonatomic, assign)CGFloat cellHeight;

/** 增加一个接受数据的属性 消息内容*/
@property (nonatomic, strong) NSString *contentStr;

+(instancetype)cellWithTableView:(UITableView *)tableView;

@end
