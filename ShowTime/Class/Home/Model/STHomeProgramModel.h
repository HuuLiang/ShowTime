//
//  STHomeProgramModel.h
//  kuaibov
//
//  Created by Sean Yue on 15/9/5.
//  Copyright (c) 2015年 kuaibov. All rights reserved.
//

#import "STEncryptedURLRequest.h"
#import "STProgram.h"

@interface STHomeProgramResponse : STURLResponse
@property (nonatomic,retain) NSArray<STPrograms> *columnList;
@end

typedef void (^STFetchHomeProgramsCompletionHandler)(BOOL success, NSArray *programs);

@interface STHomeProgramModel : STEncryptedURLRequest

@property (nonatomic,retain,readonly) NSArray<STPrograms *> *fetchedProgramList;
@property (nonatomic,retain,readonly) NSArray<STPrograms *> *fetchedVideoAndAdProgramList;

@property (nonatomic,retain,readonly) NSArray<STProgram *> *fetchedBannerPrograms;

- (BOOL)fetchHomeProgramsWithCompletionHandler:(STFetchHomeProgramsCompletionHandler)handler;

@end
