//
//  STSystemConfig.h
//  kuaibov
//
//  Created by Sean Yue on 15/9/10.
//  Copyright (c) 2015年 kuaibov. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol STSystemConfig <NSObject>

@end

@interface STSystemConfig : NSObject

@property (nonatomic) NSString *name;
@property (nonatomic) NSString *value;
@property (nonatomic) NSString *memo;
@property (nonatomic) NSString *channelNo;
@property (nonatomic) NSString *status;

@end