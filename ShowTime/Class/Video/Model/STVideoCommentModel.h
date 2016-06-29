//
//  STVideoCommentModel.h
//  ShowTime
//
//  Created by yang on 16/5/9.
//  Copyright © 2016年 iqu8. All rights reserved.
//commentList

#import "STEncryptedURLRequest.h"
#import "STVideo.h"
 
@interface STCommentResponse : STURLResponse
@property (nonatomic,retain)NSArray<STComment> *commentList;

@end

typedef void(^STCommentCompletionHandler)(BOOL Success,NSArray *commentList);

@interface STVideoCommentModel : STEncryptedURLRequest

@property (nonatomic,retain,readonly)NSArray<STComment*>*contentList;//评论数组

//获取评论(弹幕)
- (BOOL)fetchCommentWithCompletionHandler:(STCommentCompletionHandler)handler;


@end
