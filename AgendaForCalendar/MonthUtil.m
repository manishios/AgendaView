//
//  MonthUtil.m
//  AgendaForCalendar
//
//  Created by Manish Kumar on 13/08/2017.
//  Copyright © 2017 Manish Kumar. All rights reserved.
//

#import "MonthUtil.h"

typedef enum : NSUInteger {
    January = 1,
    February,
    March,
    April,
    May,
    June,
    July,
    August,
    September,
    October,
    November,
    December
} MonthName;

@implementation MonthUtil
+ (NSString *)shortSymbolForMonth:(int)monthIndex {
    
    NSString *monthName;
    
    switch (monthIndex) {
        case January:
            monthName = NSLocalizedString(@"Jan", nil);
            break;
            
        case February:
            monthName = NSLocalizedString(@"Feb", nil);
            break;
            
        case March:
            monthName = NSLocalizedString(@"Mar", nil);
            break;
            
        case April:
            monthName = NSLocalizedString(@"Apr", nil);
            break;
            
        case May:
            monthName = NSLocalizedString(@"May", nil);
            break;
            
        case June:
            monthName = NSLocalizedString(@"Jun", nil);
            break;
            
        case July:
            monthName = NSLocalizedString(@"Jul", nil);
            break;
            
        case August:
            monthName = NSLocalizedString(@"Aug", nil);
            break;
            
        case September:
            monthName = NSLocalizedString(@"Sep", nil);
            break;
            
        case October:
            monthName = NSLocalizedString(@"Oct", nil);
            break;
            
        case November:
            monthName = NSLocalizedString(@"Nov", nil);
            break;
            
        case December:
            monthName = NSLocalizedString(@"Dec", nil);
            break;
    }
    
    return monthName;
}

+ (NSString *)symbolForMonth:(int)monthIndex {
    
    NSString *monthName;
    
    switch (monthIndex) {
        case January:
            monthName = NSLocalizedString(@"January", nil);
            break;
            
        case February:
            monthName = NSLocalizedString(@"February", nil);
            break;
            
        case March:
            monthName = NSLocalizedString(@"March", nil);
            break;
            
        case April:
            monthName = NSLocalizedString(@"April", nil);
            break;
            
        case May:
            monthName = NSLocalizedString(@"May", nil);
            break;
            
        case June:
            monthName = NSLocalizedString(@"June", nil);
            break;
            
        case July:
            monthName = NSLocalizedString(@"July", nil);
            break;
            
        case August:
            monthName = NSLocalizedString(@"August", nil);
            break;
            
        case September:
            monthName = NSLocalizedString(@"September", nil);
            break;
            
        case October:
            monthName = NSLocalizedString(@"October", nil);
            break;
            
        case November:
            monthName = NSLocalizedString(@"November", nil);
            break;
            
        case December:
            monthName = NSLocalizedString(@"December", nil);
            break;
    }
    
    return monthName;
}


@end
