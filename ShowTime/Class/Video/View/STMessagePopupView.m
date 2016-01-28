//
//  STMessagePopupView.m
//  ShowTime
//
//  Created by Sean Yue on 16/1/27.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import "STMessagePopupView.h"

static NSString *const kMessageCellReusableIdentifier = @"MessageCellReusableIdentifier";

@interface STMessagePopupView () <UITableViewDataSource,UITableViewDelegate>
@property (nonatomic,retain) NSArray<NSString *> *messages;
@end

@implementation STMessagePopupView

- (instancetype)init {
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor colorWithWhite:0.1 alpha:1];
        self.layer.cornerRadius = 4;
        self.layer.masksToBounds = YES;
        self.delegate = self;
        self.dataSource = self;
        self.rowHeight = 44;
        self.separatorStyle = UITableViewCellSeparatorStyleNone;
        self.scrollEnabled = NO;
        [self registerClass:[UITableViewCell class] forCellReuseIdentifier:kMessageCellReusableIdentifier];
    }
    return self;
}

- (NSArray<NSString *> *)messages {
    if (_messages) {
        return _messages;
    }
    
    _messages = @[@"主播再露一点！", @"这个主播太美啦！", @"观众老爷们给主播点赞！", @"裤子都脱了就给我看这个！"];
    return _messages;
}

- (void)showInView:(UIView *)view atLeftBottomPosition:(CGPoint)leftBottomPos width:(CGFloat)width {
    self.alpha = 0;
    if (![view.subviews containsObject:self]) {
        [view addSubview:self];
    }
    
    const CGFloat height = self.messages.count * self.rowHeight;
    CGRect frame = CGRectMake(leftBottomPos.x, leftBottomPos.y-height, width, height);
    self.frame = frame;
    
    [UIView animateWithDuration:0.3 animations:^{
        self.alpha = 1;
    }];
}

- (void)hide {
    if (self.superview) {
        
        [UIView animateWithDuration:0.3 animations:^{
            self.alpha = 0;
        } completion:^(BOOL finished) {
            [self removeFromSuperview];
        }];
    }
}

#pragma mark - UITableViewDataSource,UITableViewDelegate

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kMessageCellReusableIdentifier forIndexPath:indexPath];
    cell.backgroundColor = tableView.backgroundColor;
    
    NSString *message = self.messages[indexPath.row];
    cell.textLabel.text = message;
    cell.textLabel.textColor = [UIColor whiteColor];
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.messages.count;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    [self hide];
    
    if (self.selectAction) {
        self.selectAction(self.messages[indexPath.row]);
    }
}
@end
