//
//  ChatViewController.h
//  NearChat
//
//  Created by Eric Nguyen on 4/21/15.
//  Copyright (c) 2015 Eric Nguyen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ViewController.h"

@interface ChatViewController : UIViewController
@property (nonatomic, strong) QBChatDialog *dialog;
@end
