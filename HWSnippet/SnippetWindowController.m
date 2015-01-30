//
//  SnippetWindowController.m
//  HWSnippet
//
//  Created by HalloWorld on 14-2-11.
//  Copyright (c) 2014年 HalloWorld. All rights reserved.
//

#import "SnippetWindowController.h"
#import "ATZGit.h"
#import "ATZShell.h"

@interface SnippetWindowController ()

@end

@implementation SnippetWindowController

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

static NSString *pathForSnippet = @"Library/Developer/Xcode/UserData/CodeSnippets";

- (IBAction)btnAppendTap:(id)sender {
    //    NSString *rps = @"https://github.com/ligun123/HWCodeSnippet.git";
    self.errNotice.stringValue = @"Clone...请不要关闭本窗口";
    NSString *rps = self.gitAddress.stringValue;
    [self createBackupFolder];
    [self backupSnippet];
    [ATZGit cloneRepository:rps toLocalPath:[NSHomeDirectory() stringByAppendingPathComponent:pathForSnippet] completion:^(NSError *error) {
        [self unbackupSnippet];
        [self cleanGitFiles];
        if (error) {
            self.errNotice.stringValue = [error localizedDescription];
            NSLog(@"%s -> %@", __FUNCTION__, error);
        } else self.errNotice.stringValue = @"Append 完毕";
        
        ATZShell *shell = [ATZShell new];
        [shell executeCommand:OPEN withArguments:@[[NSHomeDirectory() stringByAppendingPathComponent:pathForSnippet]] completion:^(NSString *output, NSError *error) {
            NSLog(@"%s -> %@", __FUNCTION__, error);
        }];
    }];
}

- (IBAction)btnReplaceTap:(id)sender {
    self.errNotice.stringValue = @"Clone...请不要关闭本窗口";
    NSString *rps = self.gitAddress.stringValue;
    [self createBackupFolder];
    [self backupSnippet];
    [ATZGit cloneRepository:rps toLocalPath:[NSHomeDirectory() stringByAppendingPathComponent:pathForSnippet] completion:^(NSError *error) {
        [self cleanGitFiles];
        if (error) {
            self.errNotice.stringValue = [error localizedDescription];
            NSLog(@"%s -> %@", __FUNCTION__, error);
        } else self.errNotice.stringValue = @"Replace 执行完毕";
        
        ATZShell *shell = [ATZShell new];
        [shell executeCommand:OPEN withArguments:@[[NSHomeDirectory() stringByAppendingPathComponent:pathForSnippet]] completion:^(NSString *output, NSError *error) {
            NSLog(@"%s -> %@", __FUNCTION__, error);
        }];
    }];
}

- (void)backupSnippet {
    NSError *err = nil;
    NSString *path = [NSHomeDirectory() stringByAppendingPathComponent:pathForSnippet];
    NSString *backupPath = [self folderOfBackup];
    NSArray *subs = [[NSFileManager defaultManager] subpathsAtPath:path];
    for (NSString *sub in subs) {
        if (![sub hasSuffix:@"codesnippet"]) {
            return ;
        }
        NSString *snpPath = [path stringByAppendingPathComponent:sub];
        if (![[NSFileManager defaultManager] moveItemAtPath:snpPath toPath:[backupPath stringByAppendingPathComponent:sub] error:&err]) {
            self.errNotice.stringValue = [err localizedDescription];
            NSLog(@"%s -> %@", __FUNCTION__, err);
        }
    }
}

- (void)unbackupSnippet {
    NSError *err = nil;
    NSString *path = [NSHomeDirectory() stringByAppendingPathComponent:pathForSnippet];
    NSString *backupPath = [self folderOfBackup];
    NSArray *subs = [[NSFileManager defaultManager] subpathsAtPath:backupPath];
    for (NSString *sub in subs) {
        NSString *snpPath = [backupPath stringByAppendingPathComponent:sub];
        NSString *toPath = [path stringByAppendingPathComponent:sub];
        [[NSFileManager defaultManager] removeItemAtPath:toPath error:nil];
        if (![[NSFileManager defaultManager] moveItemAtPath:snpPath toPath:toPath error:&err]) {
            self.errNotice.stringValue = [err localizedDescription];
            NSLog(@"%s -> %@", __FUNCTION__, err);
        }
    }
    [[NSFileManager defaultManager] removeItemAtPath:backupPath error:&err];
    if (err) {
        self.errNotice.stringValue = [err localizedDescription];
        NSLog(@"%s -> %@", __FUNCTION__, err);
    }
}

- (NSString *)folderOfBackup {
    NSString *back = [NSHomeDirectory() stringByAppendingPathComponent:@"CodeSnippetBackup"];
    return back;
}

- (void)createBackupFolder {
    BOOL isFolder = NO;
    NSString *path = [self folderOfBackup];
    if ([[NSFileManager defaultManager] fileExistsAtPath:[self folderOfBackup] isDirectory:&isFolder]) {
        if (isFolder) {
            return ;
        } else {
            if (![[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil]) {
                NSLog(@"%s create backup folder faild", __FUNCTION__);
            }
        }
    } else {
        if (![[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil]) {
            NSLog(@"%s create backup folder faild", __FUNCTION__);
        }
    }
}

- (void)cleanGitFiles {
    NSString *gitPath = [pathForSnippet stringByAppendingPathComponent:@".git"];
    NSError *err = nil;
    if (![[NSFileManager defaultManager] fileExistsAtPath:gitPath]) {
        return ;
    }
    [[NSFileManager defaultManager] removeItemAtPath:gitPath error:&err];
    if (err) {
        self.errNotice.stringValue = [err localizedDescription];
        NSLog(@"%s -> %@", __FUNCTION__, err);
    }
}


@end
