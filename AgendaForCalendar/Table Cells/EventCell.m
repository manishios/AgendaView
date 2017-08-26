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

@interface EventCell()
@property (nonatomic) UILabel *startTime;
@property (nonatomic) UILabel *duration;
@property (nonatomic) UIImageView *eventIcon;
@property (nonatomic) UILabel *eventTitle;
@end

@implementation EventCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        
        CGFloat totalWidth = self.frame.size.width;
        CGFloat startXCoordinate = Padding;
        
        _startTime = [[UILabel alloc] initWithFrame:CGRectMake(startXCoordinate, 0, totalWidth/5, HeightOfControlForEvent)];
        _startTime.font = [UIFont systemFontOfSize:SmallFontSize];
        [self.contentView addSubview:_startTime];
        
        _duration = [[UILabel alloc] initWithFrame:CGRectMake(startXCoordinate, HeightOfControlForEvent, totalWidth/5, HeightOfControlForEvent)];
        _duration.font = [UIFont systemFontOfSize:SmallFontSize];
        [self.contentView addSubview:_duration];
        
        startXCoordinate = totalWidth/5 + Padding;
        _eventIcon = [[UIImageView alloc] initWithFrame:CGRectMake(startXCoordinate, 0, 40, HeightOfControlForEvent)];
        [self.contentView addSubview:_eventIcon];
        
        startXCoordinate += (Padding + 40);
        _eventTitle = [[UILabel alloc] initWithFrame:CGRectMake(startXCoordinate, 0, (self.frame.size.width - startXCoordinate), HeightOfControlForEvent)];
        _eventTitle.font = [UIFont boldSystemFontOfSize:SmallFontSize];
        [self.contentView addSubview:_eventTitle];
        
    }
    
    return self;
}

- (void)updateWithEvent:(CalendarEvent *)event {
    
    if (!event.isAllDay) {
        _startTime.text = event.startTime;
        _duration.text = event.duration;
    } else {
        _startTime.text = @"All Day";
    }
    
    _eventTitle.text = event.meetingTitle;
    _eventIcon.image = [UIImage imageNamed:@""];
    
    [self layoutIfNeeded];
}

@end
