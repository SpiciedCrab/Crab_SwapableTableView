//
//  CustomizedCell.m
//  ReusableTable
//
//  Created by Harly on 15/7/10.
//  Copyright (c) 2015年 Harly. All rights reserved.
//


#import "CustomizedCell.h"
@interface CustomizedCell()
@property (weak, nonatomic) IBOutlet UIView *realContentView;
@property (weak, nonatomic) IBOutlet UIButton *editButton;
@property (weak, nonatomic) IBOutlet UIButton *eatButton;

@property (nonatomic, strong) UIPanGestureRecognizer *panRecognizer;
@property (nonatomic, assign) CGPoint panStartPoint;
@property (nonatomic, assign) CGFloat startingRightLayoutConstraintConstant;

@property (nonatomic, weak) IBOutlet NSLayoutConstraint *contentViewRightConstraint;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *contentViewLeftConstraint;


@end

@implementation CustomizedCell
static CGFloat const kBounceValue = 20.0f;

- (IBAction)editTouched:(id)sender {
}
- (IBAction)eatTouched:(id)sender {
}

- (void)awakeFromNib {
    self.panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panCell:)];
    self.panRecognizer.delegate = self;
    [self.realContentView addGestureRecognizer:self.panRecognizer];
    // Initialization code
}


- (void)panCell:(UIPanGestureRecognizer *)recognizer {
    switch (recognizer.state) {
        case UIGestureRecognizerStateBegan:
        {
            self.panStartPoint = [recognizer translationInView:self.realContentView];
            self.startingRightLayoutConstraintConstant = self.contentViewRightConstraint.constant;
            break;
        }
            
        case UIGestureRecognizerStateChanged: {
            CGPoint currentPoint = [recognizer translationInView:self.realContentView];
            CGFloat deltaX = currentPoint.x - self.panStartPoint.x;
            BOOL panningLeft = NO;
            if (currentPoint.x < self.panStartPoint.x) {
                panningLeft = YES;
            }
            if (self.startingRightLayoutConstraintConstant == -8) {
                
                //No editing status -> editing area hidden now
                if (!panningLeft) {
                    CGFloat constant = MAX(-deltaX, -8);
                    if (constant == -8) {
                        [self resetConstraintToZeroWithAnimated:YES notifyDelegateDidClose:NO];
                    } else {
                        self.contentViewRightConstraint.constant = constant;
                    }
                } else {
                    CGFloat constant = MIN(-deltaX, [self editAreaWidth]);
                    if (constant == [self editAreaWidth]) {
                        [self setConstraintsToShowEditAreaWithAnimated:YES notifyDelegateDidOpen:NO];
                    } else {
                        self.contentViewRightConstraint.constant = constant;
                    }
                }
            }
            else
            {
                //The cell was at least partially open.
                CGFloat adjustment = self.startingRightLayoutConstraintConstant - deltaX;
                //1
                if (!panningLeft) {
                    CGFloat constant = MAX(adjustment, -8);
                    //2
                    if (constant == -8) {
                        //3
                        [self resetConstraintToZeroWithAnimated:YES notifyDelegateDidClose:NO];
                    } else {
                        //4
                        self.contentViewRightConstraint.constant = constant;
                    }
                } else {
                    CGFloat constant = MIN(adjustment, [self editAreaWidth]);
                    //5
                    if (constant == [self editAreaWidth]) {
                        //6
                        [self setConstraintsToShowEditAreaWithAnimated:YES notifyDelegateDidOpen:NO];
                    } else { 
                        //7
                        self.contentViewRightConstraint.constant = constant;
                    }
                }
                self.contentViewLeftConstraint.constant = -self.contentViewRightConstraint.constant;
            }
            
            break;
        }

        case UIGestureRecognizerStateEnded:
        {
            if (self.startingRightLayoutConstraintConstant == -8) {
                //1
                
                //Cell was opening
                CGFloat halfOfButtonOne = CGRectGetWidth(self.editButton.frame) / 2;
                //2
                if (self.contentViewRightConstraint.constant >= halfOfButtonOne) {
                    //3
                    
                    //Open all the way
                    [self setConstraintsToShowEditAreaWithAnimated:YES notifyDelegateDidOpen:YES];
                } else {
                    
                    //Re-close
                    [self resetConstraintToZeroWithAnimated:YES notifyDelegateDidClose:YES];
                }
            } else {
                
                //Cell was closing
                CGFloat buttonOnePlusHalfOfButton2 = CGRectGetWidth(self.editButton.frame) + (CGRectGetWidth(self.eatButton.frame) / 2);
                //4
                if (self.contentViewRightConstraint.constant >= buttonOnePlusHalfOfButton2) {
                    //5
                    
                    //Re-open all the way
                    [self setConstraintsToShowEditAreaWithAnimated:YES notifyDelegateDidOpen:YES];
                } else {
                    
                    //Close
                    [self resetConstraintToZeroWithAnimated:YES notifyDelegateDidClose:YES];
                }
            }
            break;
        }
        case UIGestureRecognizerStateCancelled:
        {
            if (self.startingRightLayoutConstraintConstant == -8) {
                
                //Cell was closed - reset everything to 0
                [self resetConstraintToZeroWithAnimated:YES notifyDelegateDidClose:YES];
            } else {
                
                //Cell was open - reset to the open state
                [self setConstraintsToShowEditAreaWithAnimated:YES notifyDelegateDidOpen:YES];
            }
            break;
        }
        default:
            break;
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

-(void)prepareForReuse
{
    [super prepareForReuse];
     [self resetConstraintToZeroWithAnimated:NO notifyDelegateDidClose:NO];
}

- (void)updateConstraintsIfNeeded:(BOOL)animated completion:(void (^)(BOOL finished))completion {
    float duration = 0;
    if (animated) {
        duration = 0.1;
    }
    
    [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        [self layoutIfNeeded];
    } completion:completion];
}

- (CGFloat)editAreaWidth {
    return CGRectGetWidth(self.frame) - CGRectGetMinX(self.editButton.frame);
}

- (void)resetConstraintToZeroWithAnimated:(BOOL)animated notifyDelegateDidClose:(BOOL)endEditing
{
    if (self.startingRightLayoutConstraintConstant == -8 &&
        self.contentViewRightConstraint.constant == -8) {
        
        //Already all the way closed, no bounce necessary
        return;
    }
    
    self.contentViewRightConstraint.constant = -kBounceValue;
    self.contentViewLeftConstraint.constant = kBounceValue;
    
    [self updateConstraintsIfNeeded:animated completion:^(BOOL finished) {
        self.contentViewRightConstraint.constant = -8;
        self.contentViewLeftConstraint.constant = -8;
        
        [self updateConstraintsIfNeeded:animated completion:^(BOOL finished) {
            self.startingRightLayoutConstraintConstant = self.contentViewRightConstraint.constant;
        }];
    }];
}

- (void)setConstraintsToShowEditAreaWithAnimated:(BOOL)animated notifyDelegateDidOpen:(BOOL)notifyDelegate
{
    //1
    if (self.startingRightLayoutConstraintConstant == [self editAreaWidth] &&
        self.contentViewRightConstraint.constant == [self editAreaWidth]) {
        return;
    }
    
    //2
    self.contentViewLeftConstraint.constant = -[self editAreaWidth] - kBounceValue;
    self.contentViewRightConstraint.constant = [self editAreaWidth] + kBounceValue;
    
    [self updateConstraintsIfNeeded:animated completion:^(BOOL finished) {
        
        //3
        self.contentViewLeftConstraint.constant = -[self editAreaWidth]-8;
        self.contentViewRightConstraint.constant = [self editAreaWidth]-16;
        
        [self updateConstraintsIfNeeded:animated completion:^(BOOL finished) {
            
            //4
            self.startingRightLayoutConstraintConstant = self.contentViewRightConstraint.constant;
        }];
    }];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
