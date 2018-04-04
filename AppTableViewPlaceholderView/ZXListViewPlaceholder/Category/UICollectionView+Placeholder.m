//
//  UICollectionView+Placeholder.m
//  AppTableViewPlaceholderView
//
//  Created by 郑旭 on 2018/4/4.
//  Copyright © 2018年 郑旭. All rights reserved.
//

#import "UICollectionView+Placeholder.h"
#import "NSObject+Swizzling.h"
#import "NoDataPlaceholderView.h"
#import "ZXNetworkingConfigurationManager.h"
#import "NotNetPlaceholderView.h"
@implementation UICollectionView (Placeholder)
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
    }else{
        self.isNotFirstReload = YES;
    }
    //为何重复调用
    [self displayNoDataStatus];
}
- (void)checkEmpty{
    
    BOOL isEmpty = YES;
    
    id<UICollectionViewDataSource>dataSource = self.dataSource;
    NSInteger sections = 1;
    if ([dataSource respondsToSelector:@selector(numberOfSectionsInTableView:)]) {
        
        sections = [dataSource numberOfSectionsInCollectionView:self]-1;
    }
    
    for (NSInteger i = 0; i <= sections; i++) {
        
        NSInteger rows = [dataSource collectionView:self numberOfItemsInSection:i];
        if (rows) {
            
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
