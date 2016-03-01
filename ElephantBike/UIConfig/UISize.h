//
//  UISize.h
//  ElephantBike
//
//  Created by 黄杰锋 on 16/1/15.
//  Copyright © 2016年 黄杰锋. All rights reserved.
//

#ifndef UISize_h
#define UISize_h

#define SCREEN_WIDTH            [[UIScreen mainScreen] bounds].size.width
#define SCREEN_HEIGHT           [[UIScreen mainScreen] bounds].size.height
#define STATUS_HEIGHT           20
#define NAVIGATIONBAR_HEIGHT    self.navigationController.navigationBar.frame.size.height
#define SAME_WIDTH              0.8*SCREEN_WIDTH
#define PHONE_TEXTFIELD_WIDTH   0.625*SCREEN_WIDTH
#define VERIFY_BUTTON_WIDTH     0.15*SCREEN_WIDTH
#define SAME_HEIGHT             0.05*SCREEN_HEIGHT
#define CORNERRADIUS            6
#define UICOLOR                 [UIColor colorWithRed:0.050 green:0.700 blue:0.050 alpha:1.000];

#define IDENTIFICATION_HEIGHT   (SCREEN_HEIGHT-NAVIGATIONBAR_HEIGHT-STATUS_HEIGHT)/3
#define COMMIT_HEIGHT           IDENTIFICATION_HEIGHT/5
#define COMMIT_WIDTH            0.7*SCREEN_WIDTH

#define MARGIN                   0.075*SCREEN_HEIGHT

#define IP                      @"http://192.168.0.105:8080"


#endif /* UISize_h */
