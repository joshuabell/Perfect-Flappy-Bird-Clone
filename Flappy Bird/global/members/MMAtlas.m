//
// Created by Joshua Bell on 2/11/14.
//

#import <SpriteKit/SpriteKit.h>
#import "MMAtlas.h"

@interface MMAtlas ()

@property (strong, nonatomic) NSMutableDictionary *textureForName;
@end


@implementation MMAtlas


- (id)init
{

    if ( self = [super init] )
    {

        NSString *qs = [[NSBundle mainBundle] pathForResource:@"atlas" ofType: @"txt"];
        NSString *fileContents = [NSString stringWithContentsOfFile:qs encoding:NSUTF8StringEncoding error:nil];
        NSArray *lines = [fileContents componentsSeparatedByString:@"\n"];
        self.textureForName = [NSMutableDictionary dictionaryWithCapacity:[lines count]];
        UIImage *atlas = [UIImage imageNamed:@"atlas"];
        SKTexture *atlasTexture = [SKTexture textureWithImage:atlas];
        for ( NSString *aImageInfo in lines )
        {

            NSArray *imageData = [aImageInfo componentsSeparatedByString:@" "];
            if ( 6 <= [imageData count] )
            {

                CGFloat originX = [[imageData objectAtIndex:3] floatValue];
                CGFloat sizeHeight = [[imageData objectAtIndex:6] floatValue];
                CGFloat originY =  1 - [[imageData objectAtIndex:4] floatValue] - sizeHeight ;
                CGFloat sizeWidth = [[imageData objectAtIndex:5] floatValue];

                CGRect atlasCoordinates = CGRectMake( originX, originY, sizeWidth, sizeHeight );
                SKTexture *aTexture = [SKTexture textureWithRect:atlasCoordinates inTexture:atlasTexture];
                [self.textureForName setObject:aTexture forKey:[imageData objectAtIndex:0]];
            }
        }

//        NSLog( @"dictionary of textures -> %@", self.textureForName );
    }

    return self;
}


-(SKTexture *)textureNamed:(NSString *)name
{


      return [self.textureForName objectForKey:name];
}


-(SKNode *)numberNodeWithInteger:(NSInteger)aInteger
{

    SKNode *integerImageRepresentation = [SKNode node];
    NSMutableArray *stringNumbers = [NSMutableArray arrayWithCapacity:3];
    while ( aInteger > 0 )
    {

        NSInteger lastDigit = aInteger % 10;
        [stringNumbers addObject:[NSString stringWithFormat:@"%ld", (long)lastDigit]];
        aInteger = aInteger / 10;
    }

    if( 0 == [stringNumbers count] )
    {

        NSString *digitKey = [NSString stringWithFormat:@"font_048"];
        SKTexture *digitTexture = [self.textureForName objectForKey:digitKey];
        SKSpriteNode *zero = [SKSpriteNode spriteNodeWithTexture:digitTexture];
        [integerImageRepresentation addChild:zero];
    }
    else
    {

        SKSpriteNode *lastNode = nil;
        for ( NSString *digit in [stringNumbers reverseObjectEnumerator] )
        {

            NSInteger convertedDigit = 48 + [digit integerValue];
            NSString *digitKey = [NSString stringWithFormat:@"font_0%ld", (long)convertedDigit];
            SKTexture *digitTexture = [self.textureForName objectForKey:digitKey];
            SKSpriteNode *aDigit = [SKSpriteNode spriteNodeWithTexture:digitTexture];
            CGFloat originX = ( lastNode == nil ) ? 0.0f : lastNode.size.width + 1;
            aDigit.position = CGPointMake( originX, 0 );
            [integerImageRepresentation addChild:aDigit];
            lastNode = aDigit;
        }
    }

    return integerImageRepresentation;
}


-(SKNode *)scoreboardNumberWithInteger:(NSInteger)aInteger
{


    SKNode *integerImageRepresentation = [SKNode node];
    NSMutableArray *stringNumbers = [NSMutableArray arrayWithCapacity:3];
    while ( aInteger > 0 )
    {

        NSInteger lastDigit = aInteger % 10;
        [stringNumbers addObject:[NSString stringWithFormat:@"%ld", (long)lastDigit]];
        aInteger = aInteger / 10;
    }

    if( 0 == [stringNumbers count] )
    {

        NSString *digitKey = [NSString stringWithFormat:@"number_score_00"];
        SKTexture *digitTexture = [self.textureForName objectForKey:digitKey];
        SKSpriteNode *zero = [SKSpriteNode spriteNodeWithTexture:digitTexture];
        [integerImageRepresentation addChild:zero];
    }
    else
    {

        SKSpriteNode *lastNode = nil;
        for ( NSString *digit in [stringNumbers reverseObjectEnumerator] )
        {

            NSInteger convertedDigit = [digit integerValue];
            NSString *digitKey = [NSString stringWithFormat:@"number_score_0%ld", (long)convertedDigit];
            SKTexture *digitTexture = [self.textureForName objectForKey:digitKey];
            SKSpriteNode *aDigit = [SKSpriteNode spriteNodeWithTexture:digitTexture];
            CGFloat originX = ( lastNode == nil ) ? 0.0f : lastNode.size.width + 1;
            aDigit.position = CGPointMake( originX, 0 );
            [integerImageRepresentation addChild:aDigit];
            lastNode = aDigit;
        }
    }

    return integerImageRepresentation;
}


@end