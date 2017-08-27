//
//  CalendarEvent.h
//  AgendaForCalendar
//
//  Created by Manish Kumar on 13/08/2017.
//  Copyright © 2017 Manish Kumar. All rights reserved.
//

#import <Foundation/Foundation.h>
@class SkypeParticipant;

@interface CalendarEvent : NSObject

@property (nonatomic, strong) NSString *formattedEventDate;
@property (nonatomic, strong) NSString *startTime;
@property (nonatomic, strong) NSString *endTime;
@property (nonatomic, strong) NSString *duration;
@property (nonatomic) long meetingId;
@property (nonatomic, strong) NSString *meetingTitle;
@property (nonatomic) BOOL isAllDay;
@property (nonatomic) BOOL isSkype;
@property (nonatomic) NSArray *participantList;

+ (CalendarEvent *)createEventFromInfo:(NSDictionary *)eventInfo;
@end
