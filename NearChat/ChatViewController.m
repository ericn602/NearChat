//
//  ChatViewController.m
//  NearChat
//
//  Created by Eric Nguyen on 4/21/15.
//  Copyright (c) 2015 Eric Nguyen. All rights reserved.
//

#import "ChatViewController.h"

@interface ChatViewController () <UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *keyboardHeight;
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UITableView *messageTable;
@property (strong, nonatomic) NSMutableArray *messages;
@property (nonatomic, strong) QBChatRoom *chatRoom;
@end

@implementation ChatViewController
- (void)viewDidLoad
{
    [super viewDidLoad];
    _messages = [[NSMutableArray alloc] init];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillChangeFrameNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    [[QBChat instance] addDelegate:self];
    self.chatRoom = [self.dialog chatRoom];
    self.title = self.dialog.name;
    [self.chatRoom joinRoomWithHistoryAttribute:@{@"maxstanzas": @"0"}];
}

- (IBAction)sendMessage:(id)sender {
    QBChatMessage *message = [QBChatMessage message];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"save_to_history"] = @YES;
    [message setCustomParameters:params];
    if (self.textField.text.length == 0) {
        return;
    }
    message.text = self.textField.text;
    
    [[QBChat instance] sendChatMessage:message toRoom:self.chatRoom];
    self.textField.text = @"";
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.messages count];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ChatMessage"];
    cell.tag  = indexPath.row;
    cell.textLabel.text =((QBChatMessage *) _messages[indexPath.row]).text;
    
    
    return cell;
}

- (void)keyboardWillShow:(NSNotification *)notification
{
    NSDictionary *info = [notification userInfo];
    NSValue *kbFrame = [info objectForKey:UIKeyboardFrameEndUserInfoKey];
    NSTimeInterval animationDuration = [[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    CGRect keyboardFrame = [kbFrame CGRectValue];
    
    self.keyboardHeight.constant = keyboardFrame.size.height;
    
    [UIView animateWithDuration:animationDuration animations:^{
        [self.view layoutIfNeeded];
    }];
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    NSDictionary *info = [notification userInfo];
    NSTimeInterval animationDuration = [[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    self.keyboardHeight.constant = 20;
    [UIView animateWithDuration:animationDuration animations:^{
        [self.view layoutIfNeeded];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)chatRoomDidEnter:(QBChatRoom *)room{
    NSLog(@"Chat Room Joined");
}
- (void)chatRoomDidReceiveMessage:(QBChatMessage *)message fromRoomJID:(NSString *)roomJID{
    [_messages addObject:message];
    [_messageTable reloadData];
    [_messageTable scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:(_messages.count - 1) inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}

- (void)chatDidNotSendMessage:(QBChatMessage *)message toRoomJid:(NSString *)roomJid error:(NSError *)error
{
    
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
