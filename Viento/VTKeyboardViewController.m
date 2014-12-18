//
//  VTKeyboardViewController.m
//  Viento
//
//  Created by Radu Dutzan on 12/17/14.
//  Copyright (c) 2014 Radu Dutzan. All rights reserved.
//

#import "VTKeyboardViewController.h"

@interface VTKeyboardViewController ()

@property (nonatomic, strong) UIView *buttonContainer;
@property (nonatomic) CGPoint cursorCenter;
@property (nonatomic, strong) UIButton *preSelectedButton;
@property (nonatomic, strong) UIButton *selectedButton;
@property (nonatomic, strong) UIView *selectionIndicator;
@property (nonatomic, strong) UITextView *typedTextView;

@end

@implementation VTKeyboardViewController

BOOL _tracking = NO;
CALayer *_textCursor;

- (void)viewDidLoad
{
    self.buttonContainer = [UIView new];
    
    self.selectionIndicator = [UIView new];
    self.selectionIndicator.layer.borderColor = [UIColor whiteColor].CGColor;
    self.selectionIndicator.layer.borderWidth = 2;
    
    self.typedTextView = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, 590, 100)];
    self.typedTextView.center = CGPointMake(self.typedTextView.center.x, self.view.center.y);
    self.typedTextView.backgroundColor = [UIColor blackColor];
    self.typedTextView.textColor = [UIColor whiteColor];
    self.typedTextView.font = [UIFont systemFontOfSize:44];
    self.typedTextView.text = @"";
    self.typedTextView.textContainerInset = UIEdgeInsetsMake(22, 15, 0, 0);
    self.typedTextView.layer.borderColor = [UIColor whiteColor].CGColor;
    self.typedTextView.layer.borderWidth = 1;
    self.typedTextView.layer.cornerRadius = 8;
    
    _textCursor = [CALayer layer];
    _textCursor.frame = CGRectMake(self.typedTextView.textContainerInset.left, 15, 5, self.typedTextView.bounds.size.height - 30);
    _textCursor.backgroundColor = [UIColor whiteColor].CGColor;
    _textCursor.opacity = 0.8;
    [self.typedTextView.layer addSublayer:_textCursor];
    
    UILabel *swipeNotice = [[UILabel alloc] initWithFrame:CGRectMake(0, (self.view.bounds.size.height / 6) * 5, self.view.bounds.size.width, self.view.bounds.size.height / 5)];
    swipeNotice.text = @"Swipe from the right edge of the screen to delete.";
    swipeNotice.textColor = [UIColor colorWithWhite:.5 alpha:1];
    swipeNotice.numberOfLines = 0;
    swipeNotice.font = [UIFont systemFontOfSize:22];
    swipeNotice.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:swipeNotice];
    
    [self createButtonsWithCharacters:@[@"a", @"b", @"c", @"d", @"e", @"f", @"g", @"h", @"i", @"j", @"k", @"l", @"m", @"n", @"o", @"p", @"q", @"r", @"s", @"t", @"u", @"v", @"w", @"x", @"y", @"z", @"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9", @"0"]];
}

- (void)createButtonsWithCharacters:(NSArray *)characters
{
    CGSize buttonSize = CGSizeMake(80, 80);
    self.buttonContainer.frame = CGRectMake(50, 0, buttonSize.width * 6, buttonSize.height * 7);
    CGFloat buttonOriginX = 0;
    CGFloat buttonOriginY = 0;
    
    for (NSString *character in characters) {
        UIButton *characterButton = [UIButton buttonWithType:UIButtonTypeCustom];
        characterButton.frame = CGRectMake(buttonOriginX, buttonOriginY, buttonSize.width, buttonSize.height);
        characterButton.titleLabel.font = [UIFont systemFontOfSize:42];
        [characterButton setTitle:character forState:UIControlStateNormal];
        [characterButton addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [self.buttonContainer addSubview:characterButton];
        
        buttonOriginX += buttonSize.width;
        if (buttonOriginX >= self.buttonContainer.bounds.size.width) {
            buttonOriginX = 0;
            buttonOriginY += buttonSize.height;
        }
    }
    
    UIButton *spaceButton = [UIButton buttonWithType:UIButtonTypeCustom];
    spaceButton.frame = CGRectMake(0, buttonOriginY, self.buttonContainer.bounds.size.width / 2, buttonSize.height);
    spaceButton.titleLabel.font = [UIFont systemFontOfSize:32];
    [spaceButton setTitle:@"SPACE" forState:UIControlStateNormal];
    [spaceButton addTarget:self action:@selector(spaceButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [self.buttonContainer addSubview:spaceButton];
    
    UIButton *clearButton = [UIButton buttonWithType:UIButtonTypeCustom];
    clearButton.frame = CGRectMake(self.buttonContainer.bounds.size.width / 2, buttonOriginY, self.buttonContainer.bounds.size.width / 2, buttonSize.height);
    clearButton.titleLabel.font = [UIFont systemFontOfSize:32];
    [clearButton setTitle:@"CLEAR" forState:UIControlStateNormal];
    [clearButton addTarget:self action:@selector(clearButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [self.buttonContainer addSubview:clearButton];
    
    self.buttonContainer.center = CGPointMake(self.buttonContainer.center.x, self.view.center.y);
    [self.view addSubview:self.buttonContainer];
    
    self.typedTextView.frame = CGRectOffset(self.typedTextView.frame, self.buttonContainer.frame.origin.x + self.buttonContainer.bounds.size.width + 60, 0);
    [self.view addSubview:self.typedTextView];
    
    self.preSelectedButton = self.buttonContainer.subviews[0];
    self.selectedButton = self.buttonContainer.subviews[0];
    
    self.selectionIndicator.frame = CGRectMake(self.buttonContainer.frame.origin.x, self.buttonContainer.frame.origin.y, buttonSize.width, buttonSize.height);
    [self.view addSubview:self.selectionIndicator];
}

- (void)setPreSelectedButton:(UIButton *)preSelectedButton
{
    if ([_preSelectedButton isEqual:preSelectedButton]) return;
    
    if (_preSelectedButton.bounds.size.width != preSelectedButton.bounds.size.width) {
        [UIView animateWithDuration:.2 delay:0 usingSpringWithDamping:1 initialSpringVelocity:1 options:0 animations:^{
            self.selectionIndicator.frame = CGRectMake(self.selectionIndicator.frame.origin.x, self.selectionIndicator.frame.origin.y, preSelectedButton.bounds.size.width, preSelectedButton.bounds.size.height);
        } completion:nil];
    }
    
    _preSelectedButton = preSelectedButton;
    
    for (UIButton *button in self.buttonContainer.subviews) {
        button.backgroundColor = [UIColor clearColor];
    }
    preSelectedButton.backgroundColor = [UIColor colorWithWhite:1 alpha:.15];
}

- (void)setSelectedButton:(UIButton *)selectedButton
{
    if ([_selectedButton isEqual:selectedButton]) return;
    _selectedButton = selectedButton;
    
    [UIView animateWithDuration:.1 delay:0 usingSpringWithDamping:1 initialSpringVelocity:1 options:0 animations:^{
        self.selectionIndicator.center = [self.view convertPoint:selectedButton.center fromView:self.buttonContainer];
    } completion:nil];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    CABasicAnimation *cursorBlink = [CABasicAnimation animationWithKeyPath:@"opacity"];
    cursorBlink.fromValue = @0.8;
    cursorBlink.toValue = @0.2;
    cursorBlink.duration = 1.0;
    cursorBlink.autoreverses = YES;
    cursorBlink.repeatCount = HUGE_VALF;
    cursorBlink.fillMode = kCAFillModeBoth;
    [_textCursor addAnimation:cursorBlink forKey:@"opacityLoop"];
}

#pragma mark - Typing

- (void)buttonPressed:(UIButton *)button
{
    self.typedTextView.text = [self.typedTextView.text stringByAppendingString:[button titleForState:UIControlStateNormal]];
    [self textViewTextChanged];
}

- (void)spaceButtonPressed
{
    self.typedTextView.text = [self.typedTextView.text stringByAppendingString:@" "];
    [self textViewTextChanged];
}

- (void)clearButtonPressed
{
    self.typedTextView.text = @"";
    [self textViewTextChanged];
}

- (void)handleRightEdgeSwipeGesture
{
    if (self.typedTextView.text.length >= 1) self.typedTextView.text = [self.typedTextView.text stringByReplacingCharactersInRange:NSMakeRange(self.typedTextView.text.length - 1, 1) withString:@""];
    [self textViewTextChanged];
}

- (void)textViewTextChanged
{
    CGRect sizeRect = [self.typedTextView.text boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, self.typedTextView.bounds.size.height)
                                                            options:NSStringDrawingUsesLineFragmentOrigin
                                                         attributes:@{NSFontAttributeName: self.typedTextView.font}
                                                            context:nil];
    
    _textCursor.frame = CGRectMake(self.typedTextView.textContainerInset.left + sizeRect.size.width + 7, _textCursor.frame.origin.y, _textCursor.bounds.size.width, _textCursor.bounds.size.height);
}

#pragma mark - Scrolling and clicking

- (void)setCursorCenter:(CGPoint)cursorCenter
{
    cursorCenter.x = MAX(self.buttonContainer.frame.origin.x + self.selectionIndicator.bounds.size.width / 2, cursorCenter.x);
    cursorCenter.x = MIN(self.buttonContainer.frame.origin.x + self.buttonContainer.bounds.size.width - self.selectionIndicator.bounds.size.width / 2, cursorCenter.x);
    cursorCenter.y = MAX(self.buttonContainer.frame.origin.y + self.selectionIndicator.bounds.size.height / 2, cursorCenter.y);
    cursorCenter.y = MIN(self.buttonContainer.frame.origin.y + self.buttonContainer.bounds.size.height - self.selectionIndicator.bounds.size.height / 2, cursorCenter.y);
    _cursorCenter = cursorCenter;
    self.selectionIndicator.center = cursorCenter;
    
    self.preSelectedButton = (UIButton *)[self.buttonContainer hitTest:[self.buttonContainer convertPoint:cursorCenter fromView:self.view] withEvent:nil];
}

- (void)handleScrollWillBeginTrackingFromPoint:(CGPoint)relativeTouchPoint
{
    _tracking = YES;
    
//    self.cursorCenter = CGPointMake(self.buttonContainer.bounds.size.width * relativeTouchPoint.x, self.buttonContainer.bounds.size.height * relativeTouchPoint.y);
}

- (void)handleScrollWithOffset:(CGPoint)offset
{
    if (!_tracking) return;
    CGFloat accelerationFactor = 2.4;
    
    self.cursorCenter = CGPointMake(self.selectionIndicator.center.x - offset.x * accelerationFactor, self.selectionIndicator.center.y - offset.y * accelerationFactor);
}

- (void)handleScrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    _tracking = NO;
    self.selectedButton = self.preSelectedButton;
    
    // kill scrolling
    scrollView.contentOffset = scrollView.contentOffset;
}

- (void)handleClick
{
    [self.selectedButton sendActionsForControlEvents:UIControlEventTouchUpInside];
}

@end
