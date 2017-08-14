//
//  CalendarViewCell.m
//  AgendaForCalendar
//
//  Created by Manish Kumar on 14/08/2017.
//  Copyright © 2017 Manish Kumar. All rights reserved.
//

#import "CalendarViewCell.h"
#import "Constants.h"

@implementation CalendarViewCell
- (instancetype)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    
    if (self) {
        self.dateText = [[UILabel alloc] initWithFrame:self.contentView.frame];
        
        _dateText.textAlignment = NSTextAlignmentCenter;
        _dateText.textColor = RegularTextColor;
        [self.contentView addSubview:_dateText];
    }
    
    return self;
}

- (void)updateWithModel:(CalendarDay *)calendarDay {
    
    self.dateText.text = calendarDay.displayDate;
    
    CALayer *layer = self.contentView.layer;
    
    if (calendarDay.isDateSelected) {
        layer.backgroundColor = [[UIColor blueColor] CGColor];
        _dateText.textColor = [UIColor whiteColor];
    } else {
        layer.backgroundColor = [[UIColor clearColor] CGColor];
        _dateText.textColor = RegularTextColor;
    }
    
    [self layoutIfNeeded];
}

@end
