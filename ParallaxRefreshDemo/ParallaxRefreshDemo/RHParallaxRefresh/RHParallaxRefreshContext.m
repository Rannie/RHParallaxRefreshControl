//
//  RHParallaxRefreshContext.m
//  ParallaxRefreshDemo
//
//  Created by Hanran Liu on 15/7/14.
//  Copyright (c) 2015年 56baby. All rights reserved.
//

#import "RHParallaxRefreshContext.h"
#import "UIImage+ImageEffects.h"

static CGFloat const kProgressWeighted = 1.4;
static CGFloat const kRefreshControlHeight = 120;

@interface RHParallaxRefreshContext ()
@property (nonatomic, strong) UIScrollView  *scrollView;
@property (nonatomic, strong) UIImageView   *srcImageView;
@property (nonatomic, strong) UIImageView   *blurImageView;

@property (nonatomic, assign) CGFloat progress;
@property (nonatomic, copy) RHRefreshControllCallback beginCallback;

@property (nonatomic, strong) UIView        *refreshControl;
@property (nonatomic, strong) CAShapeLayer  *ovalShapeLayer;
@property (nonatomic, strong) CALayer       *airplaneLayer;
@end

@implementation RHParallaxRefreshContext

#pragma mark - Initial and Setup
+ (instancetype)context
{
    return [[self alloc] init];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _refreshing = NO;
        _progress = .0;
    }
    return self;
}

- (void)setupParallaxOnImageView:(UIImageView *)imageView scrollView:(UIScrollView *)scrollView
{
    _scrollView = scrollView;
    _srcImageView = imageView;
    
    imageView.layer.anchorPoint = CGPointMake(0.5, 1.0);
    imageView.frame = CGRectOffset(imageView.frame, 0, imageView.frame.size.height/2);
    
    UIImage *srcImage = imageView.image;
    UIImage *blurImage = [srcImage applyBlurWithRadius:5 tintColor:[UIColor colorWithWhite:0.2 alpha:0.2] saturationDeltaFactor:1.0 maskImage:nil];
    
    _blurImageView = [[UIImageView alloc] init];
    _blurImageView.layer.anchorPoint = CGPointMake(0.5, 1.0);
    _blurImageView.image = blurImage;
    _blurImageView.frame = imageView.bounds;
    _blurImageView.userInteractionEnabled = imageView.userInteractionEnabled;
    [imageView.superview insertSubview:_blurImageView aboveSubview:imageView];
    
    [self setupCustomRefreshControl];
}

- (void)setupCustomRefreshControl
{
    _refreshControl = [[UIView alloc] initWithFrame:CGRectMake(0, -kRefreshControlHeight, self.scrollView.frame.size.width, kRefreshControlHeight)];
    _refreshControl.backgroundColor = [UIColor clearColor];
    [self.scrollView addSubview:_refreshControl];
    
    _ovalShapeLayer = [CAShapeLayer layer];
    _ovalShapeLayer.strokeColor = [UIColor whiteColor].CGColor;
    _ovalShapeLayer.fillColor = [UIColor clearColor].CGColor;
    _ovalShapeLayer.lineWidth = 4.0;
    _ovalShapeLayer.lineDashPattern = @[@2, @3];
    
    CGSize size = _refreshControl.frame.size;
    CGFloat refreshRadius = size.height/2.0 * 0.8;
    _ovalShapeLayer.path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(size.width/2-refreshRadius, size.height/2-refreshRadius, 2*refreshRadius, 2*refreshRadius)].CGPath;
    [_refreshControl.layer addSublayer:_ovalShapeLayer];
    
    _airplaneLayer = [CALayer layer];
    UIImage *airImage = [UIImage imageNamed:@"icon-plane.png"];
    _airplaneLayer.contents = (__bridge id)airImage.CGImage;
    _airplaneLayer.bounds = CGRectMake(0, 0, airImage.size.width, airImage.size.height);
    _airplaneLayer.position = CGPointMake(size.width/2+refreshRadius, size.height/2);
    _airplaneLayer.opacity = 0.0;
    
    [_refreshControl.layer addSublayer:_airplaneLayer];
}

#pragma mark - Refresh Method
- (void)beginRefreshing
{
    self.refreshing = YES;
    
    self.scrollView.bounces = NO;
    [UIView animateWithDuration:0.6 animations:^{
        UIEdgeInsets newInsets = self.scrollView.contentInset;
        newInsets.top += kRefreshControlHeight;
        self.scrollView.contentInset = newInsets;
        self.scrollView.contentOffset = CGPointMake(0, -kRefreshControlHeight);
    } completion:^(BOOL finished) {
        self.scrollView.bounces = YES;
    }];
    
    [self customRefreshAnimation];
    
    if (self.beginCallback)
        self.beginCallback();
}

- (void)endRefreshing
{
    self.refreshing = NO;
    
    self.scrollView.bounces = YES;
    [UIView animateWithDuration:0.3 animations:^{
        UIEdgeInsets newInsets = self.scrollView.contentInset;
        newInsets.top -= kRefreshControlHeight;
        self.scrollView.contentInset = newInsets;
    } completion:^(BOOL finished) {
        [self refreshDidComplete];
    }];
}

- (void)customRefreshAnimation
{
    CABasicAnimation *strokeStartAnimation = [CABasicAnimation animationWithKeyPath:@"strokeStart"];
    strokeStartAnimation.fromValue = @-0.5;
    strokeStartAnimation.toValue = @1.0;
    
    CABasicAnimation *strokeEndAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    strokeEndAnimation.fromValue = @0.0;
    strokeEndAnimation.toValue = @1.0;
    
    CAAnimationGroup *strokeAnimationGroup = [CAAnimationGroup animation];
    strokeAnimationGroup.duration = 1.5;
    strokeAnimationGroup.repeatDuration = INFINITY;
    strokeAnimationGroup.animations = @[strokeStartAnimation, strokeEndAnimation];
    [_ovalShapeLayer addAnimation:strokeAnimationGroup forKey:nil];
    
    CAKeyframeAnimation *flightAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    flightAnimation.path = _ovalShapeLayer.path;
    flightAnimation.calculationMode = kCAAnimationPaced;
    
    CABasicAnimation *airplaneOrientationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
    airplaneOrientationAnimation.fromValue = @0.0;
    airplaneOrientationAnimation.toValue = @(2*M_PI);
    
    CAAnimationGroup *flightAnimationGroup = [CAAnimationGroup animation];
    flightAnimationGroup.duration = 1.5;
    flightAnimationGroup.repeatDuration = INFINITY;
    flightAnimationGroup.animations = @[flightAnimation, airplaneOrientationAnimation];
    [_airplaneLayer addAnimation:flightAnimationGroup forKey:nil];
}

- (void)refreshDidComplete
{
    [_ovalShapeLayer removeAllAnimations];
    [_airplaneLayer removeAllAnimations];
}

#pragma mark - Event Callback
- (void)setBeginRefreshingCallback:(RHRefreshControllCallback)callback
{
    self.beginCallback = callback;
}

#pragma mark - ScrollView Method
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat offsetY = scrollView.contentOffset.y;
    if (offsetY < 0)
    {
        CGFloat delta = -offsetY;
        CGFloat progress = delta/kRefreshControlHeight;
        CGFloat scale = MAX(1, 1 + kProgressWeighted * progress);
        _blurImageView.alpha = MAX(.0, 1-progress);
        _blurImageView.transform = CGAffineTransformMakeScale(scale, scale);
        _srcImageView.transform = CGAffineTransformMakeScale(scale, scale);
    }
    else
    {
        _srcImageView.transform = CGAffineTransformIdentity;
        _blurImageView.transform = CGAffineTransformIdentity;
        _blurImageView.alpha = 1.0;
    }
    
    CGFloat refreshOffsetY = MAX(-(offsetY + scrollView.contentInset.top), 0.0);
    self.progress = MIN(MAX(refreshOffsetY / kRefreshControlHeight, 0.0), 1.0);
    
    if (!self.isRefreshing)
        [self redrawFromProgress:self.progress];
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    if (!self.isRefreshing && self.progress >= 1.0)
        [self beginRefreshing];
}

#pragma mark - Progress
- (void)redrawFromProgress:(CGFloat)progress
{
    _ovalShapeLayer.strokeEnd = progress;
    _airplaneLayer.opacity = progress;
}

@end
