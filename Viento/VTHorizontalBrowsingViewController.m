//
//  VTHorizontalBrowsingViewController.m
//  Viento
//
//  Created by Radu Dutzan on 12/15/14.
//  Copyright (c) 2014 Radu Dutzan. All rights reserved.
//

#import "VTHorizontalBrowsingViewController.h"
#import "VTHorizontalScrollViewWithStuff.h"

@interface VTHorizontalBrowsingViewController ()

@property (nonatomic, strong) NSArray *scrollViews;
@property (nonatomic, strong) VTHorizontalScrollViewWithStuff *horizontalScrollView;
@property (nonatomic, strong) VTHorizontalScrollViewWithStuff *focusedScrollView;
@property (nonatomic, strong) CALayer *selectionIndicator;
@property (nonatomic) CGFloat verticalCursorPosition;

@end

@implementation VTHorizontalBrowsingViewController

CGFloat _focusChangeTolerance = 150;

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [VTRemoteControl sharedRemoteControl].controlScrollView.directionalLockEnabled = YES;
    
    self.selectionIndicator = [CALayer layer];
    self.selectionIndicator.borderColor = [UIColor whiteColor].CGColor;
    self.selectionIndicator.borderWidth = 4;
    
    VTHorizontalScrollViewWithStuff *topScrollView = [[VTHorizontalScrollViewWithStuff alloc] initWithFrame:CGRectZero];
    topScrollView.numberOfItems = 5;
    topScrollView.itemSize = CGSizeMake(540, 240);
    topScrollView.itemSpacing = 15;
    [topScrollView generateItems];
    
    VTHorizontalScrollViewWithStuff *middleScrollView = [[VTHorizontalScrollViewWithStuff alloc] initWithFrame:CGRectZero];
    middleScrollView.numberOfItems = 20;
    middleScrollView.itemSize = CGSizeMake(160, 240);
    middleScrollView.itemSpacing = 30;
    [middleScrollView generateItems];
    
    self.scrollViews = @[topScrollView, middleScrollView];
}

- (void)setScrollViews:(NSArray *)scrollViews
{
    _scrollViews = scrollViews;
    
    CGFloat topMargin = 60;
    CGFloat scrollViewOriginY = topMargin;
    CGFloat interScrollViewSeparation = 120;
    
    for (VTHorizontalScrollViewWithStuff *scrollView in scrollViews) {
        scrollView.frame = CGRectMake(0, scrollViewOriginY, self.view.bounds.size.width, scrollView.contentSize.height);
        [self.view addSubview:scrollView];
        scrollView.contentInset = UIEdgeInsetsMake(0, [self insetConstantForScrollView:scrollView], 0, 0);
        scrollViewOriginY += scrollView.bounds.size.height + interScrollViewSeparation;
    }
    
    self.focusedScrollView = scrollViews[0];
    [self.view.layer addSublayer:self.selectionIndicator];
}

- (void)setFocusedScrollView:(VTHorizontalScrollViewWithStuff *)focusedScrollView
{
    if ([_focusedScrollView isEqual:focusedScrollView]) return;
    if (!focusedScrollView) return;
    _focusedScrollView = focusedScrollView;
    
    [VTRemoteControl sharedRemoteControl].controlScrollView.contentSize = CGSizeMake(focusedScrollView.contentSize.width, CGFLOAT_MAX);
    [VTRemoteControl sharedRemoteControl].controlScrollView.contentOffset = CGPointMake(-[self insetConstantForScrollView:focusedScrollView], [VTRemoteControl sharedRemoteControl].controlScrollView.contentOffset.y);
    
    CGRect selectedItemFrame = CGRectMake([self insetConstantForScrollView:focusedScrollView], focusedScrollView.frame.origin.y, focusedScrollView.itemSize.width, focusedScrollView.itemSize.height);
    self.selectionIndicator.frame = CGRectInset(selectedItemFrame, -self.selectionIndicator.borderWidth, -self.selectionIndicator.borderWidth);
}

- (CGFloat)insetConstantForScrollView:(VTHorizontalScrollViewWithStuff *)scrollView
{
    return (self.view.bounds.size.width - scrollView.itemSize.width) / 2;
}

- (void)setVerticalCursorPosition:(CGFloat)verticalCursorPosition
{
    verticalCursorPosition = MAX(0, verticalCursorPosition);
    verticalCursorPosition = MIN(_focusChangeTolerance * self.scrollViews.count, verticalCursorPosition);
    _verticalCursorPosition = verticalCursorPosition;
    
    NSUInteger focusedIndex = [self.scrollViews indexOfObject:self.focusedScrollView];
    NSLog(@"verticalCursorPosition: %f", verticalCursorPosition);
    
    if (verticalCursorPosition > _focusChangeTolerance * (focusedIndex + 1) && ![self.focusedScrollView isEqual:self.scrollViews.lastObject]) {
        NSLog(@"detected change to next scrollview: %lu", focusedIndex + 1);
        self.focusedScrollView = self.scrollViews[focusedIndex + 1];
    } else if (verticalCursorPosition < _focusChangeTolerance * focusedIndex && ![self.focusedScrollView isEqual:self.scrollViews.firstObject]) {
        NSLog(@"detected change to prev scrollview: %lu", focusedIndex - 1);
        self.focusedScrollView = self.scrollViews[focusedIndex - 1];
    }
}

#pragma mark - Remote control

- (void)handleScrollWithOffset:(CGPoint)offset
{
    self.verticalCursorPosition -= offset.y;
    
    self.focusedScrollView.contentOffset = CGPointMake([VTRemoteControl sharedRemoteControl].controlScrollView.contentOffset.x - [self insetConstantForScrollView:self.focusedScrollView], 0);
}

- (void)handleScrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    CGFloat totalItemWidth = self.focusedScrollView.itemSize.width + self.focusedScrollView.itemSpacing;
    CGFloat integer = 0;
    CGFloat fraction = modf(targetContentOffset->x / totalItemWidth, &integer);
    targetContentOffset->x = (fraction >= 0.5) ? (integer + 1) *  totalItemWidth: integer * totalItemWidth;
}

@end