//
//  STPaymentModel.h
//  kuaibov
//
//  Created by Sean Yue on 15/9/15.
//  Copyright (c) 2015年 kuaibov. All rights reserved.
//

#import "STEncryptedURLRequest.h"
#import "STPaymentInfo.h"

@interface STPaymentModel : STEncryptedURLRequest

+ (instancetype)sharedModel;

- (void)startRetryingToCommitUnprocessedOrders;
- (void)commitUnprocessedOrders;
- (BOOL)commitPaymentInfo:(STPaymentInfo *)paymentInfo;

@end
