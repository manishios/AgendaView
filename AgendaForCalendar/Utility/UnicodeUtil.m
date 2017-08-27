//
//  UnicodeUtil.m
//  AgendaForCalendar
//
//  Created by Manish Kumar on 27/08/2017.
//  Copyright © 2017 Manish Kumar. All rights reserved.
//

#import "UnicodeUtil.h"

@implementation UnicodeUtil

+ (UIImage *)characterImage:(NSString *)ch sizeOfControl:(CGSize)sizeOfControl {
    
    UIFont *font = [UIFont boldSystemFontOfSize:12];
    CGSize chsize = [ch sizeWithAttributes:@{ NSFontAttributeName : font }];
    CGSize imgsize = sizeOfControl;
    
    UIGraphicsBeginImageContextWithOptions(imgsize, NO, [UIScreen mainScreen].scale);
    
    CGRect rect = CGRectMake((imgsize.width - chsize.width) / 2.0, (imgsize.height - chsize.height) / 2.0, chsize.width, chsize.height);
    NSMutableParagraphStyle *pStyle = [[NSMutableParagraphStyle alloc] init];
    pStyle.alignment = NSTextAlignmentCenter;
    pStyle.lineBreakMode = NSLineBreakByClipping;
    NSDictionary *attrs = @{ NSFontAttributeName : font, NSParagraphStyleAttributeName : pStyle };
    [ch drawInRect:rect withAttributes:attrs];
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return newImage;
}
@end
