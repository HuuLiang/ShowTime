//
//  STChannel.h
//  ShowTime
//
//  Created by ylz on 16/6/28.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import "STURLResponse.h"

@interface STChannel : STURLResponse

@property (nonatomic) NSNumber *columnId;
@property (nonatomic) NSNumber *realColumnId;
@property (nonatomic) NSString *name;
@property (nonatomic) NSString *columnDesc;
@property (nonatomic) NSString *columnImg;
@property (nonatomic) NSString *spreadUrl;
@property (nonatomic) NSNumber *type;   // 1、视频 2、图片
@property (nonatomic) NSNumber *showNumber;
@property (nonatomic) NSNumber *items;
@property (nonatomic) NSNumber *page;
@property (nonatomic) NSNumber *pageSize;
@property (nonatomic,retain) NSArray<STProgram *> *programList;

//+ (NSString *)cryptPasswordForProperty:(NSString *)propertyName withInstance:(id)instance;

@end
