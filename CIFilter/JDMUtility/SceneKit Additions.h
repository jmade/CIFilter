//
//  SceneKit Additions.h
//  3D
//
//  Created by Justin Madewell on 12/6/14.
//  Copyright (c) 2014 Justin Madewell. All rights reserved.
//

#import <SceneKit/SceneKit.h>
#import "BezierUtilities.h"
@import SpriteKit;





static const uint32_t other_B_Categor   =  0x1 << 5; //00000000000000000000000000100000 - 32
static const uint32_t other_C_Category  =  0x1 << 6; //00000000000000000000000001000000 - 64
static const uint32_t other_D_Category  =  0x1 << 7; //00000000000000000000000010000000 - 128
static const uint32_t other_E_Category  =  0x1 << 8; //00000000000000000000000100000000 - 256



//static const SCNMatrix4 xFlip = SCNMatrix4MakeRotation((90 * M_PI / 180.0f), 1, 0, 0);
//static const SCNMatrix4 yFlip = SCNMatrix4MakeRotation((90 * M_PI / 180.0f), 0, 1, 0);
//static const SCNMatrix4 zFlip = SCNMatrix4MakeRotation((90 * M_PI / 180.0f), 0, 0, 1);

//// SCNMatrix4 bottomPivot = SCNMatrix4MakeTranslation(0, -1.0, 0);
//SCNMatrix4 topPivot = SCNMatrix4MakeTranslation(0, 1.0, 0);
//
//SCNMatrix4 topFlip = SCNMatrix4Mult(yFlip, xFlip);


//typedef enum : NSUInteger  {
//    EnumNameOne = 0,
//} EnumName;


typedef enum : NSUInteger  {
    ShapeTypeRandom = 0,
    ShapeTypeCapsule = 1,
    ShapeTypeCone = 2,
    ShapeTypeCylinder = 3,
    ShapeTypePlane = 4,
    ShapeTypePyramid = 5,
    ShapeTypeSphere = 6,
    ShapeTypeTorus = 7,
    ShapeTypeTube = 8,
    ShapeTypeBox = 9
} ShapeType;

SCNGeometry* ReturnGeometryOfType(ShapeType shapeType, CGFloat base);

NSString* ShapeTypeString(ShapeType shapeType);
NSString* StringFromSCNVector3(SCNVector3 vec);

void LogSCNVector4(SCNVector4 vec4,NSString *name);
void LogSCNVector3(SCNVector3 vec3,NSString *name);
void LogSCNMatrix4(SCNMatrix4 scnMtrx,NSString *name);

SCNVector3 AddVectors(SCNVector3 v1,SCNVector3 v2);

void duplicateNodeWithMaterial(SCNNode *node,SCNMaterial *material);

SCNVector3 RandomSCNVector3(float xMin,float xMax,float yMin,float yMax,float zMin,float zMax);

SCNVector3 RandomizeSCNVector3(SCNVector3 vec,SCNVector3 factorVec);
CGFloat randSCNFloat(CGFloat min, CGFloat max);
float randomFloatNumber();

SCNVector3 GetNodeSize(SCNNode *node);

SCNNode* PhysicsCageForGridStackNode(SCNNode *blocksNode);
NSArray* GridPositions(SCNVector3 unitSize,SCNVector3 gridStackSize);
NSArray* RandomNumbers(int numbers,float seed);

NSString* MemoryDescriptionSCN(SCNNode*node);


UIColor *RandomSCNColor();
SCNMaterial* ShinyMetalMaterial();
void PlaceConnectionNode(SCNNode *nodeToAddTo,SCNVector3 placement,UIColor *color,CGFloat size);


void AddRotateAnimationToNode(SCNNode *node,NSString *axis,CGFloat duration,BOOL forever);


SCNVector3 SubtractVectors(SCNVector3 vectorA, SCNVector3 vectorB);

NSString* GenerateRobotName();













