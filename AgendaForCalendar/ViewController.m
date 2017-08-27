//
//  ViewController.m
//  AgendaForCalendar
//
//  Created by Manish Kumar on 02/08/2017.
//  Copyright © 2017 Manish Kumar. All rights reserved.
//

#import "ViewController.h"
#import "CalendarUtils.h"
#import "MonthUtil.h"
#import "WeekdayUtil.h"
#import "CalendarDay.h"
#import "CalendarEvent.h"
#import "CalendarViewCellWithMonth.h"
#import "CalendarViewCell.h"
#import "Constants.h"
#import "EventCell.h"
#import "SkypeEventCell.h"
#import "DateUtil.h"

@interface ViewController () <UICollectionViewDelegate, UICollectionViewDataSource, UIScrollViewDelegate, UITableViewDelegate, UITableViewDataSource, UICollectionViewDelegateFlowLayout>

{
    CGFloat startYCoordinateForView ;
    CGFloat heightOfView;
    CGFloat startXCoordinateForView;
    CGFloat totalWidth;
    CGFloat widthForOneDay;
    BOOL isExpanded;
    NSIndexPath *focusedIndexPath;
}

@property (nonatomic) UITableView *tableView;
@property (nonatomic) UICollectionView *collectionView;
@property (nonatomic) UIView *dayHeaderView;
@property (nonatomic) NSMutableArray <CalendarDay *> *listOfItems;
@property (nonatomic) NSIndexPath *previouslySelectedIndexPath;
@property (nonatomic) UITableView *eventsListView;
@property (nonatomic) NSInteger daysInWeek;
@property (nonatomic) NSDate *selectedDate;
@property (nonatomic) NSDictionary *events;
@end

// Tags
#define Tag_CalendarView 1001
#define Tag_EventView 1002

// Calendar range -- Start and end date in Unix epoch
#define StartDate_Epoch 1262476800
#define EndDate_Epoch 1578700800

#define Skype_Event_Cell_Height 70
#define Other_Event_Cell_Height 44
#define Collapsed_Height 150
#define Height_Of_Header_Section 30

#define OddColor [UIColor clearColor]
#define EvenColor [UIColor groupTableViewBackgroundColor]

@implementation ViewController

# pragma mark - Basic view initialization
- (void)initiateHeaderView {

    _dayHeaderView = [[UIView alloc] initWithFrame:CGRectMake(startXCoordinateForView, startYCoordinateForView, self.view.bounds.size.width, heightOfView)];
    [_dayHeaderView setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    
    for (int index=0; index<self.daysInWeek; index++) {
        
        UILabel *dayView = [[UILabel alloc] initWithFrame:CGRectMake(startXCoordinateForView, 0, widthForOneDay, heightOfView)];
        
        dayView.text = [WeekdayUtil shortSymbolForDay:(index+1)];
        dayView.textAlignment = NSTextAlignmentCenter;
        dayView.textColor = RegularTextColor;
        
        [_dayHeaderView addSubview:dayView];
        
        startXCoordinateForView += widthForOneDay;
    }
    [self.view addSubview:self.dayHeaderView];
}

- (NSInteger)daysBetweenDate:(NSDate*)fromDateTime andDate:(NSDate*)toDateTime
{
    NSDate *fromDate;
    NSDate *toDate;
    
    NSCalendar *calendar = [CalendarUtils calendar];
    
    [calendar rangeOfUnit:NSCalendarUnitDay startDate:&fromDate
                 interval:NULL forDate:fromDateTime];
    [calendar rangeOfUnit:NSCalendarUnitDay startDate:&toDate
                 interval:NULL forDate:toDateTime];
    
    NSDateComponents *difference = [calendar components:NSCalendarUnitDay
                                               fromDate:fromDate toDate:toDate options:0];
    
    return [difference day];
}

- (void)populateDataSource {
    
    [self doSomethingWithTheJson];
    
    if (!self.listOfItems) {
        _listOfItems = [NSMutableArray new];
    }
    
    NSCalendar *appCalendar = [CalendarUtils calendar];
    
    NSDate *firstDate = [NSDate dateWithTimeIntervalSince1970:StartDate_Epoch];
    NSDate *endDate = [NSDate dateWithTimeIntervalSince1970:EndDate_Epoch];
    
    NSInteger daysBetweenDates = [self daysBetweenDate:firstDate andDate:endDate];
    NSDateComponents *componentsForFirstDate = [appCalendar components:NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitYear fromDate:firstDate];
    
    // Get the weekday component of the current date
    NSDateComponents *weekdayComponents = [appCalendar components:NSCalendarUnitWeekday fromDate:firstDate];
    
    /*
     Create a date components to represent the number of days to subtract
     from the current date.
     The weekday value for Sunday in the Gregorian calendar is 1, so
     subtract 1 from the number
     of days to subtract from the date in question.  (If today's Sunday,
     subtract 0 days.)
     */
    NSDateComponents *componentsToSubtract = [[NSDateComponents alloc] init];
    /* Substract [gregorian firstWeekday] to handle first day of the week being something else than Sunday */
    [componentsToSubtract setDay: - ([weekdayComponents weekday] - [appCalendar firstWeekday])];
    
    NSDate *associatedDate = firstDate;
    
    NSDateComponents* deltaComps = [NSDateComponents new];
    
    for (NSInteger index = componentsForFirstDate.day; index <= daysBetweenDates; index++) {
        
        CalendarDay *calendarDay = [CalendarDay new];
        
        if (index == componentsForFirstDate.day) {
            [deltaComps setDay:0];
        } else {
            [deltaComps setDay:1];
        }
        associatedDate = [appCalendar dateByAddingComponents:deltaComps toDate:associatedDate options:0];
        calendarDay.associatedDate = associatedDate;
        
        calendarDay.formattedDate = [DateUtil formatEventDate:associatedDate];
        
        calendarDay.eventsOnDate = nil;
        NSDateComponents *components = [appCalendar components:NSCalendarUnitDay fromDate:associatedDate];
        calendarDay.displayDate = [NSString stringWithFormat:@"%ld", components.day];
        
        if ([CalendarUtils isDate1:[NSDate date] theSameDayAs:associatedDate]) {
            focusedIndexPath = [NSIndexPath indexPathForItem:(index - componentsForFirstDate.day) inSection:0];
        }
        
        if([_events.allKeys containsObject:calendarDay.formattedDate]) {
            calendarDay.eventsOnDate = (NSArray *)[_events objectForKey:calendarDay.formattedDate];
        }
        
        [self.listOfItems addObject:calendarDay];
    }
}

- (void)doSomethingWithTheJson {

    NSDictionary *dict = [self JSONFromFile];
    
    NSArray *events = [dict objectForKey:@"events"];
    
    NSMutableDictionary *eventSet = [NSMutableDictionary new];
    
    for (NSDictionary *event in events) {
        
        CalendarEvent *cEvent = [CalendarEvent createEventFromInfo:event];
        
        NSMutableArray *eventList = [NSMutableArray new];
        
        if ([eventSet.allKeys containsObject:cEvent.formattedEventDate]) {
            NSArray *listOfEvents = (NSArray*)[eventSet objectForKey:cEvent.formattedEventDate];
            eventList = [listOfEvents mutableCopy];
        }
        
        [eventList addObject:cEvent];
        [eventSet setObject:eventList forKey:cEvent.formattedEventDate];
    }
    
    self.events = [NSDictionary dictionaryWithDictionary:eventSet];
}

- (NSDictionary *)JSONFromFile {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"events" ofType:@"json"];
    NSData *data = [NSData dataWithContentsOfFile:path];
    return [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
}

- (void)initiateCalendarView {
    
    UICollectionViewFlowLayout *flowLayout=[[UICollectionViewFlowLayout alloc] init];
    
    [flowLayout setItemSize:CGSizeMake(widthForOneDay, widthForOneDay)];
    [flowLayout setSectionInset:UIEdgeInsetsZero];
    [flowLayout setMinimumInteritemSpacing:CGFLOAT_MIN];
    [flowLayout setMinimumLineSpacing:CGFLOAT_MIN];
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
    
    startYCoordinateForView = self.dayHeaderView.frame.origin.y + self.dayHeaderView.frame.size.height;
    heightOfView = (self.view.frame.size.height - startYCoordinateForView)/2;
    startXCoordinateForView = CGFLOAT_MIN;
    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(startXCoordinateForView, startYCoordinateForView, self.view.bounds.size.width, heightOfView) collectionViewLayout:flowLayout];
    
    _collectionView.tag = Tag_CalendarView;
    [_collectionView setDataSource:self];
    [_collectionView setDelegate:self];
    
    [_collectionView registerClass:[CalendarViewCell class] forCellWithReuseIdentifier:@"CellIdentifier"];
    [_collectionView registerClass:[CalendarViewCellWithMonth class] forCellWithReuseIdentifier:@"CellIdentifierForCellWithMonth"];
    [_collectionView setBackgroundColor:[UIColor whiteColor]];
    
    [self.view addSubview:_collectionView];
    
    // Select the current date on launch
    [self scrollToDay];
}

- (void)initiateEventListView {
    
    startYCoordinateForView = _collectionView.frame.origin.y + _collectionView.frame.size.height;
    heightOfView = self.view.frame.size.height - startYCoordinateForView;
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(startXCoordinateForView, startYCoordinateForView, self.view.frame.size.width, heightOfView) style:UITableViewStylePlain];
    
    _tableView.tag = Tag_EventView;
    _tableView.dataSource = self;
    _tableView.delegate = self;
    [self.view addSubview:_tableView];
}

- (void)contentSizeForInifinteCollectionView {
    CGSize sizeOfOneItem = [self collectionView:self.collectionView
                                            layout:self.collectionView.collectionViewLayout
                            sizeForItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]];
    
    CGFloat heightForOneItem = sizeOfOneItem.height;
    
    CGFloat totalHeightRequired = _listOfItems.count * heightForOneItem;
    
    self.collectionView.contentSize = CGSizeMake(self.view.frame.size.width, totalHeightRequired);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.daysInWeek = 7;

    startYCoordinateForView = 64;
    heightOfView = 40;
    startXCoordinateForView = CGFLOAT_MIN;
    totalWidth = self.view.frame.size.width;
    widthForOneDay = totalWidth/self.daysInWeek;

    [self createToggleViewBarButton];
    
    [self populateDataSource];

//    self.selectedDate = [(CalendarDay *)[_listOfItems objectAtIndex:0] associatedDate];
    
    // Initiate the calendar header view
    [self initiateHeaderView];
    
    // Initiate the calendar grid view
    [self initiateCalendarView];
    
    // Initiate Event list view
    [self initiateEventListView];
    isExpanded = YES;
//    [self toggleAgendaView:nil];
}

- (void)createToggleViewBarButton {
    UIBarButtonItem *toggleViewBarButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"agenda-view"]
                                                                            style:UIBarButtonItemStylePlain
                                                                           target:self
                                                                           action:@selector(toggleAgendaView:)];
    self.navigationItem.rightBarButtonItem = toggleViewBarButton;
}

- (void)toggleAgendaView:(UIBarButtonItem *)button {
    
    isExpanded =  !isExpanded;
    
    startXCoordinateForView = CGFLOAT_MIN;
    startYCoordinateForView = _collectionView.frame.origin.y;
    totalWidth = self.view.frame.size.width;
    
    [UIView animateWithDuration:0.25 animations:^{
        if (isExpanded) {
            heightOfView = self.view.frame.size.height/2 - startYCoordinateForView;
            _collectionView.frame = CGRectMake(startXCoordinateForView, startYCoordinateForView, totalWidth, heightOfView);
        } else {
            _collectionView.frame = CGRectMake(startXCoordinateForView, startYCoordinateForView, totalWidth, Collapsed_Height);
        }
        
        startYCoordinateForView = _collectionView.frame.origin.y + _collectionView.frame.size.height;
        
        if (isExpanded) {
            
            heightOfView = self.view.frame.size.height - startYCoordinateForView;
            
            _tableView.frame = CGRectMake(startXCoordinateForView, startYCoordinateForView, totalWidth, heightOfView);
        } else {
            heightOfView = self.view.frame.size.height - Collapsed_Height;
            _tableView.frame = CGRectMake(startXCoordinateForView, startYCoordinateForView, totalWidth, heightOfView);
        }

        
    }completion:^(BOOL finished) {
        
        [_collectionView reloadData];
        [_tableView reloadData];
    }];
}

#define ItemsPerRow 7

#pragma mark - Custom Collection data source

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _listOfItems.count;
}

- (void)scrollToDay {
    
    [UIView animateWithDuration:0.1 animations:^{
        [self.collectionView scrollToItemAtIndexPath:focusedIndexPath atScrollPosition:UICollectionViewScrollPositionCenteredVertically animated:NO];
    }completion:^(BOOL finished){
        [self collectionView:_collectionView didSelectItemAtIndexPath:focusedIndexPath];
    }];
    
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    CalendarDay *calendarDay = _listOfItems[indexPath.row];
    
    NSDateComponents *componentsFromCalendarDay = [[CalendarUtils calendar] components:NSCalendarUnitMonth | NSCalendarUnitDay fromDate:calendarDay.associatedDate];
    
    if(componentsFromCalendarDay.day == 1) {
        CalendarViewCellWithMonth *cellWithMonth = [collectionView dequeueReusableCellWithReuseIdentifier:@"CellIdentifierForCellWithMonth" forIndexPath:indexPath];
        
        if (componentsFromCalendarDay.month % 2 == 0) {
            cellWithMonth.backgroundColor = EvenColor;
        } else {
            cellWithMonth.backgroundColor = OddColor;
        }
        
        [cellWithMonth updateWithModel:calendarDay];
        
        return cellWithMonth;
        
    } else {
        
        CalendarViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CellIdentifier" forIndexPath:indexPath];
        
        if (componentsFromCalendarDay.month % 2 == 0) {
            cell.backgroundColor = EvenColor;
        } else {
            cell.backgroundColor = OddColor;
        }
        
        [cell updateWithModel:calendarDay];
        
        if (self.selectedDate) {
            [cell setSelected:[CalendarUtils isDate1:calendarDay.associatedDate theSameDayAs:self.selectedDate]];
        }
        
        return cell;
    }
    
    return nil;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row <= _listOfItems.count) {
        
        if (_previouslySelectedIndexPath) {
            CalendarViewCell *previouslySelectedCell = (CalendarViewCell *)[collectionView cellForItemAtIndexPath:_previouslySelectedIndexPath];
            CalendarDay *previousSelectedDay = _listOfItems[_previouslySelectedIndexPath.row];
            previousSelectedDay.isDateSelected = NO;
            [previouslySelectedCell updateWithModel:previousSelectedDay];
        }
        
        CalendarDay *day = _listOfItems[indexPath.row];
        CalendarViewCell *cell = (CalendarViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
        
        CALayer *cellLayer = cell.contentView.layer;
        cellLayer.cornerRadius = cell.contentView.frame.size.width / 2;
        
        day.isDateSelected = YES;
        
        [cell updateWithModel:day];
        
        [self setHeaderTextForDay:day];
        
        _previouslySelectedIndexPath = indexPath;
        
        [_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:indexPath.row] atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }
}

- (void)setHeaderTextForDay:(CalendarDay *)calendarDay {
    NSDateComponents *componentsFromCalendarDay = [[CalendarUtils calendar] components:NSCalendarUnitMonth | NSCalendarUnitYear fromDate:calendarDay.associatedDate];
    self.title = [NSString stringWithFormat:@"%@ %ld", [MonthUtil symbolForMonth:(int)[componentsFromCalendarDay month]], [componentsFromCalendarDay year]];
}

#pragma mark - Scrollview delegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    self.selectedDate = nil;
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    
    if (scrollView.tag == Tag_EventView && [scrollView isKindOfClass:[UITableView class]]) {
        
        NSArray *visibleCellsFromEventsView = [_tableView visibleCells];
        UITableViewCell *topMostCell = [visibleCellsFromEventsView objectAtIndex:0];
        NSIndexPath *indexPathOfTopMostCell = [_tableView indexPathForCell:topMostCell];
        
        focusedIndexPath = [NSIndexPath indexPathForItem:indexPathOfTopMostCell.section inSection:0];
        
        [self scrollToDay];
    }
}

#pragma mark - Tableview methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _listOfItems.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    CalendarDay *day = [_listOfItems objectAtIndex:section];
    
    return (day.eventsOnDate.count) ? day.eventsOnDate.count : 1;   // No event cell for all dates
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *tableCellIdentifier = @"TableCellIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:tableCellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:tableCellIdentifier];
    }
    
    CalendarDay *day = [_listOfItems objectAtIndex:indexPath.section];
    
    if (day.eventsOnDate && day.eventsOnDate.count) {
        
        if (day.eventsOnDate[indexPath.row]) {
            
            CalendarEvent *event = [day.eventsOnDate objectAtIndex:indexPath.row];
            
            if (event.isSkype) {
               
                SkypeEventCell *skypeEventCell = [tableView dequeueReusableCellWithIdentifier:@"SkypeEventCell"];
                
                if (!skypeEventCell) {
                    skypeEventCell = [[SkypeEventCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"SkypeEventCell"];
                }
                
                [skypeEventCell updateWithEvent:event];
                
                return skypeEventCell;
                
            } else {
                
                EventCell *eventCell = [tableView dequeueReusableCellWithIdentifier:@"EventCell"];
                
                if (!eventCell) {
                    eventCell = [[EventCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"EventCell"];
                }
                
                [eventCell updateWithEvent:event];
                return eventCell;
                
            }
        }
    }
    
    cell.textLabel.text = NSLocalizedString(@"No Events", nil);
    cell.textLabel.textColor = RegularTextColor;
    
    return cell;
}

- (NSString *) titleForHeaderInSection:(NSInteger)section {
    CalendarDay *day = [_listOfItems objectAtIndex:section];
    
    NSDateComponents *components = [[CalendarUtils calendar] components:NSCalendarUnitWeekday | NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:day.associatedDate];
    
    NSString *messageToDisplay;
    
    if([CalendarUtils isDate1:[NSDate date] theSameDayAs:day.associatedDate]) {

        messageToDisplay = [NSString stringWithFormat:@"%@ %@ %@, %d %@ %ld", NSLocalizedString(@"Today", nil), DefaultEventSeparator, [WeekdayUtil symbolForDay:(int)[components weekday]], (int)[components day], [MonthUtil symbolForMonth:(int)[components month]], [components year]];
        
    } else {
 
        messageToDisplay = [NSString stringWithFormat:@"%@, %d %@ %ld", [WeekdayUtil symbolForDay:(int)[components weekday]], (int)[components day], [MonthUtil symbolForMonth:(int)[components month]], [components year]];
        
    }
    return messageToDisplay;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    focusedIndexPath = [NSIndexPath indexPathForItem:indexPath.section inSection:0];
    [self scrollToDay];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return Height_Of_Header_Section;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    CalendarDay *day = [_listOfItems objectAtIndex:indexPath.section];

    if (day.eventsOnDate && day.eventsOnDate.count) {
        
        if (day.eventsOnDate[indexPath.row]) {
            
            CalendarEvent *event = [day.eventsOnDate objectAtIndex:indexPath.row];
            
            if (event.isSkype) {
                return Skype_Event_Cell_Height;
            }
        }
    }
    
    return Other_Event_Cell_Height;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    UITableViewHeaderFooterView *headerView = [[UITableViewHeaderFooterView alloc] init];
    UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, totalWidth-20, 30)];
    headerLabel.font = [UIFont systemFontOfSize:MediumFontSize];
    headerLabel.text = [self titleForHeaderInSection:section];
    
    NSString *today = NSLocalizedString(@"Today", nil);
    
    if ([[headerLabel.text substringWithRange:NSMakeRange(0, today.length)] isEqualToString:today]) {
        headerLabel.textColor = IdentifiedDayTextColor;
    } else {
        headerLabel.textColor = RegularTextColor;
    }
    [headerView addSubview:headerLabel];
    
    return headerView;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
