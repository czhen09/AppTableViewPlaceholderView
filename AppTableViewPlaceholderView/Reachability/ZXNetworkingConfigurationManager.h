//
//  ZXNetworkingConfigurationManager.h
//  LightViewControllerDemo
//
//  Created by zx on 17/6/22.
//  Copyright © 2017年 ZX. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZXNetworkingConfigurationManager : NSObject
+ (instancetype)shareInstance;
@property (nonatomic,assign,readonly) BOOL isReachable;
@property (nonatomic,assign,readonly) BOOL isWWAN;
@property (nonatomic,assign,readonly) BOOL isWiFi;
@end
