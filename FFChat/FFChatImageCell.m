//
//  FFChatImageCell.m
//  EduChat
//
//  Created by apple on 11/23/15.
//  Copyright © 2015 FF. All rights reserved.
//

#import "FFChatImageCell.h"
#import "UIImage+Utils.h"

@interface FFChatImageCell () {
    CGRect contentImageFrame, desFrame;
}

//@property (strong, nonatomic) UIImage *originalContentImage;
@end

@implementation FFChatImageCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self commitInit];
        [self buildSubviews];
        self.menuTargetView = self.contentImageView;
    }
    return self;
}

- (void)layoutSubviews {
    
    [super layoutSubviews];
    
    if (self.userType == FFChatCellUserTypeMyself) {
        
        [self buildFrameForImageByMyself];
        
    } else {
        
        [self buildFrameForImageByOther];
    }
    
    [self setFrames];
    [self setImages];

}

- (CGFloat)getHeight {
    
    CGFloat result;
    
    if (self.isShowNickname) {
        result = self.imageSize.height + [self getNicknameSize].height + 2 * FFCellPadding;
    } else {
        result = self.imageSize.height + 2 * FFCellPadding;
    }
    return result;
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {
    return [super canPerformAction:action withSender:sender] || action == @selector(upload:);
}

- (void)UIPrepareForNormalStatus {
    [self.sendingIndicator stopAnimating];
    self.sendingIndicator.hidden = YES;
    self.desLabel.hidden = YES;
    self.errorImgView.hidden = YES;
    
    self.contentImageView.image = [self.contentImageView.image renderAtAphla:1];
}

- (void)UIPrepareForSendingDataStatus {
    [self.contentView bringSubviewToFront:self.sendingIndicator];
    self.sendingIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
    self.sendingIndicator.hidden = NO;
    [self.sendingIndicator startAnimating];
    self.desLabel.hidden = NO;
    self.errorImgView.hidden = YES;

    self.contentImageView.image = [self.contentImageView.image renderAtAphla:.60];
}

- (void)UIPrepareForErrorStatus {
    
    [self.sendingIndicator stopAnimating];
    self.sendingIndicator.hidden = YES;
    self.desLabel.hidden = YES;
    self.errorImgView.hidden = NO;
    
    self.contentImageView.image = [self.contentImageView.image renderAtAphla:1];
}

#pragma mark - private methods
- (void)buildSubviews {
    _contentImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    self.contentImageView.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapContentHandler:)];
    [self.contentImageView addGestureRecognizer:tap];
    [self.contentImageView addGestureRecognizer:self.longPress];
    
    _desLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.desLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleCaption2];
    
    [self.contentView addSubview:self.contentImageView];
    [self.contentView addSubview:self.desLabel];
}

- (CGSize)getDesSize {
    
    CGSize result = [self.desLabel.text
                     boundingRectWithSize:CGSizeMake(FFErrorEdgeLength, FFErrorEdgeLength)
                     options:NSStringDrawingUsesFontLeading
                     attributes:@{NSFontAttributeName:self.desLabel.font}
                     context:nil].size;
    
    result = CGSizeMake(ceil(result.width), ceil(result.height));
    
    return result;
}

- (void)buildFrameForImageByMyself {
    
    [self buildMyselfAvatarFrame];
    
    CGSize nicknameSize = [self buildMyselfNicknameFrame];
    
    contentImageFrame = CGRectMake(FFScreenW - FFAvatarEdgeLength - 2 * FFCellPadding - self.imageSize.width,
                                   FFCellPadding + nicknameSize.height, self.imageSize.width, self.imageSize.height);
    
    //indicator frame
    sendingFrame = CGRectMake(contentImageFrame.origin.x - FFCellPadding - FFErrorEdgeLength,
                              FFCellPadding, FFErrorEdgeLength, FFErrorEdgeLength);
    errorFrame = sendingFrame;
    
    CGSize desSize = [self getDesSize];
    desFrame = CGRectMake(contentImageFrame.origin.x - FFCellPadding - desSize.width, 0, desSize.width, desSize.height);
    
    }

- (void)buildFrameForImageByOther {
    
    [self buildOtherAvatarFrame];
    
    CGSize nicknameSize = [self buildOtherNicknameFrame];
    
    contentImageFrame = CGRectMake(2 * FFCellPadding + FFAvatarEdgeLength,
                                   FFCellPadding + nicknameSize.height,
                                   self.imageSize.width, self.imageSize.height);
    if (self.isEditing) contentImageFrame = CGRectMake(contentImageFrame.origin.x + FFCellEditingEdgeLength + FFCellPadding, contentImageFrame.origin.y, contentImageFrame.size.width, contentImageFrame.size.height);
    
    sendingFrame  = CGRectMake(contentImageFrame.origin.x + contentImageFrame.size.width + FFCellPadding,
                               FFCellPadding, FFErrorEdgeLength, FFErrorEdgeLength);
    
    errorFrame = sendingFrame;
    
    CGSize desSize = [self getDesSize];
    desFrame = CGRectMake(contentImageFrame.origin.x + contentImageFrame.size.width + FFCellPadding, 0, desSize.width, desSize.height);
}

- (void)setFrames {
    
    self.avatarImgView.frame = avatareFrame;
    self.editingView.frame = editingFrame;
    self.editingView.center = CGPointMake(self.editingView.center.x, self.avatarImgView.center.y);
    self.nicknameLabel.frame = nicknameFrame;
    self.contentImageView.frame = contentImageFrame;
    
    self.sendingIndicator.frame = sendingFrame;
    float offset = self.userType == FFChatCellUserTypeMyself ? -5 : 5;
    self.sendingIndicator.center = CGPointMake(self.contentImageView.center.x + offset, self.contentImageView.center.y);
    
    self.errorImgView.frame = errorFrame;
    self.errorImgView.center = CGPointMake(self.errorImgView.center.x, self.contentImageView.center.y);
    
    self.desLabel.frame = desFrame;
    self.desLabel.center = self.sendingIndicator.center;
}

- (void)setImages {
    
    UIImage *mask;
    
    if (self.userType == FFChatCellUserTypeMyself) {
        mask = [self.bubbleMyself renderAtSize:contentImageFrame.size];
    } else {
        mask = [self.bubbleOther renderAtSize:contentImageFrame.size];
    }
    
    self.contentImageView.image = [self.contentImageView.image maskWithImage:mask];
}

- (void)tapContentHandler:(UITapGestureRecognizer *)sender {
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(interactiveChatCellDidClickContentAtIndexPath:)]) {
        [self.delegate interactiveChatCellDidClickContentAtIndexPath:self.indexPath];
    }
}

@end
