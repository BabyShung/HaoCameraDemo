
typedef void(^DXStarRatingViewCallBack)(NSNumber *newRating);

#import <UIKit/UIKit.h>

@interface DXStarRatingView : UIView

/**
 * @brief set the inital star value
 * @param  stars number of stars to be set
 * @return -
 */
- (void)setStars:(int)stars;

/**
 * @brief set initial stars and a callback action
 * @param stars number of stars to be set
 * @param target target to register action
 * @param action a SEL to be performed on star change event
 * @return -
 */
- (void)setStars:(int)stars target:(id)target callbackAction:(SEL)cllBackAction;

/**
 * @brief set initial stars and a callback block
 * @param stars number of stars to be set
 * @param void(^)(NSNumber*) a Block to recieve callback action
 * @return -
 */
- (void)setStars:(int)stars callbackBlock:(DXStarRatingViewCallBack)callBackBlock;
- (NSUInteger) currentStar;

@end
