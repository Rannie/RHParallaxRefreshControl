//
//  RHParallaxRefreshContext.h
//  ParallaxRefreshDemo
//
//  Created by Hanran Liu on 15/7/14.
//  Copyright (c) 2015年 56baby. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef dispatch_block_t RHRefreshControllCallback;

@interface RHParallaxRefreshContext : NSObject

@property (nonatomic, assign, getter=isRefreshing) BOOL refreshing;

+ (instancetype)context;

//initial setup
- (void)setupParallaxOnImageView:(UIImageView *)imageView scrollView:(UIScrollView *)scrollView;

//refresh
- (void)beginRefreshing;
- (void)endRefreshing;

//event handler
- (void)setBeginRefreshingCallback:(RHRefreshControllCallback)callback;

//scrollview delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView;
- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset;

//custom method(can subclass to override)
- (void)redrawFromProgress:(CGFloat)progress;
- (void)setupCustomRefreshControl;
- (void)customRefreshAnimation;
- (void)refreshDidComplete;

@end
