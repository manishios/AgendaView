//
//  WeekdayUtil.m
//  AgendaForCalendar
//
//  Created by Manish Kumar on 13/08/2017.
//  Copyright © 2017 Manish Kumar. All rights reserved.
//

#import "WeekdayUtil.h"

typedef enum : NSUInteger {
    Sunday = 1,
    Monday,
    Tuesday,
    Wednesday,
    Thursday,
    Friday,
    Saturday,
} WeekdayName;

@implementation WeekdayUtil
// dayIndex starts from 1-7, week starts from Sunday = 1 Saturday = 7
+ (NSString *)shortSymbolForDay:(int)dayIndex {
    
    NSString *dayName;
    
    switch (dayIndex) {
        case Sunday:
            dayName = NSLocalizedString(@"SU", nil);
            break;
            
        case Monday:
            dayName = NSLocalizedString(@"MO", nil);
            break;
            
        case Tuesday:
            dayName = NSLocalizedString(@"TU", nil);
            break;
            
        case Wednesday:
            dayName = NSLocalizedString(@"WE", nil);
            break;
            
        case Thursday:
            dayName = NSLocalizedString(@"TH", nil);
            break;
            
        case Friday:
            dayName = NSLocalizedString(@"FR", nil);
            break;
            
        case Saturday:
            dayName = NSLocalizedString(@"SA", nil);
            break;
    }
    
    return dayName;
}

+ (NSString *)symbolForDay:(int)dayIndex {
    
    NSString *dayName;
    
    switch (dayIndex) {
        case Sunday:
            dayName = NSLocalizedString(@"Sunday", nil);
            break;
            
        case Monday:
            dayName = NSLocalizedString(@"Monday", nil);
            break;
            
        case Tuesday:
            dayName = NSLocalizedString(@"Tuesday", nil);
            break;
            
        case Wednesday:
            dayName = NSLocalizedString(@"Wednesday", nil);
            break;
            
        case Thursday:
            dayName = NSLocalizedString(@"Thursday", nil);
            break;
            
        case Friday:
            dayName = NSLocalizedString(@"Friday", nil);
            break;
            
        case Saturday:
            dayName = NSLocalizedString(@"Saturday", nil);
            break;
    }
    
    return dayName;
}
@end
