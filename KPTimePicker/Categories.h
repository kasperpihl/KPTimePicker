//
//  Categories.h
//  KPTimePickerExample
//
//  Created by Kasper Pihl Tornøe on 15/11/13.
//  Copyright (c) 2013 Pihl IT. All rights reserved.
//

#import <UIKit/UIKit.h>
#define radians(degrees) (degrees * M_PI / 180)
#define degrees(radians) (radians * 180 / M_PI)
#define color(r,g,b,a) [UIColor colorWithRed: r/255.0 green: g/255.0 blue: b/255.0 alpha:a]
#define OSVER [KPUtil OSVersion]
#define sizeWithFont(string,font) ((OSVER < 7) ? [string sizeWithFont:font] : [string sizeWithAttributes:@{NSFontAttributeName:font}])
#define kIsIphone5Size (fabs((double)[[UIScreen mainScreen] bounds].size.height - (double) 568) < DBL_EPSILON)
#define valForScreen(iphone4, iphone5) (kIsIphone5Size ? iphone5 : iphone4)

@interface NSDate (Util)
- (NSDate *)dateToNearestMinutes:(NSInteger)minutes;

- (NSDate *) dateByAddingMinutes: (NSInteger) dMinutes;
- (NSDate *) dateBySubtractingMinutes: (NSInteger) dMinutes;

- (NSDate *) dateAtStartOfDay;

- (NSInteger) minutesAfterDate: (NSDate *) aDate;
- (NSInteger)distanceInDaysToDate:(NSDate *)anotherDate;

- (BOOL) isSameYearAsDate: (NSDate *) aDate;
- (BOOL) isEarlierThanDate: (NSDate *) aDate;
- (BOOL) isLaterThanDate: (NSDate *) aDate;
@end
@interface KPUtil : NSObject
+ (NSInteger)OSVersion;
+(NSString*)dayStringForDate:(NSDate*)date;
@end
@interface SlowHighlightIcon : UIButton

@end
@interface UIColor (Utilities)
-(UIColor *)colorToColor:(UIColor *)toColor percent:(float)percent;
-(UIImage*)image;
@end