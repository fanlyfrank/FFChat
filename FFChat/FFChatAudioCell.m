//
//  FFChatAudioCell.m
//  EduChat
//
//  Created by apple on 11/23/15.
//  Copyright © 2015 FF. All rights reserved.
//

#import "FFChatAudioCell.h"
#import "UIImage+Utils.h"

#define FFDurationMultiple 15

@interface FFChatAudioCell () {
    CGRect backgroundImageFrame, desFrame;
}

@property (strong, nonatomic) UIImageView *backgroundImageView;

@end

@implementation FFChatAudioCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self commitInit];
        [self buildSubviews];
        self.menuTargetView = self.backgroundImageView;
    }
    return self;
}

- (void)layoutSubviews {
    
    [super layoutSubviews];
    
    if (self.userType == FFChatCellUserTypeMyself) {
        
        [self buildFrameForAudioByMyself];
        
    } else {
        
        [self buildFrameForAudioByOther];
    }
    
    [self setFrames];
    [self setImages];
}

- (CGFloat)getHeight {
    return self.isShowNickname ? FFAvatarEdgeLength + 2 * FFCellPadding + [self getNicknameSize].height : FFAvatarEdgeLength + 2 * FFCellPadding;
}

- (void)buildSubviews {
    
    _backgroundImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    self.backgroundImageView.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(contentTapHandler:)];
    [self.backgroundImageView addGestureRecognizer:tap];
    [self.backgroundImageView addGestureRecognizer:self.longPress];
    
    _desLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.desLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleCaption2];
    
    [self.contentView addSubview:self.backgroundImageView];
    [self.contentView addSubview:self.desLabel];
}

- (void)UIPrepareForCreateStatus {
    [self.sendingIndicator stopAnimating];
    self.sendingIndicator.hidden = YES;
    self.errorImgView.hidden = YES;
    self.desLabel.hidden = YES;
    [self startFlashing];
}

- (void)UIPrepareForNormalStatus {
    [self.sendingIndicator stopAnimating];
    self.sendingIndicator.hidden = YES;
    self.errorImgView.hidden = YES;
    self.desLabel.hidden = NO;
    [self stopFlashing];
}

- (void)UIPrepareForSendingDataStatus {
    [self.contentView bringSubviewToFront:self.sendingIndicator];
    self.sendingIndicator.hidden = NO;
    [self.sendingIndicator startAnimating];
    self.errorImgView.hidden = YES;
    self.desLabel.hidden = YES;
    [self stopFlashing];
}

- (void)UIPrepareForErrorStatus {
    [self.sendingIndicator stopAnimating];
    self.sendingIndicator.hidden = YES;
    self.errorImgView.hidden = NO;
    self.desLabel.hidden = YES;
}

#pragma mark - private methods
- (void)buildFrameForAudioByMyself {
    
    [self buildMyselfAvatarFrame];
    
    CGSize nicknameSize = [self buildMyselfNicknameFrame];
    
    float backgroundLength = [self getAudioLength];
    
    backgroundImageFrame = CGRectMake(FFScreenW - FFAvatarEdgeLength - 2 * FFCellPadding - backgroundLength, FFCellPadding + nicknameSize.height, backgroundLength, FFAvatarEdgeLength);
    
    //indicator frame
    sendingFrame = CGRectMake(backgroundImageFrame.origin.x - FFCellPadding - FFErrorEdgeLength, FFCellPadding, FFErrorEdgeLength, FFErrorEdgeLength);
    errorFrame = sendingFrame;
    
    CGSize desSize = [self getDesSize];
    desFrame = CGRectMake(backgroundImageFrame.origin.x - FFCellPadding - desSize.width, 0, desSize.width, desSize.height);
}

- (void)buildFrameForAudioByOther {
    
    [self buildOtherAvatarFrame];
    
    CGSize nicknameSize = [self buildOtherNicknameFrame];
    
    float backgroundLength = [self getAudioLength];
    
    //background frame
    backgroundImageFrame = CGRectMake(FFAvatarEdgeLength + 2 * FFCellPadding, FFCellPadding + nicknameSize.height, backgroundLength, FFAvatarEdgeLength);
    if (self.isEditing) backgroundImageFrame = CGRectMake(backgroundImageFrame.origin.x + FFCellEditingEdgeLength + FFCellPadding,backgroundImageFrame.origin.y, backgroundImageFrame.size.width, backgroundImageFrame.size.height);
    
    //indicator frame
    sendingFrame = CGRectMake(backgroundImageFrame.origin.x + backgroundImageFrame.size.width + FFCellPadding, FFCellPadding, FFErrorEdgeLength, FFErrorEdgeLength);
    errorFrame = sendingFrame;
    
   
    CGSize desSize = [self getDesSize];
    desFrame = CGRectMake(backgroundImageFrame.origin.x + backgroundImageFrame.size.width + FFCellPadding, 0, desSize.width, desSize.height);
}

- (CGFloat)getAudioLength {
    return  MIN(ceil(MIN(FFScreenW - FFAvatarEdgeLength - 4 * FFCellPadding - FFIndicatorWidth, self.audioDuration * FFDurationMultiple)), FFScreenW - FFAvatarEdgeLength - 4 * FFCellPadding - FFIndicatorWidth);
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

- (void)setFrames {
    self.avatarImgView.frame = avatareFrame;
    self.editingView.frame = editingFrame;
    self.editingView.center = CGPointMake(self.editingView.center.x, self.avatarImgView.center.y);
    self.nicknameLabel.frame = nicknameFrame;
    self.backgroundImageView.frame = backgroundImageFrame;
    
    self.sendingIndicator.frame = sendingFrame;
    self.sendingIndicator.center = CGPointMake(self.sendingIndicator.center.x, self.backgroundImageView.center.y);
    
    self.errorImgView.frame = errorFrame;
    self.errorImgView.center = CGPointMake(self.errorImgView.center.x, self.backgroundImageView.center.y);
    
    self.desLabel.frame = desFrame;
    self.desLabel.center = self.sendingIndicator.center;
}

- (void)setImages {
    if (self.userType == FFChatCellUserTypeMyself) {
        self.backgroundImageView.image = [self.bubbleMyself renderAtSize:backgroundImageFrame.size];
    } else {
        self.backgroundImageView.image = [self.bubbleOther renderAtSize:backgroundImageFrame.size];
    }
}

- (void)contentTapHandler:(UITapGestureRecognizer *)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(interactiveChatCellDidClickContentAtIndexPath:)]) {
        [self.delegate interactiveChatCellDidClickContentAtIndexPath:self.indexPath];
    }
}

- (void)startFlashing {
    
    [UIView animateWithDuration:.75
                          delay:0
                        options:UIViewAnimationOptionCurveEaseInOut |
                                UIViewAnimationOptionRepeat |
                                UIViewAnimationOptionAutoreverse |
                                UIViewAnimationOptionAllowUserInteraction
     
                     animations:^{
                         self.backgroundImageView.alpha = 0;
                         
                     } completion:nil];

}

- (void)stopFlashing {
    [UIView animateWithDuration:0.12
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseInOut |
                                UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         self.backgroundImageView.alpha = 1.0f;
                     }
                     completion:nil];
}

@end
