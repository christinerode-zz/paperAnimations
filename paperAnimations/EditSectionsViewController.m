//
//  EditSectionsViewController.m
//  paperAnimations
//
//  Created by Christine Røde on 3/10/14.
//  Copyright (c) 2014 Christine Røde. All rights reserved.
//

#import "EditSectionsViewController.h"

@interface EditSectionsViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *cardFacebook;
@property (weak, nonatomic) IBOutlet UIImageView *placeholderCard;
@property (weak, nonatomic) IBOutlet UIImageView *cardHeadlines;

@property CGPoint currentLocation;
@property (nonatomic, strong) UIDynamicAnimator *animator;
@property (nonatomic, strong) UIAttachmentBehavior *attachment;
@property (nonatomic, strong) UIGravityBehavior *gravity;
@property (nonatomic, strong) UIDynamicItemBehavior *dynamic;

@property (nonatomic, assign) CGPoint originalPosition;


@property (nonatomic, assign) BOOL dragging;


- (void)onDrag:(UIPanGestureRecognizer *)gesture;


@end

@implementation EditSectionsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Do any additional setup after loading the view from its nib.
    
    self.placeholderCard.alpha = 0;
    
    // Animation setup shit
    _animator = [[UIDynamicAnimator alloc] initWithReferenceView:self.view];
    _gravity = [[UIGravityBehavior alloc] init];
    
    _dynamic = [[UIDynamicItemBehavior alloc] init];
    _dynamic.allowsRotation = YES;
    _dynamic.angularResistance = 1;
    
    self.originalPosition = self.cardHeadlines.frame.origin;
    
    [_animator addBehavior:_gravity];
    [_animator addBehavior:_dynamic];
    
    UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(onDrag:)];
    
    [self.cardHeadlines addGestureRecognizer:panRecognizer];
    
}

- (void)onDrag:(UIPanGestureRecognizer *)gesture {
    
    
    CGPoint touchPoint = [gesture locationInView:self.view];
    CGPoint tapPoint = [gesture locationInView:gesture.view];
    UIView* draggedView = gesture.view;
    
    // On begnning
    if(gesture.state == UIGestureRecognizerStateBegan){
        _dragging = YES;
        
        _currentLocation = [gesture locationInView:self.view];
        
        [_animator updateItemUsingCurrentState:self.view];
        
        _attachment = [[UIAttachmentBehavior alloc] initWithItem:draggedView attachedToAnchor:_currentLocation];
        _attachment.frequency = 0;
        _attachment.length = 1;

        [_animator addBehavior:_attachment];
        [_gravity addItem:draggedView];
        [_dynamic addItem:draggedView];
        
        [UIView animateWithDuration:0.2 animations:^{
            self.placeholderCard.alpha = 1;
            
            CGRect card1 = self.cardFacebook.frame;
                card1 = CGRectMake(50, card1.origin.y, card1.size.width, card1.size.height);
            CGRect empty = self.placeholderCard.frame;
                empty = CGRectMake(empty.origin.x-50, empty.origin.y, empty.size.width, empty.size.height);
            
        }];
        
        [UIView animateWithDuration:1 delay:0 options:UIViewAnimationOptionAutoreverse|UIViewAnimationOptionRepeat animations:^{
            [UIView setAnimationRepeatCount:100];
            gesture.view.transform = CGAffineTransformMakeRotation(M_PI/90);
        } completion:^(BOOL finished) { }];
        
        
    // On change
    }
    
    if(gesture.state == UIGestureRecognizerStateChanged && _dragging){
        
        [_attachment setAnchorPoint:touchPoint];
        
        _currentLocation = [gesture locationInView:self.view];


    }
    
    if(gesture.state == UIGestureRecognizerStateEnded){
        _dragging = NO;
        [gesture.view.layer removeAllAnimations];
        
            [UIView animateWithDuration:0.3 animations:^{
                self.placeholderCard.alpha = 0;
                
                if(_currentLocation.y < 300){
                    draggedView.frame = CGRectMake(self.placeholderCard.frame.origin.x,
                                                      self.placeholderCard.frame.origin.y,
                                                      self.placeholderCard.frame.size.width,
                                                      self.placeholderCard.frame.size.height);
                    
                    NSLog(@"IT ENDED @ %f, SNAP INTO TOP", _currentLocation.y);
                    
                } else if (_currentLocation.y > 300) {
                    draggedView.frame = CGRectMake(self.originalPosition.x,
                                                          self.originalPosition.y,
                                                          self.cardHeadlines.frame.size.width,
                                                          self.cardHeadlines.frame.size.height);
                    
                    NSLog(@"IT ENDED @ %f, SNAP INTO BOTTOM", _currentLocation.y);

                }
                    
            } completion:^(BOOL finished) {
                [_gravity removeItem:draggedView];
                [_dynamic addItem:draggedView];
                [_animator removeBehavior:_attachment];

            }];
        
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
