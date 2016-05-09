//
//  BezierUtilities.h
//
//
//  Created by Justin Madewell on 5/7/15.
//  Copyright (c) 2015 Justin Madewell. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseGeometry.h"
@import UIKit;


CGRect PathBoundingBox(UIBezierPath *path);
CGRect PathBoundingBoxWithLineWidth(UIBezierPath *path);
CGRect RectFromShapeLayer(CAShapeLayer *shapeLayer);
CGPoint PathBoundingCenter(UIBezierPath *path);
CGPoint PathCenter(UIBezierPath *path);

// Transformations
void ApplyCenteredPathTransform(UIBezierPath *path, CGAffineTransform transform);
UIBezierPath *PathByApplyingTransform(UIBezierPath *path, CGAffineTransform transform);

// Utility
void RotatePath(UIBezierPath *path, CGFloat theta);
void ScalePath(UIBezierPath *path, CGFloat sx, CGFloat sy);
void OffsetPath(UIBezierPath *path, CGSize offset);
void MovePathToPoint(UIBezierPath *path, CGPoint point);
void MovePathCenterToPoint(UIBezierPath *path, CGPoint point);
void MirrorPathHorizontally(UIBezierPath *path);
void MirrorPathVertically(UIBezierPath *path);

// Fitting
void FitPathToRect(UIBezierPath *path, CGRect rect);
void AdjustPathToRect(UIBezierPath *path, CGRect destRect);

NSArray *PointsFromPath(UIBezierPath *path);
NSArray* AngleForLinesToMakeShapeOfPoints(CGFloat points,CGFloat size);

UIBezierPath* MakeRandomPolygonWithPointsOfSize(CGFloat points,CGSize size);

NSArray* PointsForLinesToMakeShapeOfPoints(CGFloat points,CGFloat size);
NSArray* PointsPlottedAroundCenter(CGFloat numberOfPoints,CGFloat size);
NSArray* BundleOfShapeOfPointsInRect(CGFloat points,CGRect rect);

UIBezierPath *BezierStarShape(NSUInteger numberOfInflections, CGFloat percentInflection);
UIBezierPath* PathOfPolygonPoints(CGFloat points,CGFloat size);
UIBezierPath* ShapeOfPointsInRect(CGFloat points,CGRect rect);

UIBezierPath* MakePathFromPoints(NSArray *points);
UIBezierPath* MakePathOfCirclesAroundPoints(NSArray *points,CGFloat radius);
UIBezierPath* MakeRangePathFromAngles(CGFloat startAngle, CGFloat endAngle,CGFloat radius);

UIBezierPath* PathOfGear(CGFloat teeth,CGFloat radius);
UIBezierPath* PathOfGearRounded(CGFloat teethCount,CGFloat teethHeight,CGFloat gearRadius,BOOL cutIsWedgeShaped);
UIBezierPath* PathMakeGear(CGRect pathRect,CGFloat teethCount,CGFloat teethHeight,BOOL wedgeCut);
UIBezierPath* PathSmile();

UIBezierPath* PathMakeLineShape(CGFloat thickness, CGFloat length, CGFloat angle);
NSArray* PointsForRectOfSizeWithRotation(CGRect workingRect, CGFloat rotation);

CALayer* LayerMakeHudLayer(CGFloat inset);

NSArray* Gradients();

CAGradientLayer* GradientLayer();
#pragma mark -  Device Color Helper
UIColor* ColorGetDeviceColor();

#pragma mark - Image Helpers
UIImage* ImageGetImageOfColorAndSize(UIColor *color, CGSize size);
UIImage* ImageGetTransparentImage();



UIBezierPath *PathOfSizeForShapeWithPointCountAtPosition(CGFloat radius, CGFloat pointCount, CGPoint position);

UIColor *textColorForColor(UIColor *backingColor);

