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
}

- (void)setRefreshStateLoading {
    hintLabel.text = @"加载中...";
    [activityView  startAnimating];
}

- (void)setRefreshStateLoose {
    hintLabel.text = @"松手让它加载吧";
}

- (void)setRefreshStateNone {
    hintLabel.text = @"您只有这些记录";
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
