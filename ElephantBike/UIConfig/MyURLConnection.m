//
//  MyURLConnection.m
//  ElephantBike
//
//  Created by 黄杰锋 on 16/2/18.
//  Copyright © 2016年 黄杰锋. All rights reserved.
//

#import "MyURLConnection.h"

@implementation MyURLConnection {

}

- (MyURLConnection *)MyConnectioin:(NSMutableURLRequest *)request delegate:(id)delegate andName:(NSString *)name{
    self.name = name;
    self.delegate =delegate;
    return (MyURLConnection *)[NSURLConnection connectionWithRequest:request delegate:self];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    MyURLConnection *MyConnection = [[MyURLConnection alloc] init];
    MyConnection.connection = connection;
    MyConnection.name = self.name;
    [self.delegate MyConnection:MyConnection didReceiveData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    MyURLConnection *MyConnection = [[MyURLConnection alloc] init];
    MyConnection.connection = connection;
    [self.delegate MyConnection:MyConnection didFailWithError:error];
}

@end
