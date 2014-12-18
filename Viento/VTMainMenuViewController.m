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
#import "VTKeyboardViewController.h"

@interface VTMainMenuViewController ()

@property (nonatomic, strong) NSArray *buttons;
@property (nonatomic) CGPoint cursorPosition;
@property (nonatomic, strong) UIButton *selectedButton;
@property (nonatomic, strong) CALayer *selectionIndicator;

@end

@implementation VTMainMenuViewController

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
    
    self.selectionIndicator = [CALayer layer];
    self.selectionIndicator.borderColor = [UIColor whiteColor].CGColor;
    self.selectionIndicator.borderWidth = 3;
    
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
    [keyboardButton setTitle:@"Keyboard" forState:UIControlStateNormal];
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
    self.selectedButton = firstButton;
    self.cursorPosition = CGPointZero;
    
    self.selectionIndicator.frame = CGRectInset(firstButton.frame, -8, -8);
    self.selectionIndicator.cornerRadius = firstButton.layer.cornerRadius + 8;
    [buttonContainer.layer addSublayer:self.selectionIndicator];
}

- (void)setCursorPosition:(CGPoint)cursorPosition
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
    
    CGFloat cursorPositionX = cursorPosition.x;
    cursorPositionX = MIN(buttonTolerance * self.buttons.count, cursorPositionX);
    cursorPositionX = MAX(0, cursorPositionX);
    _cursorPosition = CGPointMake(cursorPositionX, 0);
    
    UIButton *firstButton = self.buttons[0];
    UIButton *lastButton = [self.buttons lastObject];
    NSUInteger currentIndex = [self.buttons indexOfObject:self.selectedButton];
    CGRect selectedButtonFakeRect = CGRectMake(buttonTolerance * currentIndex, 0, buttonTolerance, buttonTolerance);
//    NSLog(@"Cursor at: %@, -- Current Button Index: %lu -- Fake Rect: %@", NSStringFromCGPoint(_cursorPosition), (unsigned long)currentIndex, NSStringFromCGRect(selectedButtonFakeRect));
    
    if ((_cursorPosition.x >= selectedButtonFakeRect.size.width + selectedButtonFakeRect.origin.x) &&
        ![self.selectedButton isEqual:lastButton]) {
        // switch to next button, to the left
        self.selectedButton = self.buttons[currentIndex + 1];
        
    } else if ((_cursorPosition.x <= selectedButtonFakeRect.origin.x) &&
               ![self.selectedButton isEqual:firstButton]) {
        // switch to previous button, to the right
        self.selectedButton = self.buttons[currentIndex - 1];
    }
}

- (void)setSelectedButton:(UIButton *)selectedButton
{
    if (_selectedButton == selectedButton) return;
    _selectedButton = selectedButton;
    
    for (UIButton *button in self.buttons) {
        button.backgroundColor = [UIColor colorWithWhite:.1 alpha:1];
    }
    
    [UIView animateWithDuration:.2 delay:0 usingSpringWithDamping:1 initialSpringVelocity:1 options:0 animations:^{
        self.selectionIndicator.frame = CGRectInset(selectedButton.frame, -8, -8);
        selectedButton.backgroundColor = [UIColor colorWithWhite:.25 alpha:1];
    } completion:nil];
}

- (void)handleScrollWithOffset:(CGPoint)offset
{
    self.cursorPosition = CGPointMake(self.cursorPosition.x - offset.x, 0);
}

- (void)handleClick
{
    NSLog(@"Clicking button: %@", [self.selectedButton titleForState:UIControlStateNormal]);
    [self.selectedButton sendActionsForControlEvents:UIControlEventTouchUpInside];
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
    [self presentViewController:[VTKeyboardViewController new] animated:YES completion:nil];
}

@end
