//
//  MagnifierView.h
//  LiuChao
//

#import <UIKit/UIKit.h>

@interface LCMagnifierView : UIView 
@property (nonatomic, strong) UIView *viewToMagnify;
@property (nonatomic) CGPoint touchPoint;

@end