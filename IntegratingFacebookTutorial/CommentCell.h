/**
 Class for the view of a comment in a post's detail view
 **/

#import <UIKit/UIKit.h>

@interface CommentCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *commenterThumbnailImageView;
@property (weak, nonatomic) IBOutlet UILabel *commenterNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *commentTimeDiffLabel;
@property (weak, nonatomic) IBOutlet UILabel *commentContentLabel;

@end
