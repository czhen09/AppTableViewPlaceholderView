//
//  RequestFailureHandler.h
//  GJB
//
//  Created by 郑旭 on 2018/4/3.
//  Copyright © 2018年 汇金集团SR. All rights reserved.
//

#import <UIKit/UIKit.h>
@interface RequestFailureHandler : NSObject
+ (instancetype)shareInstance;
- (void)handleRequestFailure;
@end
