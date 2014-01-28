//
//  ViewController.m
//  YSHelperExample
//
//  Created by Yu Sugawara on 2013/12/31.
//  Copyright (c) 2013年 Yu Sugawara. All rights reserved.
//

#import "ViewController.h"
#import "YSHelper.h"

#define YESorNOString(yesNo) yesNo ? @"YES" : @"NO"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UITextView *textView;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self refresh];
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAll;
}

- (IBAction)refreshButtonDidPush:(id)sender
{
    [self refresh];
}

- (void)refresh
{
    self.textView.text = [NSString stringWithFormat:@"\
isPhone = %@\n\
isPad = %@\n\
deviceTypeStr = %@\n\
isRetina = %@\n\
is568h = %@\n\
isOrientationPortrait = %@\n\
isOrientationLandscape = %@\n\
isJapaneseLanguage = %@\n\
currentLanguage = %@\n\
currentISOCountryCode = %@\n\
appDisplayName = %@\n\
deviceName = %@\n\
hasAirDrop = %@\n\
isJailbroken = %@",
                          YESorNOString([YSHelper isPhone]),
                          YESorNOString([YSHelper isPad]),
                          [YSHelper deviceTypeStr],
                          YESorNOString([YSHelper isRetina]),
                          YESorNOString([YSHelper is568h]),
                          YESorNOString([YSHelper isOrientationPortrait]),
                          YESorNOString([YSHelper isOrientationLandscape]),
                          YESorNOString([YSHelper isJapaneseLanguage]),
                          [YSHelper currentLanguage],
                          [YSHelper currentISOCountryCode],
                          [YSHelper appDisplayName],
                          [YSHelper deviceName],
                          YESorNOString([YSHelper hasAirDrop]),
                          YESorNOString([YSHelper isJailbroken])];
}

@end
