//
//  KPTimePicker.m
//
//  Created by Kasper Pihl Tornøe on 01/08/13.
//  Copyright (c) 2013 Pihl IT. All rights reserved.
//

/*
 "HelveticaNeue-BoldItalic",
 "HelveticaNeue-Light",
 "HelveticaNeue-UltraLightItalic",
 "HelveticaNeue-CondensedBold",
 "HelveticaNeue-MediumItalic",
 "HelveticaNeue-Thin",
 "HelveticaNeue-Medium",
 "HelveticaNeue-ThinItalic",
 "HelveticaNeue-LightItalic",
 "HelveticaNeue-UltraLight",
 "HelveticaNeue-Bold",
 HelveticaNeue,
 "HelveticaNeue-CondensedBlack"
 */
#define kMinutesInDay 1440
#define kMinutesInHalfDay 720

#define kSunImageDistance valForScreen(160, 100)
#define kClockLabelFont [UIFont fontWithName:@"HelveticaNeue-Light" size:valForScreen(55,75)]
#define kDayLabelFont [UIFont fontWithName:@"HelveticaNeue-Light" size:valForScreen(16,19)]
#define kDefMiddleButtonRadius 60
#define kDefActualSize valForScreen(85,93)
#define kDefClearMiddle 45

#define kBackMargin 10

#define kOpenedSunAngle valForScreen(70,60)
#define kExtraAngleForIcons 22


#define kDefLightColor          color(69,82,104,1) //tcolor(SearchDrawerColor)
#define kDefDarkColor           color(36,40,46,1)
#define kDefConfirmColor        color(63,186,141,1)

#define kEndAngle               (360-(90-kOpenedSunAngle/2) + kExtraAngleForIcons)
#define kStartAngle             (kEndAngle- kOpenedSunAngle - 2*kExtraAngleForIcons)

#define kAngleSpan              (kEndAngle-kStartAngle)
#define kSunRiseMinutes         5*60
#define kSunSetMinutes          19*60
#define kSunSpan                (kSunSetMinutes - kSunRiseMinutes)
#define kMoonRiseMinutes        17*60
#define kMoonRiseSpan           (kMinutesInDay - kMoonRiseMinutes)
#define kMoonSetMinutes         7*60
#define kMoonSetSpan            (kMoonSetMinutes)
#define kGlowShowHack           0.4
#define kGlowMiddleShowHack     0.12
#define kBackButtonSize         52



#import <QuartzCore/QuartzCore.h>
#import "KPTimePicker.h"
#import "Categories.h"
@class KPTimePicker;


@interface KPTimePicker () <UIGestureRecognizerDelegate>

@property (nonatomic) BOOL isInConfirmButton;
@property (nonatomic) BOOL isOutOfScope;

@property (nonatomic,strong) UIImageView *timeSlider;
@property (nonatomic,strong) UIButton *confirmButton;
@property (nonatomic,strong) UIButton *backButton;
@property (nonatomic,strong) UIImageView *sunImage;
@property (nonatomic,strong) UIImageView *moonImage;
@property (nonatomic,strong) UILabel *dayLabel;
@property (nonatomic,strong) UILabel *clockLabel;

/* Private Properties*/

@property (nonatomic) CGPoint _centerPoint;
@property (nonatomic) CGPoint _lastPosition;
@property (nonatomic) CGFloat _lastChangedAngle;
@property (nonatomic) CGFloat _distanceForIcons;


@end
@implementation KPTimePicker
/*-(void)setDelegate:(NSObject<KPTimePickerDelegate> *)delegate{
    _delegate = delegate;
    [self updateForDate:self.pickingDate];
}*/
-(void)setPickingDate:(NSDate *)pickingDate{
    
    if(_pickingDate != pickingDate){
        if(pickingDate) pickingDate = [pickingDate dateToNearestMinutes:5];
        _pickingDate = pickingDate;
        [self updateForDate:pickingDate];
    }
}
-(void)setIsInConfirmButton:(BOOL)isInConfirmButton{
    if(_isInConfirmButton != isInConfirmButton){
        _isInConfirmButton = isInConfirmButton;
        if(_isInConfirmButton){
            [self performSelector:@selector(didWaitDelay) withObject:nil afterDelay:kGlowShowHack];
        }
        else [self didWaitDelay];
    }
}
-(void)setIsOutOfScope:(BOOL)isOutOfScope{
    if(_isOutOfScope != isOutOfScope){
        _isOutOfScope = isOutOfScope;
        if(isOutOfScope){
            [self performSelector:@selector(didWaitInMiddle) withObject:nil afterDelay:kGlowMiddleShowHack];
        }
    }
}
-(void)didWaitInMiddle{
    if(self.isOutOfScope){
        self.confirmButton.highlighted = YES;
    }
}
-(void)didWaitDelay{
    self.confirmButton.highlighted = self.isInConfirmButton;
}
#pragma mark Actions
-(void)pressedBackButton:(UIButton*)sender{
    [self.delegate timePicker:self selectedDate:nil];
}
-(void)pressedConfirmButton:(UIButton*)sender{
    [self.delegate timePicker:self selectedDate:self.pickingDate];
}
-(void)forwardGesture:(UIPanGestureRecognizer *)sender{
    [self panGestureRecognized:sender];
}
#define distanceBetween(p1,p2) sqrt(pow((p2.x-p1.x),2) + pow((p2.y-p1.y),2))
- (void)panGestureRecognized:(UIPanGestureRecognizer *)sender
{
    CGPoint velocity = [sender velocityInView:self];
    CGPoint location = [sender locationInView:self];
    CGFloat vel = fabsf(velocity.y)+fabsf(velocity.x);
    NSInteger minutesPerInterval = 5;
    CGFloat angleInterval = 50;
    //NSLog(@"%f",vel);
    if(vel > 1400){
        minutesPerInterval = 30;
        angleInterval = 40;
    }
    angleInterval = angleInterval*M_PI/180;
    CGFloat distanceToMiddle = distanceBetween(self._centerPoint, location);
    self.isInConfirmButton = (distanceToMiddle < kDefMiddleButtonRadius);
    self.isOutOfScope = (distanceToMiddle < kDefClearMiddle);
    if (sender.state == UIGestureRecognizerStateChanged || sender.state == UIGestureRecognizerStateBegan) {
        if(!self.isOutOfScope){
            CGPoint sliderStartPoint = self._lastPosition;
            if(CGPointEqualToPoint(self._lastPosition, CGPointZero)) sliderStartPoint = location;
            CGFloat angle = [self angleBetweenCenterPoint:self._centerPoint point1:sliderStartPoint point2:location];
            self._lastChangedAngle = self._lastChangedAngle + angle;
            self._lastPosition = location;
            NSInteger numberOfIntervals = round(self._lastChangedAngle/angleInterval);
            if(numberOfIntervals != 0){
                
                NSInteger timeAdded = minutesPerInterval*numberOfIntervals;
                NSDate *newTime = [self.pickingDate dateBySubtractingMinutes:timeAdded];
                self._lastChangedAngle = 0;
                
                if(self.minimumDate && [newTime isEarlierThanDate:self.minimumDate]) newTime = self.minimumDate;
                if(self.maximumDate && [newTime isLaterThanDate:self.maximumDate]) newTime = self.maximumDate;
                
                self.pickingDate = newTime;
            }
        }
        else{
            self._lastPosition = CGPointZero;
            self._lastChangedAngle = 0;
            
        }
    }
    if (sender.state == UIGestureRecognizerStateEnded) {
        self._lastPosition = CGPointZero;
        self._lastChangedAngle = 0;
        self.confirmButton.highlighted = NO;
        if(self.isInConfirmButton){
            [self.delegate timePicker:self selectedDate:self.pickingDate];
        }
    }
}
-(CGFloat)angleBetweenCenterPoint:(CGPoint)centerPoint point1:(CGPoint)p1 point2:(CGPoint)p2{
    CGPoint v1 = CGPointMake(p1.x - centerPoint.x, p1.y - centerPoint.y);
	CGPoint v2 = CGPointMake(p2.x - centerPoint.x, p2.y - centerPoint.y);
	
	CGFloat angle = atan2f(v2.x*v1.y - v1.x*v2.y, v1.x*v2.x + v1.y*v2.y);
	
	return angle;
}
- (CGPoint)pointFromPoint:(CGPoint)origin withDistance:(float)distance towardAngle:(float)angle
{
    double radAngle = angle * M_PI / 180.0;
    return CGPointMake(origin.x + distance * cos(radAngle), origin.y + distance * sin(radAngle));
}

-(void)updateForDate:(NSDate*)date{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setLocale:[NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"]];
    dateFormatter.dateFormat = @"HH:mm";
    NSString *dayString;
    NSString *timeString;
    if([self.delegate respondsToSelector:@selector(timePicker:titleForDate:)]) dayString = [self.delegate timePicker:self titleForDate:date];
    if(!dayString) dayString = [KPUtil dayStringForDate:date];
    if([self.delegate respondsToSelector:@selector(timePicker:clockForDate:)]) timeString = [self.delegate timePicker:self clockForDate:date];
    if(!timeString) timeString = [[dateFormatter stringFromDate:date] lowercaseString];
    self.clockLabel.text = timeString;
    self.dayLabel.text = dayString;
    self.backgroundColor = [self colorForDate:date];
    if(self.hideIcons){
        self.sunImage.hidden = YES;
        self.moonImage.hidden = YES;
        return;
    }
    BOOL hiddenSun = YES;
    CGFloat sunAngle = 0;
    NSInteger minutesOfDayPassed = [date minutesAfterDate:[date dateAtStartOfDay]];
    if(minutesOfDayPassed > kSunRiseMinutes && minutesOfDayPassed < kSunSetMinutes){
        hiddenSun = NO;
        NSInteger minutesSinceSunrise = minutesOfDayPassed - kSunRiseMinutes;
        CGFloat percentageOfSun = (CGFloat)minutesSinceSunrise / kSunSpan;
        sunAngle = percentageOfSun * kAngleSpan + kStartAngle;
    }
    self.sunImage.hidden = hiddenSun;
    
    BOOL hiddenMoon = YES;
    CGFloat moonAngle = 0;
    
    if(minutesOfDayPassed > kMoonRiseMinutes){
        hiddenMoon = NO;
        NSInteger minutesSinceMoonrise = minutesOfDayPassed - kMoonRiseMinutes;
        CGFloat percentageOfMoonRise = (CGFloat)minutesSinceMoonrise / kMoonRiseSpan;
        moonAngle = percentageOfMoonRise * (kAngleSpan/2) + (kStartAngle);
    }
    else if(minutesOfDayPassed < kMoonSetMinutes){
        hiddenMoon = NO;
        CGFloat minutesFloat = (CGFloat)minutesOfDayPassed;
        CGFloat percentageOfMoonSet = minutesFloat/(CGFloat)kMoonSetSpan;
        
        moonAngle = percentageOfMoonSet * (kAngleSpan/2) + (kStartAngle + (kAngleSpan/2));
        //NSLog(@"moonangle:%f",moonAngle);
    }
    if(!hiddenSun){
        self.sunImage.center = [self pointFromPoint:self._centerPoint withDistance:self._distanceForIcons towardAngle:sunAngle];
    }
    if(!hiddenMoon){
        self.moonImage.center = [self pointFromPoint:self._centerPoint withDistance:self._distanceForIcons towardAngle:moonAngle];
    }
    self.moonImage.hidden = hiddenMoon;
}
-(void)set_distanceForIcons:(CGFloat)distanceForIcons{
    __distanceForIcons = distanceForIcons;
    CGFloat calcMoonAngle = 360 - degrees([self angleBetweenCenterPoint:self._centerPoint point1:CGPointMake(self._centerPoint.x+100, self._centerPoint.y) point2:self.moonImage.center]);
    CGFloat calcSunAngle = 360 - degrees([self angleBetweenCenterPoint:self._centerPoint point1:CGPointMake(self._centerPoint.x+100, self._centerPoint.y) point2:self.sunImage.center]);
    self.moonImage.center = [self pointFromPoint:self._centerPoint withDistance:distanceForIcons towardAngle:calcMoonAngle];
    self.sunImage.center = [self pointFromPoint:self._centerPoint withDistance:distanceForIcons towardAngle:calcSunAngle];
}
-(UIColor *)colorForDate:(NSDate*)date{
    
    NSDate *startOfTheDay = [date dateAtStartOfDay];
    NSInteger minutesOfDayPassed = [date minutesAfterDate:startOfTheDay];
    BOOL overNoon = (minutesOfDayPassed > kMinutesInHalfDay);
    if(overNoon) minutesOfDayPassed = minutesOfDayPassed - kMinutesInHalfDay;
    CGFloat percentage = (CGFloat)minutesOfDayPassed / (CGFloat)kMinutesInHalfDay*100;
    UIColor *startColor = overNoon ? self.lightColor : self.darkColor;
    UIColor *endColor = overNoon ? self.darkColor : self.lightColor;
    return [startColor colorToColor:endColor percent:percentage];
}
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self._centerPoint = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/3*2);
        self._distanceForIcons = kSunImageDistance;
        self.lightColor = kDefLightColor;
        self.darkColor = kDefDarkColor;
        self.confirmColor = kDefConfirmColor;
        
        
        self.moonImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"schedule_image_moon-high"]];
        self.moonImage.center = [self pointFromPoint:self._centerPoint withDistance:kSunImageDistance towardAngle:235];
        [self addSubview:self.moonImage];
        
        self.sunImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"schedule_image_sun-high"]];
        self.sunImage.center = [self pointFromPoint:self._centerPoint withDistance:kSunImageDistance towardAngle:305];
        [self addSubview:self.sunImage];
        
        self.confirmButton = [SlowHighlightIcon buttonWithType:UIButtonTypeCustom];
        self.confirmButton.backgroundColor = [UIColor clearColor];
        [self.confirmButton setBackgroundImage:[self.confirmColor image] forState:UIControlStateHighlighted];
        self.confirmButton.frame = CGRectMake(0, 0, 2*kDefActualSize, 2*kDefActualSize);
        
        //self.confirmButton.layer.borderWidth = LINE_SIZE;
        //self.confirmButton.layer.borderColor = tcolor(TextColor).CGColor;
        self.confirmButton.center = self._centerPoint;
        [self.confirmButton addTarget:self action:@selector(pressedConfirmButton:) forControlEvents:UIControlEventTouchUpInside];
        //[self.confirmButton setImage:[UIImage imageNamed:@"done-selected"] forState:];
        [self.confirmButton setImage:[UIImage imageNamed:@"checkmark_icon_white"] forState:UIControlStateNormal];
        [self.confirmButton setImage:[UIImage imageNamed:@"checkmark_icon_white"] forState:UIControlStateHighlighted];
        self.confirmButton.layer.masksToBounds = YES;
        self.confirmButton.layer.cornerRadius = kDefActualSize;
        [self addSubview:self.confirmButton];
        
        self.timeSlider = [[UIImageView alloc] initWithImage:[UIImage imageNamed:valForScreen(@"picker_wheel_ip4",@"picker_wheel")]];
        self.timeSlider.center = self._centerPoint;
        [self addSubview:self.timeSlider];
        
        self.backButton = [SlowHighlightIcon buttonWithType:UIButtonTypeCustom];
        self.backButton.frame = CGRectMake(kBackMargin, self.bounds.size.height-kBackButtonSize-kBackMargin, kBackButtonSize, kBackButtonSize);
        self.backButton.autoresizingMask = (UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin);
        [self.backButton setImage:[UIImage imageNamed:@"round_backarrow_big"] forState:UIControlStateNormal];
        [self.backButton setImage:[UIImage imageNamed:@"round_backarrow_big-high"] forState:UIControlStateHighlighted];
        [self.backButton addTarget:self action:@selector(pressedBackButton:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.backButton];
        
        UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureRecognized:)];
        panGestureRecognizer.delegate = self;
        [self addGestureRecognizer:panGestureRecognizer];
        
        self.dayLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, 120)];
        self.dayLabel.backgroundColor = [UIColor clearColor];
        self.dayLabel.textColor = [UIColor whiteColor];
        self.dayLabel.font = kDayLabelFont;
        self.dayLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:self.dayLabel];

        self.clockLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, 120)];
        self.clockLabel.backgroundColor = [UIColor clearColor];
        self.clockLabel.textColor = [UIColor whiteColor]; //self.foregroundColor;
        self.clockLabel.font = kClockLabelFont;
        self.clockLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:self.clockLabel];
        [self layoutSubviews];
    }
    return self;
}
-(void)layoutSubviews{
    [super layoutSubviews];
    if(!self.pickingDate) self.pickingDate = [NSDate date];
    else [self updateForDate:self.pickingDate];
    CGFloat heightForContent = self._centerPoint.y - self.timeSlider.frame.size.height/2;
    
    CGFloat heightForDay = sizeWithFont(@"abcdefghADB",self.dayLabel.font).height;
    CGFloat heightForTime = sizeWithFont(@"08:00pm",self.clockLabel.font).height;
    CGFloat iconHeigt = self.sunImage.image.size.height;
    
    CGFloat overflowSpace = heightForContent - heightForDay - heightForTime - iconHeigt;
    CGFloat spacing = overflowSpace / 3;
    
    self.dayLabel.frame = CGRectMake(0, spacing, self.bounds.size.width, heightForDay);
    self.clockLabel.frame = CGRectMake(0, spacing+heightForDay, self.bounds.size.width, heightForTime);
    
    self._distanceForIcons = self.timeSlider.frame.size.height/2 + spacing*1.5 + iconHeigt/2;
}
-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
    return YES;
}
-(void)dealloc{
    self.confirmButton = nil;
    self.backButton = nil;
    self.timeSlider = nil;
    self.sunImage = nil;
    self.moonImage = nil;
    self.clockLabel = nil;
}

@end

