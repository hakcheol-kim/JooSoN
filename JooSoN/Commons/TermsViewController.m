//
//  TermsViewController.m
//  JooSoN
//
//  Created by 김학철 on 2021/02/23.
//  Copyright © 2021 김학철. All rights reserved.
//

#import "TermsViewController.h"
#import "WebViewController.h"
#import "HAlertView.h"
#import "AppDelegate.h"
#import "PermissionsViewController.h"

@interface TermsViewController ()
@property (weak, nonatomic) IBOutlet UIButton *btnCheckTerm;
@property (weak, nonatomic) IBOutlet UIButton *btnLinkTerm;
@property (weak, nonatomic) IBOutlet UIButton *btnOk;

@end

@implementation TermsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    NSAttributedString *attr = [[NSAttributedString alloc] initWithString:@"약관 보기" attributes:@{NSUnderlineStyleAttributeName: @(NSUnderlineStyleSingle)}];
    [_btnLinkTerm setAttributedTitle:attr forState:UIControlStateNormal];
    
}

- (IBAction)onClickedBtnActions:(UIButton *)sender {
    
    if (sender == _btnCheckTerm) {
        _btnCheckTerm.selected = !_btnCheckTerm.selected;
    }
    else if (sender == _btnLinkTerm) {
        WebViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"WebViewController"];
        vc.vcTitle = @"약관";
        vc.url = @"https://www.jooso-n.com/document/privacy";
        [self.navigationController pushViewController:vc animated:YES];
    }
    else if (sender == _btnOk) {
        if (_btnCheckTerm.selected == NO) {
            [HAlertView alertShowMsgWithOkAction:@"약관에 동의해주세요." alertBlock:^(NSInteger index) {
               
            }];
            return;
        }
        
        PermissionsViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"PermissionsViewController"];
        [self.navigationController pushViewController:vc animated:YES];
    }
}
@end
