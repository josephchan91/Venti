//
//  FeedViewController.m
//  IntegratingFacebookTutorial
//
//  Created by josephchan91 on 12/14/12.
//
//

#import "FeedViewController.h"
#import "FeedItemDetailViewController.h"
#import "Constants.h"
#import "FeedItemCell.h"

@interface FeedViewController ()

@end

@implementation FeedViewController

NSMutableArray *feedItems;
NSMutableData *imageData;
NSString *facebookId;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.tableView reloadData];
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
 
    if (nil != [[PFUser currentUser] objectForKey:kUserFacebookKey] && nil != [[PFUser currentUser] objectForKey:kUserPhotoKey]) {
        [self reloadFeed];
        return;
    }
    // If this is the first time signing up, store the facebook id in the PFUser to avoid future requests
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
                facebookId = userData[@"id"];
                NSString *name = userData[@"name"];
                
                [[PFUser currentUser] setObject:facebookId forKey:kUserFacebookKey];
                [[PFUser currentUser] setObject:name forKey:kUserNameKey];
                [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    // Get feed items
                    if (succeeded) {
                        [self getPhotoForFacebookId:facebookId];
                    } else {
                        NSLog(@"Error saving user details: %@", error);
                    }
                }];
                
            } else if ([[[[error userInfo] objectForKey:@"error"] objectForKey:@"type"]
                        isEqualToString: @"OAuthException"]) { // Since the request failed, we can check if it was due to an invalid session
                NSLog(@"The facebook session was invalidated");
                [self logoutButtonTouchHandler:nil];
            } else {
                NSLog(@"Some other erro: %@", error);
            }
        }];
    }
}

- (void)getPhotoForFacebookId:(NSString *)facebookId
{
    // Download the user's facebook profile picture
    imageData = [[NSMutableData alloc] init]; // the data will be loaded in here
    
    NSURL *pictureURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large&return_ssl_resources=1", facebookId]];
    
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:pictureURL
                                                              cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                          timeoutInterval:2.0f];
    // Run network request asynchronously
    NSURLConnection *urlConnection = [[NSURLConnection alloc] initWithRequest:urlRequest delegate:self];
    if (!urlConnection) {
        NSLog(@"Failed to download picture");
    }
}

#pragma mark - NSURLConnectionDelegate methods
/* Callback delegate methods used for downloading the user's profile picture */

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    // As chuncks of the image are received, we build our data file
    [imageData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    // All data has been downloaded, now we can set the image in the header image view
    PFFile *imageFile = [PFFile fileWithData:imageData];
    [imageFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        [[PFUser currentUser] setObject:imageFile forKey:kUserPhotoKey];
        [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
                [self reloadFeed];
            } else {
                NSLog(@"Error saving user photo: %@", error);
            }
        }];
    }];
}


- (void)reloadFeed
{
    // Get feed items
    PFQuery *query = [PFQuery queryWithClassName:kFeedItemClassKey];
    [query whereKey:kFeedItemViewerKey equalTo:[[PFUser currentUser] objectForKey:kUserFacebookKey]];
    [query orderByDescending:@"createdAt"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            // Find succeeded
            feedItems = [NSMutableArray arrayWithArray:objects];
            [self.tableView reloadData];
        } else {
            // Failure
            NSLog(@"Error :%@ %@", error, [error userInfo]);
        }
    }];
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
    return feedItems.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"FeedItemCell";
    FeedItemCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    if (cell == nil) {
        // Create the cell and add the labels
        cell = [[FeedItemCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        [cell setSelectionStyle:UITableViewCellSelectionStyleGray];
    }

    // Get feed
    PFObject *feedItem = [feedItems objectAtIndex:indexPath.row];
    PFObject *post = [feedItem objectForKey:kFeedItemPostKey];
    // Get post
    [post fetchIfNeededInBackgroundWithBlock:^(PFObject *post, NSError *error) {
        // Give cell postId
        cell.postId = post.objectId;
        NSDate *now = [NSDate date];
        NSDate *created = post.createdAt;
        NSUInteger unitFlags = NSDayCalendarUnit;
        NSCalendar* calendar = [NSCalendar currentCalendar];
        NSDateComponents *components = [calendar components:unitFlags fromDate:created toDate:now options:0];
        if ([components day] == 1) {
            cell.timeDiffLabel.text = [NSString stringWithFormat:@"%d day ago",[components day]];
        }
        else {
            cell.timeDiffLabel.text = [NSString stringWithFormat:@"%d days ago",[components day]];
        }
               // Get photo
        PFObject *photo = [post objectForKey:kPostPhotoKey];
        [photo fetchIfNeededInBackgroundWithBlock:^(PFObject *photo, NSError *error) {
            // Get user
            if (!error) {
                PFObject *user = [photo objectForKey:kPhotoOwnerKey];
                [user fetchIfNeededInBackgroundWithBlock:^(PFObject *user, NSError *error) {
                    // Show info
                    if (!error) {
                        cell.posterNameLabel.text = [user objectForKey:kUserNameKey];
                        PFFile *thumbnailFile = [user objectForKey:kUserPhotoKey];
                        [thumbnailFile getDataInBackgroundWithBlock:^(NSData *thumbnail, NSError *error) {
                            // Show thumbnail
                            if (!error) {
                                UIImage *image = [UIImage imageWithData:thumbnail];
                                [cell.posterThumbnailImageView setImage:image];
                                [cell.posterThumbnailImageView  setContentMode:UIViewContentModeScaleAspectFit];
                            }
                        }];
                    }
                }];
                // Get image
                PFFile *imageFile = [photo objectForKey:kPhotoImageKey];
                [imageFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                    // Show feed photo
                    if (!error) {
                        UIImage *image = [UIImage imageWithData:data];
                        [cell.feedPhotoImageView setImage:image];
                        [cell.feedPhotoImageView  setContentMode:UIViewContentModeScaleAspectFit];
                    }
                }];
            }
        }];
    }];
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     ; *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

#pragma mark - 
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showFeedItemDetail"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        FeedItemCell *cell = (FeedItemCell*)[self.tableView cellForRowAtIndexPath:indexPath];
        if ([[segue destinationViewController] class] == [FeedItemDetailViewController class]) {
            FeedItemDetailViewController *detail = [segue destinationViewController];
            detail.posterName = cell.posterNameLabel.text;
            detail.postTimeDiff = cell.timeDiffLabel.text;
            detail.posterThumbnail = [cell.posterThumbnailImageView image];
            detail.postImage = [cell.feedPhotoImageView image];
            detail.postId = cell.postId;
        }
    }
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
