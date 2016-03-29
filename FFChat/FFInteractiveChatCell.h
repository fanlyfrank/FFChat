//
//  FFInteractiveChatCell.h
//  EduChat
//
//  Created by apple on 11/17/15.
//  Copyright © 2015 FF. All rights reserved.
//
//  Super chat cell.
//  In message model, All chat cell can interactive with user must inherit from this class.
//  Edit by Fanly

#import <UIKit/UIKit.h>
#import "TTTAttributedLabel.h"

#define FFCellEditingEdgeLength 20
#define FFCellPadding 10
#define FFAvatarEdgeLength 40
#define FFIndicatorWidth 20
#define FFContentUpDownPadding 5
#define FFContentLeftRightPaddingMax 25
#define FFBubbleArrowWidth 10
#define FFContentLeftRightPaddingMin 15
#define FFErrorEdgeLength 20

#define FFFontBody [UIFont preferredFontForTextStyle:UIFontTextStyleBody]            //正常大小
#define FFFontContent [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline] //文本大小
#define FFFontMin [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote]         //迷你

#define FFColorMain FFRGBColor(90,136, 231)                   //主调色
#define FFColorBackgroud FFRGBColor(245,245,245)             //背景色
#define FFColorSeparator FFRGBColor(221,221,221)             //分割线色

#define FFColorBody FFRGBColor(51,51, 51)                     //正常文本色
#define FFColorContent FFRGBColor(102,102,102)               //内容文本色
#define FFColorSecondary FFRGBColor(153,153,153)             //次要辅助色
#define FFColorHighlight FFRGBColor(60,93, 161)               //按钮高亮色

#define FFRGBColor(r, g, b) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:1.0]// RGB色

#define FFScreenW [UIScreen mainScreen].bounds.size.width
#define FFScreenH [UIScreen mainScreen].bounds.size.height

typedef NS_ENUM(NSInteger, FFChatCellUserType) {
    FFChatCellUserTypeMyself,
    FFChatCellUserTypeOther,
};

typedef NS_ENUM(NSInteger, FFChatCellStatus) {
    FFChatCellStatusNormal,
    FFChatCellStatusSending,
    FFChatCellStatusError,
};

@class FFInteractiveChatCell;

@protocol FFInteractiveChatCellDelegate <NSObject>

@required
- (void)interactiveChatCellDidRelayAtIndexPath:(NSIndexPath *)indexPath;
- (void)interactiveChatCellDidCopyAtIndexPath:(NSIndexPath *)indexPath;
- (void)interactiveChatCellDidCollectAtIndexPath:(NSIndexPath *)indexPath;
- (void)interactiveChatCellDidClickMoreAtIndexPath:(NSIndexPath *)indexPath;
- (void)interactiveChatCellDidMutlEditingSelectedAtIndexPath:(NSIndexPath *)indexPath;
- (void)interactiveChatCellDidMutlEditingDisselectedAtIndexPath:(NSIndexPath *)indexPath;

@optional
- (void)interactiveChatCellDidUploadAtIndexPath:(NSIndexPath *)indexPath;
- (void)interactiveChatCellDidClickAvatarAtIndexPath:(NSIndexPath *)indexPath;
- (void)interactiveChatCellDidClickContentAtIndexPath:(NSIndexPath *)indexPath;
- (void)interactiveChatCellDidClickURL:(NSURL *)url AtIndexPath:(NSIndexPath *)indexPath;

@end

@interface FFInteractiveChatCell : UITableViewCell <TTTAttributedLabelDelegate> {
        CGRect avatareFrame, nicknameFrame, sendingFrame, errorFrame, editingFrame;
}

@property (strong, nonatomic) UILongPressGestureRecognizer *longPress;

@property (strong, nonatomic) UIActivityIndicatorView *sendingIndicator;
@property (strong, nonatomic) UIImageView *errorImgView;

@property (strong, nonatomic) UIImage *bubbleMyself;
@property (strong, nonatomic) UIImage *bubbleOther;

//define where the uimenuview can display
@property (strong, nonatomic) UIView *menuTargetView;

//define which cell is interactive with user.
//in your tableviewcontroller, you need indexPath to find out which data need process.
@property (strong, nonatomic) NSIndexPath *indexPath;

@property (nonatomic) BOOL isShowNickname;

@property (nonatomic) BOOL isMultEditingSelected;

@property (nonatomic) FFChatCellUserType userType;

@property (nonatomic) FFChatCellStatus status;

@property (weak, nonatomic) id<FFInteractiveChatCellDelegate> delegate;

//views proteries
@property (strong, nonatomic) UIImageView *avatarImgView;
@property (strong, nonatomic) UIImageView *editingView;
@property (strong, nonatomic) TTTAttributedLabel *nicknameLabel;

- (void)commitInit;
//why thos methods are public?
//custom subclass can invoke directly
- (void)longPressHandler:(UILongPressGestureRecognizer *)sender;

- (void)buildMyselfAvatarFrame;
- (CGSize)buildMyselfNicknameFrame;

- (void)buildOtherAvatarFrame;
- (CGSize)buildOtherNicknameFrame;

- (CGSize)getNicknameSize;

//sometimes you want add your gesture recognizer, so you need remove super calss's.
- (void)upload:(id)sender;

//subclass need to override those methods
- (void)UIPrepareForSendingDataStatus;
- (void)UIPrepareForCreateStatus;
- (void)UIPrepareForNormalStatus;
- (void)UIPrepareForErrorStatus;
- (CGFloat)getHeight;

@end
