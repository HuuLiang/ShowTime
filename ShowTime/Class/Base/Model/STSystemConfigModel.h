//
//  STSystemConfigModel.h
//  kuaibov
//
//  Created by Sean Yue on 15/9/10.
//  Copyright (c) 2015年 kuaibov. All rights reserved.
//

#import "STEncryptedURLRequest.h"
#import "STSystemConfig.h"

@interface STSystemConfigResponse : STURLResponse
@property (nonatomic,retain) NSArray<STSystemConfig> *confis;
@end

typedef void (^STFetchSystemConfigCompletionHandler)(BOOL success);

@interface STSystemConfigModel : STEncryptedURLRequest

@property (nonatomic) NSString *contact;


@property (nonatomic) double payAmount;
@property (nonatomic) NSString *paymentImage;
@property (nonatomic) NSString *channelTopImage;
@property (nonatomic) NSString *spreadTopImage;
@property (nonatomic) NSString *spreadURL;

@property (nonatomic) NSString *startupInstall;
@property (nonatomic) NSString *startupPrompt;

@property (nonatomic) NSUInteger statsTimeInterval;
@property (nonatomic,readonly) BOOL loaded;


+ (instancetype)sharedModel;

- (BOOL)fetchSystemConfigWithCompletionHandler:(STFetchSystemConfigCompletionHandler)handler;

@end
