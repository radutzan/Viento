//
//  VTExternalViewController.m
//  Viento
//
//  Created by Radu Dutzan on 12/12/14.
//  Copyright (c) 2014 Radu Dutzan. All rights reserved.
//

#import "VTExternalViewController.h"

@interface VTExternalViewController ()

@end

@implementation VTExternalViewController

- (void)loadView
{
    UIWindow *externalWindow = [UIApplication sharedApplication].windows[1];
    self.view = [[UIView alloc] initWithFrame:externalWindow.bounds];
    self.view.backgroundColor = [UIColor blackColor];
    self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
}

#pragma mark - Event distribution

- (VTExternalViewController *)viewControllerToSendEvent
{
    VTExternalViewController *viewControllerToMessage = self;
    
    while (viewControllerToMessage.presentedViewController) {
        viewControllerToMessage = (VTExternalViewController *)viewControllerToMessage.presentedViewController;
    }
    
    return viewControllerToMessage;
}

- (BOOL)shouldWithholdEvents
{
    return [self viewControllerToSendEvent].isBeingPresented || [self viewControllerToSendEvent].isBeingDismissed;
}

#pragma mark - Event receivers

- (void)remoteControlScrollViewWillBeginDragging
{
    if ([self shouldWithholdEvents]) return;
    [[self viewControllerToSendEvent] handleScrollWillBeginTracking];
}

- (void)remoteControlScrollMovedWithOffset:(CGPoint)offset
{
    if ([self shouldWithholdEvents]) return;
    [[self viewControllerToSendEvent] handleScrollWithOffset:offset];
}

- (void)remoteControlScrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    if ([self shouldWithholdEvents]) return;
    [[self viewControllerToSendEvent] handleScrollViewWillEndDragging:scrollView withVelocity:velocity targetContentOffset:targetContentOffset];
}

- (void)remoteControlSwipedFromRightEdge
{
    if ([self shouldWithholdEvents]) return;
    [[self viewControllerToSendEvent] handleRightEdgeSwipeGesture];
}

- (void)remoteControlClicked
{
    if ([self shouldWithholdEvents]) return;
    [[self viewControllerToSendEvent] handleClick];
}

- (void)remoteControlBackButtonClicked
{
    if ([self shouldWithholdEvents]) return;
    [[self viewControllerToSendEvent] handleBackButton];
}

- (void)remoteControlHomeButtonClicked
{
    // pop to home eventually, just go back for now
    NSLog(@"%@: Received Home button event, sending Back button event instead", NSStringFromClass([self class]));
    [self remoteControlBackButtonClicked];
}

- (void)remoteControlPlayPauseButtonClicked
{
    // why would i ever implement this?
    NSLog(@"%@: Received Play/Pause button event", NSStringFromClass([self class]));
}

#pragma mark - Event handlers

- (void)handleScrollWillBeginTracking
{
    NSLog(@"%@: Scroll tracking begin handler not used", NSStringFromClass([self class]));
}

- (void)handleScrollWithOffset:(CGPoint)offset
{
    NSLog(@"%@: Scroll handler not used", NSStringFromClass([self class]));
}

- (void)handleScrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    NSLog(@"%@: Scroll deceleration handler not used", NSStringFromClass([self class]));
}

- (void)handleClick
{
    NSLog(@"%@: Click handler not used", NSStringFromClass([self class]));
}

- (void)handleBackButton
{
    if (self.presentingViewController) {
        NSLog(@"%@: Received Back button event, going back", NSStringFromClass([self class]));
        [self dismissViewControllerAnimated:YES completion:nil];
        
        // RESET ALL THE HACKS!
        [[VTRemoteControl sharedRemoteControl] resetScrollSize];
        [VTRemoteControl sharedRemoteControl].controlScrollView.directionalLockEnabled = NO;
        [VTRemoteControl sharedRemoteControl].controlScrollView.decelerationRate = UIScrollViewDecelerationRateFast;
    } else {
        NSLog(@"%@: Received Back button event, but there's nothing to go back to", NSStringFromClass([self class]));
        return;
    }
}
- (void)handleRightEdgeSwipeGesture
{
    NSLog(@"%@: Right edge swipe handler not used", NSStringFromClass([self class]));
}

@end
