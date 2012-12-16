//
//  FeedViewController.h
//  IntegratingFacebookTutorial
//
//  Created by josephchan91 on 12/14/12.
//
//

#import <Parse/Parse.h>
#import <UIKit/UIKit.h>

@interface FeedViewController : UITableViewController <NSURLConnectionDelegate>

// UITableView row data properties
@property (nonatomic, strong) NSMutableArray *rowDataArray;

// UINavigationBar button touch handler
- (void)logoutButtonTouchHandler:(id)sender;
- (IBAction)createPostButtonTouchHandler:(id)sender;

@end
