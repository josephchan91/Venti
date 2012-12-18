/**
 Class for handling user logins
 **/

#import "LoginViewController.h"
#import <Parse/Parse.h>

@implementation LoginViewController


#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Venti";
    
    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:24.0/255.0 green:167.0/255.0 blue:181.0/255.0 alpha:1.0];
    
    // Check if user is cached and linked to Facebook, if so, bypass login    
    if ([PFUser currentUser] && [PFFacebookUtils isLinkedWithUser:[PFUser currentUser]]) {
        // Push to feed view controller
        [self performSegueWithIdentifier:@"FeedViewControllerSegue" sender:self];
    }
}

- (void)viewDidUnload {
    [self setBackgroundImageView:nil];
    [super viewDidUnload];
}

/* We want to hide the navigation bar for the login view only */
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO];
}

#pragma mark - Login mehtods

/* Login to facebook method */
- (IBAction)loginButtonTouchHandler:(id)sender  {
    // Set permissions required from the facebook user account
    NSArray *permissionsArray = @[ @"user_about_me"];
    
    // Login PFUser using facebook
    [PFFacebookUtils logInWithPermissions:permissionsArray block:^(PFUser *user, NSError *error) {        
        if (!user) {
            // Unable to return a user
            if (!error) {
                NSLog(@"Uh oh. The user cancelled the Facebook login.");
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Log In Error" message:@"Uh oh. The user cancelled the Facebook login." delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Dismiss", nil];
                [alert show];
            } else {
                NSLog(@"Uh oh. An error occurred: %@", error);
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Log In Error" message:[error description] delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Dismiss", nil];
                [alert show];
            }
        } else if (user.isNew) {
            // A new PFUser was created
            NSLog(@"User with facebook signed up and logged in!");
            // Push to feed view controller
            [self performSegueWithIdentifier:@"FeedViewControllerSegue" sender:self];
        } else {
            // A returning PFUser has logged in
            NSLog(@"User with facebook logged in!");
            // Push to feed view controller
            [self performSegueWithIdentifier:@"FeedViewControllerSegue" sender:self];
        }
    }];
}

@end
