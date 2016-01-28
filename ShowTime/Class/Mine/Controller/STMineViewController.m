//
//  STMineViewController.m
//  ShowTime
//
//  Created by Sean Yue on 16/1/25.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import "STMineViewController.h"
#import "STWebViewController.h"
#import "STInputTextViewController.h"

@interface STMineViewController () <UITableViewDataSource,UITableViewSeparatorDelegate>
{
    UITableView *_layoutTV;
}
@property (nonatomic,retain) NSMutableDictionary<NSIndexPath *, UITableViewCell *> *cells;
@end

@implementation STMineViewController

DefineLazyPropertyInitialization(NSMutableDictionary, cells)

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _layoutTV = [[UITableView alloc] init];
    _layoutTV.backgroundColor = self.view.backgroundColor;
    _layoutTV.delegate = self;
    _layoutTV.dataSource = self;
    _layoutTV.rowHeight = MAX(44,kScreenHeight * 0.08);
    _layoutTV.hasRowSeparator = YES;
    _layoutTV.hasSectionBorder = YES;
    [self.view addSubview:_layoutTV];
    {
        [_layoutTV mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view);
        }];
    }
    
    [self initCellLayouts];
    
    [self.navigationController.navigationBar bk_whenTouches:1 tapped:5 handler:^{
        NSString *baseURLString = [ST_BASE_URL stringByReplacingCharactersInRange:NSMakeRange(0, ST_BASE_URL.length-6) withString:@"******"];
        [[STHudManager manager] showHudWithText:[NSString stringWithFormat:@"Server:%@\nChannelNo:%@\nPackageCertificate:%@", baseURLString, ST_CHANNEL_NO, ST_PACKAGE_CERTIFICATE]];
    }];
}

- (void)initCellLayouts {
    NSUInteger row = 0;
    [self.cells setObject:[self newCellWithTitle:@"用户须知"]
                   forKey:[NSIndexPath indexPathForRow:row++ inSection:0]];

    [self.cells setObject:[self newCellWithTitle:@"常见问题"]
                   forKey:[NSIndexPath indexPathForRow:row++ inSection:0]];
    
    [self.cells setObject:[self newCellWithTitle:@"用户反馈"]
                   forKey:[NSIndexPath indexPathForRow:row++ inSection:0]];
}

- (UITableViewCell *)newCellWithTitle:(NSString *)title {
    UITableViewCell *cell = [[UITableViewCell alloc] init];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.textLabel.text = title;
    cell.textLabel.textColor = [UIColor grayColor];
    return cell;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource,UITableViewDelegate

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSIndexPath *cellIndexPath = [NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section];
    return self.cells[cellIndexPath];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.cells.count;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSIndexPath *cellIndexPath = [NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section];
    UITableViewCell *cell = self.cells[cellIndexPath];
    
    if (indexPath.row == 0) {
        NSString *urlString = [ST_BASE_URL stringByAppendingString:[STUtil isPaid]?ST_AGREEMENT_PAID_URL:ST_AGREEMENT_NOTPAID_URL];
        STWebViewController *agreementVC = [[STWebViewController alloc] initWithURL:[NSURL URLWithString:urlString]];
        agreementVC.title = cell.textLabel.text;
        [self.navigationController pushViewController:agreementVC animated:YES];
    } else if (indexPath.row == 1) {
        STWebViewController *q_aVC = [[STWebViewController alloc] initWithURL:[NSURL URLWithString:[ST_BASE_URL stringByAppendingString:ST_Q_AND_A_URL]]];
        q_aVC.title = cell.textLabel.text;
        [self.navigationController pushViewController:q_aVC animated:YES];
    } else if (indexPath.row == 2) {
        STInputTextViewController *textVC = [[STInputTextViewController alloc] init];
        textVC.limitedTextLength = 80;
        textVC.placeholder = @"输入用户反馈";
        textVC.completeButtonTitle = @"发送";
        textVC.title = cell.textLabel.text;
        [self.navigationController pushViewController:textVC animated:YES];
    }
}

@end
