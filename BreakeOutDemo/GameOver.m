//
//  GameOver.m
//  BreakeOutDemo
//
//  Created by Ekaterina Krasnova on 10.05.16.
//  Copyright © 2016 Ekaterina Krasnova. All rights reserved.
//

#import "GameOver.h"
#import "GameScene.h"

@implementation GameOver

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    /* Called when a touch begins */
    if (touches) {
        SKView * skView = (SKView *)self.view;
        
        GameScene *scene = [GameScene nodeWithFileNamed:@"GameScene"];
        scene.scaleMode = SKSceneScaleModeAspectFill;
        
        [skView presentScene:scene];
    }
}

@end
