//
//  FFChatImageCell.h
//  EduChat
//
//  Created by apple on 11/23/15.
//  Copyright © 2015 FF. All rights reserved.
//

#import "FFInteractiveChatCell.h"

@interface FFChatImageCell : FFInteractiveChatCell

@property (strong, nonatomic) UIImageView *contentImageView;
@property (strong, nonatomic) UILabel *desLabel;

@property (nonatomic) CGSize imageSize;

@end
