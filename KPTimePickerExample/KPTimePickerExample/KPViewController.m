//
//  KPViewController.m
//  KPTimePickerExample
//
//  Created by Kasper Pihl Tornøe on 15/11/13.
//  Copyright (c) 2013 Pihl IT. All rights reserved.
//

#import "KPViewController.h"
#import "KPTimePicker.h"
#import "Categories.h"
@interface KPViewController () <KPTimePickerDelegate, UIGestureRecognizerDelegate>
@property (nonatomic,strong) KPTimePicker *timePicker;
@property (nonatomic,weak) IBOutlet UIButton *setTimeButton;
@property (nonatomic,weak) IBOutlet UILabel *statusLabel;
@property (nonatomic,strong) UILongPressGestureRecognizer *longPressGestureRecognizer;
@property (nonatomic,strong) UIPanGestureRecognizer *panRecognizer;
@end

@implementation KPViewController
-(void)timePicker:(KPTimePicker *)timePicker selectedDate:(NSDate *)date{
    [self show:NO timePickerAnimated:YES];
    
    if(date){
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setLocale:[NSLocale currentLocale]];
        [dateFormatter setDateStyle:NSDateFormatterNoStyle];
        [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
        self.statusLabel.text = [[dateFormatter stringFromDate:date] lowercaseString];;
    }
}

-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
    if([otherGestureRecognizer isEqual:self.panRecognizer] && !self.timePicker) return NO;
    return YES;
}
-(void)longPressRecognized:(UILongPressGestureRecognizer*)sender{
    if(sender.state == UIGestureRecognizerStateBegan){
        [self show:YES timePickerAnimated:YES];
    }
}
-(void)show:(BOOL)show timePickerAnimated:(BOOL)animated{
    if(show){
        self.timePicker.pickingDate = [NSDate date];
        [self.view addSubview:self.timePicker];
    }
    else{
        [self.timePicker removeFromSuperview];
    }
}
-(void)panRecognized:(UIPanGestureRecognizer*)sender{
    if(!self.timePicker) return;
    [self.timePicker forwardGesture:sender];
}
-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    if ([self respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)]){
        [self setNeedsStatusBarAppearanceUpdate];
    }
    self.view.backgroundColor = color(36,40,46,1);
    
    self.setTimeButton.layer.cornerRadius = 10;
    self.setTimeButton.layer.borderColor = [UIColor whiteColor].CGColor;
    self.setTimeButton.layer.borderWidth = 2;
    
    self.timePicker = [[KPTimePicker alloc] initWithFrame:self.view.bounds];
    self.timePicker.delegate = self;
    self.timePicker.minimumDate = [self.timePicker.pickingDate dateAtStartOfDay];
    self.timePicker.maximumDate = [[[self.timePicker.pickingDate dateByAddingMinutes:(60*24)] dateAtStartOfDay] dateBySubtractingMinutes:5];
    
    self.longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressRecognized:)];
    self.longPressGestureRecognizer.allowableMovement = 44.0f;
    self.longPressGestureRecognizer.delegate = self;
    self.longPressGestureRecognizer.minimumPressDuration = 0.6f;
    [self.setTimeButton addGestureRecognizer:self.longPressGestureRecognizer];
    self.panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panRecognized:)];
    [self.view addGestureRecognizer:self.panRecognizer];
	// Do any additional setup after loading the view, typically from a nib.
}

- (IBAction)pressedTimeButton:(id)sender {
    [self show:YES timePickerAnimated:YES];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)dealloc{
    self.timePicker = nil;
}
@end
