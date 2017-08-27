//
//  DateUtil.m
//  AgendaForCalendar
//
//  Created by Manish Kumar on 26/08/2017.
//  Copyright © 2017 Manish Kumar. All rights reserved.
//

#import "DateUtil.h"
#import "CalendarUtils.h"

@implementation DateUtil

+ (NSString *)durationBetweenDates:(NSDate *)startDate endDate:(NSDate *)endDate {

    if (startDate && endDate) {
        
        NSCalendar *calendar = [CalendarUtils calendar];
        
        NSDateComponents *components = [calendar components:NSCalendarUnitHour|NSCalendarUnitMinute fromDate:startDate toDate:endDate options:0];
        NSInteger diffInMinute = components.minute;
        NSInteger diffInHour = components.hour;
        
        NSMutableString *formattedDurationBwtweenDates = [NSMutableString new];
        
        if (diffInHour > 0) {
            [formattedDurationBwtweenDates appendFormat:@"%ldh", diffInHour];
        }
        if (diffInMinute > 0) {
            if (formattedDurationBwtweenDates.length) {
                [formattedDurationBwtweenDates appendFormat:@" %ldm", diffInMinute];
            } else {
                [formattedDurationBwtweenDates appendFormat:@"%ldm", diffInMinute];
            }
        }

        return formattedDurationBwtweenDates;
    }
    
    return nil;
}

+ (NSString *)formatEventDate:(NSDate *)eventDate {
    NSString *formattedDate;
    
    if (eventDate) {
        NSCalendar *calendar = [CalendarUtils calendar];
        
        NSDateComponents *components = [calendar components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitCalendar | NSCalendarUnitDay fromDate:eventDate];
        
        formattedDate = [NSString stringWithFormat:@"%ld-%ld-%ld", components.year, components.month, components.day];
    }
    
    return formattedDate;
}

@end
