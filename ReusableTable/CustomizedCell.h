//
//  CustomizedCell.h
//  ReusableTable
//
//  Created by Harly on 15/7/10.
//  Copyright (c) 2015年 Harly. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol EditableCellDelegate <NSObject>

@optional
-(void)willBeginEditCell:(UITableViewCell*)cell;
-(void)didBeginEditCell:(UITableViewCell*)cell;

-(void)willEndEditCell:(UITableViewCell*)cell;
-(void)didEndEditCell:(UITableViewCell*)cell;

-(UIView*)editingAreaForCell:(UITableViewCell*)cell;

@end


@interface CustomizedCell : UITableViewCell<UIGestureRecognizerDelegate>
@property (weak, nonatomic) IBOutlet UILabel *titleText;
@property (weak,nonatomic) id<EditableCellDelegate> editDelegate;

//manually swap the cell to edit in code.
-(void)swapToEdit;
@end
