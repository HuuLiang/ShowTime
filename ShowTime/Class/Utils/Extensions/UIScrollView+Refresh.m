//
//  UIScrollView+Refresh.m
//  kuaibov
//
//  Created by Sean Yue on 15/9/8.
//  Copyright (c) 2015年 kuaibov. All rights reserved.
//

#import "UIScrollView+Refresh.h"
#import <MJRefresh.h>

@implementation UIScrollView (Refresh)

- (void)ST_addPullToRefreshWithHandler:(void (^)(void))handler {
    if (!self.mj_header) {
        MJRefreshNormalHeader *refreshHeader = [MJRefreshNormalHeader headerWithRefreshingBlock:handler];
        refreshHeader.lastUpdatedTimeLabel.hidden = YES;
        self.mj_header = refreshHeader;
    }
}

- (void)ST_triggerPullToRefresh {
    [self.mj_header beginRefreshing];
}

- (void)ST_endPullToRefresh {
    [self.mj_header endRefreshing];
    [self.mj_footer resetNoMoreData];
}

- (void)ST_addPagingRefreshWithHandler:(void (^)(void))handler {
    if (!self.mj_footer) {
        MJRefreshAutoNormalFooter *refreshFooter = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:handler];
        self.mj_footer = refreshFooter;
    }
}

- (void)ST_pagingRefreshNoMoreData {
    [self.mj_footer endRefreshingWithNoMoreData];
}
@end
