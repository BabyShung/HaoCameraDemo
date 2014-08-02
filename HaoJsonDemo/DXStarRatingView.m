
#import "DXStarRatingView.h"

#define kStarPadding 1.0

#define kRatingStarOnImage [UIImage imageNamed:@"star_on.png"]
#define kRatingStarOffImage [UIImage imageNamed:@"star_off.png"]

@interface DXStarRatingView ()
{
    int _stars;
    id _target;
    SEL _callBackAction;
    DXStarRatingViewCallBack _callBackBlock;
    
    BOOL _isInitialized;
}

@end

@implementation DXStarRatingView

- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code

    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self) {
    }
    return self;
}

- (void)awakeFromNib{
    [self performSelector:@selector(setupInterface) withObject:nil afterDelay:0.1];
}

- (void)setStars:(int)stars{
    _stars = stars;
    [self setupInterface];
}

- (void)setStars:(int)stars callbackBlock:(DXStarRatingViewCallBack)callBackBlock{
    _stars = stars;
    [self setupInterface];
    _callBackBlock = [callBackBlock copy];
}

- (void)setStars:(int)stars target:(id)target callbackAction:(SEL)callBackAction{
    _stars = stars;
    _target = target;
    _callBackAction = callBackAction;
    [self setupInterface];
}

- (NSUInteger) currentStar{
    return _stars;
}

- (void)setupInterface{
    if (_isInitialized) {
        //if the star rating view is already set then no need to do it all over again
        [self updateStarUI];
        return;
    }
    [[self subviews]makeObjectsPerformSelector:@selector(removeFromSuperview)];
    UIImage *starImageOn = kRatingStarOnImage;
    UIImage *starImageOff = kRatingStarOffImage;
    
    CGRect frame = self.frame;
    frame.size.height = starImageOn.size.height;
    frame.size.width = starImageOn.size.width*5+4*kStarPadding;
    self.frame = frame;
    
    CGFloat xOrigin = 0.0f;
    for (int counter=1; counter<=5; counter++) {
        UIImageView *imageView = [[UIImageView alloc]initWithImage:(counter<=_stars)?starImageOn:starImageOff];
        [imageView sizeToFit];
        frame = imageView.frame;
        frame.origin.x = xOrigin;
        frame.origin.y=0;
        imageView.frame=frame;
        imageView.tag=counter;
        
        [self addSubview:imageView];
        xOrigin+=starImageOn.size.width+kStarPadding;
    }
    _isInitialized = YES;
}

- (void)updateStarUI{
    UIImage *starImageOn = kRatingStarOnImage;
    UIImage *starImageOff = kRatingStarOffImage;
    
    for (int counter=1; counter<=5; counter++) {
        UIImageView *imageView = (UIImageView*)[self viewWithTag:counter];
        imageView.image = (counter<=_stars)?starImageOn:starImageOff;
    }
}

#define kQuarterStarDivident 20.0

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self handleStarTouches:touches withEvent:event];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    [self handleStarTouches:touches withEvent:event];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    [self handleStarTouches:touches withEvent:event];
    [self performCallBackWithStarValue];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event{
    [self updateStarUI];
    [self performCallBackWithStarValue];
}

- (void)handleStarTouches:(NSSet *)touches withEvent:(UIEvent *)event{
    if (CGRectContainsPoint(self.bounds, [[[touches allObjects]lastObject] locationInView:self])) {
        
        float xpos = [[[touches allObjects]lastObject] locationInView:self].x;
        _stars = xpos/((self.bounds.size.width)/5.0f)+1;
        
        if (_stars==1) {
            if (xpos<(self.bounds.size.width/kQuarterStarDivident)) {
                //if user slides below half star then make it zero
                _stars=0;
            }
        }
        [self updateStarUI];
    }
}

#pragma mark - call back target -

- (void)performCallBackWithStarValue{
    if (_callBackAction) {
       [_target performSelectorOnMainThread:_callBackAction withObject:@(_stars) waitUntilDone:YES];
    }
    if (_callBackBlock) {
        _callBackBlock(@(_stars));
    }
}

@end
