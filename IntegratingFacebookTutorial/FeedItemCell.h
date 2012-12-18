/**
 Class for the view of a feed item in a user's feed
 **/

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface FeedItemCell : UITableViewCell

// Card View
@property (weak, nonatomic) IBOutlet UIView *cardView;

@property (weak, nonatomic) IBOutlet UIImageView *posterThumbnailImageView;
@property (weak, nonatomic) IBOutlet UILabel *posterNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeDiffLabel;
@property (weak, nonatomic) IBOutlet UIImageView *feedPhotoImageView;
@property (strong, nonatomic) NSString *postId;

@end
