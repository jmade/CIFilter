//
//  JDMCIControllerObject.m
//  CIFilter
//
//  Created by Justin Madewell on 11/15/15.
//  Copyright © 2015 Justin Madewell. All rights reserved.
//

#import "JDMCIControllerObject.h"
#import "JDMUtility.h"



static NSString *ATTRS = @"attrs";
static NSString *DATA = @"data";
static NSString *DISPLAY_NAME = @"displayName";
static NSString *CI_NAME = @"ciName";


@interface JDMCIControllerObject ()
@property NSDictionary *data;
@property NSMutableArray *controls;

// controls for each type of value
@property NSMutableArray *sliderControls;
@property NSMutableArray *colorControls;
@property NSMutableArray *vectorControls;

@property UIView *superView;
@property GLKView *editingView;

@property UIImage *inputImage;

@property int scooter;

@property JDMNumericControlObject *numericControlObject;



//Cells
@property NSMutableArray *sortedCells;
@property NSMutableArray *alphabetsArray;

@end

@implementation JDMCIControllerObject

-(id)initWithDelegate:(id<JDMCIControllerObjectDelegate>)delegate
{
    self = [super init];
    if (self) {
        self.delegate = delegate;
        [self setup];
        
    }
    return self;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setup];
    }
    return self;
}

-(void)setup
{
    self.controls = [[NSMutableArray alloc]init];
    [self performLookupForCIFilterInfo];
    self.scooter=30;
    self.isEditingOnImageView = NO;
}

-(void)reset
{
    NSLog(@"RESET CONTROLLER");
    
    NSLog(@"self.controls Count:%i",(int)self.controls.count);
    
    
    for (NSObject *controlObject in self.controls) {
        
        if ([controlObject isKindOfClass:[JDMCIVectorControlObject class]]) {
            NSLog(@"Cleaning Vector Control");
            [(JDMCIVectorControlObject*)controlObject cleanUpAndRemove];
        }
        
        if ([controlObject isKindOfClass:[JDMNumericControlObject class]]) {
            NSLog(@"Cleaning Numeric Control");
            [(JDMNumericControlObject*)controlObject cleanUpAndRemove];
        }
        
        
    }
    
    
    self.controls = [[NSMutableArray alloc]init];
    self.scooter=30;

    
    for (UIView *view in self.superView.subviews) {
        [view removeFromSuperview];
    }

    
    
}

-(void)performLookupForCIFilterInfo
{
    //Initialize the Data Store
    self.data = [[NSMutableDictionary alloc]init];
    
    // start Loading Filter Info
    NSArray *filters = [CIFilter filterNamesInCategories:[NSArray arrayWithObject:kCICategoryBuiltIn]];
    
    NSMutableDictionary *allAttrs = [[NSMutableDictionary alloc]init];
    
    for (NSString *filterName in filters) {
        CIFilter *samplef = [CIFilter filterWithName:filterName];
        NSDictionary *attrs = [samplef attributes];
        [allAttrs setObject:attrs forKey:filterName];
    }
    
    
    [self.data setValue:[NSDictionary dictionaryWithDictionary:allAttrs] forKey:ATTRS];
    [self makeNameExchangeFunction];
    [self makeCatagories];
    [self fillCellData];
    
    
}


-(void)makeNameExchangeFunction
{
    NSMutableDictionary *displayNameDictionary = [[NSMutableDictionary alloc]init];
    NSMutableDictionary *ciNameDictionary = [[NSMutableDictionary alloc]init];
    
    for (NSString *key in [[self.data valueForKey:ATTRS] allKeys]) {
        NSDictionary  *attrs = [[self.data valueForKey:ATTRS] valueForKey:key];
        NSString *filterDisplayName = [attrs valueForKey:@"CIAttributeFilterDisplayName"];
        
        [displayNameDictionary setValue:key forKey:filterDisplayName];
        [ciNameDictionary setValue:filterDisplayName forKey:key];
        
    }
    
    NSMutableDictionary *dataDictionary = [[NSMutableDictionary alloc]init];
    [dataDictionary setValue:displayNameDictionary forKey:DISPLAY_NAME];
    [dataDictionary setValue:ciNameDictionary forKey:CI_NAME];
    
    [self.data setValue:dataDictionary forKey:DATA];
}

#pragma mark - Cell Data

-(void)fillCellData
{
    
    NSArray* allfilters = [[[self.data valueForKey:DATA] valueForKey:DISPLAY_NAME] allKeys];
    
    NSMutableArray *sections = [[NSMutableArray alloc]init];
    NSMutableArray *sectionTitles = [[NSMutableArray alloc]init];
    
    NSArray *sortedKeys =[[self.tableViewData allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    
    for (NSString *catagoryKey in sortedKeys) {
        NSArray *filtersInCatagory = [self.tableViewData valueForKey:catagoryKey];
        
        // clean Title
        NSString *cleanedCatagory = [[catagoryKey substringFromIndex:([catagoryKey rangeOfString:@"CICategory"].location+[catagoryKey rangeOfString:@"CICategory"].length)] substringToIndex:[catagoryKey length]-[@"CICategory" length]];
        
        NSString *titleCatagory = [self titleFromCamelCaseString:cleanedCatagory];
        
        [sectionTitles addObject:titleCatagory];
        [sections addObject:[self cleanCellTitles:filtersInCatagory]];
    }
    
    self.cellData = [allfilters sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    
    self.cellSections = [NSArray arrayWithArray:sections];
    self.cellSectionTitles = [NSArray arrayWithArray:sectionTitles];
}

-(NSArray*)cleanCellTitles:(NSArray*)titles
{

    NSMutableArray *convertedNames = [[NSMutableArray alloc]init];
    
    for (NSString *title in titles) {
        
        NSString *displayNameOfTitle = [self getDisplayNameFromCIName:title];
        [convertedNames addObject:displayNameOfTitle];
    }
    
    return [convertedNames sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
}

- (NSString *)titleFromCamelCaseString:(NSString *)input
{
    NSMutableString *output = [NSMutableString string];
    [output appendString:[[input substringToIndex:1] uppercaseString]];
    for (NSUInteger i = 1; i < [input length]; i++)
    {
        unichar character = [input characterAtIndex:i];
        if ([[NSCharacterSet uppercaseLetterCharacterSet] characterIsMember:character])
        {
            [output appendString:@" "];
        }
        [output appendFormat:@"%C", character];
    }
    return output;
}

-(NSArray*)makeSectionIndexArray
{
    NSMutableArray *tempFirstLetterArray = [[NSMutableArray alloc] init];
    for (int i = 0; i < [self.cellSectionTitles count]; i++) {
        NSString *letterString = [[self.cellSectionTitles objectAtIndex:i] substringToIndex:1];
            [tempFirstLetterArray addObject:letterString];
    }
    
    return tempFirstLetterArray;
}


-(void)makeCatagories
{
  NSArray *cats =  @[
    kCICategoryDistortionEffect,
    kCICategoryGeometryAdjustment,
    kCICategoryCompositeOperation,
    kCICategoryHalftoneEffect,
    kCICategoryColorAdjustment,
    kCICategoryColorEffect,
    kCICategoryTransition,
    kCICategoryTileEffect,
    kCICategoryGenerator,
    kCICategoryReduction,
    kCICategoryGradient,
    kCICategoryStylize,
    kCICategorySharpen,
    kCICategoryBlur,
    kCICategoryInterlaced,
    kCICategoryNonSquarePixels,
    kCICategoryHighDynamicRange,
     ];
    
    // ,kCICategoryVideo
    // ,kCICategoryStillImage
    // ,kCICategoryBuiltIn
    // ,kCICategoryFilterGenerator;

    NSMutableDictionary *filterCatagories = [[NSMutableDictionary alloc]init];
   
    for ( NSString *catagory in cats) {
    
        
        [filterCatagories setValue:[CIFilter filterNamesInCategories:@[catagory]] forKey:catagory];
    }
    
    self.tableViewData = [NSDictionary dictionaryWithDictionary:filterCatagories];
    
}



#pragma mark - Return Edited Image

-(UIImage*)getEditedImage
{
    UIGraphicsBeginImageContextWithOptions(self.editingView.bounds.size, self.editingView.opaque, 0.0f);
    [self.editingView drawViewHierarchyInRect:self.editingView.bounds afterScreenUpdates:YES];
    UIImage * snapshotImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return snapshotImage;
}










#pragma mark - Load controls

-(void)loadView:(UIView *)view editingView:(GLKView*)editingView withControlsForFilter:(NSString*)filterDisplayName withImage:(UIImage *)image
{
    self.filterDisplayName = filterDisplayName;
    self.filterName = [self getCINameFromDisplayName:self.filterDisplayName];
    
    self.inputImage = image;
    
    self.superView = view;
    self.editingView = editingView;
    self.scooter = 30;
    self.controls = [[NSMutableArray alloc]init];
    self.colorControls = [[NSMutableArray alloc]init];
    
    self.inputParamaters = [[NSMutableDictionary alloc]init];
    self.shouldKeepEditedImage = NO;
    
    CGFloat scale = [UIScreen mainScreen].scale;

    CGPoint center = CGPointMake((self.inputImage.size.width*scale)/2, (self.inputImage.size.height*scale)/2);
    CIVector *centerVector = [CIVector vectorWithCGPoint:center];
    
    UIImage *inputShadingImage = [self getInputShadingImage];
    
    // lookup and get Control information for Filter
    NSDictionary *controlsDictionary = [self getConfigurationInformationForFilterName:filterDisplayName];

    //make and add Keep Button
    [self makeKeepButtonOn:view];
    
    // Stock InputParameters
   
    for (NSString *key in [controlsDictionary allKeys]) {
        
        [self.inputParamaters setValue:[[controlsDictionary valueForKey:key] valueForKey:@"CIAttributeDefault"] forKey:key];
       
        if ([key isEqualToString:kCIInputImageKey]) {
            [self.inputParamaters setValue:[CIImage imageWithCGImage:self.inputImage.CGImage] forKey:kCIInputImageKey];
        }
        
        // Some Defaults for Images
        if ([key isEqualToString:kCIInputMaskImageKey]) {
            [self.inputParamaters setValue:[CIImage imageWithCGImage:inputShadingImage.CGImage] forKey:key];
        }
        
        if ([key isEqualToString:kCIInputShadingImageKey]) {
            [self.inputParamaters setValue:[CIImage imageWithCGImage:inputShadingImage.CGImage] forKey:key];
        }

        if ([key isEqualToString:kCIInputBackgroundImageKey]) {
            [self.inputParamaters setValue:[CIImage imageWithCGImage:[self getInputTargetImage].CGImage] forKey:key];
        }

        if ([key isEqualToString:kCIInputTargetImageKey]) {
            [self.inputParamaters setValue:[CIImage imageWithCGImage:[self getInputTargetImage].CGImage] forKey:key];
        }
         
        if ([key isEqualToString:kCIInputCenterKey]) {
            [self.inputParamaters setValue:centerVector forKey:key];
        }
        
        if ([key isEqualToString:@"inputMessage"]) {
            NSData *data = [@"Hello World" dataUsingEncoding:NSUTF8StringEncoding];
            [self.inputParamaters setValue:data forKey:key];
        }
        
        
        if ([key isEqualToString:@"inputCompactStyle"]) {
            [self.inputParamaters setValue:@YES forKey:key];
        }
        
    }
    
    if ([self.filterName isEqualToString:@"CIQRCodeGenerator"]) {
        
        [self makeBarCodeControllerWithControlData:self.inputParamaters];
    }
    else
    {
        if ([self.filterDisplayName isEqualToString:@"Tone Curve"]) {
            
            [self makeToneCurveControlWithControlData:self.inputParamaters];
        }
        else
        {
            for (NSString *key in [controlsDictionary allKeys]) {
                
                NSDictionary *controlData = [controlsDictionary valueForKey:key];
                
                [self makeControlWithControlData:controlData andKeyValue:key];
            }
            
        }

    }
        

    [self.delegate didUpdateInputParameters:self.inputParamaters];
    NSLog(@"self.inputParamaters:%@",self.inputParamaters);
    
   
    
}




-(void)makeKeepButtonOn:(UIView*)controlsView
{
    CGFloat controlsButtonSize = controlsView.bounds.size.width * 0.10;
    
    UIView *saveView = [[UIView alloc]initWithFrame:CGRectMake(2, 4, controlsButtonSize, controlsButtonSize)];
    
    UIBezierPath *starPath = PathByApplyingTransform(BezierStarShape(5, 0.50), CGAffineTransformMakeScale(controlsButtonSize/2, controlsButtonSize/2));
   

    CAShapeLayer *starShape = [CAShapeLayer layer];
    starShape.position = saveView.center;
    starShape.path = starPath.CGPath;
    starShape.strokeColor = [UIColor whiteColor].CGColor;
    starShape.fillColor = [UIColor clearColor].CGColor;
    starShape.borderWidth = 2.0;
    starShape.borderColor = [UIColor blackColor].CGColor;
    
    
    [saveView.layer addSublayer:starShape];
    
    UITapGestureRecognizer *saveTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleImageSaveTap:)];
    [saveView addGestureRecognizer:saveTap];
    
    [controlsView addSubview:saveView];
    saveView.center = CGPointMake(controlsButtonSize/2, controlsButtonSize/2);
    
}



-(void)handleImageSaveTap:(UITapGestureRecognizer*)tap
{
    static int decider;
    
    
    CAShapeLayer *starShape = (CAShapeLayer*)[[tap view].layer.sublayers firstObject];
    
    if (decider == 0) {
        // Do something here...
        self.shouldKeepEditedImage = YES;
        [UIView animateWithDuration:0.2 animations:^{
            starShape.fillColor = [UIColor purpleColor].CGColor;
        }];
        decider++;
        return;
    }
    else
    {
        self.shouldKeepEditedImage = NO;
        // Do something else here...
        [UIView animateWithDuration:0.2 animations:^{
            starShape.fillColor  = [UIColor clearColor].CGColor;
        }];
        decider--;
        return;
    }

    
   
}




-(CGPoint)convertToCICoord:(CGPoint)uicoord
{
    CGFloat scale = 1;//[UIScreen mainScreen].scale;
    CGPoint scaledUIPoint = CGPointMake(uicoord.x*scale, uicoord.y*scale);
    
    CGAffineTransform transform = CGAffineTransformMakeScale(1, -1);
    transform = CGAffineTransformTranslate(transform, 0, -self.inputImage.size.height*scale);
    
    CGPoint convertedPoint = CGPointApplyAffineTransform(scaledUIPoint, transform);
    return convertedPoint;
}


#pragma mark - GET CONTROLS FOR FILTER

-(NSDictionary*)getConfigurationInformationForFilterName:(NSString*)filterName
{
    NSMutableDictionary *filterControlsDictionary = [[NSMutableDictionary alloc]init];
    
    NSDictionary *filterDictionary = [self getFilterDataFromFilterDisplayName:filterName];
    // Extract just the Controller Keys
    NSArray *controlValueKeys = [self filterFilterDictionary:filterDictionary];
    
    for (NSString *controlValueKey in controlValueKeys) {
        NSDictionary *controlValue = [filterDictionary valueForKey:controlValueKey];
        [filterControlsDictionary setValue:controlValue forKey:controlValueKey];
    }
    
    return [NSDictionary dictionaryWithDictionary:filterControlsDictionary];
}



#pragma mark - Make Control 
-(void)makeControlWithControlData:(NSDictionary *)controlData andKeyValue:(NSString*)keyValue
{
    NSArray *typeArray = [self findTypeOfController:controlData];
    
    VectorType vectorType = [[typeArray lastObject] floatValue];
    ControllerType controllerType = [[typeArray firstObject] floatValue];
    
    [self makeControllerOfType:controllerType withVectorType:vectorType withData:controlData andKeyValue:keyValue];
    
}

#pragma mark - Controller Creation

-(void)makeControllerOfType:(ControllerType)controllerType withVectorType:(VectorType)vectorType withData:(NSDictionary*)data andKeyValue:(NSString*)keyValue
{
    switch (controllerType) {
            
        case ControllerTypeNumber:
            [self makeNumericControlAtYPoint:self.scooter withData:data withKeyValue:keyValue];
            self.scooter = (self.scooter + 42);
            break;
            
        case ControllerTypeColor:
            
            [self makeColorControlAtYPoint:self.scooter withData:data andKeyValue:keyValue];
            self.scooter = (self.scooter + 60);
            break;
            
        case ControllerTypeVector:
            [self makeVectorControlOfType:vectorType atYPoint:self.scooter withData:data withKeyValue:keyValue];
            self.scooter = (self.scooter + 50);
            break;
            
        default:
            break;
    }
    
}

#pragma mark - Make Color Control
-(void)makeColorControlAtYPoint:(CGFloat)yPoint withData:(NSDictionary*)controlData andKeyValue:(NSString*)keyValue
{
    
    NSString *displayName = [controlData valueForKey:@"CIAttributeDisplayName"];
    CIColor *defaultColor = [controlData valueForKey:@"CIAttributeDefault"];
    NSString *colorControlDescription = [controlData valueForKey:@"CIAttributeDescription"];
    
    JDMColorControlObject *colorControlObject = [[JDMColorControlObject alloc]initWithDelegate:self inView:self.superView withDefaultRed:defaultColor.red green:defaultColor.green blue:defaultColor.blue andAlpha:defaultColor.alpha withTitle:displayName description:colorControlDescription andKeyValue:keyValue];
    [colorControlObject updateButtonPosition:yPoint+10];
    [self.controls addObject:colorControlObject];
}

#pragma mark - Make Numeric Control
-(void)makeNumericControlAtYPoint:(CGFloat)yPoint withData:(NSDictionary*)controlData withKeyValue:(NSString*)keyValue
{
    CGFloat min = [[controlData valueForKey:@"CIAttributeSliderMin"] floatValue];
    CGFloat max = [[controlData valueForKey:@"CIAttributeSliderMax"] floatValue];
    CGFloat def = [[controlData valueForKey:@"CIAttributeDefault"] floatValue];
    NSString *title = [controlData valueForKey:@"CIAttributeDisplayName"];
    
    JDMNumericControlObject *numericControlObject = [[JDMNumericControlObject alloc]initWithDelegate:self inView:self.superView withTitle:title withMin:min andMax:max withDefault:def andKeyValue:keyValue];
    [numericControlObject updateYPosition:yPoint];
    [self.controls addObject:numericControlObject];
}

#pragma mark - Make CIVector Control
-(void)makeVectorControlOfType:(VectorType)vectorType atYPoint:(CGFloat)yPoint withData:(NSDictionary*)controlData withKeyValue:(NSString*)keyValue
{
    CIVector *defaultVector = [controlData valueForKey:@"CIAttributeDefault"];
    
    NSString *title = [controlData valueForKey:@"CIAttributeDisplayName"];
    
    JDMCIVectorControlObject *vectorControlObject = [[JDMCIVectorControlObject alloc]initWithDelegate:self inView:self.superView editingView:self.editingView ofType:vectorType withTitle:title withDefault:defaultVector andKeyValue:keyValue];
    [vectorControlObject updateYPosition:yPoint];
    [self.controls addObject:vectorControlObject];
    

}

#pragma mark - Make Tone Curve Control
-(void)makeToneCurveControlWithControlData:(NSDictionary *)controlData
{
    JDMCIVectorControlObject *vectorControlObject = [[JDMCIVectorControlObject alloc]initWithDelegateForToneCurve:self inView:self.superView editingView:self.editingView withInputParams:controlData];
    [self.controls addObject:vectorControlObject];
}

#pragma mark - Make QR Code Control
-(void)makeBarCodeControllerWithControlData:(NSDictionary *)controlData
{
    JDMBarCodeControlObject *barCodeControlObject = [[JDMBarCodeControlObject alloc]initWithDelegate:self inView:self.superView withInputParams:controlData withFilterName:self.filterName];
    [self.controls addObject:barCodeControlObject];
    
}







#pragma mark - DELEGATE CALLS

#pragma mark - BarCode Control Delegate
-(void)didChangeBarCodeValueTo:(NSData*)value forKeyValue:(NSString *)keyValue
{
    [self.inputParamaters setValue:value forKey:keyValue];
    [self proccessNewInputParameters];

}

-(void)didChangeBarCorrectionLevelTo:(NSString *)value forKeyValue:(NSString *)keyValue
{
    [self.inputParamaters setValue:value forKey:keyValue];
    [self proccessNewInputParameters];

}

#pragma mark - Number Control Delegate

-(void)didChangeNumericValueTo:(NSNumber *)newValue forKeyValue:(NSString *)keyValue
{
    [self.inputParamaters setValue:newValue forKey:keyValue];
    [self proccessNewInputParameters];
}

#pragma mark - Color Control Delegate
-(void)didChangeColor:(CIColor *)color forKeyValue:(NSString *)keyValue
{
    [self.inputParamaters setValue:color forKey:keyValue];
    [self proccessNewInputParameters];
}

#pragma mark - CIVector Control Delegate
-(void)didChangeVectorValueTo:(CIVector *)newValue forKeyValue:(NSString *)keyValue
{
    [self.inputParamaters setValue:newValue forKey:keyValue];
    [self proccessNewInputParameters];
}

-(void)isEditing:(BOOL)editing
{
    // NSLog(@"Vector Object is editing Value");
    
    if (editing) {
        self.isEditingOnImageView = YES;
    }
    else
    {
        self.isEditingOnImageView = NO;
    }
}


#pragma mark - Call To Delegate
-(void)proccessNewInputParameters
{
    [self.delegate didUpdateInputParameters:self.inputParamaters];
}
































#pragma mark - Page Curl Transition Helpers

-(UIImage*)getInputShadingImage
{
    return [self makeRadialGradientImage];
}

-(UIImage*)getinputBacksideImage
{
    return [self flipImage:self.inputImage];
}

-(UIImage*)getInputTargetImage
{
    return [self makeCheckerBoardImage];
}


-(CIImage*)getBackImage
{
    CIImage *c = [CIImage imageWithCGImage:self.inputImage.CGImage];
    
    // Apply transform
    c = [c imageByApplyingTransform:CGAffineTransformTranslate(CGAffineTransformMakeScale(1, -1), 0, c.extent.size.height)];
    
    // Convert back to UIImage
    CIContext *context = [CIContext contextWithOptions:nil];
    
    return [CIImage imageWithCGImage:[context createCGImage:c fromRect:c.extent]];
 }

#pragma mark - UIimage Flipping
- (UIImage *)flipImage:(UIImage *)image
{
    
    // Load image
    UIImage *u = image;
    // Convert to CIImage
    CIImage *c = [[CIImage alloc] initWithImage:u];
    // Apply transform
    c = [c imageByApplyingTransform:CGAffineTransformTranslate(CGAffineTransformMakeScale(1, -1), 0, c.extent.size.height)];
    
    // Convert back to UIImage
    CIContext *context = [CIContext contextWithOptions:nil];
    UIImage *flippedImage = [UIImage imageWithCGImage:[context createCGImage:c fromRect:c.extent]];
    
    CIImage *ci_image = [CIImage imageWithCGImage:flippedImage.CGImage];
    
    
    return flippedImage;
    
    
    
    
    
    
//    UIGraphicsBeginImageContext(CGSizeMake(image.size.width*3, image.size.height*3));
//    CGContextRef context = UIGraphicsGetCurrentContext();
//    
//    // fix X
//    CGContextTranslateCTM(context, 0, image.size.height);
//    CGContextScaleCTM(context, 1.0f, -1.0f);
//    
//    // then flip Y axis
//    CGContextTranslateCTM(context, image.size.width, 0);
//    CGContextScaleCTM(context, -1.0f, 1.0f);
//    
//    
//    
//    
//    CGContextDrawImage(context, CGRectMake(0, 0, image.size.width*3, image.size.height*3), [image CGImage]);
//    
//    UIImage *flipedImage = UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();
    
    
    
}

#pragma mark - Radial Gradient Image Creation
-(UIImage *)makeRadialGradientImage
{
    CGFloat w = self.superView.frame.size.width;
    CGFloat scale = [UIScreen mainScreen].scale;
    
    CGRect outRect = CGRectMake(0, 0, w*scale, w*scale);
    
    CIVector *inputCenter = [CIVector vectorWithX:outRect.size.width/2 Y:outRect.size.height/2];
    CIColor *inputColor0 = [CIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0];
    CIColor *inputColor1 = [CIColor colorWithRed:0 green:0 blue:0 alpha:1.0];
    
    NSString *filterName = @"CIRadialGradient";
    
    NSDictionary *inputParamaters = @{
                                      @"inputCenter" : inputCenter,
                                      @"inputColor0" : inputColor0,
                                      @"inputColor1" : inputColor1,
                                      @"inputRadius0" : @(4), //0-800.
                                      @"inputRadius1" : @(outRect.size.width*0.5), //0-800.
                                      };
    
    
    
    CIFilter *filter = [CIFilter filterWithName:filterName withInputParameters:inputParamaters];// A filter that is available in iOS or a custom one :)
    
    CIImage *outputImage = [filter outputImage];
    CIContext *context = [CIContext contextWithOptions:nil];
    
    
    
    
    UIImage * img = [UIImage imageWithCGImage:[context createCGImage:outputImage fromRect:outRect]];
    
    return img;
    
    
}

#pragma mark - CheckerBoard Image
-(UIImage*)makeCheckerBoardImage
{
    CGFloat w = self.superView.frame.size.width;
    
    CGFloat scale = [UIScreen mainScreen].scale;
    
    CGRect outRect = CGRectMake(0, 0, w*scale, w*scale);
    
    CIVector *inputCenter = [CIVector vectorWithX:w/2 Y:w/2];
    CIColor *inputColor0 = [CIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0];
    CIColor *inputColor1 = [CIColor colorWithRed:0 green:0 blue:0 alpha:1.0];
    
    NSString *filterName = @"CICheckerboardGenerator";
    
    NSDictionary *inputParamaters = @{
                                      @"inputCenter" : inputCenter,
                                      @"inputColor0" : inputColor0,
                                      @"inputColor1" : inputColor1,
                                      @"inputSharpness" : @(1),
                                      @"inputWidth" : @(32),
                                      };
    
    
    
    CIFilter *filter = [CIFilter filterWithName:filterName withInputParameters:inputParamaters];// A filter that is available in iOS or a custom one :)
    
    CIImage *outputImage = [filter outputImage];
    CIContext *context = [CIContext contextWithOptions:nil];
    
    UIImage * img = [UIImage imageWithCGImage:[context createCGImage:outputImage fromRect:outRect]];
    
    return img;
    
}




#pragma mark - helpers

-(NSArray*)findTypeOfController:(NSDictionary *)controllerValue
{
    VectorType vectorType = 0;
    
    NSString *attributeClass = [controllerValue valueForKey:@"CIAttributeClass"];
    
    ControllerType controllerType = [self findControllerTypeForAttributeClass:attributeClass];
    
    if (controllerType == ControllerTypeVector)
    {
        NSString *typeString = [controllerValue valueForKey:@"CIAttributeType"];
        
        if (typeString) {
            
            if ([typeString isEqualToString:@"CIAttributeTypeOffset"]) {
                vectorType = VectorTypeOffset;
            }
            
            if ([typeString isEqualToString:@"CIAttributeTypePosition"]) {
                vectorType = VectorTypePosition;
            }
            
            if ([typeString isEqualToString:@"CIAttributeTypePosition3"]) {
                vectorType = VectorTypePosition3;
            }
            
            if ([typeString isEqualToString:@"CIAttributeTypeRectangle"]) {
                vectorType = VectorTypeRectangle;
            }
        }
        else
        {
            vectorType = VectorTypeNil;
        }
        
        
    }
    
    CGFloat controllerInt = controllerType;
    CGFloat vectorInt = vectorType;
    
    return  @[
              @(controllerInt),
              @(vectorInt),
              ];
    
}





-(NSString*)getDisplayNameFromCIName:(NSString*)ciName
{
    return [[[self.data valueForKey:DATA] valueForKey:CI_NAME] valueForKey:ciName];
}

-(NSString*)getCINameFromDisplayName:(NSString*)displayName
{
    return [[[self.data valueForKey:DATA] valueForKey:DISPLAY_NAME] valueForKey:displayName];
}

-(NSDictionary*)getFilterDataFromFilterDisplayName:(NSString*)filterDisplayName
{
    NSString *key = [self getCINameFromDisplayName:filterDisplayName];
    NSDictionary *filterInfo = [[self.data valueForKey:ATTRS] valueForKey:key];
    return filterInfo;
}
    
// helper for filtering and finding the Controller keys from filter dictionary
-(NSArray*)filterFilterDictionary:(NSDictionary*)filterDictionary
{
    NSMutableArray *filteredKeys = [[NSMutableArray alloc]init];
    
    NSMutableArray *keys = [NSMutableArray arrayWithArray:[filterDictionary allKeys]];
    for (NSString *keyValue in keys) {
        
        BOOL shouldSkip = NO;
        
        if ([keyValue isEqualToString:@"CIAttributeFilterAvailable_iOS"]) {
            shouldSkip = YES;
        }
        
        if ([keyValue isEqualToString:@"CIAttributeFilterDisplayName"]) {
            shouldSkip = YES;
        }
        
        if ([keyValue isEqualToString:@"CIAttributeFilterCategories"]) {
            shouldSkip = YES;
        }
        
        if ([keyValue isEqualToString:@"CIAttributeFilterName"]) {
            shouldSkip = YES;
        }
        
        if ([keyValue isEqualToString:@"CIAttributeReferenceDocumentation"]) {
            shouldSkip = YES;
        }
        
        if ([keyValue isEqualToString:@"CIAttributeFilterAvailable_Mac"]) {
            shouldSkip = YES;
        }
        
        
        if (!shouldSkip) {
            [filteredKeys addObject:keyValue];
        }
        
    }
    
    return filteredKeys;
}



-(ControllerType)findControllerTypeForAttributeClass:(NSString*)attributeClass
{
    ControllerType foundControllerType = 0;
    
    if ([attributeClass isEqualToString:@"NSNumber"]) {
        foundControllerType = ControllerTypeNumber;
    }
    
    if ([attributeClass isEqualToString:@"CIImage"]) {
        foundControllerType = ControllerTypeImage;
    }
    
    if ([attributeClass isEqualToString:@"NSValue"]) {
        foundControllerType = ControllerTypeValue;
    }
    
    if ([attributeClass isEqualToString:@"CIColor"]) {
        foundControllerType = ControllerTypeColor;
    }
    
    if ([attributeClass isEqualToString:@"CIVector"]) {
        foundControllerType = ControllerTypeVector;
    }
    
    if ([attributeClass isEqualToString:@"NSData"]) {
        foundControllerType = ControllerTypeData;
    }
    
    if ([attributeClass isEqualToString:@"NSObject"]) {
        foundControllerType = ControllerTypeObject;
    }
    
    if ([attributeClass isEqualToString:@"NSString"]) {
        foundControllerType = ControllerTypeString;
    }
    
    return foundControllerType;
}


void LogControllerType(ControllerType controllerType)
{
    switch (controllerType) {
        case ControllerTypeColor:
            NSLog(@"ControllerTypeColor");
            break;
        case ControllerTypeData:
            NSLog(@"ControllerTypeData");
            break;
        case ControllerTypeImage:
            NSLog(@"ControllerTypeImage");
            break;
        case ControllerTypeNumber:
            NSLog(@"ControllerTypeNumber");
            break;
        case ControllerTypeObject:
            NSLog(@"ControllerTypeObject");
            break;
        case ControllerTypeString:
            NSLog(@"ControllerTypeString");
            break;
        case ControllerTypeValue:
            NSLog(@"ControllerTypeValue");
            break;
        case ControllerTypeVector:
            NSLog(@"ControllerTypeVector");
            break;
        case ControllerTypeNil:
            NSLog(@"ControllerTypeNil");
            break;
            
        default:
            break;
    }
}



void LogVectorType(VectorType vectorType)
{
    switch (vectorType) {
        case VectorTypeOffset:
            NSLog(@"VectorTypeOffset");
            break;
        case VectorTypePosition:
            NSLog(@"VectorTypePosition");
            break;
        case VectorTypePosition3:
            NSLog(@"VectorTypePosition3");
            break;
        case VectorTypeRectangle:
            NSLog(@"VectorTypeRectangle");
            break;
        case VectorTypeNil:
            NSLog(@"VectorTypeNil");
            break;
        default:
            break;
    }
}

@end
