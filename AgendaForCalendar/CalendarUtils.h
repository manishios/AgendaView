//
//  CalendarUtils.h
//  AgendaForCalendar
//
//  Created by Manish Kumar on 13/08/2017.
//  Copyright © 2017 Manish Kumar. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CalendarUtils : NSObject
+ (NSCalendar *)calendar;
+ (NSInteger)currentYear;
+ (NSInteger)numberOfMonthsInYear;
+ (NSInteger)numberDaysInYear:(NSInteger)year;
+ (NSInteger)numberOfDaysInMonth:(NSInteger)month Year:(NSInteger)year;
+ (NSInteger)numberOfDaysFrom:(NSDate *)startDate To:(NSDate *)endDate;
+ (NSInteger)weekdayOfDate:(NSDate *)date;
+ (NSDate *)dateByAddingDays:(NSInteger)days To:(NSDate *)date;
+ (NSDate *)dateWithYear:(NSInteger)year Month:(NSInteger)month Day:(NSInteger)day;
+ (NSDateComponents *)dateComponentsWithYear:(NSInteger)year Month:(NSInteger)month Day:(NSInteger)day;
+ (BOOL)isDate1:(NSDate *)date1 theSameDayAs:(NSDate *)date2;
@end
