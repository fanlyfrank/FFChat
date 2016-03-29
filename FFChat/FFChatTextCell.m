//
//  FFChatTextCell.m
//  EduChat
//
//  Created by apple on 11/23/15.
//  Copyright © 2015 FF. All rights reserved.
//

#import "FFChatTextCell.h"
#import "UIImage+Utils.h"

@interface FFChatTextCell () {
    CGRect backgroundFrame, contentFrame;
}

@property (strong, nonatomic) UIImageView *backgroundImgView;

@end

@implementation FFChatTextCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self commitInit];
        [self buildSubviews];
        self.menuTargetView = self.backgroundImgView;
    }
    return self;
}

- (CGFloat)getHeight {
    
    CGFloat result;
    
    if (self.isShowNickname) {
         result = ceil(MAX([self getContentSize].height + [self getNicknameSize].height + 2 * FFCellPadding + 2 * FFContentUpDownPadding, FFAvatarEdgeLength + 2 * FFCellPadding));
    } else {
         result = ceil(MAX([self getContentSize].height + 2 * FFCellPadding + 2 * FFContentUpDownPadding, FFAvatarEdgeLength + 2 * FFCellPadding));
    }
   
    return result;
}

- (void)layoutSubviews {
    
    [super layoutSubviews];
    
    if (self.userType == FFChatCellUserTypeMyself) {
        
        [self buildFrameForTextByMyself];
        
    } else {
        
        [self buildFrameForTextByOther];
        
    }
    
    [self setFrames];
    [self setImages];
}

- (void)UIPrepareForNormalStatus {
    [self.sendingIndicator stopAnimating];
    self.sendingIndicator.hidden = YES;
    self.errorImgView.hidden = YES;
}

- (void)UIPrepareForSendingDataStatus {
    self.sendingIndicator.hidden = NO;
    [self.sendingIndicator startAnimating];
    self.errorImgView.hidden = YES;
}

- (void)UIPrepareForErrorStatus {
    [self.sendingIndicator stopAnimating];
    self.sendingIndicator.hidden = YES;
    self.errorImgView.hidden = NO;
    self.errorImgView.backgroundColor = [UIColor redColor];
}
#pragma mark - TTTAttributedLabel delegate methods
- (void)attributedLabelDidLongPressPlainText:(TTTAttributedLabel *)label {
    [self longPressHandler:label.longPressGestureRecognizer];
}

#pragma mark - private methods

- (CGSize)getContentSize {
    
    CGSize result = [TTTAttributedLabel sizeThatFitsAttributedString:self.contentLabel.attributedText withConstraints:CGSizeMake(FFScreenW - FFAvatarEdgeLength - 4 * FFCellPadding - FFIndicatorWidth - FFContentLeftRightPaddingMax - FFContentLeftRightPaddingMin, 99999) limitedToNumberOfLines:0];
    float height = ceilf(MAX(result.height, FFAvatarEdgeLength - 2 * FFContentUpDownPadding));
    
    result = CGSizeMake(ceilf(result.width), height);
    
    return result;
}

- (void)buildFrameForTextByMyself {
    
    [self buildMyselfAvatarFrame];
    
    CGSize nicknameSize = [self buildMyselfNicknameFrame];
    
    //content frame
    CGSize contentSize =  [self getContentSize];
    contentFrame = CGRectMake(FFScreenW - FFAvatarEdgeLength - 2 * FFCellPadding - FFContentLeftRightPaddingMax - contentSize.width,
                              FFCellPadding + nicknameSize.height + FFContentUpDownPadding, contentSize.width, contentSize.height);
    
    //background frame
    backgroundFrame = CGRectMake(contentFrame.origin.x - FFContentLeftRightPaddingMin,
                                 FFCellPadding + nicknameSize.height,
                                 contentSize.width + FFContentLeftRightPaddingMax + FFContentLeftRightPaddingMin,
                                 contentSize.height + 2 * FFContentUpDownPadding);
    
    //indicator frame
    sendingFrame = CGRectMake(backgroundFrame.origin.x - FFCellPadding - FFErrorEdgeLength, FFCellPadding, FFErrorEdgeLength, FFErrorEdgeLength);
    errorFrame = sendingFrame;
    
    
}

- (void)buildFrameForTextByOther {
    
    [self buildOtherAvatarFrame];
    
    CGSize nicknameSize = [self buildOtherNicknameFrame];
    
    //content frame
    CGSize contentSize = [self getContentSize];
    contentFrame = CGRectMake(FFAvatarEdgeLength + 2 * FFCellPadding + FFContentLeftRightPaddingMax,
                              FFCellPadding + nicknameSize.height + FFContentUpDownPadding, contentSize.width, contentSize.height);
    
    if (self.isEditing) contentFrame = CGRectMake(contentFrame.origin.x + FFCellEditingEdgeLength + FFCellPadding, contentFrame.origin.y, contentFrame.size.width, contentFrame.size.height);
    
    //background frame
    backgroundFrame = CGRectMake(contentFrame.origin.x - FFContentLeftRightPaddingMax,
                                 FFCellPadding + nicknameSize.height, contentSize.width +
                                 FFContentLeftRightPaddingMax + FFContentLeftRightPaddingMin,
                                 contentSize.height + 2 * FFContentUpDownPadding);
    
    //indicator frame
    sendingFrame = CGRectMake(backgroundFrame.origin.x + backgroundFrame.size.width + FFCellPadding, FFCellPadding, FFErrorEdgeLength, FFErrorEdgeLength);
    errorFrame = sendingFrame;
    
    
}

- (void)buildSubviews {
    
    //this subclass has a long press recognizer, so make supcalss's nil
    self.longPress = nil;
    
    _backgroundImgView = [[UIImageView alloc] initWithFrame:CGRectZero];
 
    _contentLabel = [[TTTAttributedLabel alloc] initWithFrame:CGRectZero];
    self.contentLabel.delegate = self;
    self.contentLabel.font = FFFontBody;
    self.contentLabel.textColor = FFColorContent;
    self.contentLabel.numberOfLines = 0;
    self.contentLabel.linkAttributes = @{NSForegroundColorAttributeName:FFColorMain};
    
    [self.contentView addSubview:self.backgroundImgView];
    [self.contentView addSubview:self.contentLabel];
}

- (void)setFrames {
    
    self.avatarImgView.frame = avatareFrame;
    self.editingView.frame = editingFrame;
    self.editingView.center = CGPointMake(self.editingView.center.x, self.avatarImgView.center.y);
    self.nicknameLabel.frame = nicknameFrame;
    self.backgroundImgView.frame = backgroundFrame;
    self.contentLabel.frame = contentFrame;
    
    self.sendingIndicator.frame = sendingFrame;
    self.sendingIndicator.center = CGPointMake(self.sendingIndicator.center.x, self.backgroundImgView.center.y);

    self.errorImgView.frame = errorFrame;
    self.errorImgView.center = CGPointMake(self.errorImgView.center.x, self.backgroundImgView.center.y);
}

- (void)setImages {
    if (self.userType == FFChatCellUserTypeMyself) {
        self.backgroundImgView.image = [self.bubbleMyself renderAtSize:backgroundFrame.size];
    } else {
        self.backgroundImgView.image = [self.bubbleOther renderAtSize:backgroundFrame.size];
    }
}
@end
