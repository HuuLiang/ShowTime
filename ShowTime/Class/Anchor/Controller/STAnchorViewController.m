//
//  STAnchorViewController.m
//  ShowTime
//
//  Created by Sean Yue on 16/1/25.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import "STAnchorViewController.h"
#import "STAnchorCell.h"
#import "STHotVideoModel.h"
#import "STSystemConfigModel.h"

static NSString *const kAnchorCellReusableIdentifier = @"AnchorCellReusableIdentifier";
static const CGFloat kInterspacing = 5;

static NSString *kAnchorAttentionArr = @"kanchorattentionarr";

@interface STAnchorViewController () <UITableViewDataSource,UITableViewDelegate>
{
//    UIImageView *_headerImageView;
    UILabel *_priceLabel;
    
    UITableView *_layoutTV;
}
@property (nonatomic,retain) STHotVideoModel *videoModel;
@property (nonatomic,retain) NSMutableArray<STProgram *> *videos;

@property (nonatomic,retain)NSArray *attentArr;//关注人数
@property (nonatomic,retain)NSArray *changePerson;//
@end

@implementation STAnchorViewController

DefineLazyPropertyInitialization(STHotVideoModel, videoModel)
DefineLazyPropertyInitialization(NSMutableArray, videos)

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    _attentArr = [defaults objectForKey:kAnchorAttentionArr];
    if (!_attentArr) {
        
        NSMutableArray *attarr = [NSMutableArray array];
        
        for (int i = 0; i<250; i++) {
            NSInteger temp = (arc4random()%10 + 2)*100;
            NSString *str = [NSString stringWithFormat:@"%ld",(long)temp];
            [attarr addObject:str];
            
        }
        _attentArr = attarr;
        [defaults setObject:attarr forKey:kAnchorAttentionArr];
    }
    
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onPaidNotification:) name:kPaidNotificationName object:nil];
    
//    if (![STUtil isPaid]) {
//        _headerImageView = [[UIImageView alloc] init];
//        _headerImageView.userInteractionEnabled = YES;
//        
//        _priceLabel = [[UILabel alloc] init];
//        _priceLabel.font = [UIFont systemFontOfSize:14.];
//        _priceLabel.textColor = [UIColor redColor];
//        _priceLabel.textAlignment = NSTextAlignmentCenter;
//        [_headerImageView addSubview:_priceLabel];
//        {
//            [_priceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//                make.left.equalTo(_headerImageView);
//                make.top.equalTo(_headerImageView.mas_centerY);
//                make.width.equalTo(_headerImageView).multipliedBy(0.1);
//                
//            }];
//        }
//        
//        @weakify(self);
//        [_headerImageView bk_whenTapped:^{
//            @strongify(self);
//            if (![STUtil isPaid]) {
//                [self payForProgram:nil];
//            };
//        }];
//        [self.view addSubview:_headerImageView];
//        {
//            [_headerImageView mas_makeConstraints:^(MASConstraintMaker *make) {
//                make.top.left.right.equalTo(self.view);
//                make.height.equalTo(_headerImageView.mas_width).multipliedBy(0.2);
//            }];
//        }
//    }
    
    _layoutTV = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    _layoutTV.backgroundColor = self.view.backgroundColor;
    _layoutTV.delegate = self;
    _layoutTV.dataSource = self;
    _layoutTV.separatorStyle = UITableViewCellSeparatorStyleNone;
    [_layoutTV registerClass:[STAnchorCell class] forCellReuseIdentifier:kAnchorCellReusableIdentifier];
    [self.view addSubview:_layoutTV];
    {
        [_layoutTV mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.top.equalTo(_headerImageView ? _headerImageView.mas_bottom : self.view);
//            make.left.equalTo(self.view).offset(kInterspacing);
//            make.right.equalTo(self.view).offset(-kInterspacing);
//            make.bottom.equalTo(self.view);
            make.edges.equalTo(self.view).insets(UIEdgeInsetsMake(0, kInterspacing, 0, kInterspacing));
        }];
    }
    
    @weakify(self);

    [_layoutTV ST_addPullToRefreshWithHandler:^{
        @strongify(self);
        [self loadVideosWithPage:1];
//        [self loadHeaderImage];
        NSMutableArray *changeArr = [NSMutableArray array];
        for (int i = 0; i<250; i++) {
            NSInteger change = arc4random_uniform(60)+40;
            NSString *changeStr = [NSString stringWithFormat:@"%ld",(long)change];
            [changeArr addObject:changeStr];}
        self.changePerson = changeArr.copy;
        
    }];
    [_layoutTV ST_triggerPullToRefresh];
    
    [_layoutTV ST_addPagingRefreshWithHandler:^{
        @strongify(self);
        
        NSUInteger currentPage = self.videoModel.fetchedVideos.page.unsignedIntegerValue;
        [self loadVideosWithPage:currentPage+1];
    }];
}

//- (void)dealloc {
//    [[NSNotificationCenter defaultCenter] removeObserver:self];
//}

//- (void)loadHeaderImage {
//    if ([STUtil isPaid]) {
//        return ;
//    }
//    
//    @weakify(self);
//    STSystemConfigModel *systemConfigModel = [STSystemConfigModel sharedModel];
//    [systemConfigModel fetchSystemConfigWithCompletionHandler:^(BOOL success) {
//        @strongify(self);
//        if (!self) {
//            return ;
//        }
//        
//        if (success) {
//            @weakify(self);
//            [self->_headerImageView sd_setImageWithURL:[NSURL URLWithString:systemConfigModel.channelTopImage]
//                                             completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL)
//             {
//                 @strongify(self);
//                 if (!self) {
//                     return ;
//                 }
//                 
//                 if (image) {
//                     double showPrice = systemConfigModel.payAmount;
//                     BOOL showInteger = (NSUInteger)(showPrice * 100) % 100 == 0;
//                     self->_priceLabel.text = showInteger ? [NSString stringWithFormat:@"%ld", (NSUInteger)showPrice] : [NSString stringWithFormat:@"%.2f", showPrice];
//                 } else {
//                     self->_priceLabel.text = nil;
//                 }
//             }];
//        }
//    }];
//}

- (void)loadVideosWithPage:(NSUInteger)page {
    @weakify(self);
    [self.videoModel fetchVideosWithPageNo:page completionHandler:^(BOOL success, STVideos *videos) {
        @strongify(self);
        if (!self) {
            return ;
        }
        
        [self->_layoutTV ST_endPullToRefresh];
        
        if (success) {
            if (page == 1) {
                [self.videos removeAllObjects];
            }
            [self.videos addObjectsFromArray:videos.programList];
            [self->_layoutTV reloadData];
            
            if (videos.items.unsignedIntegerValue == self.videos.count) {
                [self->_layoutTV ST_pagingRefreshNoMoreData];
            }
        }
    }];
}

//- (void)onPaidNotification:(NSNotification *)notification {
//    [_headerImageView removeFromSuperview];
//    _headerImageView = nil;
//    
//    [_layoutTV mas_remakeConstraints:^(MASConstraintMaker *make) {
//        make.edges.equalTo(self.view).insets(UIEdgeInsetsMake(0, kInterspacing, 0, kInterspacing));
//    }];
//}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource,UITableViewDelegate

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    STAnchorCell *cell = [tableView dequeueReusableCellWithIdentifier:kAnchorCellReusableIdentifier forIndexPath:indexPath];
    if (indexPath.section < self.videos.count) {
        STProgram *video = self.videos[indexPath.section];
        cell.imageURL = [NSURL URLWithString:video.coverImg];
        cell.title = video.title;
        NSUInteger attentText = 0;
        if (indexPath.section < self.attentArr.count) {
            NSString *attent = self.attentArr[indexPath.section];
            NSString *change = self.changePerson[indexPath.section];
            attentText = (NSUInteger)(attent.integerValue + change.integerValue);
        }
        cell.numberOfGuests = attentText;
    }
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.videos.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return CGRectGetWidth(tableView.bounds) * 0.8;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return kInterspacing;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.1;
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section {
    view.backgroundColor = tableView.backgroundColor;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section < self.videos.count) {
        STProgram *video = self.videos[indexPath.section];
        [self switchToPlayProgram:video];
    }
}
@end
