//
//  VisualStickView.m
//  SampleGame
//
//  Created by Zhang Xiang on 13-4-26.
//  Copyright (c) 2013年 Myst. All rights reserved.
//

#import "JoyStickView.h"

#define STICK_CENTER_TARGET_POS_LEN 20.0f

@implementation JoyStickView

-(void) initStick
{
    imgStickNormal = [UIImage imageNamed:@"stick_normal.png"];
    imgStickHold = [UIImage imageNamed:@"stick_hold.png"];
//    stickView.image = imgStickNormal;
    stickOrigin = CGPointMake(128.0, 128.0);
    mCenter.x = 128;
    mCenter.y = 128;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self initStick];
    }
    return self;
}


- (id)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self)
	{
        // Initialization code
        [self initStick];
    }
	
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)notifyDir:(CGPoint)dir
{
  [self->delegate joystick:self didMoveToX:[NSNumber numberWithFloat:dir.x] andY:[NSNumber numberWithFloat:dir.y]];
}

- (void)stickMoveTo:(CGPoint)deltaToCenter
{
    CGRect fr = stickView.frame;
    fr.origin.x = deltaToCenter.x - 64;
    fr.origin.y = deltaToCenter.y - 64;
    stickView.frame = fr;
}

- (void)touchEvent:(NSSet *)touches
{

    if([touches count] != 1)
        return ;
    
    UITouch *touch = [touches anyObject];
    UIView *view = [touch view];
    if(view != self)
        return ;
    
    CGPoint touchPoint = [touch locationInView:view];
    CGPoint dtarget, dir;
    dir.x = touchPoint.x - (self.frame.size.width / 2);
    dir.y = touchPoint.y - (self.frame.size.height / 2);
    double len = sqrt(dir.x * dir.x + dir.y * dir.y);
    if(len < 2.0 && len > -2.0)
    {
        // center pos
        dtarget.x = 0.0;
        dtarget.y = 0.0;
        dir.x = 0;
        dir.y = 0;
    }
    else
    {
        dtarget.x = touchPoint.x;
        dtarget.y = touchPoint.y;
    }
    [self stickMoveTo:dtarget];
    
    [self notifyDir:dir];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    stickView.image = imgStickHold;
    [self touchEvent:touches];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self touchEvent:touches];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    stickView.image = imgStickNormal;
    CGPoint dtarget, dir;
    dir.x = dtarget.x = 0.0;
    dir.y = dtarget.y = 0.0;
    [self stickMoveTo:stickOrigin];
    
    [self notifyDir:dir];
}

@end
