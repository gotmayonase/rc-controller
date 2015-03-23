//
//  VisualStickView.h
//  SampleGame
//
//  Created by Zhang Xiang on 13-4-26.
//  Copyright (c) 2013年 Myst. All rights reserved.
//

#import <UIKit/UIKit.h>
@class JoyStickView;

@protocol JoystickDelegate <NSObject>

-(void)joystick:(JoyStickView *)stick didMoveToX:(NSNumber *)x andY: (NSNumber *)y;

@end

@interface JoyStickView : UIView
{
    IBOutlet UIImageView *stickViewBase;
    IBOutlet UIImageView *stickView;
  IBOutlet NSObject<JoystickDelegate> *delegate;
    
    UIImage *imgStickNormal;
    UIImage *imgStickHold;
    
    CGPoint mCenter;
    CGPoint stickOrigin;
}

@end
