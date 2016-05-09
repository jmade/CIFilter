//
//  JDMCIController.h
//  CIFilter
//
//  Created by Justin Madewell on 11/30/15.
//  Copyright © 2015 Justin Madewell. All rights reserved.
//

typedef enum : NSInteger {
    ControllerTypeNil = 0,
    ControllerTypeImage = 1,
    ControllerTypeVector = 2,
    ControllerTypeData = 3,
    ControllerTypeNumber = 4,
    ControllerTypeObject = 5,
    ControllerTypeString = 6,
    ControllerTypeValue = 7,
    ControllerTypeColor = 8,
} ControllerType;


typedef enum : NSInteger {
    VectorTypeNil = 0,
    VectorTypePosition = 1,
    VectorTypePosition3 = 2,
    VectorTypeRectangle = 3,
    VectorTypeOffset = 4,
} VectorType;


#import "JDMColorControlObject.h"
#import "JDMNumericControlObject.h"
#import "JDMCIVectorControlObject.h"
#import "JDMBarCodeControlObject.h"
