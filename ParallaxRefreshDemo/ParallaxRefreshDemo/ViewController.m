//
//  ViewController.m
//  ParallaxRefreshDemo
//
//  Created by Rannie on 15/7/10.
//  Copyright (c) 2015年 Rannie. All rights reserved.
//

#import "ViewController.h"
#import "SecondViewController.h"
#import <Masonry/Masonry.h>
#import "RHParallaxRefreshContext.h"

#define REFRESH_CONTROL_HEIGHT (120)

@interface ViewController () <UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate>
@property (nonatomic, strong) UITableView               *tableView;
@property (nonatomic, strong) NSMutableArray            *dataList;
@property (nonatomic, strong) RHParallaxRefreshContext  *parallaxContext;
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.dataList = [@[@"feed01", @"feed02", @"feed03", @"feed04", @"feed05", @"feed02", @"feed03", @"feed04", @"feed05", @"feed02", @"feed03", @"feed04", @"feed05"] mutableCopy];
    self.navigationController.navigationBarHidden = YES;
    
    _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [self.view addSubview:_tableView];
    
    _parallaxContext = [RHParallaxRefreshContext context];
    __weak typeof(self) weakSelf = self;
    [_parallaxContext setBeginRefreshingCallback:^{
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.6 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if (weakSelf.parallaxContext.isRefreshing)
                [weakSelf.parallaxContext endRefreshing];
        });
    }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataList.count+1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * const CellIdentifier = @"CellId";
    static NSString * const Header = @"header";
    UITableViewCell * cell = nil;
    if (indexPath.row == 0)
    {
        cell = [tableView dequeueReusableCellWithIdentifier:Header];
        if (!cell)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:Header];
            UIImageView *refreshImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, REFRESH_CONTROL_HEIGHT)];
            [cell.contentView addSubview:refreshImageView];
            refreshImageView.image = [UIImage imageNamed:@"subaru"];
            
            [_parallaxContext setupParallaxOnImageView:refreshImageView scrollView:tableView];
        }
    }
    else
    {
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (!cell)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        cell.textLabel.text = self.dataList[indexPath.row-1];
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0)
    {
        return REFRESH_CONTROL_HEIGHT;
    }
    else
    {
        return 50;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    SecondViewController *vc = [[SecondViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [_parallaxContext scrollViewDidScroll:scrollView];
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    [_parallaxContext scrollViewWillEndDragging:scrollView withVelocity:velocity targetContentOffset:targetContentOffset];
}

@end
