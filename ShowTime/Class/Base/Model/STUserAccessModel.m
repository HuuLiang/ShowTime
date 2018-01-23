//
//  STUserAccessModel.m
//  kuaibov
//
//  Created by Sean Yue on 15/11/26.
//  Copyright © 2015年 kuaibov. All rights reserved.
//

#import "STUserAccessModel.h"

@implementation STUserAccessModel

+ (Class)responseClass {
    return [NSString class];
}

+ (instancetype)sharedModel {
    static STUserAccessModel *_theInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _theInstance = [[STUserAccessModel alloc] init];
    });
    return _theInstance;
}

- (BOOL)requestUserAccess {
    NSString *userId = [STUtil userId];
    if (!userId) {
        return NO;
    }
    
    @weakify(self);
    BOOL ret = [super requestURLPath:ST_USER_ACCESS_URL
                          withParams:@{@"userId":userId,@"accessId":[STUtil accessId]}
                    responseHandler:^(STURLResponseStatus respStatus, NSString *errorMessage)
    {
        @strongify(self);
        
        BOOL success = NO;
        if (respStatus == STURLResponseSuccess) {
            NSString *resp = self.response;
            success = [resp isEqualToString:@"SUCCESS"];
            if (success) {
                DLog(@"Record user access!");
            }
        }
    }];
    return ret;
}

@end
