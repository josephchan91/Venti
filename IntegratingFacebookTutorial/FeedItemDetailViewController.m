//
//  FeedItemDetailViewController.m
//  IntegratingFacebookTutorial
//
//  Created by josephchan91 on 12/15/12.
//
//

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
    
    // Background color of text container
    self.commentView.backgroundColor = [UIColor colorWithRed:24.0/255.0 green:167.0/255.0 blue:181.0/255.0 alpha:1.0];
    
    // set up text field delegate
    self.commentTextField.delegate = self;
    
    // Get table info
    [self refreshComments];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [self configureView];
}

- (void)refreshComments
{
    PFQuery *query = [PFQuery queryWithClassName:kCommentClassKey];
    [query whereKey:kCommentPostKey equalTo:self.postId];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        // Add comments to array
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
    [super viewDidUnload];
}

#pragma mark - UITextFieldDelegate methods
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3]; // if you want to slide up the view
    CGRect commentViewRect = self.commentView.frame;
    commentViewRect.origin.y -= kOFFSET_FOR_KEYBOARD;
    self.commentView.frame = commentViewRect;
    [UIView commitAnimations];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self shiftTextFieldDown];
    [self.commentTextField resignFirstResponder];
    return YES;
}

- (IBAction)postCommentButtonAction:(id)sender {
    if ([self.commentTextField.text length] == 0) return;

    // Save the comment
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

- (void)shiftTextFieldDown
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3]; // if you want to slide up the view
    CGRect commentViewRect = self.commentView.frame;
    commentViewRect.origin.y += kOFFSET_FOR_KEYBOARD;
    self.commentView.frame = commentViewRect;
    [UIView commitAnimations];
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
    
    // Configure the cell...
    if (cell == nil) {
        // Create the cell and add the labels
        cell = [[CommentCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        [cell setSelectionStyle:UITableViewCellSelectionStyleGray];
    }
    
    PFObject *comment = [comments objectAtIndex:indexPath.row];
    cell.commentContentLabel.text = [comment objectForKey:kCommentContentKey];
    
    // Get the user
    PFUser *commenter = [comment objectForKey:kCommentCommenterKey];
    [commenter fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        if (!error) {
            // Show user info
            cell.commenterNameLabel.text = [object objectForKey:kUserNameKey];
            PFFile *photo = [object objectForKey:kUserPhotoKey];
            [photo getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                // Show photo
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

@end
