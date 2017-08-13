//
//  MonthUtil.h
//  AgendaForCalendar
//
//  Created by Manish Kumar on 13/08/2017.
//  Copyright © 2017 Manish Kumar. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MonthUtil : NSObject

+ (NSString *)shortSymbolForMonth:(int)monthIndex;
+ (NSString *)symbolForMonth:(int)monthIndex;

@end
