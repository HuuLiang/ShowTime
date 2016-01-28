//
//  STPaymentViewController.m
//  kuaibov
//
//  Created by Sean Yue on 15/12/9.
//  Copyright © 2015年 kuaibov. All rights reserved.
//

#import "STPaymentViewController.h"
#import "STPaymentPopView.h"
#import "STSystemConfigModel.h"
#import "STPaymentModel.h"
#import <objc/runtime.h>
#import "STProgram.h"
#import "WeChatPayManager.h"
#import "STPaymentInfo.h"
#import "STWeChatPayConfigModel.h"
#import "STAlipayConfigModel.h"
#import "AlipayManager.h"

@interface STPaymentViewController ()
@property (nonatomic,retain) STPaymentPopView *popView;
@property (nonatomic) NSNumber *payAmount;

@property (nonatomic,retain) STProgram *programToPayFor;
@property (nonatomic,retain) STPaymentInfo *paymentInfo;

@property (nonatomic,readonly,retain) NSDictionary *paymentTypeMap;
@end

@implementation STPaymentViewController
@synthesize paymentTypeMap = _paymentTypeMap;

+ (instancetype)sharedPaymentVC {
    static STPaymentViewController *_sharedPaymentVC;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedPaymentVC = [[STPaymentViewController alloc] init];
    });
    return _sharedPaymentVC;
}

- (STPaymentPopView *)popView {
    if (_popView) {
        return _popView;
    }
    
    @weakify(self);
    void (^Pay)(STPaymentType type) = ^(STPaymentType type) {
        @strongify(self);
        if (!self.payAmount) {
            [[STHudManager manager] showHudWithText:@"无法获取价格信息,请检查网络配置！"];
            return ;
        }
        
        [self payForProgram:self.programToPayFor
                      price:self.payAmount.doubleValue
                paymentType:type];
    };
    
    _popView = [[STPaymentPopView alloc] init];
    _popView.headerImageURL = [NSURL URLWithString:[STSystemConfigModel sharedModel].paymentImage];
    _popView.footerImage = [UIImage imageNamed:@"payment_footer"];
    [_popView addPaymentWithImage:[UIImage imageNamed:@"alipay_icon"] title:@"支付宝支付" available:YES action:^(id sender) {
        Pay(STPaymentTypeAlipay);
    }];
    
    [_popView addPaymentWithImage:[UIImage imageNamed:@"wechat_icon"] title:@"微信客户端支付" available:YES action:^(id sender) {
        Pay(STPaymentTypeWeChatPay);
    }];
    
    _popView.closeAction = ^(id sender){
        @strongify(self);
        [self hidePayment];
    };
    return _popView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.8];
    [self.view addSubview:self.popView];
    {
        [self.popView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self.view);
            
            const CGFloat width = kScreenWidth * 0.95;
            make.size.mas_equalTo(CGSizeMake(width, [self.popView viewHeightRelativeToWidth:width]));
        }];
    }
}

- (void)popupPaymentInView:(UIView *)view forProgram:(STProgram *)program {
    if (self.view.superview) {
        [self.view removeFromSuperview];
    }
    
    self.payAmount = nil;
    self.programToPayFor = program;
    self.view.frame = view.bounds;
    self.view.alpha = 0;
    
    if (view == [UIApplication sharedApplication].keyWindow) {
        [view insertSubview:self.view belowSubview:[STHudManager manager].hudView];
    } else {
        [view addSubview:self.view];
    }
    
    [UIView animateWithDuration:0.25 animations:^{
        self.view.alpha = 1.0;
    }];
    
    [self fetchPayAmount];
}

- (void)fetchPayAmount {
    @weakify(self);
    STSystemConfigModel *systemConfigModel = [STSystemConfigModel sharedModel];
    [systemConfigModel fetchSystemConfigWithCompletionHandler:^(BOOL success) {
        @strongify(self);
        if (success) {
#ifdef DEBUG
            self.payAmount = @(0.01);
#else
            self.payAmount = @(systemConfigModel.payAmount);
#endif
        }
    }];
}

- (void)setPayAmount:(NSNumber *)payAmount {
//#ifdef DEBUG
//    payAmount = @(0.1);
//#endif
    _payAmount = payAmount;
    self.popView.showPrice = payAmount;
}

- (void)hidePayment {
    [UIView animateWithDuration:0.25 animations:^{
        self.view.alpha = 0;
    } completion:^(BOOL finished) {
        [self.view removeFromSuperview];
    }];
}

- (void)payForProgram:(STProgram *)program
                price:(double)price
          paymentType:(STPaymentType)paymentType {
    @weakify(self);
    NSString *channelNo = ST_CHANNEL_NO;
    channelNo = [channelNo substringFromIndex:channelNo.length-14];
    NSString *uuid = [[NSUUID UUID].UUIDString.md5 substringWithRange:NSMakeRange(8, 16)];
    NSString *orderNo = [NSString stringWithFormat:@"%@_%@", channelNo, uuid];
    
    void (^SetPayment)(void) = ^{
        @strongify(self);
        STPaymentInfo *paymentInfo = [[STPaymentInfo alloc] init];
        paymentInfo.orderId = orderNo;
        paymentInfo.orderPrice = @((NSUInteger)(price * 100));
        paymentInfo.contentId = program.programId;
        paymentInfo.contentType = program.type;
        paymentInfo.payPointType = program.payPointType;
        paymentInfo.paymentType = @(paymentType);
        paymentInfo.paymentResult = @(PAYRESULT_UNKNOWN);
        paymentInfo.paymentStatus = @(STPaymentStatusPaying);
        [paymentInfo save];
        self.paymentInfo = paymentInfo;
    };
    
    if (paymentType == STPaymentTypeWeChatPay) {
        // Payment info
        void (^PayBlock)(void) = ^{
            @strongify(self);
            STWeChatPayConfig *config = [STWeChatPayConfig defaultConfig];
            if (!config.isValid) {
                [[STHudManager manager] showHudWithText:@"无法获取微信支付信息"];
                return ;
            }
            
            SetPayment();
            [[WeChatPayManager sharedInstance] startWeChatPayWithOrderNo:orderNo price:price completionHandler:^(PAYRESULT payResult) {
                [self notifyPaymentResult:payResult withPaymentInfo:self.paymentInfo];
            }];
        };
        
        STWeChatPayConfig *config = [STWeChatPayConfig defaultConfig];
        if (config.isValid) {
            PayBlock();
        } else {
            [[STWeChatPayConfigModel sharedModel] fetchWeChatPayConfigWithCompletionHandler:^(BOOL success, id obj) {
                PayBlock();
            }];
        }
    } else if (paymentType == STPaymentTypeAlipay) {
        void (^PayBlock)(void) = ^{
            @strongify(self);
            STAlipayConfig *config = [STAlipayConfig defaultConfig];
            if (!config.isValid) {
                [[STHudManager manager] showHudWithText:@"无法获取支付宝支付信息"];
                return ;
            }
            
            SetPayment();
            [[AlipayManager shareInstance] startAlipay:orderNo price:price withResult:^(PAYRESULT result, Order *order) {
                [self notifyPaymentResult:result withPaymentInfo:self.paymentInfo];
            }];
        };
        
        STAlipayConfig *config = [STAlipayConfig defaultConfig];
        if (config.isValid) {
            PayBlock();
        } else {
            [[STAlipayConfigModel sharedModel] fetchAlipayConfigWithCompletionHandler:^(BOOL success, id obj) {
                PayBlock();
            }];
        }
//        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//        [dateFormatter setDateFormat:@"yyyyMMddHHmmss"];
//        
//        IPNPreSignMessageUtil *preSign =[[IPNPreSignMessageUtil alloc] init];
//        preSign.consumerId = KB_CHANNEL_NO;
//        preSign.mhtOrderNo = orderNo;
//        preSign.mhtOrderName = [NSBundle mainBundle].infoDictionary[@"CFBundleDisplayName"] ?: @"家庭影院";
//        preSign.mhtOrderType = kPayNowNormalOrderType;
//        preSign.mhtCurrencyType = kPayNowRMBCurrencyType;
//        preSign.mhtOrderAmt = [NSString stringWithFormat:@"%ld", @(price*100).unsignedIntegerValue];
//        preSign.mhtOrderDetail = [preSign.mhtOrderName stringByAppendingString:@"终身会员"];
//        preSign.mhtOrderStartTime = [dateFormatter stringFromDate:[NSDate date]];
//        preSign.mhtCharset = kPayNowDefaultCharset;
//        preSign.payChannelType = ((NSNumber *)self.paymentTypeMap[@(paymentType)]).stringValue;
//        preSign.mhtReserved = KB_PAYMENT_RESERVE_DATA;
//        
//        [[STPaymentSignModel sharedModel] signWithPreSignMessage:preSign completionHandler:^(BOOL success, NSString *signedData) {
//            @strongify(self);
//            if (success && [STPaymentSignModel sharedModel].appId.length > 0) {
//                [IpaynowPluginApi pay:signedData AndScheme:KB_PAYNOW_SCHEME viewController:self delegate:self];
//            } else {
//                [[STHudManager manager] showHudWithText:@"无法获取支付信息"];
//            }
//        }];
    }
}

//- (NSDictionary *)paymentTypeMap {
//    if (_paymentTypeMap) {
//        return _paymentTypeMap;
//    }
//    
//    _paymentTypeMap = @{@(STPaymentTypeAlipay):@(PayNowChannelTypeAlipay),
//                          @(STPaymentTypeWeChatPay):@(PayNowChannelTypeWeChatPay),
//                          @(STPaymentTypeUPPay):@(PayNowChannelTypeUPPay)};
//    return _paymentTypeMap;
//}

//- (STPaymentType)paymentTypeFromPayNowType:(PayNowChannelType)type {
//    __block STPaymentType retType = STPaymentTypeNone;
//    [self.paymentTypeMap enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
//        if ([(NSNumber *)obj isEqualToNumber:@(type)]) {
//            retType = ((NSNumber *)key).unsignedIntegerValue;
//            *stop = YES;
//            return ;
//        }
//    }];
//    return retType;
//}
//
//- (PayNowChannelType)payNowTypeFromPaymentType:(STPaymentType)type {
//    return ((NSNumber *)self.paymentTypeMap[@(type)]).unsignedIntegerValue;
//}
//
//- (PAYRESULT)paymentResultFromPayNowResult:(IPNPayResult)result {
//    NSDictionary *resultMap = @{@(IPNPayResultSuccess):@(PAYRESULT_SUCCESS),
//                                @(IPNPayResultFail):@(PAYRESULT_FAIL),
//                                @(IPNPayResultCancel):@(PAYRESULT_ABANDON),
//                                @(IPNPayResultUnknown):@(PAYRESULT_UNKNOWN)};
//    return ((NSNumber *)resultMap[@(result)]).unsignedIntegerValue;
//}
//
//-(IPNPayResult)paymentResultFromPayresult:(PAYRESULT)result{
//    NSDictionary *resultMap = @{@(PAYRESULT_SUCCESS):@(IPNPayResultSuccess),
//                                @(PAYRESULT_FAIL):@(IPNPayResultFail),
//                                @(PAYRESULT_ABANDON):@(IPNPayResultCancel),
//                                @(PAYRESULT_UNKNOWN):@(IPNPayResultUnknown)};
//    return ((NSNumber *)resultMap[@(result)]).unsignedIntegerValue;
//}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)notifyPaymentResult:(PAYRESULT)result withPaymentInfo:(STPaymentInfo *)paymentInfo {
    NSDateFormatter *dateFormmater = [[NSDateFormatter alloc] init];
    [dateFormmater setDateFormat:@"yyyyMMddHHmmss"];
    
    paymentInfo.paymentResult = @(result);
    paymentInfo.paymentStatus = @(STPaymentStatusNotProcessed);
    paymentInfo.paymentTime = [dateFormmater stringFromDate:[NSDate date]];
    [paymentInfo save];
    
    if (result == PAYRESULT_SUCCESS) {
        [self hidePayment];
        [[STHudManager manager] showHudWithText:@"支付成功"];
        [[NSNotificationCenter defaultCenter] postNotificationName:kPaidNotificationName object:nil];
    } else if (result == PAYRESULT_ABANDON) {
        [[STHudManager manager] showHudWithText:@"支付取消"];
    } else {
        [[STHudManager manager] showHudWithText:@"支付失败"];
    }
    
    [[STPaymentModel sharedModel] commitPaymentInfo:paymentInfo];
}

//- (void)IpaynowPluginResult:(IPNPayResult)result errCode:(NSString *)errCode errInfo:(NSString *)errInfo {
//    DLog(@"PayNow Result:%ld\nerrorCode:%@\nerrorInfo:%@", result,errCode,errInfo);
//    PAYRESULT payResult = [self paymentResultFromPayNowResult:result];
//    [self notifyPaymentResult:payResult withPaymentInfo:self.paymentInfo];
//}

@end
