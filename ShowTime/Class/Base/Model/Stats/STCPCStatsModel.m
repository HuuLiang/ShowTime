//
//  STCPCStatsModel.m
//  STuaibo
//
//  Created by Sean Yue on 16/4/29.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import "STCPCStatsModel.h"

@implementation STCPCStatsModel

- (BOOL)statsCPCWithStatsInfos:(NSArray<STStatsInfo *> *)statsInfos
             completionHandler:(STCompletionHandler)completionHandler
{
    NSArray<NSDictionary *> *params = [self validateParamsWithStatsInfos:statsInfos];
    if (params.count == 0) {
        SafelyCallBlock(completionHandler, NO, @"No validated statsInfos to Commit!");
        return NO;
    }

    BOOL ret = [self requestURLPath:ST_STATS_CPC_URL
                         withParams:params
                    responseHandler:^(STURLResponseStatus respStatus, NSString *errorMessage)
                {
                    SafelyCallBlock(completionHandler, respStatus==STURLResponseSuccess, errorMessage);
                }];
    return ret;
}

@end
