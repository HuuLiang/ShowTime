//
//  STPayStatsModel.h
//  STuaibo
//
//  Created by Sean Yue on 16/5/3.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import "STStatsBaseModel.h"

@interface STPayStatsModel : STStatsBaseModel

- (BOOL)statsPayWithStatsInfos:(NSArray<STStatsInfo *> *)statsInfos completionHandler:(STCompletionHandler)completionHandler;

@end
