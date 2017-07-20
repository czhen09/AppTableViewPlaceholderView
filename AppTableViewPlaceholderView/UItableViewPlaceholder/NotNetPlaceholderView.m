//
//  NotNetPlaceholderView.m
//  AppTableViewPlaceholderView
//
//  Created by 郑旭 on 2017/7/20.
//  Copyright © 2017年 郑旭. All rights reserved.
//

#import "NotNetPlaceholderView.h"

@implementation NotNetPlaceholderView


- (IBAction)refresh:(id)sender {
    
    if ([self.delegate respondsToSelector:@selector(reRequesData)]) {
        
        [self.delegate reRequesData];
    }
}


@end
