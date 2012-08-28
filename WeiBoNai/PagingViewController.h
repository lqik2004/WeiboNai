//
//  PagingViewController.h
//
//  WeiBoNai
//
//  Created by liuchao on 8/5/12.
//  Copyright (c) 2012 liuchao. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PagingViewController : UIViewController<UISplitViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIButton *girlsName;
- (IBAction)pre:(id)sender;
- (IBAction)next:(id)sender;

- (IBAction)openWeiboUserUrl:(id)sender;
- (IBAction)like:(id)sender;
- (IBAction)openWeiboComment:(id)sender;
- (IBAction)shudong:(id)sender;

@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet UIButton *closeBtn;
- (IBAction)closeWebView:(id)sender;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *likeBtn;
@end
