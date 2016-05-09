/*
 
 Erica Sadun, http://ericasadun.com
 
 */

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

// Just because
#define TWO_PI (2 * M_PI)

// Undefined point
#define NULLPOINT CGRectNull.origin
#define POINT_IS_NULL(_POINT_) CGPointEqualToPoint(_POINT_, NULLPOINT)

// General
#define RECTSTRING(_aRect_)        NSStringFromCGRect(_aRect_)
#define POINTSTRING(_aPoint_)    NSStringFromCGPoint(_aPoint_)
#define SIZESTRING(_aSize_)        NSStringFromCGSize(_aSize_)

#define RECT_WITH_SIZE(_SIZE_) (CGRect){.size = _SIZE_}
#define RECT_WITH_POINT(_POINT_) (CGRect){.origin = _POINT_}

#define RANDOM(_X_)     (NSInteger)(random() % _X_)
#define RANDOM_01       ((double) random() / (double) LONG_MAX)
#define RANDOM_BOOL     (BOOL)((NSInteger)random() % 2)
#define CONTEXT         (CGContextRef)

#define radiansToDegrees(x) (180/M_PI)*x
#define degreesToRadians( degrees ) ( ( degrees ) / 180.0 * M_PI )
#define RadiansToDegrees(x) (180/M_PI)*x
#define DegreesToRadians( degrees ) ( ( degrees ) / 180.0 * M_PI )



// Utility
//CGFloat randFloat(CGFloat min, CGFloat max);
CGFloat PointDistanceFromPoint(CGPoint p1, CGPoint p2);
CGRect HalfScreenRect();
CGFloat ScreenHeight();
CGFloat ScreenWidth();
CGFloat ScreenLarger();
CGFloat ScreenSmaller();
CGRect ScreenRect();
CGRect DoubleScreenRect();

float randomFloat(float Min, float Max);
int randomInt(int low, int high);
BOOL randomBool();
float randomClamp();


CGPoint RandomPointInRect(CGRect rect);

UIColor* randomColor();


// Conversion
CGFloat DegreesFromRadians(CGFloat radians);
CGFloat RadiansFromDegrees(CGFloat degrees);

// Clamping
CGFloat Clamp(CGFloat a, CGFloat min, CGFloat max);
CGPoint ClampToRect(CGPoint pt, CGRect rect);

// General Geometry
CGPoint RectGetCenter(CGRect rect);
CGFloat PointDistanceFromPoint(CGPoint p1, CGPoint p2);

// Construction
CGRect RectMakeRect(CGPoint origin, CGSize size);
CGRect SizeMakeRect(CGSize size);
CGRect PointsMakeRect(CGPoint p1, CGPoint p2);
CGRect OriginMakeRect(CGPoint origin);
CGRect RectAroundCenter(CGPoint center, CGSize size);
CGRect RectCenteredInRect(CGRect rect, CGRect mainRect);

// Point Locations
CGPoint RectGetPointAtPercents(CGRect rect, CGFloat xPercent, CGFloat yPercent);
CGPoint PointAddPoint(CGPoint p1, CGPoint p2);
CGPoint PointSubtractPoint(CGPoint p1, CGPoint p2);
CGPoint MidPoint(CGPoint p1,CGPoint p2);


/* Time Helpers */
NSString* timeSince(CGFloat then);
NSString* floatString(CGFloat value);

NSString* StringInBetween(NSString* source,NSString* from,NSString* to);

#pragma mark - Color Helpers
/* Temporarily until move to proper place */

UIColor *colorAtPoint(CGPoint pixelPoint,UIImage *image);
NSString* stringFromColor(UIColor *color);
UIColor* lightenColor(UIColor* color,CGFloat amount);
UIColor* darkenColor(UIColor* color,CGFloat amount);
UIColor* randomColor();





#pragma mark - Trig
CGFloat GetAngle(CGPoint firstPoint,CGPoint secondPoint);
CGRect GetBoundingRectAfterRotation(CGRect rect, CGFloat angle);
CGPoint PointCalculateRotatedTopRightPoint(CGPoint viewCenter,CGFloat size,CGFloat angle,BOOL degrees);

CGRect MidSquareRect();
CGRect MidSquareRectWithMultiplyer(CGFloat multiplyer);

// Cardinal Points
CGPoint RectGetTopLeft(CGRect rect);
CGPoint RectGetTopRight(CGRect rect);
CGPoint RectGetBottomLeft(CGRect rect);
CGPoint RectGetBottomRight(CGRect rect);
CGPoint RectGetMidTop(CGRect rect);
CGPoint RectGetMidBottom(CGRect rect);
CGPoint RectGetMidLeft(CGRect rect);
CGPoint RectGetMidRight(CGRect rect);

// Aspect and Fitting
CGSize  SizeScaleByFactor(CGSize aSize, CGFloat factor);
CGSize  RectGetScale(CGRect sourceRect, CGRect destRect);
CGFloat AspectScaleFill(CGSize sourceSize, CGRect destRect);
CGFloat AspectScaleFit(CGSize sourceSize, CGRect destRect);
CGRect  RectByFittingRect(CGRect sourceRect, CGRect destinationRect);
CGRect  RectByFillingRect(CGRect sourceRect, CGRect destinationRect);
CGRect RectInsetByPercent(CGRect rect, CGFloat percent);

// Transforms
CGFloat TransformGetXScale(CGAffineTransform t);
CGFloat TransformGetYScale(CGAffineTransform t);
CGFloat TransformGetRotation(CGAffineTransform t);













// NEW Math Method
CGFloat ValueInRemappedRangeDefinedByOldMinAndMaxToNewMinAndMax(CGFloat oldValue, CGFloat oldMax,CGFloat oldMin, CGFloat newMin, CGFloat newMax);
CGFloat RemappedValueInRangeDefinedByOldMinAndMaxToNewMinAndMax(CGFloat oldValue, CGFloat oldMin,CGFloat oldMax, CGFloat newMin, CGFloat newMax);


