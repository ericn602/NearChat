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
#define IS_OS_8_OR_LATER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
@interface ViewController () <QBChatDelegate, UITableViewDelegate, UITableViewDataSource, completedNotificationDelegate, UIAlertViewDelegate, CLLocationManagerDelegate>

@property (nonatomic, strong) NSMutableArray *dialogs;
@property (nonatomic, weak) IBOutlet UITableView *dialogsTableView;
@property (nonatomic, strong) CLLocationManager *locManager;
@property (nonatomic) CLLocationDegrees latitude;
@property (nonatomic) CLLocationDegrees longitude;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view, typically from a nib.
    // Create session with user
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    appDelegate.delegate = self;
    self.locManager = [[CLLocationManager alloc] init];
    self.locManager.delegate = self;
    
    
}
-(IBAction)addDialog:(id)sender {
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"NearChat" message:@"Please enter a chat room name" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Create",nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    UITextField *alertTextField = [alert textFieldAtIndex:0];
    alertTextField.keyboardType = UIKeyboardTypeDefault;
    alertTextField.placeholder = @"chat room name";
    [alert show];
}

- (IBAction)refresh:(id)sender {
    [self completedNotification];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == [alertView cancelButtonIndex]){
        return;
    }
    QBChatDialog *chatDialog = [QBChatDialog new];
    chatDialog.name = [alertView textFieldAtIndex:0].text;
    chatDialog.type = QBChatDialogTypePublicGroup;
    [QBRequest createDialog:chatDialog successBlock:^(QBResponse *response, QBChatDialog *createdDialog) {
        QBLGeoData *geoData = [QBLGeoData geoData];
        geoData.status = createdDialog.ID;
        geoData.longitude = _longitude;
        geoData.latitude = _latitude;
        [QBRequest createGeoData:geoData successBlock:^(QBResponse *response, QBLGeoData *geoData) {
        } errorBlock:^(QBResponse *response) {
            NSLog(@"%@",response.error);
        }];
    } errorBlock:^(QBResponse *response) {
        NSLog(@"%@",response.error);
    }];
    [self completedNotification];
}
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    ChatViewController *controller = (ChatViewController *)segue.destinationViewController;
    controller.dialog = self.dialogs[((UITableViewCell *) sender).tag];
    
    
}
-(void)completedNotification {

    QBLGeoDataFilter *filter = [[QBLGeoDataFilter alloc] init];
    filter.radius = 16.0934;
    filter.currentPosition = CLLocationCoordinate2DMake(_latitude, _longitude);
    NSLog(@"RING%f", _latitude);
    [QBRequest geoDataWithFilter:filter page:[QBGeneralResponsePage responsePageWithCurrentPage:1 perPage:70] successBlock:^(QBResponse *response, NSArray *objects, QBGeneralResponsePage *page) {
        NSMutableArray *filt = [[NSMutableArray alloc] init];
        for (int i = 0; i < objects.count; i++) {
            [filt addObject:((QBLGeoData *)[objects objectAtIndex:i]).status];
        }
        NSMutableDictionary *extRequest = [[NSMutableDictionary alloc] init];
        [extRequest setObject:filt forKey:@"_id[in]"];
        [QBRequest dialogsForPage:[QBResponsePage responsePageWithLimit:100 skip:0] extendedRequest:extRequest successBlock:^(QBResponse *response, NSArray *dialogObjects, NSSet *dialogsUsersIDs, QBResponsePage *page) {
            self.dialogs = dialogObjects.mutableCopy;
            [_dialogsTableView reloadData];
            
        } errorBlock:^(QBResponse *response) {
            
        }];
    } errorBlock:^(QBResponse *response) {
        NSLog(@"%@", response.error);
    }];
}
-(void)loadLocation {
    if(IS_OS_8_OR_LATER){
        NSUInteger code = [CLLocationManager authorizationStatus];
        if (code == kCLAuthorizationStatusNotDetermined && ([self.locManager respondsToSelector:@selector(requestAlwaysAuthorization)] || [self.locManager respondsToSelector:@selector(requestWhenInUseAuthorization)])) {
            if([[NSBundle mainBundle] objectForInfoDictionaryKey:@"NSLocationWhenInUseUsageDescription"]) {
                [self.locManager  requestWhenInUseAuthorization];
            } else {
                NSLog(@"Info.plist does not contain NSLocationAlwaysUsageDescription or NSLocationWhenInUseUsageDescription");
            }
        }
    }
    [self.locManager startUpdatingLocation];
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
#pragma mark - CLLocationManagerDelegate
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"didFailWithError: %@", error);
    UIAlertView *errorAlert = [[UIAlertView alloc]
                               initWithTitle:@"Error" message:@"Failed to Get Your Location" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [errorAlert show];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    NSLog(@"didUpdateToLocation: %@", newLocation);
    CLLocation *currentLocation = newLocation;
    if (currentLocation != nil) {
        _latitude = currentLocation.coordinate.latitude;
        _longitude = currentLocation.coordinate.longitude;
        [self.locManager stopUpdatingLocation];
        [self completedNotification];
    }
}
@end
