//
// Created by Joshua Bell on 2/11/14.
//

#import <Foundation/Foundation.h>

@class SKTexture;
@class SKNode;
@interface MMAtlas : NSObject

- (id)init;

-(SKTexture *)textureNamed:(NSString *)name;
-(SKNode *)numberNodeWithInteger:(NSInteger)aInteger;
-(SKNode *)scoreboardNumberWithInteger:(NSInteger)aInteger;

@end