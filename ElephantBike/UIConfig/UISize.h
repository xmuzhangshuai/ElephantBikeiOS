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
#define UICOLOR                 [UIColor colorWithRed:112/255.0 green:177/255.0 blue:52/255.0 alpha:1.000]
#define BACKGROUNDCOLOR         [UIColor colorWithRed:240/255.0 green:240/255.0 blue:240/255.0 alpha:1.000]

#define IDENTIFICATION_HEIGHT   (SCREEN_HEIGHT-NAVIGATIONBAR_HEIGHT-STATUS_HEIGHT)/3
#define COMMIT_HEIGHT           IDENTIFICATION_HEIGHT/5
#define COMMIT_WIDTH            0.7*SCREEN_WIDTH

#define MARGIN                   0.075*SCREEN_HEIGHT

#define CENTER_X                0.5*SCREEN_WIDTH

#define iPhone5 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 1136), [[UIScreen mainScreen] currentMode].size) : NO)

#define iPhone6P ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1242, 2208), [[UIScreen mainScreen] currentMode].size) : NO)


//#define IP                      @"http://192.168.0.123:8080"
#define IP                      @"http://120.25.197.43"
//#define IP                      @"http://210.121.164.111"


#endif /* UISize_h */
