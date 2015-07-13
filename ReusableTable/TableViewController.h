//
//  TableViewController.h
//  ReusableTable
//
//  Created by Harly on 15/7/10.
//  Copyright (c) 2015年 Harly. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomizedCell.h"
@interface TableViewController : UITableViewController<EditableCellDelegate>

@property (nonatomic,strong) NSMutableArray* finalArray;

@end
