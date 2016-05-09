//
//  JDMCIControllerObject.h
//  CIFilter
//
//  Created by Justin Madewell on 11/15/15.
//  Copyright © 2015 Justin Madewell. All rights reserved.
//

#import <Foundation/Foundation.h>
@import UIKit;
@import GLKit;

#import "JDMCIController.h"

@class JDMCIControllerObject;

@protocol JDMCIControllerObjectDelegate <NSObject>

@optional
-(void)didUpdateInputParameters:(NSDictionary*)newParameters;
@end






@interface JDMCIControllerObject : NSObject < JDMColorControlObjectDelegate, JDMNumericControlObjectDelegate, JDMCIVectorControlObjectDelegate, JDMBarCodeControlObjectDelegate >

@property (nonatomic, assign) id<JDMCIControllerObjectDelegate> delegate;

@property (nonatomic, strong) NSArray *cellData;
@property (nonatomic, strong) NSArray *cellSections;
@property (nonatomic, strong) NSArray *cellSectionTitles;



//@property (nonatomic, strong) NSArray *tableViewData;

@property (nonatomic, strong) NSDictionary *tableViewData;



@property (nonatomic, strong) UIView *controllerView;
@property (nonatomic, strong) NSString *filterName;
@property (nonatomic, strong) NSString *filterDisplayName;

@property (nonatomic, strong) NSDictionary *inputParamaters;

@property BOOL shouldKeepEditedImage;
@property BOOL isEditingOnImageView;

-(void)reset;

-(void)loadView:(UIView *)view editingView:(GLKView*)editingView withControlsForFilter:(NSString*)filterDisplayName withImage:(UIImage*)image;
-(id)initWithDelegate:(id<JDMCIControllerObjectDelegate>)delegate;

-(NSArray*)makeSectionIndexArray;

-(UIImage*)getEditedImage;

@end
