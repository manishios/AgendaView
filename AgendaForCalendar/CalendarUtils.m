//
//  CalendarUtils.m
//  AgendaForCalendar
//
//  Created by Manish Kumar on 13/08/2017.
//  Copyright © 2017 Manish Kumar. All rights reserved.
//

#import "CalendarUtils.h"

@implementation CalendarUtils

+ (NSCalendar *)calendar
{
    return [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
}


+ (NSInteger)currentYear
{
    NSCalendar *calendar = [CalendarUtils calendar];
    NSDateComponents *comps = [calendar components:NSCalendarUnitYear fromDate:[NSDate date]];
    
    return comps.year;
}


+ (NSInteger)numberOfMonthsInYear
{
    return 12;
}


+ (NSInteger)numberDaysInYear:(NSInteger)year
{
    NSDateComponents *comps = [CalendarUtils dateComponentsWithYear:year Month:1 Day:1];
    
    NSCalendar *calendar = [CalendarUtils calendar];
    NSRange range = [calendar rangeOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitMonth forDate:[calendar dateFromComponents:comps]];
    
    return range.length;
}


+ (NSInteger)numberOfDaysInMonth:(NSInteger)month Year:(NSInteger)year
{
    NSDateComponents *comps = [CalendarUtils dateComponentsWithYear:year Month:month Day:1];
    
    NSCalendar *calendar = [CalendarUtils calendar];
    NSRange range = [calendar rangeOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitMonth forDate:[calendar dateFromComponents:comps]];
    
    return range.length;
}


+ (NSInteger)numberOfDaysFrom:(NSDate *)startDate To:(NSDate *)endDate
{
    NSDate *fromDate;
    NSDate *toDate;
    
    NSCalendar *calendar = [CalendarUtils calendar];
    
    [calendar rangeOfUnit:NSCalendarUnitDay startDate:&fromDate interval:NULL forDate:startDate];
    [calendar rangeOfUnit:NSCalendarUnitDay startDate:&toDate interval:NULL forDate:endDate];
    
    NSDateComponents *difference = [calendar components:NSCalendarUnitDay fromDate:fromDate toDate:toDate options:0];
    
    NSInteger days = difference.day;
    return days;
}


+ (NSInteger)weekdayOfDate:(NSDate *)date
{
    NSCalendar *calendar = [CalendarUtils calendar];
    NSDateComponents *comps = [calendar components:NSCalendarUnitWeekday fromDate:date];
    return comps.weekday;
}


+ (NSDate *)dateByAddingDays:(NSInteger)days To:(NSDate *)date
{
    NSCalendar *calendar = [CalendarUtils calendar];
    
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    comps.day = days;
    
    NSDate *newDate = [calendar dateByAddingComponents:comps toDate:date options:0];
    return newDate;
}


+ (NSDateComponents *)dateComponentsWithYear:(NSInteger)year Month:(NSInteger)month Day:(NSInteger)day
{
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    comps.year = year;
    comps.month = month;
    comps.day = day;
    
    return comps;
}


+ (NSDate *)dateWithYear:(NSInteger)year Month:(NSInteger)month Day:(NSInteger)day
{
    NSDateComponents *comps = [CalendarUtils dateComponentsWithYear:year Month:month Day:day];
    
    return [[CalendarUtils calendar] dateFromComponents:comps];
}


+ (BOOL)isDate1:(NSDate *)date1 theSameDayAs:(NSDate *)date2
{
    NSCalendar *calendar = [CalendarUtils calendar];
    NSDateComponents *comps1 = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:date1];
    NSDateComponents *comps2 = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:date2];
    
    return comps1.year == comps2.year && comps1.month == comps2.month && comps1.day == comps2.day;
    
}
@end
