//
//  FeedItemDetailViewController.h
//  IntegratingFacebookTutorial
//
//  Created by josephchan91 on 12/15/12.
//
//

#import <UIKit/UIKit.h>

@interface FeedItemDetailViewController : UIViewController

@property (weak, nonatomic) UIImage *posterThumbnail;
@property (weak, nonatomic) UIImage *postImage;
@property (weak, nonatomic) NSString *posterName;
@property (weak, nonatomic) NSString *postTimeDiff;

@property (weak, nonatomic) IBOutlet UIImageView *posterThumbnailImageView;
@property (weak, nonatomic) IBOutlet UIImageView *postImageImageView;
@property (weak, nonatomic) IBOutlet UILabel *posterNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *postTimeDiffLabel;

@end
