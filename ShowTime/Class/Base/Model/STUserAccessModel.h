//
//  STUserAccessModel.h
//  kuaibov
//
//  Created by Sean Yue on 15/11/26.
//  Copyright © 2015年 kuaibov. All rights reserved.
//

#import "STEncryptedURLRequest.h"

typedef void (^STUserAccessCompletionHandler)(BOOL success);

@interface STUserAccessModel : STEncryptedURLRequest

+ (instancetype)sharedModel;

- (BOOL)requestUserAccess;

@end
