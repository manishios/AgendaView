//
//  EventCell.m
//  AgendaForCalendar
//
//  Created by Manish Kumar on 14/08/2017.
//  Copyright © 2017 Manish Kumar. All rights reserved.
//

#import "EventCell.h"
#import "Constants.h"
#import "CalendarEvent.h"
#import "UnicodeUtil.h"

@interface EventCell()
@property (nonatomic) UILabel *startTime;
@property (nonatomic) UILabel *duration;
@property (nonatomic) UIImageView *eventIcon;
@property (nonatomic) UILabel *eventTitle;
@end

@implementation EventCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        
        CGFloat totalWidth = self.frame.size.width;
        CGFloat startXCoordinate = Padding;
        CGFloat startYCoordinate = (self.contentView.frame.size.height - HeightOfControlForEvent) / 2;

        _startTime = [[UILabel alloc] initWithFrame:CGRectMake(startXCoordinate, startYCoordinate, totalWidth/5, HeightOfControlForEvent)];
        _startTime.font = [UIFont systemFontOfSize:SmallFontSize];
        [self.contentView addSubview:_startTime];
        
        _duration = [[UILabel alloc] initWithFrame:CGRectMake(startXCoordinate, HeightOfControlForEvent, totalWidth/5, HeightOfControlForEvent)];
        _duration.font = [UIFont systemFontOfSize:SmallFontSize];
        [self.contentView addSubview:_duration];
        
        startXCoordinate = totalWidth/5 + Padding;
        _eventIcon = [[UIImageView alloc] initWithFrame:CGRectMake(startXCoordinate, startYCoordinate, IconWidth, IconHeight)];
        [self.contentView addSubview:_eventIcon];
        
        startXCoordinate += (Padding + 40);
        _eventTitle = [[UILabel alloc] initWithFrame:CGRectMake(startXCoordinate, startYCoordinate, (self.frame.size.width - startXCoordinate), HeightOfControlForEvent)];
        _eventTitle.font = [UIFont boldSystemFontOfSize:MediumFontSize];
        [self.contentView addSubview:_eventTitle];
    }
    
    return self;
}

- (void)updateWithEvent:(CalendarEvent *)event {
    
    _eventIcon.image = [UIImage imageNamed:@""];
    
    if (!event.isAllDay) {
        _startTime.text = event.startTime;
        _duration.text = event.duration;
    } else {
        _startTime.text = @"All Day";
        _eventIcon.image = [UnicodeUtil characterImage:DefaultEventSeparator sizeOfControl:_eventIcon.frame.size];
        _eventIcon.contentMode = UIViewContentModeScaleAspectFit;
    }
    
    _eventTitle.text = event.meetingTitle;
    
    [self layoutIfNeeded];
}

@end
