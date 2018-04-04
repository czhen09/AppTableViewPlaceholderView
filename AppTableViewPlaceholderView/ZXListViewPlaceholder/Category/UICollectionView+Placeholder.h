//
//  UICollectionView+Placeholder.h
//  AppTableViewPlaceholderView
//
//  Created by 郑旭 on 2018/4/4.
//  Copyright © 2018年 郑旭. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ReRequesDataDelegate.h"
@interface UICollectionView (Placeholder)<ReRequesDataDelegate>
@property (nonatomic, assign) BOOL isNotFirstReload;
@property (nonatomic, strong) UIView *placeholderView;
@property (nonatomic,weak) id<ReRequesDataDelegate> reRequestDelegate;

@end
