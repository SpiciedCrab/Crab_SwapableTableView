//
//  ViewController.m
//  ReusableTable
//
//  Created by Harly on 15/7/10.
//  Copyright (c) 2015年 Harly. All rights reserved.
//

#import "ViewController.h"
#import "TableViewController.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentControl;

@property (nonatomic,strong) NSArray* firstArray;
@property (nonatomic,strong) NSArray* secondArray;

@property (weak, nonatomic) IBOutlet UITableView *reuseTableView;

@property (nonatomic,strong) NSArray* finalArray;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    TableViewController* tableViewVc =  self.childViewControllers[0];
    tableViewVc.finalArray = [[NSMutableArray alloc]initWithArray:self.firstArray];
    // Do any additional setup after loading the view, typically from a nib.
}


-(NSArray*)firstArray
{
    if(!_firstArray)
        _firstArray = [[NSArray alloc]initWithObjects:@"first",@"second",@"third", nil];
    return _firstArray;
}

-(NSArray*)secondArray
{
    if(!_secondArray)
        _secondArray = [[NSArray alloc]initWithObjects:@"one",nil];
    return _secondArray;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)segmentChanged:(id)sender {
    UISegmentedControl* seg = sender;
    TableViewController* tableViewVc =  self.childViewControllers[0];
    if(seg.selectedSegmentIndex == 0)
        tableViewVc.finalArray = [[NSMutableArray alloc]initWithArray:self.firstArray];
    else if(seg.selectedSegmentIndex == 1)
        tableViewVc.finalArray = [[NSMutableArray alloc]initWithArray:self.secondArray];
    else
        tableViewVc.finalArray = [[NSMutableArray alloc]init];
    [tableViewVc.view performSelector:@selector(reloadData)];
    
}



@end
