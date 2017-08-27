//
//  CalendarViewCell.m
//  AgendaForCalendar
//
//  Created by Manish Kumar on 14/08/2017.
//  Copyright © 2017 Manish Kumar. All rights reserved.
//

#import "CalendarViewCell.h"
#import "Constants.h"
#import "CalendarUtils.h"

@interface CalendarViewCell()
@property (nonatomic) UILabel *dateText;
@end

@implementation CalendarViewCell
- (instancetype)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    
    if (self) {
        self.dateText = [[UILabel alloc] initWithFrame:self.contentView.frame];
        
        _dateText.textAlignment = NSTextAlignmentCenter;
        _dateText.numberOfLines = 0;
        _dateText.textColor = RegularTextColor;
        [self.contentView addSubview:_dateText];
    }
    
    return self;
}

- (void)updateWithModel:(CalendarDay *)calendarDay {
    
    self.dateText.text = (calendarDay.eventsOnDate.count) ? [NSString stringWithFormat:@"%@\n%@", calendarDay.displayDate, DefaultEventSeparator] : calendarDay.displayDate;
    
    CALayer *layer = self.contentView.layer;
    
    if (calendarDay.isDateSelected) {
        layer.backgroundColor = HighlightedBackgroundLayerColor;
        _dateText.textColor = [UIColor whiteColor];
    } else {
        layer.backgroundColor = [[UIColor clearColor] CGColor];
        _dateText.textColor = RegularTextColor;
    }
    
    [self layoutIfNeeded];
}

@end
