//
//  JDMBarCodeControlObject.h
//  CIFilter
//
//  Created by Justin Madewell on 12/7/15.
//  Copyright © 2015 Justin Madewell. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JDMCIController.h"
@import UIKit;

@class JDMBarCodeControlObject;

@protocol JDMBarCodeControlObjectDelegate <NSObject>

@optional
-(void)didChangeBarCodeValueTo:(NSData*)value forKeyValue:(NSString*)keyValue;
-(void)didChangeBarCorrectionLevelTo:(NSString *)value forKeyValue:(NSString *)keyValue;
@end



@interface JDMBarCodeControlObject : NSObject < UITextViewDelegate >

@property (nonatomic, assign) id<JDMBarCodeControlObjectDelegate> delegate;

-(id)initWithDelegate:(id<JDMBarCodeControlObjectDelegate>)delegate inView:(UIView*)view withInputParams:(NSDictionary*)inputParams withFilterName:(NSString *)filterName;


@end
