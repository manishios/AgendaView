//
//  DateUtil.h
//  AgendaForCalendar
//
//  Created by Manish Kumar on 26/08/2017.
//  Copyright © 2017 Manish Kumar. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DateUtil : NSObject
+ (NSString *)durationBetweenDates:(NSDate *)startDate endDate:(NSDate *)endDate;
+ (NSString *)formatEventDate:(NSDate *)eventDate;
@end
