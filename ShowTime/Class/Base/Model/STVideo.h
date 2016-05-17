//
//  STVideo.h
//  kuaibov
//
//  Created by Sean Yue on 15/9/6.
//  Copyright (c) 2015年 kuaibov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STURLResponse.h"

@interface STVideo : NSObject

@property (nonatomic) NSString *title;
@property (nonatomic) NSString *specialDesc;
@property (nonatomic) NSString *videoUrl;
@property (nonatomic) NSString *coverImg;

@end


@protocol STComment <NSObject>

@end

@interface STComment : STURLResponse

@property (nonatomic,copy)NSString *content;
@property (nonatomic,copy)NSString *userName;
@property (nonatomic,copy)NSString *icon;
@property (nonatomic,copy)NSString *createAt;

@end

