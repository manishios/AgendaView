//
//  EventCell.h
//  AgendaForCalendar
//
//  Created by Manish Kumar on 14/08/2017.
//  Copyright © 2017 Manish Kumar. All rights reserved.
//

#import <UIKit/UIKit.h>
@class CalendarEvent;

@interface EventCell : UITableViewCell
- (void)updateWithEvent:(CalendarEvent *)event;

@end
