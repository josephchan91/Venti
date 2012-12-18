/**
 Class for displaying a post
 **/

#import "Constants.h"
#import "FeedItemDetailViewController.h"
#import "CommentCell.h"
#define kOFFSET_FOR_KEYBOARD 216.0

@interface FeedItemDetailViewController ()

@end

@implementation FeedItemDetailViewController

NSArray *comments;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
 
- (void)configureView
{
    // Set up header view
    self.posterNameLabel.text = self.posterName;
    self.postTimeDiffLabel.text = self.postTimeDiff;
    [self.posterThumbnailImageView setImage:self.posterThumbnail];
    [self.postPhotoImageView setImage:self.postImage];
    [self.posterThumbnailImageView setContentMode:UIViewContentModeScaleAspectFit];
    [self.postPhotoImageView setContentMode:UIViewContentModeScaleAspectFit];
    
    // Set up card view
    self.cardView.layer.cornerRadius = 2;
    
    // Set up container of comment text field
    self.commentView.backgroundColor = [UIColor colorWithRed:24.0/255.0 green:167.0/255.0 blue:181.0/255.0 alpha:1.0];
    
    // set up text field delegate
    self.commentTextField.delegate = self;
    
    // Reload all comments
    [self refreshComments];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [self configureView];
}

/** Retrieves all comments for the post and refreshes the view **/
- (void)refreshComments
{
    PFQuery *query = [PFQuery queryWithClassName:kCommentClassKey];
    [query whereKey:kCommentPostKey equalTo:self.postId];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        // Add returned comment objects to array
        comments = objects;
        [self.commentsTableView reloadData];
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setPosterThumbnail:nil];
    [self setPostImage:nil];
    [self setPosterName:nil];
    [self setPostTimeDiff:nil];
    [self setCommentTextField:nil];
    [self setCommentView:nil];
    [self setCommentsTableView:nil];
    [self setFeedDetailScrollView:nil];
    [self setPosterThumbnailImageView:nil];
    [self setPosterNameLabel:nil];
    [self setPostTimeDiffLabel:nil];
    [self setPostPhotoImageView:nil];
    [self setCardView:nil];
    [super viewDidUnload];
}

- (void)shiftTextFieldDown
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3]; // if you want to slide up the view
    CGRect commentViewRect = self.commentView.frame;
    commentViewRect.origin.y += kOFFSET_FOR_KEYBOARD;
    self.commentView.frame = commentViewRect;
    [UIView commitAnimations];
}

- (IBAction)postCommentButtonAction:(id)sender {
    if ([self.commentTextField.text length] == 0) return;
    
    // Create the comment object and save
    PFObject *comment = [PFObject objectWithClassName:kCommentClassKey];
    [comment setObject:self.postId forKey:kCommentPostKey];
    [comment setObject:[PFUser currentUser] forKey:kCommentCommenterKey];
    [comment setObject:self.commentTextField.text forKey:kCommentContentKey];
    [comment saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            // Comment saved, reload the view
            [self refreshComments];
        }
        else {
            NSLog(@"Error saving comment: %@", error);
        }
    }];
    
    [self shiftTextFieldDown];
    self.commentTextField.text = @"";
    [self.commentTextField resignFirstResponder];
}

#pragma mark - UITextFieldDelegate methods
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    // Animate the text field container to slide up to above the appearing keyboard
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
    CGRect commentViewRect = self.commentView.frame;
    commentViewRect.origin.y -= kOFFSET_FOR_KEYBOARD;
    self.commentView.frame = commentViewRect;
    [UIView commitAnimations];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    // slide the text field container back down
    [self shiftTextFieldDown];
    [self.commentTextField resignFirstResponder];
    return YES;
}


#pragma mark - UITableViewDataSourceDelegate methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [comments count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"CommentCell";
    CommentCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell
    if (cell == nil) {
        // Create the cell
        cell = [[CommentCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        [cell setSelectionStyle:UITableViewCellSelectionStyleGray];
    }
    
    // Find the corresponding comment for the given cell row
    PFObject *comment = [comments objectAtIndex:indexPath.row];
    cell.commentContentLabel.text = [comment objectForKey:kCommentContentKey];
    NSDate *now = [NSDate date];
    NSDate *created = comment.createdAt;
    NSUInteger unitFlags = NSDayCalendarUnit;
    NSCalendar* calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:unitFlags fromDate:created toDate:now options:0];
    if ([components day] == 1) {
        cell.commentTimeDiffLabel.text = [NSString stringWithFormat:@"%d day ago",[components day]];
    }
    else {
        cell.commentTimeDiffLabel.text = [NSString stringWithFormat:@"%d days ago",[components day]];
    }
    
    // Get the user who made the comment
    PFUser *commenter = [comment objectForKey:kCommentCommenterKey];
    [commenter fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        if (!error) {
            // Show the user's information
            cell.commenterNameLabel.text = [object objectForKey:kUserNameKey];
            PFFile *photo = [object objectForKey:kUserPhotoKey];
            [photo getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                // Show the user's thumbnail photo
                if(!error) {
                    UIImage *image = [UIImage imageWithData:data];
                    [cell.commenterThumbnailImageView setImage:image];
                    [cell.commenterThumbnailImageView setContentMode:UIViewContentModeScaleAspectFit];
                }
            }];
        }
    }];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 85.0;
}

@end
