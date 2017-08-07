//
//  ViewController.m
//  AgendaForCalendar
//
//  Created by Manish Kumar on 02/08/2017.
//  Copyright © 2017 Manish Kumar. All rights reserved.
//

#import "ViewController.h"

@interface CalendarDay : NSObject
@property (readwrite) NSString *displayDate;
@property (readwrite) NSArray *eventsOnDate;
@property (readwrite) BOOL isDateSelected;
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

typedef enum : NSUInteger {
    Sunday,
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

@interface ViewController () <UICollectionViewDelegate, UICollectionViewDataSource, UIScrollViewDelegate, UITableViewDelegate, UITableViewDataSource>

{
    CGFloat startYCoordinateForView ;
    CGFloat heightOfView;
    CGFloat startXCoordinateForView;
    CGFloat totalWidth;
    CGFloat widthForOneDay;
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
// dayIndex starts from 0-6, week starts from Sunday = 0 Saturday = 6
- (NSString *)symbolForDay:(int)dayIndex {
    
    NSString *dayName;
    
    switch (dayIndex) {
        case Sunday:
            dayName = NSLocalizedString(@"S", nil);
            break;
            
        case Monday:
            dayName = NSLocalizedString(@"M", nil);
            break;
        
        case Tuesday:
            dayName = NSLocalizedString(@"T", nil);
            break;
        
        case Wednesday:
            dayName = NSLocalizedString(@"W", nil);
            break;
        
        case Thursday:
            dayName = NSLocalizedString(@"T", nil);
            break;
        
        case Friday:
            dayName = NSLocalizedString(@"F", nil);
            break;
        
        case Saturday:
            dayName = NSLocalizedString(@"S", nil);
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
    
    for (int index=0; index<7; index++) {
        UILabel *dayView = [[UILabel alloc] initWithFrame:CGRectMake(startXCoordinateForView, 0, widthForOneDay, heightOfView)];
        
        dayView.text = [self symbolForDay:index];
        dayView.textAlignment = NSTextAlignmentCenter;
        dayView.textColor = [UIColor whiteColor];
        
        [_dayHeaderView addSubview:dayView];
        
        startXCoordinateForView += widthForOneDay;
    }
    [self.view addSubview:self.dayHeaderView];
}

- (void)initiateCalendarView {
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
    [_collectionView setBackgroundColor:[UIColor whiteColor]];
    
    [self.view addSubview:_collectionView];
}

- (void)setSelectedDay:(CalendarDay *)selectedDay {
    
}

- (NSArray *)calendarDaysForMonth:(int)monthIndex{
    return nil;
}

- (void)initiateCurrentMonthOnLaunch {
    // initialize
    NSDate *today = [NSDate date]; //Get a date object for today's date
    NSCalendar *currentCalendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [currentCalendar components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:today];
    
    _listOfItems = [NSMutableArray new];
    
    self.title = [NSString stringWithFormat:@"%@ %ld", [self symbolForMonth:(int)[components month]], [components year]];

    NSRange days = [currentCalendar rangeOfUnit:NSCalendarUnitDay
                                         inUnit:NSCalendarUnitMonth
                                        forDate:today];
    
    for (int index=1; index<=days.length; index++) {
        CalendarDay *calendarDay = [CalendarDay new];
        
        calendarDay.displayDate = [NSString stringWithFormat:@"%d", index];
        calendarDay.eventsOnDate = nil;
        
        [self.listOfItems addObject:calendarDay];
    }
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
    
//     [_collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0 ] atScrollPosition:UICollectionViewScrollPositionCenteredVertically animated:YES];
//    [_collectionView selectItemAtIndexPath:[NSIndexPath indexPathForItem:8 inSection:0] animated:YES scrollPosition:UICollectionViewScrollPositionCenteredVertically];
    
    
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

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CalendarViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CellIdentifier" forIndexPath:indexPath];
    
    CalendarDay *calendarDay = _listOfItems[indexPath.row];
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
        
        _previouslySelectedIndexPath = indexPath;
        
        [_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:indexPath.row] atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }
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
    
//    [_collectionView selectItemAtIndexPath:indexPathForItemInDateCollection
//                                  animated:YES
//                            scrollPosition:UICollectionViewScrollPositionTop];
    
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
