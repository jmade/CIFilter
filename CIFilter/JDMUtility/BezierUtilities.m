//
//  BezierUtilities.m
// 
//
//  Created by Justin Madewell on 5/7/15.
//  Copyright (c) 2015 Justin Madewell. All rights reserved.
//

#import "BezierUtilities.h"


#pragma mark - Bounds
CGRect PathBoundingBox(UIBezierPath *path)
{
    return CGPathGetPathBoundingBox(path.CGPath);
}

CGRect PathBoundingBoxWithLineWidth(UIBezierPath *path)
{
    CGRect bounds = PathBoundingBox(path);
    return CGRectInset(bounds, -path.lineWidth / 2.0f, -path.lineWidth / 2.0f);
}

CGPoint PathBoundingCenter(UIBezierPath *path)
{
    return RectGetCenter(PathBoundingBox(path));
}

CGPoint PathCenter(UIBezierPath *path)
{
    return RectGetCenter(path.bounds);
}

CGRect RectFromShapeLayer(CAShapeLayer *shapeLayer)
{
    return PathBoundingBox([UIBezierPath bezierPathWithCGPath:shapeLayer.path]);
}

#pragma mark - Transform
void ApplyCenteredPathTransform(UIBezierPath *path, CGAffineTransform transform)
{
    CGPoint center = PathBoundingCenter(path);
    CGAffineTransform t = CGAffineTransformIdentity;
    t = CGAffineTransformTranslate(t, center.x, center.y);
    t = CGAffineTransformConcat(transform, t);
    t = CGAffineTransformTranslate(t, -center.x, -center.y);
    [path applyTransform:t];
}

UIBezierPath *PathByApplyingTransform(UIBezierPath *path, CGAffineTransform transform)
{
    UIBezierPath *copy = [path copy];
    ApplyCenteredPathTransform(copy, transform);
    return copy;
}

void RotatePath(UIBezierPath *path, CGFloat theta)
{
    CGAffineTransform t = CGAffineTransformMakeRotation(theta);
    ApplyCenteredPathTransform(path, t);
}

void ScalePath(UIBezierPath *path, CGFloat sx, CGFloat sy)
{
    CGAffineTransform t = CGAffineTransformMakeScale(sx, sy);
    ApplyCenteredPathTransform(path, t);
}

void OffsetPath(UIBezierPath *path, CGSize offset)
{
    CGAffineTransform t = CGAffineTransformMakeTranslation(offset.width, offset.height);
    ApplyCenteredPathTransform(path, t);
}

void MovePathToPoint(UIBezierPath *path, CGPoint destPoint)
{
    CGRect bounds = PathBoundingBox(path);
    CGPoint p1 = bounds.origin;
    CGPoint p2 = destPoint;
    CGSize vector = CGSizeMake(p2.x - p1.x, p2.y - p1.y);
    OffsetPath(path, vector);
}

void MovePathCenterToPoint(UIBezierPath *path, CGPoint destPoint)
{
    CGRect bounds = PathBoundingBox(path);
    CGPoint p1 = bounds.origin;
    CGPoint p2 = destPoint;
    CGSize vector = CGSizeMake(p2.x - p1.x, p2.y - p1.y);
    vector.width -= bounds.size.width / 2.0f;
    vector.height -= bounds.size.height / 2.0f;
    OffsetPath(path, vector);
}

void MirrorPathHorizontally(UIBezierPath *path)
{
    CGAffineTransform t = CGAffineTransformMakeScale(-1, 1);
    ApplyCenteredPathTransform(path, t);
}

void MirrorPathVertically(UIBezierPath *path)
{
    CGAffineTransform t = CGAffineTransformMakeScale(1, -1);
    ApplyCenteredPathTransform(path, t);
}

void FitPathToRect(UIBezierPath *path, CGRect destRect)
{
    CGRect bounds = PathBoundingBox(path);
    CGRect fitRect = RectByFittingRect(bounds, destRect);
    CGFloat scale = AspectScaleFit(bounds.size, destRect);
    
    CGPoint newCenter = RectGetCenter(fitRect);
    MovePathCenterToPoint(path, newCenter);
    ScalePath(path, scale, scale);
}

void AdjustPathToRect(UIBezierPath *path, CGRect destRect)
{
    CGRect bounds = PathBoundingBox(path);
    CGFloat scaleX = destRect.size.width / bounds.size.width;
    CGFloat scaleY = destRect.size.height / bounds.size.height;
    
    CGPoint newCenter = RectGetCenter(destRect);
    MovePathCenterToPoint(path, newCenter);
    ScalePath(path, scaleX, scaleY);
}

//TODO: Make another function that makes gears instead of circles



UIBezierPath* MakeRangePathFromTimeAngles(CGFloat startAngle, CGFloat endAngle,CGFloat radius)
{
    // Range
    UIBezierPath *path = [UIBezierPath bezierPath];
    
    CGSize size = CGSizeMake(radius, radius);
    
    CGPoint center = CGPointMake(size.width/2, size.height/2);

    CGFloat sx = center.x + radius * cos(startAngle);
    CGFloat sy = center.y + radius * sin(startAngle);
    
    CGFloat ex = center.x + radius * cos(endAngle);
    CGFloat ey = center.y + radius * sin(endAngle);
    
    CGPoint startPoint = CGPointMake(sx, sy);
    CGPoint endPoint = CGPointMake(ex, ey);
    
    [path moveToPoint:center];
    [path addLineToPoint:startPoint];
    
    [path addArcWithCenter:center radius:radius startAngle:startAngle endAngle:endAngle clockwise:NO];
    [path addLineToPoint:center];
    
//    [path moveToPoint:center];
//    [path addLineToPoint:endPoint];
    
    return path;
}



UIBezierPath* MakePathOfCirclesAroundPoints(NSArray *points,CGFloat radius)
{
    UIBezierPath *dotsPath = [UIBezierPath bezierPath];
    
    for (int i=0; i<points.count; i++) {
        CGPoint point = [[points objectAtIndex:i] CGPointValue];
        CGPoint moveToPoint = CGPointMake(point.x + radius, point.y);
        
        [dotsPath moveToPoint:moveToPoint];
        [dotsPath addArcWithCenter:point radius:radius startAngle:RadiansFromDegrees(0) endAngle:RadiansFromDegrees(360) clockwise:YES];
    }
    
    return dotsPath;
    
}


UIBezierPath* MakePathFromPoints(NSArray *points)
{
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:[[points firstObject] CGPointValue]];
    
    for (int i=1; i<points.count; i++) {
        [path addLineToPoint:[[points objectAtIndex:i] CGPointValue]];
    }
    
    return path;
    
}

// Make Gear---
UIBezierPath* PathMakeGear(CGRect pathRect,CGFloat teethCount,CGFloat teethHeight,BOOL wedgeCut)
{
    UIBezierPath *path = [UIBezierPath bezierPath];
    
    CGFloat smallerBounds = pathRect.size.width;
    if (pathRect.size.width > pathRect.size.height) {
        smallerBounds = pathRect.size.height;
    }
    
    
    //TODO: Integrate matching gears to paths by rotating-->
    //// CGFloat gearRotationDegrees = ( 360 / teethCount);
    
    
    CGFloat gearRadius = (smallerBounds * 0.90)/2;
    
    CGPoint center = RectGetCenter(pathRect);
    
    CGFloat rad = gearRadius;
    CGFloat cut = (gearRadius * (1 - teethHeight));
    
    CGFloat outerRadius = rad;
    CGFloat innerRadius = cut;
    
    CGFloat points = teethCount * 4;
    
    CGFloat step = 2 * M_PI / points;
    
    int checker = 0 ;
    
    // start it.
    [path moveToPoint:CGPointMake(center.x + rad * cos(step * 0 - M_PI_2), center.y + rad * sin(step * 0 - M_PI_2))];
    
    for (int i=0; i<points; i++)
    {
        CGFloat angle = step * i - M_PI_2;
        CGFloat nextAngle = step * (i+1) - M_PI_2;
        
        CGPoint outerCirclePoint = CGPointMake(center.x + rad * cos(step * i - M_PI_2), center.y + rad * sin(step * i - M_PI_2));
        CGPoint innerCirclePoint = CGPointMake(center.x + cut * cos(step * i - M_PI_2), center.y + cut * sin(step * i - M_PI_2));
        
        CGPoint nextOuterCirclePoint = CGPointMake(center.x + rad * cos(step * (i+1) - M_PI_2), center.y + rad * sin(step * (i+1) - M_PI_2));
        CGPoint nextInnerCirclePoint = CGPointMake(center.x + cut * cos(step * (i+1) - M_PI_2), center.y + cut * sin(step * (i+1) - M_PI_2));
        
        //Reset the Checker
        if (checker>3) {checker = 0;}
        
        // checker Switch
        switch (checker) {
            case 0:
                // Add Outer Arc
                [path addArcWithCenter:center radius:outerRadius startAngle:angle endAngle:nextAngle clockwise:YES];
                break;
            case 1:
                // Add to Line (in)
                if (wedgeCut) {
                    [path addLineToPoint:nextInnerCirclePoint];
                }
                else
                {
                    [path addLineToPoint:innerCirclePoint];
                }
                break;
            case 2:
                // Add Inner Arc
                [path addArcWithCenter:center radius:innerRadius startAngle:angle endAngle:nextAngle clockwise:YES];
                break;
            case 3:
                // Add to Line (Outer)
                if (wedgeCut) {
                    [path addLineToPoint:nextOuterCirclePoint];
                }
                else
                {
                    [path addLineToPoint:outerCirclePoint];
                }
                break;
                
            default:
                break;
        }
        checker++;
    }
    
    [path closePath];
    
    UIBezierPath *gearCircle = [UIBezierPath bezierPathWithOvalInRect:RectAroundCenter(center, CGSizeMake(gearRadius/4, gearRadius/4))];
    
    
    [path appendPath:gearCircle];
    
    path.lineWidth = 1.0;
    
    
    return path;
}


UIBezierPath* PathSmile()
{
    UIBezierPath *smilePath;
    
    CGFloat sizeAmt = 10;
    CGSize size = CGSizeMake(sizeAmt, sizeAmt);
    CGFloat points = 12;
    
    // between 4 & 8 ;
    CGPoint center = CGPointMake(size.width/2, size.height/2);
    CGFloat rad = sizeAmt;
    
    
    
    CGFloat step = 2 * M_PI / points;
    
    for (int i=0; i<points; i++) {
        
        CGFloat angleAsRad = step * i - M_PI_2;
        
        CGFloat angle = DegreesFromRadians(angleAsRad);
        
        CGPoint point = CGPointMake(center.x + rad * cos(step * i - M_PI_2), center.y + rad * sin(step * i - M_PI_2));
        
        
        
        if (i == 0) {
            [smilePath moveToPoint:point];
        }
        else
        {
            [smilePath addLineToPoint:point];
        }
        
        
        NSLog(@"Angle:%.02f for %i",angle,i);
        
        
        
    }
   
    [smilePath closePath];
    
    smilePath.lineWidth = 1.0;

    
    
    return smilePath;
}





UIBezierPath* PathOfGearRounded(CGFloat teethCount,CGFloat teethHeight,CGFloat gearRadius,BOOL cutIsWedgeShaped)
{
    UIBezierPath *path = [UIBezierPath bezierPath];
    
    CGSize size = CGSizeMake(gearRadius, gearRadius);
    
    CGPoint center = CGPointMake(size.width/2, size.height/2);
    
    CGFloat rad = gearRadius;
    CGFloat cut = (gearRadius * (1 - teethHeight));
    
    CGFloat outerRadius = rad;
    CGFloat innerRadius = cut;
    
    CGFloat points = teethCount * 4;
    
    CGFloat step = 2 * M_PI / points;
    
    int checker = 0 ;
    
    // start it.
    [path moveToPoint:CGPointMake(center.x + rad * cos(step * 0 - M_PI_2), center.y + rad * sin(step * 0 - M_PI_2))];
    
    for (int i=0; i<points; i++)
    {
        CGFloat angle = step * i - M_PI_2;
        CGFloat nextAngle = step * (i+1) - M_PI_2;
        
        CGPoint outerCirclePoint = CGPointMake(center.x + rad * cos(step * i - M_PI_2), center.y + rad * sin(step * i - M_PI_2));
        CGPoint innerCirclePoint = CGPointMake(center.x + cut * cos(step * i - M_PI_2), center.y + cut * sin(step * i - M_PI_2));
        
        CGPoint nextOuterCirclePoint = CGPointMake(center.x + rad * cos(step * (i+1) - M_PI_2), center.y + rad * sin(step * (i+1) - M_PI_2));
        CGPoint nextInnerCirclePoint = CGPointMake(center.x + cut * cos(step * (i+1) - M_PI_2), center.y + cut * sin(step * (i+1) - M_PI_2));
        
        //Reset the Checker
        if (checker>3) {checker = 0;}
        
        // checker Switch
        switch (checker) {
            case 0:
                // Add Outer Arc
                [path addArcWithCenter:center radius:outerRadius startAngle:angle endAngle:nextAngle clockwise:YES];
                break;
            case 1:
                // Add to Line (in)
                if (cutIsWedgeShaped) {
                    [path addLineToPoint:nextInnerCirclePoint];
                }
                else
                {
                    [path addLineToPoint:innerCirclePoint];
                }
                break;
            case 2:
                // Add Inner Arc
                [path addArcWithCenter:center radius:innerRadius startAngle:angle endAngle:nextAngle clockwise:YES];
                break;
            case 3:
                // Add to Line (Outer)
                if (cutIsWedgeShaped) {
                    [path addLineToPoint:nextOuterCirclePoint];
                }
                else
                {
                    [path addLineToPoint:outerCirclePoint];
                }
                break;
                
            default:
                break;
        }
        checker++;
    }
    
    [path closePath];
    
    path.lineWidth = 1.0;
   
    
    return path;
}



UIBezierPath* PathOfGear(CGFloat teeth,CGFloat radius)
{
    
    
    UIBezierPath *randomPolyPath = [UIBezierPath bezierPath];
    
    CGSize size = CGSizeMake(radius, radius);
    
    CGPoint center = CGPointMake(size.width/2, size.height/2);
    CGFloat rad = radius;
    CGFloat cut = (radius * 0.80);
    
    CGFloat points = teeth * 4;
    
    CGFloat step = 2 * M_PI / points;

    // new loop logic
    
    CGPoint nextPoint;
    CGPoint lastInnerPoint;
    CGPoint lastOuterPoint;
    
    int checker = 0 ;
    
    // start it.
    [randomPolyPath moveToPoint:CGPointMake(center.x + rad * cos(step * 0 - M_PI_2), center.y + rad * sin(step * 0 - M_PI_2))];
    
    for (int i=0; i<points; i++) {
        
        CGPoint outerCirclePoint = CGPointMake(center.x + rad * cos(step * i - M_PI_2), center.y + rad * sin(step * i - M_PI_2));
        CGPoint innerCirclePoint = CGPointMake(center.x + cut * cos(step * i - M_PI_2), center.y + cut * sin(step * i - M_PI_2));
        
        //Reset the Checker
        if (checker>3) {checker = 0;}
        
        // checker Switch
        switch (checker) {
            case 0:
                // Outer to Outer
                // next point -> Outer
                nextPoint = outerCirclePoint;
                break;
            case 1:
                // Outer to Inner
                // next point -> Inner
                 // need to refernce the same point
                nextPoint = lastInnerPoint;
                break;
            case 2:
                // Inner to Inner
                // next point -> Inner
                // nextPoint = innerCirclePoint;
                nextPoint = innerCirclePoint;
                break;
            case 3:
                // Inner to Outer
                // next point -> Outer
                // need to refernce the same point
                nextPoint = lastOuterPoint;
                break;
                
            default:
                break;
        }
         checker++;
       
        lastOuterPoint = outerCirclePoint;
        lastInnerPoint = innerCirclePoint;
        
        [randomPolyPath addLineToPoint:nextPoint];
    }
    
    [randomPolyPath closePath];
    
    randomPolyPath.lineWidth = 1.0;
    
    return randomPolyPath;

}

NSArray* AngleForLinesToMakeShapeOfPoints(CGFloat points,CGFloat size)
{
    CGFloat radius = size;
    
    CGSize circleSize = CGSizeMake(radius, radius);
    
    CGPoint center = CGPointMake(circleSize.width/2, circleSize.height/2);
    CGFloat rad = radius;
    
    CGFloat step = 2 * M_PI / points;
    
    NSMutableArray *angles = [[NSMutableArray alloc]init];
    
    for (int i=0; i < points; i++)
    {
        CGFloat angle = step * i - M_PI_2;
        
        [angles addObject:@(angle)];
        
    }
    
    return angles;

}


NSArray* PointsForLinesToMakeShapeOfPoints(CGFloat points,CGFloat size)
{
    CGFloat radius = size;
    
    CGSize circleSize = CGSizeMake(radius, radius);
    
    CGPoint center = CGPointMake(circleSize.width/2, circleSize.height/2);
    CGFloat rad = radius;
    
    CGFloat step = 2 * M_PI / points;
    
    NSMutableArray *newPoints = [[NSMutableArray alloc]init];
    
    for (int i=0; i < points; i++)
    {
        CGFloat angle = step * i - M_PI_2;
        
        CGFloat x = center.x + rad * cos(angle);
        CGFloat y = center.y + rad * sin(angle);
        
        CGPoint point = CGPointMake(x, y);
        
    [newPoints addObject:[NSValue valueWithCGPoint:point]];
    }
    
    return newPoints;

}

NSArray* PointsPlottedAroundCenter(CGFloat numberOfPoints,CGFloat size)
{
    CGFloat radius = size/2;
    
    CGPoint center = CGPointMake(radius*2, radius*2);
    
    CGFloat step = TWO_PI / numberOfPoints;
    
    NSMutableArray *newPoints = [[NSMutableArray alloc]init];
    
    for (int i=0; i < numberOfPoints; i++)
    {
        CGFloat angle = step * i - M_PI_2;
        
        CGFloat x = center.x + radius * cos(angle);
        CGFloat y = center.y + radius * sin(angle);
        
        CGPoint point = CGPointMake(x, y);
        
        [newPoints addObject:[NSValue valueWithCGPoint:point]];
    }
    
    return newPoints;

}

NSArray* PointsForShapeOfPoints(CGFloat points,CGFloat size,CGPoint center)
{
    
    
    //CGSize circleSize = CGSizeMake(radius, radius);
    
    //CGPoint center = CGPointMake(circleSize.width/2, circleSize.height/2);
    
    
    //CGFloat rad = radius;
    
    CGFloat radius = size*0.50;
    
    //CGSize circleSize = CGSizeMake(radius, radius);
    
    //CGPoint center = RectGetCenter(rect);
    CGFloat rad = radius;

    
    CGFloat step = 2 * M_PI / points;
    
    NSMutableArray *newPoints = [[NSMutableArray alloc]init];
    
    for (int i=0; i < points; i++)
    {
        CGFloat angle = step * i - M_PI_2;
        
        CGFloat x = center.x + rad * cos(angle);
        CGFloat y = center.y + rad * sin(angle);
        
        CGPoint point = CGPointMake(x, y);
        
        [newPoints addObject:[NSValue valueWithCGPoint:point]];
    }
    
    return newPoints;
    
}


UIBezierPath *BezierStarShape(NSUInteger numberOfInflections, CGFloat percentInflection)
{
    if (numberOfInflections < 3)
    {
        NSLog(@"Error: Please supply at least 3 inflections") ;
        return nil;
    }
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    CGRect destinationRect = CGRectMake(0, 0, 1, 1) ;
    CGPoint center = RectGetCenter(destinationRect) ;
    CGFloat r = 0.5;
    CGFloat rr = r * (1.0 + percentInflection) ;
    
    BOOL firstPoint = YES;
    for (int i = 0; i < numberOfInflections; i++)
    {
        CGFloat theta = i * TWO_PI / numberOfInflections;
        CGFloat dTheta = TWO_PI / numberOfInflections;
        
        if (firstPoint)
        {
            CGFloat xa = center. x + r * sin(theta) ;
            CGFloat ya = center. y + r * cos(theta) ;
            CGPoint pa = CGPointMake(xa, ya) ;
            [path moveToPoint: pa];
            firstPoint = NO;
        }
        
        CGFloat cp1x = center. x + rr *
        sin(theta + dTheta / 2) ;
        CGFloat cp1y = center. y + rr *
        cos(theta + dTheta / 2) ;
        CGPoint cp1 = CGPointMake(cp1x, cp1y) ;
        
        CGFloat xb = center. x + r * sin(theta + dTheta) ;
        CGFloat yb = center. y + r * cos(theta + dTheta) ;
        CGPoint pb = CGPointMake(xb, yb) ;
        
        [path addLineToPoint: cp1];
        [path addLineToPoint: pb];
    }
    
    [path closePath];
    return path;
}





UIBezierPath* PathOfPolygonPoints(CGFloat points,CGFloat size)
{
    UIBezierPath *randomPolyPath = [UIBezierPath bezierPath];
    
    CGFloat radius = size;
    
    CGSize circleSize = CGSizeMake(radius, radius);
    
    CGPoint center = CGPointMake(circleSize.width/2, circleSize.height/2);
    CGFloat rad = radius;
    
    CGFloat step = 2 * M_PI / points;
    
    for (int i=0; i < points; i++)
    {
        CGFloat angle = step * i - M_PI_2;
        
        CGFloat x = center.x + rad * cos(angle);
        CGFloat y = center.y + rad * sin(angle);
        
        CGPoint point = CGPointMake(x, y);
        
        NSLog(@"point : %@",NSStringFromCGPoint(point));

        
        if (i == 0)
        {
            [randomPolyPath moveToPoint:point];
        }
        else
        {
            [randomPolyPath addLineToPoint:point];
            
        }
    }
    
    [randomPolyPath closePath];
    
    randomPolyPath.lineWidth = 1.0;
    
    return randomPolyPath;
}

UIBezierPath* ShapeOfPointsInRect(CGFloat points,CGRect rect)
{
    UIBezierPath *randomPolyPath = [UIBezierPath bezierPath];
    
    CGFloat radius = rect.size.width/4;
    
    //CGSize circleSize = CGSizeMake(radius, radius);
    
    CGPoint center = RectGetCenter(rect);
    CGFloat rad = radius;
    
    CGFloat step = 2 * M_PI / points;
    
    for (int i=0; i < points; i++)
    {
        CGFloat angle = step * -i - M_PI_2;
//        
//        if (i == 0) {
//            angle = 0;
//        }
        
        
        CGFloat x = center.x + rad * cos(angle);
        CGFloat y = center.y + rad * sin(angle);
        
        CGPoint point = CGPointMake(x, y);
        
        // NSLog(@"point : %@",NSStringFromCGPoint(point));
        
        
        if (i == 0)
        {
            [randomPolyPath moveToPoint:point];
        }
        else
        {
            [randomPolyPath addLineToPoint:point];
            
        }
    }
    
    [randomPolyPath closePath];
    
    randomPolyPath.lineWidth = 1.0;
    
    return randomPolyPath;
}


NSArray* BundleOfShapeOfPointsInRect(CGFloat points,CGRect rect)
{
    UIBezierPath *randomPolyPath = [UIBezierPath bezierPath];
    
    NSMutableArray *pointsForLines = [[NSMutableArray alloc]init];
    NSMutableArray *anglesArray = [[NSMutableArray alloc]init];
    
    CGFloat radius = rect.size.width/4;
    NSLog(@"Bundle_radius: %f",radius);
    
    
    //CGSize circleSize = CGSizeMake(radius, radius);
    
    CGPoint center = RectGetCenter(rect);
    NSLog(@"Bundle_center : %@",NSStringFromCGPoint(center));
    
    CGFloat rad = radius;
    NSLog(@"Bundle_rad: %f",rad);
    
    
    CGFloat twoPi = 2 * M_PI;
    NSLog(@"twoPi: %f",twoPi);
    NSLog(@"TWO_PI: %f",TWO_PI);
    
    
    
    
    CGFloat step = 2 * M_PI / points;
    
    for (int i=0; i < points; i++)
    {
        CGFloat angle = step * i - M_PI_2;
        
        [anglesArray addObject:[NSNumber numberWithFloat:DegreesFromRadians(angle)]];
        
        CGFloat x = center.x + rad * cos(angle);
        CGFloat y = center.y + rad * sin(angle);
        
        CGPoint point = CGPointMake(x, y);
        [pointsForLines addObject:[NSValue valueWithCGPoint:point]];
        
        // NSLog(@"point : %@",NSStringFromCGPoint(point));
        
        
        if (i == 0)
        {
            [randomPolyPath moveToPoint:point];
        }
        else
        {
            [randomPolyPath addLineToPoint:point];
            
        }
    }
    
    [randomPolyPath closePath];
    
    randomPolyPath.lineWidth = 1.0;
    
    return @[
             randomPolyPath,
             pointsForLines,
             anglesArray,
             ];
}

NSArray* PointsForRectOfSizeWithRotation(CGRect workingRect, CGFloat rotation)
{
    // CGRect workingRect = CGRectMake(0, 0, size, size);
    CGFloat rotationAmount = rotation;
    
    CGFloat distance = workingRect.size.width;
    
    CGPoint center = RectGetCenter(workingRect);
    
    CGRect plotRect = RectAroundCenter(center, CGSizeMake(distance, distance));
    CGPoint centerPoint = RectGetCenter(plotRect);
    
    CGPoint tl = RectGetTopLeft(plotRect);
    CGPoint tr = RectGetTopRight(plotRect);
    CGPoint bl = RectGetBottomLeft(plotRect);
    CGPoint br = RectGetBottomRight(plotRect);
    
    CGPoint calculatedTopRightPoint = PointCalculateRotatedTopRightPoint(centerPoint, distance, rotationAmount, YES);
    CGPoint base = tr;
    CGPoint baseDiff = PointSubtractPoint(base,calculatedTopRightPoint);
    
    CGPoint offsetPoint = CGPointMake(fabs(baseDiff.x), fabs(baseDiff.y));
    CGPoint rotationDiff = offsetPoint;
    
    if (rotationAmount < 0 ) {
        rotationDiff = CGPointMake(offsetPoint.x*-1, offsetPoint.y*-1);
    }
    
    //NSLog(@"X:%.2f,Y:%.2f",rotationDiff.x,rotationDiff.y);
    
    CGPoint calulatedTopLeftPoint = CGPointMake(tl.x + rotationDiff.y , tl.y - rotationDiff.x );
    
    // point is moving toward the bottom (+) Y and (-) X
    CGPoint calulatedBottomRightPoint = CGPointMake(br.x - rotationDiff.y , br.y + rotationDiff.x );
    
    // point is moving (-) toward 0 on the X and up (-) toward 0 on the Y
    CGPoint calulatedBottomLeftPoint = CGPointMake(bl.x - rotationDiff.x , bl.y - rotationDiff.y );
    
    return @[
             [NSValue valueWithCGPoint:calulatedTopLeftPoint],
             [NSValue valueWithCGPoint:calculatedTopRightPoint],
             [NSValue valueWithCGPoint:calulatedBottomRightPoint],
             [NSValue valueWithCGPoint:calulatedBottomLeftPoint],
             ];
}





UIBezierPath* MakeRandomPolygonWithPointsOfSize(CGFloat points,CGSize size)
{
    UIBezierPath *randomPolyPath = [UIBezierPath bezierPath];
    
    CGPoint center = CGPointMake(size.width/2, size.height/2);
    CGFloat rad = size.width;
    
    CGFloat step = 2 * M_PI / points;
    
    for (int i=0; i < points; i++)
    {
        CGFloat angle = step * i - M_PI_2;
        
        CGFloat x = center.x + rad * cos(angle);
        CGFloat y = center.y + rad * sin(angle);
        
        CGPoint point = CGPointMake(x, y);
        
        if (i == 0)
        {
            [randomPolyPath moveToPoint:point];
        }
        else
        {
            [randomPolyPath addLineToPoint:point];
            
        }
        
        
    }
    
    [randomPolyPath closePath];
    
    randomPolyPath.lineWidth = 1.0;
   
    return randomPolyPath;
}

UIBezierPath *PathOfSizeForShapeWithPointCountAtPosition(CGFloat radius, CGFloat pointCount, CGPoint position)
{
    UIBezierPath *randomPolyPath = [UIBezierPath bezierPath];
    
    CGPoint center = position;
    CGFloat rad = radius;
    
    CGFloat step = 2 * M_PI / pointCount;
    
    for (int i=0; i < pointCount; i++)
    {
        CGFloat angle = step * i - M_PI_2;
        
        CGFloat x = center.x + rad * cos(angle);
        CGFloat y = center.y + rad * sin(angle);
        
        CGPoint point = CGPointMake(x, y);
        
        if (i == 0)
        {
            [randomPolyPath moveToPoint:point];
        }
        else
        {
            [randomPolyPath addLineToPoint:point];
            
        }
    }
    
    [randomPolyPath closePath];
    
    randomPolyPath.lineWidth = 1.0;
    
    return randomPolyPath;
}


#pragma mark - Get Points From uibezier path


NSArray *PointsFromPath(UIBezierPath *path)
{
    NSMutableArray *bezierPoints = [NSMutableArray array];
    void MyCGPathApplierFunc(void *info, const CGPathElement *element);
    CGPathApply(path.CGPath, (__bridge void *)(bezierPoints), MyCGPathApplierFunc);
    return bezierPoints;
}



void MyCGPathApplierFunc(void *info, const CGPathElement *element)
{
    
    NSMutableArray *bezierPoints = (__bridge NSMutableArray *)info;
    
    CGPoint *points = element->points;
    CGPathElementType type = element->type;
    
    switch(type) {
        case kCGPathElementMoveToPoint: // contains 1 point
            [bezierPoints addObject:[NSValue valueWithCGPoint:points[0]]];
            break;
            
        case kCGPathElementAddLineToPoint: // contains 1 point
            [bezierPoints addObject:[NSValue valueWithCGPoint:points[0]]];
            break;
            
        case kCGPathElementAddQuadCurveToPoint: // contains 2 points
            [bezierPoints addObject:[NSValue valueWithCGPoint:points[0]]];
            [bezierPoints addObject:[NSValue valueWithCGPoint:points[1]]];
            break;
            
        case kCGPathElementAddCurveToPoint: // contains 3 points
            [bezierPoints addObject:[NSValue valueWithCGPoint:points[0]]];
            [bezierPoints addObject:[NSValue valueWithCGPoint:points[1]]];
            [bezierPoints addObject:[NSValue valueWithCGPoint:points[2]]];
            break;
            
        case kCGPathElementCloseSubpath: // contains no point
            break;
    }
}


// Still working on...
UIBezierPath* PathForChamferProfile()
{
    UIBezierPath *path = [UIBezierPath bezierPath];
    
    CGPoint startPoint = CGPointMake(1, 0);
    CGPoint endPoint = CGPointMake(0, 1);
    
    CGPoint controlPoint1;
    CGPoint controlPoint2;
    
    // bottom slant right now
    controlPoint1 = CGPointMake(1, 0.5);
    controlPoint2 = CGPointMake(0, 0.5);
    
    [path moveToPoint:startPoint];
    
    [path addCurveToPoint:endPoint controlPoint1:controlPoint1 controlPoint2:controlPoint2];
    // for visualizing
    // UIBezierPath *scaledPath = PathByApplyingTransform(path, CGAffineTransformMakeScale(100, 100));
    
    return path;
}




UIBezierPath* PathMakeLineShape(CGFloat thickness, CGFloat length, CGFloat angle)
{
    CGPoint startPoint = CGPointMake(0, 0);
    
    CGPoint endPoint = CGPointMake(length, 0);
    
    CGPoint arcCenter = CGPointMake(length,thickness/2);
    
    CGPoint thirdPoint = CGPointMake(0, thickness);
    
    CGPoint endArcCenter = CGPointMake(0,thickness/2);
    
    UIBezierPath *linePath = [UIBezierPath bezierPath];
    [linePath moveToPoint:startPoint];
    [linePath addLineToPoint:endPoint];
    
    [linePath addArcWithCenter:arcCenter radius:thickness/2 startAngle:RadiansFromDegrees(270) endAngle:RadiansFromDegrees(90) clockwise:YES];
    
    [linePath addLineToPoint:thirdPoint];
    
    [linePath addArcWithCenter:endArcCenter radius:thickness/2 startAngle:RadiansFromDegrees(90) endAngle:RadiansFromDegrees(270) clockwise:YES];
    
    UIBezierPath *rotatedLinePath = PathByApplyingTransform(linePath, CGAffineTransformMakeRotation(RadiansFromDegrees(angle)));
    
    return rotatedLinePath;
    
}


CALayer* LayerMakeHudLayer(CGFloat inset)
{
    CGFloat insetAmount = (inset * ScreenSmaller())/2;
    CGRect layerRect = CGRectInset(MidSquareRect(), insetAmount, insetAmount);
    
    CALayer *hudLayer = [CALayer layer];
    hudLayer.name = @"hudLayer";
    hudLayer.backgroundColor = [UIColor colorWithWhite:0.93 alpha:1.0].CGColor;
    hudLayer.cornerRadius =  layerRect.size.width/8;
    hudLayer.frame = layerRect;
    hudLayer.borderColor = [UIColor blackColor].CGColor;
    hudLayer.borderWidth = 2.0;

    return hudLayer;
}



NSArray* Gradients()
{
    //// General Declarations
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    
    //// Gradient Declarations
    NSArray* gradientColors = [NSArray arrayWithObjects:
                               (id)[UIColor blackColor].CGColor,
                               (id)[UIColor whiteColor].CGColor, nil];
    
    CGFloat gradientLocations[] = {0, 1};
    CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef)gradientColors, gradientLocations);
    
    //// MainRectangle Drawing
    UIBezierPath* mainRectanglePath = [UIBezierPath bezierPathWithRect: CGRectMake(0, 0, 206.5, 736)];
    CGContextSaveGState(context);
    [mainRectanglePath addClip];
    CGContextDrawLinearGradient(context, gradient, CGPointMake(206.5, 368), CGPointMake(-0, 368), 0);
    CGContextRestoreGState(context);
    [[UIColor blackColor] setStroke];
    mainRectanglePath.lineWidth = 1;
    [mainRectanglePath stroke];
    
    
    //// rightSide Drawing
    UIBezierPath* rightSidePath = [UIBezierPath bezierPathWithRect: CGRectMake(206.5, 0, 206.5, 736)];
    CGContextSaveGState(context);
    [rightSidePath addClip];
    CGContextDrawLinearGradient(context, gradient, CGPointMake(206.5, 368), CGPointMake(413, 368), 0);
    CGContextRestoreGState(context);
    [[UIColor blackColor] setStroke];
    rightSidePath.lineWidth = 1;
    [rightSidePath stroke];
    
    
    //// Cleanup
    CGGradientRelease(gradient);
    CGColorSpaceRelease(colorSpace);
    
    
    return @[];

}


CAGradientLayer* GradientLayer()
{
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    
    gradientLayer.startPoint  = CGPointMake(0.0, 1.0);
    gradientLayer.endPoint = CGPointMake(1.0, 1.0);
    
    UIColor *topColor = [UIColor colorWithWhite:0.7 alpha:1.0];
    UIColor *bottomColor = [UIColor blackColor];
    
    NSArray *gradientColors = [NSArray arrayWithObjects:(id)topColor.CGColor, (id)bottomColor.CGColor, (id)topColor.CGColor, nil];
    NSArray *gradientLocations = @[@(0.0),@(0.5),@(1.0)];
    
    gradientLayer.colors = gradientColors;
    gradientLayer.locations = gradientLocations;
    
    return gradientLayer;
    
}



#pragma mark -  Device Color Helper
UIColor* ColorGetDeviceColor()
{
    NSString *deviceColor;
    NSString *deviceEnclosureColor;
    
    UIDevice *device = [UIDevice currentDevice];
    
    SEL selector = NSSelectorFromString(@"deviceInfoForKey:");
    if (![device respondsToSelector:selector]) {
        selector = NSSelectorFromString(@"_deviceInfoForKey:");
    }
    
    if ([device respondsToSelector:selector]) {
        // private API! Do not use in App Store builds!
        deviceColor = [device performSelector:selector withObject:@"DeviceColor"];
        deviceEnclosureColor = [device performSelector:selector withObject:@"DeviceEnclosureColor"];
    } else {
        
    }
    
    
    NSString *noHashString = [deviceEnclosureColor stringByReplacingOccurrencesOfString:@"#" withString:@""]; // remove the #
    NSScanner *scanner = [NSScanner scannerWithString:noHashString];
    [scanner setCharactersToBeSkipped:[NSCharacterSet symbolCharacterSet]]; // remove + and $
    
    unsigned hex;
    if (![scanner scanHexInt:&hex]) return nil;
    int r = (hex >> 16) & 0xFF;
    int g = (hex >> 8) & 0xFF;
    int b = (hex) & 0xFF;
    
    UIColor *color = [UIColor colorWithRed:r / 255.0f green:g / 255.0f blue:b / 255.0f alpha:1.0f];

    return color;
}



#pragma mark - Image Helpers

UIImage* ImageGetTransparentImage()
{
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0,1.0);
    UIColor *color = [UIColor clearColor];
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
    
}


UIImage* ImageGetImageOfColorAndSize(UIColor *color, CGSize size)
{
    CGRect rect = CGRectMake(0.0f, 0.0f, size.width, size.height);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
    
}



UIColor *textColorForColor(UIColor *backingColor)
{
    
    CIColor *color = [CIColor colorWithCGColor:backingColor.CGColor];
    CGFloat sum =  color.red + color.blue + color.green;
    
    UIColor *returnColor = [UIColor blackColor];
    
    if (sum <= 1.5) {
        returnColor = [UIColor whiteColor];
    }
    
    return returnColor;
    
}










