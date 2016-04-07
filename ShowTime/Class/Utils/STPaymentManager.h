//
//  STPaymentManager.h
//  ShowTime
//
//  Created by Liang on 16/4/7.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import <Foundation/Foundation.h>

@class STProgram;

typedef void(^STPaymentCompletionHandler)(PAYRESULT payResult, STPaymentInfo *paymentInfo);

@interface STPaymentManager : NSObject

+ (instancetype)sharedManager;

- (void)setup;

- (BOOL)startPaymentWithType:(STPaymentType)type
                     subType:(STPaymentType)subType
                       price:(NSUInteger)price
                  forProgram:(STProgram *)program
           completionHandler:(STPaymentCompletionHandler)handler;

- (void)handleOpenURL:(NSURL *)url;
- (void)checkPayment;

@end
