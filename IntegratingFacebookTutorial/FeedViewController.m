/**
 Class for displaying a user's feed
 **/

#import "FeedViewController.h"
#import "FeedItemDetailViewController.h"
#import "Constants.h"
#import "FeedItemCell.h"

@interface FeedViewController ()

@end

@implementation FeedViewController

NSMutableArray *feedItems;  // Array of feed items to show in UITableView
NSMutableData *imageData;   // Data to store downloaded profile picture of user for thumbnails
NSString *facebookId;       // facebookId we GET the first time a user signs up

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self reloadFeed];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
 
    // Check if the user already has his facebookId recorded
    if (nil != [[PFUser currentUser] objectForKey:kUserFacebookKey]) {
        [self reloadFeed];
        return;
    }
    // If this is the first time signing up, store the facebook id in the PFUser so future GETs won't be required
    else {
        // Create request for user's facebook data
        NSString *requestPath = @"me/?fields=id,name";
        // Send request to Facebook
        PF_FBRequest *request = [PF_FBRequest requestForGraphPath:requestPath];
        [request startWithCompletionHandler:^(PF_FBRequestConnection *connection, id result, NSError *error) {
            // Handle response
            if (!error) {
                // Parse the data received
                NSDictionary *userData = (NSDictionary *)result;
                facebookId = userData[@"id"];
                NSString *name = userData[@"name"];
                
                // Save facebookId and name to the PFUser object
                [[PFUser currentUser] setObject:facebookId forKey:kUserFacebookKey];
                [[PFUser currentUser] setObject:name forKey:kUserNameKey];
                [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    // Retrieve his facebook profile picture
                    [self getPhotoForFacebookId:facebookId]; 
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

/** Requests for the user's facebook profile picture **/
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
    // All data has been downloaded, now we can save the photo file to the user object
    PFFile *imageFile = [PFFile fileWithData:imageData];
    [imageFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        [[PFUser currentUser] setObject:imageFile forKey:kUserPhotoKey];
        [[PFUser currentUser] saveEventually];
    }];
}


- (void)reloadFeed
{
    // Pull all the feed items
    PFQuery *query = [PFQuery queryWithClassName:kFeedItemClassKey];
    // Check if facebookId exists for current user
    if (nil == [[PFUser currentUser] objectForKey:kUserFacebookKey]) {
        return;
    }
    [query whereKey:kFeedItemViewerKey equalTo:[[PFUser currentUser] objectForKey:kUserFacebookKey]];
    [query orderByDescending:@"createdAt"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            // Store returned objects into feed array for UITableView
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

#pragma mark - UITableViewDataSource delegate methods

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
    
    // Configure the cell
    if (cell == nil) {
        // Create the cell
        cell = [[FeedItemCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        [cell setSelectionStyle:UITableViewCellSelectionStyleGray];
    }
    
    // Set radius
    cell.cardView.layer.cornerRadius = 2;
    
    // Get the feed item for the particular row
    PFObject *feedItem = [feedItems objectAtIndex:indexPath.row];
    PFObject *post = [feedItem objectForKey:kFeedItemPostKey];
    // Get the parent post
    [post fetchIfNeededInBackgroundWithBlock:^(PFObject *post, NSError *error) {
        // Store the postId in the cell's class
        cell.postId = post.objectId;
        NSDate *now = [NSDate date];
        NSDate *created = post.createdAt;
        NSUInteger unitFlags = NSDayCalendarUnit;
        NSCalendar* calendar = [NSCalendar currentCalendar];
        NSDateComponents *components = [calendar components:unitFlags fromDate:created toDate:now options:0];
        // Set the time difference from date of creation
        if ([components day] == 1) {
            cell.timeDiffLabel.text = [NSString stringWithFormat:@"%d day ago",[components day]];
        }
        else {
            cell.timeDiffLabel.text = [NSString stringWithFormat:@"%d days ago",[components day]];
        }
        // Get post's photo to show
        PFObject *photo = [post objectForKey:kPostPhotoKey];
        [photo fetchIfNeededInBackgroundWithBlock:^(PFObject *photo, NSError *error) {
            // Get the user who created the post
            if (!error) {
                PFObject *user = [photo objectForKey:kPhotoOwnerKey];
                [user fetchIfNeededInBackgroundWithBlock:^(PFObject *user, NSError *error) {
                    // Display the user's information
                    if (!error) {
                        cell.posterNameLabel.text = [user objectForKey:kUserNameKey];
                        PFFile *thumbnailFile = [user objectForKey:kUserPhotoKey];
                        [thumbnailFile getDataInBackgroundWithBlock:^(NSData *thumbnail, NSError *error) {
                            // Show the user's thumbnail photo
                            if (!error) {
                                UIImage *image = [UIImage imageWithData:thumbnail];
                                [cell.posterThumbnailImageView setImage:image];
                                [cell.posterThumbnailImageView  setContentMode:UIViewContentModeScaleAspectFit];
                            }
                        }];
                    }
                }];
                // Get the actual image file
                PFFile *imageFile = [photo objectForKey:kPhotoImageKey];
                [imageFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                    // Show the photo
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

#pragma mark - 
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Provide the FeedViewController all the necessary data associated with the post it is going to display
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

/** Logout button which isn't visible; we've replaced it with a refresh button **/
- (void)logoutButtonTouchHandler:(id)sender {
    // Logout user, this automatically clears the cache
    [PFUser logOut];
    
    // Return to login view controller
    [self.navigationController popToRootViewControllerAnimated:YES];
}

/** Action for user to create a new post **/
- (IBAction)createPostButtonTouchHandler:(id)sender {
    [self performSegueWithIdentifier:@"CreatePostViewControllerSegue" sender:self];
}

/** Action to reload the feed **/
- (IBAction)refreshFeedAction:(id)sender {
    [self reloadFeed];
}


@end
