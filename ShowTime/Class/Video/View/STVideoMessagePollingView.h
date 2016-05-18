//
//  STVideoMessagePollingView.h
//  YuePaoBa
//
//  Created by Sean Yue on 16/2/25.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface STVideoMessagePollingView : UITableView

//@property (nonatomic,readonly) NSUInteger maximumDisplayingMessages;
@property (nonatomic) CGFloat messageRowHeight;

//- (instancetype)initWithMaximumDisplayingMessages:(NSUInteger)maximumDisplayingMessages;

//- (void)startPolling;
//- (void)insertMessage:(NSString *)message forName:(NSString *)name;
- (void)insertMessages:(NSArray *)messages forNames:(NSArray *)names withCount:(NSInteger)count;

@end
