
#import <UIKit/UIKit.h>

@interface MLPSpotlight : UIView

@property (assign) NSTimeInterval animationDuration;
@property (assign) CGPoint spotlightCenter;
@property (nonatomic) CGGradientRef spotlightGradientRef;
@property (assign) float spotlightStartRadius;
@property (assign) float spotlightEndRadius;

+ (instancetype)addSpotlightInView:(UIView *)view atPoint:(CGPoint)centerPoint;

+ (instancetype)addSpotlightInView:(UIView *)view atPoint:(CGPoint)centerPoint withDuration:(NSTimeInterval)duration;

+ (NSArray *)spotlightsInView:(UIView *)view;

+ (void)removeSpotlightsInView:(UIView *)view;

+ (instancetype)spotlightWithFrame:(CGRect)frame withSpotlightAtPoint:(CGPoint)centerPoint;

- (id)initWithFrame:(CGRect)frame withSpotlightAtPoint:(CGPoint)centerPoint;

@end
