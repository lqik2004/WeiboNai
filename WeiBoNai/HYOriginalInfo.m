//
//  HYOriginalInfo.m
//  WeiBoNai
//
//  Created by liuchao on 8/5/12.
//  Copyright (c) 2012 liuchao. All rights reserved.
//

#import "HYOriginalInfo.h"
#import "RegexKitLite.h"
#import "URlEncode.h"

@implementation HYOriginalInfo

-(NSMutableArray*) fetchMetaInfowithPage:(NSUInteger) pageNum{
    NSMutableArray *muArray=[NSMutableArray arrayWithCapacity:0];
    NSError *error;
    NSString *dataurlString=[NSString stringWithFormat:@"http://www.weibonai.com/page/%d",pageNum];
    NSString *data=[NSString stringWithContentsOfURL:[NSURL URLWithString:dataurlString] encoding:NSUTF8StringEncoding error:&error];
    NSString *rex=@"<article\\s*id=\"post[^\"]*\"[^>]*>([\\s\\S]+?)</article>";
    NSArray *rArray=[data arrayOfCaptureComponentsMatchedByRegex:rex];
    if(rArray){
        for(NSArray *s in rArray){
            NSString *data=[s objectAtIndex:1];
            NSString *titleRex=@"<h1\\s*class=\"entry-title\">\\s*<[^>]*>([\\s\\S]*?)</a>[\\s\\S]*?<div\\s* class=\"entry-content\">\\s*<p>\\s*<a\\s*href=\"([^\"]*)\">\\s*<img\\s*src=\"([^\"]*)\"[^>]*>";
            NSString *title=[data stringByMatching:titleRex capture:1];
            NSString *weiboOriginal=[data stringByMatching:titleRex capture:2];
            NSString *imageUrl=[data stringByMatching:titleRex capture:3];
            NSString *encodeURl=[URlEncode modifiedEncodeToPercentEscapeString:imageUrl];
            NSString *useridRex=@"/([0-9]+)/";
            NSString *userid=[weiboOriginal stringByMatching:useridRex capture:1];
            NSString *userURL=[[NSString alloc] initWithFormat:@"http://www.weibo.com/%@",userid];
            
            NSLog(@"%@\n%@\n%@\n%@\n%@\n%@",title,weiboOriginal,imageUrl,encodeURl,userid,userURL);
            if(title&&weiboOriginal&&imageUrl&&encodeURl)
            [muArray addObject:@{@"title":title,@"weiboOriginal":weiboOriginal,@"imageUrl":encodeURl,@"page":[NSNumber numberWithInteger:pageNum],@"userURL":userURL,@"isLike":@"NO"}];
        }
    }
    return muArray;
}

-(NSMutableArray*)fetchAllInfo{
    NSUInteger pageNum=1;
    BOOL isEnd=NO;
    NSMutableArray *muArray=[NSMutableArray arrayWithCapacity:0];
    NSError *error;
    while (!isEnd) {
        NSString *dataurlString=[NSString stringWithFormat:@"http://www.weibonai.com/page/%d",pageNum];
        NSString *data=[NSString stringWithContentsOfURL:[NSURL URLWithString:dataurlString] encoding:NSUTF8StringEncoding error:&error];
        NSString *rex=@"<article\\s*id=\"post[^\"]*\"[^>]*>([\\s\\S]+?)</article>";
        NSArray *rArray=[data arrayOfCaptureComponentsMatchedByRegex:rex];
        if(rArray){
            for(NSArray *s in rArray){
                NSString *data=[s objectAtIndex:1];
                NSString *titleRex=@"<h1\\s*class=\"entry-title\">\\s*<[^>]*>([\\s\\S]*?)</a>[\\s\\S]*?<div\\s* class=\"entry-content\">\\s*<p>\\s*<a\\s*href=\"([^\"]*)\">\\s*<img\\s*src=\"([^\"]*)\"[^>]*>";
                NSString *title=[data stringByMatching:titleRex capture:1];
                NSString *weiboOriginal=[data stringByMatching:titleRex capture:2];
                NSString *imageUrl=[data stringByMatching:titleRex capture:3];
                NSString *encodeURl=[URlEncode modifiedEncodeToPercentEscapeString:imageUrl];
                NSLog(@"%@\n%@\n%@\n%@",title,weiboOriginal,imageUrl,encodeURl);
                if(title&&weiboOriginal&&imageUrl&&encodeURl)
                    [muArray addObject:@{@"title":title,@"weiboOriginal":weiboOriginal,@"imageUrl":encodeURl}];
            }
        }else{
            isEnd=YES;
        }
        pageNum++;
    }
    return muArray;
}
@end
