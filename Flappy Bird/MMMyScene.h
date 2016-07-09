//
//  MMMyScene.h
//  Flappy Bird
//
//

#import <SpriteKit/SpriteKit.h>

@protocol MMMySceneDelegate

-(void)shakeScreen;

@end

@interface MMMyScene : SKScene

@property (weak, nonatomic) id<MMMySceneDelegate> sceneDelegate;

@end
