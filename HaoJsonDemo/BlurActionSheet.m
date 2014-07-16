//
//  BlurActionSheet.m
//  BlueCheese
//
//  Created by Hao Zheng on 6/18/14.
//  Copyright (c) 2014 Hao Zheng. All rights reserved.
//

/******************

 from top or from bottom, I modified this below three functions and added the BOOL fromBottom
 
 1.dismissTransition
 2.show
 3.subviewLayout

 ******************/
 
 
#import "BlurActionSheet.h"
#import "UIImage+ImageEffects.h"


#define kButtonHeight 60.f
#define kCancelButtonHeight 60.f

#define kAnimationDuration 0.3f

#define kSeparatorWidth .5f
#define kSeparatorMargin 10.f


#define kMargin 10.f
#define kBottomMargin 10.f
#define kTopMargin 30.f

#define kBlurRadiusLoginRegister 7.f
#define CORNER_RADIUS 8.f


@interface BlurActionSheet ()
@property (nonatomic, readonly) CGSize screenSize;

@property (nonatomic, strong, readonly) NSMutableArray *buttons;

@property (nonatomic, strong) UIButton *cancelButton;

@property (nonatomic, strong) UIImageView *blurView;

@property (nonatomic, strong, readonly) NSArray *separators;

@property (nonatomic, strong) UIView *backgroundView;

@property (nonatomic, strong) NSMutableDictionary *actionBlockForButtonIndex;


@end

static UIWindow *__sheetWindow = nil;

@implementation BlurActionSheet {
    UIColor *__backgroundColor;
}

@synthesize buttons = _buttons;


//used in loginRegister
- (instancetype)initWithDelegate_cancelButtonTitle:(NSString *)cancelButtonTitle {
    self = [super initWithFrame:CGRectZero];
    if (self) {
        [self __commonInit];//set up colors and blur radius
        
        [self setCancelButtonWithTitle:cancelButtonTitle];
    }
    return self;
}

/**************************
 
    set up colors and blur radius
 
 **************************/
- (void)__commonInit {
    _blurRadius = kBlurRadiusLoginRegister;
    _blurView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.screenSize.width, self.screenSize.height)];
    
    _blurView.alpha = 0.f;
    
    self.backgroundColor = [UIColor colorWithWhite:1.f alpha:0.95f];
    _highlightedButtonColor = [UIColor colorWithWhite:0.93f alpha:1.f];
    _separatorColor = [UIColor colorWithWhite:0.8 alpha:1.f];
    
    self.layer.cornerRadius = CORNER_RADIUS;
    self.clipsToBounds = YES;
}


#pragma mark - addButton

- (NSInteger)addButtonWithTitle:(NSString *)title {

    UIButton *newButton = [UIButton buttonWithType:UIButtonTypeSystem];
    newButton.titleLabel.font = [UIFont systemFontOfSize:19.f];
    [newButton setFrame:CGRectMake(0, 0, self.screenSize.width, kButtonHeight)];
    [newButton setTitle:title forState:UIControlStateNormal];
    [newButton addTarget:self action:@selector(dismissWithClickedButton:) forControlEvents:UIControlEventTouchUpInside];
    NSUInteger index = [self.buttons count];
    
    [self addSubview:newButton];
    [self.buttons addObject:newButton];
    
    return index;
    
}

- (NSInteger)addButtonWithTitle:(NSString *)title actionBlock:(void (^)())actionBlock {
    NSInteger index = [self addButtonWithTitle:title];
    [self.actionBlockForButtonIndex setObject:actionBlock forKey:[NSNumber numberWithInteger:index]];
    return index;
}


#pragma mark -


- (void)setCancelButtonWithTitle:(NSString *)title {
    if (self.cancelButton) {
        [self.cancelButton removeFromSuperview];
        self.cancelButton = nil;
    }
    if (title) {
        UIButton *newCancelButton = [UIButton buttonWithType:UIButtonTypeSystem];
        newCancelButton.titleLabel.font = [UIFont boldSystemFontOfSize:19.f];
        [newCancelButton setFrame:CGRectMake(0, 0, self.screenSize.width, kCancelButtonHeight)];
        [newCancelButton setTitle:title forState:UIControlStateNormal];
        [newCancelButton addTarget:self action:@selector(dismissWithCancelButton:) forControlEvents:UIControlEventTouchUpInside];
        self.cancelButton = newCancelButton;

        [self addSubview:newCancelButton];
    }
}

#pragma mark -

- (void)layoutSubviews {
    [super layoutSubviews];
    // calculate frames here
    
    CGSize screenSize = self.screenSize;
    
    CGFloat contentWidth = screenSize.width - (2*kMargin);
    
    CGFloat sheetHeight = ([self.buttons count] * kButtonHeight) + kCancelButtonHeight;
    
    //Hao modified
    CGFloat contentOffset;

    contentOffset = screenSize.height - sheetHeight  - kBottomMargin;

    
    self.frame = CGRectMake(kMargin, contentOffset, contentWidth, sheetHeight);
    
    contentOffset = 0.f;
    
    for (UIButton *button in self.buttons) {
        button.frame = CGRectMake(0.f, contentOffset, contentWidth, kButtonHeight);
        contentOffset += kButtonHeight;
    }
    
    if (self.cancelButton) {
        self.cancelButton.frame = CGRectMake(0.f, contentOffset, contentWidth, kCancelButtonHeight);
        contentOffset += kCancelButtonHeight;
    }
}

- (void)loadBlurViewContents {
    UIGraphicsBeginImageContextWithOptions(self.blurView.frame.size, NO, 0);
    UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];
    [keyWindow drawViewHierarchyInRect:self.blurView.frame afterScreenUpdates:NO];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    UIImage *blurredImage = [newImage applyBlurWithRadius:self.blurRadius tintColor:self.blurTintColor saturationDeltaFactor:1.f maskImage:nil];
    
    self.blurView.image = blurredImage;
}

#pragma mark - Show

- (void)show {
    UIWindow *window = [[UIWindow alloc] initWithFrame:(CGRect) {{0.f, 0.f}, self.screenSize}];
    window.backgroundColor = [UIColor clearColor];
    window.windowLevel = UIWindowLevelNormal;
    window.alpha = 1.f;
    [self layoutIfNeeded];
    [window addSubview:self.blurView];
    
    for (UIView *separator in self.separators) {
        [self addSubview:separator];
    }
    
    [window addSubview:self];
    [self loadBlurViewContents];
	
    window.hidden = NO;
    
    
    //above the screen, from top to down, note '-'
    //Hao modified

        self.frame = CGRectOffset(self.frame, 0.f, self.frame.size.height+kMargin);


    [UIView animateWithDuration:kAnimationDuration delay:0.f options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.blurView.alpha = 1.f;
        self.frame = CGRectOffset(self.frame, 0.f, -(self.frame.size.height+kMargin));
    } completion:^(BOOL finished) {

        
    }];
    
    __sheetWindow = window;
}


#pragma mark - Dismissal

- (void)dismissWithClickedButtonIndex:(NSInteger)buttonIndex animated:(BOOL)animated {
    [self dismissAnimated:animated clickedButtonIndex:buttonIndex];
}

/****************************************
 
    dismiss form, clicking normal btn
 
 ***************************************/
- (void)dismissWithClickedButton:(UIButton *)button {
    NSInteger buttonIndex = [self indexOfButton:button];
    
    void (^actionBlockForButton)() = [self.actionBlockForButtonIndex objectForKey:[NSNumber numberWithInteger:buttonIndex]];
    
    if (actionBlockForButton) {
        actionBlockForButton();
    }

    [self dismissWithClickedButtonIndex:buttonIndex animated:YES];
}

- (void)dismissWithCancelButton:(UIButton *)cancelButton {

    [self dismissAnimated:YES clickedButtonIndex:self.cancelButtonIndex];
}

- (void)dismissAnimated:(BOOL)animated clickedButtonIndex:(NSInteger)index {

    if (animated) {
        [UIView animateWithDuration:kAnimationDuration animations:^{
            [self dismissTransition];
        } completion:^(BOOL finished) {
            [self dismissCompletionWithButtonAtIndex:index];
        }];
    } else {
        [self dismissCompletionWithButtonAtIndex:index];
    }
}

- (void)dismissTransition {
    self.blurView.alpha = 0.f;
    
    self.frame = CGRectOffset(self.frame, 0.f, self.frame.size.height + kBottomMargin);

}

- (void)dismissCompletionWithButtonAtIndex:(NSInteger)index {

    __sheetWindow.hidden = YES;
    __sheetWindow = nil;
}



#pragma mark - Getters

- (NSInteger)indexOfButton:(UIButton *)button {
    if (button == self.cancelButton) {
        return [self cancelButtonIndex];
    }
    return [self.buttons indexOfObject:button];
}


- (NSMutableDictionary *)actionBlockForButtonIndex {
    if (!_actionBlockForButtonIndex) {
        _actionBlockForButtonIndex = [NSMutableDictionary dictionary];
    }
    return _actionBlockForButtonIndex;
}


- (NSArray *)separators {
    NSInteger buttonCount = self.buttons.count;
    NSMutableArray *mutableSeparators = [NSMutableArray arrayWithCapacity:buttonCount];
    
    CGFloat contentOffset = kButtonHeight - kSeparatorWidth;
    for (int i = 0; i < buttonCount; i++) {//Hao:can modify separator length
        UIView *separator = [[UIView alloc] initWithFrame:CGRectMake(kSeparatorMargin, contentOffset, self.frame.size.width-2*kSeparatorMargin, kSeparatorWidth)];
        separator.backgroundColor = self.separatorColor;
        contentOffset += kButtonHeight;
        [mutableSeparators addObject:separator];
    }
    
    return [mutableSeparators copy];
}

- (CGSize)screenSize {
    return [[UIScreen mainScreen] bounds].size;
}

- (UIColor *)separatorColor {
    if (!_separatorColor) {
        return [UIColor clearColor];
    }
    return _separatorColor;
}


- (NSMutableArray *)buttons {
    if (!_buttons) {
        _buttons = [NSMutableArray array];
    }
    return _buttons;
}

@end