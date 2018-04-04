//
//  RequestFailureHandler.m
//  GJB
//
//  Created by 郑旭 on 2018/4/3.
//  Copyright © 2018年 汇金集团SR. All rights reserved.
//

#import "RequestFailureHandler.h"
/*
 针对需求:网络请求失败的时候一般不会手动调用tableView.reloadData方法;
 解决方案:1:找到当前视图;2:找到tableView;3:调用reloadData方法;
*/
@interface RequestFailureHandler()
@property (nonatomic,strong) UIViewController  *rootVC;
@end
@implementation RequestFailureHandler
+ (instancetype)shareInstance
{
    static RequestFailureHandler *shareInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareInstance = [[RequestFailureHandler alloc] init];
    });
    return shareInstance;
}
- (void)handleRequestFailure
{
    //根控制器是UINavigationController
    if ([self.rootVC isKindOfClass:[UINavigationController class]]) {
        [[RequestFailureHandler shareInstance] handleWithNavgationController:(UINavigationController *)self.rootVC];
    }else
    {
        //没有UINavigationController的情况下
        [[RequestFailureHandler shareInstance] findTargetViewWithController:self.rootVC];
    }
}
- (void)handleWithNavgationController:(UINavigationController *)nav
{
    UIViewController *vc = nav.visibleViewController;
    if (vc.childViewControllers.count>0) {
        
        if ([vc.childViewControllers.firstObject isKindOfClass:[UIPageViewController class]]) {
            UIPageViewController *pageVc = (UIPageViewController *)vc.childViewControllers.firstObject;
            UIViewController *pageChild = pageVc.viewControllers.firstObject;
            [[RequestFailureHandler shareInstance] findTargetViewWithController:pageChild];
        }
    }else{
        [[RequestFailureHandler shareInstance] findTargetViewWithController:vc];
    }
}
- (void)findTargetViewWithController:(UIViewController *)viewController
{
    NSArray *subViews = viewController.view.subviews;
    [subViews enumerateObjectsUsingBlock:^(UIView *view, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([view isKindOfClass:[UITableView class]]) {
            UITableView *tableView = (UITableView *)view;
            [tableView reloadData];
        }
    }];
}
#pragma mark - Getters & Setters
- (UIViewController *)rootVC
{
    if (!_rootVC) {
        _rootVC = [[[UIApplication sharedApplication] delegate] window].rootViewController;
    }
    return _rootVC;
}
@end
