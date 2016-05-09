//
//  SceneKit Additions.m
//  3D
//
//  Created by Justin Madewell on 12/6/14.
//  Copyright (c) 2014 Justin Madewell. All rights reserved.
//

#import "SceneKit Additions.h"


SCNGeometry* ReturnGeometryOfType(ShapeType shapeType, CGFloat base)
{
    SCNGeometry *geometry = [SCNGeometry geometry];
    
    CGFloat shapeSize = base;
    
    if (shapeType == ShapeTypeRandom) {
        shapeType = 4;
    }
    
    NSString *shapeTypeString = ShapeTypeString(shapeType);
    
    NSLog(@"ShapeType:%@",shapeTypeString);
    
    switch (shapeType) {
        case ShapeTypeBox:
            geometry = [SCNBox boxWithWidth:1.0*shapeSize height:1.0*shapeSize length:1.0*shapeSize chamferRadius:shapeSize/32];
            break;
        case ShapeTypeCapsule:
            geometry = [SCNCapsule capsuleWithCapRadius:shapeSize/4 height:shapeSize];
            break;
        case ShapeTypeCone:
            geometry = [SCNCone coneWithTopRadius:1.0 bottomRadius:shapeSize/2 height:shapeSize];
            break;
        case ShapeTypeCylinder:
            geometry = [SCNCylinder cylinderWithRadius:shapeSize/4 height:shapeSize];
            break;
        case ShapeTypePlane:
            geometry = [SCNPlane planeWithWidth:shapeSize height:shapeSize/8];
            break;
        case ShapeTypePyramid:
            geometry = [SCNPyramid pyramidWithWidth:shapeSize height:shapeSize length:shapeSize];
            break;
        case ShapeTypeRandom:
            // Not Called
            geometry = [SCNSphere sphereWithRadius:shapeSize/2];
            break;
        case ShapeTypeSphere:
            geometry = [SCNSphere sphereWithRadius:shapeSize/2];
            break;
        case ShapeTypeTorus:
            geometry = [SCNTorus torusWithRingRadius:shapeSize/8 pipeRadius:shapeSize/16];
            break;
        case ShapeTypeTube:
            geometry = [SCNTube tubeWithInnerRadius:shapeSize/4 outerRadius:shapeSize/2 height:shapeSize];
            break;
        default:
            break;
    }
    
    return geometry;
}



#pragma mark - need to me moved to tools

NSString* ShapeTypeString(ShapeType shapeType)
{
    NSString *shapeTypeString;
    
    switch (shapeType) {
        case ShapeTypeBox:
            shapeTypeString = @"Box";
            break;
        case ShapeTypeCapsule:
            shapeTypeString = @"Capsule";
            break;
        case ShapeTypeCone:
            shapeTypeString = @"Cone";
            break;
        case ShapeTypeCylinder:
            shapeTypeString = @"Cylinder";
            break;
        case ShapeTypePlane:
            shapeTypeString = @"Plane";
            break;
        case ShapeTypePyramid:
            shapeTypeString = @"Pyramid";
            break;
        case ShapeTypeRandom:
            // Not Called
            shapeTypeString = @"Random";
            break;
        case ShapeTypeSphere:
            shapeTypeString = @"Sphere";
            break;
        case ShapeTypeTorus:
            shapeTypeString = @"Torus";
            break;
        case ShapeTypeTube:
            shapeTypeString = @"Tube";
            break;
        default:
            break;
    }
    
    return shapeTypeString;
}


void LogSCNVector4(SCNVector4 vec4,NSString *name)
{
    CGFloat x = vec4.x;
    CGFloat y = vec4.y;
    CGFloat z = vec4.z;
    CGFloat w = vec4.w;
    
    NSString *logStatement = [NSString stringWithFormat:@"%@-SCNVec4-X:%.02f|Y:%.02f|Z:%.02f|W:%.02f",name,x,y,z,w];
    NSLog(@"%@",logStatement);

    
}

void LogSCNVector3(SCNVector3 vec3,NSString *name)

{
    CGFloat x = vec3.x;
    CGFloat y = vec3.y;
    CGFloat z = vec3.z;
    
    NSString *logStatement = [NSString stringWithFormat:@"%@-SCNVec3-X:%.02f|Y:%.02f|Z:%.02f",name,x,y,z];
    NSLog(@"%@",logStatement);
}

void LogSCNMatrix4(SCNMatrix4 scnMtrx,NSString *name)
{
    CGFloat m11 = scnMtrx.m11;
    CGFloat m12 = scnMtrx.m12;
    CGFloat m13 = scnMtrx.m13;
    CGFloat m14 = scnMtrx.m14;
    
    NSString *line_1 = [NSString stringWithFormat:@"%f,%f,%f,%f",m11,m12,m13,m14];
    
    CGFloat m21 = scnMtrx.m21;
    CGFloat m22 = scnMtrx.m22;
    CGFloat m23 = scnMtrx.m23;
    CGFloat m24 = scnMtrx.m24;
    
    NSString *line_2 = [NSString stringWithFormat:@"%f,%f,%f,%f",m21,m22,m23,m24];
    
    CGFloat m31 = scnMtrx.m31;
    CGFloat m32 = scnMtrx.m32;
    CGFloat m33 = scnMtrx.m33;
    CGFloat m34 = scnMtrx.m34;
    
    NSString *line_3 = [NSString stringWithFormat:@"%f,%f,%f,%f",m31,m32,m33,m34];
    
    CGFloat m41 = scnMtrx.m41;
    CGFloat m42 = scnMtrx.m42;
    CGFloat m43 = scnMtrx.m43;
    CGFloat m44 = scnMtrx.m44;
    
    NSString *line_4 = [NSString stringWithFormat:@"%f,%f,%f,%f",m41,m42,m43,m44];
    
    NSString *logMessage = [NSString stringWithFormat:@"\n### -%@- SCNMatrix4 ### \n%@\n%@\n%@\n%@\n### ### ###",name,line_1,line_2,line_3,line_4];
    
    NSLog(@"%@",logMessage);
    
    
}


void duplicateNodeWithMaterial(SCNNode *node,SCNMaterial *material)
{
    SCNNode *newNode = [node clone];
    newNode.geometry = [node.geometry copy];
    newNode.geometry.firstMaterial = material;
}

SCNVector3 AddVectors(SCNVector3 v1,SCNVector3 v2)
{
    SCNVector3 addedVector;
    
    addedVector.x = v1.x + v2.x;
    addedVector.y = v1.y + v2.y;
    addedVector.z = v1.z + v2.z;
    
    return addedVector;
}





CGFloat randSCNFloat(CGFloat min, CGFloat max)
{
    return min + (max - min) * (CGFloat)rand() / RAND_MAX;
}

float randomFloatNumber()
{
    CGFloat r = randSCNFloat(0, 1);
   
    return r;
}

SCNVector3 RandomSCNVector3(float xMin,float xMax,float yMin,float yMax,float zMin,float zMax)
{
    SCNVector3 rVec;
    return rVec;
}

SCNVector3 RandomizeSCNVector3(SCNVector3 vec,SCNVector3 factorVec)
{
    SCNVector3 randomizedVec;
    
    CGFloat x = randSCNFloat(-factorVec.x, factorVec.x);
    CGFloat y = randSCNFloat(-factorVec.y, factorVec.y);
    CGFloat z = randSCNFloat(-factorVec.z, factorVec.z);
    
    SCNVector3 randomFactorVec = SCNVector3Make(x, y, z);
    
    randomizedVec = AddVectors(vec, randomFactorVec);
    
    return randomizedVec;
    

}

SCNVector3 GetNodeSize(SCNNode *node)
{
    // Get Node Size
    SCNVector3 minValue;
    SCNVector3 maxValue;
    
    [node getBoundingBoxMin:&minValue max:&maxValue];
    
    CGFloat width = maxValue.x - minValue.x;
    CGFloat height = maxValue.y - minValue.y;
    CGFloat depth = maxValue.z - minValue.z;
    
    return SCNVector3Make(width, height, depth);
}


SCNNode* PhysicsCageForGridStackNode(SCNNode *blocksNode)
{
    SCNVector3 gridStackSize = GetNodeSize(blocksNode);
    
    CGFloat gridWidth = gridStackSize.x;
    CGFloat gridDepth = gridStackSize.z;
    CGFloat gridHeight = gridStackSize.y;
    
    // build 6 walls
    SCNNode *frontSideWallNode;
    SCNNode *backSideWallNode;
    SCNNode *leftSideWallNode;
    SCNNode *rightSideWallNode;
    SCNNode *topNode;
    SCNNode *bottomNode;
    
    // get the size of the blocks in the node
    SCNNode *blockNode = [blocksNode.childNodes firstObject];
    SCNVector3 blockNodeSize = GetNodeSize(blockNode);
    CGFloat blockSize = blockNodeSize.x;
    
    SCNMaterial *boxMat = [SCNMaterial material];
    boxMat.diffuse.contents = [UIColor orangeColor];
    
    // Build the Wall Node
    CGFloat wallWidth = 0.25;
    //Since Example is 1.0 it doesnt matter, might want to change in the future
    wallWidth = blockSize/4; // = 0.25;
    CGFloat wallHeight = gridHeight;
    
    SCNVector3 centered = SCNVector3Make(0.5, wallHeight/2, 0.5);
    
    SCNMatrix4 yFlip = SCNMatrix4MakeRotation((90 * M_PI / 180.0f), 0, 1, 0);
    SCNMatrix4 xFlip = SCNMatrix4MakeRotation((90 * M_PI / 180.0f), 0, 0, 1);
    
    SCNMatrix4 topFlip = SCNMatrix4Mult(yFlip, xFlip);
    
    // Create a Node for the Width Wall with appropriate sizes.
    // Left & Right
    SCNBox *widthBox = [SCNBox boxWithWidth:wallWidth  height:wallHeight length:gridDepth chamferRadius:0];
    widthBox.firstMaterial = boxMat;
    SCNNode *widthWallNode = [SCNNode nodeWithGeometry:widthBox];
    widthWallNode.position = centered;
    
    // Create a Node for the Depth Wall with appropriate sizes.
    // Front & Back
    SCNBox *depthBox = [SCNBox boxWithWidth:wallWidth  height:wallHeight length:gridWidth chamferRadius:0];
    depthBox.firstMaterial = boxMat;
    SCNNode *depthWallNode = [SCNNode nodeWithGeometry:depthBox];
    depthWallNode.position = centered;
    depthWallNode.pivot = yFlip;
    
    //Create a Node for the Top of the Box
    SCNBox *topBox = [SCNBox boxWithWidth:wallWidth  height:gridDepth length:gridWidth chamferRadius:0];
    topBox.firstMaterial = boxMat;
    SCNNode *topWallNode = [SCNNode nodeWithGeometry:topBox];
    topWallNode.position = centered;
    topWallNode.pivot = topFlip;
    
    SCNVector3 topFromCenter = SCNVector3Make(0, gridHeight/2 + wallWidth/2, 0);
    SCNVector3 bottomFromCenter = SCNVector3Make(0, -(gridHeight/2 + wallWidth/2), 0);
    SCNVector3 frontFromCenter = SCNVector3Make(0, 0, gridDepth/2+wallWidth/2);
    SCNVector3 backFromCenter = SCNVector3Make(0, 0, -(gridDepth/2+wallWidth/2));
    SCNVector3 leftFromCenter = SCNVector3Make(-(gridWidth/2+wallWidth/2), 0, 0);
    SCNVector3 rightFromCenter = SCNVector3Make(gridWidth/2+wallWidth/2, 0, 0);
    
    SCNVector3 frontPos = AddVectors(centered, frontFromCenter);
    SCNVector3 backPos = AddVectors(centered, backFromCenter);
    SCNVector3 leftPos = AddVectors(centered, leftFromCenter);
    SCNVector3 rightPos = AddVectors(centered, rightFromCenter);
    
    SCNVector3 bottomPos = AddVectors(centered, bottomFromCenter);
    SCNVector3 topPos = AddVectors(centered, topFromCenter);
    
    SCNVector3 down = SCNVector3Make(1, 0, 0);
    SCNVector3 up = SCNVector3Make(-1, 0, 0);
    
    SCNVector3 left = SCNVector3Make(-1, 0, 0);
    SCNVector3 right = SCNVector3Make(1, 0, 0);
    
    SCNVector3 forward = SCNVector3Make(1, 0, 0);
    SCNVector3 backward = SCNVector3Make(-1, 0, 0);
    
    CGFloat opacity = 0.5;
    CGFloat strength = 5.0;
    
    frontSideWallNode = [depthWallNode clone];
    frontSideWallNode.position = frontPos;
    frontSideWallNode.name = @"FRONT";
    frontSideWallNode.physicsBody = [SCNPhysicsBody staticBody];
    frontSideWallNode.physicsField =[SCNPhysicsField linearGravityField];
    frontSideWallNode.physicsField.direction = backward;
    frontSideWallNode.physicsField.categoryBitMask = 0x1 << 0;
    frontSideWallNode.physicsField.strength = strength;
    frontSideWallNode.opacity = opacity;
    
    backSideWallNode = [depthWallNode clone];
    backSideWallNode.position = backPos;
    backSideWallNode.name = @"BACK";
    backSideWallNode.physicsBody = [SCNPhysicsBody staticBody];
    backSideWallNode.physicsField = [SCNPhysicsField linearGravityField];
    backSideWallNode.physicsField.direction = forward;
    backSideWallNode.physicsField.categoryBitMask = 0x1 << 0;
    backSideWallNode.physicsField.strength = strength;
    backSideWallNode.opacity = opacity;
    
    leftSideWallNode = [widthWallNode clone];
    leftSideWallNode.position = leftPos;
    leftSideWallNode.name = @"LEFT";
    leftSideWallNode.physicsBody = [SCNPhysicsBody staticBody];
    leftSideWallNode.physicsField = [SCNPhysicsField linearGravityField];
    leftSideWallNode.physicsField.direction = right;
    leftSideWallNode.physicsField.categoryBitMask = 0x1 << 0;
    leftSideWallNode.physicsField.strength = strength;
    leftSideWallNode.opacity = opacity;
    
    rightSideWallNode = [widthWallNode clone];
    rightSideWallNode.position = rightPos;
    rightSideWallNode.name = @"RIGHT";
    rightSideWallNode.physicsBody = [SCNPhysicsBody staticBody];
    rightSideWallNode.physicsField = [SCNPhysicsField linearGravityField];
    rightSideWallNode.physicsField.direction = left;
    rightSideWallNode.physicsField.categoryBitMask = 0x1 << 0;
    rightSideWallNode.physicsField.strength = strength;
    rightSideWallNode.opacity = opacity;
    
    topNode = [topWallNode clone];
    topNode.position = topPos;
    topNode.name = @"TOP";
    topNode.physicsBody = [SCNPhysicsBody staticBody];
    topNode.physicsField = [SCNPhysicsField linearGravityField];
    topNode.physicsField.direction = down;
    topNode.physicsField.categoryBitMask = 0x1 << 0;
    topNode.physicsField.strength = strength;
    topNode.opacity = opacity;
    
    bottomNode = [topWallNode clone];
    bottomNode.position = bottomPos;
    bottomNode.name = @"BOTTOM";
    bottomNode.physicsBody = [SCNPhysicsBody staticBody];
    bottomNode.physicsField = [SCNPhysicsField linearGravityField];
    bottomNode.physicsField.direction = up;
    bottomNode.physicsField.categoryBitMask = 0x1 << 0;
    bottomNode.physicsField.strength = strength;
    bottomNode.opacity = opacity;
    
    // Holder of all the Nodes
    SCNNode *physicsCageNode = [SCNNode node];
    
    [physicsCageNode addChildNode:frontSideWallNode];
    [physicsCageNode addChildNode:backSideWallNode];
    [physicsCageNode addChildNode:leftSideWallNode];
    [physicsCageNode addChildNode:rightSideWallNode];
    [physicsCageNode addChildNode:topNode];
    [physicsCageNode addChildNode:bottomNode];
    
    physicsCageNode.opacity = 0;
    
    return physicsCageNode;
    
}


NSArray* GridPositions(SCNVector3 unitSize,SCNVector3 gridStackSize)
{
    CGFloat width = gridStackSize.x;
    //CGFloat height = gridStackSize.y;
    CGFloat depth = gridStackSize.z;
    
    NSMutableArray *gridPositions = [[NSMutableArray alloc]init];
    
    //float unit = 1.0;
    
    float xUnit = unitSize.x;
    float yUnit = unitSize.y;
    float zUnit = unitSize.z;
    
    // split the amount and move to the left (-)
    float starting_X = (width/2) * -1;
    // split the amount and move back (-)
    float starting_Z = (depth/2) * -1;
    // start from the bottom and go up
    float starting_Y = yUnit/2;
    
    for (int y=1; y<=gridStackSize.y; y++) {
        //going from ground up
        
        for (int x=1; x<=gridStackSize.x; x++) {
            //going left to right
            
            for (int z=1; z<=gridStackSize.z; z++) {
                //back to front
                
                // Loop Logic
                int check = depth/2;
                float mod = 1.0;
                BOOL afterZero = YES;
                
                if (z<=check) {
                    mod = -1.0;
                    afterZero = NO;
                }
                
                float newZ;
                
                if (afterZero) {
                    newZ = starting_Z + ((zUnit * z) * mod);
                }
                else
                {
                    newZ = starting_Z - ((zUnit * z) * mod);
                }
                
                float newX = starting_X + (xUnit * x);
                float newY = starting_Y + ((y-1) * yUnit);
                
                float xValue = newX;
                float yValue = newY;
                float zValue = newZ;
                
                SCNVector3 newPosition =  SCNVector3Make(xValue, yValue, zValue);
                
                NSValue *newPositionValue = [NSValue valueWithSCNVector3:newPosition];
                
                [gridPositions addObject:newPositionValue];
                
            }
        }
    }
    
    return gridPositions;
    
}


NSArray* RandomNumbers(int numbers,float seed)
{
    NSMutableArray *numbersArray = [[NSMutableArray alloc]init];
    
    for (int i=0; i<numbers; i++) {
        [numbersArray addObject:@((drand48()))];
    }
    
    return numbersArray;
}

UIColor *RandomSCNColor()
{
    float seed =  arc4random() ;
    srand48(seed);
    
    return [UIColor colorWithRed:(drand48()) green:(drand48()) blue:(drand48()) alpha:1.0];
}


NSString* MemoryDescriptionSCN(SCNNode*node)
{
    NSString *value = node.description;
    NSString *separator = @": ";
    
    NSRange firstInstance = [value rangeOfString:separator];
    NSRange secondInstance = [[value substringFromIndex:firstInstance.location + firstInstance.length] rangeOfString:separator];
    NSRange finalRange = NSMakeRange(firstInstance.location + separator.length, secondInstance.location);
    
    NSString *firstChunk = [value substringWithRange:finalRange];
    NSString *newString =  [firstChunk substringToIndex:11];
    
    return newString;
}


void AddRotateAnimationToNode(SCNNode *node,NSString *axis,CGFloat duration,BOOL forever)
{
    NSValue *toValue;
    
    if ([axis isEqualToString:@"X"]) {
        toValue = [NSValue valueWithSCNVector4:SCNVector4Make(1, 0, 0, M_PI * 2)];
    }
    else if ([axis isEqualToString:@"Y"]) {
        toValue = [NSValue valueWithSCNVector4:SCNVector4Make(0, 1, 0, M_PI * 2)];
    }
    else if ([axis isEqualToString:@"Z"]) {
        toValue = [NSValue valueWithSCNVector4:SCNVector4Make(0, 0, 1, M_PI * 2)];
    }
    
    NSLog(@"toValue:%@",toValue);
    
    CGFloat repeatCount = 0;
    if (forever) {
        repeatCount = FLT_MAX;
    }
    
    
    NSString *keyName = [NSString stringWithFormat:@"%@RotationAnimation",axis];
    
    NSLog(@"keyName:%@",keyName);
    
    
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"rotation"];
    animation.duration = duration;
    animation.toValue = toValue;
    animation.repeatCount = repeatCount;
    [node addAnimation:animation forKey:keyName];
}




SCNMaterial* ShinyMetalMaterial()
{
    SCNMaterial *material = [SCNMaterial material];
    
    
    SKTexture *diffuseNoiseTexture = [SKTexture textureNoiseWithSmoothness:CGFLOAT_MIN size:CGSizeMake(1000, 1000) grayscale:YES];
    
    
    
    material.diffuse.contents  = diffuseNoiseTexture;
    material.normal.contents = [diffuseNoiseTexture textureByGeneratingNormalMap];
    material.specular.contents = [UIColor whiteColor];
    material.shininess = 1.0;
    
    material.diffuse.minificationFilter = SCNFilterModeLinear;
    material.diffuse.magnificationFilter = SCNFilterModeLinear;
    material.diffuse.mipFilter = SCNFilterModeLinear;
    
    return material;
}

void PlaceConnectionNode(SCNNode *nodeToAddTo,SCNVector3 placement,UIColor *color,CGFloat size)
{
    static int counter = 0;
    counter++;
    
    if (color==nil) {
        color = [UIColor colorWithRed:0.98 green:0.23 blue:0.91 alpha:1.0];
    }
    
    UIColor *connectionNodeColor = color;
    
    SCNNode *connectionNode = [SCNNode node];
    connectionNode.name = [NSString stringWithFormat:@"connectionNode_%i",counter];
    
//    connectionNode.physicsBody = [SCNPhysicsBody kinematicBody];
//    connectionNode.physicsBody.categoryBitMask = robotCategory;
    
    connectionNode.geometry = [SCNBox boxWithWidth:size height:size length:size chamferRadius:size/8];
    connectionNode.geometry.firstMaterial.emission.contents = connectionNodeColor;
    connectionNode.geometry.firstMaterial.diffuse.contents = connectionNodeColor;
    connectionNode.geometry.firstMaterial.lightingModelName = SCNLightingModelConstant;
    
    [nodeToAddTo addChildNode:connectionNode];
    connectionNode.position = placement;
    
    // connectionNode.opacity = 0.75;
}






#pragma mark - Vector Functions
#pragma mark - Geometry Math

float DotProduct(SCNVector3 vector1,SCNVector3 vector2)
{
    return (vector1.x*vector2.x) +
    (vector1.y*vector2.y) +
    (vector1.z*vector2.z);
}

SCNVector3 SubtractVectors(SCNVector3 vectorA, SCNVector3 vectorB)
{
    float x = vectorA.x - vectorB.x;
    float y = vectorA.y - vectorB.y;
    float z = vectorA.z - vectorB.z;
    
    SCNVector3 subtractedVector = SCNVector3Make(x, y, z);
    
    return subtractedVector;
    
}


// Cross Product
SCNVector3 CrossProduct(SCNVector3 vectorA, SCNVector3 vectorB)
{
    float x = (vectorA.y * vectorB.z) - (vectorA.z * vectorB.y) ;
    float y = (vectorA.z * vectorB.x) - (vectorA.x * vectorB.z) ;
    float z = (vectorA.x * vectorB.y) - (vectorA.y * vectorB.x) ;
    
    return SCNVector3Make(x, y, z);
}


//// Normalized
//SCNVector3 normalizeVector(SCNVector3 vector)
//{
//    CGFloat magnitude = GetVectorMagnitude(vector);
//    
//    if (magnitude == 0.0) {
//        return SCNVector3Make(1, 0, 0);
//    }
//    
//    float x = (vector.x/magnitude) ;
//    float y = (vector.y/magnitude) ;
//    float z = (vector.z/magnitude) ;
//    
//    SCNVector3 normalizedVector = SCNVector3Make(x, y, z);
//    
//    return normalizedVector;
//}
//
//// Magnitude
//CGFloat GetVectorMagnitude(SCNVector3 vector)
//{
//    return sqrtf((vector.x * vector.x) +
//                 (vector.y * vector.y) +
//                 (vector.z * vector.z));
//}


#pragma mark - Robot Name
NSString* GenerateRobotName()
{
    NSArray *firstLetterArray;
    NSArray *secondLetterArray;
    NSArray *thirdLetterArray;
    
    firstLetterArray = @[@"B",@"D",@"K",@"T",@"G"];
    secondLetterArray = @[@"A",@"E",@"I",@"O",@"U",@"Y"];
    thirdLetterArray = @[@"N",@"P",@"CK",@"D",@"M",@"Z"];
    
    NSInteger letterCount = 3;
    
    NSString *name = @"";
    
    for (int i=0; i<letterCount; i++) {
        
        NSString *currentString = @"";
        
        if (i == 0) {
            currentString = [firstLetterArray objectAtIndex:arc4random_uniform((int)firstLetterArray.count)];
        }
        
        if (i == 1) {
            currentString = [secondLetterArray objectAtIndex:arc4random_uniform((int)secondLetterArray.count)];
        }
        
        if (i == 2) {
            currentString = [secondLetterArray objectAtIndex:arc4random_uniform((int)secondLetterArray.count)];
        }
        
        if (i == 3) {
            currentString = [thirdLetterArray objectAtIndex:arc4random_uniform((int)thirdLetterArray.count)];
        }
        
        NSString *newName = [NSString stringWithFormat:@"%@%@",name,currentString];
        name = newName;
        
    }
    
    
    NSString *robotNameString = name;
    NSString *randomNumbersString = [NSString stringWithFormat:@"%i%i%i",arc4random_uniform(9),arc4random_uniform(9),arc4random_uniform(9)];
    
    NSString *nameString = [NSString stringWithFormat:@"%@.%@",robotNameString,randomNumbersString];
    
    NSLog(@"nameString:%@",nameString);
    
    
    return nameString;
}



#pragma mark - Primitives

// Create a carousel of 3D primitives
SCNNode* CarouselOfPrimativesNode()
{
    
    // Create the carousel node. It will host all the primitives as child nodes.
    SCNNode *carouselNode = [SCNNode node];
    carouselNode.position = SCNVector3Make(0, 0.1, -5);
    carouselNode.scale = SCNVector3Make(0, 0, 0); // start infinitely small
    
    //[self.groundNode addChildNode:_carouselNode];
    
    // Animate the scale to achieve a "grow" effect
    [SCNTransaction begin];
    [SCNTransaction setAnimationDuration:1.0];
    {
        carouselNode.scale = SCNVector3Make(1, 1, 1);
    }
    [SCNTransaction commit];
    
    // Rotate the carousel forever
    CABasicAnimation *rotationAnimation = [CABasicAnimation animationWithKeyPath:@"rotation"];
    rotationAnimation.duration = 40.0;
    rotationAnimation.repeatCount = FLT_MAX;
    rotationAnimation.toValue = [NSValue valueWithSCNVector4:SCNVector4Make(0, 1, 0, M_PI * 2)];
    [carouselNode addAnimation:rotationAnimation forKey:nil];
    
    // A material shared by all the primitives
    SCNMaterial *sharedMaterial = [SCNMaterial material];
    
    //TODO: Implement this
    //sharedMaterial.reflective.contents = [NSImage imageNamed:@"envmap"];
    sharedMaterial.reflective.intensity = 0.2;
    sharedMaterial.doubleSided = YES;
    
    __block int primitiveIndex = 0;
    void (^addPrimitive)(SCNGeometry *, CGFloat) = ^(SCNGeometry *geometry, CGFloat yPos) {
        CGFloat xPos = 13.0 * sin(M_PI * 2 * primitiveIndex / 9.0);
        CGFloat zPos = 13.0 * cos(M_PI * 2 * primitiveIndex / 9.0);
        
        SCNNode *node = [SCNNode node];
        node.position = SCNVector3Make(xPos, yPos, zPos);
        node.geometry = geometry;
        node.geometry.firstMaterial = sharedMaterial;
        [carouselNode addChildNode:node];
        
        primitiveIndex++;
        rotationAnimation.timeOffset = -primitiveIndex;
        [node addAnimation:rotationAnimation forKey:nil];
    };
    
    // SCNBox
    SCNBox *box = [SCNBox boxWithWidth:5.0 height:5.0 length:5.0 chamferRadius:5.0 * 0.05];
    box.widthSegmentCount = 4;
    box.heightSegmentCount = 4;
    box.lengthSegmentCount = 4;
    box.chamferSegmentCount = 4;
    addPrimitive(box, 5.0 / 2);
    
    // SCNPyramid
    SCNPyramid *pyramid = [SCNPyramid pyramidWithWidth:5.0 * 0.8 height:5.0 length:5.0 * 0.8];
    pyramid.widthSegmentCount = 4;
    pyramid.heightSegmentCount = 10;
    pyramid.lengthSegmentCount = 4;
    addPrimitive(pyramid, 0);
    
    // SCNCone
    SCNCone *cone = [SCNCone coneWithTopRadius:0 bottomRadius:5.0 / 2 height:5.0];
    cone.radialSegmentCount = 20;
    cone.heightSegmentCount = 4;
    addPrimitive(cone, 5.0 / 2);
    
    // SCNTube
    SCNTube *tube = [SCNTube tubeWithInnerRadius:5.0 * 0.25 outerRadius:5.0 * 0.5 height:5.0];
    tube.heightSegmentCount = 5;
    tube.radialSegmentCount = 40;
    addPrimitive(tube, 5.0 / 2);
    
    // SCNCapsule
    SCNCapsule *capsule = [SCNCapsule capsuleWithCapRadius:5.0 * 0.4 height:5.0 * 1.4];
    capsule.heightSegmentCount = 5;
    capsule.radialSegmentCount = 20;
    addPrimitive(capsule, 5.0 * 0.7);
    
    // SCNCylinder
    SCNCylinder *cylinder = [SCNCylinder cylinderWithRadius:5.0 * 0.5 height:5.0];
    cylinder.heightSegmentCount = 5;
    cylinder.radialSegmentCount = 40;
    addPrimitive(cylinder, 5.0 / 2);
    
    // SCNSphere
    SCNSphere *sphere = [SCNSphere sphereWithRadius:5.0 * 0.5];
    sphere.segmentCount = 20;
    addPrimitive(sphere, 5.0 / 2);
    
    // SCNTorus
    SCNTorus *torus = [SCNTorus torusWithRingRadius:5.0 * 0.5 pipeRadius:5.0 * 0.25];
    torus.ringSegmentCount = 40;
    torus.pipeSegmentCount = 20;
    addPrimitive(torus, 5.0 / 4);
    
    // SCNPlane
    SCNPlane *plane = [SCNPlane planeWithWidth:5.0 height:5.0];
    plane.widthSegmentCount = 5;
    plane.heightSegmentCount = 5;
    plane.cornerRadius = 5.0 * 0.1;
    addPrimitive(plane, 5.0 / 2);
    
    
    return carouselNode;
}










