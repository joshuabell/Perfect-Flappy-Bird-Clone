//
//  MMGlobal.m
//  Flappy Bird
//
//  Created by Joshua Bell on 2/11/14.
//

#import "MMGlobal.h"
#import "MMAtlas.h"

@interface MMGlobal ()

- (id)init;
@end

@implementation MMGlobal

+ (MMGlobal *)sharedInstance
{
    static MMGlobal *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[MMGlobal alloc] init];
        // Do any other initialisation stuff here
    });
    return sharedInstance;
}

- (id)init
{

    if ( self = [super init] )
    {
         _atlas = [[MMAtlas alloc] init];
    }

    return self;
}

@end
