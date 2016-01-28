//
//  STBaseViewController.m
//  ShowTime
//
//  Created by Sean Yue on 16/1/25.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import "STBaseViewController.h"
#import "STPaymentViewController.h"
#import "STProgram.h"
#import "STLiveVideoViewController.h"

@import MediaPlayer;
@import AVKit;
@import AVFoundation.AVPlayer;
@import AVFoundation.AVAsset;
@import AVFoundation.AVAssetImageGenerator;

@interface STBaseViewController ()

@end

@implementation STBaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor colorWithWhite:0.93 alpha:1];
}

- (void)switchToPlayProgram:(STProgram *)program {
    if (![STUtil isPaid]) {
        [self payForProgram:program];
    } else if (program.type.unsignedIntegerValue == STProgramTypeVideo) {
        UIViewController *videoPlayVC = [[STLiveVideoViewController alloc] initWithVideo:program];//[self playerVCWithVideo:program];
        videoPlayVC.hidesBottomBarWhenPushed = YES;
        [self presentViewController:videoPlayVC animated:YES completion:nil];
    }
}

- (void)payForProgram:(STProgram *)program {
    [[STPaymentViewController sharedPaymentVC] popupPaymentInView:self.view.window forProgram:program];
}

//- (UIViewController *)playerVCWithVideo:(STVideo *)video {
//    UIViewController *retVC;
//    if (NSClassFromString(@"AVPlayerViewController")) {
//        AVPlayerViewController *playerVC = [[AVPlayerViewController alloc] init];
//        playerVC.player = [[AVPlayer alloc] initWithURL:[NSURL URLWithString:video.videoUrl]];
//        [playerVC aspect_hookSelector:@selector(viewDidAppear:)
//                          withOptions:AspectPositionAfter
//                           usingBlock:^(id<AspectInfo> aspectInfo){
//                               AVPlayerViewController *thisPlayerVC = [aspectInfo instance];
//                               [thisPlayerVC.player play];
//                           } error:nil];
//        
//        retVC = playerVC;
//    } else {
//        retVC = [[MPMoviePlayerViewController alloc] initWithContentURL:[NSURL URLWithString:video.videoUrl]];
//    }
//    
//    [retVC aspect_hookSelector:@selector(supportedInterfaceOrientations) withOptions:AspectPositionInstead usingBlock:^(id<AspectInfo> aspectInfo){
//        UIInterfaceOrientationMask mask = UIInterfaceOrientationMaskAll;
//        [[aspectInfo originalInvocation] setReturnValue:&mask];
//    } error:nil];
//    
//    [retVC aspect_hookSelector:@selector(shouldAutorotate) withOptions:AspectPositionInstead usingBlock:^(id<AspectInfo> aspectInfo){
//        BOOL rotate = YES;
//        [[aspectInfo originalInvocation] setReturnValue:&rotate];
//    } error:nil];
//    return retVC;
//}

- (BOOL)shouldAutorotate {
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
