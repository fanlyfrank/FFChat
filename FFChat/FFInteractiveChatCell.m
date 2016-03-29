//
//  FFInteractiveChatCell.m
//  EduChat
//
//  Created by apple on 11/17/15.
//  Copyright © 2015 FF. All rights reserved.
//

#import "FFInteractiveChatCell.h"

@interface FFInteractiveChatCell ()

@end

@implementation FFInteractiveChatCell

#pragma mark - override methods
- (void)layoutSubviews {
    [super layoutSubviews];
}

- (BOOL)canBecomeFirstResponder {
    return YES;
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {
    return (action == @selector(copy:) ||
            action == @selector(relay:) ||
            action == @selector(collect:)) ||
            action == @selector(more:);
}

- (void)copy:(id)sender {
    [self throwWarningIfNeeded];
    if (self.delegate && [self.delegate respondsToSelector:@selector(interactiveChatCellDidCopyAtIndexPath:)]) {
        [self.delegate interactiveChatCellDidCopyAtIndexPath:self.indexPath];
    }
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    if (editing) {
        [self buildEidtingFrame];
    }
    else {
        editingFrame = CGRectZero;
    }
    [super setEditing:editing animated:animated];
}
#pragma mark - TTTAttributedLabel delegate methods
- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithURL:(NSURL *)url {
    if (self.delegate && [self.delegate respondsToSelector:@selector(interactiveChatCellDidClickURL:AtIndexPath:)]) {
        [self.delegate interactiveChatCellDidClickURL:url AtIndexPath:self.indexPath];
    }
}

#pragma mark - publice methods
- (void)commitInit {
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    //long press recognizer need subclass to determine which view should be add, not do add action here
    _longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressHandler:)];
    
    UITapGestureRecognizer *avatarTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(avatarTapHandler:)];
    _avatarImgView = [[UIImageView alloc] initWithFrame:CGRectZero];
    self.avatarImgView.userInteractionEnabled = YES;
    [self.avatarImgView addGestureRecognizer:avatarTap];
    
    UITapGestureRecognizer *editingTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(editingTapHandler:)];
    _editingView = [[UIImageView alloc] initWithFrame:CGRectZero];
    self.editingView.userInteractionEnabled = YES;
    self.editingView.image = [UIImage imageNamed:@"btn_point_marquee_select_contacts_normal"];
    [self.editingView addGestureRecognizer:editingTap];
    
    _nicknameLabel = [[TTTAttributedLabel alloc] initWithFrame:CGRectZero];
    self.nicknameLabel.delegate = self;
    self.nicknameLabel.font = FFFontContent;
    self.nicknameLabel.textColor = FFColorContent;
    self.nicknameLabel.linkAttributes = @{NSForegroundColorAttributeName:FFColorContent};
    _sendingIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectZero];
    self.sendingIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
    _errorImgView = [[UIImageView alloc] initWithFrame:CGRectZero];
    
    [self.contentView addSubview:self.avatarImgView];
    [self.contentView addSubview:self.editingView];
    [self.contentView addSubview:self.nicknameLabel];
    [self.contentView addSubview:self.sendingIndicator];
    [self.contentView addSubview:self.errorImgView];
    
    _bubbleMyself = [UIImage imageNamed:@"BubbleMyself"];
    _bubbleOther = [UIImage imageNamed:@"BubbleOther"];
    
    self.contentView.backgroundColor = FFColorBackgroud;
}

- (void)longPressHandler:(UILongPressGestureRecognizer *)sender {
    
    if (sender.state != UIGestureRecognizerStateBegan) return;
    
    [self becomeFirstResponder];
    
    UIMenuItem *relay = [[UIMenuItem alloc] initWithTitle:@"Relay" action:@selector(relay:)];
    UIMenuItem *upload = [[UIMenuItem alloc] initWithTitle:@"Upload" action:@selector(upload:)];
    UIMenuItem *collect = [[UIMenuItem alloc] initWithTitle:@"Collect" action:@selector(collect:)];
    UIMenuItem *more = [[UIMenuItem alloc] initWithTitle:@"More" action:@selector(more:)];
    
    
    UIMenuController *menu = [UIMenuController sharedMenuController];
    [menu setMenuItems:[NSArray arrayWithObjects:relay, upload, collect, more, nil]];
    
    [menu setTargetRect:self.menuTargetView.frame inView:self];
    [menu setMenuVisible:YES animated:YES];
}

- (void)buildEidtingFrame {
    editingFrame = CGRectMake(FFCellPadding, FFCellPadding, FFCellEditingEdgeLength, FFCellEditingEdgeLength);
}

- (void)buildMyselfAvatarFrame {
    //avatar frame
    avatareFrame = CGRectMake(FFScreenW - FFCellPadding - FFAvatarEdgeLength,
                              FFCellPadding, FFAvatarEdgeLength, FFAvatarEdgeLength);
}

- (CGSize)buildMyselfNicknameFrame {
    //nickname frame
    CGSize nicknameSize = CGSizeZero;
    if (self.isShowNickname) {
        self.nicknameLabel.textAlignment = NSTextAlignmentRight;
        nicknameSize = [self getNicknameSize];
        
        nicknameFrame = CGRectMake(FFScreenW - FFAvatarEdgeLength - 2 * FFCellPadding - nicknameSize.width - FFBubbleArrowWidth,
                                   FFCellPadding, nicknameSize.width, nicknameSize.height);
    } else {
        nicknameFrame = CGRectZero;
    }
    return nicknameSize;
}

- (void)buildOtherAvatarFrame {
    
    avatareFrame = CGRectMake(FFCellPadding, FFCellPadding, FFAvatarEdgeLength, FFAvatarEdgeLength);
    if (self.isEditing) avatareFrame = CGRectMake(avatareFrame.origin.x + FFCellEditingEdgeLength + FFCellPadding, FFCellPadding, FFAvatarEdgeLength, FFAvatarEdgeLength);
  
}

- (CGSize)buildOtherNicknameFrame {
    //nickname frame
    CGSize nicknameSize = CGSizeZero;
    if (self.isShowNickname) {
        self.nicknameLabel.textAlignment = NSTextAlignmentRight;
        nicknameSize = [self getNicknameSize];
        
        nicknameFrame = CGRectMake(FFAvatarEdgeLength + 2 * FFCellPadding + FFBubbleArrowWidth,
                                   FFCellPadding, nicknameSize.width, nicknameSize.height);
        if (self.isEditing) nicknameFrame = CGRectMake(nicknameFrame.origin.x + FFCellEditingEdgeLength + FFCellPadding, nicknameFrame.origin.y, nicknameFrame.size.width, nicknameFrame.size.height);
    } else {
        nicknameFrame = CGRectZero;
    }
    return nicknameSize;
}

- (CGSize)getNicknameSize {
    CGSize result = [TTTAttributedLabel sizeThatFitsAttributedString:self.nicknameLabel.attributedText withConstraints:CGSizeMake(FFScreenW - FFAvatarEdgeLength - 2 * FFCellPadding, 99999) limitedToNumberOfLines:99999];
    result = CGSizeMake(ceil(result.width), ceil(result.height));
    
    return result;
}

#pragma mark - private methods
- (void)relay:(id)sender {
    [self throwWarningIfNeeded];
    if (self.delegate && [self.delegate respondsToSelector:@selector(interactiveChatCellDidRelayAtIndexPath:)]) {
        [self.delegate interactiveChatCellDidRelayAtIndexPath:self.indexPath];
    }
}

- (void)collect:(id)sender {
    [self throwWarningIfNeeded];
    if (self.delegate && [self.delegate respondsToSelector:@selector(interactiveChatCellDidCollectAtIndexPath:)]) {
        [self.delegate interactiveChatCellDidCollectAtIndexPath:self.indexPath];
    }
}

- (void)more:(id)sender {
    [self throwWarningIfNeeded];
    if (self.delegate && [self.delegate respondsToSelector:@selector(interactiveChatCellDidClickMoreAtIndexPath:)]) {
        [self.delegate interactiveChatCellDidClickMoreAtIndexPath:self.indexPath];
    }
}

- (void)throwWarningIfNeeded {
    if (!self.indexPath) {
        NSLog(@"you must set indexPath a non nil value when use it!!!");
    }
}

#pragma mark - public methods
- (void)upload:(id)sender {
    [self throwWarningIfNeeded];
    if (self.delegate && [self.delegate respondsToSelector:@selector(interactiveChatCellDidUploadAtIndexPath:)]) {
        [self.delegate interactiveChatCellDidUploadAtIndexPath:self.indexPath];
    }
}

- (void)avatarTapHandler:(UITapGestureRecognizer *)sender {
    [self throwWarningIfNeeded];
    if (self.delegate && [self.delegate respondsToSelector:@selector(interactiveChatCellDidClickAvatarAtIndexPath:)]) {
        [self.delegate interactiveChatCellDidClickAvatarAtIndexPath:self.indexPath];
    }
}

- (void)editingTapHandler:(UITapGestureRecognizer *)sender {
    [self throwWarningIfNeeded];
    if (!self.isMultEditingSelected && self.delegate && [self.delegate respondsToSelector:@selector(interactiveChatCellDidMutlEditingSelectedAtIndexPath:)]) {
        self.isMultEditingSelected = YES;
        self.editingView.image = [UIImage imageNamed:@"btn_point_marquee_select_contacts_selected"];
        [self.delegate interactiveChatCellDidMutlEditingSelectedAtIndexPath:self.indexPath];
    }
    else if (self.isMultEditingSelected && self.delegate && [self.delegate respondsToSelector:@selector(interactiveChatCellDidMutlEditingDisselectedAtIndexPath:)]) {
        self.isMultEditingSelected = NO;
        self.editingView.image = [UIImage imageNamed:@"btn_point_marquee_select_contacts_normal"];
        [self.delegate interactiveChatCellDidMutlEditingDisselectedAtIndexPath:self.indexPath];
    }
}

- (void)UIPrepareForSendingDataStatus {
    NSLog(@"super void implement, you must override this method!!");
}

- (void)UIPrepareForCreateStatus; {
    NSLog(@"super void implement, you must override this method!!");
}

- (void)UIPrepareForNormalStatus {
    NSLog(@"super void implement, you must override this method!!");
}

- (void)UIPrepareForErrorStatus {
    NSLog(@"super void implement, you must override this method!!");
}

- (CGFloat)getHeight {
    NSLog(@"super void implement, you must override this method!!");
    return 0;
}
@end
