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
@property (weak, nonatomic) IBOutlet UIView *editingAreaView;

@property (nonatomic, strong) UIPanGestureRecognizer *panRecognizer;
@property (nonatomic) CGPoint panStartPoint;
@property (nonatomic) CGFloat startingRightLayoutConstraintConstant;
@property (nonatomic) CGFloat originalFixedConstant;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *contentViewRightConstraint;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *contentViewLeftConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *realContentLeftConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *realContentRightConstraint;


@end

@implementation CustomizedCell
static CGFloat const kBounceValue = 20.0f;

- (void)awakeFromNib {
    self.panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panCell:)];
    self.panRecognizer.delegate = self;

    
    [self.realContentView addGestureRecognizer:self.panRecognizer];
    // Initialization code
}

-(void)drawRect:(CGRect)rect
{
    //If you want to use the view you customized in your delegate,these statements will adjust the original editingarea view's frame to fit your view
    //Then update the constraints , but unfortunately, there's a little missing part in your customized view when put into the editingarea.
    if([self.editDelegate respondsToSelector:@selector(editingAreaForCell:)])
    {
        UIView* customizedView = [self.editDelegate editingAreaForCell:self];
        float deltaOriginX = self.editingAreaView.frame.size.width - customizedView.frame.size.width;
        [self.editingAreaView setFrame:CGRectMake(self.editingAreaView.frame.origin.x, 0, customizedView.frame.size.width, customizedView.frame.size.height)];
        [self.editingAreaView addSubview: customizedView];
        
        self.realContentLeftConstraint.constant += deltaOriginX;
    }
    
    //In xib files ,when constraints are added to the contents, the minumum constant is always -8,
    //not zero, I dont know why, perhaps you can fix it
    //ToDo: to fix -8 =>0
    self.originalFixedConstant = self.contentViewLeftConstraint.constant;
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
            if (self.startingRightLayoutConstraintConstant == self.originalFixedConstant) {
                
                //open editing area.
                if (!panningLeft) {
                    CGFloat constant = MAX(-deltaX, self.originalFixedConstant);
                    if (constant == self.originalFixedConstant) {
                        [self resetConstraintToZeroWithAnimated:YES notifyDelegateDidClose:NO];
                    } else {
                        self.contentViewRightConstraint.constant = constant;
                    }
                } else {
                    
                    //You can pan right anyway then constraint will be set to zero at the end of the gesture.
                    //It's a better experience for users to pan left/right.
                    self.contentViewRightConstraint.constant = self.startingRightLayoutConstraintConstant - deltaX;
                    self.contentViewLeftConstraint.constant = -self.contentViewRightConstraint.constant;
                    
                    //Comment area is from the references but deleted due to the experience.
//                    CGFloat constant = MIN(-deltaX, [self editAreaWidth]);
//                    if (constant == [self editAreaWidth]) {
//                        [self setConstraintsToShowEditAreaWithAnimated:YES notifyDelegateDidOpen:NO];
//                    } else {
//                        self.contentViewRightConstraint.constant = constant;
//                    }
                }
            }
            else
            {
                //The cell was at least partially open.
                CGFloat adjustment = self.startingRightLayoutConstraintConstant - deltaX;
                //1
                if (!panningLeft) {
                    if(adjustment == -self.originalFixedConstant)
                    {
                        [self resetConstraintToZeroWithAnimated:YES notifyDelegateDidClose:NO];
                    }
                    else
                    {
                        self.contentViewRightConstraint.constant = adjustment;
                    }
                    //Now i choose to close the editing area once you pan right.
                    
//                    CGFloat constant = MAX(adjustment, -8);
//                    //2
//                    if (constant == -8) {
//                        //3
//                        [self resetConstraintToZeroWithAnimated:YES notifyDelegateDidClose:NO];
//                    } else {
//                        //4
//                        self.contentViewRightConstraint.constant = constant;
//                    }
                } else {
//                    CGFloat constant = MIN(adjustment, [self editAreaWidth]);
//                    //6
//                    if (constant == [self editAreaWidth]) {
//                        //7
//                        [self setConstraintsToShowAllButtons:YES notifyDelegateDidOpen:NO];
//                    } else {
//                        //8
//                        self.contentViewRightConstraint.constant = constant;
//                    }
                    
                    //5
                    self.contentViewRightConstraint.constant = adjustment;
//                    [self setConstraintsToShowEditAreaWithAnimated:YES notifyDelegateDidOpen:NO];
                }
                
                self.contentViewLeftConstraint.constant = -self.contentViewRightConstraint.constant;
            }
            
            break;
        }

        case UIGestureRecognizerStateEnded:
        {
            if (self.startingRightLayoutConstraintConstant == self.originalFixedConstant) {
                //1
                
                //Cell was opening-> you can fix the halfEditingWidth to meet your experience
                CGFloat halfEditingWidth = CGRectGetWidth(self.editingAreaView.frame) / 2;
                //2
                if (self.contentViewRightConstraint.constant >= halfEditingWidth) {
                    //3
                    
                    //Open all the way
                    [self setConstraintsToShowEditAreaWithAnimated:YES notifyDelegateDidOpen:YES];
                } else {
                    
                    //Re-close
                    [self resetConstraintToZeroWithAnimated:YES notifyDelegateDidClose:YES];
                }
            } else {
                
                //Cell was closing
                CGFloat editAreaWith = CGRectGetWidth(self.editingAreaView.frame)+self.originalFixedConstant*2;
                //4
                if (self.contentViewRightConstraint.constant >= editAreaWith) {
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
            if (self.startingRightLayoutConstraintConstant == self.originalFixedConstant) {
                
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
    return CGRectGetWidth(self.frame) - CGRectGetMinX(self.editingAreaView.frame);
}

- (void)resetConstraintToZeroWithAnimated:(BOOL)animated notifyDelegateDidClose:(BOOL)endEditing
{
    if (self.startingRightLayoutConstraintConstant == self.originalFixedConstant &&
        self.contentViewRightConstraint.constant == self.originalFixedConstant) {
        
        //Already all the way closed, no bounce necessary
        return;
    }
    
    self.contentViewRightConstraint.constant = -kBounceValue;
    self.contentViewLeftConstraint.constant = kBounceValue;
    
    if(endEditing)
    {
        if([self.editDelegate respondsToSelector:@selector(willEndEditCell:)])
        {
            [self.editDelegate willEndEditCell:self];
        }
    }
    
    [self updateConstraintsIfNeeded:animated completion:^(BOOL finished) {
        self.contentViewRightConstraint.constant = self.originalFixedConstant;
        self.contentViewLeftConstraint.constant = self.originalFixedConstant;
        
        if(endEditing)
        {
            if([self.editDelegate respondsToSelector:@selector(didEndEditCell:)])
            {
                [self.editDelegate didEndEditCell:self];
            }
        }
        
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
    
    if(notifyDelegate)
    {
        if([self.editDelegate respondsToSelector:@selector(willBeginEditCell:)])
        {
            [self.editDelegate willBeginEditCell:self];
        }
    }
    
    [self updateConstraintsIfNeeded:animated completion:^(BOOL finished) {
        
        //3
        self.contentViewLeftConstraint.constant = -[self editAreaWidth]+self.originalFixedConstant;
        self.contentViewRightConstraint.constant = [self editAreaWidth]+self.originalFixedConstant*2;
        
        [self updateConstraintsIfNeeded:animated completion:^(BOOL finished) {
            
            if(notifyDelegate)
            {
                if([self.editDelegate respondsToSelector:@selector(didBeginEditCell:)])
                {
                    [self.editDelegate didBeginEditCell:self];
                }
            }
            //4
            self.startingRightLayoutConstraintConstant = self.contentViewRightConstraint.constant;
        }];
    }];
}

-(void)swapToEdit
{
    [self setConstraintsToShowEditAreaWithAnimated:YES notifyDelegateDidOpen:YES];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
