//
//  Copyright (c) 2012 Parse. All rights reserved.

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
        // push to feed
        [self performSegueWithIdentifier:@"FeedViewControllerSegue" sender:self];
    }
}

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
        [_activityIndicator stopAnimating]; // Hide loading indicator
        
        if (!user) {
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
            NSLog(@"User with facebook signed up and logged in!");
            // push to feed
            [self performSegueWithIdentifier:@"FeedViewControllerSegue" sender:self];
        } else {
            NSLog(@"User with facebook logged in!");
            // push to feed
            [self performSegueWithIdentifier:@"FeedViewControllerSegue" sender:self];
        }
    }];
    
    [_activityIndicator startAnimating]; // Show loading indicator until login is finished
}

- (void)viewDidUnload {
    [self setBackgroundImageView:nil];
    [super viewDidUnload];
}
@end
