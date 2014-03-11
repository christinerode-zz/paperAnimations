//
//  MainViewController.m
//  paperAnimations
//
//  Created by Christine Røde on 2/27/14.
//  Copyright (c) 2014 Christine Røde. All rights reserved.
//

#import "MainViewController.h"
#import "KASlideShow.h"
#import "EditSectionsViewController.h"

@interface MainViewController ()

- (void)onLongPress:(UILongPressGestureRecognizer *)panGestureRecognizer;
// - (void)onDragCards:(UIPanGestureRecognizer *)panGestureRecognizer;


@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIView *foreground;
@property (nonatomic, assign) CGPoint localtouch;

@property (strong, nonatomic) KASlideShow *slideshow;
@property (nonatomic, assign) BOOL isMenuRevealed;

@property (weak, nonatomic) IBOutlet UIView *menu;
@property (assign, nonatomic) CGRect mySensitiveRect;

@property (weak, nonatomic) UINavigationController *mvc;

@end

@implementation MainViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        self.title = @"Main View";
    }
    return self;
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    
    self.scrollView.contentSize = CGSizeMake(2348, 255);
    [self.scrollView setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin];
    
    UILongPressGestureRecognizer *pressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(onLongPress:)];
    pressGestureRecognizer.minimumPressDuration = 0.2;
    [self.foreground addGestureRecognizer:pressGestureRecognizer];
    
    
    // Slideshow! Plugin installed using CocoaPods
    _slideshow = [[KASlideShow alloc] initWithFrame:CGRectMake(0,0,320,568)];
    [_slideshow setDelay:3]; // Delay between transitions
    [_slideshow setTransitionDuration:1]; // Transition duration
    [_slideshow setTransitionType:KASlideShowTransitionFade]; // Choose a transition type (fade or slide)
    [_slideshow setImagesContentMode:UIViewContentModeScaleAspectFill]; // Choose a content mode for images to display
    [_slideshow addImagesFromResources:@[@"feature",@"feature2",@"feature3"]]; // Add images from resources
    [_slideshow start];
    
    [self.foreground addSubview:_slideshow];
    [self.foreground sendSubviewToBack:_slideshow];
    
    self.mySensitiveRect = CGRectMake(0.0, 300.0, 320.0, 100.0);
    
    UITapGestureRecognizer *gr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleGesture:)];
    
    gr.numberOfTapsRequired = 1;
    
    self.menu.userInteractionEnabled = YES;
    [self.menu addGestureRecognizer:gr];
    



}

- (void)handleGesture:(UIGestureRecognizer *)gestureRecognizer {
    CGPoint p = [gestureRecognizer locationInView:self.menu];
    if (CGRectContainsPoint(self.mySensitiveRect, p)) {
        
    EditSectionsViewController *controller = [[EditSectionsViewController alloc] init];
        
     UIWindow *window = [UIApplication sharedApplication].keyWindow;
       [window.rootViewController presentViewController:controller animated:YES completion:^{
           NSLog(@"Omg it worked");
       }];
    }
    

}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark

- (void)onLongPress:(UILongPressGestureRecognizer *)pressGestureRecognizer {
  
    CGPoint touch = [pressGestureRecognizer locationInView:self.view];
    CGRect moveableForeground = self.foreground.frame;
    
    // I didn't even need this range for anything oh wells
    CGFloat const inMin = 0;
    CGFloat const inMax = 568;
    CGFloat const outMin = 1;
    CGFloat const outMax = 0;
    CGFloat in;
    CGFloat out;
    
    // On begin -- Set localtouch location
    if(pressGestureRecognizer.state == UIGestureRecognizerStateBegan){
        in = touch.y-self.localtouch.y;
        out = outMin + (outMax - outMin) * (in - inMin) / (inMax - inMin);
        
        self.localtouch = [pressGestureRecognizer locationInView:self.foreground];
        moveableForeground = CGRectMake(moveableForeground.origin.x, in, 320, 568);
        
        NSLog(@"Saved touch location: %f", self.localtouch.y);
    }
    
    // On change -- Update location, do math do create friction
    if(pressGestureRecognizer.state == UIGestureRecognizerStateChanged){
        in = touch.y-self.localtouch.y;
        out = outMin + (outMax - outMin) * (in - inMin) / (inMax - inMin);
        
        if(in < 0){
            NSLog(@"Undamped: %f", in);
            in = in-(in*0.90);
            NSLog(@"Damped: %f", in);
        }
        
        pressGestureRecognizer.view.frame = CGRectMake(moveableForeground.origin.x, in, 320, 568);
        
    }
    
    // On end - animate to final destination
    if(pressGestureRecognizer.state == UIGestureRecognizerStateEnded){
        
        [UIView animateWithDuration:0.5 animations:^{
            if(moveableForeground.origin.y > 150 && !_isMenuRevealed){
                pressGestureRecognizer.view.frame = CGRectMake(moveableForeground.origin.x, 525, 320, 568);
                _isMenuRevealed = YES;
                NSLog(@"Animated to 550");
                
            } else if(moveableForeground.origin.y > 400 && _isMenuRevealed) {
                pressGestureRecognizer.view.frame = CGRectMake(moveableForeground.origin.x, 0, 320, 568);
                _isMenuRevealed = NO;
                NSLog(@"Animated to 0");
                
            } else {
                pressGestureRecognizer.view.frame = CGRectMake(moveableForeground.origin.x, 0, 320, 568);
                _isMenuRevealed = NO;
                NSLog(@"Animated to 0");
            }
        }];
    }
    
}

/* 
 > Taking out because I don't have time to figure out overlapping gestures :(
 > Will try to learn how to drag and resize the cards later.
 
 - (void)onDragCards:(UIPanGestureRecognizer *)scrollDragGesture {
 CGPoint touch = [scrollDragGesture locationInView:self.view];
 
 if(scrollDragGesture.state == UIGestureRecognizerStateBegan){
 NSLog(@"Touch!: %f", touch.y);
 }
 
 if(scrollDragGesture.state == UIGestureRecognizerStateChanged){
 self.scrollView.frame = CGRectMake(0, touch.y, self.scrollView.frame.size.width, self.view.frame.size.height-touch.y);
 
 NSLog(@"Resized! New pixels: %f", self.view.frame.size.height-touch.y);
 
 }
 
 if(scrollDragGesture.state  == UIGestureRecognizerStateEnded){
 
 }
 
 } */


@end
