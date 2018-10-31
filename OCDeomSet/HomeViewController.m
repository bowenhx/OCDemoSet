//
//  HomeViewController.m
//  OCDeomSet
//
//  Created by ligb on 2018/10/24.
//  Copyright © 2018年 com.professional.cn. All rights reserved.
//

#import "HomeViewController.h"
#import "ToolHeader.h"
@interface HomeViewController ()

@end

@implementation HomeViewController {
    NSArray *_classNames;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"test demo";
    
    _classNames = @[@"OneExampleViewController"];
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _classNames.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.textLabel.text = [NSString stringWithFormat:@"%@",_classNames[indexPath.row]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self showNextControllerName:_classNames[indexPath.row] params:nil isPush:YES];
}


@end
