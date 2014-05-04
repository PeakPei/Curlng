//
//  CURViewController.m
//  Curlng
//
//  Created by Séraphin Hochart on 2014-04-26.
//  Copyright (c) 2014 Séraphin Hochart. All rights reserved.
//

#import "CURViewController.h"
#import "CURScene.h"

@implementation CURViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIButton *b_reset = [UIButton buttonWithType:UIButtonTypeSystem];
    b_reset.frame = CGRectMake(10.0f, self.view.frame.size.height - 30.0f, 100.0f, 15.0f);
    [b_reset setTitle:@"Reset" forState:UIControlStateNormal];
    [b_reset addTarget:self action:@selector(resetGame) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:b_reset];
}

- (BOOL)shouldAutorotate {
    return NO;
}

- (void)resetGame {
    SKView * skView = (SKView *)self.view;
    [(CURScene *)skView.scene resetRocksPositions];
}

- (void)viewWillLayoutSubviews {
    
    [super viewWillLayoutSubviews];
    
    // Configure the view.
    SKView * skView = (SKView *)self.view;
    
    if (!skView.scene) {
        skView.showsFPS = NO;
        skView.showsNodeCount = NO;
        
        // Create and configure the scene.
        SKScene * scene = [CURScene sceneWithSize:skView.bounds.size];
        scene.scaleMode = SKSceneScaleModeAspectFill;
        
        // Present the scene.
        [skView presentScene:scene];
    }
}

- (NSUInteger)supportedInterfaceOrientations
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

@end
