//
//  ViewController.m
//  CIFilter
//
//  Created by Justin Madewell on 11/15/15.
//  Copyright © 2015 Justin Madewell. All rights reserved.
//

#import "ViewController.h"
#import "JDMUtility.h"
@import GLKit;
@import OpenGLES;





@interface ViewController ()
@property CALayer *filterLayer;



@property JDMCIControllerObject *controller;
@property UITableView *tableView;
@property UISearchBar *mySearchBar;
@property UIImageView *imageView;
@property UIImageView *backingBlurView;
@property UIView *controllerView;

@property UIImage *image;
@property UIImage *editImage;
@property UIImage *fullsizeImage;


@property EAGLContext *_eaglContext;
@property CIContext *_cictx;
@property GLKView *_viewForImage;

@property CGRect scrollingRectForTableView;
@property CGRect scrollingRectForImageView;
@property CGRect glkViewRect;
@property CGRect controllerViewRect;
@property CGRect searchBarRect;



@property BOOL isEditing;
@property BOOL isSearching;

@property NSMutableArray *searchedResults;


@property NSMutableDictionary *allClassTypes;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self calculateRects];
    [self buildViews];
 }

-(void)calculateRects
{
    // image config
    [self configureImage:[UIImage imageNamed:@"duckling"]];
    
    // two modes,
    
    // scrolling -- table view is going to be 2/3 the screen height and image view will be 1/3-20 and start right under the status bar
    CGFloat statusBarOffset = 20;
    CGFloat searchBarHeight = 0;//40;
    
    CGFloat padding = 8;
    
    CGFloat offsetY = (self.view.frame.size.height/3)-statusBarOffset;
    _scrollingRectForTableView = CGRectMake(0, offsetY, self.view.frame.size.width, self.view.frame.size.height-offsetY);
    
    _scrollingRectForImageView = CGRectMake(0, (statusBarOffset+searchBarHeight), self.view.frame.size.width,  _scrollingRectForTableView.origin.y-(statusBarOffset+searchBarHeight+padding));
    
    // editing -- tableview is hidden and the controls view is posisitoned on top of it
    _glkViewRect = CGRectMake(0, 0, self.view.frame.size.width,self.view.frame.size.width);
    _controllerViewRect = CGRectMake(0, self.view.frame.size.width,self.view.frame.size.width , self.view.frame.size.height-self.view.frame.size.width);

    _searchBarRect = CGRectMake(0, statusBarOffset, self.view.frame.size.width, searchBarHeight);
    
}





#pragma mark - Build Views

-(void)buildViews
{
    self.isEditing = NO;
    // Init the controller object
    self.controller = [[JDMCIControllerObject alloc]initWithDelegate:self];
   
    [self setupBackingBlur];
    [self setupImageView];
    [self setupTableView];
    // [self setupSearchBar];
    
    [self setupControllerView];
    [self setupGLContext];
    
    
}

-(void)setupTableView
{
    
    UITableView *tv = [[UITableView alloc]initWithFrame:_scrollingRectForTableView];
    tv.dataSource = self;
    tv.delegate = self;
    [tv registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
    [self.view addSubview:tv];
    
    self.tableView = tv;
}


-(void)setupSearchBar
{
    
    UISearchBar *searchBar = [[UISearchBar alloc]initWithFrame:_searchBarRect];
    searchBar.delegate = self;
    searchBar.placeholder = @"Search Here...";
    
    searchBar.backgroundImage = ImageGetTransparentImage();
    searchBar.scopeBarBackgroundImage = ImageGetTransparentImage();

    
    [self.view addSubview:searchBar];
    self.mySearchBar = searchBar;
}


-(void)setupImageView
{
    UIImageView *imgView = [[UIImageView alloc]initWithFrame:_scrollingRectForImageView];
    
    [imgView.layer setMasksToBounds:NO ];
    [imgView.layer setShadowColor:[[UIColor blackColor ] CGColor ] ];
    [imgView.layer setShadowOpacity:0.65 ];
    [imgView.layer setShadowRadius:6.0 ];
    [imgView.layer setShadowOffset:CGSizeMake( 0 , 0 ) ];

    imgView.image = self.image;
    
    [self.view addSubview:imgView];
    
    imgView.contentMode = UIViewContentModeScaleAspectFit;
    
    self.imageView = imgView;
}

-(void)setupControllerView
{
    
    UIView *view = [[UIView alloc]initWithFrame:_controllerViewRect];
    view.backgroundColor = [UIColor orangeColor];
    view.alpha = 0;
    [self.view addSubview:view];
    [view setHidden:YES];
    
    self.controllerView = view;
}


-(void)setupGLContext
{
    __eaglContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    __viewForImage = [[GLKView alloc] initWithFrame:_glkViewRect context:__eaglContext];
    __cictx = [CIContext contextWithEAGLContext:__eaglContext options:@{kCIContextWorkingColorSpace: [NSNull null]}];
    
    [__viewForImage setEnableSetNeedsDisplay:NO];
    
    [[self view] addSubview:__viewForImage];
    
    [self loadImageIntoEAGLContext];
    
    __viewForImage.alpha = 0;
    [__viewForImage setHidden:YES];
}

-(void)setupBackingBlur
{
    UIImageView *backingBlurView = [[UIImageView alloc]initWithFrame:self.view.frame];
    UIImage *image = self.image;
    UIImage *blurredImage = [image applyLightEffect];
    backingBlurView.image = blurredImage;
    [self.view addSubview:backingBlurView];
    
    self.backingBlurView = backingBlurView;
}




#pragma mark - Controller Object Delegate

-(void)didUpdateInputParameters:(NSDictionary *)newParameters
{
    // Make the Filter
    CIFilter *filter = [CIFilter filterWithName:self.controller.filterName withInputParameters:newParameters];// A filter that is available in iOS or a custom one :)
    
    CIImage *image = [CIImage imageWithCGImage:[self.editImage CGImage]];
    
    CIImage *resultImage = [filter valueForKey:kCIOutputImageKey];
    
    [__viewForImage bindDrawable];
    
    if (__eaglContext != [EAGLContext currentContext]) {
        [EAGLContext setCurrentContext:__eaglContext];
    }
    
    //glClearColor(0.5, 0.5, 0.5, 1.0);
    
    glClearColor(0.0, 0.0, 0.0, 0.0);
    
    glClear(GL_COLOR_BUFFER_BIT);
    glEnable(GL_BLEND);
    glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA);
    
    CGRect extentRect = [image extent];
    
    if (CGRectIsInfinite(extentRect) || CGRectIsEmpty(extentRect)) {
        extentRect = __viewForImage.bounds;

    }
    
    if ([self.controller.filterName isEqualToString:@"CIQRCodeGenerator"] || [self.controller.filterName isEqualToString:@"CIAztecCodeGenerator"]) {
        CGAffineTransform scaleTransform = CGAffineTransformMakeScale(54, 54); // Scale by 5 times along both dimensions
        
      
        
        
        resultImage = [resultImage imageByApplyingTransform: scaleTransform];
    }

    
    if ([self.controller.filterName isEqualToString:@"CIPDF417BarcodeGenerator"] || [self.controller.filterName isEqualToString:@"CICode128BarcodeGenerator"] ) {
        
        CGAffineTransform scaleTransform = CGAffineTransformMakeScale(5, 5); // Scale by 5 times
        resultImage = [resultImage imageByApplyingTransform: scaleTransform];

    }
    

    
    
    [__cictx drawImage:resultImage inRect:CGRectMake(0.0, 0.0,__viewForImage.drawableWidth,__viewForImage.drawableHeight) fromRect:extentRect];
    [__viewForImage display];

}

-(void)nsHipsterCIFilter
{
    UIImage *originalImage = self.fullsizeImage;
    
    CIImage *inputImage = [[CIImage alloc] initWithImage:originalImage];
    CIImage *outputImage = nil;
    
    CGAffineTransform transform = CGAffineTransformIdentity;
    CIFilter *clampFilter = [CIFilter filterWithName:@"CIAffineClamp"];
    [clampFilter setDefaults];
    [clampFilter setValue:[NSValue valueWithBytes:&transform objCType:@encode(CGAffineTransform)] forKeyPath:@"inputTransform"];
    [clampFilter setValue:inputImage forKeyPath:kCIInputImageKey];
    outputImage = [clampFilter outputImage];
    
    //CGFloat darkness = 0.5f;
    CIFilter *blackColorGenerator = [CIFilter filterWithName:@"CIConstantColorGenerator"];
    CIColor *blackColor = [CIColor colorWithCGColor:[UIColor black50PercentColor].CGColor];
    [blackColorGenerator setValue:blackColor forKey:kCIInputColorKey];
    
    CIFilter *compositeFilter = [CIFilter filterWithName:@"CIDarkenBlendMode"];
    [compositeFilter setDefaults];
    [compositeFilter setValue:[blackColorGenerator outputImage] forKey:kCIInputImageKey];
    [compositeFilter setValue:outputImage forKey:kCIInputBackgroundImageKey];
    outputImage = [compositeFilter outputImage];
    
    CGFloat radius = 2.0f;
    CIFilter *blurFilter = [CIFilter filterWithName:@"CIGaussianBlur"];
    [blurFilter setDefaults];
    [blurFilter setValue:@(radius) forKey:kCIInputRadiusKey];
    [blurFilter setValue:outputImage forKey:kCIInputImageKey];
    outputImage = [blurFilter outputImage];
    
    CIContext *context = [CIContext contextWithOptions:nil];
    CGImageRef imageRef = [context createCGImage:outputImage fromRect:inputImage.extent];
    
    UIImage *filteredImage = [UIImage imageWithCGImage:imageRef];
    
    
    
    CFRelease(imageRef);
}

-(void)saveHighResImageWithParameters:(NSDictionary *)inputParameters
{
    NSMutableDictionary *mutableCopyOfInputParameters = [NSMutableDictionary dictionaryWithDictionary:inputParameters];
    
    UIImage *originalImage = self.fullsizeImage;
    CIImage *inputImage = [[CIImage alloc] initWithImage:originalImage];
    CIImage *outputImage = nil;
    
    for (NSString *key in [mutableCopyOfInputParameters allKeys]) {
        if ([key isEqualToString:kCIInputImageKey]) {
            [mutableCopyOfInputParameters setValue:inputImage forKey:kCIInputImageKey];
        }
    }
    
    // Make the Filter
    
    CIFilter *filter = [CIFilter filterWithName:self.controller.filterName withInputParameters:mutableCopyOfInputParameters];// A filter that is available in iOS or a custom one :)
    outputImage = [filter outputImage];
    
    CIContext *context = [CIContext contextWithOptions:nil];
    
    CGRect extent = inputImage.extent;
    
    if ([self.controller.filterName isEqualToString:@"CIQRCodeGenerator"]) {
        outputImage = [outputImage imageByApplyingTransform:CGAffineTransformMakeScale(54, 54)];
        extent = CGRectMake(0, 0, 1242, 1242);
        
    }
    
    CGImageRef imageRef = [context createCGImage:outputImage fromRect:extent];
    
    UIImage *filteredImage = [UIImage imageWithCGImage:imageRef];

    [self saveImage:filteredImage];
    self.fullsizeImage = filteredImage;
    
    CFRelease(imageRef);
    

}

-(void)loadImageIntoEAGLContext
{
    CIImage *image = [CIImage imageWithCGImage:[self.editImage CGImage]];
    
    [__viewForImage bindDrawable];
    
    [__cictx drawImage:image inRect:CGRectMake(0.0, 0.0,__viewForImage.drawableWidth,__viewForImage.drawableHeight) fromRect:[image extent]];
    
    [__viewForImage display];
    

}




#pragma mark - TableView

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
   NSString *cellStringHit = [[self.controller.cellSections objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    
  
    
   
    
    [self performAnimation];
    
    
    
    [self.controller loadView:self.controllerView editingView:__viewForImage withControlsForFilter:cellStringHit withImage:self.editImage];
    
   [self.mySearchBar resignFirstResponder];
}


#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return self.controller.cellSectionTitles.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.isSearching == YES) {
        return self.searchedResults.count;
    } else {
        return [[self.controller.cellSections objectAtIndex:section] count];
    }
    
    
    
    

}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
   return [self.controller.cellSectionTitles objectAtIndex:section];
}


-(CGFloat)tableView:(UITableView *)tableView estimatedHeightForHeaderInSection:(NSInteger)section
{
    return 30;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    
    [self configureCell:cell forRowAtIndexPath:indexPath];
    
    return cell;
}

- (void)configureCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.isSearching == YES) {
        cell.textLabel.text = [self.searchedResults objectAtIndex:indexPath.row];
    } else {
        
        cell.textLabel.text = [[self.controller.cellSections objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    }
}


#pragma mark - Section Index
- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    return [self.controller makeSectionIndexArray];
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
    
    [tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:index] atScrollPosition:UITableViewScrollPositionTop animated:YES];
    
    return index;
}




#pragma mark UISearchBar Delegate Methods
-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    self.isSearching = NO;
    self.mySearchBar.text = @"";

    [self.mySearchBar resignFirstResponder];
    [searchBar resignFirstResponder];
    [self.tableView reloadData];
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
}




- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar
{
    return YES;
}


-(BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
     return YES;
}



-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [self.mySearchBar resignFirstResponder];
}



-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    
    if (searchText.length == 0) {
        self.isSearching = NO;
    }
    else {
        self.isSearching = YES;
        
        self.searchedResults = [[NSMutableArray alloc]init];
        
        for (NSString * filterName in self.controller.cellData)
        {
            NSRange filterNameRange = [filterName rangeOfString:searchText options:NSCaseInsensitiveSearch];
            
            if (filterNameRange.location != NSNotFound)
            {
                [self.searchedResults addObject:filterName];
            }
        }
        
    }
    
    [self.tableView reloadData];
}

















#pragma mark - Animations

-(void)performAnimation
{
    static int decider;
    
    if (decider == 0) {
        // Do something here...
        [self animateToImageEditMode];
        decider++;
        return;
    }
    else
    {
        // Do something else here...
        [self animateToScrollFiltersMode];
        decider--;
        return;
    }

}



#pragma mark - Animate to Edit Mode
-(void)animateToImageEditMode
{
    
    [self.controllerView setHidden:NO];
    [__viewForImage setHidden:NO];
    
    
    [UIView animateWithDuration:0.75 delay:0 usingSpringWithDamping:0.65 initialSpringVelocity:0.74 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.tableView.alpha = 0;
        self.imageView.alpha = 0;
        self.mySearchBar.alpha = 0;
        
        self.controllerView.alpha = 1.0;
        __viewForImage.alpha = 1.0;
        
        } completion:^(BOOL finished) {
            
        [self.tableView setHidden:YES];
        [self.imageView setHidden:YES];
            [self.mySearchBar setHidden:YES];
        self.isEditing = YES;
    }];
    
    
    
}


#pragma mark - Animate to scroll Filters Mode

-(void)animateToScrollFiltersMode
{
    
    if (self.controller.shouldKeepEditedImage) {
        NSLog(@"Should Keep edited Image");
        [self saveEditedImage];
        [self saveFullSizedImage];
    }
    else
    {
        NSLog(@"Return to normal");
    }
    
    
    [self.controller reset];
    [self.tableView setHidden:NO];
    [self.imageView setHidden:NO];
    [self.mySearchBar setHidden:NO];
    [self.tableView reloadData];
    
    [UIView animateWithDuration:0.75 delay:0 usingSpringWithDamping:0.65 initialSpringVelocity:0.74 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        
        self.tableView.alpha = 1.0;
        self.imageView.alpha = 1.0;
        self.mySearchBar.alpha = 1.0;
        
        self.controllerView.alpha = 0;
        __viewForImage.alpha = 0;

      
    } completion:^(BOOL finished) {
        [self.controllerView setHidden:YES];
        [__viewForImage setHidden:YES];
        self.isEditing = NO;
    }];

}

-(void)saveFullSizedImage
{
    [self saveHighResImageWithParameters:self.controller.inputParamaters];
}


-(void)configureImage:(UIImage*)image
{
    self.fullsizeImage = image;
    
    
    
   
    
    UIImage *resizedImage;
    
    if (image.size.width > image.size.height) {
        //NSLog(@"Wider");
        resizedImage = [image resizedImageByWidth:(int)self.view.frame.size.width];
    }
    else
    {
        //NSLog(@"Taller");
        resizedImage = [image resizedImageByHeight:(int)self.view.frame.size.width];
    }
    
    NSString *resizeString = [NSString stringWithFormat:@"%ix%i#",(int)self.view.frame.size.width,(int)self.view.frame.size.width];
    
    UIImage *editResizedImage = [image resizedImageByMagick:resizeString];
    self.editImage = editResizedImage;
    NSLog(@"self.editImage.size: %@",NSStringFromCGSize(self.editImage.size));
    
    
    UIImage *blurredImage = [image applyLightEffect];
    

    
    
    self.image = resizedImage;
    self.imageView.image = self.image;
    self.backingBlurView.image = blurredImage;
    
   
    
    
}

-(void)saveEditedImage
{
    UIImage *newEditedImage = [self.controller getEditedImage];
    UIImage *newBlurredImage = [newEditedImage applyLightEffect];
    
    self.image = newEditedImage;
    self.imageView.image = self.image;
    self.backingBlurView.image = newBlurredImage;
    self.editImage = self.image;
}


#pragma mark - Touches

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    CGPoint touchedPoint = [[touches anyObject] locationInView:self.view];
    
    
    if (self.isEditing) {
        if (CGRectContainsPoint(__viewForImage.frame, touchedPoint)) {
            if (self.controller.isEditingOnImageView) {
                
            }
            else
            {
                [self performAnimation];
            }

        }
    }
    else
    {
        if (CGRectContainsPoint(self.imageView.frame, touchedPoint)) {
            [self chooseImage];
            
        }
    }
    
    
    
}




#pragma mark - Image Picker

-(void)chooseImage
{
    UIImagePickerController *imagePicker =
    [[UIImagePickerController alloc] init];
    
    imagePicker.delegate = self;
    
    imagePicker.sourceType =
    UIImagePickerControllerSourceTypePhotoLibrary;
    
    //    imagePicker.mediaTypes =
    //    @[(NSString *) kUTTypeImage,
    //      (NSString *) kUTTypeMovie];
    
    imagePicker.allowsEditing = YES;
    [self presentViewController:imagePicker
                       animated:YES completion:nil];
}



-(void)imagePickerController:
(UIImagePickerController *)picker
didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    // Code here to work with media
    [self dismissViewControllerAnimated:YES completion:nil];
    
    NSLog(@"Got New Image");
    [self configureImage:info[UIImagePickerControllerEditedImage]];
    
}

-(void)imagePickerControllerDidCancel:
(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}


-(void)saveImage:(UIImage*)image
{
    UIImageWriteToSavedPhotosAlbum(image, self,@selector(image:didFinishSavingWithError:contextInfo:),nil);
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    UIAlertView *alert;
    
    // Unable to save the image
    if (error) {
        alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                           message:@"Unable to save image to Photo Album."
                                          delegate:self cancelButtonTitle:@"Ok"
                                 otherButtonTitles:nil];
    }else {// All is well
        NSLog(@"Image Saved!");
    }
}

-(void)savedImageToAlbums
{
    //  NSLog(@"Image Saved!");
}














-(void)doNewShineStuff
{
    CIImage *inputImage = [CIImage imageWithCGImage:(CGImageRef)(self.filterLayer.contents)];
    
    CIVector *lightPoint = [CIVector vectorWithX:200 Y:200 Z:0];
    CIVector *lightPosition = [CIVector vectorWithX:400 Y:600 Z:150];
    CIColor *inputColor = [CIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.5];
    
    NSString *filterName = @"CISpotLight";
    
    NSDictionary *inputParamaters = @{
                                      @"inputBrightness" : @(3),
                                      @"inputColor" : inputColor,
                                      @"inputConcentration" : @(0.001),
                                      //@"inputImage" : inputImage,
                                      @"inputLightPointsAt" : lightPoint,
                                      @"inputLightPosition" : lightPosition,
                                      
                                      };
    
    
    
    CIFilter *filter = [CIFilter filterWithName:filterName withInputParameters:inputParamaters];// A filter that is available in iOS or a custom one :)
    
    CIImage *outputImage = [filter outputImage];
    
    CIContext *context = [CIContext contextWithOptions:nil];
    CGImageRef cgimg = [context createCGImage:outputImage fromRect:[outputImage extent]];
    
    
    self.filterLayer.contents = (__bridge id _Nullable)(cgimg);
    
}


-(void)doCILenticularHaloGeneratorStuff
{
    CIImage *inputImage = [CIImage imageWithCGImage:(CGImageRef)(self.filterLayer.contents)];
    
    
    CIVector *inputCenter = [CIVector vectorWithX:150 Y:150];
    CIColor *inputColor = [CIColor colorWithRed:1.0 green:0.9 blue:0.8 alpha:1.0];
    
    NSString *filterName = @"CILenticularHaloGenerator";
    
    NSDictionary *inputParamaters = @{
                                      @"inputCenter" : inputCenter,
                                      @"inputColor" : inputColor,
                                      @"inputHaloOverlap" : @(0.77),
                                      @"inputHaloRadius" : @(70), // 0 - 1000.
                                      @"inputHaloWidth" : @(83), // 0 - 300.
                                      @"inputStriationContrast" : @(1), // 0-5.
                                      @"inputStriationStrength" : @(0.5), // 0-3.
                                      @"inputTime" : @(0), // 0-1.
                                      
                                      };
    
    
    
    CIFilter *filter = [CIFilter filterWithName:filterName withInputParameters:inputParamaters];// A filter that is available in iOS or a custom one :)
    
    CIImage *outputImage = [filter outputImage];
    
    CIContext *context = [CIContext contextWithOptions:nil];
    CGImageRef cgimg = [context createCGImage:outputImage fromRect:[outputImage extent]];
    
    
    self.filterLayer.contents = (__bridge id _Nullable)(cgimg);
    
}







#pragma mark - Page Curl Transition Helpers

-(UIImage*)getInputShadingImage
{
    return [self makeRadialGradientImage];
}

-(UIImage*)getinputBacksideImage
{
    return [self flipImage:self.editImage];
}

-(UIImage*)getInputTargetImage
{
    return [self makeCheckerBoardImage];
}

#pragma mark - UIimage Flipping
- (UIImage *)flipImage:(UIImage *)image
{
    
    UIGraphicsBeginImageContext(image.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // fix X
    CGContextTranslateCTM(context, 0, image.size.height);
    CGContextScaleCTM(context, 1.0f, -1.0f);
    
    // then flip Y axis
    CGContextTranslateCTM(context, image.size.width, 0);
    CGContextScaleCTM(context, -1.0f, 1.0f);
    
    CGContextDrawImage(context, CGRectMake(0.0, 0.0, image.size.width, image.size.height), [image CGImage]);
    
    UIImage *flipedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return flipedImage;
    
}

#pragma mark - Radial Gradient Image Creation
-(UIImage *)makeRadialGradientImage
{
    CGFloat w = self.view.frame.size.width;
    CGRect outRect = CGRectMake(0, 0, w, w);
    
    CIVector *inputCenter = [CIVector vectorWithX:w/2 Y:w/2];
    CIColor *inputColor0 = [CIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0];
    CIColor *inputColor1 = [CIColor colorWithRed:0 green:0 blue:0 alpha:1.0];
    
    NSString *filterName = @"CIRadialGradient";
    
    NSDictionary *inputParamaters = @{
                                      @"inputCenter" : inputCenter,
                                      @"inputColor0" : inputColor0,
                                      @"inputColor1" : inputColor1,
                                      @"inputRadius0" : @(4), //0-800.
                                      @"inputRadius1" : @(w*0.5), //0-800.
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
    CGFloat w = self.view.frame.size.width;
    CGRect outRect = CGRectMake(0, 0, w, w);
    
    CIVector *inputCenter = [CIVector vectorWithX:w/2 Y:w/2];
    CIColor *inputColor0 = [CIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0];
    CIColor *inputColor1 = [CIColor colorWithRed:0 green:0 blue:0 alpha:1.0];
    
    NSString *filterName = @"CICheckerboardGenerator";
    
    NSDictionary *inputParamaters = @{
                                      @"inputCenter" : inputCenter,
                                      @"inputColor0" : inputColor0,
                                      @"inputColor1" : inputColor1,
                                      @"inputSharpness" : @(1),
                                      @"inputWidth" : @(40),
                                      };
    
    
    
    CIFilter *filter = [CIFilter filterWithName:filterName withInputParameters:inputParamaters];// A filter that is available in iOS or a custom one :)
    
    CIImage *outputImage = [filter outputImage];
    CIContext *context = [CIContext contextWithOptions:nil];
    
    
    
    
    UIImage * img = [UIImage imageWithCGImage:[context createCGImage:outputImage fromRect:outRect]];
    
    return img;

}











- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
