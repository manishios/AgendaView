//
//  ViewController.m
//  AgendaForCalendar
//
//  Created by Manish Kumar on 02/08/2017.
//  Copyright © 2017 Manish Kumar. All rights reserved.
//

#import "ViewController.h"
typedef enum : NSUInteger {
    Sunday = 1,
    Monday,
    Tuesday,
    Wednesday,
    Thursday,
    Friday,
    Saturday,
} WeekdayName;

typedef enum : NSUInteger {
    January = 1,
    February,
    March,
    April,
    May,
    June,
    July,
    August,
    September,
    October,
    November,
    December
} MonthName;

@interface CalendarDay : NSObject
@property (readwrite) NSString *displayDate;
@property (readwrite) NSArray *eventsOnDate;
@property (readwrite) BOOL isDateSelected;
@property (readwrite) NSDate *associatedDate;
@end

@implementation CalendarDay

@end

@interface CalendarViewCell : UICollectionViewCell
@property (nonatomic) UILabel *dateText;
@end

#define selectedDateFontSize    22
#define deselectedDateFontSize    17

@implementation CalendarViewCell

- (instancetype)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    
    if (self) {
        self.dateText = [[UILabel alloc] initWithFrame:self.contentView.frame];
        
        _dateText.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:_dateText];
    }
    
    return self;
}

-(void)layoutSubviews {
    
}

- (void)updateWithModel:(CalendarDay *)calendarDay {
    
    self.dateText.text = calendarDay.displayDate;

    CALayer *layer = self.contentView.layer;
    
    if (calendarDay.isDateSelected) {
        layer.backgroundColor = [[UIColor blueColor] CGColor];
        layer.cornerRadius = self.contentView.frame.size.width/2;
        _dateText.textColor = [UIColor whiteColor];
        _dateText.font = [UIFont boldSystemFontOfSize:selectedDateFontSize];
    } else {
        layer.backgroundColor = [[UIColor clearColor] CGColor];
        _dateText.textColor = [UIColor darkTextColor];
        _dateText.font = [UIFont systemFontOfSize:deselectedDateFontSize];
    }
    
    [self layoutIfNeeded];
}


@end

@interface CalendarViewCellWithMonth : CalendarViewCell
@property (nonatomic) UILabel *monthName;
@end

@implementation CalendarViewCellWithMonth

- (instancetype)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    
    if (self) {
        self.dateText = [[UILabel alloc] initWithFrame:self.contentView.frame];
        
        super.dateText.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:super.dateText];
        
        self.monthName = [[UILabel alloc] initWithFrame:CGRectZero];
        _monthName.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:_monthName];
    }
    
    return self;
}

-(void)layoutSubviews {
    
}

- (void)updateWithModel:(CalendarDay *)calendarDay {
    
    self.dateText.text = calendarDay.displayDate;
    
    CALayer *layer = self.contentView.layer;
    
    if (calendarDay.displayDate.integerValue == 1) {
        NSDateComponents *componentsFromCalendarDay = [[NSCalendar currentCalendar] components:NSCalendarUnitMonth | NSCalendarUnitYear fromDate:calendarDay.associatedDate];
        
        NSString *monthText = [NSString stringWithFormat:@"%@", [self shortSymbolForMonth:(int)[componentsFromCalendarDay month]]];
        
        self.dateText.frame = CGRectMake(0, 0, self.contentView.frame.size.width, self.contentView.frame.size.height/2);
        [self.monthName setFrame:CGRectMake(0, self.contentView.frame.size.height/2, self.contentView.frame.size.width, self.contentView.frame.size.height/2)];
        self.monthName.text = monthText;
    } else {
        _monthName.hidden = YES;
    }
    
    if (calendarDay.isDateSelected) {
        layer.backgroundColor = [[UIColor blueColor] CGColor];
        layer.cornerRadius = self.contentView.frame.size.width/2;
        super.dateText.textColor = [UIColor whiteColor];
        super.dateText.font = [UIFont boldSystemFontOfSize:selectedDateFontSize];
        _monthName.textColor = [UIColor whiteColor];
    
    } else {
        layer.backgroundColor = [[UIColor clearColor] CGColor];
        super.dateText.textColor = [UIColor darkTextColor];
        super.dateText.font = [UIFont systemFontOfSize:deselectedDateFontSize];
        _monthName.textColor = [UIColor darkTextColor];
        //        _monthName.font = [UIFont systemFontOfSize:deselectedDateFontSize];
    }
    
    [self layoutIfNeeded];
}

- (NSString *)shortSymbolForMonth:(int)monthIndex {
    
    NSString *monthName;
    
    switch (monthIndex) {
        case January:
            monthName = NSLocalizedString(@"Jan", nil);
            break;
            
        case February:
            monthName = NSLocalizedString(@"Feb", nil);
            break;
            
        case March:
            monthName = NSLocalizedString(@"Mar", nil);
            break;
            
        case April:
            monthName = NSLocalizedString(@"Apr", nil);
            break;
            
        case May:
            monthName = NSLocalizedString(@"May", nil);
            break;
            
        case June:
            monthName = NSLocalizedString(@"Jun", nil);
            break;
            
        case July:
            monthName = NSLocalizedString(@"Jul", nil);
            break;
            
        case August:
            monthName = NSLocalizedString(@"Aug", nil);
            break;
            
        case September:
            monthName = NSLocalizedString(@"Sep", nil);
            break;
            
        case October:
            monthName = NSLocalizedString(@"Oct", nil);
            break;
            
        case November:
            monthName = NSLocalizedString(@"Nov", nil);
            break;
            
        case December:
            monthName = NSLocalizedString(@"Dec", nil);
            break;
    }
    
    return monthName;
}

@end

@interface ViewController () <UICollectionViewDelegate, UICollectionViewDataSource, UIScrollViewDelegate, UITableViewDelegate, UITableViewDataSource>

{
    CGFloat startYCoordinateForView ;
    CGFloat heightOfView;
    CGFloat startXCoordinateForView;
    CGFloat totalWidth;
    CGFloat widthForOneDay;
    BOOL isExpanded;
}

@property (nonatomic) UITableView *tableView;
@property (nonatomic) UICollectionView *collectionView;
@property (nonatomic) UIView *dayHeaderView;
@property (nonatomic) NSMutableArray <CalendarDay *> *listOfItems;
@property (nonatomic) NSIndexPath *previouslySelectedIndexPath;
@property (nonatomic) UITableView *eventsListView;
@end

@implementation ViewController

# pragma mark - Data formatter
// dayIndex starts from 1-7, week starts from Sunday = 1 Saturday = 7
- (NSString *)symbolForDay:(int)dayIndex {
    
    NSString *dayName;
    
    switch (dayIndex) {
        case Sunday:
            dayName = NSLocalizedString(@"SU", nil);
            break;
            
        case Monday:
            dayName = NSLocalizedString(@"MO", nil);
            break;
        
        case Tuesday:
            dayName = NSLocalizedString(@"TU", nil);
            break;
        
        case Wednesday:
            dayName = NSLocalizedString(@"WE", nil);
            break;
        
        case Thursday:
            dayName = NSLocalizedString(@"TH", nil);
            break;
        
        case Friday:
            dayName = NSLocalizedString(@"FR", nil);
            break;
        
        case Saturday:
            dayName = NSLocalizedString(@"SA", nil);
            break;
    }
    
    return dayName;
}

- (NSString *)symbolForMonth:(int)monthIndex {
    
    NSString *monthName;
    
    switch (monthIndex) {
        case January:
            monthName = NSLocalizedString(@"January", nil);
            break;
            
        case February:
            monthName = NSLocalizedString(@"February", nil);
            break;
            
        case March:
            monthName = NSLocalizedString(@"March", nil);
            break;
            
        case April:
            monthName = NSLocalizedString(@"April", nil);
            break;
            
        case May:
            monthName = NSLocalizedString(@"May", nil);
            break;
            
        case June:
            monthName = NSLocalizedString(@"June", nil);
            break;
            
        case July:
            monthName = NSLocalizedString(@"July", nil);
            break;
            
        case August:
            monthName = NSLocalizedString(@"August", nil);
            break;
            
        case September:
            monthName = NSLocalizedString(@"September", nil);
            break;
            
        case October:
            monthName = NSLocalizedString(@"October", nil);
            break;
            
        case November:
            monthName = NSLocalizedString(@"November", nil);
            break;
            
        case December:
            monthName = NSLocalizedString(@"December", nil);
            break;
    }
    
    return monthName;
}

# pragma mark - Basic view initialization
- (void)initiateHeaderView {

    _dayHeaderView = [[UIView alloc] initWithFrame:CGRectMake(startXCoordinateForView, startYCoordinateForView, self.view.bounds.size.width, heightOfView)];
//    [_dayHeaderView setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    _dayHeaderView.backgroundColor = [UIColor grayColor];
    
    for (int index=1; index<=7; index++) {
        UILabel *dayView = [[UILabel alloc] initWithFrame:CGRectMake(startXCoordinateForView, 0, widthForOneDay, heightOfView)];
        
        dayView.text = [self symbolForDay:index];
        dayView.textAlignment = NSTextAlignmentCenter;
        dayView.textColor = [UIColor whiteColor];
        
        [_dayHeaderView addSubview:dayView];
        
        startXCoordinateForView += widthForOneDay;
    }
    [self.view addSubview:self.dayHeaderView];
}

- (NSInteger)daysBetweenDate:(NSDate*)fromDateTime andDate:(NSDate*)toDateTime
{
    NSDate *fromDate;
    NSDate *toDate;
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    [calendar rangeOfUnit:NSCalendarUnitDay startDate:&fromDate
                 interval:NULL forDate:fromDateTime];
    [calendar rangeOfUnit:NSCalendarUnitDay startDate:&toDate
                 interval:NULL forDate:toDateTime];
    
    NSDateComponents *difference = [calendar components:NSCalendarUnitDay
                                               fromDate:fromDate toDate:toDate options:0];
    
    return [difference day];
}

- (void)populateDataSource {
    
    if (!self.listOfItems) {
        _listOfItems = [NSMutableArray new];
    }
    
    NSCalendar *gregorian = [NSCalendar currentCalendar];
    
    NSDate *firstDate = [NSDate dateWithTimeIntervalSince1970:1262476800]; // Epoch time is 3rd Jan 2010. 1262476800 is the time interval since 1970
    NSDate *endDate = [NSDate dateWithTimeIntervalSince1970:1578700800]; // Epoch time is 11th Jan 2020. 1578700800 is the time interval since 1970
    
    NSInteger daysBetweenDates = [self daysBetweenDate:firstDate andDate:endDate];
    NSDateComponents *componentsForFirstDate = [gregorian components:NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitYear fromDate:firstDate];
    
    // Get the weekday component of the current date
    NSDateComponents *weekdayComponents = [gregorian components:NSCalendarUnitWeekday fromDate:firstDate];
    
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
    [componentsToSubtract setDay: - ([weekdayComponents weekday] - [gregorian firstWeekday])];
    
    NSDate *associatedDate = firstDate;
    
    NSDateComponents* deltaComps = [NSDateComponents new];
    
    
    for (NSInteger index = componentsForFirstDate.day; index <= daysBetweenDates; index++) {
        
        CalendarDay *calendarDay = [CalendarDay new];
        
        if (index == componentsForFirstDate.day) {
            [deltaComps setDay:0];
        } else {
            [deltaComps setDay:1];
        }
        associatedDate = [gregorian dateByAddingComponents:deltaComps toDate:associatedDate options:0];
        calendarDay.associatedDate = associatedDate;
        
        calendarDay.eventsOnDate = nil;
        NSDateComponents *components = [gregorian components:NSCalendarUnitDay fromDate:associatedDate];
        calendarDay.displayDate = [NSString stringWithFormat:@"%ld", components.day];
        
        [self.listOfItems addObject:calendarDay];
    }
}

- (void)initiateCalendarView {
    
    [self populateDataSource];
    
    UICollectionViewFlowLayout *flowLayout=[[UICollectionViewFlowLayout alloc] init];
    
    [flowLayout setItemSize:CGSizeMake(320/6, 320/6)];
    [flowLayout setMinimumLineSpacing:5];
    [flowLayout setMinimumInteritemSpacing:1];
    [flowLayout setSectionInset:UIEdgeInsetsMake(0, 0, 0, 0)];
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
    
    startYCoordinateForView = self.dayHeaderView.frame.origin.y + self.dayHeaderView.frame.size.height;
    heightOfView = (self.view.frame.size.height - startYCoordinateForView)/2;
    startXCoordinateForView = CGFLOAT_MIN;
    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(startXCoordinateForView, startYCoordinateForView, self.view.bounds.size.width, heightOfView) collectionViewLayout:flowLayout];
    
    _collectionView.tag = 1001;
    [_collectionView setDataSource:self];
    [_collectionView setDelegate:self];
    
    [_collectionView registerClass:[CalendarViewCell class] forCellWithReuseIdentifier:@"CellIdentifier"];
    [_collectionView registerClass:[CalendarViewCellWithMonth class] forCellWithReuseIdentifier:@"CellIdentifierForCellWithMonth"];
    [_collectionView setBackgroundColor:[UIColor whiteColor]];
    
    [_collectionView addObserver:self forKeyPath:@"contentSize" options:NSKeyValueObservingOptionOld context:NULL];

    [self.view addSubview:_collectionView];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary  *)change context:(void *)context
{
    // You will get here when the reloadData finished
    for (CalendarDay *day in _listOfItems) {
        if ([day.associatedDate isEqual:[NSDate date]]) {
            
//            NSIndexPath
//            [UIView animateWithDuration:0.1 animations:^{
//                [_collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredVertically animated:YES];
//            }completion:^(BOOL finished){
//                [_collectionView selectItemAtIndexPath:indexPath animated:YES scrollPosition:UICollectionViewScrollPositionCenteredVertically];
//            }];
            
            
        }
    }
}

- (void)setSelectedDay:(CalendarDay *)selectedDay {
    
}

- (NSArray *)calendarDaysForMonth:(int)monthIndex{
    return nil;
}

- (void)initiateCurrentMonthOnLaunch {
    
    // initialize
    NSDate *today = [NSDate date]; //Get a date object for today's date
    
    NSCalendar *gregorianCalendar = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian];
    NSInteger weekDay = [gregorianCalendar component:NSCalendarUnitWeekday fromDate:today];
    NSInteger monthDate = [gregorianCalendar component:NSCalendarUnitDay fromDate:today];
    NSInteger monthNumber = [gregorianCalendar component:NSCalendarUnitMonth fromDate:today];
    
    NSInteger weekDay2 = [gregorianCalendar component:NSCalendarUnitWeekdayOrdinal fromDate:today];
    
    NSCalendar *currentCalendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [currentCalendar components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:today];
    
//    _listOfItems = [NSMutableArray new];
    
    self.title = [NSString stringWithFormat:@"%@ %ld", [self symbolForMonth:(int)[components month]], [components year]];

//    NSRange days = [currentCalendar rangeOfUnit:NSCalendarUnitDay
//                                         inUnit:NSCalendarUnitMonth
//                                        forDate:today];
//    
//    for (int index=1; index<=days.length; index++) {
//        CalendarDay *calendarDay = [CalendarDay new];
//        
//        calendarDay.displayDate = [NSString stringWithFormat:@"%d", index];
//        calendarDay.eventsOnDate = nil;
//        
//        [self.listOfItems addObject:calendarDay];
//    }
}

- (void)initiateEventListView {
    
    startYCoordinateForView = _collectionView.frame.origin.y + _collectionView.frame.size.height;
    heightOfView = self.view.frame.size.height - startYCoordinateForView;
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(startXCoordinateForView, startYCoordinateForView, self.view.frame.size.width, heightOfView) style:UITableViewStylePlain];
    
    _tableView.tag = 1002;
    _tableView.dataSource = self;
    _tableView.delegate = self;
    [self.view addSubview:_tableView];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    startYCoordinateForView = 64;
    heightOfView = 40;
    startXCoordinateForView = CGFLOAT_MIN;
    totalWidth = self.view.bounds.size.width;
    widthForOneDay = totalWidth/7;
    
    // Initiate the calendar header view
    [self initiateHeaderView];
    
    // Initiate the calendar grid view
    [self initiateCalendarView];
    
    // Initiate Event list view
    [self initiateEventListView];
    
    // set up calendar
    [self initiateCurrentMonthOnLaunch];
    
//    [self createToggleViewBarButton];
}

- (void)createToggleViewBarButton {
    UIBarButtonItem *toggleViewBarButton = [[UIBarButtonItem alloc] initWithTitle:@"Hi" style:UIBarButtonItemStylePlain target:self action:@selector(toggleAgendaView:)];
    self.navigationItem.rightBarButtonItem = toggleViewBarButton;
}

- (void)toggleAgendaView:(UIBarButtonItem *)button {
    
    
    [UIView animateWithDuration:0.25 animations:^{
        if (isExpanded) {
            _collectionView.frame = CGRectMake(0, 0, 320, 200);
        } else {
            _collectionView.frame = CGRectMake(0, 0, 320, 500);
        }
        
    }completion:^(BOOL finished) {
        if (isExpanded) {
            _tableView.frame = CGRectMake(0, 200, 320, 500);
        } else {
            _tableView.frame = CGRectMake(0, 500, 320, 200);
        }
    }];
    
    isExpanded =  !isExpanded;
}

#pragma mark - Custom Collection data source
- (void)addDaysToDataSourceAfterMonth:(int)currentMonth {
    
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _listOfItems.count;
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
 
    return YES;
}

#define OddColor [UIColor clearColor]
#define EvenColor [UIColor groupTableViewBackgroundColor]

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CalendarDay *calendarDay = _listOfItems[indexPath.row];
    
    NSDateComponents *componentsFromCalendarDay = [[NSCalendar currentCalendar] components:NSCalendarUnitMonth | NSCalendarUnitDay fromDate:calendarDay.associatedDate];
    
    if(componentsFromCalendarDay.day == 1) {
        CalendarViewCell *cellWithMonth = [collectionView dequeueReusableCellWithReuseIdentifier:@"CellIdentifierForCellWithMonth" forIndexPath:indexPath];
        
        if (componentsFromCalendarDay.month % 2 == 0) {
            cellWithMonth.backgroundColor = EvenColor;
        } else {
            cellWithMonth.backgroundColor = OddColor;
        }
        [cellWithMonth updateWithModel:calendarDay];
        
        return cellWithMonth;
    }
    
    CalendarViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CellIdentifier" forIndexPath:indexPath];
    if (componentsFromCalendarDay.month % 2 == 0) {
        cell.backgroundColor = EvenColor;
    } else {
        cell.backgroundColor = OddColor;
    }
    [cell updateWithModel:calendarDay];

    return cell;
}

//- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
//{
//    return CGSizeMake(widthForOneDay, widthForOneDay);
//}

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
        day.isDateSelected = YES;
        
        [cell updateWithModel:day];
        
        [self setHeaderTextForDay:day];
        
        _previouslySelectedIndexPath = indexPath;
        
        [_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:indexPath.row] atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }
}

- (void)setHeaderTextForDay:(CalendarDay *)calendarDay {
    NSDateComponents *componentsFromCalendarDay = [[NSCalendar currentCalendar] components:NSCalendarUnitMonth | NSCalendarUnitYear fromDate:calendarDay.associatedDate];
    self.title = [NSString stringWithFormat:@"%@ %ld", [self symbolForMonth:(int)[componentsFromCalendarDay month]], [componentsFromCalendarDay year]];
}

#pragma mark - Scrollview delegate

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    if (scrollView.tag == 1001 && [scrollView isKindOfClass:[UICollectionView class]]) {
        NSLog(@"Collection");
    }
    if (scrollView.tag == 1002 && [scrollView isKindOfClass:[UITableView class]]) {
        NSLog(@"TableView");
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
//    
//    if (scrollView.tag == 1001 && [scrollView isKindOfClass:[UICollectionView class]]) {
//        NSLog(@"Collection");
//    }
//    if (scrollView.tag == 1002 && [scrollView isKindOfClass:[UITableView class]]) {
//        NSLog(@"TableView");
//        
//        NSArray *visibleCellsFromEventsView = [_tableView visibleCells];
//        UITableViewCell *topMostCell = [visibleCellsFromEventsView objectAtIndex:0];
//        NSIndexPath *indexPathOfTopMostCell = [_tableView indexPathForCell:topMostCell];
//        
//        NSIndexPath *pathForItemInCalendarView = [NSIndexPath indexPathForItem:indexPathOfTopMostCell.section inSection:0];
//        
//        CalendarViewCell *cell = (CalendarViewCell *)[_collectionView cellForItemAtIndexPath:pathForItemInCalendarView];
//        if (cell) {
//            NSLog(@"Text in scrolled collection cell %@", cell.dateText.text);
//        }
//        
//        [_collectionView scrollToItemAtIndexPath:pathForItemInCalendarView
//                                atScrollPosition:UICollectionViewScrollPositionCenteredVertically
//                                        animated:YES];
//        
//        [_collectionView selectItemAtIndexPath:pathForItemInCalendarView
//                                      animated:YES
//                                scrollPosition:UICollectionViewScrollPositionCenteredVertically];
//    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    
    if (scrollView.tag == 1001 && [scrollView isKindOfClass:[UICollectionView class]]) {
        NSLog(@"Collection");
    }
    if (scrollView.tag == 1002 && [scrollView isKindOfClass:[UITableView class]]) {
        NSLog(@"TableView");
        
        NSArray *visibleCellsFromEventsView = [_tableView visibleCells];
        UITableViewCell *topMostCell = [visibleCellsFromEventsView objectAtIndex:0];
        NSIndexPath *indexPathOfTopMostCell = [_tableView indexPathForCell:topMostCell];
        
        NSIndexPath *pathForItemInCalendarView = [NSIndexPath indexPathForItem:indexPathOfTopMostCell.section inSection:0];
        
        CalendarViewCell *cell = (CalendarViewCell *)[_collectionView cellForItemAtIndexPath:pathForItemInCalendarView];
        if (cell) {
            NSLog(@"Text in scrolled collection cell %@", cell.dateText.text);
        }
        
        [_collectionView scrollToItemAtIndexPath:pathForItemInCalendarView
                                atScrollPosition:UICollectionViewScrollPositionCenteredVertically
                                        animated:YES];
        
        [_collectionView selectItemAtIndexPath:pathForItemInCalendarView
                                      animated:YES
                                scrollPosition:UICollectionViewScrollPositionCenteredVertically];
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
    
    if (day.eventsOnDate.count) {
        cell.textLabel.text = @"None";
    } else {
        cell.textLabel.text = @"An event";
    }
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    CalendarDay *day = [_listOfItems objectAtIndex:section];
    
    return day.displayDate;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSInteger indexPathForDateInCollectionView = indexPath.section;
    
    NSIndexPath *indexPathForItemInDateCollection = [NSIndexPath indexPathForItem:indexPathForDateInCollectionView inSection:0];
    
    [_collectionView selectItemAtIndexPath:indexPathForItemInDateCollection
                                  animated:YES
                            scrollPosition:UICollectionViewScrollPositionTop];
    
//    [_collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:indexPathForDateInCollectionView inSection:0] atScrollPosition:UICollectionViewScrollPositionTop animated:YES];
    
}
//- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
//    
//    UITableViewHeaderFooterView *headerView = [UITableViewHeaderFooterView new];
//    
//}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
