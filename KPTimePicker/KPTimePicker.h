//
//  KPTimePicker.h
//
//  Created by Kasper Pihl Tornøe on 01/08/13.
//  Copyright (c) 2013 Pihl IT. All rights reserved.
//

#import <UIKit/UIKit.h>
@class KPTimePicker;
@protocol KPTimePickerDelegate
/* Returns selected date -- date is nil if back is pressed */
-(void)timePicker:(KPTimePicker*)timePicker selectedDate:(NSDate *)date;
@optional
/* Get's called every time the date changes - used for customizing the labels */
-(NSString*)timePicker:(KPTimePicker*)timePicker titleForDate:(NSDate *)time;
-(NSString*)timePicker:(KPTimePicker*)timePicker clockForDate:(NSDate *)time;
@end


@interface KPTimePicker : UIView

@property (nonatomic,weak) NSObject<KPTimePickerDelegate> *delegate;

@property (nonatomic,strong) NSDate *pickingDate;
@property (nonatomic,strong) NSDate *minimumDate;
@property (nonatomic,strong) NSDate *maximumDate;

@property (nonatomic) UIColor *lightColor;
@property (nonatomic) UIColor *darkColor;
@property (nonatomic) UIColor *confirmColor;

@property (nonatomic) BOOL hideIcons;

-(void)forwardGesture:(UIPanGestureRecognizer*)sender;
@end
