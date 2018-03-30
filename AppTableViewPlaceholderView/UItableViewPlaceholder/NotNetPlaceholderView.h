//
//  NotNetPlaceholderView.h
//  AppTableViewPlaceholderView
//
//  Created by 郑旭 on 2017/7/20.
//  Copyright © 2017年 郑旭. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ReRequesDataDelegate.h"


@interface NotNetPlaceholderView : UIView
@property (nonatomic,weak) id<ReRequesDataDelegate> delegate;
@end
