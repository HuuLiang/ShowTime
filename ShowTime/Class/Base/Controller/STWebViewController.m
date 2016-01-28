//
//  STWebViewController.m
//  ShowTime
//
//  Created by Sean Yue on 16/1/27.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import "STWebViewController.h"

@interface STWebViewController ()
{
    UIWebView *_webView;
}
@end

@implementation STWebViewController

- (instancetype)initWithURL:(NSURL *)URL {
    self = [self init];
    if (self) {
        _url = URL;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _webView = [[UIWebView alloc] init];
    [self.view addSubview:_webView];
    {
        [_webView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view);
        }];
    }
    
    [_webView loadRequest:[NSURLRequest requestWithURL:_url]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
