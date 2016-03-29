//
//  FFChatViewController.m
//  FFChat
//
//  Created by fanly frank on 3/25/16.
//  Copyright © 2016 fanly frank. All rights reserved.
//

#import "FFChatViewController.h"
#import "FFChatTextCell.h"
#import "FFAudioClient.h"

@interface FFChatViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) FFAudioClient *audioClient;

@end

@implementation FFChatViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:
                                      CGRectMake(0, 0, 0, self.tabBarController.tabBar.frame.size.height)];
    self.tableView.tableHeaderView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    
    self.tableView.backgroundColor = FFColorBackgroud;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.separatorColor = FFColorSeparator;
    self.tableView.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0, 50, 0);
    
    [self.tableView registerClass:[FFChatTextCell class] forCellReuseIdentifier:NSStringFromClass([FFChatTextCell class])];
    
    _audioClient = [FFAudioClient sharedAudioClient];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 4	;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    FFChatTextCell *cell = [self.tableView dequeueReusableCellWithIdentifier:NSStringFromClass([FFChatTextCell class])];
    
    [cell.contentLabel setText:@"fanly your"];
    NSRange range = [cell.contentLabel.text rangeOfString:@"your"];
    [cell.contentLabel addLinkToURL:[NSURL URLWithString:@"http://github.com/mattt/"] withRange:range];
    
    //cell.delegate = self;
    cell.indexPath = indexPath;
    cell.isShowNickname = @"fanly test msg";
    cell.isMultEditingSelected = NO;
    [cell.nicknameLabel setText:@"fanly"];
    NSRange xrange = [cell.nicknameLabel.text rangeOfString:@"frank"];
    [cell.nicknameLabel addLinkToURL:[NSURL  URLWithString:@"user://frank"] withRange:xrange];
    cell.userType = indexPath.row % 2 ? FFChatCellUserTypeMyself : FFChatCellUserTypeOther;
    
    if (cell.userType == FFChatCellUserTypeMyself) {
        cell.avatarImgView.image = [UIImage imageNamed:@"AvatarMe"];
    } else {
        cell.avatarImgView.image = [UIImage imageNamed:@"AvatarOther"];
    }

    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    FFChatTextCell *cell = [self.tableView dequeueReusableCellWithIdentifier:NSStringFromClass([FFChatTextCell class])];
    
    [cell.contentLabel setText:@"fanly your"];
    NSRange range = [cell.contentLabel.text rangeOfString:@"your"];
    [cell.contentLabel addLinkToURL:[NSURL URLWithString:@"http://github.com/mattt/"] withRange:range];
    
    //cell.delegate = self;
    cell.indexPath = indexPath;
    cell.isShowNickname = @"fanly test msg";
    cell.isMultEditingSelected = NO;
    [cell.nicknameLabel setText:@"fanly"];
    NSRange xrange = [cell.nicknameLabel.text rangeOfString:@"frank"];
    [cell.nicknameLabel addLinkToURL:[NSURL  URLWithString:@"user://frank"] withRange:xrange];
    cell.userType = FFChatCellUserTypeMyself;
    
    if (cell.userType == FFChatCellUserTypeMyself) {
        cell.avatarImgView.image = [UIImage imageNamed:@"AvatarMe"];
    } else {
        cell.avatarImgView.image = [UIImage imageNamed:@"AvatarOther"];
    }

    return [cell getHeight];
}

- (IBAction)beginToSpeak:(id)sender {
    [self.audioClient startRecorderAudio];
}

- (IBAction)maybeCancleSpeak:(id)sender {
}

- (IBAction)goOnSpeak:(id)sender {
}

- (IBAction)sendAudio:(id)sender {
    [self.audioClient endRecord];
}


- (IBAction)switchInputWay:(id)sender {
}

@end
