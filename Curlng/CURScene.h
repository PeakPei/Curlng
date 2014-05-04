//
//  CURScene.h
//  Curlng
//

//  Copyright (c) 2014 Séraphin Hochart. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

typedef NS_ENUM(uint32_t, PhysicsCategory) {
    PhysicsCategoryBackground   = 0x1 << 0,
    PhysicsCategoryRock         = 0x1 << 1,
    PhysicsCategoryTarget       = 0x1 << 2
};

@interface CURScene : SKScene <SKPhysicsContactDelegate>

- (void)resetRocksPositions;

@end
