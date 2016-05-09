/*
 
 Erica Sadun, http://ericasadun.com
 
 */

#import "BaseGeometry.h"

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#pragma mark - UTILITY


CGFloat ScreenLarger()
{
    CGFloat larger;
    
    if ([UIScreen mainScreen].bounds.size.height > [UIScreen mainScreen].bounds.size.width) {
        larger = [UIScreen mainScreen].bounds.size.height;
    }
    else
    {
        larger = [UIScreen mainScreen].bounds.size.width;
    }
    
    return larger;
}


CGFloat ScreenSmaller()
{
    CGFloat smaller;
    
    if ([UIScreen mainScreen].bounds.size.height < [UIScreen mainScreen].bounds.size.width) {
        smaller = [UIScreen mainScreen].bounds.size.height;
    }
    else
    {
        smaller = [UIScreen mainScreen].bounds.size.width;
    }
    
    return smaller;
}




CGFloat ScreenHeight()
{
    return [UIScreen mainScreen].bounds.size.height;
}
CGFloat ScreenWidth()
{
    return [UIScreen mainScreen].bounds.size.width;
}

CGSize ScreenSize()
{
    return [UIScreen mainScreen].bounds.size;
}


CGRect ScreenRect()
{
    return [UIScreen mainScreen].bounds;
}

CGRect DoubleScreenRect()
{
    CGFloat w = ScreenWidth() * 2;
    CGFloat h = ScreenHeight() * 2;
    
    return CGRectMake(-w/2, -h/2, w, h);
}

CGRect MidSquareRect()
{
     CGFloat pad = (ScreenHeight() - ScreenWidth())/2;
    
    CGFloat x = 0;
    CGFloat y = pad;
    CGFloat w = floorf(ScreenSmaller());
    CGFloat h = floorf(ScreenSmaller());
    
    return CGRectMake(x, y, w, h);
}


CGRect MidSquareRectWithMultiplyer(CGFloat multiplyer)
{
    CGFloat insetAmount = (multiplyer * ScreenSmaller())/2;
    CGRect layerRect = CGRectInset(MidSquareRect(), insetAmount, insetAmount);
    
    return layerRect;

}


CGRect HalfScreenRect()
{
    CGRect screenRect = [UIScreen mainScreen].bounds;
    
    return CGRectMake(screenRect.size.width/4, screenRect.size.height/4, screenRect.size.width/2, screenRect.size.height/2);
    
}

#pragma mark - Conversion
// Degrees from radians
CGFloat DegreesFromRadians(CGFloat radians)
{
    return radians * 180.0f / M_PI;
}

// Radians from degrees
CGFloat RadiansFromDegrees(CGFloat degrees)
{
    return degrees * M_PI / 180.0f;
}

#pragma mark - Clamp
CGFloat Clamp(CGFloat a, CGFloat min, CGFloat max)
{
    return fmin(fmax(min, a), max);
}

CGPoint ClampToRect(CGPoint pt, CGRect rect)
{
    CGFloat x = Clamp(pt.x, CGRectGetMinX(rect), CGRectGetMaxX(rect));
    CGFloat y = Clamp(pt.y, CGRectGetMinY(rect), CGRectGetMaxY(rect));
    return CGPointMake(x, y);
}


#pragma mark - General Geometry
CGPoint RectGetCenter(CGRect rect)
{
    return CGPointMake(CGRectGetMidX(rect), CGRectGetMidY(rect));
}

CGFloat PointDistanceFromPoint(CGPoint p1, CGPoint p2)
{
    CGFloat dx = p2.x - p1.x;
    CGFloat dy = p2.y - p1.y;
    
    return sqrt(dx*dx + dy*dy);
}

CGPoint RectGetPointAtPercents(CGRect rect, CGFloat xPercent, CGFloat yPercent)
{
    CGFloat dx = xPercent * rect.size.width;
    CGFloat dy = yPercent * rect.size.height;
    return CGPointMake(rect.origin.x + dx, rect.origin.y + dy);
}

#pragma mark - Rectangle Construction
CGRect RectMakeRect(CGPoint origin, CGSize size)
{
    return (CGRect){.origin = origin, .size = size};
}

CGRect SizeMakeRect(CGSize size)
{
    return (CGRect){.size = size};
}

CGRect PointsMakeRect(CGPoint p1, CGPoint p2)
{
    CGRect rect = CGRectMake(p1.x, p1.y, p2.x - p1.x, p2.y - p1.y);
    return CGRectStandardize(rect);
}

CGRect OriginMakeRect(CGPoint origin)
{
    return (CGRect){.origin = origin};
}

CGRect RectAroundCenter(CGPoint center, CGSize size)
{
    CGFloat halfWidth = size.width / 2.0f;
    CGFloat halfHeight = size.height / 2.0f;
    
    return CGRectMake(center.x - halfWidth, center.y - halfHeight, size.width, size.height);
}

CGRect RectCenteredInRect(CGRect rect, CGRect mainRect)
{
    CGFloat dx = CGRectGetMidX(mainRect)-CGRectGetMidX(rect);
    CGFloat dy = CGRectGetMidY(mainRect)-CGRectGetMidY(rect);
    return CGRectOffset(rect, dx, dy);
}




#pragma mark - Point Location
CGPoint PointAddPoint(CGPoint p1, CGPoint p2)
{
    return CGPointMake(p1.x + p2.x, p1.y + p2.y);
}

CGPoint PointSubtractPoint(CGPoint p1, CGPoint p2)
{
    return CGPointMake(p1.x - p2.x, p1.y - p2.y);
}

CGPoint MidPoint(CGPoint p1,CGPoint p2)
{
    CGPoint midPoint;
    CGFloat x = (p1.x + p2.x)/2;
    CGFloat y = (p1.y + p2.y)/2;
    
    midPoint.x = x;
    midPoint.y = y;
    
    return midPoint;
}


#pragma mark - Cardinal Points
CGPoint RectGetTopLeft(CGRect rect)
{
    return CGPointMake(
                       CGRectGetMinX(rect),
                       CGRectGetMinY(rect)
                       );
}

CGPoint RectGetTopRight(CGRect rect)
{
    return CGPointMake(
                       CGRectGetMaxX(rect),
                       CGRectGetMinY(rect)
                       );
}

CGPoint RectGetBottomLeft(CGRect rect)
{
    return CGPointMake(
                       CGRectGetMinX(rect),
                       CGRectGetMaxY(rect)
                       );
}

CGPoint RectGetBottomRight(CGRect rect)
{
    return CGPointMake(
                       CGRectGetMaxX(rect),
                       CGRectGetMaxY(rect)
                       );
}

CGPoint RectGetMidTop(CGRect rect)
{
    return CGPointMake(
                       CGRectGetMidX(rect),
                       CGRectGetMinY(rect)
                       );
}

CGPoint RectGetMidBottom(CGRect rect)
{
    return CGPointMake(
                       CGRectGetMidX(rect),
                       CGRectGetMaxY(rect)
                       );
}

CGPoint RectGetMidLeft(CGRect rect)
{
    return CGPointMake(
                       CGRectGetMinX(rect),
                       CGRectGetMidY(rect)
                       );
}

CGPoint RectGetMidRight(CGRect rect)
{
    return CGPointMake(
                       CGRectGetMaxX(rect),
                       CGRectGetMidY(rect)
                       );
}

#pragma mark - Aspect and Fitting
CGSize SizeScaleByFactor(CGSize aSize, CGFloat factor)
{
    return CGSizeMake(aSize.width * factor, aSize.height * factor);
}

CGSize RectGetScale(CGRect sourceRect, CGRect destRect)
{
    CGSize sourceSize = sourceRect.size;
    CGSize destSize = destRect.size;
    
    CGFloat scaleW = destSize.width / sourceSize.width;
    CGFloat scaleH = destSize.height / sourceSize.height;
    
    return CGSizeMake(scaleW, scaleH);
}

CGFloat AspectScaleFill(CGSize sourceSize, CGRect destRect)
{
    CGSize destSize = destRect.size;
    CGFloat scaleW = destSize.width / sourceSize.width;
    CGFloat scaleH = destSize.height / sourceSize.height;
    return fmax(scaleW, scaleH);
}

CGFloat AspectScaleFit(CGSize sourceSize, CGRect destRect)
{
    CGSize destSize = destRect.size;
    CGFloat scaleW = destSize.width / sourceSize.width;
    CGFloat scaleH = destSize.height / sourceSize.height;
    return fmin(scaleW, scaleH);
}

CGRect RectByFittingRect(CGRect sourceRect, CGRect destinationRect)
{
    CGFloat aspect = AspectScaleFit(sourceRect.size, destinationRect);
    CGSize targetSize = SizeScaleByFactor(sourceRect.size, aspect);
    return RectAroundCenter(RectGetCenter(destinationRect), targetSize);
}

CGRect RectByFillingRect(CGRect sourceRect, CGRect destinationRect)
{
    CGFloat aspect = AspectScaleFill(sourceRect.size, destinationRect);
    CGSize targetSize = SizeScaleByFactor(sourceRect.size, aspect);
    return RectAroundCenter(RectGetCenter(destinationRect), targetSize);
}

CGRect RectInsetByPercent(CGRect rect, CGFloat percent)
{
    CGFloat wInset = rect.size.width * (percent / 2.0f);
    CGFloat hInset = rect.size.height * (percent / 2.0f);
    return CGRectInset(rect, wInset, hInset);
}

#pragma mark - Transforms

// Extract the x scale from transform
CGFloat TransformGetXScale(CGAffineTransform t)
{
    return sqrt(t.a * t.a + t.c * t.c);
}

// Extract the y scale from transform
CGFloat TransformGetYScale(CGAffineTransform t)
{
    return sqrt(t.b * t.b + t.d * t.d);
}

// Extract the rotation in radians
CGFloat TransformGetRotation(CGAffineTransform t)
{
    return atan2f(t.b, t.a);
}


#pragma mark TIME HELPER
NSString* floatString(CGFloat value)
{
    NSNumber *sinceNumber = [NSNumber numberWithFloat:value];
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    numberFormatter.alwaysShowsDecimalSeparator = YES;
    numberFormatter.minimumFractionDigits = 3;
    numberFormatter.maximumFractionDigits = 3;
    numberFormatter.minimumIntegerDigits = 1;
    
    return [numberFormatter stringFromNumber:sinceNumber];
    
    
}
NSString* timeSince(CGFloat then)
{
    CFAbsoluteTime now = CFAbsoluteTimeGetCurrent();
    CGFloat since = now-then;
    NSNumber *sinceNumber = [NSNumber numberWithFloat:since];
    
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    numberFormatter.alwaysShowsDecimalSeparator = YES;
    numberFormatter.minimumFractionDigits = 2;
    numberFormatter.maximumFractionDigits = 2;
    numberFormatter.minimumIntegerDigits = 1;
    
    return [numberFormatter stringFromNumber:sinceNumber];
    
}

#pragma mark - String Helpers

NSString* StringInBetween(NSString* source,NSString* from,NSString* to)
{
    // Add Options To string searching
    NSRange startRange = [source rangeOfString:from];
    NSString *firstChopToEnd = [source substringFromIndex:(startRange.location+startRange.length)];
    // Find the Second
    NSRange endRange = [firstChopToEnd rangeOfString:to];
    NSString *inBetween = [firstChopToEnd substringToIndex:endRange.location];
    return inBetween;
}





#pragma mark - COLORS


UIColor *colorAtPoint(CGPoint pixelPoint,UIImage *image)
{
    
    CGDataProviderRef provider = CGImageGetDataProvider(image.CGImage);
    CFDataRef pixelData = CGDataProviderCopyData(provider);
    const UInt8* data = CFDataGetBytePtr(pixelData);
    
    int numberOfColorComponents = 4; // R,G,B, and A
    float x = pixelPoint.x;
    float y = pixelPoint.y;
    float w = image.size.width;
    int pixelInfo = ((w * y) + x) * numberOfColorComponents;
    
    UInt8 red = data[pixelInfo];
    UInt8 green = data[(pixelInfo + 1)];
    UInt8 blue = data[pixelInfo + 2];
    UInt8 alpha = data[pixelInfo + 3];
    CFRelease(pixelData);
    
    // RGBA values range from 0 to 255
    return [UIColor colorWithRed:red/255.0
                           green:green/255.0
                            blue:blue/255.0
                           alpha:alpha/255.0];
    
}



NSString* stringFromColor(UIColor *color)
{
    const size_t totalComponents = CGColorGetNumberOfComponents(color.CGColor);
    const CGFloat * components = CGColorGetComponents(color.CGColor);
    return [NSString stringWithFormat:@"#%02X%02X%02X",(int)(255 * components[MIN(0,totalComponents-2)]),(int)(255 * components[MIN(1,totalComponents-2)]),(int)(255 * components[MIN(2,totalComponents-2)])];
}



UIColor* lightenColor(UIColor* color,CGFloat amount)
{
    CGFloat hue, saturation, brightness, alpha;
    
    [color getHue:&hue saturation:&saturation brightness:&brightness alpha:&alpha];
    
    UIColor *lightendColor = [UIColor colorWithHue:hue saturation:saturation * (1.0f - amount) brightness:brightness * (1.0f + amount) alpha:alpha];
    
    return lightendColor;
    
}


UIColor* darkenColor(UIColor* color,CGFloat amount)
{
    CGFloat hue, saturation, brightness, alpha;
    
    [color getHue:&hue saturation:&saturation brightness:&brightness alpha:&alpha];
    
    UIColor *darkendColor = [UIColor colorWithHue:hue saturation:saturation * (1.0f + amount) brightness:brightness * (1.0f - amount) alpha:alpha];
    
    return darkendColor;
    
}

UIColor* randomColor()
{
    return [UIColor colorWithRed:(arc4random()%255)/255.0f
                           green:(arc4random()%255)/255.0f
                            blue:(arc4random()%255)/255.0f
                           alpha:1.0f];
}


UIColor* colorOfRandomValue()
{
    return [UIColor colorWithRed:(arc4random()%255)/255.0f
                           green:(arc4random()%255)/255.0f
                            blue:(arc4random()%255)/255.0f
                           alpha:1.0f];
}



#pragma mark - Trig

CGFloat GetAngle(CGPoint firstPoint,CGPoint secondPoint)
{
    CGFloat dx = firstPoint.x - secondPoint.x;
    CGFloat dy = firstPoint.y - secondPoint.y;
    CGFloat angle = (atan2(dy, dx));
    
    return DegreesFromRadians(angle);
}

CGRect GetBoundingRectAfterRotation(CGRect rect, CGFloat angle)
{
    
    CGFloat newWidth = rect.size.width * fabsf(cosf(angle)) + rect.size.height * fabsf(sinf(angle));
    
    CGFloat newHeight = rect.size.height  * fabsf(cosf(angle)) + (rect.size.width) * fabs(sinf(angle));
    
    CGFloat newX = (rect.origin.x) + ((rect.size.width) - newWidth) / 2;
    
    CGFloat newY = (rect.origin.y) + ((rect.size.height) - newHeight) / 2;
    
    CGRect rotatedRect = CGRectMake(newX, newY, newWidth,newHeight);
    
    return rotatedRect;
    
}

CGPoint PointCalculateRotatedTopRightPoint(CGPoint viewCenter,CGFloat size,CGFloat angle,BOOL degrees)
{
    CGFloat adjacent = size/2.0;
    CGFloat opposite = size/2.0;
    CGFloat hipotenuse = sqrtf(powf(adjacent, 2.0) + pow(opposite, 2.0));
    CGFloat thetaRad = acosf((powf(hipotenuse, 2.0) + powf(adjacent, 2.0) - pow(opposite, 2.0)) / (2 * hipotenuse * adjacent));
    
    CGFloat angleRad = 0.0;
    if (degrees) {
        angleRad = angle*M_PI/180.0;
    } else {
        angleRad = angle;
    }
    
    CGFloat widthOffset = cosf(angleRad - thetaRad) * hipotenuse;
    CGFloat heightOffset = sinf(angleRad - thetaRad) * hipotenuse;
    
    return CGPointMake(viewCenter.x + widthOffset, viewCenter.y + heightOffset);
    
}







#pragma mark - Random Float Helpers
//
float randomFloat(float Min, float Max){
    return ((arc4random()%RAND_MAX)/(RAND_MAX*1.0))*(Max-Min)+Min;
}

/* Return a random integer number between low and high inclusive */
int randomInt(int low, int high)
{
    return (arc4random() % (high-low+1)) + low;
}

/* Return a random BOOL value */
BOOL randomBool()
{
    return (BOOL)randomInt(0, 1);
}

/* Return a random float between 0.0 and 1.0 */
float randomClamp()
{
    return (float)(arc4random() % ((unsigned)RAND_MAX + 1)) / (float)((unsigned)RAND_MAX + 1);
}

CGPoint RandomPointInRect(CGRect rect)
{
    CGFloat x = rect.origin.x + randomClamp() * rect.size.width;
    CGFloat y = rect.origin.y + randomClamp() * rect.size.height;
    
    return CGPointMake(x,y);
}




/** Returns value remapped in a new range.
 
 @param oldVal Original float value to be remapped.
 @param oldMaxVal Maximum value of the original range.
 @param oldMinVal Minimum value of the original range.
 @param newMaxVal Maximum value of the new range.
 @param newMinVal Minimum value of the new range.
 @return Returns the float value remapped in the new range.
 */

CGFloat ValueInRemappedRangeDefinedByOldMinAndMaxToNewMinAndMax(CGFloat oldValue, CGFloat oldMin,CGFloat oldMax, CGFloat newMin, CGFloat newMax)
{
    CGFloat realRange    = oldMax - oldMin;
    CGFloat newRange    = newMax - newMin;
    CGFloat newVal        = (((oldValue - oldMin) * newRange) / realRange) + newMin;
    return newVal;

}


CGFloat RemappedValueInRangeDefinedByOldMinAndMaxToNewMinAndMax(CGFloat oldValue, CGFloat oldMin,CGFloat oldMax, CGFloat newMin, CGFloat newMax)
{
    CGFloat realRange    = oldMax - oldMin;
    CGFloat newRange    = newMax - newMin;
    CGFloat newVal        = (((oldValue - oldMin) * newRange) / realRange) + newMin;
    return newVal;
    
}




























