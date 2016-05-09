//
//  JDMBarCodeControlObject.m
//  CIFilter
//
//  Created by Justin Madewell on 12/7/15.
//  Copyright © 2015 Justin Madewell. All rights reserved.
//

#import "JDMBarCodeControlObject.h"

@interface JDMBarCodeControlObject ()

@property UIView *superView;
@property NSString *filterName;
@property NSDictionary *inputParams;

@property UITextView *textView;
@property UISlider *correctionSlider;
//@property UILabel *textFieldLabel;

@end

@implementation JDMBarCodeControlObject

-(id)initWithDelegate:(id<JDMBarCodeControlObjectDelegate>)delegate inView:(UIView *)view withInputParams:(NSDictionary *)inputParams withFilterName:(NSString *)filterName
{
    self = [super init];
    if(self)
    {
        self.delegate = delegate;
        self.superView = view;
        self.filterName = filterName;
        self.inputParams = inputParams;
        
        [self setup];
    }
    return self;
}

-(void)setup
{
    if ([self.filterName isEqualToString:@"CIQRCodeGenerator"]) {
        [self setupForQR];
       
    } else if ([self.filterName isEqualToString:@"CIAztecCodeGenerator"]) {
        [self setupForAztec];
        
    } else if ([self.filterName isEqualToString:@"CICode128BarcodeGenerator"]) {
        [self setupForCode128];
    }

    [self updateInputMessage:@"Setup Complete"];
}


-(void)setupForQR
{
    NSLog(@"Its QR");
     self.textView  = [self makeTextView];
    [self.superView addSubview:self.textView];
    [self makeSubmitButton];
    [self makeUISlider];
}



-(UITextView*)makeTextView
{
    CGFloat w = self.superView.bounds.size.width * 0.75;
    CGFloat h = 40;
    CGRect frame = CGRectMake(0, 0, w, h);
    
    UITextView *textView = [[UITextView alloc]initWithFrame:frame];
    textView.layer.masksToBounds = YES;
    textView.layer.cornerRadius = 8;
    
    textView.center = CGPointMake(self.superView.center.x, 28);
    textView.delegate = self;
    textView.scrollEnabled = NO;
    
    
   
    textView.textAlignment = NSTextAlignmentCenter;
    
    textView.font = [UIFont systemFontOfSize:24];
    
    // Enable auto-correction and Spellcheck
    textView.autocapitalizationType = UITextAutocapitalizationTypeAllCharacters;
    textView.spellCheckingType = UITextSpellCheckingTypeNo;
    textView.autocorrectionType = UITextAutocorrectionTypeNo;

    return textView;

}

-(void)makeSubmitButton
{
    CGFloat  size = 40;
    
    CGFloat centerX = self.superView.bounds.size.width/2;
    CGFloat halftextview = (self.superView.bounds.size.width * 0.75)/2;
    
    CGFloat frameX = centerX + halftextview+ 4 ;
    CGRect frame = CGRectMake(frameX,8, size*1.1, size);
    
    UILabel *submitLabel = [[UILabel alloc]initWithFrame:frame];
    submitLabel.textAlignment = NSTextAlignmentCenter;
    submitLabel.text = @"QR!";
    submitLabel.textColor = [UIColor whiteColor];
    submitLabel.backgroundColor = [UIColor blueColor];
    submitLabel.layer.masksToBounds = YES;
    submitLabel.layer.cornerRadius = 8;
    submitLabel.userInteractionEnabled = YES;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleGOTap:)];
    [submitLabel addGestureRecognizer:tap];
    
    [self.superView addSubview:submitLabel];
    
    
    
}

-(void)handleGOTap:(UITapGestureRecognizer*)tap
{
    [self.textView resignFirstResponder];
}


-(void)makeUISlider
{
    self.correctionSlider = [self makeSliderForQR];
    [self.superView addSubview:self.correctionSlider];
    
    self.correctionSlider.center = CGPointMake(self.superView.bounds.size.width/2, 100);
}

-(UISlider*)makeSliderForQR
{
    CGFloat sliderFrameH = 30;
    CGFloat sliderFrameW = self.superView.frame.size.width * 0.75;
    
    UISlider *slider = [[UISlider alloc] initWithFrame:CGRectMake(0,0, sliderFrameW, sliderFrameH)];
    
    [slider addTarget:self action:@selector(handleQRSlider:) forControlEvents:UIControlEventAllTouchEvents];
    
    slider.minimumTrackTintColor = [UIColor blackColor];
    
    slider.minimumValue = 0;
    slider.maximumValue = 3;
    slider.value = 1;
    
    CGRect labelRect = CGRectMake(0, -10, sliderFrameW, 13);
    
    UILabel *sliderTitle = [[UILabel alloc]initWithFrame:labelRect];
    sliderTitle.textAlignment = NSTextAlignmentCenter;
    sliderTitle.font = [UIFont fontWithName:@"Helvetica" size:12];
    sliderTitle.text = @"Correction Level";
    [slider addSubview:sliderTitle];
    
    UILabel *valueLabel = [[UILabel alloc]initWithFrame:labelRect];
    valueLabel.textAlignment = NSTextAlignmentRight;
    valueLabel.font = [UIFont fontWithName:@"Helvetica" size:12];
    valueLabel.text = [@"" stringByAppendingFormat:@"%.02f",slider.value];
    [slider addSubview:valueLabel];
    
    return slider;
}


-(void)handleQRSlider:(UISlider*)slider
{
    UILabel *label = (UILabel*)[slider.subviews objectAtIndex:1];
    label.text = [@"" stringByAppendingFormat:@"%.02f",slider.value];
    
    int sliderValue = slider.value;
    
    NSString *qualityLevelString = @"M";
    
     // "QRCode correction level L, M, Q, or H.";
    
    switch (sliderValue) {
        case 0:
            qualityLevelString = @"L";
            break;
        case 1:
            qualityLevelString = @"M";
            break;
        case 2:
            qualityLevelString = @"Q";
            break;
        case 3:
            qualityLevelString = @"H";
            break;
            
        default:
            break;
    }
    
    label.text = qualityLevelString;
    
    
        
    
    [self.inputParams setValue:qualityLevelString forKey:@"inputCorrectionLevel"];
    [self.delegate didChangeBarCorrectionLevelTo:qualityLevelString forKeyValue:@"inputCorrectionLevel"];
    
}




-(void)setupForAztec
{
    
}

-(void)setupForCode128
{
    
}



#pragma mark - Text Feild Delegate

-(BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    return YES;
}

-(BOOL)textViewShouldEndEditing:(UITextView *)textView
{
    return YES;
}

-(void)textViewDidBeginEditing:(UITextView *)textView
{
    [textView selectAll:textView];
}

-(void)textViewDidEndEditing:(UITextView *)textView
{
    [self updateInputMessage:textView.text];
}





#pragma mark - Update Delegate
-(void)updateInputMessage:(NSString*)newMessage
{
     NSData *data = [newMessage dataUsingEncoding:NSUTF8StringEncoding];
    
    [self.delegate didChangeBarCodeValueTo:data forKeyValue:@"inputMessage"];
}


@end
