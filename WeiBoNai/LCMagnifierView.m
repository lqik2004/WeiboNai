//
//  MagnifierView.m
//  LiuChao
//

#import "LCMagnifierView.h"
#import <QuartzCore/QuartzCore.h>

#define iPadHeight 200
#define iPhoneHeight 80

@implementation LCMagnifierView{
    CGFloat height;
}
@synthesize viewToMagnify, touchPoint;

- (id)initWithFrame:(CGRect)frame {
    [self magnifierHeight];
	if (self = [super initWithFrame:CGRectMake(0, 0, height, height)]) {
		// make the circle-shape outline with a nice border.
		self.layer.borderColor = [[UIColor lightGrayColor] CGColor];
		self.layer.borderWidth = 3;
		self.layer.cornerRadius = (height)/2;
		self.layer.masksToBounds = YES;
        self.layer.anchorPoint=CGPointMake(0.5, 0.5);
	}
	return self;
}

- (void)setTouchPoint:(CGPoint)pt {
	touchPoint = pt;
	// whenever touchPoint is set, 
	// update the position of the magnifier (to just above what's being magnified)
    //接近屏幕顶端
    if(height*3/2>=pt.y){
        self.center = CGPointMake(pt.x-height, pt.y);
    }else{
        self.center = CGPointMake(pt.x, pt.y-height);
    }
}

- (void)drawRect:(CGRect)rect {
	// here we're just doing some transforms on the view we're magnifying,
	// and rendering that view directly into this view,
	// rather than the previous method of copying an image.
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextTranslateCTM(context,1*(self.frame.size.width*0.5),1*(self.frame.size.height*0.5));
	CGContextScaleCTM(context, 1.5, 1.5);
	CGContextTranslateCTM(context,-1*(touchPoint.x),-1*(touchPoint.y));
	[self.viewToMagnify.layer renderInContext:context];
}

-(void) magnifierHeight{
    //iPad
    if([UIDevice currentDevice].userInterfaceIdiom==UIUserInterfaceIdiomPad){
        height=iPadHeight;
    }else if ([UIDevice currentDevice].userInterfaceIdiom==UIUserInterfaceIdiomPhone){
        height=iPhoneHeight;
    }else{
        //现在就两种设备，这语句几乎不会执行
        height=iPhoneHeight;
    }
}


@end
