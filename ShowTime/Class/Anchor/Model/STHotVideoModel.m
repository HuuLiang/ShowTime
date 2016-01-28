//
//  STHotVideoModel.m
//  PhotoLibrary
//
//  Created by Sean Yue on 15/12/6.
//  Copyright © 2015年 iqu8. All rights reserved.
//

#import "STHotVideoModel.h"

@implementation STVideos

@end

@implementation STHotVideoModel

+ (Class)responseClass {
    return [STVideos class];
}

- (BOOL)fetchVideosWithPageNo:(NSUInteger)pageNo
            completionHandler:(STFetchVideosCompletionHandler)handler
{
    @weakify(self);
    BOOL ret = [self requestURLPath:ST_HOT_VIDEO_URL
                         withParams:@{@"page":@(pageNo)}
                    responseHandler:^(STURLResponseStatus respStatus, NSString *errorMessage)
    {
        @strongify(self);
        
        STVideos *videos;
        if (respStatus == STURLResponseSuccess) {
            videos = self.response;
            self.fetchedVideos = videos;
        }
        
        if (handler) {
            handler(respStatus == STURLResponseSuccess, videos);
        }
    }];
    return ret;
}

@end
