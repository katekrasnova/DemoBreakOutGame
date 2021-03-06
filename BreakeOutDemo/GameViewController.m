//
//  GameViewController.m
//  BreakeOutDemo
//
//  Created by Ekaterina Krasnova on 09.05.16.
//  Copyright (c) 2016 Ekaterina Krasnova. All rights reserved.
//

#import "GameViewController.h"
#import "GameStart.h"
@import GameKit;

@implementation GameViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    GKLocalPlayer *playa = [GKLocalPlayer localPlayer];
    [playa setAuthenticateHandler:^(UIViewController * _Nullable viewController, NSError * _Nullable error) {
        //SKView * skView = (SKView *)self.view;
        //[skView setPaused:YES];
        if (error) {
            NSLog(@"Error here full %@", error);
        }
        if (viewController) {
            [self presentViewController:viewController animated:YES completion:nil];
        }
    }];

    // Configure the view.
    SKView * skView = (SKView *)self.view;
    skView.showsFPS = YES;
    skView.showsNodeCount = YES;
    /* Sprite Kit applies additional optimizations to improve rendering performance */
    skView.ignoresSiblingOrder = YES;
    
    // Create and configure the scene.
    GameStart *scene = [GameStart nodeWithFileNamed:@"GameStart"];
    scene.scaleMode = SKSceneScaleModeAspectFill;
    
    // Present the scene.
    [skView presentScene:scene];
}

- (BOOL)shouldAutorotate
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

@end
