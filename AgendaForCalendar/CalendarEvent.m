//
//  CalendarEvent.m
//  AgendaForCalendar
//
//  Created by Manish Kumar on 13/08/2017.
//  Copyright © 2017 Manish Kumar. All rights reserved.
//

#import "CalendarEvent.h"

@implementation CalendarEvent
+ (CalendarEvent *)createEventFromInfo:(NSDictionary *)eventInfo {
    
    if (eventInfo) {
        CalendarEvent *event = [CalendarEvent new];
        
        event.startTime = eventInfo[@"start"];
        event.duration = eventInfo[@"duration"];
        event.endTime = eventInfo[@"end"];
        event.meetingId = [eventInfo[@"id"] longValue];
        event.meetingTitle = eventInfo[@"title"];
        event.isAllDay = [eventInfo[@"allDay"] boolValue];
        event.isSkype = [eventInfo[@"isSkype"] boolValue];
        return event;
    }
    
    return nil;
}
@end
