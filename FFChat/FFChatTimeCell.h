//
//  FFChatTimeCell.h
//  EduChat
//
//  Created by apple on 11/23/15.
//  Copyright © 2015 FF. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FFInteractiveChatCell.h"

@interface FFChatTimeCell : UITableViewCell

@property (strong, nonatomic) UILabel *contentLabel;

- (CGFloat)getHeight;

@end
