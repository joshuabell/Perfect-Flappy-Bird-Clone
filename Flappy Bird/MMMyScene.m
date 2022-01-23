//
//  MMMyScene.m
//  Flappy Bird
//
//  Created by Joshua Bell on 2/10/14.
//

#import "MMMyScene.h"
#import "MMAtlas.h"
#import "MMGlobal.h"
#import "MMGameOverUI.h"
#import "OALSimpleAudio.h"

#define GOD_MODE NO
#define ARC4RANDOM_MAX      0x100000000
#define CHANCE_OF_DAY       0.7
#define VELOCITY_FLAP       355//390
#define GRAVITY             -8//-10
#define MASS_FLAPPYBIRD     8
#define GROUND_SPEED        137//136
#define FLAPPY_GROUND_CONTACT_Y 126
#define DISTANCE_X_BETWEEN_PIPES 206
#define DISTANCE_Y_BETWEEN_PIPES 106 // 101
#define MAX_PIPE_Y 500//255 // 235 // 535
#define MIN_PIPE_Y 170//130//-10 // 20 //150
#define OFFSET_Y_FOR_IPHONE4S_AND_LESS 60

static const uint32_t flappyBirdHeroCategory    =  0x1 << 0;
static const uint32_t pipeCategory              =  0x1 << 1;

typedef enum
{

    MMGameplayStateGetReadyUI = 1,
    MMGameplayStatePlaying,
    MMGameplaystateCrashing,
    MMGameplayStateGameOverUI

} MMGameplayState;



@interface MMMyScene () <SKPhysicsContactDelegate>

@property (strong, nonatomic) SKSpriteNode *background;
@property (strong, nonatomic) SKSpriteNode *backgroundNight;
@property (strong, nonatomic) SKSpriteNode *ground0;
@property (strong, nonatomic) SKSpriteNode *ground1;
@property (strong, nonatomic) SKSpriteNode *pipeUp0;
@property (strong, nonatomic) SKSpriteNode *pipeDown0;
@property (strong, nonatomic) SKSpriteNode *pipeUp1;
@property (strong, nonatomic) SKSpriteNode *pipeDown1;
@property (strong, nonatomic) SKSpriteNode *pipeUp2;
@property (strong, nonatomic) SKSpriteNode *pipeDown2;
@property (strong, nonatomic) SKSpriteNode *flappyBird;
@property (assign, nonatomic) MMGameplayState gameplayState;
@property (assign, nonatomic) NSInteger     currentScore;
@property (weak, nonatomic) SKSpriteNode    *nextCandidatePipe;
@property (strong, nonatomic) SKNode        *scoreImage;
@property (strong, nonatomic) SKNode        *instructionNode;
@property (strong, nonatomic) MMGameOverUI  *gameOverUI;
@property (strong, nonatomic) NSArray       *curBirdAnimationFrames;
@property (strong, nonatomic) SKAction      *curFlappyingAction;
@property (assign, nonatomic) CGFloat        deviceOffsetOriginY;
@property (assign, nonatomic) CGFloat        extraHeightForSmallScreen;
@property (assign, nonatomic) CGFloat        squatScreenPipeSubtraction;

- (void)initForDevice;
- (void)switchBackground;
- (void)initGround;
- (void)initPipes;
- (void)startPhysics;
- (void)stopPhysics;
- (void)parallaxGround;
- (void)parallaxPipes;
- (CGFloat)randPipePositionY;
- (void)resetGame;
- (void)updateScore;
- (void)initPipesPosition;

@end

@implementation MMMyScene
{
    NSTimeInterval _lastUpdateTime;
    NSTimeInterval _deltaTime;
}

-(id)initWithSize:(CGSize)size {    
    if (self = [super initWithSize:size]) {
        /* Setup your scene here */
        
        [self initForDevice];

        self.currentScore = 0;
        [self initBackgrounds];
        [self initPipes];
        [self initGround];
        [self initUI];
        [self resetGame];
        self.gameOverUI = [MMGameOverUI node];
        [self.gameOverUI setupWithSceneSize:self.size];
        self.gameOverUI.position = CGPointMake( self.gameOverUI.position.x, self.deviceOffsetOriginY );
        [[OALSimpleAudio sharedInstance] preloadEffect:@"sfx_wing.caf"];
        [[OALSimpleAudio sharedInstance] preloadEffect:@"sfx_die.caf"];
        [[OALSimpleAudio sharedInstance] preloadEffect:@"sfx_hit.caf"];
        [[OALSimpleAudio sharedInstance] preloadEffect:@"sfx_point.aif"];
        [[OALSimpleAudio sharedInstance] preloadEffect:@"sfx_swooshing.caf"];
    }
    return self;
}

-(void)initForDevice
{

    NSLog(@"height %f", self.size.height);
    // 0.563380 is iPhone SE: short screen 568
    // 0.462203 is 13 Pro max: long screen 692.336449
    // 0.461823 is iPhone X: long screen 692.906667
    CGFloat isLongScreen = 630 < self.size.height;
    if ( isLongScreen )
    {
        self.deviceOffsetOriginY = 0;
        self.extraHeightForSmallScreen = 0;
    }
    else
    {

        self.squatScreenPipeSubtraction = -100;
    }
}



- (void)initUI
{

    self.instructionNode = [SKNode node];
    SKTexture *readyTexture = [[MMGlobal sharedInstance].atlas textureNamed:@"text_ready"];
    SKSpriteNode *getReadyImage = [SKSpriteNode spriteNodeWithTexture:readyTexture];
    getReadyImage.position = CGPointMake( 0, 0);
    [self.instructionNode addChild:getReadyImage];

    SKTexture *graphicInstructionTexture = [[MMGlobal sharedInstance].atlas textureNamed:@"tutorial"];
    SKSpriteNode *graphicInstructionImage = [SKSpriteNode spriteNodeWithTexture:graphicInstructionTexture];
    graphicInstructionImage.position = CGPointMake(0, -graphicInstructionImage.size.height * .9);
    [self.instructionNode addChild:graphicInstructionImage];
    self.instructionNode.position = CGPointMake(CGRectGetMidX(self.frame), self.frame.size.height * 0.67 + self.deviceOffsetOriginY);
//
//    self.scoreImage = [[MMGlobal sharedInstance].atlas numberNodeWithInteger:self.currentScore];
//    self.scoreImage.position = CGPointMake(CGRectGetMidX(self.frame), self.size.height * 0.8 + self.deviceOffsetOriginY);
}

-(void)resetGame
{

//    [self switchBackground];
    [self.gameOverUI removeFromParent];
    self.currentScore = 0;
    self.scoreImage = [[MMGlobal sharedInstance].atlas numberNodeWithInteger:self.currentScore];
    self.scoreImage.position = CGPointMake(CGRectGetMidX(self.frame) - self.scoreImage.frame.size.width / 2, self.size.height * 0.8 + self.deviceOffsetOriginY + self.extraHeightForSmallScreen);
    [self addChild:self.scoreImage];
    [self addChild:self.instructionNode];
    [self initPipesPosition];
    self.nextCandidatePipe = self.pipeUp0;
    [self resetFlappyBird];
    self.gameplayState = MMGameplayStateGetReadyUI;
    [self.gameOverUI reset];
    [self switchBackground];
}


-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    /* Called when a touch begins */

    switch ( self.gameplayState )
    {

        case MMGameplayStateGetReadyUI:
        {

            [self startPhysics];
            [self performSelector:@selector(flapFlappyBird) withObject:nil afterDelay:0.01];
            break;
        }
        case MMGameplayStatePlaying:
        {

            [self flapFlappyBird];
            break;
        }
        case MMGameplaystateCrashing:
            // do nothing

            break;
        case MMGameplayStateGameOverUI:
        {

            UITouch *touch = [touches anyObject];
            CGPoint location = [touch locationInNode:self];
            SKNode *node = [self nodeAtPoint:location];

            if ( [node.name isEqualToString:@"playAgainButton"] || [node.name isEqualToString:@"playAgainButtonTwo"] )
            {

                [[OALSimpleAudio sharedInstance] playEffect:@"sfx_swooshing.caf"];
                [self resetGame];
                
                
//                if ( SHOW_CHARTBOOST_ADS_AND_MOREGAMES )
//                {
//                    
//                    [[Chartboost sharedChartboost] showInterstitial:CBLocationLevelComplete];
//                    [Flurry logEvent:@"called showInterstitial method"];
//                }
            }
            
            break;
        }
        default:
        {
//            NSLog( @"state not recoginized" );
            break;
        }
    }
}

-(void)flapFlappyBird
{

    self.flappyBird.physicsBody.velocity = CGVectorMake(0, VELOCITY_FLAP);
    [[OALSimpleAudio sharedInstance] playEffect:@"sfx_wing.caf"];
}

-(void)update:(CFTimeInterval)currentTime
{

    /* Called before each frame is rendered */
    if (_lastUpdateTime)
    {

        _deltaTime = currentTime - _lastUpdateTime;
    }
    else
    {

        _deltaTime = 0;
    }
    _lastUpdateTime = currentTime;
    if ( self.gameplayState == MMGameplayStateGetReadyUI )
    {

        [self parallaxGround];
    }
    else if ( self.gameplayState == MMGameplayStatePlaying )
    {

        [self parallaxGround];
        [self parallaxPipes];
        [self updateScore];

        // check for flappy hit ground
        if ( FLAPPY_GROUND_CONTACT_Y >= self.flappyBird.position.y )
        {

            [[OALSimpleAudio sharedInstance] playEffect:@"sfx_hit.caf"];
            [[OALSimpleAudio sharedInstance] playEffect:@"sfx_die.caf"];
            [self stopPhysics];
        }

        // check for flappy hit ceiling

        CGFloat ceilingHeight = self.size.height - self.flappyBird.size.height / 3  + self.deviceOffsetOriginY + self.extraHeightForSmallScreen;
        if ( ceilingHeight < self.flappyBird.position.y )
        {

            self.flappyBird.position = CGPointMake(self.flappyBird.position.x, ceilingHeight );
        }

        // rotate flappy
        if ( self.flappyBird.physicsBody.velocity.dy > -230 )
        {

             if ( self.flappyBird.zRotation < M_PI_4 / 3)
             {

                 self.flappyBird.zRotation = self.flappyBird.zRotation + (M_PI_4 / 3);
             }
             else
             {

                 self.flappyBird.zRotation = self.flappyBird.zRotation = M_PI_4 / 3;
             }

             if ( ![self.flappyBird hasActions] )
             {

                 [self.flappyBird runAction:self.curFlappyingAction];
             }
        }
        else
        {

            if ( self.flappyBird.zRotation >  -(M_PI_4 ))
            {

                self.flappyBird.zRotation = self.flappyBird.zRotation - (M_PI_4 / 9);
                if ( [self.flappyBird hasActions] )
                {

                    [self.flappyBird removeAllActions];
                }

            }
            else
            {

                self.flappyBird.zRotation = -(M_PI_4);
            }
        }

    }
    else if ( self.gameplayState == MMGameplaystateCrashing )
    {

        if ( self.flappyBird.zRotation > -M_PI_2 )
        {

            self.flappyBird.zRotation = self.flappyBird.zRotation - ( M_PI_4 / 3 );
            if ( self.flappyBird.zRotation < -M_PI_2 )
            {

                self.flappyBird.zRotation = -M_PI_2;
            }
        }

        if ( FLAPPY_GROUND_CONTACT_Y >= self.flappyBird.position.y )
        {

            self.gameplayState = MMGameplayStateGameOverUI;
            self.flappyBird.position = CGPointMake(self.flappyBird.position.x, FLAPPY_GROUND_CONTACT_Y );
            [self performSelector:@selector(showGameOverUI) withObject:nil afterDelay:0.3];
        }
        else
        {

            self.flappyBird.position = CGPointMake( self.flappyBird.position.x, self.flappyBird.position.y - 8 );
        }
    }
}


- (void)showGameOverUI
{

    [self.flappyBird removeFromParent];
    [self addChild:self.gameOverUI];
    [self.gameOverUI showWithFinalScore:self.currentScore];
}

- (void)updateScore
{

    if ( self.nextCandidatePipe.position.x < self.flappyBird.position.x )
    {

        [[OALSimpleAudio sharedInstance] playEffect:@"sfx_point.aif"];
        self.currentScore = self.currentScore + 1;
        [self.scoreImage removeFromParent];
        self.scoreImage = [[MMGlobal sharedInstance].atlas numberNodeWithInteger:self.currentScore];
        self.scoreImage.position = CGPointMake(CGRectGetMidX(self.frame) - self.scoreImage.frame.size.width / 2, self.size.height * 0.8 + self.extraHeightForSmallScreen + self.deviceOffsetOriginY);
        [self addChild:self.scoreImage];

        if ( self.nextCandidatePipe == self.pipeUp0 )
        {

            self.nextCandidatePipe = self.pipeUp1;
        }
        else if ( self.nextCandidatePipe == self.pipeUp1 )
        {

            self.nextCandidatePipe = self.pipeUp2;
        }
        else if ( self.nextCandidatePipe == self.pipeUp2 )
        {
            self.nextCandidatePipe = self.pipeUp0;
        }

    }
}


- (void)parallaxPipes
{

    self.pipeUp0.position = CGPointMake(self.pipeUp0.position.x-(GROUND_SPEED * _deltaTime), self.pipeUp0.position.y);
    self.pipeDown0.position = CGPointMake(self.pipeDown0.position.x-(GROUND_SPEED * _deltaTime), self.pipeDown0.position.y);
    if ( self.pipeUp0.position.x < -self.pipeUp0.size.width )
    {

        CGFloat pipe0PositionY = [self randPipePositionY];
        self.pipeUp0.position = CGPointMake( self.pipeUp2.position.x + DISTANCE_X_BETWEEN_PIPES, pipe0PositionY );
        self.pipeDown0.position = CGPointMake( self.pipeUp2.position.x + DISTANCE_X_BETWEEN_PIPES, pipe0PositionY + DISTANCE_Y_BETWEEN_PIPES );
    }

    self.pipeUp1.position = CGPointMake(self.pipeUp1.position.x-(GROUND_SPEED * _deltaTime), self.pipeUp1.position.y);
    self.pipeDown1.position = CGPointMake(self.pipeDown1.position.x-(GROUND_SPEED * _deltaTime), self.pipeDown1.position.y);
    if ( self.pipeUp1.position.x < -self.pipeUp1.size.width )
    {

        CGFloat pipe1PositionY = [self randPipePositionY];
        self.pipeUp1.position = CGPointMake( self.pipeUp0.position.x + DISTANCE_X_BETWEEN_PIPES, pipe1PositionY );
        self.pipeDown1.position = CGPointMake( self.pipeDown0.position.x + DISTANCE_X_BETWEEN_PIPES, pipe1PositionY + DISTANCE_Y_BETWEEN_PIPES );
    }


    self.pipeUp2.position = CGPointMake(self.pipeUp2.position.x-(GROUND_SPEED * _deltaTime), self.pipeUp2.position.y);
    self.pipeDown2.position = CGPointMake(self.pipeDown2.position.x-(GROUND_SPEED * _deltaTime), self.pipeDown2.position.y);
    if ( self.pipeUp2.position.x < -self.pipeUp2.size.width )
    {

        CGFloat pipe2PositionY = [self randPipePositionY];
        self.pipeUp2.position = CGPointMake( self.pipeUp1.position.x + DISTANCE_X_BETWEEN_PIPES, pipe2PositionY );
        self.pipeDown2.position = CGPointMake( self.pipeDown1.position.x + DISTANCE_X_BETWEEN_PIPES, pipe2PositionY + DISTANCE_Y_BETWEEN_PIPES );
    }
}


- (void)parallaxGround
{

    self.ground0.position = CGPointMake(self.ground0.position.x-(GROUND_SPEED * _deltaTime), self.ground0.position.y);
    self.ground1.position = CGPointMake(self.ground1.position.x-(GROUND_SPEED * _deltaTime), self.ground1.position.y);

    if (self.ground0.position.x < -self.ground0.size.width)
    {

        self.ground0.position = CGPointMake(self.ground1.position.x + self.ground1.size.width - 1, self.ground0.position.y);
    }

    if (self.ground1.position.x < -self.ground1.size.width)
    {

        self.ground1.position = CGPointMake(self.ground0.position.x + self.ground0.size.width - 1, self.ground1.position.y);
    }
}


-(void)initBackgrounds
{


    //    [self.background removeFromParent];

//      NSString *backgroundName = @"land_0";
    SKTexture *backgroundTexture = [[MMGlobal sharedInstance].atlas textureNamed:@"bg_day"];
    SKTexture *backgroundNightTexture = [[MMGlobal sharedInstance].atlas textureNamed:@"bg_night"];

    self.background = [SKSpriteNode spriteNodeWithTexture:backgroundTexture];
    self.backgroundNight = [SKSpriteNode spriteNodeWithTexture:backgroundNightTexture];
    self.background.size = self.frame.size;
    self.backgroundNight.size = self.frame.size;
    self.background.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
    self.backgroundNight.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
//    [self insertChild:self.background atIndex:0];
    [self addChild:self.background];
    [self addChild:self.backgroundNight];

}


-(void)switchBackground
{

    double random = ((double)arc4random() / ARC4RANDOM_MAX);
    if ( random < CHANCE_OF_DAY )
    {

        [self.background setHidden:NO];
        [self.backgroundNight setHidden:YES];
    }
    else
    {

        [self.background setHidden:YES];
        [self.backgroundNight setHidden:NO];
    }
}



- (void)initPipes
{

    NSString *pipeUpName = @"pipe_up";
    SKTexture *pipeUpTexture = [[MMGlobal sharedInstance].atlas textureNamed:pipeUpName];
    self.pipeUp0 = [SKSpriteNode spriteNodeWithTexture:pipeUpTexture];
    self.pipeUp1 = [SKSpriteNode spriteNodeWithTexture:pipeUpTexture];
    self.pipeUp2 = [SKSpriteNode spriteNodeWithTexture:pipeUpTexture];
    
    
    self.pipeUp0.anchorPoint = CGPointMake( 0.5f, 1 );
    self.pipeUp0.size = CGSizeMake(52, 520);
    [self addPhysicsToPipe:self.pipeUp0 isUpPipe:YES];
    [self addChild:self.pipeUp0];
    NSLog( @"Anchor point x is %f, y %f", self.pipeUp0.anchorPoint.x, self.pipeUp0.anchorPoint.y);

//    self.pipeUp1.anchorPoint = CGPointZero;
    self.pipeUp1.anchorPoint = CGPointMake( 0.5f, 1 );
    self.pipeUp1.size = CGSizeMake(52, 520);
    [self addPhysicsToPipe:self.pipeUp1 isUpPipe:YES];
    [self addChild:self.pipeUp1];

//    self.pipeUp2.anchorPoint = CGPointZero;
    self.pipeUp2.anchorPoint = CGPointMake( 0.5f, 1 );
    self.pipeUp2.size = CGSizeMake(52, 520);
    [self addPhysicsToPipe:self.pipeUp2 isUpPipe:YES];
    [self addChild:self.pipeUp2];

    NSString *pipeDownName = @"pipe_down";
    SKTexture *pipeDownTexture = [[MMGlobal sharedInstance].atlas textureNamed:pipeDownName];
    self.pipeDown0 = [SKSpriteNode spriteNodeWithTexture:pipeDownTexture];
    self.pipeDown0.size = CGSizeMake(52, 520);
//    NSLog( @"width is %f", self.pipeDown0.size.height);
    self.pipeDown0.anchorPoint = CGPointMake( 0.5f, 0 );
    [self addPhysicsToPipe:self.pipeDown0 isUpPipe:NO];
    [self addChild:self.pipeDown0];

    self.pipeDown1 = [SKSpriteNode spriteNodeWithTexture:pipeDownTexture];
    self.pipeDown1.size = CGSizeMake(52, 520);

    self.pipeDown1.anchorPoint = CGPointMake( 0.5f, 0 );
    [self addPhysicsToPipe:self.pipeDown1 isUpPipe:NO];
    [self addChild:self.pipeDown1];

    self.pipeDown2 = [SKSpriteNode spriteNodeWithTexture:pipeDownTexture];
    self.pipeDown2.size = CGSizeMake(52, 520);

    self.pipeDown2.anchorPoint = CGPointMake( 0.5f, 0 );
    [self addPhysicsToPipe:self.pipeDown2 isUpPipe:NO];
    [self addChild:self.pipeDown2];
}

- (void)initPipesPosition
{
    CGFloat pipe2PositionY = [self randPipePositionY];
    CGFloat pipe1PositionY = [self randPipePositionY];
    CGFloat pipe0PositionY = [self randPipePositionY];
    self.pipeUp0.position = CGPointMake( 640, pipe0PositionY );
    self.pipeUp1.position = CGPointMake( self.pipeUp0.position.x + DISTANCE_X_BETWEEN_PIPES, pipe1PositionY);
    self.pipeUp2.position = CGPointMake( self.pipeUp1.position.x + DISTANCE_X_BETWEEN_PIPES, pipe2PositionY );
    self.pipeDown0.position = CGPointMake( self.pipeUp0.position.x, DISTANCE_Y_BETWEEN_PIPES + pipe0PositionY);
    self.pipeDown1.position = CGPointMake( self.pipeUp1.position.x, DISTANCE_Y_BETWEEN_PIPES + pipe1PositionY);
    self.pipeDown2.position = CGPointMake( self.pipeUp2.position.x, DISTANCE_Y_BETWEEN_PIPES + pipe2PositionY);
}

-(void)addPhysicsToPipe:(SKSpriteNode *)aPipe isUpPipe:(BOOL)isUpPipe
{
    if ( !GOD_MODE )
    {
        
        CGFloat centerY = aPipe.size.height / 2;
        centerY *= isUpPipe ? -1 : 1;
        CGPoint center = CGPointMake( 0, centerY);
        aPipe.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:aPipe.size center:center];
        aPipe.physicsBody.dynamic = NO;
        aPipe.physicsBody.categoryBitMask = pipeCategory;
        aPipe.physicsBody.contactTestBitMask = flappyBirdHeroCategory;
        aPipe.physicsBody.collisionBitMask = 0;
        aPipe.physicsBody.usesPreciseCollisionDetection = YES;
    }
}
-(void)initGround
{

    NSString *groundName = @"land";
    SKTexture *backgroundTexture = [[MMGlobal sharedInstance].atlas textureNamed:groundName];
    self.ground0 = [SKSpriteNode spriteNodeWithTexture:backgroundTexture];
    self.ground0.anchorPoint = CGPointZero;
    self.ground0.position = CGPointZero;
//    self.ground0.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));

    [self addChild:self.ground0];

    self.ground1 = [SKSpriteNode spriteNodeWithTexture:backgroundTexture];
    self.ground1.anchorPoint = CGPointZero;
    self.ground1.position = CGPointMake(self.ground0.size.width - 1, 0);
    [self addChild:self.ground1];
}


- (void)resetFlappyBird
{

    self.curBirdAnimationFrames = [self randomBirdColor];
    SKTexture *backgroundTexture = [self.curBirdAnimationFrames objectAtIndex:0];
    self.flappyBird = [SKSpriteNode spriteNodeWithTexture:backgroundTexture];
    self.flappyBird.position = CGPointMake(100, 300 + 5);
    [self.flappyBird setScale:1.1];
    [self addChild:self.flappyBird];
    SKAction *flappingAction = [SKAction animateWithTextures:self.curBirdAnimationFrames timePerFrame:0.06f resize:NO restore:YES];
    self.curFlappyingAction = [SKAction repeatActionForever:flappingAction];
    [self.flappyBird runAction:self.curFlappyingAction];
    self.flappyBird.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:CGSizeMake(22, 22)];
    self.flappyBird.physicsBody.mass = MASS_FLAPPYBIRD;
    if ( !GOD_MODE )
    {

        self.flappyBird.physicsBody.categoryBitMask = flappyBirdHeroCategory;
        self.flappyBird.physicsBody.contactTestBitMask = pipeCategory;
        self.flappyBird.physicsBody.collisionBitMask = 0;
        self.flappyBird.physicsBody.usesPreciseCollisionDetection = YES;
        self.physicsWorld.contactDelegate = self;
    }
    self.physicsWorld.gravity = CGVectorMake(0, 0);
}



- (void)startPhysics
{




    self.physicsWorld.gravity = CGVectorMake(0, GRAVITY);
//    [self drawPhysicsBodies];
    [self.instructionNode removeFromParent];
    self.gameplayState = MMGameplayStatePlaying;
//    [Flurry logEvent:@"Play did start"];
 

}


- (void)stopPhysics
{

    [self.flappyBird removeAllActions];
    [self.scoreImage removeFromParent];
    self.flappyBird.position = CGPointMake(self.flappyBird.position.x, FLAPPY_GROUND_CONTACT_Y);
    self.flappyBird.physicsBody.velocity = CGVectorMake(0, 0);
    self.physicsWorld.gravity = CGVectorMake(0, 0);
    self.physicsWorld.contactDelegate = nil;
    self.gameplayState = MMGameplaystateCrashing;
//    NSNumber *score = [NSNumber numberWithInteger:self.currentScore];
//    [Flurry logEvent:@"Play did end" withParameters:[NSDictionary dictionaryWithObject:score forKey:@"Score"]];
}


-(CGFloat)randPipePositionY
{

    CGFloat maxPipeY = MAX_PIPE_Y + self.squatScreenPipeSubtraction;
    return ((CGFloat)(arc4random_uniform(maxPipeY - MIN_PIPE_Y) + MIN_PIPE_Y)) ;

}


- (void)didBeginContact:(SKPhysicsContact *)contact
{

    NSLog( @"contact -> %@", contact );
    [self.sceneDelegate shakeScreen];
    [[OALSimpleAudio sharedInstance] playEffect:@"sfx_hit.caf"];
    [[OALSimpleAudio sharedInstance] playEffect:@"sfx_die.caf"];
    [self stopPhysics];
}

- (NSArray *)randomBirdColor
{

    NSInteger numFrames = 3;
    NSInteger birdRange = labs((NSInteger)arc4random() % numFrames);
    NSMutableArray *textures = [NSMutableArray arrayWithCapacity:numFrames];
    for ( NSInteger i = 0; i < numFrames; ++i )
    {

        NSString *textureName = [NSString stringWithFormat:@"bird%ld_%ld", (long)birdRange, (long)i];
        SKTexture *aBirdTexture = [[MMGlobal sharedInstance].atlas textureNamed:textureName];
        [textures addObject:aBirdTexture];
    }

    return [NSArray arrayWithArray:textures];
}


@end
