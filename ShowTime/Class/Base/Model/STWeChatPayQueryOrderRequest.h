//
//  STWeChatPayQueryOrderRequest.h
//  kuaibov
//
//  Created by Sean Yue on 15/11/23.
//  Copyright © 2015年 kuaibov. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^STWeChatPayQueryOrderCompletionHandler)(BOOL success, NSString *trade_state, double total_fee);

@class STPaymentInfo;
@interface STWeChatPayQueryOrderRequest : NSObject

@property (nonatomic) NSString *return_code;
@property (nonatomic) NSString *result_code;
@property (nonatomic) NSString *trade_state;
@property (nonatomic) double total_fee;

- (BOOL)queryOrderWithNo:(NSString *)orderNo completionHandler:(STWeChatPayQueryOrderCompletionHandler)handler;

@end
