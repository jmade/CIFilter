//
//  JDMColorControlObject.m
//  CIFilter
//
//  Created by Justin Madewell on 11/22/15.
//  Copyright © 2015 Justin Madewell. All rights reserved.
//

#import "JDMColorControlObject.h"

@interface JDMColorControlObject ()

@property CGRect bounds;
@property UIView *superView;

@property UISlider *redSlider;
@property UISlider *greenSlider;
@property UISlider *blueSlider;
@property UISlider *alphaSlider;

@property UILabel *descriptionLabel;
@property UIView *expandedView;

@property UIView *buttonView;


@property NSString *colorTitle;
@property NSString *colorDescription;

@property CIColor *defaultCIColor;

@property CGFloat commonHeight;
@property BOOL isSliding;

@property UILabel *buttonLabel;


@end




@implementation JDMColorControlObject

-(id)initWithDelegate:(id<JDMColorControlObjectDelegate>)delegate inView:(UIView *)view withDefaultRed:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue andAlpha:(CGFloat)alpha withTitle:(NSString *)title description:(NSString *)description andKeyValue:(NSString *)keyValue
{
    self = [super init];
    if(self)
    {
        self.delegate = delegate;
        self.keyValue = keyValue;
        self.superView = view;
        self.colorTitle = title;
        self.colorDescription = description;
        self.defaultCIColor = [CIColor colorWithRed:red green:green blue:blue alpha:alpha];
        self.positionY = 20;
        
        
        [self setup];
    }
    return self;
}


-(void)updateButtonPosition:(CGFloat)buttonY
{
    [self updateLabelColor];
    
    // update the views colors
    [UIView animateWithDuration:0 animations:^{
        self.buttonView.center = CGPointMake(self.superView.center.x, buttonY);
    }];
    
    
}



-(void)setup
{
    // Set Defaults
    self.bounds = self.superView.bounds;
    
    self.color = [UIColor colorWithCIColor:self.defaultCIColor];
    
    [self makeExpandedView];
    self.buttonView =  [self makeColorControlButtonwithDisplayName:self.colorTitle];
    
    
    [self.superView addSubview:self.buttonView];
    self.buttonView.center = CGPointMake(self.superView.center.x, self.positionY);
    
    [self updateLabelColor];
    
    self.isSliding = NO;
}



-(void)makeExpandedView
{
    CIColor *ci_color = [CIColor colorWithCGColor:self.color.CGColor];
    
    self.expandedView = [self makeColorControlExpandedView];
    
    self.redSlider = [self makeColorSliderWithTitle:@"RED" withDefault:ci_color.red];
    self.greenSlider = [self makeColorSliderWithTitle:@"GREEN" withDefault:ci_color.green];
    self.blueSlider = [self makeColorSliderWithTitle:@"BLUE" withDefault:ci_color.blue];
    self.alphaSlider = [self makeColorSliderWithTitle:@"ALPHA" withDefault:ci_color.alpha];
    
    self.descriptionLabel = [self makeDescriptionLabel];
    
    [self.expandedView addSubview:self.redSlider];
    [self.expandedView addSubview:self.greenSlider];
    [self.expandedView addSubview:self.blueSlider];
    [self.expandedView addSubview:self.alphaSlider];
    [self.expandedView addSubview:self.descriptionLabel];
    
    // Layout Calculations
    self.commonHeight = 30;
    CGFloat multplyerY = self.commonHeight*1.5;
    
    CGFloat centerX = self.expandedView.frame.size.width/2;
    CGFloat centerY = multplyerY;
    
    // Set Positions
    self.redSlider.center = CGPointMake(centerX, centerY);
    self.greenSlider.center = CGPointMake(centerX, multplyerY*2);
    self.blueSlider.center = CGPointMake(centerX,(multplyerY*3));
    self.alphaSlider.center = CGPointMake(centerX, (multplyerY*4));
    self.descriptionLabel.center = CGPointMake(centerX, (multplyerY*5));
}




-(NSArray*)getAllLabels
{
    NSMutableArray *alllabels = [[NSMutableArray alloc]init];
    
        NSArray *sliders = @[self.redSlider,self.greenSlider,self.blueSlider,self.alphaSlider];
    
    for (UISlider *slider in sliders) {
        
        for (UILabel *label in slider.subviews) {
            if ([label class] == [UILabel class]) {
                [alllabels addObject:label];
            }
        }
    }
    
    [alllabels addObject:self.buttonLabel];
    [alllabels addObject:self.descriptionLabel];
   
    return alllabels;
}


-(void)updateLabelColor
{
    
    
    UIColor *newTextColor = textColorForColor(self.color);
    
    
    
    [UIView animateWithDuration:0 animations:^{
       
        for (UILabel *label in [self getAllLabels]) {
            label.textColor = newTextColor;
            self.buttonView.layer.borderColor = newTextColor.CGColor;
            self.expandedView.layer.borderColor = newTextColor.CGColor;
        }
        
    }];
    
}




#pragma mark - Make Color Control
-(UIView*)makeColorControlButtonwithDisplayName:(NSString*)colorDisplayName
{
    CGFloat widthValue = (self.bounds.size.width/3)*2;
    
    UIColor *color = [UIColor whiteColor];
    
    CGRect colorControlbuttonRect = CGRectMake(0, 0, widthValue, self.commonHeight*1.25);
    
    UIView *colorControlButtonView = [[UIView alloc]initWithFrame:colorControlbuttonRect];
    colorControlButtonView.backgroundColor = [UIColor colorWithCIColor:self.defaultCIColor];
    
    colorControlButtonView.layer.cornerRadius = colorControlbuttonRect.size.height/2;
    colorControlButtonView.layer.masksToBounds = YES;
    colorControlButtonView.layer.borderColor = color.CGColor;
    colorControlButtonView.layer.borderWidth = 2.0;
    
    UILabel *colorDisplayNameLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, widthValue, self.commonHeight)];
    colorDisplayNameLabel.textColor = color;
    colorDisplayNameLabel.textAlignment = NSTextAlignmentCenter;
    colorDisplayNameLabel.numberOfLines=1;
    colorDisplayNameLabel.text = colorDisplayName;
    colorDisplayNameLabel.center = colorControlButtonView.center;
    
    [colorControlButtonView addSubview:colorDisplayNameLabel];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleColorButtonTap)];
    [colorControlButtonView addGestureRecognizer:tap];
    
    self.buttonLabel = colorDisplayNameLabel;
    
    return colorControlButtonView;
}

-(UILabel*)makeDescriptionLabel
{
    CGFloat labelSize = self.bounds.size.width*0.80;
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0 , 0 , labelSize, self.commonHeight*2)];
    label.textAlignment = NSTextAlignmentCenter;
    label.lineBreakMode = NSLineBreakByWordWrapping;
    label.numberOfLines=0;
    
    label.text = self.colorDescription;
    
    return label;
}




#pragma mark - Make Color Slider
-(UISlider*)makeColorSliderWithTitle:(NSString*)sliderTitle withDefault:(CGFloat)defaultValue
{
    UIColor *trackTintColor = [UIColor blackColor];
    
    if ([sliderTitle isEqualToString:@"RED"]) {
        trackTintColor = [UIColor redColor];
    }
    
    if ([sliderTitle isEqualToString:@"BLUE"]) {
        trackTintColor = [UIColor blueColor];
    }
    
    if ([sliderTitle isEqualToString:@"GREEN"]) {
        trackTintColor = [UIColor greenColor];
    }
    
    if ([sliderTitle isEqualToString:@"ALPHA"]) {
        trackTintColor = [UIColor grayColor];
    }
    
    CGFloat sliderSize = (self.bounds.size.width/3)*2;
    
    UISlider *slider = [[UISlider alloc] initWithFrame:CGRectMake(0 , 0 , sliderSize, self.commonHeight)];
    [slider addTarget:self action:@selector(handleColorSlider:) forControlEvents:UIControlEventAllTouchEvents];
    
    slider.minimumTrackTintColor = trackTintColor;
    
    slider.minimumValue = 0;
    slider.maximumValue = 1;
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
-(void)handleColorSlider:(UISlider*)slider
{
    
    
    
    
    UILabel *label = (UILabel*)[slider.subviews objectAtIndex:1];
    label.text = [@"" stringByAppendingFormat:@"%.02f",slider.value];
    
    CIColor *currentColor = [CIColor colorWithRed:self.redSlider.value green:self.greenSlider.value blue:self.blueSlider.value alpha:self.alphaSlider.value];
    [self.delegate didChangeColor:currentColor forKeyValue:self.keyValue];
    self.color = [UIColor colorWithCIColor:currentColor];
    
    [self updateLabelColor];
    
    // update the views colors
    [UIView animateWithDuration:0 animations:^{
        self.expandedView.backgroundColor = self.color;
        self.buttonView.backgroundColor = self.color;
       
    }];
}



-(void)handleColorButtonTap
{
    [self expandColorControl];
}


#pragma mark - Make Color Control

-(UIView*)makeColorControlExpandedView
{
    CGRect colorControlRect = CGRectInset(self.superView.frame, 20, 20);
    UIView *colorController = [[UIView alloc]initWithFrame:colorControlRect];
    
    colorController.backgroundColor = self.color;
    colorController.layer.cornerRadius = 10;
    colorController.layer.masksToBounds = YES;
    colorController.layer.borderColor = [UIColor blackColor].CGColor;
    colorController.layer.borderWidth = 2.0;
    
    UISwipeGestureRecognizer *swipeDown = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(handleSwipeDown:)];
    swipeDown.direction = UISwipeGestureRecognizerDirectionDown;
    
    [colorController addGestureRecognizer:swipeDown];
    
    return colorController;
    
}



#pragma mark - Dismiss
-(void)handleSwipeDown:(UISwipeGestureRecognizer*)swipeDownRec
{
    [self dissmissColorControl];
}

#pragma mark - Color Control Expanded Animations


-(void)expandColorControl
{
    [self makeExpandedView];
    [self.superView addSubview:self.expandedView];
    
    [UIView animateWithDuration:0.75 delay:0 usingSpringWithDamping:0.65 initialSpringVelocity:0.72 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.expandedView.alpha = 1.0;
        self.expandedView.center = RectGetCenter(self.superView.bounds);
        [self updateLabelColor];
        
    } completion:^(BOOL finished) {
        //
    }];
}

-(void)dissmissColorControl
{
    CGRect centerRect = CGRectMake(200, 400, 1.0, 1.0);
    
    [UIView animateWithDuration:0.75 delay:0 usingSpringWithDamping:0.65 initialSpringVelocity:0.72 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        //
        self.expandedView.frame = centerRect;
        self.expandedView.alpha = 0.0;
        
    } completion:^(BOOL finished) {
        //
        [self.expandedView removeFromSuperview];
    }];
}




-(void)cleanUpAndRemove
{
    
}





/* 
 
  */








@end
