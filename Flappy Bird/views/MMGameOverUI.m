//
// Created by Joshua Bell on 2/13/14.
//

#import "MMGameOverUI.h"
#import "MMGlobal.h"
#import "MMAtlas.h"

#define SLIDE_IN_TIME 0.3
#define ALPHA_IN_TIME 0.4

static NSString *const USER_DEFAULTS_MAX_SCORE_KEY = @"MAX_SCORE";

@interface MMGameOverUI ()

@property (strong, nonatomic) SKSpriteNode *gameOverImage;
@property (strong, nonatomic) SKSpriteNode *scoreboardBackground;
@property (strong, nonatomic) SKSpriteNode *playAgainButton;
//@property (strong, nonatomic) SKSpriteNode *playAgainButtonTwo;
@property (strong, nonatomic) SKSpriteNode *theNewScoreText;
@property (strong, nonatomic) SKNode       *highScoreImageDigits;
@property (strong, nonatomic) SKNode       *curScoreImageDigits;
@property (strong, nonatomic) SKNode       *scoreBoardContainer;
@property (assign, nonatomic) NSInteger     scoreIncrementCounter;
@property (assign, nonatomic) NSInteger     curScore;
@property (assign, nonatomic) NSInteger     tempMaxScore;
@property (assign, nonatomic) CGSize        theSceneSize;

-(SKSpriteNode *)medalForScore:(NSInteger)aScore;
-(void)showScoreboard;
-(void)showPlayAgainButton;
@end

@implementation MMGameOverUI


- (void)setupWithSceneSize:(CGSize)aSceneSize;
{

    self.theSceneSize = aSceneSize;
    self.position = CGPointMake( self.theSceneSize.width / 2, 0 );

    SKTexture *gameOverTexture = [[MMGlobal sharedInstance].atlas textureNamed:@"text_game_over"];
    self.gameOverImage = [SKSpriteNode spriteNodeWithTexture:gameOverTexture];
    self.gameOverImage.position = CGPointMake(0, self.theSceneSize.height * 0.75f);
    self.gameOverImage.alpha = 0;
    [self addChild:self.gameOverImage];

    SKTexture *scoreboardBackgroundTexture = [[MMGlobal sharedInstance].atlas textureNamed:@"score_panel"];
    self.scoreboardBackground = [SKSpriteNode spriteNodeWithTexture:scoreboardBackgroundTexture];
    self.scoreBoardContainer = [SKNode node];
    self.scoreBoardContainer.position = CGPointMake(0, -126);
    self.scoreBoardContainer.alpha = 0;
    [self addChild:self.scoreBoardContainer];

    SKTexture *playAgainButton = [[MMGlobal sharedInstance].atlas textureNamed:@"button_play"];
    self.playAgainButton = [SKSpriteNode spriteNodeWithTexture:playAgainButton];
    self.playAgainButton.position = CGPointMake( 0, -70);
    self.playAgainButton.name = @"playAgainButton";
    self.playAgainButton.alpha = 0;
    [self addChild:self.playAgainButton];

//    SKTexture *playAgainTwoButton = [[MMGlobal sharedInstance].atlas textureNamed:@"button_play"];
//    self.playAgainButtonTwo = [SKSpriteNode spriteNodeWithTexture:playAgainTwoButton];
//    self.playAgainButtonTwo.position = CGPointMake(self.playAgainButton.size.width * 1.2 - self.playAgainButtonTwo.size.width / 1.65, theSceneSize.height * 0.35f);
//    self.playAgainButtonTwo.name = @"playAgainButtonTwo";
//    [self addChild:self.playAgainButtonTwo];

    SKTexture *newText = [[MMGlobal sharedInstance].atlas textureNamed:@"new"];
    self.theNewScoreText = [SKSpriteNode spriteNodeWithTexture:newText];
    self.theNewScoreText.position = CGPointMake( 36, -4 );

}


-(void)showWithFinalScore:(NSInteger)finalScore
{

    self.curScore = finalScore;
    [self.gameOverImage runAction:[SKAction fadeInWithDuration:ALPHA_IN_TIME]];
    [self performSelector:@selector(showScoreboard) withObject:nil afterDelay:0.3];
}


-(void)showScoreboard
{

    [self.scoreBoardContainer addChild:self.scoreboardBackground];
    NSInteger maxScore = [[NSUserDefaults standardUserDefaults] integerForKey:USER_DEFAULTS_MAX_SCORE_KEY];
    self.tempMaxScore = maxScore;
    if (maxScore < self.curScore )
    {

        [self.scoreBoardContainer addChild:self.theNewScoreText];
        [[NSUserDefaults standardUserDefaults] setInteger:self.curScore forKey:USER_DEFAULTS_MAX_SCORE_KEY];
    }

    self.highScoreImageDigits = [[MMGlobal sharedInstance].atlas scoreboardNumberWithInteger:maxScore];
    CGFloat curHighScoreOriginX = 99 - [self.highScoreImageDigits calculateAccumulatedFrame].size.width;
    self.highScoreImageDigits.position = CGPointMake( curHighScoreOriginX, -23 );
    [self.scoreBoardContainer addChild:self.highScoreImageDigits];

    SKSpriteNode *medal = [self medalForScore:self.curScore];
    if ( nil != medal )
    {

        [self.scoreBoardContainer addChild:medal];
    }

    self.scoreIncrementCounter = 0;
    self.curScoreImageDigits = [[MMGlobal sharedInstance].atlas scoreboardNumberWithInteger:self.scoreIncrementCounter];
    CGFloat curScoreOriginX = 99 - [self.self.curScoreImageDigits calculateAccumulatedFrame].size.width;
    self.curScoreImageDigits.position = CGPointMake( curScoreOriginX, 19 );
    [self.scoreBoardContainer addChild:self.curScoreImageDigits];

    SKAction *alphaIn = [SKAction fadeInWithDuration:ALPHA_IN_TIME];
    SKAction *animationIn = [SKAction moveToY:(self.theSceneSize.height * 0.55f) duration:SLIDE_IN_TIME];
    [self.scoreBoardContainer runAction:alphaIn];
    __weak MMGameOverUI *theSelf = self;
    [self.scoreBoardContainer runAction:animationIn completion:^{
        [theSelf performSelector:@selector(incrementScore) withObject:nil afterDelay:0.5];
    }];
}


-(void)incrementScore
{
    if ( self.scoreIncrementCounter < self.curScore )
    {

        self.scoreIncrementCounter = self.scoreIncrementCounter + 1;
        [self.curScoreImageDigits removeFromParent];
        self.curScoreImageDigits = [[MMGlobal sharedInstance].atlas scoreboardNumberWithInteger:self.scoreIncrementCounter];
        CGFloat curScoreOriginX = 99 - [self.self.curScoreImageDigits calculateAccumulatedFrame].size.width;
        self.curScoreImageDigits.position = CGPointMake( curScoreOriginX, 19 );
        [self.scoreBoardContainer addChild:self.curScoreImageDigits];
        [self performSelector:@selector(incrementScore) withObject:nil afterDelay:0.07];

        if ( self.scoreIncrementCounter >= self.curScore )
        {

            if ( self.tempMaxScore < self.curScore )
            {

                NSInteger maxScore = [[NSUserDefaults standardUserDefaults] integerForKey:USER_DEFAULTS_MAX_SCORE_KEY];
                [self.highScoreImageDigits removeFromParent];
                self.highScoreImageDigits = [[MMGlobal sharedInstance].atlas scoreboardNumberWithInteger:maxScore];
                CGFloat curHighScoreOriginX = 99 - [self.highScoreImageDigits calculateAccumulatedFrame].size.width;
                self.highScoreImageDigits.position = CGPointMake( curHighScoreOriginX, -23 );
                [self.scoreBoardContainer addChild:self.highScoreImageDigits];
            }
        }
    }
    else
    {

         SKAction *slideIn = [SKAction moveToY:( self.theSceneSize.height * 0.35f ) duration:SLIDE_IN_TIME];
         SKAction *alphaIn = [SKAction fadeInWithDuration:ALPHA_IN_TIME];
         [self.playAgainButton runAction:slideIn];
         [self.playAgainButton runAction:alphaIn];

    }

}


-(void)showPlayAgainButton
{

}


-(SKSpriteNode *)medalForScore:(NSInteger)aScore
{

    SKSpriteNode *medal = nil;
    NSString *textureName = nil;
    if ( aScore >= 40 )
    {

        textureName = @"medals_0";
    }
    else if ( aScore >= 30 )
    {

        textureName = @"medals_1";
    }
    else if ( aScore >= 20 )
    {

        textureName = @"medals_2";
    }
    else if ( aScore >= 10 )
    {

        textureName = @"medals_3";
    }

    if ( nil != textureName )
    {

        SKTexture *medalTexture = [[MMGlobal sharedInstance].atlas textureNamed:textureName];
        medal = [SKSpriteNode spriteNodeWithTexture:medalTexture];
        medal.position = CGPointMake( -64, -3 );
    }

    return medal;
}


-(void)reset
{

    [self.scoreBoardContainer removeAllChildren];
    self.scoreBoardContainer.position = CGPointMake(self.scoreBoardContainer.position.x, -[self.scoreBoardContainer calculateAccumulatedFrame].size.height);
    self.playAgainButton.position = CGPointMake(self.playAgainButton.position.x, -self.playAgainButton.frame.size.height);
    self.scoreBoardContainer.alpha = 0;
    self.playAgainButton.alpha = 0;
    self.gameOverImage.alpha = 0;
}



@end