//
//  ZXAspectEx.m
//  GJB
//
//  Created by 郑旭 on 2018/3/29.
//  Copyright © 2018年 汇金集团SR. All rights reserved.
//

#import "ZXAspectEx.h"
#import "Aspects.h"
#import "UITableView+Placeholder.h"
@implementation ZXAspectEx
+ (void)load
{
    [super load];
    [ZXAspectEx sharedInstance];
}
+ (instancetype)sharedInstance
{
    static dispatch_once_t onceToken;
    static ZXAspectEx *sharedInstance;
    dispatch_once(&onceToken, ^{
        
        sharedInstance = [[ZXAspectEx alloc] init];
        
    });
    return sharedInstance;
}
- (instancetype)init
{
    self = [super init];
    if (self) {
        /* 方法拦截_viewWillAppear */
        [UIViewController aspect_hookSelector:@selector(viewWillAppear:) withOptions:AspectPositionAfter usingBlock:^(id<AspectInfo>aspectInfo){
            [self aspectViewWillAppearWithViewController:aspectInfo.instance];
        }error:NULL];
    }
    return self;
}
#pragma mark - fake methods for UIViewController
- (void)aspectViewWillAppearWithViewController:(UIViewController *)viewController
{
    //tableView在手动调用reloadData方法之前,会自动调用一次;
    //为了避免自动调用这一次触发无数据的情况,那么第一次的的调用需要处理并判断标记;
    NSArray *subViews = viewController.view.subviews;
    [subViews enumerateObjectsUsingBlock:^(UIView *view, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([view isKindOfClass:[UITableView class]]) {
            UITableView *tableView = (UITableView *)view;
            tableView.firstReload = YES;
        }
        NSArray *secondLevelSubviews = view.subviews;
        [secondLevelSubviews enumerateObjectsUsingBlock:^(UIView *secondView, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([secondView isKindOfClass:[UITableView class]]) {
                UITableView *tableView = (UITableView *)secondView;
                tableView.firstReload = YES;
            }
            NSArray *thirdLevelSubviews = secondView.subviews;
            [thirdLevelSubviews enumerateObjectsUsingBlock:^(UIView *thirdView, NSUInteger idx, BOOL * _Nonnull stop) {
                if ([thirdView isKindOfClass:[UITableView class]]) {
                    UITableView *tableView = (UITableView *)thirdView;
                    tableView.firstReload = YES;
                }
            }];
        }];
    }];
}

@end
