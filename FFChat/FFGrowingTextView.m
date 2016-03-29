//
//  FFGrowingTextView.m
//  EduChat
//
//  Created by apple on 11/11/15.
//  Copyright © 2015 FF. All rights reserved.
//

#import "FFGrowingTextView.h"

@interface FFGrowingTextView ()

@property (assign, nonatomic) CGFloat maxNumberOfLinesToDisplay;
@property (assign, nonatomic) CGFloat initialHeight;

@end

@implementation FFGrowingTextView

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self commenInit];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self commenInit];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if (self.contentSize.height < [self getMaxHeight]) {
        self.contentOffset = CGPointZero;
    }
}

- (void)scrollRectToVisible:(CGRect)rect animated:(BOOL)animated {
    
}

- (void)scrollRangeToVisible:(NSRange)range {
    
}
#pragma mark -- public method
- (CGFloat)getHeightConstraint {
    CGSize size = [self sizeThatFits:CGSizeMake(self.bounds.size.width, 9999.f)];
    
    if (size.height > [self getMaxHeight]) {
        self.showsVerticalScrollIndicator = YES;
        self.contentOffset = CGPointMake(0, self.contentSize.height - self.frame.size.height);
        return [self getMaxHeight];
    } else {
        self.showsVerticalScrollIndicator = NO;
        return size.height;
    }
}

- (CGFloat)getMaxHeight {
    CGFloat buffer = self.font.lineHeight / 4.0f;
    return self.initialHeight + self.font.lineHeight * (self.maxNumberOfLinesToDisplay - 1) + buffer;
}

#pragma mark -- private methods
- (void)commenInit {
    self.initialHeight = [self calculateInitialHeight];
    self.maxNumberOfLinesToDisplay = 4;
    //Apple said The default is NO. Do not believe it!!!
    self.layoutManager.allowsNonContiguousLayout = NO;
    self.textColor = FFColorContent;
    self.backgroundColor = FFColorBackgroud;
    self.layer.borderColor = FFColorContent.CGColor;
    
    self.layer.borderWidth = .5;
    
    self.layer.cornerRadius = 5.0;
}

- (void)setLineNumberToStopGrowing:(NSInteger)number {
    _maxNumberOfLinesToDisplay = number;
    _initialHeight = [self calculateInitialHeight];
}

- (CGFloat)calculateInitialHeight {
    NSString *text = self.text;
    self.text = @" ";
    CGSize size = [self sizeThatFits:CGSizeMake(self.bounds.size.width, 9999.0)];
    self.text = text;
    return size.height;
}



@end
