//
//  CalendarEvent.m
//  AgendaForCalendar
//
//  Created by Manish Kumar on 13/08/2017.
//  Copyright © 2017 Manish Kumar. All rights reserved.
//

#import "CalendarEvent.h"
#import "SkypeParticipant.h"
#import "DateUtil.h"

@implementation CalendarEvent

+ (CalendarEvent *)createEventFromInfo:(NSDictionary *)eventInfo {
    
    if (eventInfo) {
        CalendarEvent *event = [CalendarEvent new];
        
        NSDateFormatter *formatter = [NSDateFormatter new];
        [formatter setDateFormat:@"h:mm a"];
    
        NSDate *startDate = [NSDate dateWithTimeIntervalSince1970:[eventInfo[@"start"] longLongValue]];
        event.startTime = [formatter stringFromDate:startDate];
        
        event.formattedEventDate = [DateUtil formatEventDate:startDate];
        
        NSDate *endDate;
        if (eventInfo[@"end"]) {
            endDate = [NSDate dateWithTimeIntervalSince1970:[eventInfo[@"end"] longLongValue]];
            event.endTime = [formatter stringFromDate:endDate];
        }
        
        formatter = nil;
        
        event.duration = [DateUtil durationBetweenDates:startDate endDate:endDate];
        
        event.isAllDay = [eventInfo[@"allDay"] boolValue];
        
        event.meetingId = [eventInfo[@"id"] longValue];
        event.meetingTitle = eventInfo[@"title"];
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
