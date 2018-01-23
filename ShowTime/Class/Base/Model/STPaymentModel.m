//
//  STPaymentModel.m
//  kuaibov
//
//  Created by Sean Yue on 15/9/15.
//  Copyright (c) 2015年 kuaibov. All rights reserved.
//

#import "STPaymentModel.h"
#import "NSDictionary+STSign.h"
#import "STPaymentInfo.h"

static const NSTimeInterval kRetryingTimeInterval = 180;

static NSString *const SSignKey = @"qdge^%$#@(sdwHs^&";
static NSString *const SPaymentEncryptionPassword = @"wdnxs&*@#!*qb)*&qiang";

typedef void (^STPaymentCompletionHandler)(BOOL success);

@interface STPaymentModel ()
@property (nonatomic,retain) NSTimer *retryingTimer;
@end

@implementation STPaymentModel

+ (instancetype)sharedModel {
    static STPaymentModel *_sharedModel;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedModel = [[STPaymentModel alloc] init];
    });
    return _sharedModel;
}

- (NSURL *)baseURL {
    return nil;
}

- (BOOL)shouldPostErrorNotification {
    return NO;
}

- (STURLRequestMethod)requestMethod {
    return STURLPostRequest;
}

+ (NSString *)signKey {
    return SSignKey;
}

- (NSDictionary *)encryptWithParams:(NSDictionary *)params {
    NSDictionary *signParams = @{  @"appId":ST_REST_APP_ID,
                                   @"key":SSignKey,
                                   @"imsi":@"999999999999999",
                                   @"channelNo":ST_CHANNEL_NO,
                                   @"pV":ST_PAYMENT_PV };
    
    NSString *sign = [signParams signWithDictionary:[self class].commonParams keyOrders:[self class].keyOrdersOfCommonParams];
    NSString *encryptedDataString = [params encryptedStringWithSign:sign password:SPaymentEncryptionPassword excludeKeys:@[@"key"]];
    return @{@"data":encryptedDataString, @"appId":ST_REST_APP_ID};
}

- (void)startRetryingToCommitUnprocessedOrders {
    if (!self.retryingTimer) {
        @weakify(self);
        self.retryingTimer = [NSTimer bk_scheduledTimerWithTimeInterval:kRetryingTimeInterval block:^(NSTimer *timer) {
            @strongify(self);
            DLog(@"Payment: on retrying to commit unprocessed orders!");
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                [self commitUnprocessedOrders];
            });
        } repeats:YES];
    }
}

- (void)stopRetryingToCommitUnprocessedOrders {
    [self.retryingTimer invalidate];
    self.retryingTimer = nil;
}

- (void)commitUnprocessedOrders {
    NSArray<STPaymentInfo *> *unprocessedPaymentInfos = [STUtil paidNotProcessedPaymentInfos];
    [unprocessedPaymentInfos enumerateObjectsUsingBlock:^(STPaymentInfo * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [self commitPaymentInfo:obj];
    }];
}

- (BOOL)commitPaymentInfo:(STPaymentInfo *)paymentInfo {
    return [self commitPaymentInfo:paymentInfo withCompletionHandler:nil];
}

- (BOOL)commitPaymentInfo:(STPaymentInfo *)paymentInfo withCompletionHandler:(STPaymentCompletionHandler)handler {
    NSDictionary *statusDic = @{@(PAYRESULT_SUCCESS):@(1), @(PAYRESULT_FAIL):@(0), @(PAYRESULT_ABANDON):@(2), @(PAYRESULT_UNKNOWN):@(0)};
    
    if (nil == [STUtil userId] || paymentInfo.orderId.length == 0) {
        return NO;
    }
    
    NSDictionary *params = @{@"uuid":[STUtil userId],
                             @"orderNo":paymentInfo.orderId,
                             @"imsi":@"999999999999999",
                             @"imei":@"999999999999999",
                             @"payMoney":paymentInfo.orderPrice.stringValue,
                             @"channelNo":ST_CHANNEL_NO,
                             @"contentId":paymentInfo.contentId.stringValue ?: @"0",
                             @"contentType":paymentInfo.contentType.stringValue ?: @"0",
                             @"pluginType":paymentInfo.paymentType,
                             @"payPointType":paymentInfo.payPointType ?: @"1",
                             @"appId":ST_REST_APP_ID,
                             @"versionNo":@(ST_REST_APP_VERSION.integerValue),
                             @"status":statusDic[paymentInfo.paymentResult],
                             @"pV":ST_PAYMENT_PV,
                             @"payTime":paymentInfo.paymentTime};
    
    BOOL success = [super requestURLPath:ST_PAYMENT_COMMIT_URL
                              withParams:params
                         responseHandler:^(STURLResponseStatus respStatus, NSString *errorMessage)
    {
        if (respStatus == STURLResponseSuccess) {
            paymentInfo.paymentStatus = @(STPaymentStatusProcessed);
            [paymentInfo save];
        } else {
            DLog(@"Payment: fails to commit the order with orderId:%@", paymentInfo.orderId);
        }
                        
        if (handler) {
            handler(respStatus == STURLResponseSuccess);
        }
    }];
    return success;
}

- (void)processResponseObject:(id)responseObject withResponseHandler:(STURLResponseHandler)responseHandler {
    NSDictionary *decryptedResponse = [self decryptResponse:responseObject];
    DLog(@"Payment response : %@", decryptedResponse);
    NSNumber *respCode = decryptedResponse[@"response_code"];
    STURLResponseStatus status = (respCode.unsignedIntegerValue == 100) ? STURLResponseSuccess : STURLResponseFailedByInterface;
    if (responseHandler) {
        responseHandler(status, nil);
    }
}
@end
