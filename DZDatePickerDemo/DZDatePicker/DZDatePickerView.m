//
//  DZDatePickerView.m
//  Pods
//
//  Created by zwz on 16/6/15.
//
//


#import "DZDatePickerView.h"
#import "NSDate+DZPicker.h"

@interface NSMutableArray (DZPicker)
@end

@implementation NSMutableArray (DZPicker)
- (void)dz_addObject:(id)i{
    if (i!=nil) {
        [self addObject:i];
    }
}

@end

@interface NSArray (DZPicker)
@end

@implementation NSArray (DZPicker)
- (id)dz_objectAtIndex:(NSUInteger)index{
    if (index <self.count) {
        return self[index];
    }else{
        return nil;
    }
}

@end

typedef void (^DZPickerViewFinishedBlock) ();
static CGFloat const kDZDatePickerHeight = 252.0; /**< 整个picker的高度 */
static CGFloat const kDZDatePickerButtonWidth = 60.0; /**< 按钮的高度 */
static CGFloat const kDZDatePickerTopBarHeight = 60.0; /**< topBar的宽度 */
static CGFloat const kDZDatePickerBackAlpha = 0.3; /**<背景透明度 */
static CGFloat const kDZDatePickerAnimationDuration = 0.3;/**< 动画持续时间 */

#define kDZ_DATEPICKER_SCREEN_WIDTH        ([UIScreen mainScreen].bounds.size.width)
#define kDZ_DATEPICKER_SINGLE_LINE_WIDTH   (1 / [UIScreen mainScreen].scale)

@interface DZDatePickerView ()<UIPickerViewDataSource, UIPickerViewDelegate>

@property (nonatomic,copy) DZDatePickerConfirmBlock confirmBlock;
@property (nonatomic,copy) DZDatePickerCancelBlock  cancelBlock;

@property (nonatomic,strong) NSDate     *startDate;/**< 起始时间 */
@property (nonatomic,strong) NSDate     *endDate;/**< 结束时间 */
@property (nonatomic,strong) NSDate     *initialDate;/**< 初始化时间 */
@property (nonatomic,assign) NSUInteger delta;/**< 分钟粒度，增量 */

@property (nonatomic,assign) NSUInteger earliestHour;/**< 最早时刻：小时 */
@property (nonatomic,assign) NSUInteger earliestminute;/**< 最早时刻：分钟 */
@property (nonatomic,assign) NSUInteger latestHour;/**< 最晚时刻：小时 */
@property (nonatomic,assign) NSUInteger latestminute;/**< 最晚时刻：分钟 */

@property (nonatomic,strong) NSArray    *days;/**< 存储所有日期的数组 */

@property (nonatomic,strong) NSArray    *hours_early;/**< 存储前期小时数据的数组 */
@property (nonatomic,strong) NSArray    *hours_middle;/**< 存储所有普通小时数据的数组 */
@property (nonatomic,strong) NSArray    *hours_late;/**< 存储后期小时数据的数组 */

@property (nonatomic,strong) NSArray    *minutes_early;/**< 存储早期分钟数据的数组 */
@property (nonatomic,strong) NSArray    *minutes_middle;/**< 存储普通分钟数据的数组 */
@property (nonatomic,strong) NSArray    *minutes_late;/**< 存储后期分钟数据的数组 */
@property (nonatomic,strong) NSArray    *minutes_startHour;/**< 存储开始分钟数据的数组 */
@property (nonatomic,strong) NSArray    *minutes_endHour;/**< 存储结束分钟数据的数组 */

@property (nonatomic,strong) UIView     *contentView;
@property (nonatomic,strong) UIView     *backView;
@property (nonatomic,assign) CGRect     frameBeforeAnimation;
@property (nonatomic,assign) CGRect     frameOriginal;
@property (nonatomic,assign) CGSize     contentSize;

@property (nonatomic,strong) UIButton     *btnOK;
@property (nonatomic,strong) UIButton     *btnCancel;
@property (nonatomic,strong) UIPickerView *datePicker;
@property (nonatomic,strong) UILabel      *lblTitle;
@property (nonatomic,strong) UIView       *separateLine;

@end

@implementation DZDatePickerView

#pragma mark - init & dealloc

- (void)dealloc {
    _datePicker.delegate = nil;
    _datePicker.dataSource = nil;
    _confirmBlock = nil;
    _cancelBlock = nil;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.userInteractionEnabled = YES;
        self.backgroundColor = [UIColor clearColor];
        [self addSubview:self.backView];
        [self addSubview:self.contentView];
        self.contentView.frame = CGRectMake(0, 0, self.contentSize.width, self.contentSize.height);
        
        self.contentSize = CGSizeMake(kDZ_DATEPICKER_SCREEN_WIDTH, kDZDatePickerHeight);
        [self.contentView addSubview:self.btnCancel];
        [self.contentView addSubview:self.btnOK];
        [self.contentView addSubview:self.datePicker];
        [self.contentView addSubview:self.lblTitle];
        [self.contentView addSubview:self.separateLine];
    }
    return self;
}

#pragma mark - Picker show

- (UIView *)availableSuperView:(UIView *)view{
    UIView *superView;
    if (view) {
        superView = view;
    }else{
        superView = [[UIApplication sharedApplication].delegate window];
    }
    return superView;
}

- (void)showInView:(UIView *)view {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIView *superView = [self availableSuperView:view];
        self.frame = superView.bounds;
        self.backView.frame = superView.bounds;
        [superView addSubview:self];
        
        self.frameOriginal = CGRectMake((self.frame.size.width - self.contentSize.width) / 2,
                                        self.frame.origin.y + self.frame.size.height - self.contentSize.height,
                                        self.contentSize.width,
                                        self.contentSize.height);
        self.frameBeforeAnimation = self.frameOriginal;
        self->_frameBeforeAnimation.origin.y = self.frame.origin.y + self.frame.size.height;
        
        self.contentView.frame = self.frameBeforeAnimation;
        
        [UIView animateWithDuration:kDZDatePickerAnimationDuration animations:^{
            self.backView.alpha = kDZDatePickerBackAlpha;
            self.contentView.frame = self.frameOriginal;
        }completion:NULL];
    });
}

- (void)dismissViewFinished:(DZPickerViewFinishedBlock)block {
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:kDZDatePickerAnimationDuration animations:^{
            self.backView.alpha = 0;
            self.contentView.frame = self.frameBeforeAnimation;
        } completion:^(BOOL finished) {
            if (block) {
                block();
            }
            [self removeFromSuperview];
        }];
    });
}

- (void)showInView:(UIView *)superView
         startDate:(NSDate *)startDate
           endDate:(NSDate *)endDate
       initialDate:(NSDate *)initialDate
      minutesDelta:(NSUInteger)delta
           confirm:(DZDatePickerConfirmBlock)datePickerConfirmBlock
            cancel:(DZDatePickerCancelBlock)datePickerCancelBlock {
    [self showInView:superView
           startDate:startDate
             endDate:endDate
         initialDate:initialDate
        minutesDelta:delta
        earliestTime:nil
          latestTime:nil
             confirm:datePickerConfirmBlock
              cancel:datePickerCancelBlock];
}

- (void)showInView:(UIView *)superView
         startDate:(NSDate *)startDate
              days:(NSUInteger)days
       initialDate:(NSDate *)initialDate
      minutesDelta:(NSUInteger)delta
      earliestTime:(NSString *)earliestTime
        latestTime:(NSString *)latestTime
           confirm:(DZDatePickerConfirmBlock)datePickerConfirmBlock
            cancel:(DZDatePickerCancelBlock)datePickerCancelBlock {
    [self showInView:superView
           startDate:startDate
             endDate:[startDate dateByAddingDays:days]
         initialDate:initialDate
        minutesDelta:delta
        earliestTime:earliestTime
          latestTime:latestTime
             confirm:datePickerConfirmBlock
              cancel:datePickerCancelBlock];
}

- (void)showInView:(UIView *)superView
         startDate:(NSDate *)startDate
           endDate:(NSDate *)endDate
       initialDate:(NSDate *)initialDate
      minutesDelta:(NSUInteger)delta
      earliestTime:(NSString *)earliestTime
        latestTime:(NSString *)latestTime
           confirm:(DZDatePickerConfirmBlock)datePickerConfirmBlock
            cancel:(DZDatePickerCancelBlock)datePickerCancelBlock {
    
    [self setStartDate:startDate];
    [self setEndDate:endDate];
    self.initialDate = initialDate;
    
    [self setDelta:delta];
    [self setEarliestTime:earliestTime];
    [self setLatestTime:latestTime];
    
    self.confirmBlock = datePickerConfirmBlock;
    self.cancelBlock = datePickerCancelBlock;
    
    [self showInView:superView];
    [self reloadWithDate:initialDate];
}

#pragma mark - Date getter setter

- (void)reloadWithDate:(NSDate *)aDate {
    //如不设置初始时间默认显示第一项
    if (!aDate) {
        [_datePicker selectRow:0 inComponent:0 animated:NO];
        [_datePicker selectRow:0 inComponent:1 animated:NO];
        [_datePicker selectRow:0 inComponent:2 animated:NO];
        return;
    }
    
    NSUInteger aMinuteBeforeHandle = 0;
    NSUInteger aHour = [aDate hour];
    if (aHour < self.earliestHour) {
        aHour = self.earliestHour;
    }else if(aHour > self.latestHour){
        aHour = self.latestHour;
    }else if (aHour == self.earliestHour){
        aMinuteBeforeHandle = MAX(self.earliestminute, [aDate minute]);
    }else if (aHour == self.latestHour){
        aMinuteBeforeHandle = MIN(self.latestminute, [aDate minute]);
    }else{
        aMinuteBeforeHandle = [aDate minute];
    }
    
    NSUInteger aMinute = [self startMinute:aMinuteBeforeHandle];
    
    NSDate *newDate = [[[aDate dateAtStartOfDay] dateByAddingHours:aHour] dateByAddingMinutes:aMinute];
    if ([newDate isLaterThanDate:self.endDate] || [newDate isEarlierThanDate:self.startDate]) {
        return;
    }

    NSInteger dayIndex = 0;
    NSInteger hourIndex = 0;
    NSInteger minuteIndex = 0;
    for (NSDate *date in self.days) {
        if ([date isTheSameDay:newDate]) {
            dayIndex = [self.days indexOfObject:date];
            break;
        }
    }
    
    NSArray *hourArray = [self getHourWithDayIndex:dayIndex]?:[NSArray array];
    for (NSString *hour in hourArray) {
        if ([hour integerValue] == aHour) {
            hourIndex = [hourArray indexOfObject:hour];
            break;
        }
    }
    
    NSArray *minuteArray = [self getMinuteWithDayIndex:dayIndex hourIndex:hourIndex]?:[NSArray array];
    for (NSString *minute in minuteArray) {
        if ([minute integerValue] == aMinute) {
            minuteIndex = [minuteArray indexOfObject:minute];
            break;
        }
    }
    
    //不延迟一点时间会出bug，分钟那一栏reload有问题，很诡异，找不到原因
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.15 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [self.datePicker reloadComponent:0];
        [self.datePicker selectRow:dayIndex inComponent:0 animated:NO];
        [self.datePicker reloadComponent:1];
        [self.datePicker selectRow:hourIndex inComponent:1 animated:NO];
        [self.datePicker reloadComponent:2];
        [self.datePicker selectRow:minuteIndex inComponent:2 animated:NO];
    });
}

- (NSDate *)selectedDate {
    NSInteger dayIndex = [_datePicker selectedRowInComponent:0];
    NSInteger hourIndex = [_datePicker selectedRowInComponent:1];
    NSInteger minuteIndex = [_datePicker selectedRowInComponent:2];
    
    NSArray *days = self.days;
    NSArray *hourArray = [self getHourWithDayIndex:dayIndex];
    NSArray *minuteArray = [self getMinuteWithDayIndex:dayIndex hourIndex:hourIndex];
    
    NSDate *day = [days dz_objectAtIndex:dayIndex];
    NSInteger hour = [[hourArray dz_objectAtIndex:hourIndex] integerValue];
    NSInteger minute = [[minuteArray dz_objectAtIndex:minuteIndex] integerValue];
    NSDate *date = [[day dateByAddingHours:hour] dateByAddingMinutes:minute];
    return date;
}

#pragma mark - UIPickerViewDataSource
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 3;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    switch (component) {
        case 0:{
            return self.days.count;
        }
        case 1:{
            if (self.days.count == 0) {
                return 0;
            }
            NSInteger selectedDayIndex = [_datePicker selectedRowInComponent:0];
            return  [[self getHourWithDayIndex:selectedDayIndex] count];
        }
        case 2:{
            if (self.days.count == 0) {
                return 0;
            }
            NSInteger selectedDayIndex = [_datePicker selectedRowInComponent:0];
            NSInteger selectedHourIndex = [_datePicker selectedRowInComponent:1];
            NSArray *array = [self getMinuteWithDayIndex:selectedDayIndex hourIndex:selectedHourIndex];
            return [array count];
        }
        default:{
            return 0;
        }
    }
}

#pragma mark - UIPickerViewDelegate

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component{
    CGFloat width1 = [@"0000-00-00" boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, 34)
                                                options:(NSStringDrawingUsesLineFragmentOrigin |
                                                         NSStringDrawingTruncatesLastVisibleLine)
                                             attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:20]}
                                                context:nil].size.width;
    CGFloat width2 = [@"00" boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, 34)
                                                options:(NSStringDrawingUsesLineFragmentOrigin |
                                                         NSStringDrawingTruncatesLastVisibleLine)
                                             attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:20]}
                                                context:nil].size.width;
    CGFloat width3 = [@"00" boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, 34)
                                                options:(NSStringDrawingUsesLineFragmentOrigin |
                                                         NSStringDrawingTruncatesLastVisibleLine)
                                             attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:20]}
                                                context:nil].size.width;
    CGFloat gap = 0; //每个label除去显示文字的距离后，左右两边的空白距离
    CGFloat componentGap = 4; //两个Component之间的间距，用reveal可以看到
    gap = (kDZ_DATEPICKER_SCREEN_WIDTH - width1 - width2 - width3 - componentGap * 2) / 6;
    if (component == 0) {
        return width1 + gap * 2;
    }else if (component == 1){
        return width2 + gap * 2;
    }else if (component == 2){
        return width3 + gap * 2;
    }
    return 0;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component {
    return 34.0f;
}

- (UIView *)pickerView:(UIPickerView *)pickerView
            viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view {
    UILabel* lblContent;
    if (view && [view isKindOfClass:[UILabel class]]) {
        //pickerView 复用机制，貌似没什么卵用，好像是iOS7、8、9的bug，苹果一直不修复
        lblContent = (UILabel *)view;
    }else{
        CGRect rect = CGRectMake(0, 0,
                                 [pickerView rowSizeForComponent:component].width,
                                 [pickerView rowSizeForComponent:component].height);
        lblContent = [[UILabel alloc] initWithFrame:rect];
        lblContent.backgroundColor = [UIColor whiteColor];
        [lblContent setFont:[UIFont systemFontOfSize:20]];
        [lblContent setTextColor:[UIColor blackColor]];
        lblContent.textAlignment = NSTextAlignmentCenter;
    }
    switch (component) {
        case 0 : {
            NSDate *date = [self.days dz_objectAtIndex:row];
            if ([date isToday]) {
                lblContent.text = @"Today";
            }else{
                lblContent.text = [date stringWithFormat:@"yyyy-MM-dd"];
            }
        } break;
        case 1 : {
            NSInteger selectedDayIndex = [_datePicker selectedRowInComponent:0];
            NSArray *array = [self getHourWithDayIndex:selectedDayIndex];
            //同时快速滚动两个component，数组里面可能会返回nil。当为nil时,把text设置成@“”
            lblContent.text = [array dz_objectAtIndex:row] ? [NSString stringWithFormat:@"%@",[array dz_objectAtIndex:row]] : @"";
        } break;
        case 2 : {
            NSInteger selectedDayIndex = [_datePicker selectedRowInComponent:0];
            NSInteger selectedHourIndex = [_datePicker selectedRowInComponent:1];
            NSArray *array =  [self getMinuteWithDayIndex:selectedDayIndex hourIndex:selectedHourIndex];
            //同时快速滚动两个component，数组里面可能会返回nil。当为nil时,把text设置成@“”
            lblContent.text = [array dz_objectAtIndex:row] ? [NSString stringWithFormat:@"%.2ld",(long)[[array dz_objectAtIndex:row] integerValue]] : @"";
        } break;
    }
    return lblContent;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    switch (component) {
        case 0 : {
            [pickerView reloadComponent:1];
            [pickerView reloadComponent:2];
        } break;
        case 1 : {
            [pickerView reloadComponent:2];
        } break;
        case 2 : {
        } break;
    }
}

#pragma mark - Get TimeArray
- (NSArray *)days {
    if (!_days) {
        NSDate *startDay = [self.startDate dateAtStartOfDay];
        NSDate *endDay  = [self.endDate dateAtStartOfDay];
        
        NSMutableArray *days = [NSMutableArray array];
        for (NSDate *date = startDay; [date isEarlierThanDate:endDay] || [date isTheSameDay:endDay]; date = [date dateByAddingDays:1] ) {
            if ([date isTheSameDay:self.startDate]) {
                NSDate *startDayLatestTime = [[startDay dateByAddingHours:self.latestHour] dateByAddingMinutes:self.latestminute];//第一天的最晚时间
                if ([self.startDate isLaterThanDate:startDayLatestTime]) {
                    continue;//第一天已经过了最晚时间，不加进去
                }
            }
            if ([date isTheSameDay:self.endDate]) {
                NSDate *endDayEarliestTime = [[endDay dateByAddingHours:self.earliestHour] dateByAddingMinutes:self.earliestminute];//最后一天最早时间
                if ( [self.endDate isEarlierThanDate:endDayEarliestTime]) {
                    continue; //最后一天结束时间还没到最早时间，不加进去
                }
            }
            [days dz_addObject:date];
        }
        _days = [NSArray arrayWithArray:days];
    }
    return _days;
}

- (NSArray *)getHourWithDayIndex:(NSUInteger)index {
    
    NSDate *date = (NSDate *)[self.days dz_objectAtIndex:index];
    if ([date isTheSameDay:self.startDate]) {
        //第一天
        return self.hours_early;
    }else if ([date isTheSameDay:self.endDate]){
        //最后一天
        return self.hours_late;
    }else{
        //中间
        return self.hours_middle;
    }
    return nil;
}

- (NSArray *)getMinuteWithDayIndex:(NSUInteger)dayIndex hourIndex:(NSUInteger)hourIndex {
    NSDate *selectDateDay = [self.days dz_objectAtIndex:dayIndex];
    
    NSArray *hours = [self getHourWithDayIndex:dayIndex];
    NSInteger selectHour = [[hours dz_objectAtIndex:hourIndex] integerValue];
    
    if ([selectDateDay isTheSameDay:self.startDate] && selectHour == MAX([self.startDate hour], self.earliestHour)) {
        //第一天，第一个 hour
        return self.minutes_startHour;
    }else if ([selectDateDay isTheSameDay:self.endDate] && selectHour == MIN([self.endDate hour], self.latestHour)){
        //最后一天，最后一个 hour
        return self.minutes_endHour;
    }else if (selectHour == self.earliestHour){
        //非第一天，第一个 hour
        return self.minutes_early;
    }else if (selectHour == self.latestHour){
        //非最后一天，最后一个 hour
        return self.minutes_late;
    }else{
        //最普通状态
        return self.minutes_middle;
    }
    return nil;
}

#pragma mark -  Time Info Data
- (NSArray *)hours_early {
    if (!_hours_early) {
        NSMutableArray *hours = [NSMutableArray array];
        NSInteger startHour = MAX([self.startDate hour], self.earliestHour);
        NSInteger endHour;
        
        if ([self.startDate isTheSameDay:self.endDate]) {
            //如果开始时间和结束时间是同一天要特殊处理
            endHour = MIN([self.endDate hour],self.latestHour);
        }else{
            endHour = self.latestHour;
        }
        NSInteger starMinute = [self startMinute_early];
        
        for (NSInteger i = startHour; i <= endHour; i++) {
            if (starMinute + self.delta > 60 && i == startHour) {
                //当前时间是19：55,但是时间粒度是10， 此时不应该显示19点这个hour
                continue;
            }
            [hours dz_addObject:[NSString stringWithFormat:@"%ld", (long)i]];
        }
        _hours_early = [NSArray arrayWithArray:hours];
    }
    return _hours_early;
}

- (NSArray *)hours_middle {
    if (!_hours_middle) {
        NSMutableArray *hours = [NSMutableArray array];
        NSInteger startHour = self.earliestHour;
        NSInteger endHour = self.latestHour;
        for (NSInteger i = startHour; i <= endHour; i++) {
            [hours dz_addObject:[NSString stringWithFormat:@"%ld", (long)i]];
        }
        _hours_middle = [NSArray arrayWithArray:hours];
    }
    return _hours_middle;
}

- (NSArray *)hours_late {
    if (!_hours_late) {
        NSMutableArray *hours = [NSMutableArray array];
        NSInteger startHour = self.earliestHour;
        NSInteger endHour = MIN([self.endDate hour], self.latestHour);
        for (NSInteger i = startHour; i <= endHour; i++) {
            [hours dz_addObject:[NSString stringWithFormat:@"%ld", (long)i]];
        }
        _hours_late = [NSArray arrayWithArray:hours];
    }
    return _hours_late;
}

- (NSArray *)minutes_early {
    if (!_minutes_early) {
        NSInteger starMinute = [self startMinute:self.earliestminute];
        NSInteger endMinute = 59;
        NSMutableArray *minutes = [NSMutableArray array];
        for (NSUInteger i = starMinute; i <= endMinute; i = i + self.delta) {
            [minutes dz_addObject:[NSString stringWithFormat:@"%ld",(long)i]];
        }
        _minutes_early = [NSArray arrayWithArray:minutes];
    }
    return _minutes_early;
}

- (NSArray *)minutes_middle {
    if (!_minutes_middle) {
        NSInteger starMinute = 0;
        NSInteger endMinute = 59;
        NSMutableArray *minutes = [NSMutableArray array];
        for (NSUInteger i = starMinute; i <= endMinute; i = i + self.delta) {
            [minutes dz_addObject:[NSString stringWithFormat:@"%ld",(long)i]];
        }
        _minutes_middle = [NSArray arrayWithArray:minutes];
    }
    return _minutes_middle;
}

- (NSArray *)minutes_late {
    if (!_minutes_late) {
        NSInteger starMinute = 0;
        NSInteger endMinute = self.latestminute;
        NSMutableArray *minutes = [NSMutableArray array];
        for (NSUInteger i = starMinute; i <= endMinute; i = i + self.delta) {
            [minutes dz_addObject:[NSString stringWithFormat:@"%ld",(long)i]];
        }
        _minutes_late = [NSArray arrayWithArray:minutes];
    }
    return _minutes_late;
}

- (NSArray *)minutes_startHour {
    if (!_minutes_startHour) {
        NSInteger starMinute = [self startMinute_early];
        NSInteger endMinute = 59;
        NSMutableArray *minutes = [NSMutableArray array];
        for (NSUInteger i = starMinute; i <= endMinute; i = i + self.delta) {
            [minutes dz_addObject:[NSString stringWithFormat:@"%ld",(long)i]];
        }
        _minutes_startHour = [NSArray arrayWithArray:minutes];
    }
    return _minutes_startHour;
}

- (NSArray *)minutes_endHour {
    if (!_minutes_endHour) {
        NSInteger starMinute = 0;
        NSInteger endMinute = 0;//[self.endDate hour] < self.latestHour ? [self.endDate minute] : self.latestminute;
        if ([self.endDate hour] < self.latestHour) {
            endMinute = [self.endDate minute];
        }else if ([self.endDate hour] == self.latestHour){
            endMinute = MIN([self.endDate minute], self.latestminute);
        }else{
            endMinute = self.latestminute;
        }
        NSMutableArray *minutes = [NSMutableArray array];
        for (NSUInteger i = starMinute; i <= endMinute; i = i + self.delta) {
            [minutes dz_addObject:[NSString stringWithFormat:@"%ld",(long)i]];
        }
        _minutes_endHour = [NSArray arrayWithArray:minutes];
    }
    return _minutes_endHour;
}

#pragma mark -  Minute

/**
 *  获取可用的开始分钟 比如传入32，时间粒度为15，则传出45（32 － 2 ＋ 15）
 */
- (NSInteger)startMinute:(NSInteger)aMinute{
    NSInteger startMinute;
    NSInteger x = aMinute % self.delta;
    if (x == 0) {
        startMinute = aMinute;
    }else{
        startMinute = aMinute - x + self.delta;
    }
    return startMinute;
}

/**
 *  最早的开始分钟
 */
- (NSInteger)startMinute_early{
    NSInteger starMinuteBeforeHandle;
    if ([self.startDate hour] > self.earliestHour) {
        starMinuteBeforeHandle = [self.startDate minute];
    }else if ([self.startDate hour] == self.earliestHour){
        starMinuteBeforeHandle = MAX([self.startDate minute], self.earliestminute);
    }else{
        starMinuteBeforeHandle = self.earliestminute;
    }
    return [self startMinute:starMinuteBeforeHandle];
 }

#pragma mark -  func

- (void)setTitle:(NSString *)title {
    _title = title;
    _lblTitle.text = title;
}

- (void)setDelta:(NSUInteger)delta {
    if (delta == 0) {
        delta = 1;
    }
    if (delta > 30) {
        delta = 30;
    }
    
    if (60 % delta == 0) {
        _delta = delta;
    }else{
        //防止有傻逼传7、8、13这种除不尽的时间粒度进来
        for (NSUInteger i = delta; i > 0; i --) {
            if (60 % i == 0) {
                _delta = i;
                break;
            }
        }
    }
}

- (void)setStartDate:(NSDate *)startDate{
    NSUInteger second = [startDate second];
    if (second == 0) {
        _startDate = startDate;
    }else{
        NSUInteger hour = [startDate hour];
        NSUInteger minute = [startDate minute];
        _startDate = [[[startDate dateAtStartOfDay] dateByAddingHours:hour] dateByAddingMinutes:minute + 1];
    }
}

- (void)setEndDate:(NSDate *)endDate{
    NSUInteger second = [endDate second];
    if (second == 0) {
        _endDate = endDate;
    }else{
        NSUInteger hour = [endDate hour];
        NSUInteger minute = [endDate minute];
        _endDate = [[[endDate dateAtStartOfDay] dateByAddingHours:hour] dateByAddingMinutes:minute];
    }
}

- (void)setEarliestTime:(NSString *)time {
    if (time) {
        self.earliestHour = [[[time componentsSeparatedByString:@":"] firstObject] intValue];
        self.earliestminute = [[[time componentsSeparatedByString:@":"] lastObject] intValue];
    } else {
        self.earliestHour = 0;
        self.earliestminute = 0;
    }
    
    //为了应对 工作开始时间 9：49 时间粒度是15分钟的这种sb配置
    if (self.earliestminute + self.delta > 60) {
        self.earliestHour += 1;
        self.earliestminute = 0;
    }
}

- (void)setLatestTime:(NSString *)time {
    if (time) {
        self.latestHour = [[[time componentsSeparatedByString:@":"] firstObject] intValue];
        self.latestminute = [[[time componentsSeparatedByString:@":"] lastObject] intValue];
    } else {
        self.latestHour = 23;
        self.latestminute = 59;
    }
}

- (void)cancel{
    [self dismissViewFinished:^{
        if (self.cancelBlock) {
            self.cancelBlock();
        }
    }];
}

- (void)btnOKClicked{
    [self dismissViewFinished:^{
        if (self.confirmBlock) {
            self.confirmBlock(self.selectedDate);
        }
    }];
}

- (void)backViewTapped{
    if (self.clickBackViewToHide) {
        [self cancel];
    }
}

#pragma mark - lazy load

- (UIView *)contentView {
    if (!_contentView) {
        _contentView = [[UIView alloc] init];
        _contentView.backgroundColor = [UIColor whiteColor];
        _contentView.layer.masksToBounds = YES;
    }
    return _contentView;
}

- (UIView *)backView {
    if (!_backView) {
        _backView = [[UIView alloc] init];
        _backView.backgroundColor = [UIColor blackColor];
        _backView.alpha = 0;
        _backView.layer.masksToBounds = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backViewTapped)];
        [_backView addGestureRecognizer:tap];
    }
    return _backView;
}

- (UIButton *)btnCancel {
    if (!_btnCancel) {
        _btnCancel = [UIButton buttonWithType:UIButtonTypeCustom];
        _btnCancel.frame = CGRectMake(0, 0, kDZDatePickerButtonWidth, kDZDatePickerTopBarHeight);
        [_btnCancel setTitle:@"Cancel" forState:UIControlStateNormal];
        [_btnCancel setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        _btnCancel.titleLabel.font = [UIFont systemFontOfSize:14];
        [_btnCancel addTarget:self action:@selector(cancel) forControlEvents:UIControlEventTouchUpInside];
    }
    return _btnCancel;
}

- (UIButton *)btnOK {
    if (!_btnOK) {
        _btnOK = [UIButton buttonWithType:UIButtonTypeCustom];
        _btnOK.frame = CGRectMake(kDZ_DATEPICKER_SCREEN_WIDTH - kDZDatePickerButtonWidth, 0, kDZDatePickerButtonWidth, kDZDatePickerTopBarHeight);
        [_btnOK setTitle:@"OK" forState:UIControlStateNormal];
        _btnOK.titleLabel.font = [UIFont systemFontOfSize:14];
        [_btnOK setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
        [_btnOK addTarget:self action:@selector(btnOKClicked) forControlEvents:UIControlEventTouchUpInside];
    }
    return _btnOK;
}

- (UIPickerView *)datePicker {
    if (!_datePicker) {
        _datePicker = [[UIPickerView alloc] init];
        _datePicker.frame = CGRectMake(0, kDZDatePickerTopBarHeight, kDZ_DATEPICKER_SCREEN_WIDTH, kDZDatePickerHeight - kDZDatePickerTopBarHeight);
        _datePicker.dataSource = self;
        _datePicker.delegate = self;
        _datePicker.backgroundColor = [UIColor whiteColor];
        _datePicker.showsSelectionIndicator = YES;
    }
    return _datePicker;
}

- (UILabel *)lblTitle {
    if (!_lblTitle) {
        _lblTitle = [[UILabel alloc] init];
        _lblTitle.font = [UIFont systemFontOfSize:17];
        _lblTitle.textColor = [UIColor blackColor];
        _lblTitle.textAlignment = NSTextAlignmentCenter;
        _lblTitle.frame = CGRectMake(kDZDatePickerButtonWidth, 0, kDZ_DATEPICKER_SCREEN_WIDTH - 2 * kDZDatePickerButtonWidth , kDZDatePickerTopBarHeight);
        _lblTitle.text = self.title?:@"";
    }
    return _lblTitle;
}

- (UIView *)separateLine{
    if (!_separateLine) {
        _separateLine = [[UIView alloc] init];
        _separateLine.backgroundColor = [UIColor grayColor];
        _separateLine.frame = CGRectMake(0, kDZDatePickerTopBarHeight, kDZ_DATEPICKER_SCREEN_WIDTH, kDZ_DATEPICKER_SINGLE_LINE_WIDTH);
    }
    return _separateLine;
}


@end



