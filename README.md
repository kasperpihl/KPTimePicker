KPTimePicker
--------------------
<p align="left"><img src="https://raw.github.com/kasperpihl/KPTimePicker/master/github-assets/kptimepickerscreenshot.png"/></p>

Bringing back the iPod wheel to adjust time in a more delicate manner.
This is an open-source version of the TimePicker used in [Swipes](http://swipesapp.com) iOS app.

## Usage
Include KPTimePicker folder to your project
```objc
#import "KPTimePicker.h"
KPTimePicker *timePicker = [[KPTimePicker alloc] init];
timePicker.delegate = self;
[view addSubview:timePicker];
```

## Demo
<p align="left"><img src="https://raw.github.com/kasperpihl/KPTimePicker/master/github-assets/kptimepickerdemo.gif"/></p>

### Delegate

KPTimePicker has a delegate to get the selected date.

```objc
@interface ViewController () <KPTimePickerDelegate>
```

```objc
#pragma mark - KPTimePickerDelegate

// Returns selected date -- date is nil if back is pressed
-(void)timePicker:(KPTimePicker*)timePicker selectedDate:(NSDate *)date;

@optional
// Get's called every time the date changes - used for customizing the labels
-(NSString*)timePicker:(KPTimePicker*)timePicker titleForDate:(NSDate *)time;
-(NSString*)timePicker:(KPTimePicker*)timePicker clockForDate:(NSDate *)time;

```

## Requirements
- iOS >= 5.0 (iOS 7 compatible)
- ARC

## Contact
Pull-request and feedback is highly appreciated :-)
Kasper Pihl Tornøe
- http://twitter.com/tornoe