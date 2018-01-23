//
//  STProgram.h
//  kuaibov
//
//  Created by Sean Yue on 15/9/6.
//  Copyright (c) 2015年 kuaibov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STURLResponse.h"
#import "STVideo.h"

typedef NS_ENUM(NSUInteger, STProgramType) {
    STProgramTypeNone = 0,
    STProgramTypeVideo = 1,
    STProgramTypePicture = 2,
    STProgramTypeAd = 3,
    STProgramTypeBanner = 4,
    STProgramTypeTrival = 5
};

@protocol STProgramUrl <NSObject>

@end

@interface STProgramUrl : NSObject
@property (nonatomic) NSNumber *programUrlId;
@property (nonatomic) NSString *title;
@property (nonatomic) NSString *url;
@property (nonatomic) NSNumber *width;
@property (nonatomic) NSNumber *height;
@end

@protocol STProgram <NSObject>

@end

@interface STProgram : STVideo

@property (nonatomic) NSNumber *programId;
@property (nonatomic) NSNumber *payPointType; // 1、会员注册 2、付费
@property (nonatomic) NSNumber *type; // 1、视频 2、图片
@property (nonatomic,retain) NSArray<STProgramUrl> *urlList; // type==2有集合，目前为图集url集合

@end

//@protocol STPrograms <NSObject>
//
//@end
//
//@interface STPrograms : STURLResponse
//@property (nonatomic) NSNumber *columnId;
//@property (nonatomic) NSString *name;
//@property (nonatomic) NSString *columnImg;
//@property (nonatomic) NSNumber *type; // 1、视频 2、图片
//@property (nonatomic) NSNumber *showNumber;
//@property (nonatomic) NSString *spreadUrl;
//@property (nonatomic,retain) NSArray<STProgram> *programList;
//@end

