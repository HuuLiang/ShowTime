//
//  UIScrollView+Refresh.h
//  kuaibov
//
//  Created by Sean Yue on 15/9/8.
//  Copyright (c) 2015年 kuaibov. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UIScrollView (Refresh)

- (void)ST_addPullToRefreshWithHandler:(void (^)(void))handler;
- (void)ST_triggerPullToRefresh;
- (void)ST_endPullToRefresh;

- (void)ST_addPagingRefreshWithHandler:(void (^)(void))handler;
- (void)ST_pagingRefreshNoMoreData;

@end
