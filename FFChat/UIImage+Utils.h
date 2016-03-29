//
//  UIImage+Utils.h
//  ImageBubble
//
//  Created by Richard Kirby on 3/14/13.
//  Copyright (c) 2013 Kirby. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Utils)

- (UIImage *) renderAtSize:(const CGSize) size;
- (UIImage *) renderAtAphla:(const float) alpha;
- (UIImage *) maskWithImage:(const UIImage *) maskImage;
- (UIImage *) maskWithColor:(UIColor *) color;
- (UIImage *)rotateImage:(const UIImage *)aImage;

//颜色转图片
+ (UIImage *) imageWithColor:(UIColor *) color;
@end
