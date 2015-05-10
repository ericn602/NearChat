//
//  AppDelegate.h
//  NearChat
//
//  Created by Eric Nguyen on 4/12/15.
//  Copyright (c) 2015 Eric Nguyen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Quickblox/Quickblox.h"

@protocol completedNotificationDelegate <NSObject>

-(void)loadLocation;

@end
@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong,nonatomic) id<completedNotificationDelegate> delegate;

@end

