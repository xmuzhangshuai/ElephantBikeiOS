//
//  RecommendTableViewCell.m
//  ElephantBike
//
//  Created by king_hm on 16/4/15.
//  Copyright © 2016年 黄杰锋. All rights reserved.
//

#import "RecommendTableViewCell.h"
//#import "RecommendCellFrame.h"
#import "UISize.h"


#define RECOMMENDNAMELABEL_HEIGHT 32
#define RECOMMENDNAMELABEL_WIDTH 0.866*SCREEN_WIDTH



@interface RecommendTableViewCell()

@end

@implementation RecommendTableViewCell

+(instancetype)cellWithTableView:(UITableView *)tableView{
    static NSString *identify = @"RecommendTableViewCell";
    RecommendTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
    if (cell == nil) {
        
        cell = [[RecommendTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identify];
    }
    return cell;
}
/** 添加控件到视图中*/
-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.RecommendNameLabel = [[UILabel alloc] init];
        [self.contentView addSubview:self.RecommendNameLabel];
        /** 以cell为父视图*/
        self.RecommendNameLabel.frame = CGRectMake(10, 0, RECOMMENDNAMELABEL_WIDTH, RECOMMENDNAMELABEL_HEIGHT);
        self.RecommendNameLabel.font = [UIFont fontWithName:@"QingYuanMono" size:15];

        self.RecommendLineView = [[UIView alloc] init];
        [self.contentView addSubview: self.RecommendLineView];
        self.RecommendLineView.frame = CGRectMake(10, RECOMMENDNAMELABEL_HEIGHT, RECOMMENDNAMELABEL_WIDTH-20, 1);
        self.RecommendLineView.backgroundColor = [UIColor colorWithRed:166.0/255 green:147.0/255 blue:124.0/255 alpha:1];
        
        self.RecommendDateLabel = [[UILabel alloc] init];
        [self.contentView addSubview:self.RecommendDateLabel];
        self.RecommendDateLabel.frame = CGRectMake(10, RECOMMENDNAMELABEL_HEIGHT+11, RECOMMENDNAMELABEL_WIDTH, RECOMMENDNAMELABEL_HEIGHT);
        self.RecommendDateLabel.font = [UIFont fontWithName:@"QingYuanMono" size:13];
        self.RecommendDateLabel.tintColor = [UIColor colorWithRed:80.0/255 green:79.0/255 blue:79.0/255 alpha:1];
        

        self.RecommendDetailLabel = [[UILabel alloc] init];
        [self.contentView addSubview:self.RecommendDetailLabel];
        self.RecommendDetailLabel.numberOfLines = 0;
        self.RecommendDetailLabel.font = [UIFont fontWithName:@"QingYuanMono" size:13];
        self.RecommendDetailLabel.tintColor = [UIColor colorWithRed:80.0/255 green:79.0/255 blue:79.0/255 alpha:1];
//        NSLog(@"self.contentStr:......%@", self.contentStr);
//        NSLog(@"text:.....%@", self.RecommendDetailLabel.text);
//        CGSize size = [self getLabelSizeWithLabel:self.RecommendDetailLabel andLineSpacing:2 andText:self.contentStr];
//        NSLog(@"size:.....%f", size.height);
        self.RecommendDetailLabel.frame = CGRectMake(10, self.RecommendDateLabel.frame.origin.y+RECOMMENDNAMELABEL_HEIGHT+10, RECOMMENDNAMELABEL_WIDTH-20, CGSizeZero.height);
        
//        self.cellHeight = RECOMMENDNAMELABEL_HEIGHT+self.RecommendLineView.bounds.size.height+self.RecommendDateLabel.bounds.size.height+size.height;
        NSLog(@"self.cellHeight:......%f", self.cellHeight);
    }
    return self;
}
-(void)setContentStr:(NSString *)contentStr{
    _contentStr = contentStr;
    CGSize size = [self getLabelSizeWithLabel:self.RecommendDetailLabel andLineSpacing:5 andText:contentStr];
    self.RecommendDetailLabel.frame = CGRectMake(10, self.RecommendDateLabel.frame.origin.y+RECOMMENDNAMELABEL_HEIGHT+10, RECOMMENDNAMELABEL_WIDTH-20, size.height);
    self.cellHeight = RECOMMENDNAMELABEL_HEIGHT+self.RecommendLineView.bounds.size.height+self.RecommendDateLabel.bounds.size.height+size.height+35;
    NSLog(@"self.cellHeight:......%f", self.cellHeight);
    NSLog(@"contentStr:.....%@", self.contentStr);
}



-(CGSize)getLabelSizeWithLabel:(UILabel *)label andLineSpacing:(CGFloat)lineSpacing andText:(NSString *)text{
    label.numberOfLines = 0;
    CGFloat oneRowHeight = [text sizeWithAttributes:@{NSFontAttributeName:[UIFont fontWithName:@"QingYuanMono" size:13]}].height;
    CGSize textSize = [text boundingRectWithSize:CGSizeMake(RECOMMENDNAMELABEL_WIDTH, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin |NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:[UIFont fontWithName:@"QingYuanMono" size:13]} context:nil].size;
    NSLog(@"lineSpacing:.......%f", lineSpacing);
    
    NSMutableAttributedString * attributedString1 = [[NSMutableAttributedString alloc] initWithString:text];
    NSMutableParagraphStyle * paragraphStyle = [[NSMutableParagraphStyle alloc] init];
//    paragraphStyle.alignment = NSTextAlignmentJustified;
    [paragraphStyle setLineSpacing:lineSpacing];
    [attributedString1 addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [text length])];
    
    CGFloat rows = textSize.height / oneRowHeight;
    CGFloat realHeight = oneRowHeight;
    if (rows > 1) {
        realHeight = (rows * oneRowHeight) + (rows - 1) * lineSpacing;
    }
    [label setAttributedText:attributedString1];
//    * 返回该label的长宽
    return CGSizeMake(textSize.width, realHeight);
//    NSDictionary *dict = @{NSFontAttributeName : [UIFont fontWithName:@"QingYuanMono" size:13]};
//    // 如果将来计算的文字的范围超出了指定的范围,返回的就是指定的范围
//     // 如果将来计算的文字的范围小于指定的范围, 返回的就是真实的范围
//     CGSize size =  [text boundingRectWithSize:CGSizeMake(RECOMMENDNAMELABEL_WIDTH, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:dict context:nil].size;
//     return size;
    
    
}




///** 直接在cell当中布局就可以，再写一个frame太麻烦*/
///** 重写RecommendCellFrame的setter方法*/
//-(void)setRecommendCellFrame:(RecommendCellFrame *)RecommendCellFrame{
//    
//    _RecommendCellFrame = self.RecommendCellFrame;
//    
//    
//    
//    [self settingFrame];
//
//}
//
//
//-(void)settingFrame{
//    self.RecommendNameLabel.frame = self.RecommendCellFrame.RecommendNameFrame;
//    self.RecommendLineView.frame = self.RecommendCellFrame.RecommendViewFrame;
//    self.RecommendDateLabel.frame = self.RecommendCellFrame.RecommendDateFrame;
//    self.RecommendDetailLabel.frame = self.RecommendCellFrame.RecommendViewFrame;
//}
//

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
