//
//  MDBrowser.m
//  MDBrowser
//
//  Created by Mohammed Eldehairy on 12/13/13.
//  Copyright (c) 2013 Mohammed Eldehairy. All rights reserved.
//

#import "MDBrowser.h"

@implementation MDBrowser

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        browser = [[UIWebView alloc] initWithFrame:CGRectMake(0,0, frame.size.width-20, frame.size.height-50)];
        
        self.clipsToBounds = NO;
        ContainerView = [[UIView alloc] initWithFrame:CGRectMake(10,5, frame.size.width-20, frame.size.height-5)];
        [self addSubview:ContainerView];
        ContainerView.layer.cornerRadius = 10;
        ContainerView.clipsToBounds = YES;
        
        UIButton *closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [closeBtn setImage:[UIImage imageNamed:@"close.png"] forState:UIControlStateNormal];
        closeBtn.frame = CGRectMake(0, -5, 35, 35);
        [closeBtn addTarget:self action:@selector(CancelLoginAction:) forControlEvents:UIControlEventTouchUpInside];
        
        [self addSubview:closeBtn];
        
        
        browser.delegate = self;
        browser.scalesPageToFit = YES;
        
        ContainerView.layer.borderColor = [UIColor lightGrayColor].CGColor;
        ContainerView.layer.borderWidth = 5;
        [ContainerView addSubview:browser];
        
        buttonsView = [[UIView alloc] initWithFrame:CGRectMake(0, browser.frame.size.height, frame.size.width, 50)];
        buttonsView.backgroundColor = [UIColor colorWithRed:(241.0f/255.0f) green:(241.0f/255.0f) blue:(241.0f/255.0f) alpha:1.0];
        [ContainerView addSubview:buttonsView];
        
        
        
        
        UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        backBtn.frame = CGRectMake(0, 0, ContainerView.frame.size.width/2, 50);
        
        [backBtn setImage:[UIImage imageNamed:@"back.png"] forState:UIControlStateNormal];
        [backBtn setImage:[UIImage imageNamed:@"back_active.png"] forState:UIControlStateHighlighted];
        [backBtn addTarget:self action:@selector(BackAction:) forControlEvents:UIControlEventTouchUpInside];
        [buttonsView addSubview:backBtn];
        
        UIButton *forwardBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        forwardBtn.frame = CGRectMake(ContainerView.frame.size.width/2, 0, ContainerView.frame.size.width/2, 50);
        [forwardBtn addTarget:self action:@selector(ForwardAction:) forControlEvents:UIControlEventTouchUpInside];
        [forwardBtn setImage:[UIImage imageNamed:@"next.png"] forState:UIControlStateNormal];
        [forwardBtn setImage:[UIImage imageNamed:@"next_active.png"] forState:UIControlStateHighlighted];
        [buttonsView addSubview:forwardBtn];
        
        UIView *topSeparator = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ContainerView.frame.size.width, 1)];
        topSeparator.backgroundColor = [UIColor colorWithRed:(37.0f/255.0f) green:(37.0f/255.0f) blue:(37.0f/255.0f) alpha:0.4];
        [buttonsView addSubview:topSeparator];
        
        UIView *separator = [[UIView alloc] initWithFrame:CGRectMake((ContainerView.frame.size.width/2)-1, 0, 1, 50)];
        separator.backgroundColor = [UIColor colorWithRed:(37.0f/255.0f) green:(37.0f/255.0f) blue:(37.0f/255.0f) alpha:0.4];
        [buttonsView addSubview:separator];
        
        [self bringSubviewToFront:closeBtn];
    }
    return self;
}
-(void)setButtonsHidden:(BOOL)hidden
{
    buttonsView.hidden = hidden;
    if(hidden)
    {
        browser.frame = CGRectMake(0, 0, self.frame.size.width-20, self.frame.size.height-20);
    }else
    {
        browser.frame = CGRectMake(0,0, self.frame.size.width-20, self.frame.size.height-50);
    }
}
- (void)ForwardAction:(id)sender
{
    if([browser canGoForward])
    {
        [self startAnimatingIndicator];
        [browser goForward];
    }
}
- (void)BackAction:(id)sender
{
    if([browser canGoBack])
    {
        [self startAnimatingIndicator];
        [browser goBack];
    }
    
}
- (void)LoadUrl:(NSURL *)url
{
    [browser loadRequest:[[NSURLRequest alloc] initWithURL:url]];
}
-(void)LoadHtmlString:(NSString*)html
{
    [browser loadHTMLString:html baseURL:nil];
}
- (void)startAnimatingIndicator
{
    [self StopAnimatingIndicator];
    if(!indicator)
    {
        indicator = [[MyActivityIndicator alloc] initWithFrame:CGRectMake(0, 0, 60, 60)];
    }
    indicator.center = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
    [self addSubview:indicator];
    
    [indicator startAnimating];
}
- (void)StopAnimatingIndicator
{
    [indicator stopAnimating];
    [indicator removeFromSuperview];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self StopAnimatingIndicator];
    if([_delegate respondsToSelector:@selector(browserDidFinishLoading:)])
    {
        [_delegate browserDidFinishLoading:self];
    }
}
- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [self startAnimatingIndicator];
    if([_delegate respondsToSelector:@selector(browserDidStartLoading:)])
    {
        [_delegate browserDidStartLoading:self];
    }
}
-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    if([_delegate respondsToSelector:@selector(browser:DidFailToLoadWithError:)])
    {
        [_delegate browser:self DidFailToLoadWithError:error];
    }
}
-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    if([_delegate respondsToSelector:@selector(browserShouldStartLoadWithRequest:withNavigationType:)])
    {
        return [_delegate browserShouldStartLoadWithRequest:request withNavigationType:navigationType];
    }else
    {
        return YES;
    }
}
- (void)CancelLoginAction:(id)sender
{
    [self removeFromView];
}
- (void)removeFromView
{
    if([_delegate respondsToSelector:@selector(browserViewRemovedFromSuperView:)])
    {
        [_delegate browserViewRemovedFromSuperView:self];
    }
    [self StopAnimatingIndicator];
    
    [UIView animateWithDuration:0.2 animations:^(void){
        
        
        self.alpha = 0.0;
        self.layer.transform = CATransform3DMakeScale(0.1, 0.1, 0.1);
        
    } completion:^(BOOL finished){
        [self removeFromSuperview];
        self.layer.transform = CATransform3DIdentity;
        [browser loadHTMLString:@"" baseURL:nil];
    }];
}
- (void)ShowInView:(UIView *)View
{
    
    CATransform3D transform = CATransform3DMakeScale(0.1, 0.1, 0.1);
    
    self.layer.transform = transform;
    
    
    [UIView animateWithDuration:0.3 animations:^(void){
        
        [View addSubview:self];
        self.alpha = 1.0;
        
        self.layer.transform = CATransform3DMakeScale(1.05, 1.05, 1.05);
        
    } completion:^(BOOL finished){
        [UIView animateWithDuration:0.2 animations:^(void){
            
            self.layer.transform = CATransform3DMakeScale(0.95, 0.95, 0.95);
            
            
            
        } completion:^(BOOL finished){
            [UIView animateWithDuration:0.2 animations:^(void){
                
                self.layer.transform = CATransform3DIdentity;
                
                
                
            } completion:^(BOOL finished){
                
                
            }];
            
        }];
        
        
    }];
}
/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect
 {
 // Drawing code
 }
 */


@end