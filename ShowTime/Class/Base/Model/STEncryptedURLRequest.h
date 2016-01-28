//
//  STEncryptedURLRequest.h
//  kuaibov
//
//  Created by Sean Yue on 15/9/14.
//  Copyright (c) 2015年 kuaibov. All rights reserved.
//

#import "STURLRequest.h"

@interface STEncryptedURLRequest : STURLRequest

+ (NSString *)signKey;
+ (NSDictionary *)commonParams;
+ (NSArray *)keyOrdersOfCommonParams;
- (NSDictionary *)encryptWithParams:(NSDictionary *)params;
- (id)decryptResponse:(id)encryptedResponse;

- (BOOL)requestURLPath:(NSString *)urlPath
        standbyURLPath:(NSString *)standbyUrlPath
            withParams:(NSDictionary *)params
       responseHandler:(STURLResponseHandler)responseHandler;

@end