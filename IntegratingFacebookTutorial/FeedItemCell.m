//
//  FeedItemCell.m
//  IntegratingFacebookTutorial
//
//  Created by josephchan91 on 12/14/12.
//
//

#import "FeedItemCell.h"

@implementation FeedItemCell

UIImageView *posterThumbnailImageView;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


@end
