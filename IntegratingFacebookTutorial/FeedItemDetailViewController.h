/**
 Class for displaying a post
 **/

#import <Parse/Parse.h>
#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface FeedItemDetailViewController : UIViewController <UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource>

// Post data
@property (weak, nonatomic) IBOutlet UIScrollView *feedDetailScrollView;
@property (weak, nonatomic) UIImage *posterThumbnail;
@property (weak, nonatomic) UIImage *postImage;
@property (weak, nonatomic) NSString *posterName;
@property (weak, nonatomic) NSString *postTimeDiff;
@property (weak, nonatomic) NSString *postId;

// Card View that contains the post information
@property (weak, nonatomic) IBOutlet UIView *cardView;

// Header view - area above all the comments
@property (weak, nonatomic) IBOutlet UIImageView *posterThumbnailImageView;
@property (weak, nonatomic) IBOutlet UILabel *posterNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *postTimeDiffLabel;
@property (weak, nonatomic) IBOutlet UIImageView *postPhotoImageView;

// Comments
@property (weak, nonatomic) IBOutlet UIView *commentView;
@property (weak, nonatomic) IBOutlet UITextField *commentTextField;
- (IBAction)postCommentButtonAction:(id)sender;
@property (weak, nonatomic) IBOutlet UITableView *commentsTableView;

@end
