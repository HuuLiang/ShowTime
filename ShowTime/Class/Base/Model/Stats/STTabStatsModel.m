//
//  STTabStatsModel.m
//  STuaibo
//
//  Created by Sean Yue on 16/5/3.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import "STTabStatsModel.h"

@implementation STTabStatsModel

- (BOOL)statsTabWithStatsInfos:(NSArray<STStatsInfo *> *)statsInfos
             completionHandler:(STCompletionHandler)completionHandler
{
    NSArray<NSDictionary *> *params = [self validateParamsWithStatsInfos:statsInfos];
    if (params.count == 0) {
        SafelyCallBlock(completionHandler,NO,@"No validated statsInfos to Commit!");
        return NO;
    }
    
    BOOL ret = [self requestURLPath:ST_STATS_TAB_URL
                         withParams:params
                    responseHandler:^(STURLResponseStatus respStatus, NSString *errorMessage)
    {
        SafelyCallBlock(completionHandler, respStatus == STURLResponseSuccess, errorMessage);
    }];
    return ret;
}

@end
