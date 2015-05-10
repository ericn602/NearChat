//
//  ViewController.m
//  NearChat
//
//  Created by Eric Nguyen on 4/12/15.
//  Copyright (c) 2015 Eric Nguyen. All rights reserved.
//

#import "ViewController.h"
#import "AppDelegate.h"
#import "ChatViewController.h"
@interface ViewController () <QBChatDelegate, UITableViewDelegate, UITableViewDataSource, completedNotificationDelegate, UIAlertViewDelegate>

@property (nonatomic, strong) NSMutableArray *dialogs;
@property (nonatomic, weak) IBOutlet UITableView *dialogsTableView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view, typically from a nib.
    // Create session with user
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    appDelegate.delegate = self;
    
}
-(IBAction)addDialog:(id)sender {
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Hello!" message:@"Please enter a chat room name" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Create",nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    UITextField *alertTextField = [alert textFieldAtIndex:0];
    alertTextField.keyboardType = UIKeyboardTypeDefault;
    alertTextField.placeholder = @"chat room name";
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == [alertView cancelButtonIndex]){
        return;
    }
    QBChatDialog *chatDialog = [QBChatDialog new];
    chatDialog.name = [alertView textFieldAtIndex:0].text;
    chatDialog.type = QBChatDialogTypePublicGroup;
    [QBRequest createDialog:chatDialog successBlock:^(QBResponse *response, QBChatDialog *createdDialog) {
        [self completedNotification];
    } errorBlock:^(QBResponse *response) {
        NSLog(@"%@",response.error);
    }];
}
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    ChatViewController *controller = (ChatViewController *)segue.destinationViewController;
    
}
-(void)completedNotification {
    [QBRequest dialogsWithSuccessBlock:^(QBResponse *response, NSArray *dialogObjects, NSSet *dialogsUsersIDs) {
        self.dialogs = dialogObjects.mutableCopy;
        [_dialogsTableView reloadData];
    } errorBlock:^(QBResponse *response) {
        NSLog(@"%@", response.error);
    }];
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.dialogs count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DialogueIdentifier"];
    
    QBChatDialog *chatDialog = self.dialogs[indexPath.row];
    cell.tag  = indexPath.row;
    cell.textLabel.text = chatDialog.name;
    
   
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark -
#pragma mark QBChatDelegate
    
    // Chat delegate
- (void)chatDidLogin{
        // You have successfully signed in to QuickBlox Chat
    NSLog(@"Chat Success!");
    }
    
- (void)chatDidNotLogin{
        
    }

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
