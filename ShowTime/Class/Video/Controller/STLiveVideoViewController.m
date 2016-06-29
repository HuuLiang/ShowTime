//
//  STLiveVideoViewController.m
//  ShowTime
//
//  Created by Sean Yue on 16/1/27.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import "STLiveVideoViewController.h"
#import "STLiveVideoPlayer.h"
#import "STVideo.h"
#import "STMessagePopupView.h"
#import "STRocketBarrageView.h"
#import "STVideoMessagePollingView.h"
#import "STVideoCommentModel.h"
#import "STPaymentViewController.h"

static const CGFloat kThumbFlowerButtonInsets = 10;
static int kSTBarrageIndex = 0;

@interface STLiveVideoViewController ()
{
    STLiveVideoPlayer *_player;
    
    UIButton *_closeButton;
    UIButton *_typeButton;
    
    UIButton *_thumbButton;
    UIButton *_flowerButton;
}
@property (nonatomic,retain) STMessagePopupView *messageView;
@property (nonatomic,retain) STRocketBarrageView *rocketBarrageView;
@property (nonatomic,retain) STVideoMessagePollingView *messagePollingView;
@property (nonatomic,retain) NSTimer *timer;
//@property (nonatomic,retain) NSTimer *loadTimer;//加载弹幕
@property (nonatomic,retain) NSArray *usersList;
@property (nonatomic,retain) NSArray *barrageList;
@end

@implementation STLiveVideoViewController

DefineLazyPropertyInitialization(STRocketBarrageView, rocketBarrageView)

- (instancetype)initWithVideo:(STProgram *)video {
    self = [self init];
    if (self) {
        _video = video;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor blackColor];
    STVideo *video = (STVideo *)_video;
    _player = [[STLiveVideoPlayer alloc] initWithVideoURL:[NSURL URLWithString:video.videoUrl]];
    [self.view addSubview:_player];
    {
        [_player mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view);
        }];
    }
    
    [_player.player addObserver:self forKeyPath:@"status" options:0 context:nil];;
    
    
    @weakify(self);
    [_player bk_whenTapped:^{
        @strongify(self);
        [self->_messageView hide];
    }];
    
    _closeButton = [[UIButton alloc] init];
    UIImage *closeImage = [UIImage imageNamed:@"video_close"];
    [_closeButton setImage:closeImage forState:UIControlStateNormal];
    [self.view addSubview:_closeButton];
    {
        [_closeButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.view).offset(-18);
            make.top.equalTo(self.view).offset(30);
            make.size.mas_equalTo(closeImage.size);
        }];
    }
    
    [_closeButton bk_addEventHandler:^(id sender) {
        @strongify(self);
        if (![STUtil isPaid]) {
            
            [[STPaymentViewController sharedPaymentVC] popupPaymentInView:self.view.window forProgram:self.video programLocation:self.videoLocation inChannel:self.channel];
        }

        [self dismissViewControllerAnimated:YES completion:nil];
    } forControlEvents:UIControlEventTouchUpInside];
    
    _typeButton = [[UIButton alloc] init];
    [_typeButton aspect_hookSelector:@selector(titleRectForContentRect:)
                         withOptions:AspectPositionInstead
                          usingBlock:^(id<AspectInfo> aspectInfo, CGRect bounds)
     {
         CGRect textRect = CGRectInset(bounds, 15, 5);
         [[aspectInfo originalInvocation] setReturnValue:&textRect];
     } error:nil];
    [_typeButton setTitle:@"对TA说些什么？" forState:UIControlStateNormal];
    _typeButton.backgroundColor = [UIColor colorWithWhite:0.3 alpha:0.5];
    _typeButton.titleLabel.font = [UIFont systemFontOfSize:16.];
    _typeButton.layer.cornerRadius = 4;
    _typeButton.layer.masksToBounds = YES;
    [_typeButton addTarget:self action:@selector(onTypeMessage) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_typeButton];
    {
        [_typeButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.view).offset(15);
            make.right.equalTo(self.view).offset(-15);
            make.bottom.equalTo(self.view).offset(-15);
            make.height.mas_equalTo(44);
        }];
    }
    
    _thumbButton = [[UIButton alloc] init];
    _thumbButton.contentEdgeInsets = UIEdgeInsetsMake(kThumbFlowerButtonInsets, kThumbFlowerButtonInsets, kThumbFlowerButtonInsets, kThumbFlowerButtonInsets);
    UIImage *thumbImage = [UIImage imageNamed:@"thumb_icon"];
    [_thumbButton setImage:thumbImage forState:UIControlStateNormal];
    [_thumbButton addTarget:self action:@selector(onThumb) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_thumbButton];
    {
        [_thumbButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(_typeButton);
            make.bottom.equalTo(_typeButton.mas_top).offset(-10);
            make.size.mas_equalTo(CGSizeMake(thumbImage.size.width+_thumbButton.contentEdgeInsets.left+_thumbButton.contentEdgeInsets.right, thumbImage.size.height+_thumbButton.contentEdgeInsets.top+_thumbButton.contentEdgeInsets.bottom));
        }];
    }
    
    _flowerButton = [[UIButton alloc] init];
    _flowerButton.contentEdgeInsets = UIEdgeInsetsMake(kThumbFlowerButtonInsets, kThumbFlowerButtonInsets, kThumbFlowerButtonInsets, kThumbFlowerButtonInsets);
    UIImage *flowerImage = [UIImage imageNamed:@"flower_icon"];
    [_flowerButton setImage:flowerImage forState:UIControlStateNormal];
    [_flowerButton addTarget:self action:@selector(onFlower) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_flowerButton];
    {
        [_flowerButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_typeButton);
            make.bottom.equalTo(_thumbButton);
            make.size.mas_equalTo(CGSizeMake(flowerImage.size.width+_flowerButton.contentEdgeInsets.left+_flowerButton.contentEdgeInsets.right, flowerImage.size.height+_flowerButton.contentEdgeInsets.top+_flowerButton.contentEdgeInsets.bottom));
        }];
    }
    _messagePollingView = [[STVideoMessagePollingView alloc] init];
    _messagePollingView.contentInset = UIEdgeInsetsMake(kScreenHeight /3.5, 0, 0, 0);
    //        [self.view addSubview:_messagePollingView];
    [self.view insertSubview:_messagePollingView belowSubview:_flowerButton];
    {
        [_messagePollingView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.view);
            make.bottom.mas_equalTo(_flowerButton.mas_top).mas_offset(-2);
            //            make.right.equalTo(self.view.mas_centerX).multipliedBy(1.5);
            make.width.mas_equalTo(kScreenWidth*0.75);
            //            make.height.equalTo(self.view.mas_height).multipliedBy(0.3);
            //            make.height.mas_equalTo(_messagePollingView.contentInset.top);
            make.height.mas_equalTo(kScreenHeight /3.5);
        }];
        
    }
    //    //加载弹幕内容
    //    [self loadBarrages];
}

- (void)loadBarrages{
    
    [[[STVideoCommentModel alloc] init] fetchCommentWithCompletionHandler:^(BOOL Success, NSArray *commentList) {
        if (Success) {
//            [_loadTimer invalidate];
//            _loadTimer = nil;
            if (commentList.count == 0) {
                return ;
            }
            NSMutableArray *users = [NSMutableArray array];
            NSMutableArray *comments = [NSMutableArray array];
            [commentList enumerateObjectsUsingBlock:^(STComment*  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                [users addObject:obj.userName];
                [comments addObject:obj.content];
                //                NSLog(@"%@,---%@",obj.userName,obj.content);
                
            }];
            
            int count;
            if (comments.count % 2 == 0) {
                
                count = arc4random()%((int)comments.count/3) + ((int)comments.count/3) ;
            }else {
                
                count = arc4random()%((int)comments.count/3) + ((int)comments.count/3) +1 ;
                
            }
            
            
            NSMutableArray *userList = [NSMutableArray array];
            NSMutableArray *barrageList = [NSMutableArray array];
            for (int j = 0; j<count; j++) {
                int  i = arc4random_uniform((int)users.count);
                NSString *user = users[i];
                NSString *barrage = comments[i];
                [userList addObject:user];
                [barrageList addObject:barrage];
                //                NSLog(@"%d,%@,%@",i,user,barrage);
                
            }
            //            NSMutableArray * userTemp = [NSMutableArray arrayWithArray:[[NSSet setWithArray:userList] allObjects]];
            //            NSMutableArray * barrageTemp = [NSMutableArray arrayWithArray:[[NSSet setWithArray:barrageList] allObjects]];
            NSArray *user = userList;
            NSArray *barrage = barrageList;
            _usersList = user;
            _barrageList = barrage;
            //            NSLog(@"user=%@,barrage=%@",_usersList,_barrageList);
            
            [self gotoMessagePollingView];
            if (!_timer) {
                _timer = [NSTimer scheduledTimerWithTimeInterval:3.0 target:self selector:@selector(gotoMessagePollingView) userInfo:nil repeats:YES];
            }
            
            
        }
        
    }];
}
//使用KVO监听播放器是否开始播放
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    if (object == _player.player && [keyPath isEqualToString:@"status"])
    {
//        if (_player.player.status == AVPlayerStatusReadyToPlay) {
//           _loadTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(loadBarrages) userInfo:nil repeats:YES];
//        }
        [self loadBarrages];
    }
    
}

- (void)gotoMessagePollingView{
    ++kSTBarrageIndex ;
    int i = kSTBarrageIndex-1;
    NSString *user = _usersList[i];
    NSString *barrage = _barrageList[i];
    if (kSTBarrageIndex >= _usersList.count-1) {
        kSTBarrageIndex = 0;
        [_timer invalidate];
        _timer = nil;
    }
    //    NSLog(@"user --%@,barr%@--->%d",user,barrage,kSTBarrageIndex);
    [_messagePollingView insertMessages:@[barrage] forNames:@[user]withCount:_usersList.count];
}

- (void)dealloc {
    [_player.player removeObserver:self forKeyPath:@"status"];
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [_player startToPlay];
}

- (STMessagePopupView *)messageView {
    if (_messageView) {
        return _messageView;
    }
    
    _messageView = [[STMessagePopupView alloc] init];
    @weakify(self);
    _messageView.selectAction = ^(NSString *selectedWord) {
        @strongify(self);
        [self.rocketBarrageView moveInView:self.view withTitle:selectedWord];
    };
    return _messageView;
}

- (void)onTypeMessage {
    [self.messageView showInView:self.view atLeftBottomPosition:CGPointMake(_typeButton.frame.origin.x,
                                                                            _typeButton.frame.origin.y+_typeButton.frame.size.height) width:_typeButton.frame.size.width];
}

- (void)animateImageViewWithName:(NSString *)name fromRect:(CGRect)rect {
    const CGFloat xOffsetRange = 30;
    CGRect imageFrame = CGRectInset(rect, kThumbFlowerButtonInsets, kThumbFlowerButtonInsets);
    imageFrame = CGRectOffset(imageFrame, xOffsetRange/2-arc4random_uniform(xOffsetRange), 0);
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:imageFrame];
    imageView.image = [[UIImage imageNamed:name] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    
    
    [imageView setTintColor:[UIColor colorWithRed:arc4random_uniform(256)/256. green:arc4random_uniform(256)/256. blue:arc4random_uniform(256)/256. alpha:1]];
    [self.view addSubview:imageView];
    
    [UIView animateWithDuration:3 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        imageView.frame = CGRectOffset(imageView.frame, 0, -CGRectGetHeight(self.view.bounds)*0.4);
        imageView.alpha = 0;
    } completion:^(BOOL finished) {
        [imageView removeFromSuperview];
    }];
}

- (void)onThumb {
    [self animateImageViewWithName:@"thumb_icon" fromRect:_thumbButton.frame];
}

- (void)onFlower {
    [self animateImageViewWithName:@"flower_icon" fromRect:_flowerButton.frame];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [_timer invalidate];
    _timer = nil;
//    [_loadTimer invalidate];
//    _loadTimer = nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
