//
//  UITableView+Placeholder.m
//  FoodSecurityB
//
//  Created by ZX on 2017/4/20.
//  Copyright © 2017年 cdbqkj. All rights reserved.
//
/*
 需要考虑的问题:
 1:第一次加载的时候系统自动调用一次reloadData的问题--->>解决方案:扩展tableView  isNotFirstReload属性;
 
 2:数据加载失败的问题:无论什么时候,只需要调用一次reloadData即可检查数据的有无,为了避免耦合,所以网络请求失败的时候,在整体的网络封装接口中的failure回调中调用当前控制器的tableView的reloadData方法;
 ** 通过:
 UINavigationController *nav = (UINavigationController *)[UIApplication sharedApplication].keyWindow.rootViewController;
 UIViewController *vc = nav.visibleViewController;
 获取到当前的控制器;
 那么又需要考虑的是:1):控制器的childControllers为0的时候,直接获取其subViews;
 2):控制器的childControllers>0的时候;比如UIPageViewController;
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
 }
 3:点击再次加载的策略
 通过继承  loadData方案;父类懒加载实现tableview的创建,并且设置代理;代理方法中调用[self loadData];并且在viewDidLoad中第一次调用;
 
 4:检查是否有数据的情况:  rows==0||sectionheaderView == nil

*/
#import "UITableView+Placeholder.h"
#import "NSObject+Swizzling.h"
#import "NoDataPlaceholderView.h"
#import "ZXNetworkingConfigurationManager.h"
#import "NotNetPlaceholderView.h"
@implementation UITableView (Placeholder)
//TODO: 这里后面根据需求再改动吧；1.可以将没有数据和没有网络状态合并成一个placeholderview，只需要传递不同的图片即可；  2.如果分开成两个的时候，要考虑开始没有网络，后面又突然有了网络的情况，是否需要隐藏没有网络的那个view？待测试;
+ (void)load{

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        //没有网络状态下，就直接在reload的时候添加view
        if (![ZXNetworkingConfigurationManager shareInstance].isReachable) {
            [self methodSwizzlingWithOriginalSelector:@selector(reloadData) bySwizzledSelector:@selector(displayNotNetworkStatus)];
            return;
        }
        //有网络状态但是没有数据的状态下
        [self methodSwizzlingWithOriginalSelector:@selector(reloadData) bySwizzledSelector:@selector(displayNoDataStatus)];
        
    });
}
- (void)displayNotNetworkStatus
{
    [self creatNoNetPlaceholderView];
}

- (void)displayNoDataStatus
{
    if (self.isNotFirstReload) {
        [self checkEmpty];
    }
    self.isNotFirstReload = YES;
    //为何重复调用
    [self displayNoDataStatus];
}
- (void)checkEmpty{
    
    BOOL isEmpty = YES;
    
    id<UITableViewDataSource>dataSource = self.dataSource;
    id<UITableViewDelegate>delegate = self.delegate;
    NSInteger sections = 1;
    if ([dataSource respondsToSelector:@selector(numberOfSectionsInTableView:)]) {
        
        sections = [dataSource numberOfSectionsInTableView:self]-1;
    }
    
    for (NSInteger i = 0; i <= sections; i++) {
        
        NSInteger rows = [dataSource tableView:self numberOfRowsInSection:i];
        //不能仅仅考虑numberofrows==0;还得考虑section!=0;rows==0;有sectionheader的时候
        UIView *sectionHeaderView = nil;
        if ([delegate respondsToSelector:@selector(tableView:viewForHeaderInSection:)]) {
            sectionHeaderView = [delegate tableView:self viewForHeaderInSection:i];
        }
        if (rows||sectionHeaderView) {
            
            isEmpty = NO;
        }
    }
    if (isEmpty) {
        [self creatNoDataPlaceholderView];
        self.placeholderView.hidden = NO;
       
    }else{
        
        self.placeholderView.hidden = YES;
    }
    
}
//无网络的占位
- (void)creatNoNetPlaceholderView{
    
    if (!self.placeholderView) {
        self.bounds = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
        NotNetPlaceholderView *holderView = [[NSBundle mainBundle] loadNibNamed:NSStringFromClass([NotNetPlaceholderView class]) owner:nil options:nil].lastObject;
        holderView.delegate = self;
        holderView.frame = self.bounds;
        self.placeholderView = holderView;
        [self addSubview:self.placeholderView];
    }
}
//没数据的占位
- (void)creatNoDataPlaceholderView{
    if (!self.placeholderView) {
        self.bounds = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
        NoDataPlaceholderView *holderView = [[NSBundle mainBundle] loadNibNamed:NSStringFromClass([NoDataPlaceholderView class]) owner:nil options:nil].lastObject;
        holderView.frame = self.bounds;
        self.placeholderView = holderView;
        [self addSubview:self.placeholderView];
    }
}
- (void)reRequesData
{
    if ([self.reRequestDelegate respondsToSelector:@selector(reRequesData)]) {
        
        [self.reRequestDelegate reRequesData];
    }
}

- (UIView *)placeholderView {
    return objc_getAssociatedObject(self, @selector(placeholderView));
}
- (void)setPlaceholderView:(UIView *)placeholderView {
    objc_setAssociatedObject(self, @selector(placeholderView), placeholderView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (id<ReRequesDataDelegate>)reRequestDelegate
{
    return objc_getAssociatedObject(self, @selector(reRequestDelegate));
}
- (void)setReRequestDelegate:(id<ReRequesDataDelegate>)reRequestDelegate
{
    objc_setAssociatedObject(self, @selector(reRequestDelegate), reRequestDelegate, OBJC_ASSOCIATION_ASSIGN);
}
- (BOOL)isNotFirstReload {
    return [objc_getAssociatedObject(self, @selector(isNotFirstReload)) boolValue];
}

- (void)setIsNotFirstReload:(BOOL)isNotFirstReload {
    objc_setAssociatedObject(self, @selector(isNotFirstReload), @(isNotFirstReload), OBJC_ASSOCIATION_ASSIGN);
}
@end








