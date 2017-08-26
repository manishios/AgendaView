//
//  SkypeEventCell.m
//  AgendaForCalendar
//
//  Created by Manish Kumar on 26/08/2017.
//  Copyright © 2017 Manish Kumar. All rights reserved.
//

#import "SkypeEventCell.h"
#import "Constants.h"
#import "CalendarEvent.h"
#import "SkypeParticipant.h"

@interface SkypeEventCell()
@property (nonatomic) UILabel *startTime;
@property (nonatomic) UILabel *duration;
@property (nonatomic) UIImageView *eventIcon;
@property (nonatomic) UILabel *eventTitle;
@property (nonatomic) UILabel *skyepMeeting;
@end

#define IconWidth 15
#define IconHeight 15

@implementation SkypeEventCell

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
        _eventIcon = [[UIImageView alloc] initWithFrame:CGRectMake(startXCoordinate, 2, IconWidth, IconHeight)];
        [self.contentView addSubview:_eventIcon];
        
        startXCoordinate += (Padding + 40);
        _eventTitle = [[UILabel alloc] initWithFrame:CGRectMake(startXCoordinate, 0, (self.frame.size.width - startXCoordinate), HeightOfControlForEvent)];
        _eventTitle.font = [UIFont boldSystemFontOfSize:SmallFontSize];
        [self.contentView addSubview:_eventTitle];
        
        _skyepMeeting = [[UILabel alloc] initWithFrame:CGRectMake(startXCoordinate, 2*HeightOfControlForEvent, (self.frame.size.width - startXCoordinate), HeightOfControlForEvent)];
        _skyepMeeting.textColor = RegularTextColor;
        _skyepMeeting.font = [UIFont systemFontOfSize:SmallFontSize];
        [self.contentView addSubview:_skyepMeeting];
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
    _eventIcon.image = [UIImage imageNamed:@"skype"];
    
    CGFloat startXCoordinateForIcons = _eventTitle.frame.origin.x;
    
    for (int index=0; index<event.participantList.count; index++) {
        
        SkypeParticipant *participant = [event.participantList objectAtIndex:index];
        
        UIImageView *participantIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:participant.spIcon]];
        [participantIcon setFrame:CGRectMake(startXCoordinateForIcons, HeightOfControlForEvent, IconWidth, IconHeight)];
        
        startXCoordinateForIcons += Padding/2 + IconWidth;
        
        [self.contentView addSubview:participantIcon];
    }
    _skyepMeeting.text = (event.isSkype) ? @"Skype Meeting" : @"";
    
    [self layoutIfNeeded];
}

@end
