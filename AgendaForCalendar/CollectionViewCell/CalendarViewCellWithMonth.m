//
//  CalendarViewCellWithMonth.m
//  AgendaForCalendar
//
//  Created by Manish Kumar on 14/08/2017.
//  Copyright © 2017 Manish Kumar. All rights reserved.
//

#import "CalendarViewCellWithMonth.h"
#import "CalendarUtils.h"
#import "MonthUtil.h"
#import "Constants.h"

@interface CalendarViewCellWithMonth()
@property (nonatomic) UILabel *dateText;
@property (nonatomic) UILabel *monthName;
@end

@implementation CalendarViewCellWithMonth
- (instancetype)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    
    if (self) {
        _monthName = [[UILabel alloc] initWithFrame:CGRectZero];
        _monthName.textAlignment = NSTextAlignmentCenter;
        _monthName.textColor = RegularTextColor;
        
        self.dateText = [[UILabel alloc] initWithFrame:self.contentView.frame];
        _dateText.textColor = RegularTextColor;
        self.dateText.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:self.dateText];
        
        [self.contentView addSubview:_monthName];
    }
    
    return self;
}

- (void)updateWithModel:(CalendarDay *)calendarDay {
    
    self.dateText.text = calendarDay.displayDate;
    
    CALayer *layer = self.contentView.layer;
    
    if (calendarDay.displayDate.integerValue == 1) {
        NSDateComponents *componentsFromCalendarDay = [[CalendarUtils calendar] components:NSCalendarUnitMonth | NSCalendarUnitYear fromDate:calendarDay.associatedDate];
        
        NSString *monthText = [NSString stringWithFormat:@"%@", [MonthUtil shortSymbolForMonth:(int)[componentsFromCalendarDay month]]];
        
        [self.monthName setFrame:CGRectMake(0, 0, self.contentView.frame.size.width, self.contentView.frame.size.height/2)];
        self.monthName.text = monthText;

        [self.dateText setFrame:CGRectMake(0, self.contentView.frame.size.height/2, self.contentView.frame.size.width, self.contentView.frame.size.height/2)];
        
    } else {
        _monthName.hidden = YES;
    }
    
    if (calendarDay.isDateSelected) {
        layer.backgroundColor = HighlightedBackgroundLayerColor;
        _dateText.textColor = HighlightedTextColor;
        _monthName.textColor = HighlightedTextColor;
        
    } else {
        layer.backgroundColor = [[UIColor clearColor] CGColor];
        _dateText.textColor = RegularTextColor;
        _monthName.textColor = RegularTextColor;
    }
    
    [self layoutIfNeeded];
}

@end
