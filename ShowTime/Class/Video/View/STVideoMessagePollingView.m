//
//  STVideoMessagePollingView.m
//  YuePaoBa
//
//  Created by Sean Yue on 16/2/25.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import "STVideoMessagePollingView.h"
#import "STVideoMessagePollingCell.h"

static  CGFloat offsetY = 0;

@interface STVideoMessagePollingView () <UITableViewDataSource,UITableViewDelegate>
@property (nonatomic,retain) NSMutableArray<NSAttributedString *> *messages;
@property (nonatomic,retain,readonly) NSString *cellIdentifier;
@property (nonatomic,retain) NSMutableDictionary<NSString *, UIColor *> *nameColors;
@property (nonatomic,retain) NSTimer *fadingTimer;
@property (nonatomic,assign) CGFloat cellHeight;
@end

@implementation STVideoMessagePollingView

DefineLazyPropertyInitialization(NSMutableArray, messages)
DefineLazyPropertyInitialization(NSMutableDictionary, nameColors)

- (instancetype)init {
    self = [super init];
    if (self) {
        _messageRowHeight = 35;
        
        self.estimatedRowHeight = 30;
        self.rowHeight = UITableViewAutomaticDimension;
        self.userInteractionEnabled = NO;
        self.backgroundColor = [UIColor clearColor];
        self.delegate = self;
        self.dataSource = self;
        //self.rowHeight = _messageRowHeight;
        self.separatorStyle = UITableViewCellSeparatorStyleNone;
        self.scrollEnabled = NO;
        self.bounces = NO;
        [self registerClass:[STVideoMessagePollingCell class] forCellReuseIdentifier:self.cellIdentifier];
        
    }
    return self;
}

- (void)setMessageRowHeight:(CGFloat)messageRowHeight {
    _messageRowHeight = messageRowHeight;
    //        self.rowHeight = messageRowHeight;
}

- (void)insertMessages:(NSArray *)messages forNames:(NSArray *)names withCount:(NSInteger)count {
    //    NSLog(@"-------------------------->%f",offsetY);
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
        [self.messages addObject:attributedMessage];
    }];
    
    NSUInteger numberOfRows = [self numberOfRowsInSection:0];
    NSMutableArray<NSIndexPath *> *indexPaths = [NSMutableArray array];
    for (NSUInteger i = 0; i < messages.count; ++i) {
        [indexPaths addObject:[NSIndexPath indexPathForRow:numberOfRows+i inSection:0]];
    }
    //    NSLog(@"%lu,num%lu",(unsigned long)messages.count,(unsigned long)numberOfRows);
    if (indexPaths.count > 0) {
        [UIView animateWithDuration:0.5 animations:^{
            [self insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
        }];
    }
    
    //  CGFloat frameX = CGRectGetMaxY(_pollCell.frame);
    //    CGFloat frameH = CGRectGetHeight(_pollCell.frame);
    //    
    const CGFloat offsetY1 = self.messages.count * self.messageRowHeight - CGRectGetHeight(self.bounds);
    //    if (_messages.count == 1) {
    //        
    //        offsetY = self.cellHeight  + 10+ offsetY -CGRectGetHeight(self.bounds);
    //    }else {
    //        offsetY = offsetY +10 + self.cellHeight;
    //    }
    //    
    //    NSLog(@" ------> %f,",offsetY);
    //    NSLog(@"%f,%ld,%f,--->cell %f",offsetY,(unsigned long)self.messages.count,_cellHeight,frameX);
    
    [self setContentOffset:CGPointMake(0, offsetY1) animated:YES];
    
    [self countDownFading];
    
//    NSLog(@"%lu,---->%lu",(long)count,(unsigned long)_messages.count);
    
    if (self.messages.count == count) {
       
            [self setContentOffset:CGPointMake(0, offsetY1) animated:YES];
       
    }
    //    NSLog(@" ------> %f,",offsetY1);
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
    
    if (indexPath.row < self.messages.count) {
        cell.titleLabel.attributedText = self.messages[indexPath.row];
        
    }
    //    _pollCell = [tableView cellForRowAtIndexPath:indexPath];
    //    _pollCell = self.messages[indexPath.row-1];
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.messages.count;
}
//
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    CGFloat contentW = 140;
    CGSize constraint = CGSizeMake(contentW, MAXFLOAT);
    NSAttributedString *attStr = self.messages[indexPath.row];
    
    CGRect rect = [attStr boundingRectWithSize:constraint options:NSStringDrawingUsesLineFragmentOrigin context:nil];
    
    //    CGSize size = [attStr.string sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14.]}];
    //    NSString *str = [attStr string];
    //    CGSize rec= [str sizeWithFont:[UIFont systemFontOfSize:14.] forWidth:contentW lineBreakMode:NSLineBreakByWordWrapping];
    //    rect = [str boundingRectWithSize:constraint options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14.]} context:nil];
    
    
    
    //    NSLog(@"%@--->%f,in%ld",attStr,rect.size.height,(long)indexPath.row);
    
    CGFloat cellHeight = MAX(rect.size.height, 20);
    _cellHeight = cellHeight;
    return cellHeight;
}
//
- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 36.f;
}

@end
