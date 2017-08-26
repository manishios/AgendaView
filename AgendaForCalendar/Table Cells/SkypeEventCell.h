//
//  SkypeEventCell.h
//  AgendaForCalendar
//
//  Created by Manish Kumar on 26/08/2017.
//  Copyright © 2017 Manish Kumar. All rights reserved.
//

#import <UIKit/UIKit.h>
@class CalendarEvent;

@interface SkypeEventCell : UITableViewCell
- (void)updateWithEvent:(CalendarEvent *)event;
@end
