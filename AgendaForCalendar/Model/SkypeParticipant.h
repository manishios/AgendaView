//
//  SkypeParticipant.h
//  AgendaForCalendar
//
//  Created by Manish Kumar on 26/08/2017.
//  Copyright © 2017 Manish Kumar. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SkypeParticipant : NSObject
@property (nonatomic) NSString *spName;
@property (nonatomic) NSString *spIcon;

+ (instancetype)createWithInfo:(NSDictionary *)participantInfo;
@end
