//
//  STHomeViewController.m
//  ShowTime
//
//  Created by Sean Yue on 16/1/25.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import "STHomeViewController.h"
#import "STHomeCell.h"
#import "STHomeCollectionHeaderView.h"
#import "STHomeProgramModel.h"

NSInteger items = 300;//生成随机人数的数量,如果后台可以获取到总共的items则需要换成后台获取的items

static NSString *const kNormalCellReusableIdentifier = @"NormalCellReusableIdentifier";
//static NSString *const kBannerCellReusableIdentifier = @"BannerCellReusableIdentifier";
static NSString *const kHeaderViewReusableIdentifier = @"HeaderViewReusableIdentifier";

static const CGFloat kInteritemSpacing = 5;
static NSString *kHomeAttentionArr = @"khomeattentionarr";


@interface STHomeViewController () <UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>
{
    UICollectionView *_layoutCV;
}
@property (nonatomic,retain) STHomeProgramModel *programModel;

@property (nonatomic,readonly) CGSize normalCellSize;
@property (nonatomic,readonly) CGSize bannerCellSize;

@property (nonatomic,retain)NSArray *attentArr;//关注人数
@property (nonatomic,retain)NSArray *changePerson;//
@end

@implementation STHomeViewController
@synthesize normalCellSize = _normalCellSize;
@synthesize bannerCellSize = _bannerCellSize;

DefineLazyPropertyInitialization(STHomeProgramModel, programModel)

//- (void)viewWillAppear:(BOOL)animated {
//    [super viewWillAppear:animated];
//    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
//    _attentArr = [defaults objectForKey:kHomeAttentionArr];
//    if (!_attentArr) {
//        
//        NSMutableArray *attarr = [NSMutableArray array];
//        
//        for (int i = 0; i<250; i++) {
//            NSInteger temp = (arc4random()%10 + 2)*100;
//            NSString *str = [NSString stringWithFormat:@"%ld",(long)temp];
//            [attarr addObject:str];
//            
//        }
//        _attentArr = attarr;
//        [defaults setObject:attarr forKey:kHomeAttentionArr];
//    }
//    
//}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.minimumInteritemSpacing = kInteritemSpacing;
    layout.minimumLineSpacing = kInteritemSpacing;
    
    _layoutCV = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    _layoutCV.backgroundColor = self.view.backgroundColor;
    _layoutCV.delegate = self;
    _layoutCV.dataSource = self;
    _layoutCV.contentInset = UIEdgeInsetsMake(0, 0, 30, 0);
    [_layoutCV registerClass:[STHomeCell class] forCellWithReuseIdentifier:kNormalCellReusableIdentifier];
    //[_layoutCV registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:kBannerCellReusableIdentifier];
    [_layoutCV registerClass:[STHomeCollectionHeaderView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:kHeaderViewReusableIdentifier];
    [self.view addSubview:_layoutCV];
    {
        [_layoutCV mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view);
        }];
    }
    
    @weakify(self);
    [_layoutCV ST_addPullToRefreshWithHandler:^{
        @strongify(self);
        [self reloadPrograms];
//        NSMutableArray *changeArr = [NSMutableArray array];
//        for (int i = 0; i<250; i++) {
//            NSInteger change = arc4random_uniform(60)+40;
//            NSString *changeStr = [NSString stringWithFormat:@"%ld",(long)change];
//            [changeArr addObject:changeStr];}
//         self.changePerson = changeArr.copy;
    }];
    [_layoutCV ST_triggerPullToRefresh];
}

- (void)reloadPrograms {
    @weakify(self);
    [self.programModel fetchHomeProgramsWithCompletionHandler:^(BOOL success, NSArray *programs) {
        @strongify(self);
        
        if (success) {
            [self attentPerson];
            [self->_layoutCV reloadData];
        }
        [self->_layoutCV ST_endPullToRefresh];
    }];
}

//关注的人数(客户端随机生成)
- (void)attentPerson{
    NSInteger allItems = 0;
    for (STChannel *channel in _programModel.fetchedProgramList) {
        allItems = (channel.items.integerValue) + allItems;
    }
    items = allItems ? allItems : items ;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    _attentArr = [defaults objectForKey:kHomeAttentionArr];
    if (_attentArr.count != items || _attentArr.count==0 ) {
        
        NSMutableArray *attarr = [NSMutableArray array];
        
        for (int i = 0; i<items; i++) {
            NSInteger temp = (arc4random()%50 + 10)*100;
            NSString *str = [NSString stringWithFormat:@"%ld",(long)temp];
            [attarr addObject:str];
            
        }
        _attentArr = attarr;
        [defaults setObject:attarr forKey:kHomeAttentionArr];
    }
    
    NSMutableArray *changeArr = [NSMutableArray array];
    for (int i = 0; i<items; i++) {
        NSInteger change = arc4random_uniform(60)+40;
        NSString *changeStr = [NSString stringWithFormat:@"%ld",(long)change];
        [changeArr addObject:changeStr];
    }
    self.changePerson = changeArr.copy;
    
}


- (STChannel *)programsInSection:(NSUInteger)section {
    STChannel *programs;
    if (section < self.programModel.fetchedVideoAndAdProgramList.count) {
        programs = self.programModel.fetchedVideoAndAdProgramList[section];
    }
    return programs;
}

- (CGSize)normalCellSize {
    if (_normalCellSize.width > 0 && _normalCellSize.height > 0) {
        return _normalCellSize;
    }
    
    const CGFloat width = (kScreenWidth - kInteritemSpacing*3) / 2;
    const CGFloat height = width * 0.75;
    _normalCellSize = CGSizeMake(width, height);
    return _normalCellSize;
}

- (CGSize)bannerCellSize {
    if (_bannerCellSize.width > 0 && _bannerCellSize.height > 0) {
        return _bannerCellSize;
    }
    
    const CGFloat width = kScreenWidth - kInteritemSpacing*2;
    _bannerCellSize = CGSizeMake(width, width/5);
    return _bannerCellSize;
}
//- (NSArray<STProgram *> *)programsForCellAtIndexPath:(NSIndexPath *)indexPath {
//    if (indexPath.section == 0) {
//        return self.programModel.fetchedBannerPrograms;
//    }
//    
//    STChannel *programs = self.programModel.fetchedVideoAndAdProgramList[indexPath.section-1];
//    
//    NSMutableArray *programsForCell = [NSMutableArray array];
//    for (NSUInteger i = 0; i < 3; ++i) {
//        NSUInteger index = indexPath.row * 3 + i;
//        if (index < programs.programList.count) {
//            [programsForCell addObject:programs.programList[index]];
//        }
//    }
//    return programsForCell.count > 0 ? programsForCell : nil;
//}

//- (STProgram *)adProgramAtIndexPath:(NSIndexPath *)indexPath {
//    STChannel *programs = self.programModel.fetchedVideoAndAdProgramList[indexPath.section-1];
//    if (programs.type.unsignedIntegerValue == STProgramTypeAd) {
//        return programs.programList[indexPath.item];
//    }
//    return nil;
//}

//- (BOOL)isAdBannerInSection:(NSUInteger)section {
//    STChannel *programs = self.programModel.fetchedVideoAndAdProgramList[section-1];
//    return programs.type.unsignedIntegerValue == STProgramTypeAd;
//}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


//- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
//    [[STStatsManager sharedManager] statsTabIndex:self.tabBarController.selectedIndex subTabIndex:[STUtil currentSubTabPageIndex] forClickCount:1];
//
//}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    [[STStatsManager sharedManager] statsTabIndex:self.tabBarController.selectedIndex subTabIndex:[STUtil currentSubTabPageIndex] forSlideCount:1];
}

#pragma mark - UICollectionViewDataSource,UICollectionViewDelegateFlowLayout

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    STChannel *programs = [self programsInSection:indexPath.section];
    STProgram *program;
    if (indexPath.item < programs.programList.count) {
        program = programs.programList[indexPath.item];
    }
    
    STHomeCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kNormalCellReusableIdentifier
                                                                 forIndexPath:indexPath];
    if (programs.type.unsignedIntegerValue == STProgramTypeVideo || programs.type.unsignedIntegerValue == STProgramTypeTrival) {
        cell.imageURL = [NSURL URLWithString:program.coverImg];
        cell.title = program.title;
      
//        if (indexPath.item < self.attentArr.count) {
//            NSString *attent = self.attentArr[indexPath.item];
//            NSString *change = self.changePerson[indexPath.item];
//            attentText = (NSUInteger)(attent.integerValue + change.integerValue);
//        }
//        cell.numberOfGuests = attentText;
        cell.showFooter = YES;
        cell.showTrival = NO;
         NSUInteger attentText = 0;
        if (programs.type.unsignedIntegerValue == STProgramTypeTrival) {
            cell.showTrival = YES;
            if (indexPath.item < self.attentArr.count) {
                NSString *attent = self.attentArr[indexPath.item];
                NSString *change = self.changePerson[indexPath.item];
                attentText = (NSUInteger)(attent.integerValue + change.integerValue);
            }
            cell.numberOfGuests = attentText;
        }else {
            if (indexPath.item < self.attentArr.count) {
                NSString *attent = self.attentArr[indexPath.item+2];
                NSString *change = self.changePerson[indexPath.item+2];
                attentText = (NSUInteger)(attent.integerValue + change.integerValue);
            }
            cell.numberOfGuests = attentText;
        
        }
    } else if (programs.type.unsignedIntegerValue == STProgramTypeAd) {
        cell.imageURL = [NSURL URLWithString:programs.columnImg];
        cell.showFooter = NO;
    }
    
    return cell;
    
//    if (programs.type.unsignedIntegerValue == STProgramTypeVideo) {
//        STHomeCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kNormalCellReusableIdentifier
//                                                                     forIndexPath:indexPath];
//        cell.imageURL = [NSURL URLWithString:program.coverImg];
//        cell.title = program.title;
//        cell.numberOfGuests = program.specialDesc.integerValue;
//        return cell;
//    } else {
//        UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kBannerCellReusableIdentifier forIndexPath:indexPath];
//        
//        if (!cell.backgroundView) {
//            cell.backgroundView = [[UIImageView alloc] init];
//        }
//        
//        UIImageView *imageView = (UIImageView *)cell.backgroundView;
//        [imageView sd_setImageWithURL:[NSURL URLWithString:programs.columnImg]];
//        return cell;
//    }
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
//    NSLog(@">>>%ld",self.programModel.fetchedVideoAndAdProgramList.count);
    return self.programModel.fetchedVideoAndAdProgramList.count;
    
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    STChannel *programs = [self programsInSection:section];
    //|| programs.type.unsignedIntegerValue == STProgramTypeTrival
    if (programs.type.unsignedIntegerValue == STProgramTypeVideo || programs.type.unsignedIntegerValue == STProgramTypeTrival) {
        return programs.programList.count;
    } else if (programs.type.unsignedIntegerValue == STProgramTypeAd) {
        return 1;
    }
    return 0;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView
           viewForSupplementaryElementOfKind:(NSString *)kind
                                 atIndexPath:(NSIndexPath *)indexPath
{
    STChannel *programs = [self programsInSection:indexPath.section];
    if (programs.type.unsignedIntegerValue != STProgramTypeVideo) {
        return nil;
    }
    
    STHomeCollectionHeaderView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                                                                                withReuseIdentifier:kHeaderViewReusableIdentifier
                                                                                       forIndexPath:indexPath];
    
    headerView.title = programs.name;
    return headerView;
    
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
//     return CGSizeMake(collectionView.bounds.size.width-kInteritemSpacing*2, MIN(25,collectionView.bounds.size.height*0.06));
    STChannel *programs = [self programsInSection:section];
    if (programs.type.unsignedIntegerValue ==  STProgramTypeVideo ) {
        return CGSizeMake(collectionView.bounds.size.width-kInteritemSpacing*2, MIN(25,collectionView.bounds.size.height*0.06));
    }
    return CGSizeZero;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    STChannel *programs = [self programsInSection:indexPath.section];
    if (programs.type.unsignedIntegerValue == STProgramTypeVideo ||programs.type.unsignedIntegerValue == STProgramTypeTrival) {
        return self.normalCellSize;
    } else if (programs.type.unsignedIntegerValue == STProgramTypeAd) {
        return self.bannerCellSize;
    }
    return CGSizeZero;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    STChannel *programs = [self programsInSection:section];
    if (programs.type.unsignedIntegerValue == STProgramTypeVideo ||programs.type.unsignedIntegerValue == STProgramTypeTrival) {
        return UIEdgeInsetsMake(kInteritemSpacing, kInteritemSpacing, kInteritemSpacing, kInteritemSpacing);
    } else if (programs.type.unsignedIntegerValue == STProgramTypeAd) {
        return UIEdgeInsetsMake(0, kInteritemSpacing, kInteritemSpacing, kInteritemSpacing);
    }
    return UIEdgeInsetsZero;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    STChannel *programs = [self programsInSection:indexPath.section];
    if (programs.type.unsignedIntegerValue == STProgramTypeVideo) {
        if (indexPath.item < programs.programList.count) {
            
            STProgram *program = programs.programList[indexPath.item];
            
            [self switchToPlayProgram:program isTrival:NO programLocation:indexPath.item inChannel:programs];
            //数据统计
             [[STStatsManager sharedManager] statsCPCWithProgram:program programLocation:indexPath.item inChannel:programs andTabIndex:self.tabBarController.selectedIndex subTabIndex:[STUtil currentSubTabPageIndex]];
        }
    } else if (programs.type.unsignedIntegerValue == STProgramTypeAd) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:programs.spreadUrl]];
    } else if (programs.type.unsignedIntegerValue == STProgramTypeTrival) {
        
        [self switchToPlayProgram:programs.programList[indexPath.item] isTrival:YES programLocation:indexPath.item inChannel:programs];
        
         [[STStatsManager sharedManager] statsCPCWithProgram:programs.programList[indexPath.item] programLocation:indexPath.item inChannel:programs andTabIndex:self.tabBarController.selectedIndex subTabIndex:[STUtil currentSubTabPageIndex]];
    
    }
}
@end
