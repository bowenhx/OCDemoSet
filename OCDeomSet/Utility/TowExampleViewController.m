/**
 -  TowExampleViewController.m
 -  OCDeomSet
 -  Created by ligb on 2018/11/21.
 -  Copyright © 2018 com.professional.cn. All rights reserved.
 */

#import "TowExampleViewController.h"
#import "ToolHeader.h"

@interface TowExampleViewController ()

@end

@implementation TowExampleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
  
}

- (IBAction)showAlertVCAction:(id)sender {
    CustomAlertController *customAlert = [CustomAlertController alertController];
    customAlert.title(@"这是alert").message(@"message").cancelTitle(@"取消").confirmTitle(@"确定").controller(self).alertStyle(alert);
    [customAlert show:nil confirmAction:^(UIAlertAction *action) {
        NSLog(@"action.title = %@",action.title);
    } cancelAction:nil];
}

- (IBAction)showSheetVCAction:(id)sender {
    //默认actionSheet
    CustomAlertController *customAlert = [CustomAlertController alertController];
    customAlert.title(@"这是actionSheet").message(@"信息").actions(@[@"测试1",@"测试2",@"测试3"]).cancelTitle(@"cancel").cancelStyle(ActionStyleDestructive);
    [customAlert show:^(UIAlertAction *action, NSInteger index) {
         NSLog(@"action.title = %@ selectIndex = %zd",action.title,index);
    } confirmAction:^(UIAlertAction *action) {
        NSLog(@"确定");
    } cancelAction:^(UIAlertAction *action) {
         NSLog(@"取消");
    }];
}

- (IBAction)showInputVCAction:(id)sender {
    CustomAlertController *customAlert = [CustomAlertController alertController];
    customAlert.title(@"这是一个TextField").message(@"描述信息").tfPlaceholders(@[@"请输入用户名",@"请输入密码"]).cancelTitle(@"取消").confirmTitle(@"确定").controller(self).alertStyle(alert);
    [customAlert showTextField:^(UITextField *textField) {
        if (textField.tag == 1) {
            textField.secureTextEntry = YES;
        }
        NSLog(@"textField.text = %@",textField.text);
    } confirmAction:^(UIAlertAction *action, NSArray<UITextField *> *textFields) {
        for (UITextField *textField in textFields) {
            NSLog(@"* *  textField.text = %@",textField.text);
        }
    } cancelAction:^(UIAlertAction *action, NSArray<UITextField *> *textFields) {
        
    }];
}



@end
