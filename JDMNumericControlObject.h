//
//  JDMNumericControlObject.h
//  CIFilter
//
//  Created by Justin Madewell on 11/22/15.
//  Copyright © 2015 Justin Madewell. All rights reserved.
//

#import <Foundation/Foundation.h>
@import UIKit;


@class JDMNumericControlObject;

@protocol JDMNumericControlObjectDelegate <NSObject>

@optional
-(void)didChangeNumericValueTo:(NSNumber*)newValue forKeyValue:(NSString*)keyValue;
@end


@interface JDMNumericControlObject : NSObject

@property (nonatomic, assign) id<JDMNumericControlObjectDelegate> delegate;
@property (nonatomic, strong) NSString *keyValue;

-(id)initWithDelegate:(id<JDMNumericControlObjectDelegate>)delegate inView:(UIView*)view withTitle:(NSString *)title withMin:(CGFloat)min andMax:(CGFloat)max withDefault:(CGFloat)defaultValue andKeyValue:(NSString*)keyValue;

-(void)updateYPosition:(CGFloat)positionY;


-(void)cleanUpAndRemove;

@end
