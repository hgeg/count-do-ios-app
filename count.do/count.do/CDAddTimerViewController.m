//
//  CDAddTimerViewController.m
//  count.do
//
//  Created by Ali Can Bülbül on 6/6/13.
//  Copyright (c) 2013 Can Bülbül. All rights reserved.
//

#import "CDAddTimerViewController.h"
#import "NSDate+Reporting.h"
#import <stdlib.h>
#define dayNums @{@"Sunday":@0,@"Monday":@1,@"Tuesday":@2,@"Wednesday":@3,@"Thursday":@4,@"Friday":@5,@"Saturday":@6}

@interface CDAddTimerViewController ()

@end

@implementation CDAddTimerViewController
@synthesize monthLabel;
@synthesize yearLabel;
@synthesize hourLabel;
@synthesize minLabel;

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    if([[NSUserDefaults standardUserDefaults] boolForKey:@"editing"]) {
        [self editReminder];
    }else {
        [self newReminder];
    }
    //Add Gesture recognizers
    //Month Selection
    UISwipeGestureRecognizer *rgr = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(nextMonth:)];
    rgr.direction = UISwipeGestureRecognizerDirectionRight;
    UISwipeGestureRecognizer *lgr = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(previousMonth:)];
    lgr.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.monthDetector addGestureRecognizer:rgr];
    [self.monthDetector addGestureRecognizer:lgr];
    
    //Hour selection
    UISwipeGestureRecognizer *uhgr = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(nextHour:)];
    uhgr.direction = UISwipeGestureRecognizerDirectionUp;
    UISwipeGestureRecognizer *dhgr = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(previousHour:)];
    dhgr.direction = UISwipeGestureRecognizerDirectionDown;
    [self.hourDetector addGestureRecognizer:uhgr];
    [self.hourDetector addGestureRecognizer:dhgr];
    
    UISwipeGestureRecognizer *umgr = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(nextMin:)];
    umgr.direction = UISwipeGestureRecognizerDirectionUp;
    UISwipeGestureRecognizer *dmgr = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(previousMin:)];
    dmgr.direction = UISwipeGestureRecognizerDirectionDown;
    [self.minDetector addGestureRecognizer:umgr];
    [self.minDetector addGestureRecognizer:dmgr];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if([selectedTheme isEqualToString:@"red"]) {
        self.view.backgroundColor = white;
        self.shield.backgroundColor = white;
    }else{
        self.view.backgroundColor = colors[selectedTheme][@"background"];
        self.shield.backgroundColor = colors[selectedTheme][@"background"];
    }
    self.topView.backgroundColor = colors[selectedTheme][@"topcolor"];
    self.bottomView.backgroundColor = colors[selectedTheme][@"bottomcolor"];
    for (UIView *v in self.dayTitleView.subviews) {
        if([v respondsToSelector:@selector(setTextColor:)]) {
            [((UILabel *)v) setTextColor:colors[selectedTheme][@"titlecolor"]];
        }
    }
    self.titleInput.textColor = colors[selectedTheme][@"textcolor"];
    [self.slider setThumbImage:[UIImage imageNamed:[NSString stringWithFormat:@"Knob_%@.png",selectedTheme]] forState:UIControlStateNormal];
    [self.slider setMinimumTrackTintColor:colors[selectedTheme][@"bottomcolor"]];
    
}

- (void) newReminder {
    
    sliderVal = 0;
    if(!boughtReminder || [reminderType isEqualToString:@"basic"]) self.slider.enabled = false;
    NSDate *current = [NSDate date];
    NSCalendar *cal = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    date = [cal components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit| NSHourCalendarUnit | NSMinuteCalendarUnit) fromDate:current];
    date.minute+=5;
    UITapGestureRecognizer *shieldToggle = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(endEdits)];
    [self.shield addGestureRecognizer:shieldToggle];
    [self redrawDateValues];
    double delayInSeconds = 0.5;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self.titleInput becomeFirstResponder];
    });
}

- (void) editReminder {
    if(!boughtReminder || [reminderType isEqualToString:@"basic"]) self.slider.enabled = false;
    self.titleInput.text = [[NSUserDefaults standardUserDefaults] objectForKey:@"edit"][@"title"];
    NSDate *current = [NSDate dateWithTimeIntervalSince1970:[[[NSUserDefaults standardUserDefaults] objectForKey:@"edit"][@"timestamp"] integerValue]];
    NSCalendar *cal = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    date = [cal components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit| NSHourCalendarUnit | NSMinuteCalendarUnit) fromDate:current];
    date.minute+=5;
    self.slider.value = [[[NSUserDefaults standardUserDefaults] objectForKey:@"edit"][@"offset"] floatValue];
    UISlider *sender = self.slider;
    if(sender.value==0) {
        self.reminderLabel.text = @"Remind me at exact time";
        sliderVal = 0;
    }else if(sender.value<=0.1) {
        self.reminderLabel.text = @"Remind me 10 minutes earlier";
        sliderVal = 600;
    }else if(sender.value<=0.3) {
        self.reminderLabel.text = @"Remind me 30 minutes earlier";
        sliderVal = 1800;
    }else if(sender.value<=0.5) {
        self.reminderLabel.text = @"Remind me 1 hour earlier";
        sliderVal = 3600;
    }else if(sender.value<=0.7) {
        self.reminderLabel.text = @"Remind me 6 hours earlier";
        sliderVal = 21600;
    }else if(sender.value<=0.9) {
        self.reminderLabel.text = @"Remind me 12 hours earlier";
        sliderVal = 43200;
    }else {
        self.reminderLabel.text = @"Remind me one day earlier";
        sliderVal = 86400;
    }
    UITapGestureRecognizer *shieldToggle = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(endEdits)];
    [self.shield addGestureRecognizer:shieldToggle];
    [self redrawDateValues];
    [self textFieldDidChange:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)goBack:(id)sender {
    self.titleInput.text = @" ";
    [self endEdits];
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)saveReminder:(id)sender {
    
    if([[NSUserDefaults standardUserDefaults] boolForKey:@"editing"]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"editingEnd" object:nil];
    }
    
    NSCalendar *cal = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat: @"dd/MM/yyyy HH:mm:ss"];
    date.second = arc4random_uniform(5);
    NSDateComponents *offset = [[NSDateComponents alloc] init];
    [offset setSecond:-sliderVal];
    NSDate *selected = [cal dateFromComponents:date];
    NSDate *timed = [cal dateFromComponents:date];
    timed = [cal dateByAddingComponents:offset toDate:selected options:0];
    NSMutableArray *reminders = [NSMutableArray arrayWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:@"reminders"]];
    
    NSNumber *timestamp = @([selected timeIntervalSince1970]);
    
    //Set an alarm
    UILocalNotification *localNotif = [[UILocalNotification alloc] init];
    if (localNotif != nil){
        // Notification details
        localNotif.fireDate = timed;
        localNotif.timeZone = [NSTimeZone defaultTimeZone];
        localNotif.alertBody = [NSString stringWithFormat:@"Countdown finished: %@",self.titleInput.text];
        localNotif.alertAction = @"Dismiss";
        localNotif.soundName = @"sound.m4r";
        localNotif.applicationIconBadgeNumber = 1;
        localNotif.userInfo = @{@"uid":timestamp};
        // Schedule the notification
        [[UIApplication sharedApplication] scheduleLocalNotification:localNotif];
    };
    [reminders addObject:@{@"title":self.titleInput.text,@"date":[formatter stringFromDate:selected], @"timestamp":timestamp,@"offset":[NSNumber numberWithFloat:self.slider.value],@"alarm":@"1",@"priority":@0}];
    NSSortDescriptor * sort = [[NSSortDescriptor alloc] initWithKey:@"timestamp" ascending:true];
    NSArray *sorted = [reminders sortedArrayUsingDescriptors:[NSArray arrayWithObject:sort]];
    sort = [[NSSortDescriptor alloc] initWithKey:@"priority" ascending:false];
    sorted = [sorted sortedArrayUsingDescriptors:[NSArray arrayWithObject:sort]];
    [[NSUserDefaults standardUserDefaults] setObject:sorted forKey:@"reminders"];
    [[NSUserDefaults standardUserDefaults] setObject:[sorted lastObject][@"date"] forKey:@"init"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark -
#pragma mark Date Selector Methods

- (void) redrawDateValues {
    yearLabel.text = [NSString stringWithFormat:@"%d",date.year];
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"US"]];
    monthLabel.text = [[[df monthSymbols] objectAtIndex:(date.month-1)] uppercaseString];
    NSDateFormatter *weekday = [[NSDateFormatter alloc] init];
    [weekday setDateFormat: @"EEEE"];
    [weekday setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"US"]];
    NSCalendar *cal = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDate *selected = [cal dateFromComponents:date];
    
    days = [NSMutableArray arrayWithCapacity:42];
    for (int t=0; t<42; t++) days[t] = @"*";
    
    NSDate *first = [NSDate firstDayOfMonthFromDate:selected];
    NSDate *last  = [NSDate lastDayOfMonthFromDate:[NSDate firstDayOfPreviousMonthFromDate:selected]];
    
    int day = [cal rangeOfUnit:NSDayCalendarUnit
                       inUnit:NSMonthCalendarUnit
                      forDate:selected].length;
    
    int dayLast = [cal rangeOfUnit:NSDayCalendarUnit
                        inUnit:NSMonthCalendarUnit
                       forDate:last].length;

    for (i=0; i<[dayNums[[weekday stringFromDate:first]] intValue]; i++) {
        days[i] = [NSString stringWithFormat:@"%d",dayLast + (i+1) - [dayNums[[weekday stringFromDate:first]] intValue]];
    }
    for (j=0; j<day; j++) {
        days[j+i] = [NSString stringWithFormat:@"%d",j+1];
    }
    for (k=0; k<(7-(i+j)%7); k++) {
        days[i+j+k] = [NSString stringWithFormat:@"%d",k+1];
    }
    [self.calendar reloadData];
    date.minute = (date.minute-date.minute%5)%60;
    int hOffset = 0;
    NSLog(@"clock: %@, %d",clockType, [(NSString *)clockType isEqualToString:@"12"]);
    if([(NSString *)clockType isEqualToString:@"12"]){
        self.ampmIndicator.hidden = false;
        if (date.hour>12) {
            hOffset = 12;
            self.ampmIndicator.text = @"PM";
        }else {
            self.ampmIndicator.text = @"AM";
        }
        if (date.hour==12) self.ampmIndicator.text = @"PM";
    }else {
        self.ampmIndicator.hidden = true;
    }
    
    hourLabel.text = [NSString stringWithFormat:@"%02d",date.hour-hOffset];
    minLabel.text = [NSString stringWithFormat:@"%02d",(date.minute)];
    
    [UIView animateWithDuration:0.2 animations:^{
        self.monthLabel.alpha = 1;
        self.calendar.alpha   = 1;
        self.hourLabel.alpha  = 1;
        self.minLabel.alpha   = 1;
    }];
    [UIView animateWithDuration:0.4 animations:^{
        self.yearLabel.alpha=1;
    }];
    
}

- (IBAction)nextMonth:(id)sender {
    date.day = 1;
    [UIView animateWithDuration:0.2 animations:^{
        self.monthLabel.alpha=0.2;
        self.calendar.alpha = 0.5;
    }];
    if(date.month<12) date.month++;
    else {
        date.month=1;
        date.year++;
        [UIView animateWithDuration:0.4 animations:^{
            self.yearLabel.alpha=0.2;
        }];
    }
    [self redrawDateValues];
}
- (IBAction)previousMonth:(id)sender {
    date.day = 1;
    [UIView animateWithDuration:0.2 animations:^{
        self.monthLabel.alpha=0.2;
        self.calendar.alpha=0.5;
    }];
    if(date.month>1) date.month--;
    else {
        date.month=12;
        date.year--;
        [UIView animateWithDuration:0.4 animations:^{
            self.yearLabel.alpha=0.2;
        }];
    }
    [self redrawDateValues];
}

- (IBAction)nextHour:(id)sender{
    [UIView animateWithDuration:0.2 animations:^{
        self.hourLabel.alpha=0.1;
    }];
    if(date.hour<23) date.hour++;
    else {
        date.hour=0;
    }
    [self redrawDateValues];
}
- (IBAction)previousHour:(id)sender{
    [UIView animateWithDuration:0.2 animations:^{
        self.hourLabel.alpha=0.1;
    }];
    if(date.hour>0) date.hour--;
    else {
        date.hour = 23;
    }
    [self redrawDateValues];
}

- (IBAction)nextMin:(id)sender{
    [UIView animateWithDuration:0.2 animations:^{
        self.minLabel.alpha=0.1;
    }];
    if(date.minute<55) date.minute+=5;
    else {
        date.minute=0;
    }
    date.minute-=date.minute%5;
    [self redrawDateValues];
}
- (IBAction)previousMin:(id)sender{
    [UIView animateWithDuration:0.2 animations:^{
        self.minLabel.alpha=0.1;
    }];
    if(date.minute>0) date.minute-=5;
    else {
        date.minute=55;
    }
    date.minute-=date.minute%5;
    [self redrawDateValues];
}

#pragma mark -
#pragma mark Collection View Delegate Methods

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView*)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView*)collectionView numberOfItemsInSection:(NSInteger)section {
    if(i+j<29) return 28;
    if(i+j>35) return 42;
    else return 35;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row>=i && indexPath.row<i+j) {
        date.day = indexPath.row-i+1;
        [self redrawDateValues];
        [self.calendar reloadData];
    }
}


#pragma mark -
#pragma mark Collection View Data Source Methods

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    UICollectionViewCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"day"
                                                                  forIndexPath:indexPath];
    ((UILabel *)[cell viewWithTag:1]).text = days[indexPath.row];
    if (indexPath.row<i) {
        ((UILabel *)[cell viewWithTag:1]).textColor = [UIColor lightGrayColor];
    } else if (indexPath.row>=i+j) {
        ((UILabel *)[cell viewWithTag:1]).textColor = [UIColor lightGrayColor];
    } else {
        ((UILabel *)[cell viewWithTag:1]).textColor = colors[selectedTheme][@"textcolor"];
    }
    if (indexPath.row-i+1==date.day) {
        cell.backgroundColor = [UIColor colorWithRed:230/255.0 green:97/255.0 blue:97/255.0 alpha:1];
        ((UILabel *)[cell viewWithTag:1]).font = [UIFont fontWithName:@"Helvetica-Bold" size:15];
        ((UILabel *)[cell viewWithTag:1]).textColor = [UIColor whiteColor];
    }else{
        cell.backgroundColor = [UIColor clearColor];
        ((UILabel *)[cell viewWithTag:1]).font = [UIFont fontWithName:@"Helvetica-Light" size:15];
    }
    
    return cell;
}

#pragma mark -
#pragma mark Text Field Delegate Methods

- (void) textFieldDidBeginEditing:(UITextField *)textField {
    self.shield.alpha=0;
    [self.view bringSubviewToFront:self.shield];
    if (self.titleInput.text.length==0) {
        self.backButton.hidden = false;
        self.backButton.alpha = 1;
    }
    [UIView animateWithDuration:0.3 animations:^{
        self.shield.alpha=0.7;
    }];
}

- (BOOL) textFieldShouldEndEditing:(UITextField *)textField {
    if (self.titleInput.text.length>0) {
        return YES;
    }else return NO;
}

- (BOOL)textFieldShouldReturn:(UITextField *)theTextField {
    [theTextField resignFirstResponder];
    if (self.titleInput.text.length>0) {
        return YES;
    }else return NO;
}

- (IBAction)textFieldDidChange:(id)sender{
    if (self.titleInput.text.length==0) {
        self.backButton.hidden  = false;
        self.placeholder.hidden = false;
    }else {
        self.backButton.hidden  = true;
        self.backButton.alpha = 1;
        self.placeholder.hidden = true;
    }
    if (self.titleInput.text.length>=24) {
        self.titleInput.text = [self.titleInput.text substringToIndex:24];
    }
}

- (void) textFieldDidEndEditing:(UITextField *)textField {
    [UIView animateWithDuration:0.3 animations:^{
        self.shield.alpha = 0;
        self.backButton.alpha = 0;
    } completion:^(BOOL finished) {
        [self.view sendSubviewToBack:self.shield];
        self.backButton.hidden = true;
    }];
}

- (IBAction) textFieldDoneEditing:(id)sender {
    [sender resignFirstResponder];
}

- (void)endEdits {
    if (self.titleInput.text.length>0) {
        [self.titleInput resignFirstResponder];
    }
}

- (IBAction)sliderChanged:(UISlider *)sender {
    if(sender.value==0) {
        self.reminderLabel.text = @"Remind me at exact time";
        sliderVal = 0;
    }else if(sender.value<=0.1) {
        self.reminderLabel.text = @"Remind me 10 minutes earlier";
        sliderVal = 600;
    }else if(sender.value<=0.3) {
        self.reminderLabel.text = @"Remind me 30 minutes earlier";
        sliderVal = 1800;
    }else if(sender.value<=0.5) {
        self.reminderLabel.text = @"Remind me 1 hour earlier";
        sliderVal = 3600;
    }else if(sender.value<=0.7) {
        self.reminderLabel.text = @"Remind me 6 hours earlier";
        sliderVal = 21600;
    }else if(sender.value<=0.9) {
        self.reminderLabel.text = @"Remind me 12 hours earlier";
        sliderVal = 43200;
    }else {
        self.reminderLabel.text = @"Remind me one day earlier";
        sliderVal = 86400;
    }
}

@end
