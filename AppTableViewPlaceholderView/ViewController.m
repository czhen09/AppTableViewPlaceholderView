//
//  ViewController.m
//  AppTableViewPlaceholderView
//
//  Created by 郑旭 on 2017/7/20.
//  Copyright © 2017年 郑旭. All rights reserved.
//

#import "ViewController.h"
#import "NetworkRequestTool.h"
#import <MJRefresh/MJRefresh.h>
@interface ViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic,strong) NSArray *dataArr;
@property (nonatomic,assign) BOOL isShowData;
@end

@implementation ViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadData];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [self loadData];
    }];
    [self.view addSubview:self.tableView];
}

#pragma mark - ReRequesDataDelegate
- (void)loadData
{
     NSLog(@"重新请求");
    [NetworkRequestTool getWithURL:@"http://123.57.213.117/Api/ServerTime/Get" params:nil success:^(id data) {
        if (self.isShowData==0) {
            self.dataArr = @[@"numberOfRowsInSection",@"numberOfRowsInSection",@"numberOfRowsInSection"];
        }else{
            self.dataArr = @[];
        }
        [self.tableView reloadData];
        self.isShowData = !self.isShowData;
        [self.tableView.mj_header endRefreshing];
    } failure:^(NSError *error) {
        [self.tableView.mj_header endRefreshing];
    }];
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return  self.dataArr.count;
    
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
        cell.textLabel.text = self.dataArr[indexPath.row];
        
    }
    return cell;
}

@end
