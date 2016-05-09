//
//  JDMColorControlObject.h
//  CIFilter
//
//  Created by Justin Madewell on 11/22/15.
//  Copyright © 2015 Justin Madewell. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JDMUtility.h"
@import UIKit;


@class JDMColorControlObject;
@protocol JDMColorControlObjectDelegate <NSObject>

@optional
-(void)didChangeColor:(CIColor*)color forKeyValue:(NSString*)keyValue;
@end



@interface JDMColorControlObject : NSObject

@property (nonatomic, assign) id<JDMColorControlObjectDelegate> delegate;

@property (nonatomic, strong) UIColor *color;
@property (nonatomic, strong) CIColor *ciColor;
@property (nonatomic, strong) NSString *keyValue;
@property CGFloat positionY;


-(id)initWithDelegate:(id<JDMColorControlObjectDelegate>)delegate inView:(UIView*)view withDefaultRed:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue andAlpha:(CGFloat)alpha withTitle:(NSString*)title description:(NSString*)description andKeyValue:(NSString*)keyValue;

-(void)updateButtonPosition:(CGFloat)buttonY;

-(void)cleanUpAndRemove;

@end
