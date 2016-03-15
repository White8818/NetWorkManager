//
//  NetworkManager.m
//
//  Created by white on 15/1/15.
//  Copyright (c) 2015年 white8818. All rights reserved.
//

#import "NetworkManager.h"
#import <UIKit/UIKit.h>


@interface NetworkManager ()<NSURLConnectionDataDelegate>

@property (nonatomic, assign) id<NetworkManagerDelegate> delegate;//代理对象
@property (nonatomic, retain) NSMutableData *receivedData;//保存接收到的数据
@property (nonatomic, retain) NSMutableDictionary *paramsDictionary;//如果是POST请求，则保存请求参数

- (NSData *)_HTTPBodyFromParams;//得到POST请求的参数数据
@end

@implementation NetworkManager



#pragma mark - Lazy Loading Getter

- (NSMutableData *)receivedData {
    if (!_receivedData) {
        self.receivedData = [NSMutableData data];
    }
    return _receivedData;
}

- (NSMutableDictionary *)paramsDictionary {
    if (!_paramsDictionary) {
        self.paramsDictionary = [NSMutableDictionary dictionary];
    }
    return _paramsDictionary;
}

+ (id)managerWithDelegate:(id<NetworkManagerDelegate>)delegate {
    NetworkManager *manager = [[NetworkManager alloc] init];
    manager.delegate = delegate;
    return manager;
}

- (void)setParam:(NSString *)aParam forKey:(NSString *)key {
    [self.paramsDictionary setObject:aParam forKey:key];
}

- (NSData *)_HTTPBodyFromParams {
    NSMutableArray *params = [NSMutableArray array];
    for (NSString *key in self.paramsDictionary) {
        NSString *paramString = [NSString stringWithFormat:@"%@=%@", key, self.paramsDictionary[key]];
        [params addObject:paramString];
    }
    NSString *finalString = [params componentsJoinedByString:@"&"];
    return [finalString dataUsingEncoding:NSUTF8StringEncoding];
}

- (void)startAcquire {
    NSURL *URL = [NSURL URLWithString:self.URLString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
    //判断如果是POST请求，则设置请求方式，以及请求体，否则默认为GET
    if ([self.HTTPType isEqualToString:@"POST"]) {
        request.HTTPMethod = self.HTTPType;
        request.HTTPBody = [self _HTTPBodyFromParams];
    }
    //建立异步链接请求，代理回调
    [NSURLConnection connectionWithRequest:request delegate:self];
}


- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    //网络状态指示器显示（在状态栏上的菊花会转起来）
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [self.receivedData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    if (self.delegate && [self.delegate respondsToSelector:@selector(manager:didFinishLoadingWithInfo:)]) {
        [self.delegate manager:self didFinishLoadingWithInfo:self.receivedData];
    }
    [self.receivedData setData:nil];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    if (self.delegate && [self.delegate respondsToSelector:@selector(manager:didFailedWithError:)]) {
        [self.delegate manager:self didFailedWithError:error];
    }
    [self.receivedData setData:nil];
}





@end
