//
//  ViewController.m
//  DZDatePickerDemo
//
//  Created by zwz on 2016/11/9.
//  Copyright © 2016年 zwz. All rights reserved.
//

#import "ViewController.h"
#import "DZDatePickerView.h"

@interface ViewController ()

@property (nonatomic,strong)NSDate *dateA;
@property (nonatomic,strong)NSDate *dateB;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    UIButton *btnA = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnA setTitle:@"00:00 ~ 23:59" forState:UIControlStateNormal];
    [btnA setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    btnA.frame = CGRectMake((self.view.bounds.size.width - 180) / 2, 100, 180, 40);
    [self.view addSubview:btnA];
    [btnA addTarget:self action:@selector(btnAClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *btnB = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnB setTitle:@"08:30 ~ 22:00" forState:UIControlStateNormal];
    [btnB setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    btnB.frame = CGRectMake((self.view.bounds.size.width - 180) / 2, 200, 180, 40);
    [self.view addSubview:btnB];
    [btnB addTarget:self action:@selector(btnBClicked:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)btnAClicked:(UIButton *)sender {
    DZDatePickerView *picker = [[DZDatePickerView alloc] init];
    picker.clickBackViewToHide = YES;
    picker.title = @"00:00 ~ 23:59";
    [picker showInView:nil startDate:[NSDate date] endDate:[[NSDate date] dateByAddingTimeInterval:60 * 60 * 24 * 5] initialDate:self.dateA minutesDelta:15 confirm:^(NSDate *date) {
        self.dateA = date;
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
        NSString *timeStr = [dateFormatter stringFromDate:date];
        [sender setTitle:timeStr forState:UIControlStateNormal];
        NSLog(@"%@",timeStr);
    } cancel:NULL];
}

- (void)btnBClicked:(UIButton *)sender {
    DZDatePickerView *picker = [[DZDatePickerView alloc] init];
    picker.title = @"08:30 ~ 22:00";
    [picker showInView:nil startDate:[NSDate date] endDate:[[NSDate date] dateByAddingTimeInterval:60 * 60 * 24 * 5]  initialDate:self.dateB minutesDelta:15 earliestTime:@"08:30" latestTime:@"22:00" confirm:^(NSDate *date) {
        self.dateB = date;
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
        NSString *timeStr = [dateFormatter stringFromDate:date];
        [sender setTitle:timeStr forState:UIControlStateNormal];
        NSLog(@"%@",timeStr);
    } cancel:NULL];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
