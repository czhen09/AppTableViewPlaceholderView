//
//  ViewController.m
//  AppTableViewPlaceholderView
//
//  Created by 郑旭 on 2017/7/20.
//  Copyright © 2017年 郑旭. All rights reserved.
//

#import "ViewController.h"
@interface ViewController ()
//@property (nonatomic,strong) UITableView *tableView;
@property (nonatomic,strong) NSArray *dataArr;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view addSubview:self.tableView];
    
}

#pragma mark - ReRequesDataDelegate
- (void)loadData
{
     NSLog(@"重新请求");
}

//- (void)reRequesData
//{
//    NSLog(@"在这里再次调用网络请求");
//}
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

//- (UITableView *)tableView
//{
//    if (!_tableView) {
//        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
//        _tableView.dataSource = self;
//        _tableView.delegate = self;
//        _tableView.reRequestDelegate = self;
//    }
//    return _tableView;
//}
- (NSArray *)dataArr
{
    if (!_dataArr) {
        _dataArr = @[];
    }
    return _dataArr;
}
@end
