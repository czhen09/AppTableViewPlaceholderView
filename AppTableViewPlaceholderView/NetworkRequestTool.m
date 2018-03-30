//
//  NetworkRequestTool.m
//  AppTableViewPlaceholderView
//
//  Created by 郑旭 on 2018/3/30.
//  Copyright © 2018年 郑旭. All rights reserved.
//

#import "NetworkRequestTool.h"
#import <AFNetworking/AFNetworking.h>
@implementation NetworkRequestTool
+ (void)postWithURL:(NSString *)urlStr Method:(NSString *)method params:(id)params success:(void(^)(id data))success failure:(void(^)(NSError *error))failure{
    AFHTTPSessionManager *manager=[AFHTTPSessionManager manager];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.requestSerializer.timeoutInterval = 30.0f;
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
    NSString * url = [NSString stringWithFormat:@"%@%@",urlStr,method];
    [manager POST:url parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"responseObject===%@",responseObject);
        if (responseObject) {
            
            success(responseObject);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failure(error);
        //失败的时候处理
        [NetworkRequestTool handleFailNoData];
    }];
}
#pragma mark - 失败无数据处理
+ (void)handleFailNoData
{
    UINavigationController *nav = (UINavigationController *)[UIApplication sharedApplication].keyWindow.rootViewController;
    UIViewController *vc = nav.visibleViewController;
    if (vc.childViewControllers.count>0) {
        
        if ([vc.childViewControllers.firstObject isKindOfClass:[UIPageViewController class]]) {
            UIPageViewController *pageVc = (UIPageViewController *)vc.childViewControllers.firstObject;
            UIViewController *pageChild = pageVc.viewControllers.firstObject;
            NSArray *subViews = pageChild.view.subviews;
            [subViews enumerateObjectsUsingBlock:^(UIView *view, NSUInteger idx, BOOL * _Nonnull stop) {
                if ([view isKindOfClass:[UITableView class]]) {
                    UITableView *tableView = (UITableView *)view;
                    [tableView reloadData];
                }
            }];
        }
    }else{
        NSArray *subViews = vc.view.subviews;
        [subViews enumerateObjectsUsingBlock:^(UIView *view, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([view isKindOfClass:[UITableView class]]) {
                UITableView *tableView = (UITableView *)view;
                [tableView reloadData];
            }
        }];
    }
}
@end
