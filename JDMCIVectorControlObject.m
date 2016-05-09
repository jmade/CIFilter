//
//  JDMCIVectorControlObject.m
//  CIFilter
//
//  Created by Justin Madewell on 11/29/15.
//  Copyright © 2015 Justin Madewell. All rights reserved.
//

#import "JDMCIVectorControlObject.h"


@interface JDMCIVectorControlObject ()

// for refernces
@property UIView *superView;
@property GLKView *imageEditingView;

@property UIView *buttonView;
@property UIView *dotView;
@property UIView *rectangleView;
@property UIView *touchView;

@property CGPoint value;

@property NSString *title;
@property CIVector *defaultVector;

@property CIVector *inputVector;

@property VectorType vectorType;

@property CGRect resizedRect;
@property CGRect oldDotRect;
@property CGPoint beganTouchingPoint;

@property CGPoint oldPoint;

@property CGFloat oldRectWidth;
@property CGFloat oldRectHeight;

@property BOOL shouldDragDot;

// offset
@property UILabel *descriptionLabel;
@property UIView *expandedView;
@property BOOL isExpanded;
@property UISlider *zSlider;
@property UISlider *xSlider;
@property UISlider *ySlider;



@property UIView *toneCurveViewControl;
@property NSMutableDictionary* toneCurveControlDots;
@property NSString *keyToMove;
@property CAShapeLayer *graphLayer;

@end

@implementation JDMCIVectorControlObject

-(id)initWithDelegate:(id<JDMCIVectorControlObjectDelegate>)delegate inView:(UIView *)view editingView:(GLKView*)editingView ofType:(VectorType)vectorType withTitle:(NSString *)title withDefault:(CIVector *)defaultValue andKeyValue:(NSString *)keyValue
{
    self = [super init];
    if(self)
    {
        self.delegate = delegate;
        self.vectorType = vectorType;
        self.superView = view;
        self.imageEditingView = editingView;
        self.defaultVector = defaultValue;
        self.title = title;
        self.keyValue = keyValue;
        
        [self setup];
    }
    return self;

}


-(id)initWithDelegateForToneCurve:(id<JDMCIVectorControlObjectDelegate>)delegate inView:(UIView *)view editingView:(GLKView *)editingView withInputParams:(NSDictionary *)inputParams
{
    self = [super init];
    if(self)
    {
        self.delegate = delegate;
        self.superView = view;
        self.imageEditingView = editingView;
        
        [self setupForToneCurve:inputParams];
    }
    return self;
}






-(void)updateYPosition:(CGFloat)positionY
{
    // update the views colors
    [UIView animateWithDuration:0 animations:^{
        self.buttonView.center = CGPointMake(self.superView.center.x, positionY);
    }];

}

-(BOOL)isKeyAPoint:(NSString*)key
{
    BOOL keyIsAPoint = NO;
    
    NSString *inputString = @"inputPoint";

    NSMutableString *output = [NSMutableString string];
    [output appendString:[key substringToIndex:10]];
    
    if ([output isEqualToString:inputString]) {
        keyIsAPoint = YES;
    }
    
    return keyIsAPoint;
}


-(void)setupForToneCurve:(NSDictionary*)data
{
    self.toneCurveControlDots = [[NSMutableDictionary alloc]init];
    
    
    // find out how many controls we have, build them and put them in a @{}
    for (int i=0; i<[data allKeys].count; i++) {
        NSString *key = [[data allKeys] objectAtIndex:i];
        if ([self isKeyAPoint:key]) {
            NSMutableString *indexString = [NSMutableString string];
            [indexString appendString:[key substringFromIndex:10]];
            
            [self.toneCurveControlDots setValue:[self makeToneControlDot] forKey:indexString];
            
        }
        
    }
    
    int numberOfControls = (int)[[self.toneCurveControlDots allKeys] count];
    
    self.toneCurveViewControl = [self makeToneCurveController:numberOfControls];
    
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(handleToneCurvePan:)];
    [self.superView addGestureRecognizer:pan];

    
    [self addControlsToToneCurveControl];
    
    [self.superView addSubview:self.toneCurveViewControl];
    
    [self updateForToneControl];
    
    [self updateGraph];
    [self animateInToneViewControl];
    
    
}

-(void)addControlsToToneCurveControl
{
    int controlCount = (int)[[self.toneCurveControlDots allKeys] count];
    CGFloat spacingY = 0.25;
    
    CGFloat spacing = self.toneCurveViewControl.bounds.size.width / (controlCount-1) ;
    
    for (int i=0; i<controlCount; i++) {
        NSString *key = [NSString stringWithFormat:@"%i",i];
        UIView *dot = [self.toneCurveControlDots valueForKey:key];
        
        CGFloat amount = (1.0 - (spacingY*i));
        
        CGFloat yAmount = (amount * self.toneCurveViewControl.bounds.size.height);
       
        dot.center =  CGPointMake(i*spacing, yAmount);
        [self.toneCurveViewControl addSubview:dot];
    }
    
}


-(void)setup
{
    // make Button View
    self.buttonView = [self makeVectorControlButtonwithDisplayName:self.title];
    [self.superView addSubview:self.buttonView];
    
    //make Control's Auxilary views
    self.touchView = [self makeTouchView];
    self.dotView = [self makeDotView];
    
    
    self.inputVector = self.defaultVector;
    
    switch (self.vectorType) {
        case VectorTypeNil:
            break;
        case VectorTypePosition:
            self.value = CGPointMake(self.defaultVector.X, self.defaultVector.Y);
            
            // correct for Center Vector
            if ([self.title isEqualToString:@"Center"]) {
                self.value = self.imageEditingView.center;
            }

            
            break;
        case VectorTypePosition3:
            self.value = CGPointMake(self.defaultVector.X, self.defaultVector.Y);
            self.expandedView = [self makeExpandedView];
            self.isExpanded = NO;
            break;
        case VectorTypeRectangle:
            self.resizedRect = CGRectMake(self.defaultVector.X, self.defaultVector.Y, self.defaultVector.Z, self.defaultVector.W);
            self.rectangleView = [self makeRectangleViewWithRect:self.resizedRect];
            break;
        case VectorTypeOffset:
            
            break;
        default:
            break;
    }
}


-(UIView*)makeTouchView
{
    CGRect touchViewRect = self.imageEditingView.bounds;
    
    UIView *touchView = [[UIView alloc]initWithFrame:touchViewRect];
    touchView.backgroundColor = [UIColor colorWithWhite:0.97 alpha:0.22];
    
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(handleTouchViewPan:)];
    [touchView addGestureRecognizer:pan];
    
    return touchView;

}

-(UIView*)makeDotView
{
    CGFloat viewSize = 50;
    
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, viewSize, viewSize)];
    
    view.layer.masksToBounds = YES;
    view.layer.cornerRadius = viewSize/2;
    view.layer.borderColor = [UIColor whiteColor].CGColor;
    view.layer.backgroundColor = [UIColor blueColor].CGColor;
    
    view.alpha=1.0;
    
    return view;
    
    
}


-(UIView*)makeRectangleViewWithRect:(CGRect)rect
{
    UIView *view = [[UIView alloc]initWithFrame:rect];
    view.backgroundColor = [UIColor grassColor];
    view.layer.borderColor = [UIColor whiteColor].CGColor;
    view.layer.borderWidth = 2.0;

    return view;
    
}



#pragma mark - Setup for Position


-(UIView*)makeVectorControlButtonwithDisplayName:(NSString*)vectorDisplayName
{
    CGFloat widthValue = (self.superView.bounds.size.width/3)*2;
    
    UIColor *color = [UIColor whiteColor];
    
    CGRect vectorControlbuttonRect = CGRectMake(0, 0, widthValue, 37.5);
    
    UIView *vectorControlButtonView = [[UIView alloc]initWithFrame:vectorControlbuttonRect];
    vectorControlButtonView.backgroundColor = [UIColor purpleColor];
    
    vectorControlButtonView.layer.cornerRadius = vectorControlbuttonRect.size.height/2;
    vectorControlButtonView.layer.masksToBounds = YES;
    vectorControlButtonView.layer.borderColor = color.CGColor;
    vectorControlButtonView.layer.borderWidth = 2.0;
    
    UILabel *vectorDisplayNameLabel = [[UILabel alloc]initWithFrame:vectorControlbuttonRect];
    vectorDisplayNameLabel.textColor = color;
    vectorDisplayNameLabel.textAlignment = NSTextAlignmentCenter;
    vectorDisplayNameLabel.numberOfLines=1;
    vectorDisplayNameLabel.text = vectorDisplayName;
    vectorDisplayNameLabel.center = vectorControlButtonView.center;
    
    [vectorControlButtonView addSubview:vectorDisplayNameLabel];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleVectorButtonTap)];
    [vectorControlButtonView addGestureRecognizer:tap];
    
    return vectorControlButtonView;
}


#pragma mark - Hand Button Tap
-(void)handleVectorButtonTap
{
    [self.delegate isEditing:YES];
    
    
    switch (self.vectorType) {
        case VectorTypeNil:
            break;
        case VectorTypePosition:
            [self handlePosition];
            break;
        case VectorTypePosition3:
            [self handlePosition3];
            break;
        case VectorTypeRectangle:
            [self handleRectangle];
            break;
        case VectorTypeOffset:
            [self handleOffset];
            break;
        default:
            break;
    }
}

#pragma mark - Handle Setup For Vector Type
-(void)handlePosition
{
    [self setupForPosition];
}

-(void)handlePosition3
{
    [self setupForPosition3];
}

-(void)handleRectangle
{
    [self setupForRectangle];
}

-(void)handleOffset
{
    [self setupForOffset];
}



#pragma mark - Position
-(void)setupForPosition
{
    self.dotView.alpha=0;
    self.touchView.alpha=0;
    
    [self.touchView addSubview:self.dotView];
    self.dotView.center = self.value;
    [[self.superView superview] addSubview:self.touchView];
    
    [UIView animateWithDuration:0.2 animations:^{
        self.dotView.alpha=1;
        self.touchView.alpha=1;
        self.buttonView.backgroundColor = [UIColor blueColor];
        self.superView.backgroundColor = [UIColor purpleColor];
        
    }];

    
    
}


#pragma mark - Handle Touch View Pan
-(void)handleTouchViewPan:(UIPanGestureRecognizer*)pan
{
    CGPoint panLocation = [pan locationInView:pan.view];
    
    CGPoint translation = [pan translationInView:pan.view];
    
    switch (pan.state) {
        case UIGestureRecognizerStateBegan:
            
            if (CGRectContainsPoint(self.dotView.frame, panLocation)) {
                self.shouldDragDot = YES;
                self.oldPoint = panLocation;
                self.oldRectWidth = self.rectangleView.frame.size.width;
                self.oldRectHeight = self.rectangleView.frame.size.height;
            }
            else
            {
                self.shouldDragDot = NO;
            }
           
            [self handleNewPanValue:panLocation andTranslationValue:translation];
            break;
            
        case UIGestureRecognizerStateChanged:
            
           [self handleNewPanValue:panLocation andTranslationValue:translation];
            break;
            
        case UIGestureRecognizerStateEnded:
            [self handlePanEnded];
            break;
            
        default:
            break;
    }

}

-(void)handleNewPanValue:(CGPoint)newPanValue andTranslationValue:(CGPoint)translation
{
    switch (self.vectorType) {
        case VectorTypeNil:
            //
            break;
        case VectorTypePosition:
            [self handleNewValueForPosition:newPanValue];
            break;
        case VectorTypePosition3:
            //TODO: Try, then fix
            [self handleNewValueForPosition3:newPanValue withZ:self.zSlider.value];
            break;
        case VectorTypeRectangle:
            [self handleNewValueForRectangle:newPanValue andTranslationValue:translation];
            break;
        case VectorTypeOffset:
            //
            break;
        default:
            break;
    }
}




#pragma mark -  Handle Pan End
-(void)handlePanEnded
{
    self.resizedRect = self.rectangleView.frame;
  
    switch (self.vectorType) {
        case VectorTypeNil:
            //
            break;
        case VectorTypePosition:
            break;
        case VectorTypePosition3:
            break;
        case VectorTypeRectangle:
            self.inputVector = [CIVector vectorWithCGRect:[self convertRectToCICoordinates:self.resizedRect]];
            break;
        case VectorTypeOffset:
            break;
        default:
            break;
    }
    
    [self informDelegateOfNewValue];
    
    if (!self.isExpanded) {
        [UIView animateWithDuration:0.2 animations:^{
            
            [self.dotView removeFromSuperview];
            [self.rectangleView removeFromSuperview];
            [self.touchView removeFromSuperview];
            
            [self.delegate isEditing:NO];
            
            self.superView.backgroundColor = [UIColor orangeColor];
            self.buttonView.backgroundColor = [UIColor purpleColor];
        }];

    }
}



#pragma mark - Position3
-(void)setupForPosition3
{
    [self handlePosition3ButtonTap];
    
    
    
    
}





-(void)setupForRectangle
{
    self.rectangleView.alpha=0;
    self.dotView.alpha=0;
    self.touchView.alpha=0;
    
    
    self.rectangleView = [self makeRectangleViewWithRect:self.resizedRect];
    [self.touchView addSubview:self.rectangleView];
    
    [self.touchView addSubview:self.dotView];
    self.dotView.center = RectGetBottomRight(self.resizedRect);
    
    [[self.superView superview] addSubview:self.touchView];
    
    [UIView animateWithDuration:0.2 animations:^{
        self.rectangleView.alpha=1;
        self.dotView.alpha=1;
        self.touchView.alpha=1;
        self.buttonView.backgroundColor = [UIColor grassColor];
        self.superView.backgroundColor = [UIColor purpleColor];

    }];
    
    
    
    
    
 }


-(void)setupForOffset
{
    
   NSLog(@" self.keyValue:%@", self.keyValue);
    
    
     self.expandedView = [self makeExpandedViewForVectorType:self.vectorType];
    
    self.xSlider.value = self.defaultVector.X;
    UILabel *label = (UILabel*)[self.xSlider.subviews objectAtIndex:1];
    label.text = [@"" stringByAppendingFormat:@"%.02f",self.defaultVector.X];
    self.ySlider.value = self.defaultVector.Y;
    UILabel *ylabel = (UILabel*)[self.ySlider.subviews objectAtIndex:1];
    ylabel.text = [@"" stringByAppendingFormat:@"%.02f",self.defaultVector.Y];
    
    [self.superView addSubview:self.expandedView];
    
    [UIView animateWithDuration:0.75 delay:0 usingSpringWithDamping:0.65 initialSpringVelocity:0.72 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.expandedView.alpha = 1.0;
        self.expandedView.center = CGPointMake(RectGetCenter(self.superView.bounds).x, RectGetCenter(self.superView.bounds).y-self.superView.bounds.size.height/8);
        
    } completion:^(BOOL finished) {
        self.isExpanded = YES;
    }];

}







#pragma mark - Handle New Values

-(void)handleNewValueForPosition:(CGPoint)newPoint
{
    self.dotView.center = newPoint;
    self.value = newPoint;
    
    CGPoint convertedPoint = [self convertToCICoord:newPoint];
    
    CGFloat scale = [UIScreen mainScreen].scale;
    CGPoint pt = CGPointMake(convertedPoint.x *scale, convertedPoint.y*scale);
    
    self.inputVector = [CIVector vectorWithCGPoint:pt];
    
    [self informDelegateOfNewValue];

}


-(void)handleNewValueForPosition3:(CGPoint)newPoint withZ:(CGFloat)zValue
{
    
    self.dotView.center = newPoint;
    
    self.value = newPoint;
    
    CGPoint convertedPoint = [self convertToCICoord: self.value];
    CGFloat scale = [UIScreen mainScreen].scale;
    
    CGFloat vX = convertedPoint.x *scale;
    CGFloat vY = convertedPoint.y *scale;
    CGFloat vZ = zValue;
    
    self.inputVector = [CIVector vectorWithX:vX Y:vY Z:vZ];
    
    [self informDelegateOfNewValue];
    

}

-(void)handleNewValueForRectangle:(CGPoint)newPoint andTranslationValue:(CGPoint)translation
{
    if (self.shouldDragDot) {
        [self resizeRect:newPoint andTranslationValue:translation];
    }
    else
    {
        [self moveRect:newPoint andTranslationValue:translation];
    }
    
    
    
    //self.inputVector = [CIVector vectorWithCGRect:[self convertRectToCICoordinates:self.resizedRect]];
    self.inputVector = [CIVector vectorWithCGRect:self.resizedRect];
    
    [self informDelegateOfNewValue];
}

-(void)moveRect:(CGPoint)point andTranslationValue:(CGPoint)translation
{
    CGRect oldResizeRect = self.resizedRect;
    CGRect newRect = RectAroundCenter(point, oldResizeRect.size);
    self.resizedRect = newRect;
    
    [UIView animateWithDuration:0 animations:^{
        self.rectangleView.center = point;
        self.dotView.center = RectGetBottomRight(self.resizedRect);
    }];
}

-(void)resizeRect:(CGPoint)point andTranslationValue:(CGPoint)translation
{
    CGPoint movementAmount = PointSubtractPoint(point, self.oldPoint);
    
    CGFloat frameX = self.rectangleView.frame.origin.x;
    CGFloat frameY = self.rectangleView.frame.origin.y;
    CGFloat W = self.oldRectWidth + movementAmount.x;
    CGFloat H = self.oldRectHeight + movementAmount.y;
    
    CGRect revisedRect =  CGRectMake(frameX, frameY, W, H);
    self.resizedRect = revisedRect;
    
    [UIView animateWithDuration:0 animations:^{
        self.rectangleView.frame = self.resizedRect;
        self.dotView.center = RectGetBottomRight(self.resizedRect);
    }];
    
    
}



#pragma mark - Offset-Handle New Vaue
-(void)handleNewValueForOffset:(CGPoint)newPoint
{
    CGPoint convertedPoint = [self convertToCICoord:newPoint];
    
    CGFloat scale = [UIScreen mainScreen].scale;
    CGPoint pt = CGPointMake(convertedPoint.x *scale, convertedPoint.y*scale);
    
    self.inputVector = [CIVector vectorWithCGPoint:pt];
    
    [self informDelegateOfNewValue];

}



#pragma mark - Offset Expanded View

-(void)handlePosition3ButtonTap
{
    
    
    self.touchView = [self makeTouchView];
    self.expandedView = [self makeExpandedView];
    self.dotView = [self makeDotView];

    self.dotView.alpha=0;
    self.touchView.alpha=0;
    
    [self.touchView addSubview:self.dotView];
    self.dotView.center = self.value;
    [[self.superView superview] addSubview:self.touchView];
    
    [UIView animateWithDuration:0.2 animations:^{
        self.dotView.alpha=1;
        self.touchView.alpha=1;
        self.buttonView.backgroundColor = [UIColor blueColor];
        self.superView.backgroundColor = [UIColor purpleColor];
        
    }];

    
    [self expandZControl];
    
    
}








#pragma mark - Make Z Control

-(UILabel*)makeDescriptionLabel
{
    CGFloat labelSize = (self.superView.bounds.size.width-40)*0.80;
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0 , 0 , labelSize, 60)];
    label.textAlignment = NSTextAlignmentCenter;
    label.lineBreakMode = NSLineBreakByWordWrapping;
    label.numberOfLines=0;
    
    return label;
}


-(UIView*)makeExpandedViewForVectorType:(VectorType)vectorType
{
    
    UIView *expandedView;
    
    if (vectorType == VectorTypePosition3) {
        CGFloat expandedH = self.superView.bounds.size.height/4;
        CGRect colorControlRect = CGRectInset(self.superView.frame, 20, expandedH);
        UIView *colorController = [[UIView alloc]initWithFrame:colorControlRect];
        
        colorController.backgroundColor = [UIColor eggshellColor];
        colorController.layer.cornerRadius = 10;
        colorController.layer.masksToBounds = YES;
        colorController.layer.borderColor = [UIColor blackColor].CGColor;
        colorController.layer.borderWidth = 2.0;
        
        UISwipeGestureRecognizer *swipeDown = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(handleSwipeDown:)];
        swipeDown.direction = UISwipeGestureRecognizerDirectionDown;
        
        [colorController addGestureRecognizer:swipeDown];
        
        UISlider *slider = [self makeZSliderWithTitle:@"Z" withDefault:self.defaultVector.Z];
        
        [colorController addSubview:slider];
        
        [self.superView addSubview:colorController];
        
        self.zSlider = slider;
        
        expandedView = colorController;
    }
    
    
    if (vectorType == VectorTypeOffset) {
        // offset
        CGFloat expandedH = self.superView.bounds.size.height/4;
        CGRect colorControlRect = CGRectInset(self.superView.frame, 20, expandedH);
        UIView *expandedViewOffset = [[UIView alloc]initWithFrame:colorControlRect];
        
        expandedViewOffset.backgroundColor = [UIColor eggshellColor];
        expandedViewOffset.layer.cornerRadius = 10;
        expandedViewOffset.layer.masksToBounds = YES;
        expandedViewOffset.layer.borderColor = [UIColor blackColor].CGColor;
        expandedViewOffset.layer.borderWidth = 2.0;
        
        UISwipeGestureRecognizer *swipeDown = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(handleSwipeDown:)];
        swipeDown.direction = UISwipeGestureRecognizerDirectionDown;
        
        [expandedViewOffset addGestureRecognizer:swipeDown];
        
        UISlider *offsetXSlider = [self makeZSliderWithTitle:@"X Offset" withDefault:self.defaultVector.X];
        offsetXSlider.maximumValue = 10000;
        
        UISlider *offsetYSlider = [self makeZSliderWithTitle:@"Y Offset" withDefault:self.defaultVector.Y];
        offsetYSlider.maximumValue = 10000;
        
        offsetYSlider.center = CGPointMake(offsetXSlider.center.x, offsetXSlider.center.y+40);
        
        [expandedViewOffset addSubview:offsetXSlider];
        [expandedViewOffset addSubview:offsetYSlider];
        
        [self.superView addSubview:expandedViewOffset];
        
        self.xSlider = offsetXSlider;
        self.ySlider = offsetYSlider;
        
        expandedView = expandedViewOffset;
    }

    
    return expandedView;
}



-(UIView*)makeExpandedView
{
    CGFloat expandedH = self.superView.bounds.size.height/4;
    CGRect colorControlRect = CGRectInset(self.superView.frame, 20, expandedH);
    UIView *colorController = [[UIView alloc]initWithFrame:colorControlRect];
    
    colorController.backgroundColor = [UIColor eggshellColor];
    colorController.layer.cornerRadius = 10;
    colorController.layer.masksToBounds = YES;
    colorController.layer.borderColor = [UIColor blackColor].CGColor;
    colorController.layer.borderWidth = 2.0;
    
    UISwipeGestureRecognizer *swipeDown = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(handleSwipeDown:)];
    swipeDown.direction = UISwipeGestureRecognizerDirectionDown;
    
    [colorController addGestureRecognizer:swipeDown];
    
    UISlider *slider = [self makeZSliderWithTitle:@"Z" withDefault:self.defaultVector.Z];
    
    [colorController addSubview:slider];
    
    
    [self.superView addSubview:colorController];
    
    self.zSlider = slider;
    
    return colorController;
    
}

-(UISlider*)makeZSliderWithTitle:(NSString*)sliderTitle withDefault:(CGFloat)defaultValue
{
    UIColor *trackTintColor = [UIColor blackColor];
    
    CGFloat sliderSize = (self.superView.bounds.size.width/3)*2;
    
    CGFloat x = (self.superView.bounds.size.width -40 )/2-sliderSize/2;
    
    UISlider *slider = [[UISlider alloc] initWithFrame:CGRectMake(x, 45, sliderSize, 30)];
    [slider addTarget:self action:@selector(handleZValueSlider:) forControlEvents:UIControlEventAllTouchEvents];
    
    slider.minimumTrackTintColor = trackTintColor;
    
    slider.minimumValue = 0;
    slider.maximumValue = 500;
    slider.value = defaultValue;
    
    CGRect labelRect = CGRectMake(0, -9, sliderSize, 13);
    
    UILabel *title = [[UILabel alloc]initWithFrame:labelRect];
    title.textAlignment = NSTextAlignmentCenter;
    title.font = [UIFont fontWithName:@"Helvetica" size:12];
    title.text = sliderTitle;
    [slider addSubview:title];
    
    UILabel *valueLabel = [[UILabel alloc]initWithFrame:labelRect];
    valueLabel.textAlignment = NSTextAlignmentRight;
    valueLabel.font = [UIFont fontWithName:@"Helvetica" size:12];
    valueLabel.text = [@"" stringByAppendingFormat:@"%.02f",slider.value];
    [slider addSubview:valueLabel];
    
    return slider;
}

#pragma mark -  Color Slider Changed
-(void)handleZValueSlider:(UISlider*)slider
{
    UILabel *label = (UILabel*)[slider.subviews objectAtIndex:1];
    label.text = [@"" stringByAppendingFormat:@"%.02f",slider.value];
    
    if (self.vectorType == VectorTypePosition3) {
        CGPoint convertedPoint = [self convertToCICoord: self.value];
        CGFloat scale = [UIScreen mainScreen].scale;
        
        CGFloat X = convertedPoint.x *scale;
        CGFloat Y = convertedPoint.y *scale;
        CGFloat Z = slider.value;
        
        
        self.inputVector = [CIVector vectorWithX:X Y:Y Z:Z];
        
        [self informDelegateOfNewValue];

    }
    
    if (self.vectorType == VectorTypeOffset) {
        
        self.value = CGPointMake(self.xSlider.value, self.ySlider.value);
        self.inputVector = [CIVector vectorWithCGPoint:self.value];
        [self informDelegateOfNewValue];

        
    }
    
}






#pragma mark - Dismiss
-(void)handleSwipeDown:(UISwipeGestureRecognizer*)swipeDownRec
{
    [self dissmissZControl];
}

#pragma mark - Offset Control Expanded Animations


-(void)expandZControl
{
    [self.superView addSubview:self.expandedView];
    
    [UIView animateWithDuration:0.75 delay:0 usingSpringWithDamping:0.65 initialSpringVelocity:0.72 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.expandedView.alpha = 1.0;
        self.expandedView.center = CGPointMake(RectGetCenter(self.superView.bounds).x, RectGetCenter(self.superView.bounds).y-self.superView.bounds.size.height/8);
        
    } completion:^(BOOL finished) {
        self.isExpanded = YES;
    }];
}

-(void)dissmissZControl
{
    CGRect centerRect = CGRectMake(200, 400, 1.0, 1.0);
    
    
    [UIView animateWithDuration:0.75 delay:0 usingSpringWithDamping:0.65 initialSpringVelocity:0.72 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        //
        self.expandedView.frame = centerRect;
        self.expandedView.alpha = 0.0;
        
        self.dotView.alpha = 0.0;
        self.touchView.alpha = 0.0;
        
        [self.delegate isEditing:NO];
        
        self.superView.backgroundColor = [UIColor orangeColor];
        self.buttonView.backgroundColor = [UIColor purpleColor];

        
        
    } completion:^(BOOL finished) {
        //
        [self.expandedView removeFromSuperview];
        [self.dotView removeFromSuperview];
        [self.touchView removeFromSuperview];

        self.isExpanded = NO;
    }];
}










#pragma mark - Inform Delegate
-(void)informDelegateOfNewValue
{
    [self.delegate didChangeVectorValueTo:self.inputVector forKeyValue:self.keyValue];
}



#pragma mark - Reset Call
-(void)cleanUpAndRemove
{

    CGAffineTransform transform = CGAffineTransformIdentity;
    
    CGAffineTransform rotate = CGAffineTransformRotate(transform, RadiansFromDegrees(-135));
    CGAffineTransform translate = CGAffineTransformTranslate(transform, -500, 500);

    
    [UIView animateWithDuration:0.2 delay:0 usingSpringWithDamping:0.45 initialSpringVelocity:0.72 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        //
        [self.delegate isEditing:NO];
        
        self.dotView.alpha=0;
        self.rectangleView.alpha = 0;
        
        [self.dotView removeFromSuperview];
        [self.rectangleView removeFromSuperview];
        [self.touchView removeFromSuperview];
        self.superView.backgroundColor = [UIColor orangeColor];
        //
        
        self.toneCurveViewControl.transform = CGAffineTransformConcat(rotate, translate);

        
        
    } completion:^(BOOL finished) {
        //
    }];
    
    
}




#pragma mark - ToneCurve Controller

-(UIView*)makeToneCurveController:(int)numberOfControls
{
    
    CGFloat inset = self.superView.bounds.size.height*0.10;
    
    CGRect toneControlRect = CGRectInset(CGRectMake(0, 0, self.superView.bounds.size.height, self.superView.bounds.size.height), inset, inset);
    
    UIView *toneControllerView = [[UIView alloc]initWithFrame:toneControlRect];
    
    toneControllerView.backgroundColor = [UIColor lightCreamColor];

    CAShapeLayer *gridLayer = [self makeGridLayerForView:toneControllerView withCount:numberOfControls];
    [toneControllerView.layer addSublayer:gridLayer];
    
    
    CAShapeLayer *graphLayer = [self makeGraphShapeLayer:[self getGraphPath]];
    [toneControllerView.layer addSublayer:graphLayer];
    
    self.graphLayer = graphLayer;
    
    CGPoint bottomCenter = CGPointMake(RectGetCenter(toneControlRect).x, RectGetCenter(toneControlRect).y+500);
    toneControllerView.alpha = 0.0;
    toneControllerView.center = bottomCenter;
    toneControllerView.transform = CGAffineTransformMakeRotation(RadiansFromDegrees(-135));

    return toneControllerView;

}

-(NSString*)isPointTouchingAControl:(CGPoint)point
{
    NSString *returnString = @"NO";
    
    CGPoint convertedPoint = [self.superView convertPoint:point toView:self.toneCurveViewControl];

    for (NSString *key in [self.toneCurveControlDots allKeys]) {
        
        UIView *controlView = [self.toneCurveControlDots valueForKey:key];
        
        CGRect largerRect = CGRectInset(controlView.frame, -12, -12);
        
        if (CGRectContainsPoint(largerRect, convertedPoint)) {
            
            returnString = key;
        }
        
    }
    
    return returnString;
}

-(UIView*)getControlViewBeingTouched:(CGPoint)touchPoint
{
    UIView *controlViewBeingTouched;
    
    for (NSString *key in [self.toneCurveControlDots allKeys]) {
        UIView *controlView = [self.toneCurveControlDots valueForKey:key];
        if (CGRectContainsPoint(controlView.frame, touchPoint)) {
            controlViewBeingTouched = controlView;
        }
    }
    
    return controlViewBeingTouched;
}


-(void)handleToneCurvePan:(UIPanGestureRecognizer*)pan
{
    
    CGPoint panLocation = [pan locationInView:self.superView];
    
    switch (pan.state) {
        case UIGestureRecognizerStateBegan:
            
            if (![[self isPointTouchingAControl:panLocation] isEqualToString:@"NO"]) {
                self.shouldDragDot = YES;
                self.keyToMove = [self isPointTouchingAControl:panLocation];
                [self toneControlSelected];
            }
            else
            {
                self.shouldDragDot = NO;
            }
            
            [self adjustToneControl:self.keyToMove withPoint:panLocation];
            
            
            break;
        case UIGestureRecognizerStateChanged:
            [self adjustToneControl:self.keyToMove withPoint:panLocation];

            break;
        case UIGestureRecognizerStateEnded:
            
             [self adjustToneControl:self.keyToMove withPoint:panLocation];
            [self toneControlDeSelected];
            break;
        default:
            break;
    }

}

-(void)toneControlSelected
{
    UIView *dotView = [self.toneCurveControlDots valueForKey:self.keyToMove];
    UIColor *selectedColor = [UIColor denimColor];
    
    [UIView animateWithDuration:0.25 delay:0 usingSpringWithDamping:0.65 initialSpringVelocity:0.73 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        dotView.backgroundColor = selectedColor;
        dotView.transform = CGAffineTransformMakeScale(1.25, 1.25);
    } completion:^(BOOL finished) {
        //
    }];
}

-(void)toneControlDeSelected
{
     UIView *dotView = [self.toneCurveControlDots valueForKey:self.keyToMove];
    UIColor *deSelectedColor = [UIColor darkGrayColor];
    
    [UIView animateWithDuration:0.25 delay:0 usingSpringWithDamping:0.65 initialSpringVelocity:0.73 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        dotView.backgroundColor = deSelectedColor;
        dotView.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
        //
    }];
}



-(void)updateForToneControl
{
    for (NSString *key in [self.toneCurveControlDots allKeys]) {
        UIView *dotView = [self.toneCurveControlDots valueForKey:key];
        CGPoint position = dotView.center;
        [self adjustToneControl:key withPoint:[self convertToCICoord:position]];
        
    }
}

-(void)adjustToneControl:(NSString*)controlKey withPoint:(CGPoint)point
{
    UIView *dot = [self.toneCurveControlDots valueForKey:controlKey];
    CGFloat yMax = self.toneCurveViewControl.bounds.size.height;
    CGFloat xMax = self.toneCurveViewControl.bounds.size.width;
    
    CGPoint convertedPoint = [self.superView convertPoint:point toView:self.toneCurveViewControl];
    
    CGPoint newCenter = CGPointMake(dot.center.x, convertedPoint.y);
    
    if (newCenter.y > yMax) {
        newCenter = CGPointMake(dot.center.x, yMax);
    }
    
    if (newCenter.y < 0) {
        newCenter = CGPointMake(dot.center.x, 0);

    }

    if (self.shouldDragDot) {
        dot.center = newCenter;
        
        NSString *keyValueString = [NSString stringWithFormat:@"inputPoint%@",controlKey];
        
        CGFloat newValue = RemappedValueInRangeDefinedByOldMinAndMaxToNewMinAndMax(newCenter.y, yMax, 0, 0, 1);
        CGFloat newValueX = RemappedValueInRangeDefinedByOldMinAndMaxToNewMinAndMax(newCenter.x, 0, xMax, 0, 1);
        
        self.inputVector = [CIVector vectorWithCGPoint:CGPointMake(newValueX, newValue)];
        self.keyValue = keyValueString;
        
        [self updateGraph];
        
        [self.delegate didChangeVectorValueTo:self.inputVector forKeyValue:self.keyValue];

    }
    
    
}



-(UIBezierPath*)getGraphPath
{
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    CGPoint firstPoint;

    for (int i=0; i<[[self.toneCurveControlDots allKeys] count]; i++) {
       
        UIView *controlView = [self.toneCurveControlDots valueForKey:[NSString stringWithFormat:@"%i",i]];
        
        if (i==0) {
            firstPoint = controlView.center;
            [path moveToPoint:controlView.center];
        }
        else
        {
            [path addLineToPoint:controlView.center];
        }
    }
    
   
    [path addLineToPoint:RectGetBottomRight(self.toneCurveViewControl.bounds)];
    [path addLineToPoint:RectGetBottomLeft(self.toneCurveViewControl.bounds)];
    [path addLineToPoint:firstPoint];
    
    
    return path;
}



-(void)updateGraph
{
    self.graphLayer.path =[self getGraphPath].CGPath;

}


-(CAShapeLayer*)makeGraphShapeLayer:(UIBezierPath*)path
{
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    shapeLayer.frame = self.toneCurveViewControl.bounds;
    
    shapeLayer.path = path.CGPath;
    shapeLayer.strokeColor = [UIColor orangeColor].CGColor;
    shapeLayer.fillColor = [UIColor clearColor].CGColor;
//    shapeLayer.borderColor = [UIColor whiteColor].CGColor;
//    shapeLayer.borderWidth = 0.5;
    shapeLayer.lineWidth = 4.0;
    
    
    return shapeLayer;

}

-(CAShapeLayer*)makeGridLayerForView:(UIView*)toneControllerView withCount:(int)wCount
{
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    shapeLayer.frame = toneControllerView.bounds;
    
    int lineCount = wCount -1;
    int hCount = lineCount;//8;
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    
    //draw vertical lines, then horizontal
    CGFloat gridWidth = toneControllerView.bounds.size.width/lineCount;
    CGFloat gridHeight = toneControllerView.bounds.size.height/hCount;
    CGFloat bottomY = toneControllerView.bounds.size.height;
    CGFloat endX = toneControllerView.bounds.size.width;
    
    
    //add horizontal lines first
    //draw left to right adding an amount to Y to move down each iteration
    
    for (int i=0; i<=hCount; i++) {
        [path moveToPoint:CGPointMake(0, i*gridHeight)];
        [path addLineToPoint:CGPointMake(endX, i*gridHeight)];
    }
    
    
    for (int i=0; i<=lineCount; i++) {
        [path moveToPoint:CGPointMake(i*gridWidth, 0)];
        [path addLineToPoint:CGPointMake(i*gridWidth, bottomY)];
    }

    
    shapeLayer.path = path.CGPath;
    shapeLayer.strokeColor = [UIColor steelBlueColor].CGColor;
    shapeLayer.lineWidth = 2.0;
    
    return shapeLayer;
}


-(UIView*)makeToneControlDot
{
    CGFloat viewSize = 25;
    
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, viewSize, viewSize)];
    
    view.layer.masksToBounds = YES;
    view.layer.cornerRadius = viewSize/2;
    view.layer.borderColor = [UIColor blackColor].CGColor;
    view.layer.backgroundColor = [UIColor darkGrayColor].CGColor;
    
    view.alpha=1.0;
    
    return view;
}



-(void)animateInToneViewControl
{
    
    [UIView animateWithDuration:0.75 delay:0 usingSpringWithDamping:0.65 initialSpringVelocity:0.72 options:UIViewAnimationOptionCurveEaseInOut animations:^{
    
        self.toneCurveViewControl.alpha = 1.0;
        self.toneCurveViewControl.center = RectGetCenter(self.superView.bounds);
        self.toneCurveViewControl.transform = CGAffineTransformIdentity;
        
    } completion:^(BOOL finished) {
    }];

}



#pragma mark - Helpers

// CoreImage coordinate system origin is at the bottom left corner and UIKit is at the top left corner
// So we need to translate features positions before drawing them to screen
// In order to do so we make an affine transform
// **Note**
// Its better to convert CoreImage coordinates to UIKit coordinates and
// not the other way around because doing so could affect other drawings


-(CGRect)convertRectToCICoordinates:(CGRect)uiRect
{
    CGRect ciRect;
    CGAffineTransform transform = CGAffineTransformMakeScale(1, -1);
    transform = CGAffineTransformTranslate(transform, 0, -self.imageEditingView.frame.size.height);
    
    ciRect = CGRectApplyAffineTransform(uiRect, transform);
    
    return ciRect;
}



-(CGPoint)convertToCICoord:(CGPoint)uiPoint
{
    CGAffineTransform transform = CGAffineTransformMakeScale(1, -1);
    transform = CGAffineTransformTranslate(transform, 0, -self.imageEditingView.frame.size.height);
    
    CGPoint convertedPoint = CGPointApplyAffineTransform(uiPoint, transform);
    return convertedPoint;
}


@end
