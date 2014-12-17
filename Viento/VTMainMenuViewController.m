//
//  VTMainMenuViewController.m
//  Viento
//
//  Created by Radu Dutzan on 12/13/14.
//  Copyright (c) 2014 Radu Dutzan. All rights reserved.
//

#import "VTMainMenuViewController.h"
#import "VTMovingDotDemoViewController.h"
#import "VTVerticalListViewController.h"
#import "VTHorizontalBrowsingViewController.h"

@interface VTMainMenuViewController ()

@property (nonatomic, strong) NSArray *buttons;
@property (nonatomic) CGPoint invisibleCursorPosition;
@property (nonatomic, strong) UIButton *currentButton;

@end

@implementation VTMainMenuViewController

CALayer *_selectionOutline;

- (void)viewDidLoad
{
    UILabel *menuTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height / 4)];
    menuTitle.text = @"Direct Manipulation Demos";
    menuTitle.textColor = [UIColor whiteColor];
    menuTitle.font = [UIFont systemFontOfSize:42];
    menuTitle.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:menuTitle];
    
    UILabel *menuDescription = [[UILabel alloc] initWithFrame:CGRectMake(self.view.bounds.size.width / 4, (self.view.bounds.size.height / 4) * 3, self.view.bounds.size.width / 2, self.view.bounds.size.height / 4)];
    menuDescription.text = @"These demos (including this menu) show how it feels like to operate a TV using direct manipulation mechanisms.";
    menuDescription.textColor = [UIColor colorWithWhite:.5 alpha:1];
    menuDescription.numberOfLines = 0;
    menuDescription.font = [UIFont systemFontOfSize:22];
    menuDescription.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:menuDescription];
    
    _selectionOutline = [CALayer layer];
    _selectionOutline.borderColor = [UIColor whiteColor].CGColor;
    _selectionOutline.borderWidth = 3;
    
    UIButton *movingDotButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [movingDotButton setTitle:@"Moving Dot" forState:UIControlStateNormal];
    [movingDotButton addTarget:self action:@selector(movingDotButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *verticalListButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [verticalListButton setTitle:@"Vertical List" forState:UIControlStateNormal];
    [verticalListButton addTarget:self action:@selector(verticalListButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *horizontalBrowsingButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [horizontalBrowsingButton setTitle:@"Horizontal\nBrowsing" forState:UIControlStateNormal];
    [horizontalBrowsingButton addTarget:self action:@selector(horizontalBrowsingButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *keyboardButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [keyboardButton setTitle:@"Hive Keyboard" forState:UIControlStateNormal];
    [keyboardButton addTarget:self action:@selector(keyboardButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    
    self.buttons = @[movingDotButton, verticalListButton, horizontalBrowsingButton, keyboardButton];
}

- (void)setButtons:(NSArray *)buttons
{
    _buttons = buttons;
    
    UIView *buttonContainer = [[UIView alloc] initWithFrame:CGRectZero];
    
    CGFloat separatorWidth = 26;
    CGFloat buttonWidth = 282;
    CGFloat buttonOriginX = 0;
    
    for (UIButton *button in buttons) {
        button.frame = CGRectMake(buttonOriginX, 0, buttonWidth, 159);
        button.titleLabel.font = [UIFont systemFontOfSize:32.0];
        button.titleLabel.numberOfLines = 0;
        button.titleLabel.textAlignment = NSTextAlignmentCenter;
        button.layer.cornerRadius = 12;
        [buttonContainer addSubview:button];
        buttonOriginX += buttonWidth + separatorWidth;
    }
    
    buttonContainer.frame = CGRectMake(0, 0, buttonOriginX - separatorWidth, 160);
    buttonContainer.center = self.view.center;
    [self.view addSubview:buttonContainer];
    
    UIButton *firstButton = buttons[0];
    self.currentButton = firstButton;
    self.invisibleCursorPosition = CGPointZero;
    
    _selectionOutline.frame = CGRectInset(firstButton.frame, -8, -8);
    _selectionOutline.cornerRadius = firstButton.layer.cornerRadius + 8;
    [buttonContainer.layer addSublayer:_selectionOutline];
}

- (void)setInvisibleCursorPosition:(CGPoint)invisibleCursorPosition
{
/*  The cursor's function is to select between buttons. Duh.
    It does this by moving through a number line starting at 0,
    detecting button changes every time it passes a 'notch', 
    which is a multiplier of the buttonTolerance value.
 
    The cursor is 'on' a buton when it's within its virtual range.
 
    All this because the control model is continuous and not sequential,
    and that makes room for fun abstractions like this one.
 */
    CGFloat buttonTolerance = 65;
    
    CGFloat invisibleCursorPositionX = invisibleCursorPosition.x;
    invisibleCursorPositionX = MIN(buttonTolerance * self.buttons.count, invisibleCursorPositionX);
    invisibleCursorPositionX = MAX(0, invisibleCursorPositionX);
    _invisibleCursorPosition = CGPointMake(invisibleCursorPositionX, 0);
    
    UIButton *firstButton = self.buttons[0];
    UIButton *lastButton = [self.buttons lastObject];
    NSUInteger currentIndex = [self.buttons indexOfObject:self.currentButton];
    CGRect currentButtonFakeRect = CGRectMake(buttonTolerance * currentIndex, 0, buttonTolerance, buttonTolerance);
//    NSLog(@"Cursor at: %@, -- Current Button Index: %lu -- Fake Rect: %@", NSStringFromCGPoint(_invisibleCursorPosition), (unsigned long)currentIndex, NSStringFromCGRect(currentButtonFakeRect));
    
    if ((_invisibleCursorPosition.x >= currentButtonFakeRect.size.width + currentButtonFakeRect.origin.x) &&
        ![self.currentButton isEqual:lastButton]) {
        // switch to next button, to the left
        self.currentButton = self.buttons[currentIndex + 1];
        
    } else if ((_invisibleCursorPosition.x <= currentButtonFakeRect.origin.x) &&
               ![self.currentButton isEqual:firstButton]) {
        // switch to previous button, to the right
        self.currentButton = self.buttons[currentIndex - 1];
    }
}

- (void)setCurrentButton:(UIButton *)currentButton
{
    if (_currentButton == currentButton) return;
    _currentButton = currentButton;
    NSLog(@"Setting current button to: %@", [currentButton titleForState:UIControlStateNormal]);
    
    for (UIButton *button in self.buttons) {
        button.highlighted = NO;
        button.backgroundColor = [UIColor colorWithWhite:.1 alpha:1];
    }
    
    currentButton.highlighted = YES;
    
    [UIView animateWithDuration:.2 delay:0 usingSpringWithDamping:1 initialSpringVelocity:1 options:0 animations:^{
        _selectionOutline.frame = CGRectInset(currentButton.frame, -8, -8);
        currentButton.backgroundColor = [UIColor colorWithWhite:.25 alpha:1];
    } completion:nil];
}

- (void)handleScrollWithOffset:(CGPoint)offset
{
    self.invisibleCursorPosition = CGPointMake(self.invisibleCursorPosition.x - offset.x, 0);
}

- (void)handleClick
{
    NSLog(@"Main Menu click");
    for (UIButton *button in self.buttons) {
        if (button.isHighlighted) {
            NSLog(@"Selecting button: %@", [button titleForState:UIControlStateNormal]);
            [button sendActionsForControlEvents:UIControlEventTouchUpInside];
        }
    }
}

- (void)movingDotButtonPressed
{
    [self presentViewController:[VTMovingDotDemoViewController new] animated:YES completion:nil];
}

- (void)verticalListButtonPressed
{
    [self presentViewController:[VTVerticalListViewController new] animated:YES completion:nil];
}

- (void)horizontalBrowsingButtonPressed
{
    [self presentViewController:[VTHorizontalBrowsingViewController new] animated:YES completion:nil];
}

- (void)keyboardButtonPressed
{
//    [self presentViewController:[VTHorizontalBrowsingViewController new] animated:YES completion:nil];
}

@end
