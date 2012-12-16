//
//  CreatePostViewController.m
//  IntegratingFacebookTutorial
//
//  Created by josephchan91 on 12/14/12.
//
//

#import "CreatePostViewController.h"
#import "Constants.h"

@interface CreatePostViewController ()

@property (retain, nonatomic) PF_FBFriendPickerViewController *friendPickerController;
@property (nonatomic, strong) PFFile *photoFile;

@end

@implementation CreatePostViewController

NSMutableArray *friendIds;
UIImageView *photoImageView;
UIImage *image;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    // Add post button
    UIBarButtonItem *postButton = [[UIBarButtonItem alloc] initWithTitle:@"Post" style:UIBarButtonItemStyleBordered target:self action:@selector(postButtonTouchHandler:)];
    self.navigationItem.rightBarButtonItem = postButton;
    
    // Set up array for friends to share photo with
    friendIds = [NSMutableArray array];
    
    // Set up keyboard immediately
    self.shareWithFriendsTextField.delegate = self;
    //[self.shareWithFriendsTextField becomeFirstResponder];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setShareWithFriendsTextField:nil];
    [self setAddPhotoButton:nil];
    [self setPhotoButtonContainerView:nil];
    [self setSearchBar:nil];
    [self setSearchText:nil];
    [super viewDidUnload];
}

#pragma mark - Photo

/** Add Photo Methods **/
// Called when add photo button is clicked
- (IBAction)addPhotoAction:(id)sender {
    BOOL photoLibraryAvailable = [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary];
    if (photoLibraryAvailable) {
        [self shouldStartPhotoLibraryPickerController];
    }
}

// Takes user to photo library picker
- (BOOL)shouldStartPhotoLibraryPickerController {
    if (([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary] == NO
         && [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum] == NO)) {
        return NO;
    }
    
    UIImagePickerController *cameraUI = [[UIImagePickerController alloc] init];
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]
        && [[UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypePhotoLibrary] containsObject:(NSString *)kUTTypeImage]) {
        
        cameraUI.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        cameraUI.mediaTypes = [NSArray arrayWithObject:(NSString *) kUTTypeImage];
        
    } else if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum]
               && [[UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeSavedPhotosAlbum] containsObject:(NSString *)kUTTypeImage]) {
        
        cameraUI.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
        cameraUI.mediaTypes = [NSArray arrayWithObject:(NSString *) kUTTypeImage];
        
    } else {
        return NO;
    }
    
    cameraUI.allowsEditing = YES;
    cameraUI.delegate = self;
    
    [self presentViewController:cameraUI animated:YES completion:NULL];
    
    return YES;
}

/** UIImagePickerDelegate **/

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [self dismissViewControllerAnimated:YES completion:NULL];
    
    image = [info objectForKey:UIImagePickerControllerEditedImage];
    if (nil == photoImageView) {
        photoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 44.0f, 320.0f, 320.0f)];
        [photoImageView setBackgroundColor:[UIColor blackColor]];
    }
    [photoImageView setImage:image];
    [photoImageView setContentMode:UIViewContentModeScaleAspectFit];
    
    //[self.addPhotoButton setHidden:YES];
    //[self.photoButtonContainerView setHidden:YES];
    [self.shareWithFriendsTextField resignFirstResponder];
    
    [self.view addSubview:photoImageView];
}

#pragma mark - Share With
/** UITextFieldDelegate **/
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    return NO;
}

- (IBAction)shareWithFriendsAction:(id)sender {
    if (self.friendPickerController == nil) {
        // Create friend picker, and get data loaded into it.
        self.friendPickerController = [[PF_FBFriendPickerViewController alloc] init];
        self.friendPickerController.title = @"Pick Friends";
        self.friendPickerController.delegate = self;
    }
    
    [self.friendPickerController loadData];
    [self.friendPickerController clearSelection];
    [self presentViewController:self.friendPickerController animated:YES completion:^(void){
        [self addSearchBarToFriendPickerView];
    }];
}

- (void)facebookViewControllerDoneWasPressed:(id)sender {
    NSMutableString *text = [[NSMutableString alloc] init];
    
    // we pick up the users from the selection, and create a string that we use to update the text view
    // at the bottom of the display; note that self.selection is a property inherited from our base class
    for (id<PF_FBGraphUser> user in self.friendPickerController.selection) {
        if ([text length]) {
            [text appendString:@", "];
        }
        [text appendString:user.name];
        [friendIds addObject:user.id];
    }
    
    self.shareWithFriendsTextField.text = text;
    [self handlePickerDone];
}

- (void)facebookViewControllerCancelWasPressed:(id)sender {
    NSLog(@"Cancelled friend selection");
    [self handlePickerDone];
}

// Search functionality for friend picker
- (void)addSearchBarToFriendPickerView
{
    if (self.searchBar == nil) {
        CGFloat searchBarHeight = 44.0;
        self.searchBar =
        [[UISearchBar alloc]
         initWithFrame:
         CGRectMake(0,0,
                    self.view.bounds.size.width,
                    searchBarHeight)];
        self.searchBar.autoresizingMask = self.searchBar.autoresizingMask |
        UIViewAutoresizingFlexibleWidth;
        self.searchBar.delegate = self;
        self.searchBar.showsCancelButton = YES;
        
        [self.searchBar becomeFirstResponder];
        [self.friendPickerController.canvasView addSubview:self.searchBar];
        CGRect newFrame = self.friendPickerController.view.bounds;
        newFrame.size.height -= searchBarHeight;
        newFrame.origin.y = searchBarHeight;
        self.friendPickerController.tableView.frame = newFrame;
    }
}

- (BOOL)friendPickerViewController:(PF_FBFriendPickerViewController *)friendPicker
                 shouldIncludeUser:(id<PF_FBGraphUser>)user
{
    if (self.searchText && ![self.searchText isEqualToString:@""]) {
        if ([[user.name lowercaseString] hasPrefix:[self.searchText lowercaseString]]) {
            return YES;
        } else {
            return NO;
        }
    } else {
        return YES;
    }
    return YES;
}

- (void) handleSearch:(UISearchBar *)searchBar {
    self.searchText = searchBar.text;
    [self.friendPickerController updateView];
}

- (void)handlePickerDone
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

/** UISearchBarDelegate Methods **/
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    [self handleSearch:searchBar];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *) searchBar {
    self.searchText = nil;
    [searchBar resignFirstResponder];
}

#pragma mark - 
// Send the post
- (void)postButtonTouchHandler:(id)sender {

    // Check for people to share with
    if ([friendIds count] == 0) {
        UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"No Friends Selected" message:@"Please select people to share with." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [message show];
        return;
    }
    
    // Check for photo
    if (nil == image) {
        UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"No Photo Selected" message:@"Please select a photo to share." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [message show];
        return;
    }
    
    NSLog(@"Going to post photo now!");
    // JPEG to decrease file size and enable faster uploads & downloads
    NSData *imageData = UIImageJPEGRepresentation(image, 0.8f);
    self.photoFile = [PFFile fileWithData:imageData];
    [self.photoFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            // Create a photo object
            PFObject *photo = [PFObject objectWithClassName:kPhotoClassKey];
            [photo setObject:[PFUser currentUser] forKey:kPhotoOwnerKey];
            [photo setObject:self.photoFile forKey:kPhotoImageKey];
            [photo saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                // Create post object
                PFObject *post = [PFObject objectWithClassName:kPostClassKey];
                [post setObject:[PFUser currentUser] forKey:kPostPosterKey];
                [post setObject:photo forKey:kPostPhotoKey];
                [post saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    // Create the feed objects for all viewers
                    // Add self as viewer
                    [friendIds addObject:[[PFUser currentUser] objectForKey:kUserFacebookKey]];
                    NSEnumerator *e = [friendIds objectEnumerator];
                    NSString *object;
                    while (object = [e nextObject]) {
                        PFObject *feedItem = [PFObject objectWithClassName:kFeedItemClassKey];
                        [feedItem setObject:object forKey:kFeedItemViewerKey];
                        [feedItem setObject:post forKey:kFeedItemPostKey];
                        [feedItem saveInBackground];
                    }
                }];
            }];
        }
    }];
    
    
    
    [self.navigationController popViewControllerAnimated:YES];

}


@end
