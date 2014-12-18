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

@property (nonatomic, strong) UIView *controlledDot;

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
    
    self.controlScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height - 44)];
    self.controlScrollView.contentSize = CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX);
    self.controlScrollView.contentOffset = CGPointMake(100000, 100000);
    self.controlScrollView.backgroundColor = [UIColor darkGrayColor];
    self.controlScrollView.delegate = self;
    self.controlScrollView.showsHorizontalScrollIndicator = NO;
    self.controlScrollView.showsVerticalScrollIndicator = NO;
    self.controlScrollView.scrollsToTop = NO;
    self.controlScrollView.decelerationRate = UIScrollViewDecelerationRateFast;
    [self.view addSubview:self.controlScrollView];
    
    _previousOffset = self.controlScrollView.contentOffset;
    
    UITapGestureRecognizer *scrollViewTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(scrollViewTapped)];
    [self.controlScrollView addGestureRecognizer:scrollViewTap];
    
    UIScreenEdgePanGestureRecognizer *rightEdgeSwipe = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(edgePanRecognized:)];
    rightEdgeSwipe.edges = UIRectEdgeRight;
    [self.controlScrollView addGestureRecognizer:rightEdgeSwipe];
    
    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height - 44, self.view.bounds.size.width, 44)];
    toolbar.barStyle = UIBarStyleBlack;
    [self.view addSubview:toolbar];
    
    UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:self action:@selector(backButtonTapped)];
    UIBarButtonItem *spacer1 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *homeButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Home" style:UIBarButtonItemStylePlain target:self action:@selector(homeButtonTapped)];
    UIBarButtonItem *spacer2 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *playButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemPlay target:self action:@selector(playPauseButtonTapped)];
    
    toolbar.items = @[backButtonItem, spacer1, homeButtonItem, spacer2, playButtonItem];
    
    self.controlledDot = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
    self.controlledDot.center = CGPointMake(self.view.center.x, self.view.center.y / 2);
    self.controlledDot.backgroundColor = [UIColor greenColor];
//    [self.view addSubview:self.controlledDot];
}

- (void)resetDot
{
    self.controlledDot.center = CGPointMake(self.view.center.x, self.view.center.y / 2);
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
//    self.controlScrollView.delegate = nil;
    self.controlScrollView.contentOffset = CGPointZero;
    self.controlScrollView.contentSize = size;
    NSLog(@"%@: Setting special scroll size to: %@", NSStringFromClass([self class]), NSStringFromCGSize(size));
    [self resetDot];
//    self.controlScrollView.delegate = self;
}

- (void)resetScrollSize
{
    self.controlScrollView.contentSize = CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX);
    self.controlScrollView.contentOffset = CGPointMake(100000, 100000);
    NSLog(@"%@: Resetting scroll size", NSStringFromClass([self class]));
    [self resetDot];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGPoint offset = CGPointMake(scrollView.contentOffset.x - _previousOffset.x, scrollView.contentOffset.y - _previousOffset.y);
    
    self.controlledDot.center = CGPointMake(self.controlledDot.center.x - offset.x, self.controlledDot.center.y - offset.y);
    
    if ([[UIScreen screens] count] > 1) {
        [self.externalScreenController remoteControlScrollMovedWithOffset:offset];
    }
    
    _previousOffset = scrollView.contentOffset;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    self.controlledDot.backgroundColor = [UIColor orangeColor];
    [self.externalScreenController remoteControlScrollViewWillBeginDragging];
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    self.controlledDot.backgroundColor = [UIColor greenColor];
    [self.externalScreenController remoteControlScrollViewWillEndDragging:scrollView withVelocity:velocity targetContentOffset:targetContentOffset];
}

#pragma mark - Buttons

- (void)scrollViewTapped
{
    [self.externalScreenController remoteControlClicked];
}

- (void)backButtonTapped
{
    [self resetDot];
    [self.externalScreenController remoteControlBackButtonClicked];
}

- (void)homeButtonTapped
{
    [self resetDot];
    [self.externalScreenController remoteControlHomeButtonClicked];
}

- (void)playPauseButtonTapped
{
    [self resetDot];
    [self.externalScreenController remoteControlPlayPauseButtonClicked];
}

@end
