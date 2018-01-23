//
//  STVideoPlayViewController.m
//  ShowTime
//
//  Created by ylz on 16/6/20.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import "STVideoPlayViewController.h"
#import "STVideoPlayer.h"
#import "STPaymentViewController.h"

@interface STVideoPlayViewController ()
{
    STVideoPlayer *_videoPlayer;
    UIButton *_closeButton;
}
@end

@implementation STVideoPlayViewController

- (instancetype)initWithVideo:(STProgram *)video {
    if (self = [self init]) {
        _video = video;
        _shouldPopupPaymentIfNotPaid = YES;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    @weakify(self);
    _videoPlayer = [[STVideoPlayer alloc] initWithVideoURL:[NSURL URLWithString:self.video.videoUrl]];
    _videoPlayer.endPlayAction = ^(id sender) {
        @strongify(self);
        [self dismissAndPopPayment];
    };
    [self.view addSubview:_videoPlayer];
    {
        [_videoPlayer mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view);
        }];
    }

    _closeButton = [[UIButton alloc] init];
    [_closeButton setImage:[UIImage imageNamed:@"close"] forState:UIControlStateNormal];
    [self.view addSubview:_closeButton];
    {
        [_closeButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.view).offset(15);
            make.top.equalTo(self.view).offset(30);
        }];
    }
    
    [_closeButton bk_addEventHandler:^(id sender) {
        @strongify(self);
        [self->_videoPlayer pause];
        
        [self dismissAndPopPayment];
    } forControlEvents:UIControlEventTouchUpInside];

}

- (void)dismissAndPopPayment {
    if (![STUtil isPaid]) {
        
//        [[STPaymentViewController sharedPaymentVC] popupPaymentInView:self.view.window forProgram:self.video];
//        [[STPaymentViewController sharedPaymentVC] popupPaymentInView:self.view.window forProgram:self.video programLocation:self inChannel:<#(STChannel *)#>];
        
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [_videoPlayer startToPlay];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
