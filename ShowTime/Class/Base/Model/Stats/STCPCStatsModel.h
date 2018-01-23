//
//  STCPCStatsModel.h
//  STuaibo
//
//  Created by Sean Yue on 16/4/29.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import "STStatsBaseModel.h"

@interface STCPCStatsModel : STStatsBaseModel

- (BOOL)statsCPCWithStatsInfos:(NSArray<STStatsInfo *> *)statsInfos
             completionHandler:(STCompletionHandler)completionHandler;

@end
