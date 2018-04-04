//
//  NetworkRequestTool.h
//  AppTableViewPlaceholderView
//
//  Created by 郑旭 on 2018/3/30.
//  Copyright © 2018年 郑旭. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NetworkRequestTool : NSObject
+ (void)getWithURL:(NSString *)urlStr params:(id)params success:(void(^)(id data))success failure:(void(^)(NSError *error))failure;
@end
