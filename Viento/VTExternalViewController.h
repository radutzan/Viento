//
//  VTExternalViewController.h
//  Viento
//
//  Created by Radu Dutzan on 12/12/14.
//  Copyright (c) 2014 Radu Dutzan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VTRemoteControl.h"

@interface VTExternalViewController : UIViewController

// Event receivers: DO NOT OVERRIDE
- (void)remoteControlScrollViewWillBeginDragging;
- (void)remoteControlScrollMovedWithOffset:(CGPoint)offset;
- (void)remoteControlScrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset;
- (void)remoteControlSwipedFromRightEdge;
- (void)remoteControlClicked;
- (void)remoteControlBackButtonClicked;
- (void)remoteControlHomeButtonClicked;
- (void)remoteControlPlayPauseButtonClicked;

// Handlers: override these!
- (void)handleScrollWillBeginTracking;
- (void)handleScrollWithOffset:(CGPoint)offset;
- (void)handleScrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset;
- (void)handleClick;
- (void)handleRightEdgeSwipeGesture;

@end
