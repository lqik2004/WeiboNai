//
//  PagingViewController.m
//
//  WeiBoNai
//
//  Created by liuchao on 8/5/12.
//  Copyright (c) 2012 liuchao. All rights reserved.
//

#import "PagingViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "HYOriginalInfo.h"
#import <dispatch/dispatch.h>
#import "LCMagnifierView.h"

@interface PagingViewController() 

@end

@implementation PagingViewController
{
    NSInteger currentImage;
    NSInteger currentPage;
    //判断是否全部读完
    BOOL isEnd;
    dispatch_queue_t preLoadingQueue;
    NSMutableArray *data;
    NSMutableDictionary *likeDict;
    //loup
    LCMagnifierView *_loupeView;
}
@synthesize likeBtn;
@synthesize webView;
@synthesize closeBtn;


@synthesize imageView;
@synthesize girlsName;


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    data=[NSMutableArray arrayWithCapacity:0];
    isEnd=NO;
    //reading likeDict
    likeDict=[NSMutableDictionary dictionaryWithCapacity:1];
    likeDict=[[[NSUserDefaults standardUserDefaults] objectForKey:@"likeDict"] mutableCopy];
    if(likeDict){
    //update like Button
    [self updateLikeBtnImageNumber:currentImage];
    }
    //loading newest data
    [self loadingDatawithPage:1];
    currentImage=0;
    currentPage=1;
    NSString *urlString=[[data objectAtIndex:0] objectForKey:@"imageUrl"];
    [imageView setImageWithURL:[NSURL URLWithString:urlString] placeholderImage:[UIImage imageNamed:@"placeholder.png"]];
    imageView.contentMode=UIViewContentModeScaleAspectFit;
    [self.view addSubview:imageView];
    
    /////name
    [self settingGirlTitle];
    [self.view addSubview:girlsName];
    //hide webview
    [self.webView setHidden:YES];
    //hide closebutton
    [self.closeBtn setHidden:YES];
    //set likebutton
    NSString *weiboOriginal=[[data objectAtIndex:currentImage] objectForKey:@"weiboOriginal"];
    if([likeDict objectForKey:weiboOriginal]){
        [self.likeBtn setTintColor:[UIColor redColor]];
    }else{
        [self.likeBtn setTintColor:[UIColor blueColor]];
    }
       //add longpress touch recognizer
    UILongPressGestureRecognizer *recognizer;
	recognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self
                                                                action:@selector(_longPressHandler:)];
	[self.view addGestureRecognizer:recognizer];

}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

#pragma mark -Custom Methods
-(void) loadingDatawithPage:(NSUInteger) pageNum{
    if(!isEnd){
        HYOriginalInfo *info=[HYOriginalInfo new];
        NSArray *array=[info fetchMetaInfowithPage:pageNum];
        if(array){
            [data addObjectsFromArray:array];
            for(NSDictionary *dic in array){
                NSString *urlString=[dic objectForKey:@"imageUrl"];
                SDWebImageManager *manager = [SDWebImageManager sharedManager];
                [manager downloadWithURL:[NSURL URLWithString:urlString]
                                delegate:self
                                 options:0
                                 success:nil failure:nil];
            }

        }else{
            isEnd=YES;
        }
    }
}
-(void) updateLikeBtnImageNumber:(NSUInteger) num{
    NSString *weiboOriginal=[[data objectAtIndex:num] objectForKey:@"weiboOriginal"];
    if([likeDict objectForKey:weiboOriginal]){
        [self.likeBtn setTintColor:[UIColor redColor]];
    }else{
        [self.likeBtn setTintColor:[UIColor blueColor]];
    }
}
- (IBAction)pre:(id)sender {
    if(currentImage>0){
        currentImage--;
        NSString *urlString=[[data objectAtIndex:currentImage] objectForKey:@"imageUrl"];
        [imageView setImageWithURL:[NSURL URLWithString:urlString] placeholderImage:[UIImage imageNamed:@"placeholder.png"]];
        [self updateInfo];
    }
    else{
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"提示" message:@"这已经是最新的一张了" delegate:nil cancelButtonTitle:@"知道了" otherButtonTitles:nil];
        [alert show];
    }

}

- (IBAction)next:(id)sender {
    if(currentImage<data.count-1){
    currentImage++;
    if(currentImage<data.count){
        NSString *urlString=[[data objectAtIndex:currentImage] objectForKey:@"imageUrl"];
        [imageView setImageWithURL:[NSURL URLWithString:urlString] placeholderImage:[UIImage imageNamed:@"placeholder.png"]];
        [self updateInfo];
    }
    if(data.count-currentImage==3&&!isEnd){
        self->preLoadingQueue=dispatch_queue_create("com.res0w.weibonai.preload", NULL);
        dispatch_async(preLoadingQueue, ^{
            currentPage++;
            [self loadingDatawithPage:currentPage];
        });
        dispatch_release(preLoadingQueue);
    }}
}

- (IBAction)openWeiboUserUrl:(id)sender {
    NSString *userURL=[[data objectAtIndex:currentImage] objectForKey:@"userURL"];
    NSURLRequest *request=[[NSURLRequest alloc] initWithURL:[NSURL URLWithString:userURL]];
    [webView loadRequest:request];
    [self.view bringSubviewToFront:webView];
    [self.webView setHidden:NO];
    [self.closeBtn setHidden:NO];
    [self.view bringSubviewToFront:self.closeBtn];
}

- (IBAction)like:(id)sender {
    NSString *weiboOriginal=[[data objectAtIndex:currentImage] objectForKey:@"weiboOriginal"];
    if([likeDict objectForKey:weiboOriginal]){
        NSLog(@"xihuan");
        [likeDict removeObjectForKey:weiboOriginal];
        [[NSUserDefaults standardUserDefaults] setObject:likeDict forKey:@"likeDict"];
        [self.likeBtn setTintColor:[UIColor blueColor]];
    }else{
        NSLog(@"buxihuan");
        [likeDict setObject:@"YES" forKey:weiboOriginal];
        [[NSUserDefaults standardUserDefaults] setObject:likeDict forKey:@"likeDict"];
        [self.likeBtn setTintColor:[UIColor redColor]];
    }
}

- (IBAction)openWeiboComment:(id)sender {
    NSString *userURL=[[data objectAtIndex:currentImage] objectForKey:@"weiboOriginal"];
    NSURLRequest *request=[[NSURLRequest alloc] initWithURL:[NSURL URLWithString:userURL]];
    [webView loadRequest:request];
    [self.view bringSubviewToFront:webView];
    [self.webView setHidden:NO];
    [self.closeBtn setHidden:NO];
    [self.view bringSubviewToFront:self.closeBtn];
}

- (IBAction)shudong:(id)sender {
    
}

-(void) updateInfo{
    [self settingGirlTitle];
    [self updateLikeBtnImageNumber:currentImage];
}

-(void) settingGirlTitle{
    NSString *name=[[data objectAtIndex:currentImage] objectForKey:@"title"];
    [girlsName setTitle:name forState:UIControlStateNormal];
}

- (void)viewDidUnload {
    [self setImageView:nil];
    [self setGirlsName:nil];
    [self setWebView:nil];
    [self setLikeBtn:nil];
    [self setCloseBtn:nil];
    [super viewDidUnload];
}
- (IBAction)closeWebView:(id)sender {
    [self.webView setHidden:YES];
    [self.closeBtn setHidden:YES];
}


#pragma mark -Touch Event Methods
-(void)_longPressHandler:(UILongPressGestureRecognizer *)touch{
    if (touch.state == UIGestureRecognizerStateBegan ||
		touch.state == UIGestureRecognizerStateChanged) {
        CGPoint aPoint=[touch locationInView:self.view];
        if(!_loupeView){
            
            _loupeView = [[LCMagnifierView alloc] init];
            [_loupeView setViewToMagnify:self.view];
            [_loupeView setTouchPoint:aPoint];
            [self.view addSubview:_loupeView];
            [_loupeView setNeedsDisplay];
            
        }else{
            [_loupeView setTouchPoint:aPoint];
            [_loupeView setNeedsDisplay];
        }
    }
    else {
        NSLog(@"else");
    }
    if (touch.state == UIGestureRecognizerStateRecognized) {
        NSLog(@"end");
        [_loupeView removeFromSuperview];
		_loupeView = nil;
    }
}


@end
