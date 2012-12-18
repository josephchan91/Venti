/**
 Class for handling user logins
 **/

#import <UIKit/UIKit.h>

@interface LoginViewController : UIViewController

@property (nonatomic, strong) IBOutlet UIActivityIndicatorView *activityIndicator;

- (IBAction)loginButtonTouchHandler:(id)sender;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;

@end
