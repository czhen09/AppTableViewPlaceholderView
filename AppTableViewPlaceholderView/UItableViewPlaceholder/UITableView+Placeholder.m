//
//  UITableView+Placeholder.m
//  FoodSecurityB
//
//  Created by ZX on 2017/4/20.
//  Copyright © 2017年 cdbqkj. All rights reserved.
//

#import "UITableView+Placeholder.h"
#import "NSObject+Swizzling.h"
#import "NoDataPlaceholderView.h"
#import "ZXNetworkingConfigurationManager.h"
#import "NotNetPlaceholderView.h"
static  NSString *isFirstLoad = @"isFirstLoad";

#define UserDefaults [NSUserDefaults standardUserDefaults]


@implementation UITableView (Placeholder)

+ (void)load{
    

    [UserDefaults setBool:YES forKey:isFirstLoad];
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
//TODO: 这里后面根据需求再改动吧；1.可以将没有数据和没有网络状态合并成一个placeholderview，只需要传递不同的图片即可；  2.如果分开成两个的时候，要考虑开始没有网络，后面又突然有了网络的情况，是否需要隐藏没有网络的那个view？待测试
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
    [self creatNotNetPlaceholderView];
}

- (void)displayNoDataStatus
{

    if (![UserDefaults boolForKey:isFirstLoad]) {
        [self checkEmpty];
    }
    [UserDefaults setBool:NO forKey:isFirstLoad];
    //为何重复调用
    [self displayNoDataStatus];
}


- (void)checkEmpty{
    
    BOOL isEmpty = YES;
    
    id<UITableViewDataSource>dataSource = self.dataSource;
    NSInteger sections = 1;
    if ([dataSource respondsToSelector:@selector(numberOfSectionsInTableView:)]) {
        
        sections = [dataSource numberOfSectionsInTableView:self]-1;
    }
    
    for (NSInteger i = 0; i <= sections; i++) {
        
        NSInteger rows = [dataSource tableView:self numberOfRowsInSection:i];
        if (rows) {
            
            isEmpty = NO;
        }
    }
    
    
    if (isEmpty) {
        
        if (!self.placeholderView) {
            
            [self creatNoDataPlaceholderView];
        }
        self.placeholderView.hidden = NO;
       
    }else{
        
        self.placeholderView.hidden = YES;
    }
    
}
- (void)creatNotNetPlaceholderView{
    
    self.bounds = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    NotNetPlaceholderView *holderView = [[NSBundle mainBundle] loadNibNamed:NSStringFromClass([NotNetPlaceholderView class]) owner:nil options:nil].lastObject;
    holderView.delegate = self;
    holderView.frame = self.bounds;
    self.placeholderView = holderView;
    [self addSubview:self.placeholderView];
    
}


- (void)creatNoDataPlaceholderView{
    
    self.bounds = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    NoDataPlaceholderView *holderView = [[NSBundle mainBundle] loadNibNamed:NSStringFromClass([NoDataPlaceholderView class]) owner:nil options:nil].lastObject;
    holderView.frame = self.bounds;
    self.placeholderView = holderView;
    [self addSubview:self.placeholderView];
    
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

@end








