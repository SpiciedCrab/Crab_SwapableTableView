//
//  CustomizedCell.h
//  ReusableTable
//
//  Created by Harly on 15/7/10.
//  Copyright (c) 2015年 Harly. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomizedCell : UITableViewCell<UIGestureRecognizerDelegate>
@property (weak, nonatomic) IBOutlet UILabel *titleText;

@end
