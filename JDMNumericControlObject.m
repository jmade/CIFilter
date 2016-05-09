//
//  JDMNumericControlObject.m
//  CIFilter
//
//  Created by Justin Madewell on 11/22/15.
//  Copyright © 2015 Justin Madewell. All rights reserved.
//

#import "JDMNumericControlObject.h"


@interface JDMNumericControlObject ()

@property UIView *superView;
@property UISlider *slider;
@property NSString *title;
@property CGFloat min;
@property CGFloat max;
@property CGFloat def;



@end

@implementation JDMNumericControlObject


-(id)initWithDelegate:(id<JDMNumericControlObjectDelegate>)delegate inView:(UIView *)view withTitle:(NSString *)title withMin:(CGFloat)min andMax:(CGFloat)max withDefault:(CGFloat)defaultValue andKeyValue:(NSString *)keyValue
{
    self = [super init];
    if(self)
    {
        self.delegate = delegate;
        self.superView = view;
        self.min = min;
        self.max = max;
        self.def = defaultValue;
        self.title = title;
        self.keyValue = keyValue;
        
        
        [self setup];
    }
    return self;
}

-(void)updateYPosition:(CGFloat)positionY
{
    // update the views colors
    [UIView animateWithDuration:0 animations:^{
        self.slider.center = CGPointMake(self.superView.center.x, positionY);
    }];

    
}


-(void)setup
{
    self.slider = [self makeSlider];
    self.slider.center = CGPointMake(self.superView.center.x, 20);
    [self.superView addSubview:self.slider];
    
}


-(UISlider*)makeSlider
{
    CGFloat sliderFrameH = 30;
    CGFloat sliderFrameW = self.superView.frame.size.width * 0.75;
    
    UISlider *slider = [[UISlider alloc] initWithFrame:CGRectMake(0,0, sliderFrameW, sliderFrameH)];
    
    [slider addTarget:self action:@selector(handleSlider:) forControlEvents:UIControlEventAllTouchEvents];
    
    slider.minimumTrackTintColor = [UIColor blackColor];
    
    slider.minimumValue = self.min;
    slider.maximumValue = self.max;
    slider.value = self.def;
    
    CGRect labelRect = CGRectMake(0, -10, sliderFrameW, 13);
    
    UILabel *sliderTitle = [[UILabel alloc]initWithFrame:labelRect];
    sliderTitle.textAlignment = NSTextAlignmentCenter;
    sliderTitle.font = [UIFont fontWithName:@"Helvetica" size:12];
    sliderTitle.text = self.title;
    [slider addSubview:sliderTitle];
    
    UILabel *valueLabel = [[UILabel alloc]initWithFrame:labelRect];
    valueLabel.textAlignment = NSTextAlignmentRight;
    valueLabel.font = [UIFont fontWithName:@"Helvetica" size:12];
    valueLabel.text = [@"" stringByAppendingFormat:@"%.02f",slider.value];
    [slider addSubview:valueLabel];

    return slider;
}


-(void)handleSlider:(UISlider*)slider
{
    UILabel *label = (UILabel*)[slider.subviews objectAtIndex:1];
    label.text = [@"" stringByAppendingFormat:@"%.02f",slider.value];
    
    CGFloat newValue = slider.value;
    
    [self.delegate didChangeNumericValueTo:@(newValue) forKeyValue:self.keyValue];
    
}



-(void)cleanUpAndRemove
{
    
}




@end
