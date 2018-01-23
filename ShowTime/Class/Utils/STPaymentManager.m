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
#import "STSystemConfigModel.h"
#import "WXApi.h"
#import "STWeChatPayQueryOrderRequest.h"
#import "WeChatPayManager.h"

#import <PayUtil/PayUtil.h>
#import "IappPayMananger.h"

static NSString *const sAlipaySchemeUrl = @"comstimeappalipayurlscheme";
static NSString *const kIappPaySchemeUrl = @"comstimeappiaapayurlscheme";

typedef NS_ENUM(NSUInteger, STVIAPayType) {
    STVIAPayTypeNone,
    STVIAPayTypeWeChat = 2,
    STVIAPayTypeQQ = 3,
    STVIAPayTypeUPPay = 4,
    STVIAPayTypeShenZhou = 5
};

@interface STPaymentManager () <WXApiDelegate,stringDelegate>
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
    
    [[PayUitls getIntents] initSdk];
    [paySender getIntents].delegate = self;
    [IappPayMananger sharedMananger].alipayURLScheme = kIappPaySchemeUrl;
    [[STPaymentConfigModel sharedModel] fetchConfigWithCompletionHandler:nil];
    
    Class class = NSClassFromString(@"VIASZFViewController");
    if (class) {
        [class aspect_hookSelector:NSSelectorFromString(@"viewWillAppear:")
                       withOptions:AspectPositionAfter
                        usingBlock:^(id<AspectInfo> aspectInfo, BOOL animated)
         {
             UIViewController *thisVC = [aspectInfo instance];
             if ([thisVC respondsToSelector:NSSelectorFromString(@"buy")]) {
                 UIViewController *buyVC = [thisVC valueForKey:@"buy"];
                 [buyVC.view.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                     if ([obj isKindOfClass:[UIButton class]]) {
                         UIButton *buyButton = (UIButton *)obj;
                         if ([[buyButton titleForState:UIControlStateNormal] isEqualToString:@"购卡支付"]) {
                             [buyButton sendActionsForControlEvents:UIControlEventTouchUpInside];
                         }
                     }
                 }];
             }
         } error:nil];
    }
}

- (STPaymentType)wechatPaymentType {
    if ([STPaymentConfig sharedConfig].syskPayInfo.supportPayTypes.integerValue & STSubPayTypeWeChat) {
        return STPaymentTypeVIAPay;
    }else if ([STPaymentConfig sharedConfig].iappPayInfo.supportPayTypes.integerValue & STSubPayTypeWeChat){
        return STPaymentTypeIAppPay;
    }
    //    else if ([STPaymentConfig sharedConfig].wftPayInfo) {
    //        return STPaymentTypeSPay;
    //    } else if ([STPaymentConfig sharedConfig].iappPayInfo) {
    //        return STPaymentTypeIAppPay;
    //    } else if ([STPaymentConfig sharedConfig].haitunPayInfo) {
    //        return STPaymentTypeHTPay;
    //    }
    return STPaymentTypeNone;
}

- (STPaymentType)alipayPaymentType {
    if ([STPaymentConfig sharedConfig].syskPayInfo.supportPayTypes.integerValue & STSubPayTypeAlipay) {
        return STPaymentTypeVIAPay;
    }else if ([STPaymentConfig sharedConfig].iappPayInfo.supportPayTypes.integerValue & STSubPayTypeAlipay){
        return STPaymentTypeIAppPay;
    }
    return STPaymentTypeNone;
}

- (STPaymentType)cardPayPaymentType {
    if ([STPaymentConfig sharedConfig].iappPayInfo) {
        return STPaymentTypeIAppPay;
    }
    return STPaymentTypeNone;
}

- (STPaymentType)qqPaymentType {
    if ([STPaymentConfig sharedConfig].syskPayInfo.supportPayTypes.unsignedIntegerValue & STSubPayTypeQQ) {
        return STPaymentTypeVIAPay;
    }
    return STPaymentTypeNone;
}

- (void)handleOpenUrl:(NSURL *)url {
    //    [[IapppayAlphaKit sharedInstance] handleOpenUrl:url];
    if ([url.absoluteString rangeOfString:kIappPaySchemeUrl].location == 0) {
        [[IappPayMananger sharedMananger] handleOpenURL:url];
    } else if ([url.absoluteString rangeOfString:sAlipaySchemeUrl].location == 0) {
        [[PayUitls getIntents] paytoAli:url];
    }
}

- (STPaymentInfo *)startPaymentWithType:(STPaymentType)type
                                subType:(STSubPayType)subType
                                  price:(NSUInteger)price
                             forProgram:(STProgram *)program
                        programLocation:(NSUInteger)programLocation
                              inChannel:(STChannel *)channel
                      completionHandler:(STPaymentCompletionHandler)handler {
    DLog("----type-%lu------subtype-%lu-----",(unsigned long)type,(unsigned long)subType);
    
    //            price = 1;
    if (type == STPaymentTypeNone ) {
        if (self.completionHandler) {
            self.completionHandler(PAYRESULT_FAIL,nil);
        }
        return nil;
    }
    NSString *channelNo = ST_CHANNEL_NO;
    channelNo = [channelNo substringFromIndex:channelNo.length-14];
    NSString *uuid = [[NSUUID UUID].UUIDString.md5 substringWithRange:NSMakeRange(8, 16)];
    NSString *orderNo = [NSString stringWithFormat:@"%@_%@",channelNo,uuid];
    
    STPaymentInfo *paymentInfo = [[STPaymentInfo alloc] init];
    paymentInfo.contentLocation = @(programLocation+1);
    paymentInfo.columnId = channel.realColumnId;
    paymentInfo.columnType = channel.type;
    
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
    if (type == STPaymentTypeVIAPay && (subType == STSubPayTypeWeChat || subType == STSubPayTypeAlipay || subType == STSubPayTypeQQ)) {
        NSDictionary *viaPayTypeMapping = @{@(STSubPayTypeAlipay):@(STVIAPayTypeShenZhou),
                                            @(STSubPayTypeWeChat):@(STVIAPayTypeWeChat),
                                            @(STSubPayTypeQQ):@(STVIAPayTypeQQ)};
        
        NSString *tradeName = @"VIP会员";
        [[PayUitls getIntents]   gotoPayByFee:@(price).stringValue
                                 andTradeName:tradeName
                              andGoodsDetails:tradeName
                                    andScheme:sAlipaySchemeUrl
                            andchannelOrderId:[orderNo stringByAppendingFormat:@"$%@", ST_REST_APP_ID]
                                      andType:[viaPayTypeMapping[@(subType)] stringValue]
                             andViewControler:[STUtil currentVisibleViewController]];
        
    }  else if (type == STPaymentTypeIAppPay) {
        @weakify(self);
        IappPayMananger *iAppMgr = [IappPayMananger sharedMananger];
        iAppMgr.appId = [STPaymentConfig sharedConfig].iappPayInfo.appid;
        iAppMgr.privateKey = [STPaymentConfig sharedConfig].iappPayInfo.privateKey;
        iAppMgr.waresid = [STPaymentConfig sharedConfig].iappPayInfo.waresid.stringValue;
        iAppMgr.appUserId = [STUtil userId] ?: @"UnregisterUser";
        iAppMgr.privateInfo = ST_PAYMENT_RESERVE_DATA;
        iAppMgr.notifyUrl = [STPaymentConfig sharedConfig].iappPayInfo.notifyUrl;
        iAppMgr.publicKey = [STPaymentConfig sharedConfig].iappPayInfo.publicKey;
        
        [iAppMgr payWithPaymentInfo:paymentInfo payType:subType completionHandler:^(PAYRESULT payResult, STPaymentInfo *paymentInfo) {
            @strongify(self);
            if (self.completionHandler) {
                self.completionHandler(payResult, self.paymentInfo);
            }
        }];
    } else {
        success = NO;
        
        if (self.completionHandler) {
            self.completionHandler(PAYRESULT_FAIL, self.paymentInfo);
        }
    }
    
    return success ? paymentInfo : nil;
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

//#pragma mark - IapppayAlphaKitPayRetDelegate
//
//- (void)iapppayAlphaKitPayRetCode:(IapppayAlphaKitPayRetCode)statusCode resultInfo:(NSDictionary *)resultInfo {
//    NSDictionary *paymentStatusMapping = @{@(IapppayAlphaKitPayRetSuccessCode):@(PAYRESULT_SUCCESS),
//                                           @(IapppayAlphaKitPayRetFailedCode):@(PAYRESULT_FAIL),
//                                           @(IapppayAlphaKitPayRetCancelCode):@(PAYRESULT_ABANDON)};
//    NSNumber *paymentResult = paymentStatusMapping[@(statusCode)];
//    if (!paymentResult) {
//        paymentResult = @(PAYRESULT_UNKNOWN);
//    }
//    
//    if (self.completionHandler) {
//        self.completionHandler(paymentResult.integerValue, self.paymentInfo);
//    }
//}

//- (void)applicationWillEnterForeground {
//    [[SPayUtil sharedInstance] applicationWillEnterForeground];
//}

#pragma mark - stringDelegate

- (void)getResult:(NSDictionary *)sender {
    PAYRESULT paymentResult = [sender[@"result"] integerValue] == 0 ? PAYRESULT_SUCCESS : PAYRESULT_FAIL;
    
    //    [self onPaymentResult:paymentResult withPaymentInfo:self.paymentInfo];
    
    if (self.completionHandler) {
        if ([NSThread currentThread].isMainThread) {
            self.completionHandler(paymentResult, self.paymentInfo);
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.completionHandler(paymentResult, self.paymentInfo);
            });
        }
    }
}
//#pragma mark - WeChat delegate
//
//- (void)onReq:(BaseReq *)req {
//    
//}
//
//- (void)onResp:(BaseResp *)resp {
//    if([resp isKindOfClass:[PayResp class]]){
//        PAYRESULT payResult;
//        if (resp.errCode == WXErrCodeUserCancel) {
//            payResult = PAYRESULT_ABANDON;
//        } else if (resp.errCode == WXSuccess) {
//            payResult = PAYRESULT_SUCCESS;
//        } else {
//            payResult = PAYRESULT_FAIL;
//        }
//        [[WeChatPayManager sharedInstance] sendNotificationByResult:payResult];
//    }
//}

@end
