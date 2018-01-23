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
#import "STPaymentConfig.h"
#import "STPaymentManager.h"
//#import "STAlipayConfigModel.h"
//#import "AlipayManager.h"

@interface STPaymentViewController ()
@property (nonatomic,retain) STPaymentPopView *popView;
@property (nonatomic) NSNumber *payAmount;

@property (nonatomic,retain) STProgram *programToPayFor;
@property (nonatomic,retain) STPaymentInfo *paymentInfo;

@property (nonatomic) NSUInteger programLocationToPayFor;
@property (nonatomic,retain) STChannel *channelToPayFor;

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
    void (^Pay)(STPaymentType type, STSubPayType subType) = ^(STPaymentType type, STSubPayType subType) {
        @strongify(self);
        if (!self.payAmount) {
            [[STHudManager manager] showHudWithText:@"无法获取价格信息,请检查网络配置！"];
            return ;
        }
        
        [self payForProgram:self.programToPayFor
                      price:self.payAmount.doubleValue
                paymentType:type
             paymentSubType:subType];
        [self hidePayment];
    };
    
    _popView = [[STPaymentPopView alloc] init];
    _popView.headerImageURL = [NSURL URLWithString:[STSystemConfigModel sharedModel].paymentImage];
    _popView.footerImage = [UIImage imageNamed:@"payment_footer"];
    
    STPaymentType wechatPaymentType = [[STPaymentManager sharedManager] wechatPaymentType];
    if (wechatPaymentType != STPaymentTypeNone) {
        [_popView addPaymentWithImage:[UIImage imageNamed:@"wechat_icon"] title:@"微信支付" subtitle:nil backgroundColor:[UIColor colorWithHexString:@"#05c30b"] action:^(id sender) {
            Pay(wechatPaymentType, STSubPayTypeWeChat);
        }];
    }
    
    STPaymentType alipayPaymentType = [[STPaymentManager sharedManager] alipayPaymentType];
    if (alipayPaymentType != STPaymentTypeNone) {
        [_popView addPaymentWithImage:[UIImage imageNamed:@"alipay_icon"] title:@"支付宝" subtitle:nil backgroundColor:[UIColor colorWithHexString:@"#02a0e9"] action:^(id sender) {
            Pay(alipayPaymentType, STSubPayTypeAlipay);
        }];
    }
    
    STPaymentType qqPaymentType = [[STPaymentManager sharedManager] qqPaymentType];
    if (qqPaymentType != STPaymentTypeNone) {
        [_popView addPaymentWithImage:[UIImage imageNamed:@"qq_icon"] title:@"QQ钱包" subtitle:nil backgroundColor:[UIColor redColor] action:^(id sender) {
            Pay(qqPaymentType, STSubPayTypeQQ);
        }];
    }
    
    //    STPaymentType cardPayPaymentType = [[STPaymentManager sharedManager] cardPayPaymentType];
    //    if (cardPayPaymentType != STPaymentTypeNone) {
    //        [_popView addPaymentWithImage:[UIImage imageNamed:@"card_pay_icon"] title:@"购卡支付" subtitle:@"支持微信和支付宝" backgroundColor:[UIColor colorWithHexString:@"#ff206f"] action:^(id sender) {
    //            Pay(cardPayPaymentType, STSubPayTypeNone);
    //        }];
    //    }
    
    //    if (([STPaymentConfig sharedConfig].iappPayInfo.supportPayTypes.unsignedIntegerValue & STIAppPayTypeWeChat) || [STPaymentConfig sharedConfig].weixinInfo) {
    //        BOOL useBuildInWeChatPay = [STPaymentConfig sharedConfig].weixinInfo != nil;
    //        [_popView addPaymentWithImage:[UIImage imageNamed:@"wechat_icon"] title:@"微信客户端支付" available:YES action:^(id sender) {
    //            Pay(useBuildInWeChatPay?STPaymentTypeWeChatPay:STPaymentTypeIAppPay, useBuildInWeChatPay?STPaymentTypeNone:STPaymentTypeWeChatPay);
    //        }];
    //        
    //    }
    //    
    //    if (([STPaymentConfig sharedConfig].iappPayInfo.supportPayTypes.unsignedIntegerValue & STIAppPayTypeAlipay)
    //        || [STPaymentConfig sharedConfig].alipayInfo) {
    //        BOOL useBuildInAlipay = [STPaymentConfig sharedConfig].alipayInfo != nil;
    //        [_popView addPaymentWithImage:[UIImage imageNamed:@"alipay_icon"] title:@"支付宝支付" available:YES action:^(id sender) {
    //            Pay(useBuildInAlipay?STPaymentTypeAlipay:STPaymentTypeIAppPay, useBuildInAlipay?STPaymentTypeNone:STPaymentTypeAlipay);
    //        }];
    //    }
    
    _popView.closeAction = ^(id sender){
        @strongify(self);
        [self hidePayment];
        [[STStatsManager sharedManager] statsPayWithOrderNo:nil payAction:STStatsPayActionClose payResult:PAYRESULT_UNKNOWN forProgram:self.programToPayFor programLocation:self.programLocationToPayFor inChannel:self.channelToPayFor andTabIndex:[STUtil currentTabPageIndex] subTabIndex:[STUtil currentSubTabPageIndex]];
        
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
            make.centerX.equalTo(self.view);
            const CGFloat width = MAX(kScreenWidth * 0.95, 275);
            const CGFloat height = [self.popView viewHeightRelativeToWidth:width];
            make.size.mas_equalTo(CGSizeMake(width, height));
            make.centerY.equalTo(self.view).offset(-height/20);
        }];
    }
}

- (void)popupPaymentInView:(UIView *)view forProgram:(STProgram *)program
           programLocation:(NSUInteger)programLocation
                 inChannel:(STChannel *)channel{
    if (self.view.superview) {
        [self.view removeFromSuperview];
    }
    
    self.payAmount = nil;
    self.programToPayFor = program;
    self.programLocationToPayFor = programLocation;
    self.channelToPayFor = channel;
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
        self.programToPayFor = nil;
        self.programLocationToPayFor = 0;
        self.channelToPayFor = nil;
    }];
}

- (void)payForProgram:(STProgram *)program
                price:(double)price
          paymentType:(STPaymentType)paymentType
       paymentSubType:(STSubPayType)subType
{
    @weakify(self);
    STPaymentInfo *paymentInfo = [[STPaymentManager sharedManager] startPaymentWithType:paymentType
                                                                                subType:subType
                                                                                  price:price*100
                                                                             forProgram:program
                                                                        programLocation:self.programLocationToPayFor
                                                                              inChannel:self.channelToPayFor
                                                                      completionHandler:^(PAYRESULT payResult, STPaymentInfo *paymentInfo)
                                  {
                                      @strongify(self);
                                      [self notifyPaymentResult:payResult withPaymentInfo:paymentInfo];
                                  }];
    
    if (paymentInfo) {
        [[STStatsManager sharedManager] statsPayWithPaymentInfo:paymentInfo forPayAction:STStatsPayActionGoToPay andTabIndex:[STUtil currentTabPageIndex] subTabIndex:[STUtil currentSubTabPageIndex]];
    }
    
}


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
    
    [[STStatsManager sharedManager] statsPayWithPaymentInfo:paymentInfo forPayAction:STStatsPayActionPayBack andTabIndex:[STUtil currentTabPageIndex] subTabIndex:[STUtil currentSubTabPageIndex]];
    
}

//- (void)IpaynowPluginResult:(IPNPayResult)result errCode:(NSString *)errCode errInfo:(NSString *)errInfo {
//    DLog(@"PayNow Result:%ld\nerrorCode:%@\nerrorInfo:%@", result,errCode,errInfo);
//    PAYRESULT payResult = [self paymentResultFromPayNowResult:result];
//    [self notifyPaymentResult:payResult withPaymentInfo:self.paymentInfo];
//}

@end
