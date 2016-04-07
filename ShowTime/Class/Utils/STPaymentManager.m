//
//  STPaymentManager.m
//  ShowTime
//
//  Created by Liang on 16/4/7.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import "STPaymentManager.h"
#import "STPaymentInfo.h"
#import "STPaymentViewController.h"
#import "STProgram.h"
#import "STPaymentConfigModel.h"

#import "WXApi.h"
#import "STWeChatPayQueryOrderRequest.h"
#import "WeChatPayManager.h"

#import <IapppayAlphaKit/IapppayAlphaOrderUtils.h>
#import <IapppayAlphaKit/IapppayAlphaKit.h>

static NSString *const sAlipaySchemeUrl = @"comshowtimevappalipayurlscheme";

@interface STPaymentManager () <IapppayAlphaKitPayRetDelegate,WXApiDelegate>
@property (nonatomic,retain) STPaymentInfo *paymentInfo;
@property (nonatomic,copy) STPaymentCompletionHandler completionHandler;
@property (nonatomic,retain) STWeChatPayQueryOrderRequest * wechatPayOrderQueryRequest;
@end

@implementation STPaymentManager

DefineLazyPropertyInitialization(STWeChatPayQueryOrderRequest, wechatPayOrderQueryRequest)

+ (instancetype)sharedManager {
    static STPaymentManager *_sharedManager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [[self alloc] init];
    });
     return _sharedManager;
}

- (void)setup {
    [[STPaymentConfigModel sharedModel] fetchConfigWithCompletionHandler:^(BOOL success, id obj) {
        [[IapppayAlphaKit sharedInstance] setAppAlipayScheme:sAlipaySchemeUrl];
        [[IapppayAlphaKit sharedInstance] setAppId:[STPaymentConfig sharedConfig].iappPayInfo.appid mACID:ST_CHANNEL_NO];
        [WXApi registerApp:[STPaymentConfig sharedConfig].weixinInfo.appId];
    }];
}

- (void)handleOpenURL:(NSURL *)url {
    [[IapppayAlphaKit sharedInstance] handleOpenUrl:url];
    
}

- (BOOL)startPaymentWithType:(STPaymentType)type
                     subType:(STPaymentType)subType
                       price:(NSUInteger)price
                  forProgram:(STProgram *)program
           completionHandler:(STPaymentCompletionHandler)handler {
    DLog("----type-%lu------subtype-%lu-----",(unsigned long)type,(unsigned long)subType);
    if (type == STPaymentTypeNone || (type == STPaymentTypeIAppPay && subType == STPaymentTypeNone)) {
        if (self.completionHandler) {
            self.completionHandler(PAYRESULT_FAIL,nil);
        }
        return NO;
    }

    NSString *channelNo = ST_CHANNEL_NO;
    channelNo = [channelNo substringFromIndex:channelNo.length-14];
    NSString *uuid = [[NSUUID UUID].UUIDString.md5 substringWithRange:NSMakeRange(8, 16)];
    NSString *orderNo = [NSString stringWithFormat:@"%@_%@",channelNo,uuid];
    
    STPaymentInfo *paymentInfo = [[STPaymentInfo alloc] init];
    paymentInfo.orderId = orderNo;
    paymentInfo.orderPrice = @(price);
    paymentInfo.contentId = program.programId;
    paymentInfo.contentType = program.type;
    paymentInfo.payPointType = program.payPointType;
    paymentInfo.paymentType = @(type);
    paymentInfo.paymentResult = @(PAYRESULT_UNKNOWN);
    paymentInfo.paymentStatus = @(STPaymentStatusPaying);
    
    if (type == STPaymentTypeWeChatPay) {
        paymentInfo.appId = [STPaymentConfig sharedConfig].weixinInfo.appId;
        paymentInfo.mchId = [STPaymentConfig sharedConfig].weixinInfo.mchId;
        paymentInfo.signKey = [STPaymentConfig sharedConfig].weixinInfo.signKey;
        paymentInfo.notifyUrl = [STPaymentConfig sharedConfig].weixinInfo.notifyUrl;
    }
    [paymentInfo save];
    self.paymentInfo = paymentInfo;
    self.completionHandler = handler;
    
    BOOL success = YES;
    if (type == STPaymentTypeWeChatPay) {
        @weakify(self);
        [[WeChatPayManager sharedInstance] startWeChatPayWithPayment:paymentInfo completionHandler:^(PAYRESULT payResult) {
            @strongify(self);
            if (self.completionHandler) {
                self.completionHandler(payResult, self.paymentInfo);
            }
        }];
    } else if (type == STPaymentTypeIAppPay) {
        NSDictionary *paymentTypeMapping = @{@(STPaymentTypeAlipay):@(IapppayAlphaKitAlipayPayType),
                                             @(STPaymentTypeWeChatPay):@(IapppayAlphaKitWeChatPayType)};
        NSNumber *payType = paymentTypeMapping[@(subType)];
        if (!payType) {
            return NO;
        }
        
        IapppayAlphaOrderUtils *order = [[IapppayAlphaOrderUtils alloc] init];
        order.appId = [STPaymentConfig sharedConfig].iappPayInfo.appid;
        order.cpPrivateKey = [STPaymentConfig sharedConfig].iappPayInfo.privateKey;
        order.cpOrderId = orderNo;
#ifdef DEBUG
        order.waresId = @"1";
#else
        order.waresId = [KbPaymentConfig sharedConfig].iappPayInfo.waresid;
#endif
        order.price = [NSString stringWithFormat:@"%.2f", price/100.];
        order.appUserId = [STUtil userId] ?: @"UnregisterUser";
        order.cpPrivateInfo = ST_PAYMENT_RESERVE_DATA;
        
        NSString *trandData = [order getTrandData];
        success = [[IapppayAlphaKit sharedInstance] makePayForTrandInfo:trandData
                                                          payMethodType:payType.unsignedIntegerValue
                                                            payDelegate:self];
    } else {
        success = NO;
        
        if (self.completionHandler) {
            self.completionHandler(PAYRESULT_FAIL,self.paymentInfo);
        }
    }
    
    return success;
}

- (void)checkPayment {
    NSArray<STPaymentInfo *> *payingPaymentInfos = [STUtil payingPaymentInfos];
    [payingPaymentInfos enumerateObjectsUsingBlock:^(STPaymentInfo * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        STPaymentType paymentType = obj.paymentType.unsignedIntegerValue;
        if (paymentType == STPaymentTypeWeChatPay) {
            if (obj.appId.length == 0 || obj.mchId.length == 0 || obj.signKey.length == 0 || obj.notifyUrl.length == 0) {
                obj.appId = [STPaymentConfig sharedConfig].weixinInfo.appId;
                obj.mchId = [STPaymentConfig sharedConfig].weixinInfo.mchId;
                obj.signKey = [STPaymentConfig sharedConfig].weixinInfo.signKey;
                obj.notifyUrl = [STPaymentConfig sharedConfig].weixinInfo.notifyUrl;
            }
            
            [self.wechatPayOrderQueryRequest queryOrderWithNo:obj.orderId completionHandler:^(BOOL success, NSString *trade_state, double total_fee) {
                if ([trade_state isEqualToString:@"SUCCESS"]) {
                    STPaymentViewController *paymentVC = [STPaymentViewController sharedPaymentVC];
                    [paymentVC notifyPaymentResult:PAYRESULT_SUCCESS withPaymentInfo:obj];
                }
            }];
        }
    }];
}

#pragma mark - IapppayAlphaKitPayRetDelegate

- (void)iapppayAlphaKitPayRetCode:(IapppayAlphaKitPayRetCode)statusCode resultInfo:(NSDictionary *)resultInfo {
    NSDictionary *paymentStatusMapping = @{@(IapppayAlphaKitPayRetSuccessCode):@(PAYRESULT_SUCCESS),
                                           @(IapppayAlphaKitPayRetFailedCode):@(PAYRESULT_FAIL),
                                           @(IapppayAlphaKitPayRetCancelCode):@(PAYRESULT_ABANDON)};
    NSNumber *paymentResult = paymentStatusMapping[@(statusCode)];
    if (!paymentResult) {
        paymentResult = @(PAYRESULT_UNKNOWN);
    }
    
    if (self.completionHandler) {
        self.completionHandler(paymentResult.integerValue, self.paymentInfo);
    }
}

#pragma mark - WeChat delegate

- (void)onReq:(BaseReq *)req {
    
}

- (void)onResp:(BaseResp *)resp {
    if([resp isKindOfClass:[PayResp class]]){
        PAYRESULT payResult;
        if (resp.errCode == WXErrCodeUserCancel) {
            payResult = PAYRESULT_ABANDON;
        } else if (resp.errCode == WXSuccess) {
            payResult = PAYRESULT_SUCCESS;
        } else {
            payResult = PAYRESULT_FAIL;
        }
        [[WeChatPayManager sharedInstance] sendNotificationByResult:payResult];
    }
}

@end
