//
//  FeedViewController.m
//  IntegratingFacebookTutorial
//
//  Created by josephchan91 on 12/14/12.
//
//

#import "FeedViewController.h"
#import "Constants.h"

@interface FeedViewController ()

@end

@implementation FeedViewController

NSMutableArray *feedItems;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    // Add logout navigation bar button
    UIBarButtonItem *logoutButton = [[UIBarButtonItem alloc] initWithTitle:@"Logout" style:UIBarButtonItemStyleBordered target:self action:@selector(logoutButtonTouchHandler:)];
    self.navigationItem.leftBarButtonItem = logoutButton;
 
    // If this is the first time signing up, store the facebook id in the PFUser to avoid future requests
    if (nil != [[PFUser currentUser] objectForKey:kUserFacebookKey]) {
        NSLog(@"Current user has facebookId field");
    }
    else {
        // Create request for user's facebook data
        NSString *requestPath = @"me/?fields=id,name";
        // Send request to Facebook
        PF_FBRequest *request = [PF_FBRequest requestForGraphPath:requestPath];
        [request startWithCompletionHandler:^(PF_FBRequestConnection *connection, id result, NSError *error) {
            // handle response
            if (!error) {
                // Parse the data received
                NSDictionary *userData = (NSDictionary *)result;
                NSString *facebookId = userData[@"id"];
                NSString *name = userData[@"name"];
                [[PFUser currentUser] setObject:facebookId forKey:kUserFacebookKey];
                [[PFUser currentUser] setObject:name forKey:kUserNameKey];
                [[PFUser currentUser] saveInBackground];
            } else if ([[[[error userInfo] objectForKey:@"error"] objectForKey:@"type"]
                        isEqualToString: @"OAuthException"]) { // Since the request failed, we can check if it was due to an invalid session
                NSLog(@"The facebook session was invalidated");
                [self logoutButtonTouchHandler:nil];
            } else {
                NSLog(@"Some other error: %@", error);
            }
        }];
    }
    
    // Get feed items
    PFQuery *query = [PFQuery queryWithClassName:kFeedItemClassKey];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return _rowDataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"FeedCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    if (cell == nil) {
        // Create the cell and add the labels
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Show feed data
     
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

- (void)logoutButtonTouchHandler:(id)sender {
    // Logout user, this automatically clears the cache
    [PFUser logOut];
    
    // Return to login view controller
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (IBAction)createPostButtonTouchHandler:(id)sender {
    [self performSegueWithIdentifier:@"CreatePostViewControllerSegue" sender:self];
}


@end
