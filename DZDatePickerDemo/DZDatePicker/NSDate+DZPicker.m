//
//  NSDate+DZPicker.m
//  Pods
//
//  Created by zwz on 2016/11/9.
//
//

#import "NSDate+DZPicker.h"
#define D_MINUTE	60
#define D_HOUR	(60 * 60)
#define D_DAY	(60 * 60 * 24)

#define kDZ_CURRENT_CALENDAR [NSCalendar currentCalendar]

#define kDZ_DATE_COMPONENTS (NSCalendarUnitYear| NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitWeekOfMonth | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond | NSCalendarUnitWeekday | NSCalendarUnitWeekdayOrdinal)


@implementation NSDate (DZPicker)

+ (NSCalendar *)currentCalendar{
    static NSCalendar *sharedCalendar = nil;
    if (!sharedCalendar)
        sharedCalendar = [NSCalendar autoupdatingCurrentCalendar];
    return sharedCalendar;
}

- (NSInteger)hour{
    NSDateComponents *components = [kDZ_CURRENT_CALENDAR components:kDZ_DATE_COMPONENTS fromDate:self];
    

    return components.hour;
}

- (NSInteger)minute{
    NSDateComponents *components = [kDZ_CURRENT_CALENDAR components:kDZ_DATE_COMPONENTS fromDate:self];
    return components.minute;
}

- (NSInteger)second{
    NSDateComponents *components = [kDZ_CURRENT_CALENDAR components:kDZ_DATE_COMPONENTS fromDate:self];
    return components.second;
}

- (NSInteger)day{
    NSDateComponents *components = [kDZ_CURRENT_CALENDAR components:kDZ_DATE_COMPONENTS fromDate:self];
    return components.day;
}

- (NSInteger)month{
    NSDateComponents *components = [kDZ_CURRENT_CALENDAR components:kDZ_DATE_COMPONENTS fromDate:self];
    return components.month;
}

- (NSInteger)week{
    NSDateComponents *components = [kDZ_CURRENT_CALENDAR components:kDZ_DATE_COMPONENTS fromDate:self];
    return components.weekOfYear;
}

- (NSInteger)weekday{
    NSDateComponents *components = [kDZ_CURRENT_CALENDAR components:kDZ_DATE_COMPONENTS fromDate:self];
    return components.weekday;
}

- (NSInteger)year{
    NSDateComponents *components = [kDZ_CURRENT_CALENDAR components:kDZ_DATE_COMPONENTS fromDate:self];
    return components.year;
}

+ (NSDate *)dateTomorrow{
    return [[NSDate date] dateByAddingDays:1];
}

+ (NSDate *)dateYesterday{
    return [[NSDate date] dateBySubtractingDays:1];
}

- (NSString *)stringWithFormat:(NSString *)format{
    NSDateFormatter *formatter = [NSDateFormatter new];
    formatter.dateFormat = format;
    return [formatter stringFromDate:self];
}

- (BOOL)isTheSameDay:(NSDate *)aDate
{
    NSDateComponents *components1 = [kDZ_CURRENT_CALENDAR components:kDZ_DATE_COMPONENTS fromDate:self];
    NSDateComponents *components2 = [kDZ_CURRENT_CALENDAR components:kDZ_DATE_COMPONENTS fromDate:aDate];
    return ((components1.year == components2.year) &&
            (components1.month == components2.month) &&
            (components1.day == components2.day));
}

- (BOOL)isToday{
    return [self isTheSameDay:[NSDate date]];
}

- (BOOL)isTomorrow{
    return [self isTheSameDay:[NSDate dateTomorrow]];
}

- (BOOL)isYesterday{
    return [self isTheSameDay:[NSDate dateYesterday]];
}

- (BOOL)isEarlierThanDate:(NSDate *)aDate
{
    return ([self compare:aDate] == NSOrderedAscending);
}

- (BOOL)isLaterThanDate:(NSDate *)aDate{
    return ([self compare:aDate] == NSOrderedDescending);
}


- (NSDate *)dateByAddingDays:(NSInteger)days{
    NSTimeInterval aTimeInterval = [self timeIntervalSinceReferenceDate] + D_DAY * days;
    NSDate *newDate = [NSDate dateWithTimeIntervalSinceReferenceDate:aTimeInterval];
    return newDate;
}

- (NSDate *)dateBySubtractingDays:(NSInteger)days{
    return [self dateByAddingDays:(days * -1)];
}

- (NSDate *)dateByAddingHours:(NSInteger)hours{
    NSTimeInterval aTimeInterval = [self timeIntervalSinceReferenceDate] + D_HOUR * hours;
    NSDate *newDate = [NSDate dateWithTimeIntervalSinceReferenceDate:aTimeInterval];
    return newDate;
}

- (NSDate *)dateByAddingMinutes:(NSInteger)minutes{
    NSTimeInterval aTimeInterval = [self timeIntervalSinceReferenceDate] + D_MINUTE * minutes;
    NSDate *newDate = [NSDate dateWithTimeIntervalSinceReferenceDate:aTimeInterval];
    return newDate;
}

- (NSDate *)dateBySubtractingMinutes:(NSInteger)minutes{
    return [self dateByAddingMinutes:(minutes * -1)];
}

- (NSDate *)dateAtStartOfDay{
    NSDateComponents *components = [kDZ_CURRENT_CALENDAR components:kDZ_DATE_COMPONENTS fromDate:self];
    components.hour = 0;
    components.minute = 0;
    components.second = 0;
    return [kDZ_CURRENT_CALENDAR dateFromComponents:components];
}

- (NSDate *)dateAtEndOfDay{
    NSDateComponents *components = [[NSDate currentCalendar] components:kDZ_DATE_COMPONENTS fromDate:self];
    components.hour = 23;
    components.minute = 59;
    components.second = 59;
    return [[NSDate currentCalendar] dateFromComponents:components];
}

- (NSInteger)minutesAfterDate:(NSDate *)aDate{
    NSTimeInterval ti = [self timeIntervalSinceDate:aDate];
    return (NSInteger) (ti / D_MINUTE);
}

- (NSInteger)hoursBeforeDate:(NSDate *)aDate{
    NSTimeInterval ti = [aDate timeIntervalSinceDate:self];
    return (NSInteger) (ti / D_HOUR);
}

- (NSInteger)daysAfterDate:(NSDate *)aDate{
    NSTimeInterval ti = [self timeIntervalSinceDate:aDate];
    return (NSInteger) (ti / D_DAY);
}

@end
