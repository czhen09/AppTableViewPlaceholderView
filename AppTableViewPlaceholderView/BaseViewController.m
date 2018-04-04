//
//  BaseViewController.m
//  AppTableViewPlaceholderView
//
//  Created by 郑旭 on 2017/7/20.
//  Copyright © 2017年 郑旭. All rights reserved.
//

#import "BaseViewController.h"
#import "UITableView+Placeholder.h"
@interface BaseViewController ()<UITableViewDelegate,UITableViewDataSource,ReRequesDataDelegate>

@end

@implementation BaseViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    
 
}

- (void)loadData
{
   //子类重写这个方法，并且在这个方法中进行网络请求
}

#pragma mark - ReRequesDataDelegate
- (void)reRequesData
{
    [self loadData];
}

- (UITableView *)tableView
{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
        _tableView.tableFooterView = [UIView new];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.reRequestDelegate = self;
    }
    return _tableView;
}
@end
