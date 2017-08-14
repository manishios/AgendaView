//
//  CalendarViewCellWithMonth.h
//  AgendaForCalendar
//
//  Created by Manish Kumar on 14/08/2017.
//  Copyright © 2017 Manish Kumar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CalendarDay.h"

@interface CalendarViewCellWithMonth : UICollectionViewCell
@property (nonatomic) UILabel *dateText;
@property (nonatomic) UILabel *monthName;

- (void)updateWithModel:(CalendarDay *)calendarDay;

@end
