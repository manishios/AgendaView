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

#define RegularTextColor [UIColor lightGrayColor]

@interface CalendarDay : NSObject
@property (nonatomic, strong, readwrite) NSString *displayDate;
@property (nonatomic, strong, readwrite) NSArray *eventsOnDate;
@property (readwrite) BOOL isDateSelected;
@property (nonatomic, strong, readwrite) NSDate *associatedDate;
@end

@implementation CalendarDay

@end

@interface CalendarViewCell : UICollectionViewCell
@property (nonatomic) UILabel *dateText;
@end

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

@interface CalendarViewCellWithMonth : UICollectionViewCell
@property (nonatomic) UILabel *dateText;
@property (nonatomic) UILabel *monthName;
@end

@implementation CalendarViewCellWithMonth

- (instancetype)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    
    if (self) {
        self.dateText = [[UILabel alloc] initWithFrame:self.contentView.frame];
        _dateText.textColor = RegularTextColor;
        self.dateText.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:self.dateText];
        
        _monthName = [[UILabel alloc] initWithFrame:CGRectZero];
        _monthName.textAlignment = NSTextAlignmentCenter;
        _monthName.textColor = RegularTextColor;
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
        
        self.dateText.frame = CGRectMake(0, 0, self.contentView.frame.size.width, self.contentView.frame.size.height/2);
        [self.monthName setFrame:CGRectMake(0, self.contentView.frame.size.height/2, self.contentView.frame.size.width, self.contentView.frame.size.height/2)];
        self.monthName.text = monthText;
    } else {
        _monthName.hidden = YES;
    }
    
    if (calendarDay.isDateSelected) {
        layer.backgroundColor = [[UIColor blueColor] CGColor];
        self.dateText.textColor = [UIColor whiteColor];
        _monthName.textColor = [UIColor whiteColor];
    
    } else {
        layer.backgroundColor = [[UIColor clearColor] CGColor];
        self.dateText.textColor = RegularTextColor;
        _monthName.textColor = RegularTextColor;
    }
    
    [self layoutIfNeeded];
}

@end

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
@property (strong, readwrite, nonatomic) NSDate *selectedDate;
@end

@implementation ViewController

# pragma mark - Basic view initialization
- (void)initiateHeaderView {

    _dayHeaderView = [[UIView alloc] initWithFrame:CGRectMake(startXCoordinateForView, startYCoordinateForView, self.view.bounds.size.width, heightOfView)];
    [_dayHeaderView setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
//    _dayHeaderView.backgroundColor = [UIColor grayColor];
    
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
    
    if (!self.listOfItems) {
        _listOfItems = [NSMutableArray new];
    }
    
    NSCalendar *gregorian = [CalendarUtils calendar];
    
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
        
        if ([CalendarUtils isDate1:[NSDate date] theSameDayAs:associatedDate]) {
            focusedIndexPath = [NSIndexPath indexPathForItem:(index - componentsForFirstDate.day) inSection:0];
        }
        
        [self.listOfItems addObject:calendarDay];
    }
}

- (void)initiateCalendarView {
    
    UICollectionViewFlowLayout *flowLayout=[[UICollectionViewFlowLayout alloc] init];
    
    [flowLayout setItemSize:CGSizeMake(widthForOneDay, widthForOneDay)];
    [flowLayout setSectionInset:UIEdgeInsetsMake(0, 0, 0, 0)];
    [flowLayout setMinimumInteritemSpacing:CGFLOAT_MIN];
    [flowLayout setMinimumLineSpacing:CGFLOAT_MIN];
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
    
    [self.view addSubview:_collectionView];
    
    // Select the current date on launch
    [self scrollToDay];
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

    [self populateDataSource];

    self.selectedDate = [(CalendarDay *)[_listOfItems objectAtIndex:0] associatedDate];
    
    // Initiate the calendar header view
    [self initiateHeaderView];
    
    // Initiate the calendar grid view
    [self initiateCalendarView];
    
    // Initiate Event list view
    [self initiateEventListView];
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

#define ItemsPerRow 7

#pragma mark - Custom Collection data source

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

- (void)scrollToDay {
    [UIView animateWithDuration:0.1 animations:^{
        [self.collectionView scrollToItemAtIndexPath:focusedIndexPath atScrollPosition:UICollectionViewScrollPositionCenteredVertically animated:NO];
    }completion:^(BOOL finished){
        [self collectionView:_collectionView didSelectItemAtIndexPath:focusedIndexPath];
    }];
}

#define OddColor [UIColor clearColor]
#define EvenColor [UIColor groupTableViewBackgroundColor]

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
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

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    if (scrollView.tag == 1001 && [scrollView isKindOfClass:[UICollectionView class]]) {
        NSLog(@"Collection");
    }
    if (scrollView.tag == 1002 && [scrollView isKindOfClass:[UITableView class]]) {
        NSLog(@"TableView");
    }
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
        
        focusedIndexPath = [NSIndexPath indexPathForItem:indexPathOfTopMostCell.section inSection:0];
//        
//        CalendarViewCell *cell = (CalendarViewCell *)[_collectionView cellForItemAtIndexPath:pathForItemInCalendarView];
//        if (cell) {
//            NSLog(@"Text in scrolled collection cell %@", cell.dateText.text);
//        }
        
        [self scrollToDay];
//        [_collectionView scrollToItemAtIndexPath:pathForItemInCalendarView
//                                atScrollPosition:UICollectionViewScrollPositionCenteredVertically
//                                        animated:YES];
//        
//        [_collectionView selectItemAtIndexPath:pathForItemInCalendarView
//                                      animated:YES
//                                scrollPosition:UICollectionViewScrollPositionCenteredVertically];
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
        cell.textLabel.text = @"Some event";
    } else {
        cell.textLabel.text = @"No Event";
    }
    
    cell.textLabel.textColor = RegularTextColor;
    
    return cell;
}

- (NSString *) titleForHeaderInSection:(NSInteger)section {
    CalendarDay *day = [_listOfItems objectAtIndex:section];
    
    NSDateComponents *components = [[CalendarUtils calendar] components:NSCalendarUnitWeekday | NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:day.associatedDate];
    
    NSString *messageToDisplay = [NSString stringWithFormat:@"%@, %d %@ %ld", [WeekdayUtil symbolForDay:(int)[components weekday]], (int)[components day], [MonthUtil symbolForMonth:(int)[components month]], [components year]];
    
    return messageToDisplay;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    focusedIndexPath = [NSIndexPath indexPathForItem:indexPath.section inSection:0];
    [self scrollToDay];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 30;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    UITableViewHeaderFooterView *headerView = [[UITableViewHeaderFooterView alloc] init];
    UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, totalWidth-20, 30)];
    headerLabel.textColor = RegularTextColor;
    headerLabel.font = [UIFont systemFontOfSize:14];
    headerLabel.text = [self titleForHeaderInSection:section];
    [headerView addSubview:headerLabel];
    
    return headerView;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
