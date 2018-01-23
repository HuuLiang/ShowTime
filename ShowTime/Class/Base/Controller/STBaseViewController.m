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
//#import "STVideoPlayViewController.h"

@import MediaPlayer;
@import AVKit;
@import AVFoundation.AVPlayer;
@import AVFoundation.AVAsset;
@import AVFoundation.AVAssetImageGenerator;

@interface STBaseViewController ()

@end

@implementation STBaseViewController

- (NSUInteger)currentIndex {
    return NSNotFound;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor colorWithWhite:0.93 alpha:1];
}

- (void)switchToPlayProgram:(STProgram *)program isTrival:(BOOL)isTrival
            programLocation:(NSUInteger)programLocation
                  inChannel:(STChannel *)channel{
    if (![STUtil isPaid] && isTrival == NO) {
        [self payForProgram:program programLocation:programLocation inChannel:channel];
    } else if (program.type.unsignedIntegerValue == STProgramTypeVideo && isTrival == NO) {
        UIViewController *videoPlayVC = [[STLiveVideoViewController alloc] initWithVideo:program];//[self playerVCWithVideo:program];
        videoPlayVC.hidesBottomBarWhenPushed = YES;
        [self presentViewController:videoPlayVC animated:YES completion:nil];
    }else if (isTrival == YES) {
    STLiveVideoViewController *videoPlayVC = [[STLiveVideoViewController alloc] initWithVideo:program];
        videoPlayVC.isTrival = YES;
        videoPlayVC.channel = channel;
        videoPlayVC.videoLocation = programLocation;
        [self presentViewController:videoPlayVC animated:YES completion:nil];
    }
}

- (void)payForProgram:(STProgram *)program programLocation:(NSUInteger)programLocation
            inChannel:(STChannel *)channel{
    [[STPaymentViewController sharedPaymentVC] popupPaymentInView:self.view.window forProgram:program programLocation:programLocation inChannel:channel];
}

- (void)playVideo:(STProgram *)video withTimeControl:(BOOL)hasTimeControl shouldPopPayment:(BOOL)shouldPopPayment {
//    if (hasTimeControl) {
//        UIViewController *videoPlayVC = [self playerVCWithVideo:video];
//        videoPlayVC.hidesBottomBarWhenPushed = YES;
//        [self presentViewController:videoPlayVC animated:YES completion:nil];
//    } else {
    if (hasTimeControl && shouldPopPayment) {
        
//        STVideoPlayViewController *playerVC = [[STVideoPlayViewController alloc] initWithVideo:video];
//        playerVC.hidesBottomBarWhenPushed = YES;
//        [self presentViewController:playerVC animated:YES completion:nil];
    }
//    }
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
