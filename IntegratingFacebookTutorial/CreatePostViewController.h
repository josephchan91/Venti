//
//  CreatePostViewController.h
//  IntegratingFacebookTutorial
//
//  Created by josephchan91 on 12/14/12.
//
//

#import <UIKit/UIKit.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <Parse/Parse.h>

@interface CreatePostViewController : UIViewController <UINavigationControllerDelegate, UIImagePickerControllerDelegate,
UISearchBarDelegate, UITextFieldDelegate, PF_FBFriendPickerDelegate>


// Share with Friends Text Field
@property (weak, nonatomic) IBOutlet UITextField *shareWithFriendsTextField;
// Views
@property (weak, nonatomic) IBOutlet UIView *photoButtonContainerView;
// Buttons
@property (weak, nonatomic) IBOutlet UIButton *addPhotoButton;
// Actions
- (IBAction)addPhotoAction:(id)sender;
- (IBAction)shareWithFriendsAction:(id)sender;
// Friend Picker Search
@property (retain, nonatomic) UISearchBar *searchBar;
@property (retain, nonatomic) NSString *searchText;



@end
