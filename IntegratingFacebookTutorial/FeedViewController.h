/**
 Class for displaying a user's feed
 **/

#import <Parse/Parse.h>
#import <UIKit/UIKit.h>

@interface FeedViewController : UITableViewController <NSURLConnectionDelegate>

// UITableView row data for feed objects
@property (nonatomic, strong) NSMutableArray *rowDataArray;

// UINavigationBar button touch handler
- (void)logoutButtonTouchHandler:(id)sender;
- (IBAction)createPostButtonTouchHandler:(id)sender;

// Refresh button action
- (IBAction)refreshFeedAction:(id)sender;

@end
