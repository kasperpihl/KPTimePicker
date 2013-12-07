//
//  Categories.m
//  KPTimePickerExample
//
//  Created by Kasper Pihl Tornøe on 15/11/13.
//  Copyright (c) 2013 Pihl IT. All rights reserved.
//

#import "Categories.h"
#define DATE_COMPONENTS (NSEraCalendarUnit | NSYearCalendarUnit| NSMonthCalendarUnit | NSDayCalendarUnit | NSWeekCalendarUnit |  NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit | NSWeekdayCalendarUnit | NSWeekdayOrdinalCalendarUnit)
#define CURRENT_CALENDAR [NSCalendar currentCalendar]
#define D_MINUTE	60
@implementation KPUtil
+ (NSInteger)OSVersion
{
    static NSUInteger _deviceSystemMajorVersion = -1;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _deviceSystemMajorVersion = [[[[[UIDevice currentDevice] systemVersion] componentsSeparatedByString:@"."] objectAtIndex:0] intValue];
    });
    return _deviceSystemMajorVersion;
}
+(NSString*)dayStringForDate:(NSDate*)date{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSLocale *usLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    [dateFormatter setLocale:usLocale];
    if([date isSameYearAsDate:[NSDate date]]) dateFormatter.dateFormat = @"d LLL";
    else dateFormatter.dateFormat = @"d LLL '´'yy";
    NSString *endingString = [dateFormatter stringFromDate:date];
    
    
    NSDate *beginningOfDate = [date dateAtStartOfDay];
    NSInteger numberOfDaysAfterTodays = [beginningOfDate distanceInDaysToDate:[[NSDate date] dateAtStartOfDay]];
    NSString *dayString;
    if(numberOfDaysAfterTodays == 0){
        dayString = @"Today";
        if([date isLaterThanDate:[NSDate date]]) dayString = @"Today";
    }
    else if(numberOfDaysAfterTodays == -1) dayString = @"Tomorrow";
    else if(numberOfDaysAfterTodays == 1) dayString = @"Yesterday";
    else{
        dateFormatter.dateFormat = @"EEE";
    }
    if(!dayString) dayString = [dateFormatter stringFromDate:date];
    return [NSString stringWithFormat:@"%@ - %@",dayString,endingString];
}
@end

@implementation SlowHighlightIcon
-(void)setHighlighted:(BOOL)highlighted{
    if(highlighted != self.highlighted){
        [UIView transitionWithView:self
                          duration:0.3
                           options:UIViewAnimationOptionTransitionCrossDissolve
                        animations:^{ [super setHighlighted:highlighted]; }
                        completion:nil];
    }
}
@end

@implementation UIColor (Utilities)
- (UIColor *)colorToColor:(UIColor *)toColor percent:(float)percent
{
    float dec = percent / 100.f;
    CGFloat fRed, fBlue, fGreen, fAlpha;
    CGFloat tRed, tBlue, tGreen, tAlpha;
    CGFloat red, green, blue, alpha;
    
    if(CGColorGetNumberOfComponents(self.CGColor) == 2) {
        [self getWhite:&fRed alpha:&fAlpha];
        fGreen = fRed;
        fBlue = fRed;
    }
    else {
        [self getRed:&fRed green:&fGreen blue:&fBlue alpha:&fAlpha];
    }
    if(CGColorGetNumberOfComponents(toColor.CGColor) == 2) {
        [toColor getWhite:&tRed alpha:&tAlpha];
        tGreen = tRed;
        tBlue = tRed;
    }
    else {
        [toColor getRed:&tRed green:&tGreen blue:&tBlue alpha:&tAlpha];
    }
    
    red = (dec * (tRed - fRed)) + fRed;
    green = (dec * (tGreen - fGreen)) + fGreen;
    blue = (dec * (tBlue - fBlue)) + fBlue;
    alpha = (dec * (tAlpha - fAlpha)) + fAlpha;
    
    return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
}
- (UIImage *)image{
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [self CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

@end

@implementation NSDate (Util)
- (NSDate *) dateAtStartOfDay
{
	NSDateComponents *components = [CURRENT_CALENDAR components:DATE_COMPONENTS fromDate:self];
	components.hour = 0;
	components.minute = 0;
	components.second = 0;
	return [CURRENT_CALENDAR dateFromComponents:components];
}
- (NSInteger) minutesAfterDate: (NSDate *) aDate
{
	NSTimeInterval ti = [self timeIntervalSinceDate:aDate];
	return (NSInteger) (ti / D_MINUTE);
}
- (NSDate *) dateByAddingMinutes: (NSInteger) dMinutes
{
	NSTimeInterval aTimeInterval = [self timeIntervalSinceReferenceDate] + D_MINUTE * dMinutes;
	NSDate *newDate = [NSDate dateWithTimeIntervalSinceReferenceDate:aTimeInterval];
	return newDate;
}

- (NSDate *) dateBySubtractingMinutes: (NSInteger) dMinutes
{
	return [self dateByAddingMinutes: (dMinutes * -1)];
}
- (NSDate *)dateToNearestMinutes:(NSInteger)minutes {
    unsigned unitFlags = NSYearCalendarUnit| NSMonthCalendarUnit | NSDayCalendarUnit | NSWeekCalendarUnit |  NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit | NSWeekdayCalendarUnit | NSWeekdayOrdinalCalendarUnit;
    // Extract components.
    NSDateComponents *time = [[NSCalendar currentCalendar] components:unitFlags fromDate:self];
    NSInteger thisMin = [time minute];
    NSDate *newDate;
    int remain = thisMin % minutes;
    // if less then 3 then round down
    NSInteger dividor = ceil(minutes/2);
    if (remain<dividor){
    	// Subtract the remainder of time to the date to round it down evenly
    	newDate = [self dateByAddingTimeInterval:-60*(remain)];
    }else{
    	// Add the remainder of time to the date to round it up evenly
    	newDate = [self dateByAddingTimeInterval:60*(minutes-remain)];
    }
    NSDateComponents *comps = [[NSCalendar currentCalendar] components:unitFlags fromDate:newDate];
    [comps setSecond:0];
    return [[NSCalendar currentCalendar] dateFromComponents:comps];
}
- (BOOL) isEarlierThanDate: (NSDate *) aDate
{
	return ([self compare:aDate] == NSOrderedAscending);
}

- (BOOL) isLaterThanDate: (NSDate *) aDate
{
	return ([self compare:aDate] == NSOrderedDescending);
}
- (NSInteger)distanceInDaysToDate:(NSDate *)anotherDate
{
    NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *components = [gregorianCalendar components:NSDayCalendarUnit fromDate:self toDate:anotherDate options:0];
    return components.day;
}
- (BOOL) isSameYearAsDate: (NSDate *) aDate
{
	NSDateComponents *components1 = [CURRENT_CALENDAR components:NSYearCalendarUnit fromDate:self];
	NSDateComponents *components2 = [CURRENT_CALENDAR components:NSYearCalendarUnit fromDate:aDate];
	return (components1.year == components2.year);
}

@end

