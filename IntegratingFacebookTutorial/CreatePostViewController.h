/**
 Class for creating a new post
 **/


#import <UIKit/UIKit.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <Parse/Parse.h>

@interface CreatePostViewController : UIViewController <UINavigationControllerDelegate, UIImagePickerControllerDelegate,
UISearchBarDelegate, UITextFieldDelegate, PF_FBFriendPickerDelegate>


// Friend Ricker
@property (weak, nonatomic) IBOutlet UITextField *shareWithFriendsTextField;
@property (retain, nonatomic) UISearchBar *searchBar;
@property (retain, nonatomic) NSString *searchText;

// Views
@property (weak, nonatomic) IBOutlet UIView *photoButtonContainerView;

// Buttons
@property (weak, nonatomic) IBOutlet UIButton *addPhotoButton;

// Actions
- (IBAction)addPhotoAction:(id)sender;
- (IBAction)shareWithFriendsAction:(id)sender;



@end
