//
//  DZDatePickerView.h
//  Pods
//
//  Created by zwz on 16/6/15.
//
//

#import <UIKit/UIKit.h>


typedef void (^DZDatePickerConfirmBlock) (NSDate *date);
typedef void (^DZDatePickerCancelBlock) ();

@interface DZDatePickerView : UIView <UIPickerViewDataSource, UIPickerViewDelegate>

/**
 *  当前选择的时间
 */
@property (nonatomic, strong) NSDate   *selectedDate;

/**
 *  title
 */
@property (nonatomic, strong) NSString *title;

/**
 *  弹出 DatePickerView
 *  @param superView              superView 传nil则默认显示在当前 window
 *  @param startDate              起始时间
 *  @param endDate                结束时间
 *  @param initialDate            初始化已选时间 传nil的话则默认选中第一行
 *  @param delta                  时间分钟粒度
 *  @param datePickerConfirmBlock 回调
 *  @param datePickerCancelBlock  回调
 */
- (void)showInView:(UIView *)superView
         startDate:(NSDate *)startDate
           endDate:(NSDate *)endDate
       initialDate:(NSDate *)initialDate
      minutesDelta:(NSUInteger)delta
           confirm:(DZDatePickerConfirmBlock)datePickerConfirmBlock
            cancel:(DZDatePickerCancelBlock)datePickerCancelBlock;

/**
 *  弹出 DatePickerView
 *  @param superView              superView 传nil则默认显示在当前 window
 *  @param startDate              起始时间
 *  @param days                   结束时间距离起始时间的天数
 *  @param initialDate            初始化已选时间 传nil的话则默认选中第一行
 *  @param delta                  时间分钟粒度
 *  @param earliestTime           每天的最早时间（格式为“08:30”）不需要的话传nil
 *  @param latestTime             每天的最晚时间（格式为“08:30”）不需要的话传nil
 *  @param datePickerConfirmBlock 回调
 *  @param datePickerCancelBlock 回调
 */
- (void)showInView:(UIView *)superView
         startDate:(NSDate *)startDate
              days:(NSUInteger)days
       initialDate:(NSDate *)initialDate
      minutesDelta:(NSUInteger)delta
      earliestTime:(NSString *)earliestTime
        latestTime:(NSString *)latestTime
           confirm:(DZDatePickerConfirmBlock)datePickerConfirmBlock
            cancel:(DZDatePickerCancelBlock)datePickerCancelBlock;

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

@end
