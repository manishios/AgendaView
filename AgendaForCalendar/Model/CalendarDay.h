//
//  CalendarDay.h
//  AgendaForCalendar
//
//  Created by Manish Kumar on 14/08/2017.
//  Copyright © 2017 Manish Kumar. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CalendarDay : NSObject

@property (nonatomic, strong, readwrite) NSString *displayDate;
@property (nonatomic, strong, readwrite) NSArray *eventsOnDate;
@property (readwrite) BOOL isDateSelected;
@property (nonatomic) NSDate *associatedDate;
@property (nonatomic) NSString *formattedDate;

@end
