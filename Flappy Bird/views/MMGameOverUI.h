//
// Created by Joshua Bell on 2/13/14.
//

#import <Foundation/Foundation.h>
#import <SpriteKit/SpriteKit.h>


@interface MMGameOverUI : SKNode

- (void)setupWithSceneSize:(CGSize)aSceneSize;
-(void)showWithFinalScore:(NSInteger)finalScore;
-(void)reset;
@end