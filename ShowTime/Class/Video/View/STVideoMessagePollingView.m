//
//  STVideoMessagePollingView.m
//  YuePaoBa
//
//  Created by Sean Yue on 16/2/25.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import "STVideoMessagePollingView.h"
#import "STVideoMessagePollingCell.h"
#import "NSString+Size.h"
#import "UITableView+FDTemplateLayoutCell.h"


@interface STVideoMessagePollingView () <UITableViewDataSource,UITableViewDelegate>
@property (nonatomic,retain) NSMutableArray<NSAttributedString *> *messages;
@property (nonatomic,retain,readonly) NSString *cellIdentifier;
@property (nonatomic,retain) NSMutableDictionary<NSString *, UIColor *> *nameColors;
@property (nonatomic,retain) NSTimer *fadingTimer;
@property (nonatomic,retain) NSMutableArray *cellHeights;
@property (nonatomic,retain) NSMutableArray<NSIndexPath *> *indexPaths;
@end

@implementation STVideoMessagePollingView

DefineLazyPropertyInitialization(NSMutableArray, messages)
DefineLazyPropertyInitialization(NSMutableDictionary, nameColors)
DefineLazyPropertyInitialization(NSMutableArray, cellHeights)
//DefineLazyPropertyInitialization(NSMutableArray, indexPaths)


- (instancetype)init {
    self = [super init];
    if (self) {
        _messageRowHeight = 25;
        
        //        self.estimatedRowHeight = 30;
        //        self.rowHeight = UITableViewAutomaticDimension;
        self.userInteractionEnabled = NO;
        self.backgroundColor = [UIColor clearColor];
        self.delegate = self;
        self.dataSource = self;
        //self.rowHeight = _messageRowHeight;
        self.separatorStyle = UITableViewCellSeparatorStyleNone;
        self.scrollEnabled = NO;
        self.bounces = NO;
        [self registerClass:[STVideoMessagePollingCell class] forCellReuseIdentifier:self.cellIdentifier];
        self.fd_debugLogEnabled = YES;
    }
    return self;
}

- (void)setMessageRowHeight:(CGFloat)messageRowHeight {
    _messageRowHeight = messageRowHeight;
    self.rowHeight = messageRowHeight;
}

- (void)insertMessages:(NSArray *)messages forNames:(NSArray *)names withCount:(NSInteger)count {
    
    [self.fadingTimer invalidate];
    self.fadingTimer = nil;
    
    if (self.alpha == 0) {
        [self clearMessages];
        self.alpha = 1;
    }
    
    [messages enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *message = obj;
        NSString *name = @"";
        if (names.count > idx) {
            name = names[idx];
        }
        
        UIColor *nameColor = [self.nameColors objectForKey:name];
        if (!nameColor) {
            nameColor = [UIColor colorWithRed:(128+arc4random_uniform(128))/256. green:(128+arc4random_uniform(128))/256. blue:(128+arc4random_uniform(128))/256. alpha:1];
            [self.nameColors setObject:nameColor forKey:name];
        }
        
        NSMutableAttributedString *attributedMessage = [[NSMutableAttributedString alloc] init];
        [attributedMessage appendAttributedString:[[NSAttributedString alloc] initWithString:name attributes:@{NSForegroundColorAttributeName:nameColor}]];
        [attributedMessage appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@":%@", message] attributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}]];
        
        NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
        style.headIndent = 5;//缩进
        style.firstLineHeadIndent = 5;
        style.lineSpacing = 2;//行距
        [attributedMessage addAttribute:NSParagraphStyleAttributeName value:style range:NSMakeRange(0, attributedMessage.length)];
        [attributedMessage addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:14.] range:NSMakeRange(0, attributedMessage.length)];
        //计算行高
        CGFloat contentW = kScreenWidth *0.75 - 15;
        NSString *str = attributedMessage.string;
        CGSize size = [str sizeWithFont:[UIFont systemFontOfSize:17.] maxWidth:contentW];
        NSString * heigth = [NSString stringWithFormat:@"%f",size.height];
        [self.cellHeights addObject:heigth];
        
        [self.messages addObject:attributedMessage];
    }];
    
    NSUInteger numberOfRows = [self numberOfRowsInSection:0];
    //    NSMutableArray<NSIndexPath *> *indexPaths = [NSMutableArray array];
    //    for (NSUInteger i = 0; i < messages.count; ++i) {
    //        [indexPaths addObject:[NSIndexPath indexPathForRow:numberOfRows+i inSection:0]];
    //    }
    //    if (!_indexPaths) {
    
    _indexPaths = [NSMutableArray array];
    //    }
    [_indexPaths addObject:[NSIndexPath indexPathForRow:numberOfRows + messages.count-1 inSection:0]];
    if (_indexPaths.count > 0) {
        [self insertRowsAtIndexPaths:_indexPaths withRowAnimation:UITableViewRowAnimationNone];
    }
    
    //
    //    const CGFloat offsetY = self.messages.count * self.messageRowHeight - CGRectGetHeight(self.bounds);
    //    NSLog(@"%f",offsetY);
    //    [self setContentOffset:CGPointMake(0, offsetY) animated:YES];
    [self scrollToRowAtIndexPath:_indexPaths.lastObject atScrollPosition:UITableViewScrollPositionBottom animated:NO];
    
    [self countDownFading];
    
}


- (void)clearMessages {
    [self.messages removeAllObjects];
    [self reloadData];
}

- (void)countDownFading {
    @weakify(self);
    self.fadingTimer = [NSTimer bk_scheduledTimerWithTimeInterval:5 block:^(NSTimer *timer) {
        @strongify(self);
        if (!timer) {
            return ;
        }
        
        [UIView animateWithDuration:1 animations:^{
            self.alpha = 0;
        } completion:^(BOOL finished) {
            if (finished && self.alpha == 0) {
                [self clearMessages];
                self.alpha = 1;
            }
        }];
    } repeats:NO];
}

- (NSString *)cellIdentifier {
    return @"VideoMessagePollingCellReusableIdentifier";
}

#pragma mark - UITableViewDataSource,UITableViewDelegate

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    STVideoMessagePollingCell *cell = [tableView dequeueReusableCellWithIdentifier:self.cellIdentifier forIndexPath:indexPath];
    //    if (!cell) {
    //        cell = [[STVideoMessagePollingCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:self.cellIdentifier];
    //    }
    
    
    if (indexPath.row < self.messages.count) {
        cell.titleLabel.attributedText = self.messages[indexPath.row];
        cell.fd_enforceFrameLayout = YES;
        //        cell.fd_isTemplateLayoutCell = NO;
    }
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.messages.count;
}
//
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    //
    //        CGFloat contentW = kScreenWidth *0.75 - 30;
    //        CGSize constraint = CGSizeMake(contentW, MAXFLOAT);
    //        NSAttributedString *attStr = self.messages[indexPath.row];
    //
    //        CGRect rect = [attStr boundingRectWithSize:constraint options:NSStringDrawingUsesLineFragmentOrigin context:nil];
    //
    //        CGFloat cellHeight = MAX(rect.size.height, 20);
    
    //    CGFloat contentW = kScreenWidth *0.75 - 30;
    //    NSString *str = self.messages[indexPath.row].string;
    //    CGSize size = [str sizeWithFont:[UIFont systemFontOfSize:17.] maxWidth:contentW];
    //    CGFloat height = [self.cellHeights[indexPath.row] floatValue];
    //    return height;
    return [tableView fd_heightForCellWithIdentifier:self.cellIdentifier cacheByIndexPath:indexPath configuration:^(STVideoMessagePollingCell* cell) {
        cell.titleLabel.attributedText = self.messages[indexPath.row];
        
    }];
}
//
- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
    return 35.f;
}

@end
