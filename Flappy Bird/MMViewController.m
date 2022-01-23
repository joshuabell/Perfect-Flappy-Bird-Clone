//
//  MMViewController.m
//  Flappy Bird
//
//  Created by Joshua Bell on 2/10/14.
//

#import "MMViewController.h"
#import "MMMyScene.h"

@interface MMViewController () <MMMySceneDelegate>

@end


@implementation MMViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Configure the view.
    SKView * skView = (SKView *)self.view;
//    skView.showsFPS = YES;
//    skView.showsNodeCount = YES;
//    skView.showsPhysics = YES;
//    skView.showsFields = YES;
    // Create and configure the scene.
    CGSize screenSize = [UIScreen mainScreen].bounds.size;    
    CGFloat height = (screenSize.height / screenSize.width) * 320.0f;
    CGSize sceneSize = CGSizeMake(320.0f, height);
    MMMyScene * scene = [MMMyScene sceneWithSize:sceneSize];
    scene.sceneDelegate = self;
    scene.scaleMode = SKSceneScaleModeAspectFill;
    
    // Present the scene.
    [skView presentScene:scene];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillResignActive:) name:UIApplicationWillResignActiveNotification object:nil];
}

- (BOOL)shouldAutorotate
{
    return NO;
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return UIInterfaceOrientationMaskAllButUpsideDown;
    } else {
        return UIInterfaceOrientationMaskAll;
    }
}

-(void)shakeScreen
{
    CAKeyframeAnimation * anim = [ CAKeyframeAnimation animationWithKeyPath:@"transform" ] ;
    anim.values = @[ [ NSValue valueWithCATransform3D:CATransform3DMakeTranslation(-3.0f, 0.0f, 0.0f) ], [ NSValue valueWithCATransform3D:CATransform3DMakeTranslation(3.0f, 0.0f, 0.0f) ] ] ;
    anim.autoreverses = YES ;
    anim.repeatCount = 4.0f ;
    anim.duration = 0.05f ;

    [ self.view.layer addAnimation:anim forKey:nil ] ;
}

-(void)applicationDidBecomeActive:(NSNotification *)aNotification
{
 
    SKView * skView = (SKView *)self.view;
    if ( skView.paused )
    {
        skView.paused = NO;
    }
    
}
-(void)applicationWillResignActive:(NSNotification *)aNotification
{
    
    SKView * skView = (SKView *)self.view;
    if ( !skView.paused )
    {
        skView.paused = YES;
    }
}
@end
