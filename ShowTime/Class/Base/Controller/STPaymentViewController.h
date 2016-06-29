//
//  STPaymentViewController.h
//  kuaibov
//
//  Created by Sean Yue on 15/12/9.
//  Copyright © 2015年 kuaibov. All rights reserved.
//

#import "STBaseViewController.h"

@class STProgram;
@class STPaymentInfo;

@interface STPaymentViewController : STBaseViewController

+ (instancetype)sharedPaymentVC;

//- (void)popupPaymentInView:(UIView *)view forProgram:(STProgram *)program;
- (void)popupPaymentInView:(UIView *)view forProgram:(STProgram *)program
           programLocation:(NSUInteger)programLocation
                 inChannel:(STChannel *)channel;

- (void)hidePayment;

- (void)notifyPaymentResult:(PAYRESULT)result withPaymentInfo:(STPaymentInfo *)paymentInfo;

@end
