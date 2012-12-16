//
//  FeedItemDetailViewController.h
//  IntegratingFacebookTutorial
//
//  Created by josephchan91 on 12/15/12.
//
//

#import <Parse/Parse.h>
#import <UIKit/UIKit.h>

@interface FeedItemDetailViewController : UIViewController <UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource>

// Scroll view
@property (weak, nonatomic) IBOutlet UIScrollView *feedDetailScrollView;
@property (weak, nonatomic) UIImage *posterThumbnail;
@property (weak, nonatomic) UIImage *postImage;
@property (weak, nonatomic) NSString *posterName;
@property (weak, nonatomic) NSString *postTimeDiff;
@property (weak, nonatomic) NSString *postId;

// Header view
@property (weak, nonatomic) IBOutlet UIImageView *posterThumbnailImageView;
@property (weak, nonatomic) IBOutlet UILabel *posterNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *postTimeDiffLabel;
@property (weak, nonatomic) IBOutlet UIImageView *postPhotoImageView;


// Comment
@property (weak, nonatomic) IBOutlet UIView *commentView;
@property (weak, nonatomic) IBOutlet UITextField *commentTextField;
- (IBAction)postCommentButtonAction:(id)sender;

// Table for comments
@property (weak, nonatomic) IBOutlet UITableView *commentsTableView;

@end
