//
//  LoadingView.m
//  ElephantBike
//
//  Created by 黄杰锋 on 16/2/23.
//  Copyright © 2016年 黄杰锋. All rights reserved.
//

#import "LoadingView.h"

@implementation LoadingView {
    UILabel *hintLabel;
    UIActivityIndicatorView *activityView;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.state = @"normal";
        
        hintLabel = [[UILabel alloc] initWithFrame:CGRectMake(frame.size.width*0.4, 0, frame.size.width*0.4, frame.size.height)];
        hintLabel.text = @"上拉查看更多";
        hintLabel.textColor = [UIColor lightGrayColor];
        hintLabel.textAlignment = NSTextAlignmentLeft;
        hintLabel.backgroundColor = [UIColor clearColor];
        
        activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        activityView.frame = CGRectMake(frame.size.width*0.2, 0, frame.size.width*0.2, frame.size.height);
        activityView.backgroundColor = [UIColor clearColor];
        
        [self addSubview:hintLabel];
        [self addSubview:activityView];
    }
    return self;
}

- (void)setRefreshStateNormal {
    hintLabel.text = @"上拉查看更多";
    [activityView stopAnimating];
    self.backgroundColor = [UIColor grayColor];
    hintLabel.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    hintLabel.textAlignment = NSTextAlignmentCenter;
}

- (void)setRefreshStateLoading {
    NSLog(@"加载中");
    hintLabel.text = @"加载中";
    [activityView  startAnimating];
    hintLabel.frame = CGRectMake(self.frame.size.width*0.4, 0, self.frame.size.width*0.4, self.frame.size.height);
    hintLabel.textAlignment = NSTextAlignmentLeft;
    self.backgroundColor = [UIColor grayColor];
}

- (void)setRefreshStateLoose {
    hintLabel.text = @"松手让它加载吧";
    self.backgroundColor = [UIColor grayColor];
    hintLabel.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    hintLabel.textAlignment = NSTextAlignmentCenter;
}

- (void)setRefreshStateNone {
    hintLabel.text = @"您只有这些记录";
    [activityView stopAnimating];
    self.backgroundColor = [UIColor grayColor];
    self.state = @"none";
    hintLabel.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    hintLabel.textAlignment = NSTextAlignmentCenter;
}

- (void)setRefreshStateWhite {
    [activityView stopAnimating];
    hintLabel.text = @"";
    self.backgroundColor = [UIColor whiteColor];
    
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
