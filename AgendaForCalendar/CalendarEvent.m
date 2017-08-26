//
//  CalendarEvent.m
//  AgendaForCalendar
//
//  Created by Manish Kumar on 13/08/2017.
//  Copyright © 2017 Manish Kumar. All rights reserved.
//

#import "CalendarEvent.h"
#import "SkypeParticipant.h"

@implementation CalendarEvent

+ (CalendarEvent *)createEventFromInfo:(NSDictionary *)eventInfo {
    
    if (eventInfo) {
        CalendarEvent *event = [CalendarEvent new];
        
        NSDate *startDate = [NSDate dateWithTimeIntervalSince1970:[eventInfo[@"start"] longLongValue]];
        event.startTime = [startDate descriptionWithLocale:[NSLocale currentLocale]];

        NSDate *endDate = [NSDate dateWithTimeIntervalSince1970:[eventInfo[@"end"] longLongValue]];
        event.endTime = [endDate descriptionWithLocale:[NSLocale currentLocale]];

        event.duration = eventInfo[@"duration"];
        event.endTime = eventInfo[@"end"];
        event.meetingId = [eventInfo[@"id"] longValue];
        event.meetingTitle = eventInfo[@"title"];
        event.isAllDay = [eventInfo[@"allDay"] boolValue];
        event.isSkype = [eventInfo[@"isSkype"] boolValue];
        
        if (event.isSkype && [eventInfo[@"participants"] count]) {
            
            NSArray *participants = eventInfo[@"participants"];

            NSMutableArray *listOfParticipant = [NSMutableArray new];

            for (NSDictionary *participantInfo in participants) {
                SkypeParticipant *participant = [SkypeParticipant createWithInfo:participantInfo];
                [listOfParticipant addObject:participant];
            }
            
            event.participantList = listOfParticipant;
        }
        return event;
    }
    
    return nil;
}
@end
