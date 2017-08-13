//
//  WeekdayUtil.h
//  AgendaForCalendar
//
//  Created by Manish Kumar on 13/08/2017.
//  Copyright © 2017 Manish Kumar. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WeekdayUtil : NSObject
+ (NSString *)shortSymbolForDay:(int)dayIndex;
+ (NSString *)symbolForDay:(int)dayIndex;
@end
