//
//  OpenMemberViewController.h
//  ElephantBike
//
//  Created by 黄杰锋 on 16/3/24.
//  Copyright © 2016年 黄杰锋. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol OpenMemberDelegate <NSObject>

- (void)getMonth:(NSString *)month;

@end

@interface OpenMemberViewController : UIViewController

@property (nonatomic, strong)IBOutlet UITableViewCell *customCell;
//button的文字传递过来，确定是开通会员还是会员续费
@property (nonatomic, strong)NSString *MemberStatus;

@property (nonatomic, weak) id<OpenMemberDelegate> delegate;
@end
