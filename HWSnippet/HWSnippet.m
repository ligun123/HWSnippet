//
//  HWSnippet.m
//  HWSnippet
//
//  Created by cdsb on 15/1/30.
//  Copyright (c) 2015年 cdsb. All rights reserved.
//

#import "HWSnippet.h"
#import "SnippetWindowController.h"

@interface HWSnippet ()

@property (nonatomic, strong) SnippetWindowController *snippetController;

@end

@implementation HWSnippet

+ (void)pluginDidLoad:(NSBundle*)plugin
{
    static id sharedPlugin = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        sharedPlugin = [[self alloc] init];
    });
}

- (id)init
{
    if (self = [super init])
    {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(applicationDidFinishLaunching:)
                                                     name:NSApplicationDidFinishLaunchingNotification
                                                   object:nil];
    }
    return self;
}

- (void)applicationDidFinishLaunching:(NSNotification*)notification
{
    NSLog(@"%s -> ", __FUNCTION__);
    [self addSettingMenu];
}

- (void)addSettingMenu
{
    NSMenuItem *editMenuItem = [[NSApp mainMenu] itemWithTitle:@"Window"];
    if (editMenuItem) {
        [[editMenuItem submenu] addItem:[NSMenuItem separatorItem]];
        
        NSMenuItem *newMenuItem = [[NSMenuItem alloc] initWithTitle:@"HWSnippet" action:@selector(showSettingPanel:) keyEquivalent:@""];
        
        [newMenuItem setTarget:self];
        [[editMenuItem submenu] addItem:newMenuItem];
    }
}


- (SnippetWindowController *)snippetController {
    if (_snippetController == nil) {
        _snippetController = [[SnippetWindowController alloc] initWithWindowNibName:@"SnippetWindowController"];
    }
    return _snippetController;
}

- (void)showSettingPanel:(NSNotification *)noti {
    [self.snippetController showWindow:self.snippetController];
}

@end
