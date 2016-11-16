//
//  GameScene.m
//  BreakeOutDemo
//
//  Created by Ekaterina Krasnova on 09.05.16.
//  Copyright (c) 2016 Ekaterina Krasnova. All rights reserved.
//

#import "GameScene.h"
#import "GameOver.h"
#import "GameWon.h"
@import GameKit;

static const CGFloat kTrackPointsPerSecond = 1000;

static const uint32_t category_fence  = 0x1 << 3;
static const uint32_t category_paddle = 0x1 << 2;
static const uint32_t category_block  = 0x1 << 1;
static const uint32_t category_ball   = 0x1 << 0;

@interface GameScene () <SKPhysicsContactDelegate>

@property (nonatomic, strong, nullable) UITouch *motivatingTouch;
@property (strong, nonatomic) NSMutableArray *blockFrames;
@property (assign, nonatomic) int blocksBusted;
@property (assign, nonatomic) BOOL busted1block;
@property (assign, nonatomic) BOOL busted10blocks;

@end

@implementation GameScene

-(void)didMoveToView:(SKView *)view {
    
    self.blocksBusted = 0;
    self.busted1block = NO;
    self.busted10blocks = NO;
    [self resetAchievements];
    
    self.name = @"Fence";
    self.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:self.frame];
    self.physicsBody.categoryBitMask = category_fence;
    self.physicsBody.collisionBitMask = 0x0;
    self.physicsBody.contactTestBitMask = 0x0;
    
    self.physicsWorld.contactDelegate = self;
    
    SKSpriteNode *background = (SKSpriteNode  *)[self childNodeWithName:@"Background"];
    background.zPosition = 0;
    background.lightingBitMask = 0x1;
    
    SKSpriteNode *ball1 = [SKSpriteNode spriteNodeWithImageNamed:@"sphere1.png"];
    ball1.name = @"Ball1";
    ball1.position = CGPointMake(60, 30);
    ball1.zPosition = 1;
    ball1.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:ball1.size.width/2];
    ball1.physicsBody.dynamic = YES;
    //ball1.position = CGPointMake(100, self.size.height/2);
    ball1.physicsBody.friction = 0.0;
    ball1.physicsBody.restitution = 1.0;
    ball1.physicsBody.linearDamping = 0.0;
    ball1.physicsBody.angularDamping = 0.0;
    ball1.physicsBody.allowsRotation = NO;
    ball1.physicsBody.mass = 1.0;
    ball1.physicsBody.velocity = CGVectorMake(200.0, 200.0);
    ball1.physicsBody.affectedByGravity = NO;
    ball1.physicsBody.categoryBitMask = category_ball;
    ball1.physicsBody.collisionBitMask = category_fence | category_ball | category_block | category_paddle;
    ball1.physicsBody.contactTestBitMask = category_fence | category_block;
    ball1.physicsBody.usesPreciseCollisionDetection = YES;
    [self addChild:ball1];
    
    SKLightNode *light = [SKLightNode new];
    light.categoryBitMask = 0x1;
    light.falloff = 1;
    light.ambientColor = [UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:1.0];
    light.lightColor = [UIColor colorWithRed:0.7 green:0.7 blue:1.0 alpha:1.0];
    light.shadowColor = [[UIColor alloc]initWithRed:0.0 green:0.0 blue:0.0 alpha:1.0];
    light.zPosition = 1;
    [ball1 addChild:light];
    
    SKSpriteNode *ball2 = [SKSpriteNode spriteNodeWithImageNamed:@"sphere1.png"];
    ball2.name = @"Ball2";
    ball2.position = CGPointMake(60, 75);
    ball2.zPosition = 1;
    ball2.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:ball2.size.width/2];
    ball2.physicsBody.dynamic = YES;
    //ball2.position = CGPointMake(150, self.size.height/2);
    ball2.physicsBody.friction = 0.0;
    ball2.physicsBody.restitution = 1.0;
    ball2.physicsBody.linearDamping = 0.0;
    ball2.physicsBody.angularDamping = 0.0;
    ball2.physicsBody.allowsRotation = NO;
    ball2.physicsBody.mass = 1.0;
    ball2.physicsBody.velocity = CGVectorMake(200.0, 200.0);
    ball2.physicsBody.affectedByGravity = NO;
    ball2.physicsBody.categoryBitMask = category_ball;
    ball2.physicsBody.collisionBitMask = category_fence | category_ball | category_block | category_paddle;
    ball2.physicsBody.contactTestBitMask = category_fence | category_block;
    ball2.physicsBody.usesPreciseCollisionDetection = YES;
    [self addChild:ball2];
    
    SKSpriteNode *paddle = [SKSpriteNode spriteNodeWithImageNamed:@"paddle1.png"];
    paddle.name = @"Paddle";
    paddle.position = CGPointMake(self.size.width/2, 100);
    paddle.zPosition = 1;
    paddle.lightingBitMask = 0x1;
    paddle.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:CGSizeMake(paddle.size.width, paddle.size.height)];
    paddle.physicsBody.dynamic = NO;
    paddle.physicsBody.friction = 0.0;
    paddle.physicsBody.restitution = 1.0;
    paddle.physicsBody.linearDamping = 0.0;
    paddle.physicsBody.angularDamping = 0.0;
    paddle.physicsBody.allowsRotation = NO;
    paddle.physicsBody.mass = 1.0;
    paddle.physicsBody.velocity = CGVectorMake(0.0, 0.0);
    paddle.physicsBody.categoryBitMask = category_paddle;
    paddle.physicsBody.collisionBitMask = 0x0;
    paddle.physicsBody.contactTestBitMask = category_ball;
    paddle.physicsBody.usesPreciseCollisionDetection = YES;
    [self addChild:paddle];
    
    CGPoint ball1Anchor = CGPointMake(ball1.position.x, ball1.position.y);
    CGPoint ball2Anchor = CGPointMake(ball2.position.x, ball2.position.y);
    SKPhysicsJointSpring *joint = [SKPhysicsJointSpring jointWithBodyA:ball1.physicsBody bodyB:ball2.physicsBody anchorA:ball1Anchor anchorB:ball2Anchor];
    joint.damping = 0.0;
    joint.frequency = 1.5;
    [self.scene.physicsWorld addJoint:joint];
    
    self.blockFrames = [NSMutableArray array];
    SKTextureAtlas *blockAnimation = [SKTextureAtlas atlasNamed:@"block.atlas"];
    unsigned long numImages = blockAnimation.textureNames.count;
    for (int i = 0; i < numImages; i++) {
        NSString *textureName = [NSString stringWithFormat:@"block%02d", i];
        SKTexture *temp = [blockAnimation textureNamed:textureName];
        [self.blockFrames addObject:temp];
    }
    
    //SKSpriteNode *node = [SKSpriteNode spriteNodeWithImageNamed:@"block1.png"];
    SKSpriteNode *node = [SKSpriteNode spriteNodeWithTexture:self.blockFrames[0]];
    node.scale = 0.35;
    CGFloat kBlockWidth = node.size.width;
    CGFloat kBlockHeight = node.size.height;
    CGFloat kBlockHorizSpace = 20.0f;
    int kBlocksPerRow = (self.size.width / (kBlockWidth + kBlockHorizSpace));
    //Top row of blocks
    for (int i = 0; i < kBlocksPerRow; i++) {
        //node = [SKSpriteNode spriteNodeWithImageNamed:@"block1.png"];
        node = [SKSpriteNode spriteNodeWithTexture:self.blockFrames[0]];
        node.scale = 0.35;
        
        node.name = @"Block";
        node.position = CGPointMake(kBlockHorizSpace/2 + kBlockWidth/2 + i*(kBlockWidth) + i*kBlockHorizSpace,
                                    self.size.height - 100.0);
        node.zPosition = 1;
        node.lightingBitMask = 0x1;

        node.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:node.size center:CGPointMake(0, 0)];
        node.physicsBody.dynamic = NO;
        node.physicsBody.friction = 0.0;
        node.physicsBody.restitution = 1.0;
        node.physicsBody.linearDamping = 0.0;
        node.physicsBody.angularDamping = 0.0;
        node.physicsBody.allowsRotation = NO;
        node.physicsBody.mass = 1.0;
        node.physicsBody.velocity = CGVectorMake(0.0, 0.0);
        node.physicsBody.categoryBitMask = category_block;
        node.physicsBody.collisionBitMask = 0x0;
        node.physicsBody.contactTestBitMask = category_ball;
        node.physicsBody.usesPreciseCollisionDetection = NO;
        [self addChild:node];
    }
    
    //Middle row of blocks
    kBlocksPerRow = (self.size.width / (kBlockWidth + kBlockHorizSpace)) - 1;
    for (int i = 0; i < kBlocksPerRow; i++) {
        //node = [SKSpriteNode spriteNodeWithImageNamed:@"block1.png"];
        node = [SKSpriteNode spriteNodeWithTexture:self.blockFrames[0]];
        node.scale = 0.35;
        
        node.name = @"Block";
        node.position = CGPointMake(kBlockHorizSpace + kBlockWidth + i*(kBlockWidth) + i*kBlockHorizSpace,
                                    self.size.height - 100.0 - (1.5*kBlockHeight));
        node.zPosition = 1;
        node.lightingBitMask = 0x1;

        node.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:node.size center:CGPointMake(0, 0)];
        node.physicsBody.dynamic = NO;
        node.physicsBody.friction = 0.0;
        node.physicsBody.restitution = 1.0;
        node.physicsBody.linearDamping = 0.0;
        node.physicsBody.angularDamping = 0.0;
        node.physicsBody.allowsRotation = NO;
        node.physicsBody.mass = 1.0;
        node.physicsBody.velocity = CGVectorMake(0.0, 0.0);
        node.physicsBody.categoryBitMask = category_block;
        node.physicsBody.collisionBitMask = 0x0;
        node.physicsBody.contactTestBitMask = category_ball;
        node.physicsBody.usesPreciseCollisionDetection = NO;
        [self addChild:node];
    }
    
    //Third row of blocks
    kBlocksPerRow = (self.size.width / (kBlockWidth + kBlockHorizSpace));
    for (int i = 0; i < kBlocksPerRow; i++) {
        //node = [SKSpriteNode spriteNodeWithImageNamed:@"block1.png"];
        node = [SKSpriteNode spriteNodeWithTexture:self.blockFrames[0]];
        node.scale = 0.35;
        
        node.name = @"Block";
        node.position = CGPointMake(kBlockHorizSpace/2 + kBlockWidth/2 + i*(kBlockWidth) + i*kBlockHorizSpace,
                                    self.size.height - 100.0 - (3.0 * kBlockHeight));
        node.zPosition = 1;
        node.lightingBitMask = 0x1;

        node.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:node.size center:CGPointMake(0, 0)];
        node.physicsBody.dynamic = NO;
        node.physicsBody.friction = 0.0;
        node.physicsBody.restitution = 1.0;
        node.physicsBody.linearDamping = 0.0;
        node.physicsBody.angularDamping = 0.0;
        node.physicsBody.allowsRotation = NO;
        node.physicsBody.mass = 1.0;
        node.physicsBody.velocity = CGVectorMake(0.0, 0.0);
        node.physicsBody.categoryBitMask = category_block;
        node.physicsBody.collisionBitMask = 0x0;
        node.physicsBody.contactTestBitMask = category_ball;
        node.physicsBody.usesPreciseCollisionDetection = NO;
        [self addChild:node];
    }
    
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    const CGRect touchRegion = CGRectMake(0, 0, self.size.width, self.size.height * 0.3);
    
    for (UITouch *touch in touches) {
        CGPoint p = [touch locationInNode:self];
        if (CGRectContainsPoint(touchRegion, p)) {
            self.motivatingTouch = touch;
        }
    }
    
    [self trackPaddlesToMotivatingTouches];
}

-(void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self trackPaddlesToMotivatingTouches];
}

-(void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if ([touches containsObject:self.motivatingTouch]) {
        self.motivatingTouch = nil;
    }
}

-(void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if ([touches containsObject:self.motivatingTouch]) {
        self.motivatingTouch = nil;
    }
}

- (void)trackPaddlesToMotivatingTouches {
    SKNode *node = [self childNodeWithName:@"Paddle"];
    
    UITouch *touch = self.motivatingTouch;
    if (!touch) {
        return;
    }
    
    CGFloat xPos = [touch locationInNode:self].x;
    NSTimeInterval duration = ABS(xPos - node.position.x) / kTrackPointsPerSecond;
    [node runAction:[SKAction moveToX:xPos duration:duration]];
}

-(void)update:(CFTimeInterval)currentTime {
    /* Called before each frame is rendered */
    static const int kMaxSpeed = 1500;
    static const int kMinSpeed = 400;
    
    SKNode *ball1 = [self childNodeWithName:@"Ball1"];
    SKNode *ball2 = [self childNodeWithName:@"Ball2"];
    float speedBall1 = sqrt(ball1.physicsBody.velocity.dx*ball1.physicsBody.velocity.dx + ball1.physicsBody.velocity.dy*ball1.physicsBody.velocity.dy);
    float dx = (ball1.physicsBody.velocity.dx + ball2.physicsBody.velocity.dx)/2;
    float dy = (ball1.physicsBody.velocity.dy + ball2.physicsBody.velocity.dy)/2;
    float speed = sqrtf(dx*dx + dy*dy);
    if ((speedBall1 > kMaxSpeed) || (speed > kMaxSpeed)) {
        ball1.physicsBody.linearDamping += 0.1f;
        ball2.physicsBody.linearDamping += 0.1f;
    }
    else if ((speedBall1 < kMinSpeed) || (speed < kMinSpeed)) {
        ball1.physicsBody.linearDamping -= 0.1f;
        ball2.physicsBody.linearDamping -= 0.1f;
    }
    else {
        ball1.physicsBody.linearDamping = 0.0f;
        ball2.physicsBody.linearDamping = 0.0f;
    }

}

- (void)didBeginContact:(SKPhysicsContact *)contact {
    NSString *nameA = contact.bodyA.node.name;
    NSString *nameB = contact.bodyB.node.name;
    
    if (([nameA containsString:@"Ball"] && [nameB containsString:@"Block"]) || ([nameA containsString:@"Block"] && [nameB containsString:@"Ball"])) {
        
        self.blocksBusted++;
        if ((self.blocksBusted >= 1) && (self.busted1block == NO)) {
            self.busted1block = YES;
            [self report1BlockAchievement];
        }
        if ((self.blocksBusted >= 10) && (self.busted10blocks == NO)) {
            self.busted10blocks = YES;
            [self report10BlocksAchievement];
        }
        
        //Figure out wich body is exploding
        SKNode *block;
        if ([nameA containsString:@"Block"]) {
            block = contact.bodyA.node;
        }
        else {
            block = contact.bodyB.node;
        }
        
        //Do the build up
        SKAction *actionAudioRamp = [SKAction playSoundFileNamed:@"sound_block.mp3" waitForCompletion:NO];
        SKAction *actionVisualRamp = [SKAction animateWithTextures:self.blockFrames timePerFrame:0.04f resize:NO restore:NO];
        NSString *particleRampPath = [[NSBundle mainBundle] pathForResource:@"ParticleRampUp" ofType:@"sks"];
        SKEmitterNode *particleRamp = [NSKeyedUnarchiver unarchiveObjectWithFile:particleRampPath];
        particleRamp.position = CGPointMake(0, 0);
        particleRamp.zPosition = 0;
        SKAction *actionParticleRamp = [SKAction runBlock:^{
            [block addChild:particleRamp];
        }];
        //Group
        SKAction *actionRampSequence = [SKAction group:@[actionAudioRamp, actionParticleRamp, actionVisualRamp]];
        
        SKAction *actionAudioExplode = [SKAction playSoundFileNamed:@"sound_explode.mp3" waitForCompletion:NO];
        NSString *particleExplosionPath = [[NSBundle mainBundle] pathForResource:@"ParticleBlock" ofType:@"sks"];
        SKEmitterNode *particleExplosion = [NSKeyedUnarchiver unarchiveObjectWithFile:particleExplosionPath];
        particleExplosion.position = CGPointMake(0, 0);
        particleExplosion.zPosition = 2;
        SKAction *actionParticleExplosion = [SKAction runBlock:^{
            [block addChild:particleExplosion];
        }];
        
        NSString *particleScorePath = [[NSBundle mainBundle] pathForResource:@"ParticleScore" ofType:@"sks"];
        SKEmitterNode *particleScore = [NSKeyedUnarchiver unarchiveObjectWithFile:particleScorePath];
        particleScore.position = CGPointMake(0, 0);
        particleScore.zPosition = 2;
        SKAction *actionParticleScore = [SKAction runBlock:^{
            [block addChild:particleScore];
        }];
        
        SKAction *actionRemoveBlock = [SKAction removeFromParent];
        SKAction *actionExplodeSequence = [SKAction sequence:@[actionAudioExplode, actionParticleExplosion, [SKAction fadeOutWithDuration:1]]];
        
        SKAction *checkGameOver = [SKAction runBlock:^{
            BOOL anyBlocksRemaining = ([self childNodeWithName:@"Block"] != nil);
            if (!anyBlocksRemaining) {
                SKView *skView = (SKView *)self.view;
                [self removeFromParent];
                
                [self reportScore:(self.blocksBusted*100)];
                
                GameWon *scene = [GameWon nodeWithFileNamed:@"GameWon"];
                scene.scaleMode = SKSceneScaleModeAspectFit;
                [skView presentScene:scene];
            }
        }];
        
        [block runAction:[SKAction sequence:@[actionParticleScore, actionRampSequence, actionExplodeSequence, actionRemoveBlock, checkGameOver]]];
    }
    
    else if (([nameA containsString:@"Ball"] && [nameB containsString:@"Paddle"]) || ([nameA containsString:@"Paddle"] && [nameB containsString:@"Ball"])) {
        SKAction *paddleAudio = [SKAction playSoundFileNamed:@"sound_paddle.mp3" waitForCompletion:NO];
        [self runAction:paddleAudio];
    }
    
    else if (([nameA containsString:@"Fence"] && [nameB containsString:@"Ball"]) || ([nameA containsString:@"Ball"] && [nameB containsString:@"Fence"])) {
        SKAction *fenceAudio = [SKAction playSoundFileNamed:@"sound_wall.mp3" waitForCompletion:NO];
        [self runAction:fenceAudio];
        
        SKNode *ball;
        if ([nameA containsString:@"Ball"]) {
            ball = contact.bodyA.node;
        }
        else {
            ball = contact.bodyB.node;
        }
        //You missed the ball - Game Over
        if (contact.contactPoint.y < 10) {
            SKAction *actionAudioExplode = [SKAction playSoundFileNamed:@"sound_explode.mp3" waitForCompletion:NO];
            NSString *particleExplosionPath = [[NSBundle mainBundle] pathForResource:@"ParticleBlock" ofType:@"sks"];
            SKEmitterNode *particleExplosion = [NSKeyedUnarchiver unarchiveObjectWithFile:particleExplosionPath];
            particleExplosion.position = CGPointMake(0, 0);
            //particleExplosion.zPosition = 2;
            //particleExplosion.targetNode = self;
            SKAction *actionParticleExplosion = [SKAction runBlock:^{
                [ball addChild:particleExplosion];
            }];
            SKAction *actionRemoveBall = [SKAction removeFromParent];
            SKAction *reportScore = [SKAction runBlock:^{
                [self reportScore:(self.blocksBusted*100)];
            }];
            SKAction *switchScene = [SKAction runBlock:^{
                SKView *skView = (SKView *)self.view;
                [self removeFromParent];
                GameOver *scene = [GameOver nodeWithFileNamed:@"GameOver"];
                scene.scaleMode = SKSceneScaleModeAspectFill;
                [skView presentScene:scene];
            }];
            SKAction *actionExplodeSequence = [SKAction sequence:@[actionParticleExplosion, actionAudioExplode, [SKAction fadeOutWithDuration:0.25], actionRemoveBall, reportScore, switchScene]];
            [ball runAction:actionExplodeSequence];
        }
        else {
            SKAction *fenceAudio = [SKAction playSoundFileNamed:@"sound_wall.mp3" waitForCompletion:NO];
            [self runAction:fenceAudio];
        }
    }
    
    else {
        
    }
    
    NSLog(@"\nWhat collided? %@ %@", nameA, nameB);
}

- (void)reportScore:(int)myScore {
    GKScore *score = [[GKScore alloc] initWithLeaderboardIdentifier:@"High_Score"];
    score.value = myScore;
    [GKScore reportScores:@[score] withCompletionHandler:^(NSError *error) {
        if (error != nil) {
            NSLog(@"%@", [error localizedDescription]);
        }
    }];
}

- (void) report1BlockAchievement {
    GKAchievement *scoreAchievement = [[GKAchievement alloc] initWithIdentifier:@"Broke_1_Block"];
    scoreAchievement.percentComplete = 100;
    scoreAchievement.showsCompletionBanner = YES;
    [GKAchievement reportAchievements:@[scoreAchievement] withCompletionHandler:^(NSError *error) {
        if (error != nil) {
            NSLog(@"%@", [error localizedDescription]);
        }
    }];
}

- (void) report10BlocksAchievement {
    GKAchievement *scoreAchievement = [[GKAchievement alloc] initWithIdentifier:@"Broke_10_Blocks"];
    scoreAchievement.percentComplete = 100;
    scoreAchievement.showsCompletionBanner = YES;
    [GKAchievement reportAchievements:@[scoreAchievement] withCompletionHandler:^(NSError *error) {
        if (error != nil) {
            NSLog(@"%@", [error localizedDescription]);
        }
    }];
}

- (void) resetAchievements {
    [GKAchievement resetAchievementsWithCompletionHandler:^(NSError * _Nullable error) {
        if (error != nil) {
            NSLog(@"%@", [error localizedDescription]);
        }
    }];
}

@end
