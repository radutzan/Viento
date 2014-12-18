//
//  VTRemoteControl.m
//  Viento
//
//  Created by Radu Dutzan on 12/12/14.
//  Copyright (c) 2014 Radu Dutzan. All rights reserved.
//

#import "VTRemoteControl.h"
#import "VTHorizontalBrowsingViewController.h"

@interface VTRemoteControl () <UIScrollViewDelegate>

@end

@implementation VTRemoteControl

CGPoint _previousOffset;

static VTRemoteControl *sharedRemoteControl = nil;

+ (VTRemoteControl *)sharedRemoteControl
{
    if (!sharedRemoteControl) {
        sharedRemoteControl = [self new];
    }
    return sharedRemoteControl;
}

- (void)loadView
{
    self.view = [[UIView alloc] initWithFrame:[UIApplication sharedApplication].keyWindow.bounds];
    self.view.backgroundColor = [UIColor blackColor];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    UIView *remoteSizeView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 240, 330)];
    remoteSizeView.center = self.view.center;
    [self.view addSubview:remoteSizeView];
    
    self.controlScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, remoteSizeView.bounds.size.width, remoteSizeView.bounds.size.height - 50)];
    self.controlScrollView.contentSize = CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX);
    self.controlScrollView.contentOffset = CGPointMake(100000, 100000);
    self.controlScrollView.backgroundColor = [UIColor darkGrayColor];
    self.controlScrollView.delegate = self;
    self.controlScrollView.showsHorizontalScrollIndicator = NO;
    self.controlScrollView.showsVerticalScrollIndicator = NO;
    self.controlScrollView.scrollsToTop = NO;
    self.controlScrollView.decelerationRate = UIScrollViewDecelerationRateFast;
    self.controlScrollView.panGestureRecognizer.delaysTouchesBegan = NO;
    [remoteSizeView addSubview:self.controlScrollView];
    
    _previousOffset = self.controlScrollView.contentOffset;
    
    UITapGestureRecognizer *scrollViewTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(scrollViewTapped:)];
    [self.controlScrollView addGestureRecognizer:scrollViewTap];
    
    UIScreenEdgePanGestureRecognizer *rightEdgeSwipe = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(edgePanRecognized:)];
    rightEdgeSwipe.edges = UIRectEdgeRight;
    [self.view addGestureRecognizer:rightEdgeSwipe];
    
    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, remoteSizeView.bounds.size.height - 50, remoteSizeView.bounds.size.width, 50)];
    toolbar.barStyle = UIBarStyleBlack;
    [remoteSizeView addSubview:toolbar];
    
    UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:self action:@selector(backButtonTapped)];
    UIBarButtonItem *spacer1 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *homeButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Home" style:UIBarButtonItemStylePlain target:self action:@selector(homeButtonTapped)];
    UIBarButtonItem *spacer2 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *playButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemPlay target:self action:@selector(playPauseButtonTapped)];
    
    toolbar.items = @[backButtonItem, spacer1, homeButtonItem, spacer2, playButtonItem];
    
    CALayer *borderLayer = [CALayer new];
    borderLayer.frame = remoteSizeView.bounds;
    borderLayer.borderWidth = 0.5;
    borderLayer.borderColor = [UIColor colorWithWhite:1 alpha:.15].CGColor;
    [remoteSizeView.layer addSublayer:borderLayer];
    
    UILabel *aboutTheSize = [[UILabel alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height - 70, remoteSizeView.bounds.size.width, 70)];
    aboutTheSize.center = CGPointMake(self.view.center.x, aboutTheSize.center.y);
    aboutTheSize.font = [UIFont systemFontOfSize:11];
    aboutTheSize.textAlignment = NSTextAlignmentCenter;
    aboutTheSize.textColor = [UIColor colorWithWhite:.4 alpha:1];
    aboutTheSize.text = @"Simulated size of the proposed\nremote control touch surface.";
    aboutTheSize.numberOfLines = 0;
    [self.view addSubview:aboutTheSize];
}

- (void)edgePanRecognized:(UIScreenEdgePanGestureRecognizer *)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        [self.externalScreenController remoteControlSwipedFromRightEdge];
        // kill it
        recognizer.enabled = NO;
        recognizer.enabled = YES;
    }
}

#pragma mark - Scrollview

- (void)setSpecialScrollSize:(CGSize)size
{
    self.controlScrollView.contentOffset = CGPointZero;
    self.controlScrollView.contentSize = size;
    NSLog(@"%@: Setting special scroll size to: %@", NSStringFromClass([self class]), NSStringFromCGSize(size));
}

- (void)resetScrollSize
{
    self.controlScrollView.contentSize = CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX);
    self.controlScrollView.contentOffset = CGPointMake(100000, 100000);
    NSLog(@"%@: Resetting scroll size", NSStringFromClass([self class]));
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGPoint offset = CGPointMake(scrollView.contentOffset.x - _previousOffset.x, scrollView.contentOffset.y - _previousOffset.y);
    _previousOffset = scrollView.contentOffset;
    
    [self.externalScreenController remoteControlScrollMovedWithOffset:offset];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    // Touch point is delivered using the unit coordinate space, like CALayer's anchorPoint
    CGPoint touchLocation = [scrollView.panGestureRecognizer locationInView:scrollView.superview];
    CGPoint relativePoint = CGPointMake(touchLocation.x / scrollView.bounds.size.width, touchLocation.y / scrollView.bounds.size.height);
    
    [self.externalScreenController remoteControlScrollViewWillBeginDraggingFromPoint:relativePoint];
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    [self.externalScreenController remoteControlScrollViewWillEndDragging:scrollView withVelocity:velocity targetContentOffset:targetContentOffset];
}

#pragma mark - Buttons

- (void)scrollViewTapped:(UITapGestureRecognizer *)recognizer
{
    [self.externalScreenController remoteControlClicked];
}

- (void)backButtonTapped
{
    [self.externalScreenController remoteControlBackButtonClicked];
}

- (void)homeButtonTapped
{
    [self.externalScreenController remoteControlHomeButtonClicked];
}

- (void)playPauseButtonTapped
{
    [self.externalScreenController remoteControlPlayPauseButtonClicked];
}

@end
