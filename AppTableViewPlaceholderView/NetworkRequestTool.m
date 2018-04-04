//
//  NetworkRequestTool.m
//  AppTableViewPlaceholderView
//
//  Created by 郑旭 on 2018/3/30.
//  Copyright © 2018年 郑旭. All rights reserved.
//

#import "NetworkRequestTool.h"
#import <AFNetworking/AFNetworking.h>
#import "RequestFailureHandler.h"
@implementation NetworkRequestTool
+ (void)getWithURL:(NSString *)urlStr params:(id)params success:(void(^)(id data))success failure:(void(^)(NSError *error))failure{
    AFHTTPSessionManager *manager=[AFHTTPSessionManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer]; manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
    [manager GET:urlStr parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"responseObject===%@",responseObject);
        if (responseObject) {
            
            success(responseObject);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failure(error);
        //失败的时候处理
        [[RequestFailureHandler shareInstance] handleRequestFailure];
    }];
}
@end
