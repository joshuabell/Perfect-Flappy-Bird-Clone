//
//  MMGlobal.h
//  Flappy Bird
//
//  Created by Joshua Bell on 2/11/14.
//

#import <Foundation/Foundation.h>

@class MMAtlas;

@interface MMGlobal : NSObject

@property (readonly, strong, nonatomic) MMAtlas *atlas;

+ (MMGlobal *)sharedInstance;

@end
