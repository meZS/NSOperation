//
//  ZSOperation.m
//  NSoperation
//
//  Created by wordy on 2017/7/6.
//  Copyright © 2017年 golddatacommunications. All rights reserved.
//

#import "ZSOperation.h"

@implementation ZSOperation


/**
  需要执行的任务,重写main方法
 */
- (void)main
{
    for (int i = 0; i < 2; i ++) {
        NSLog(@"\n---ZSOperation--%@",[NSThread currentThread]);
    }
}


@end
