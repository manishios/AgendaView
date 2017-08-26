//
//  SkypeParticipant.m
//  AgendaForCalendar
//
//  Created by Manish Kumar on 26/08/2017.
//  Copyright © 2017 Manish Kumar. All rights reserved.
//

#import "SkypeParticipant.h"

@implementation SkypeParticipant

+ (instancetype)createWithInfo:(NSDictionary *)participantInfo {
    
    if (participantInfo) {
    
        SkypeParticipant *participant = [SkypeParticipant new];
        
        participant.spName = participantInfo[@"name"];
        participant.spIcon = participantInfo[@"icon"];
        
        return participant;
    }
    
    return nil;
}
@end
