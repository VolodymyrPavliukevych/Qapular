//
//  QCCodeViewController.m
//  Qapular Code Composer
//
//  Created by Volodymyr Pavliukevych.
//  Copyright (c) 2015 Qapular. All rights reserved.
//

#import "QCCodeViewController.h"

#import "QCCodeView.h"
#import "QCCRootView.h"
#import "QCCStatusBar.h"
#import "QCCWindowTitleBar.h"
#import "QCCEditorRulerView.h"
#import "QCCPreferences.h"
#import "QCCodeStorage.h"
#import "QCCThemaManager.h"

@interface QCCodeViewController () <QCCWindowTitleBarDelegate> {
    
    QCCEditorRulerView          *_editorRulerView;

    IBOutlet QCCRootView         *_rootView;
    IBOutlet QCCWindowTitleBar   *_titleBar;
    IBOutlet QCCStatusBar        *_statusBar;
    IBOutlet NSScrollView        *_editorScrollView;
    IBOutlet QCCodeView          *_codeView;
    
    id<QCCEditorDataSource>      _editorDataSource;
    QCCThemaManager             *_themaManager;

    BOOL                        _codeViewWrapingColumnIsEqualFrame;
    
}

@end

@implementation QCCodeViewController

#pragma mark - Notification actions
- (void) updatedPreferences:(NSNotification *) notification {
        
    if ([notification.userInfo objectForKey:QCCPreferencesUpdatedValueKey] == QCCPreferencesWrapColumnKey)
        [self updateWrapColumn];
    
    if ([notification.userInfo objectForKey:QCCPreferencesUpdatedValueKey] == QCCPreferencesShowLineNumberKey)
        _editorRulerView.shouldShowLineNumber = [[_editorDataSource preferencesForCodeView:_codeView] shouldShowLineNumbering];
    
}

- (void) themeManagerUpdated {
    [self updateWrapColumn];
}

- (void) subscribeForNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updatedPreferences:)
                                                 name:QCCPreferencesUpdatedNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(themeManagerUpdated)
                                                 name:QCCThemaManagerReplacedNotification
                                               object:nil];
}

- (void) unsubscribeForNotifications {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - ViewController  lifecycle

-(void)viewDidLoad {
    [super viewDidLoad];
    // NSLog(@"%s",__FUNCTION__);
    
    [self updateEditorDataSourceRelations];
    
}

-(void)awakeFromNib {
    // NSLog(@"%s",__FUNCTION__);
    [super awakeFromNib];
}


-(void)viewDidLayout {
    // NSLog(@"%s",__FUNCTION__);
    [super viewDidLayout];
    
    if (_codeViewWrapingColumnIsEqualFrame)
        _codeView.wrapingColumnWidht = self.view.frame.size.width;
    
    [_editorRulerView setNeedsDisplay:YES];

}

-(void)viewWillAppear {
    // NSLog(@"%s",__FUNCTION__);
    [super viewWillAppear];
    [self subscribeForNotifications];

}

-(void)viewWillDisappear {
    // NSLog(@"%s", __FUNCTION__);
    [super viewWillDisappear];
    [self unsubscribeForNotifications];
}

#pragma mark - Ruller 
- (void) setupRuler {
    // NSLog(@"%s", __FUNCTION__);

    _editorRulerView = [[QCCEditorRulerView alloc] initWithScrollView:_editorScrollView forCodeView:_codeView andThemaManager:_themaManager];
    _editorRulerView.shouldShowLineNumber = [[_editorDataSource preferencesForCodeView:_codeView] shouldShowLineNumbering];
    
    [_editorScrollView setVerticalRulerView:_editorRulerView];
    [_editorScrollView setHasHorizontalRuler:NO];
    [_editorScrollView setHasVerticalRuler:YES];
    [_editorScrollView setRulersVisible:YES];
}

#pragma mark - CodeView appearence
- (void) updateWrapColumn {
    // NSLog(@"%s", __FUNCTION__);

    QCCPreferences *preferences = [_editorDataSource preferencesForCodeView:_codeView];
    
    QCCPreferencesWrapColumn wrapColumn = preferences.wrapColumn;
    
    switch (wrapColumn.type) {
        case QCCWrapColumnNon:
            _codeView.wrapingColumnWidht = MAXFLOAT;
            _codeViewWrapingColumnIsEqualFrame = NO;
            break;
            
        case QCCWrapColumnAtFrameSize:
            _codeViewWrapingColumnIsEqualFrame = YES;
            _codeView.wrapingColumnWidht = self.view.frame.size.width;
            break;
            
        case QCCWrapColumnValue:
            _codeViewWrapingColumnIsEqualFrame = NO;
            _codeView.wrapingColumnWidht = wrapColumn.columns * [[self codeStorage] defaultCharSize].width;
            break;
    }
    
    [_editorRulerView setNeedsDisplay:YES];
}

#pragma mark - QCCEditorDataSource
-(void)replaceEditorDataSource:(id<QCCEditorDataSource>)editorDataSource {
    // NSLog(@"%s",__FUNCTION__);

    _editorDataSource = editorDataSource;
    if (!_editorDataSource)
        return;
    [self updateEditorDataSourceRelations];
}

- (void) updateEditorDataSourceRelations {
    // NSLog(@"%s", __FUNCTION__);
    if (!_editorDataSource)
        return;
    
    _titleBar.delegate = self;
    
    [_statusBar setThemaManager:[self themaManager]];
    [_titleBar setThemaManager:[self themaManager]];
    [_titleBar setTitle:[_editorDataSource titleForDocument]];
    
    [_codeView setThemaManager:[self themaManager]];
    [_codeView replaceCodeStorage:[self codeStorage]];
    
    [self updateWrapColumn];
    [self setupRuler];

}

- (QCCThemaManager *) themaManager {
        
    if (_themaManager != [_editorDataSource themaManagerForCodeView:_codeView])
        _themaManager = [_editorDataSource themaManagerForCodeView:_codeView];
    
    return _themaManager;
}

- (QCCodeStorage *) codeStorage {
   return [_editorDataSource codeStorageForCodeView:_codeView];
}


#pragma mark - QCCWindowTitleBarDelegate
-(void)titleBarHandleActionWithButton:(NSWindowButton)button {
        
    switch (button) {
        case NSWindowCloseButton:
            [_windowController.window close];
            break;
            
        case NSWindowMiniaturizeButton:
            [_windowController.window miniaturize:nil];
            break;
            
        case NSWindowFullScreenButton:
            [_windowController.window zoom:nil];
            break;
            
        default:
            break;            
    }
}


@end
