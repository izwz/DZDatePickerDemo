DZDatePickerView
===
#简介(summary)
DZDatePickerView是一个时间选择器，可以设定开始时间，结束时间，初始化时间，时间颗粒度，以及每天的时间限制（比如08:00至22:00）

Author:`zwz` E-mail:`izwz@outlook.com`

#GIF示例和屏幕截图(screenShot)
![example](https://github.com/zwz293299/DZDatePickerDemo/blob/master/example.gif)
![screenShot](https://github.com/zwz293299/DZDatePickerDemo/blob/master/ScreenShot.png)

#1 code
``` Objective-C
/**
 *  弹出 DatePickerView
 *  @param superView              superView 传nil则默认显示在当前 window
 *  @param startDate              起始时间
 *  @param endDate                结束时间
 *  @param initialDate            初始化已选时间 传nil的话则默认选中第一行
 *  @param delta                  时间分钟粒度
 *  @param earliestTime           每天的最早时间（格式为“08:30”）不需要的话传nil
 *  @param latestTime             每天的最晚时间（格式为“08:30”）不需要的话传nil
 *  @param datePickerConfirmBlock 回调
 *  @param datePickerCancelBlock 回调
 */
- (void)showInView:(UIView *)superView
         startDate:(NSDate *)startDate
           endDate:(NSDate *)endDate
       initialDate:(NSDate *)initialDate
      minutesDelta:(NSUInteger)delta
      earliestTime:(NSString *)earliestTime
        latestTime:(NSString *)latestTime
           confirm:(DZDatePickerConfirmBlock)datePickerConfirmBlock
            cancel:(DZDatePickerCancelBlock)datePickerCancelBlock;
```


#使用 (how to use)

``` Objective-C
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
```




