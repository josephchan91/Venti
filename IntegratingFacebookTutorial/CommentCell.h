//
//  CommentCell.h
//  IntegratingFacebookTutorial
//
//  Created by josephchan91 on 12/16/12.
//
//

#import <UIKit/UIKit.h>

@interface CommentCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *commenterThumbnailImageView;
@property (weak, nonatomic) IBOutlet UILabel *commenterNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *commentContentLabel;

@end
