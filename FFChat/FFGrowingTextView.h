//
//  FFGrowingTextView.h
//  EduChat
//
//  Created by apple on 11/11/15.
//  Copyright © 2015 FF. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FFInteractiveChatCell.h"


@interface FFGrowingTextView : UITextView

- (void)setLineNumberToStopGrowing:(NSInteger)number;

- (CGFloat)getHeightConstraint;

- (CGFloat)getMaxHeight;

@end
