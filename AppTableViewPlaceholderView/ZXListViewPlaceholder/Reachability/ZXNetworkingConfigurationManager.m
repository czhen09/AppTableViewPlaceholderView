//
//  ZXNetworkingConfigurationManager.m
//  LightViewControllerDemo
//
//  Created by zx on 17/6/22.
//  Copyright © 2017年 ZX. All rights reserved.
//

#import "ZXNetworkingConfigurationManager.h"
#import <AFNetworking/AFNetworking.h>

@implementation ZXNetworkingConfigurationManager
+ (instancetype)shareInstance
{
    static ZXNetworkingConfigurationManager *shareInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareInstance = [[ZXNetworkingConfigurationManager alloc] init];
        [[AFNetworkReachabilityManager sharedManager] startMonitoring];

    });
    return shareInstance;
}

- (BOOL)isReachable
{
    if ([AFNetworkReachabilityManager sharedManager].networkReachabilityStatus == AFNetworkReachabilityStatusUnknown) {
        //网络状态未知也是有网络的
        return YES;
    } else {
        return [[AFNetworkReachabilityManager sharedManager] isReachable];
    }
}
- (BOOL)isWWAN
{
    return [[AFNetworkReachabilityManager sharedManager] isReachableViaWWAN];
}
- (BOOL)isWiFi
{
    return [[AFNetworkReachabilityManager sharedManager] isReachableViaWiFi];
}
@end
