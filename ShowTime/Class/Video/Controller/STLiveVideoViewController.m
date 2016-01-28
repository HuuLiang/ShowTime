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

static const CGFloat kThumbFlowerButtonInsets = 10;

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
@end

@implementation STLiveVideoViewController

DefineLazyPropertyInitialization(STRocketBarrageView, rocketBarrageView)

- (instancetype)initWithVideo:(STVideo *)video {
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
    
    _player = [[STLiveVideoPlayer alloc] initWithVideoURL:[NSURL URLWithString:_video.videoUrl]];
    [self.view addSubview:_player];
    {
        [_player mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view);
        }];
    }
    
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
