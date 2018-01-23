//
//  STEncryptedURLRequest.m
//  kuaibov
//
//  Created by Sean Yue on 15/9/14.
//  Copyright (c) 2015年 kuaibov. All rights reserved.
//

#import "STEncryptedURLRequest.h"
#import "NSDictionary+STSign.h"
#import "NSString+crypt.h"

static NSString *const kEncryptionPasssword = @"f7@j3%#5aiG$4";

@implementation STEncryptedURLRequest

+ (NSString *)signKey {
    return kEncryptionPasssword;
}

+ (NSDictionary *)commonParams {
    return @{@"appId":ST_REST_APP_ID,
             kEncryptionKeyName:[self class].signKey,
             @"imsi":@"999999999999999",
             @"channelNo":ST_CHANNEL_NO,
             @"pV":ST_REST_PV
             };
}

+ (NSArray *)keyOrdersOfCommonParams {
    return @[@"appId",kEncryptionKeyName,@"imsi",@"channelNo",@"pV"];
}

- (NSDictionary *)encryptWithParams:(NSDictionary *)params {
    NSMutableDictionary *mergedParams = params ? params.mutableCopy : [NSMutableDictionary dictionary];
    NSDictionary *commonParams = [[self class] commonParams];
    if (commonParams) {
        [mergedParams addEntriesFromDictionary:commonParams];
    }
    
    return [mergedParams encryptedDictionarySignedTogetherWithDictionary:commonParams keyOrders:[[self class] keyOrdersOfCommonParams] passwordKeyName:kEncryptionKeyName];
}

- (BOOL)requestURLPath:(NSString *)urlPath
            withParams:(NSDictionary *)params
       responseHandler:(STURLResponseHandler)responseHandler {
    return [self requestURLPath:urlPath
                 standbyURLPath:nil
                     withParams:params
                responseHandler:responseHandler];
}

- (BOOL)requestURLPath:(NSString *)urlPath
        standbyURLPath:(NSString *)standbyUrlPath
            withParams:(NSDictionary *)params
       responseHandler:(STURLResponseHandler)responseHandler
{
    BOOL willUseStandby = standbyUrlPath.length > 0;
    
    NSDictionary *encryptedParams = [self encryptWithParams:params];
    
    @weakify(self);
    BOOL ret = [self requestURLPath:urlPath
                         withParams:encryptedParams
                          isStandby:NO
                  shouldNotifyError:!willUseStandby
                    responseHandler:^(STURLResponseStatus respStatus, NSString *errorMessage)
    {
        @strongify(self);
        
        if (willUseStandby && respStatus == STURLResponseFailedByNetwork) {
            [self requestURLPath:standbyUrlPath withParams:params isStandby:YES shouldNotifyError:YES responseHandler:responseHandler];
        } else {
            if (responseHandler) {
                responseHandler(respStatus, errorMessage);
            }
        }
    }];
    return ret;
}

- (id)decryptResponse:(id)encryptedResponse {
    if (![encryptedResponse isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    
    NSDictionary *originalResponse = (NSDictionary *)encryptedResponse;
    NSArray *keys = [originalResponse objectForKey:kEncryptionKeyName];
    NSString *dataString = [originalResponse objectForKey:kEncryptionDataName];
    if (!keys || !dataString) {
        return nil;
    }
    
    NSString *decryptedString = [dataString decryptedStringWithKeys:keys];
    id jsonObject = [NSJSONSerialization JSONObjectWithData:[decryptedString dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];
    if (jsonObject == nil) {
        jsonObject = decryptedString;
    }
    return jsonObject;
}

- (void)processResponseObject:(id)responseObject withResponseHandler:(STURLResponseHandler)responseHandler {

    if (![responseObject isKindOfClass:[NSDictionary class]]) {
        [super processResponseObject:nil withResponseHandler:responseHandler];
        return ;
    }
    
    id decryptedResponse = [self decryptResponse:responseObject];
    DLog(@"Decrypted response: %@", decryptedResponse);
    [super processResponseObject:decryptedResponse withResponseHandler:responseHandler];
}
@end
