//
//  NetworkManager.h
//
//  Created by white on 15/1/15.
//  Copyright (c) 2015年 white8818. All rights reserved.
//

#import <Foundation/Foundation.h>
@class NetworkManager;

@protocol NetworkManagerDelegate <NSObject>
//请求成功，通过如下协议方法回调下载到的数据
- (void)manager:(NetworkManager *)manager didFinishLoadingWithInfo:(id)info;
//请求失败，回调失败信息
- (void)manager:(NetworkManager *)manager didFailedWithError:(NSError *)error;
@end

@interface NetworkManager : NSObject

@property (nonatomic, assign) NSInteger ID;
@property (nonatomic, retain) NSString *HTTPType;//请求的方式，GET/POST
@property (nonatomic, retain) NSString *URLString;//请求的接口
//声明便利构造器方法
+ (id)managerWithDelegate:(id<NetworkManagerDelegate>)delegate;
//如果是POST请求，通过调用该方法设置请求参数
- (void)setParam:(NSString *)aParam
          forKey:(NSString *)key;
//开始网络请求的方法
- (void)startAcquire;

@end
