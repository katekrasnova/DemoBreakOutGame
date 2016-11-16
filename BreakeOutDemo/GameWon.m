//
//  GameWon.m
//  BreakeOutDemo
//
//  Created by Ekaterina Krasnova on 14.05.16.
//  Copyright © 2016 Ekaterina Krasnova. All rights reserved.
//

#import "GameWon.h"
#import "GameScene.h"

@implementation GameWon

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (touches) {
        SKView *skView = (SKView *)self.view;
        [self removeFromParent];
        
        GameScene *scene = [GameScene nodeWithFileNamed:@"GameScene"];
        scene.scaleMode = SKSceneScaleModeAspectFill;
        
        [skView presentScene:scene];
    }
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
}

@end
