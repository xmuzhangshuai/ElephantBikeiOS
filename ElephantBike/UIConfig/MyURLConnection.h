//
//  MyURLConnection.h
//  ElephantBike
//
//  Created by 黄杰锋 on 16/2/18.
//  Copyright © 2016年 黄杰锋. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MyURLConnection;

@protocol MyURLConnectionDelegate <NSObject>

- (void)MyConnection:(MyURLConnection *)connection didReceiveData:(NSData *)data;

@end

@interface MyURLConnection : NSURLConnection <NSURLConnectionDelegate, NSURLConnectionDataDelegate>
@property NSString *name;
@property NSURLConnection *connection;
@property (nonatomic, weak)id<MyURLConnectionDelegate> delegate;
- (MyURLConnection *)MyConnectioin:(NSMutableURLRequest *)request delegate:(id)delegate andName:(NSString *)name;
@end
