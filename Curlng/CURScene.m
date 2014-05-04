//
//  CURScene.m
//  Curlng
//
//  Created by Séraphin Hochart on 2014-04-26.
//  Copyright (c) 2014 Séraphin Hochart. All rights reserved.
//

#import "CURScene.h"
#import "Math.h"

@interface CURScene () {
    NSTimeInterval lastUpdate;
    NSTimeInterval deltaTime;
    
    CGPoint startPosition;
    SKAction *swipe;
    
    BOOL span;
    BOOL rockIsSliding;
    CGFloat length;
}

@property (nonatomic, strong) SKSpriteNode *sn_rock;
@property (nonatomic, strong) SKSpriteNode *sn_target;
@property (nonatomic, strong) SKSpriteNode *sn_background;
@property (nonatomic, strong) SKSpriteNode *sn_launchZone;

@end

static NSString * const kMovableNodeName = @"movable"; // Keep track of what can be moved

@implementation CURScene

-(id)initWithSize:(CGSize)size {    
    if (self = [super initWithSize:size]) {
        
        // SCENE
        
        length = 0.0;
        startPosition = CGPointMake(size.width/2, 50.0f);
        
        self.physicsWorld.gravity = CGVectorMake(0, 0);
        self.physicsWorld.contactDelegate = self;
        
        // NODES
        
        self.sn_background = [SKSpriteNode spriteNodeWithColor:[UIColor colorWithRed:0.95 green:0.9 blue:0.95 alpha:1.0] size:size];
        self.sn_background.anchorPoint = CGPointZero;
        self.sn_background.position = CGPointZero;
        self.sn_background.zPosition = 1;
        [self addChild:self.sn_background];
        
        CGSize launchZone = CGSizeMake(size.width, size.height/3.5);
        self.sn_launchZone = [SKSpriteNode spriteNodeWithColor:[UIColor colorWithRed:0.95 green:0.5 blue:0.5 alpha:1.0] size:launchZone];
        self.sn_launchZone.anchorPoint = CGPointZero;
        self.sn_launchZone.position = CGPointZero;
        self.sn_launchZone.zPosition = 2;
        [self addChild:self.sn_launchZone];
        
        // Init the target
        self.sn_target = [SKSpriteNode spriteNodeWithColor:[UIColor redColor] size:CGSizeMake(20.0f, 20.0f)];
        [self.sn_target setPosition:CGPointMake(size.width/2, size.height - 75.0f)];
        self.sn_target.zPosition = 3;
        [self addChild:self.sn_target];
        
        // Init the rock
        self.sn_rock = [SKSpriteNode spriteNodeWithColor:[UIColor grayColor] size:CGSizeMake(25.0f, 25.0f)];
        [self.sn_rock setName:kMovableNodeName];
        [self.sn_rock setPosition:startPosition];
        self.sn_rock.zPosition = 4;
        [self addChild:self.sn_rock];
        
        // PHYSICS
        
        self.sn_background.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:CGRectMake(0, 0, size.width, size.height * 3)];
        self.sn_background.physicsBody.categoryBitMask = PhysicsCategoryBackground;
        self.sn_background.physicsBody.contactTestBitMask = PhysicsCategoryRock;
        self.sn_background.physicsBody.collisionBitMask = PhysicsCategoryRock;
        
        self.sn_target.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:10.0f];
        self.sn_target.physicsBody.categoryBitMask = PhysicsCategoryTarget;
        self.sn_target.physicsBody.contactTestBitMask = PhysicsCategoryBackground | PhysicsCategoryRock | PhysicsCategoryTarget;
        self.sn_target.physicsBody.collisionBitMask = PhysicsCategoryBackground;
        
        self.sn_rock.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:10.0f];
        self.sn_rock.physicsBody.mass = 18.0;
        self.sn_rock.physicsBody.friction = 0.1;
        self.sn_rock.physicsBody.linearDamping = 0.75;
        self.sn_rock.physicsBody.categoryBitMask = PhysicsCategoryRock;
        self.sn_rock.physicsBody.contactTestBitMask = PhysicsCategoryBackground | PhysicsCategoryRock | PhysicsCategoryTarget;
        self.sn_rock.physicsBody.collisionBitMask = PhysicsCategoryBackground;
    }
    return self;
}

- (void)resetRocksPositions {
    [self resetRockPhysics];
    startPosition = CGPointMake(self.size.width/2, 50.0f);
    [self.sn_rock setPosition:startPosition];
    [self.sn_target setPosition:CGPointMake(self.size.width/2, self.size.height - 50.0f)];
}

- (void)resetRockPhysics {
    [self.sn_rock removeAllActions];
    self.sn_rock.physicsBody.resting = YES;
    length = 0;
    rockIsSliding = NO; // Allow retouching for now. TODO : Limit to only the bottom part
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    /* Called when a touch begins */
    
    CGPoint touchLocation = [[touches anyObject] locationInNode:self.sn_background];
    
    if (rockIsSliding) {
        [self resetRockPhysics];
    }
    
    startPosition = touchLocation;
    
    if (!rockIsSliding && CGRectContainsPoint(self.sn_rock.frame, touchLocation)) {
        NSLog(@"touch");
        span = YES;
    } else {
        span = NO;
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (span && !rockIsSliding) {
        
        CGPoint touchLocation = [[touches anyObject] locationInNode:self];
        
        CGPoint vector = vectorSub(touchLocation, startPosition);
        CGPoint normalVector = vectorNorm(vector);
        CGFloat angleRads = vectorAngle(normalVector);
        int angleDegs = (int)radiansToDegrees(angleRads);
        length = vectorLength(vector);
        
        while (angleDegs < 0) {
            angleDegs += 360;
        }
        
        // NSLog(@"%i", angleDegs);
        
        // Set new position
        self.sn_rock.position = vectorAdd(startPosition, vectorScalarMult(normalVector, length));
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (rockIsSliding) {
        NSLog(@"swipe");
        return;
    }
    
    CGPoint vector = vectorSub(startPosition, self.sn_rock.position);
    CGPoint velocity = vectorScalarMult(vector, length * 0.2);
    
    NSLog(@"Velocity : %@", NSStringFromCGPoint(velocity));
    
    [self.sn_rock.physicsBody applyImpulse:CGVectorMake(-velocity.x, -velocity.y)];
    
    span = NO;
    rockIsSliding = YES;
}

-(void)update:(CFTimeInterval)currentTime {
    /* Called before each frame is rendered */
    deltaTime = currentTime - lastUpdate;
    if (deltaTime > 0.02) {
        deltaTime = 0.02;
    }
    lastUpdate = currentTime;
    
    if ([self.sn_rock.physicsBody isResting] && rockIsSliding) {
        rockIsSliding = NO;
        
        // Calculate the distance
    }
}


- (void)didBeginContact:(SKPhysicsContact *)contact
{
    SKNode *firstBody = contact.bodyA.node;
    SKNode *secondBody = contact.bodyB.node;
    
    uint32_t collision = firstBody.physicsBody.categoryBitMask | secondBody.physicsBody.categoryBitMask;
    
    NSLog(@"firstbody: %@", firstBody);
    NSLog(@"secondbody: %@", secondBody);
    
    if (collision == (PhysicsCategoryRock | PhysicsCategoryTarget)) {
        NSLog(@"Two rocks hit");
    } else if (collision == (PhysicsCategoryRock | PhysicsCategoryBackground)) {
        NSLog(@"rock hits the Wall");
    } else {
        NSLog(@"ERROR");
    }
}

@end
