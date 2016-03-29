//
//  FFChatTimeCell.m
//  EduChat
//
//  Created by apple on 11/23/15.
//  Copyright © 2015 FF. All rights reserved.
//

#import "FFChatTimeCell.h"

#define FFTimeCellPadding 4

@interface FFChatTimeCell () {
    CGRect backgroundFrame, contentFrame;
}

@property (strong, nonatomic) UIImageView *backgroundImageView;

@end

@implementation FFChatTimeCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        _backgroundImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        self.backgroundImageView.image = [UIImage imageNamed:@"bg_show_date_class_dialogue_pages"];
        
        _contentLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        self.contentLabel.font = FFFontMin;
        self.contentLabel.textColor = [UIColor whiteColor];
        
        [self.contentView addSubview:self.backgroundImageView];
        [self.contentView addSubview:self.contentLabel];
        
        self.contentView.backgroundColor = FFColorBackgroud;
    }
    return self;
}

- (void)layoutSubviews {
    
    CGSize contentSize = [self getContentSize];
    
    contentFrame = CGRectMake(0, 0, contentSize.width, contentSize.height);
    backgroundFrame = CGRectMake(0, 0, contentSize.width + 2 * FFTimeCellPadding, contentSize.height + 2 * FFTimeCellPadding);
    
    self.contentLabel.frame = contentFrame;
    self.backgroundImageView.frame = backgroundFrame;
    
    self.contentLabel.center = self.contentView.center;
    self.backgroundImageView.center = self.contentView.center;
}

- (CGFloat)getHeight {
    return [self getContentSize].height + 2 * FFTimeCellPadding;
}

- (CGSize)getContentSize {
    return [self.contentLabel.text
            boundingRectWithSize:CGSizeMake(0, 0)
            options:NSStringDrawingUsesLineFragmentOrigin
            attributes:@{NSFontAttributeName:self.contentLabel.font}
            context:nil].size;

}

@end
