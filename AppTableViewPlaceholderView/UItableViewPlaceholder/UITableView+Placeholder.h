//
//  UITableView+Placeholder.h
//  FoodSecurityB
//
//  Created by ZX on 2017/4/20.
//  Copyright © 2017年 cdbqkj. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ReRequesDataDelegate.h"
@interface UITableView (Placeholder)<ReRequesDataDelegate>
/*
 * 是否是第一次的自动调用reloadData方法;
 */
@property (nonatomic, assign) BOOL firstReload;
@property (nonatomic, strong) UIView *placeholderView;
@property (nonatomic,weak) id<ReRequesDataDelegate> reRequestDelegate;
@end
