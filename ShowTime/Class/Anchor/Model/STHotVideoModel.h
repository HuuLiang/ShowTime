//
//  STHotVideoModel.h
//  PhotoLibrary
//
//  Created by Sean Yue on 15/12/6.
//  Copyright © 2015年 iqu8. All rights reserved.
//

#import "STEncryptedURLRequest.h"
#import "STProgram.h"

@interface STVideos : STChannel
//@property (nonatomic) NSNumber *items;
//@property (nonatomic) NSNumber *page;
//@property (nonatomic) NSNumber *pageSize;

@end

typedef void (^STFetchVideosCompletionHandler)(BOOL success, STVideos *videos);

@interface STHotVideoModel : STEncryptedURLRequest

@property (nonatomic,retain) STVideos *fetchedVideos;

- (BOOL)fetchVideosWithPageNo:(NSUInteger)pageNo
            completionHandler:(STFetchVideosCompletionHandler)handler;

@end
