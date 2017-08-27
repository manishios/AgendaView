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
#import "UnicodeUtil.h"

@interface SkypeEventCell()
@property (nonatomic) UILabel *startTime;
@property (nonatomic) UILabel *duration;
@property (nonatomic) UIImageView *eventIcon;
@property (nonatomic) UILabel *eventTitle;
@property (nonatomic) UILabel *skyepMeeting;
@end

@implementation SkypeEventCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        
        CGFloat totalWidth = self.frame.size.width;
        CGFloat startXCoordinate = Padding;
        CGFloat startYCoordinate = 5;

        _startTime = [[UILabel alloc] initWithFrame:CGRectMake(startXCoordinate, startYCoordinate, totalWidth/5, HeightOfControlForEvent)];
        _startTime.font = [UIFont systemFontOfSize:SmallFontSize];
        [self.contentView addSubview:_startTime];
      
        startYCoordinate += HeightOfControlForEvent;
        _duration = [[UILabel alloc] initWithFrame:CGRectMake(startXCoordinate, startYCoordinate, totalWidth/5, HeightOfControlForEvent)];
        _duration.font = [UIFont systemFontOfSize:SmallFontSize];
        _duration.textColor = RegularTextColor;
        [self.contentView addSubview:_duration];
        
        startYCoordinate = 5;
        startXCoordinate = totalWidth/5 + Padding;
        _eventIcon = [[UIImageView alloc] initWithFrame:CGRectMake(startXCoordinate, startYCoordinate, IconWidth, IconHeight)];
        [self.contentView addSubview:_eventIcon];

        startXCoordinate += (Padding + 40);
        _eventTitle = [[UILabel alloc] initWithFrame:CGRectMake(startXCoordinate, startYCoordinate, (self.frame.size.width - startXCoordinate), HeightOfControlForEvent)];
        _eventTitle.font = [UIFont boldSystemFontOfSize:MediumFontSize];
        [self.contentView addSubview:_eventTitle];
        
        startYCoordinate = 5 + 2*HeightOfControlForEvent;
        _skyepMeeting = [[UILabel alloc] initWithFrame:CGRectMake(startXCoordinate, startYCoordinate, (self.frame.size.width - startXCoordinate), HeightOfControlForEvent)];
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
        _eventIcon.image = [UnicodeUtil characterImage:DefaultEventSeparator sizeOfControl:_eventIcon.frame.size];
        _eventIcon.contentMode = UIViewContentModeScaleAspectFit;
    }
    
    _eventTitle.text = event.meetingTitle;
    _eventIcon.image = [UIImage imageNamed:@"skype"];
    
    CGFloat startXCoordinateForIcons = _eventTitle.frame.origin.x;
    CGFloat startYCoordinate = _duration.frame.origin.y;
    for (int index=0; index<event.participantList.count; index++) {
        
        SkypeParticipant *participant = [event.participantList objectAtIndex:index];
        
        UIImageView *participantIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:participant.spIcon]];
        [participantIcon setFrame:CGRectMake(startXCoordinateForIcons, startYCoordinate, IconWidth, IconHeight)];
        
        startXCoordinateForIcons += Padding/2 + IconWidth;
        
        [self.contentView addSubview:participantIcon];
    }
    _skyepMeeting.text = (event.isSkype) ? @"Skype Meeting" : @"";
    
    [self layoutIfNeeded];
}

@end
