//
//  FeedItemDetailViewController.m
//  IntegratingFacebookTutorial
//
//  Created by josephchan91 on 12/15/12.
//
//

#import "FeedItemDetailViewController.h"

@interface FeedItemDetailViewController ()

@end

@implementation FeedItemDetailViewController

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
    [self.posterThumbnailImageView setImage: self.posterThumbnail];
    [self.posterThumbnailImageView setContentMode:UIViewContentModeScaleAspectFit];
    [self.postImageImageView setImage:self.postImage];
    [self.postImageImageView setContentMode:UIViewContentModeScaleAspectFit];
    self.posterNameLabel.text = self.posterName;
    self.postTimeDiffLabel.text = self.postTimeDiff;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [self configureView];
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
    [super viewDidUnload];
}
@end
