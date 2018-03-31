//
//  QCCSourceTreeController.m
//  Qapular Code Composer
//
//  Created by Volodymyr Pavliukevych.
//  Copyright (c) 2015 Qapular. All rights reserved.
//

#import "QCCSourceTreeController.h"
#import <QCCProjectEssenceKit/QCCProjectEssenceKit.h>
#import "QCCSourceTreeRowView.h"
#import "QCCProjectDocument.h"
#import "QCCBaseProjectDocument+Dialog.h"
#import "NSObject+Cast.h"

typedef enum : NSUInteger {
    QCCTreeMenuShowInFinder     = 1,
    QCCTreeMenuOpenInEditor     = 2,
    QCCTreeMenuAddFile          = 3,
    QCCTreeMenuAddFolder        = 4,
    QCCTreeMenuDelete           = 5,
    QCCTreeMenuImportFile       = 6,
} QCCTreeMenu;

@interface QCCSourceTreeController() <QCCProjectGroupRootDelegate>

@end

@implementation QCCSourceTreeController

-(void)awakeFromNib {
    [super awakeFromNib];
    NSTreeNode *rootTreeNode = [[self.arrangedObjects childNodes] firstObject];
    
    if ([rootTreeNode respondsToSelector:@selector(representedObject)]) {
        id rootRepresentedObject = rootTreeNode.representedObject;
        [rootRepresentedObject dependClass:[QCCProjectGroup class] performBlock:^(QCCProjectGroup * rootGroup) {
            if (rootGroup.root)
                rootGroup.delegate = self;
        }];
    }
}

#pragma mark - QCCProjectGroupRootDelegate
- (void) invalidateGroup:(QCCProjectGroup *)group child:(BOOL) child {
    if ([_interfaceDelegate respondsToSelector:@selector(invalidateGroup:)])
        [_interfaceDelegate invalidateGroup:[self nodeForObject:group]];

    if (child)
        if ([_interfaceDelegate respondsToSelector:@selector(invalidateItem:children:)])
            [_interfaceDelegate invalidateItem:[self nodeForObject:group] children:YES];
}

#pragma mark - NSOutlineViewDelegate
- (BOOL)outlineView:(NSOutlineView *)outlineView shouldEditTableColumn:(NSTableColumn *)tableColumn item:(id)item {

    return NO;
}

#pragma mark - NSControlTextEditingDelegate
- (BOOL)control:(NSControl *)control textShouldBeginEditing:(NSText *)fieldEditor {
    NSLog(@"%@ %@", control, fieldEditor);
    return NO;
}

#pragma mark - QCCOutlineViewDelegate
-(void) outlineView:(QCCOutlineView *)outlineView didDoubleClickOnColumn:(NSUInteger)columnt row:(NSUInteger)row {
    QCCProjectEssence *essence = [self firstSelectedEssenceOrNil];
    if (!essence.isValid)
        return;
    
    if ([essence isKindOfClass:[QCCProjectGroup class]]) {
        NSTreeNode *node = (NSTreeNode *) [outlineView itemAtRow:row];
        if (essence.root){
            [_delegate openProjectConfigurationWithObject:essence];
        } else if ([outlineView isExpandable:node] && ![outlineView isItemExpanded:node])
            [outlineView expandItem:node];
        
        return;
    }

    if ([_delegate respondsToSelector:@selector(openFileWithObject:inTab:)])
        [_delegate openFileWithObject:essence inTab:YES];
}

#pragma mark - NSMenuDelegate
-(BOOL)validateMenuItem:(NSMenuItem *)menuItem {

    QCCProjectEssence *selectedObject = [self firstSelectedEssenceOrNil];
    if (!selectedObject || !selectedObject.isValid)
        return NO;
    
    if (menuItem.tag == QCCTreeMenuAddFile && [selectedObject respondsToSelector:@selector(path)]) {
        NSString *title = [NSString stringWithFormat:@"%@ '%@'", NSLocalizedString(@"Add file to", nil), [selectedObject path]];
        menuItem.title = title;
    }
    if (menuItem.tag == QCCTreeMenuAddFolder && [selectedObject respondsToSelector:@selector(path)]) {
        NSString *title = [NSString stringWithFormat:@"%@ '%@'", NSLocalizedString(@"Add folder to", nil), [selectedObject path]];
        menuItem.title = title;
    }
    
    if (menuItem.tag == QCCTreeMenuOpenInEditor && [selectedObject isKindOfClass:[QCCProjectGroup class]])
        return NO;
        
    if ((menuItem.tag == QCCTreeMenuAddFile || menuItem.tag == QCCTreeMenuAddFolder) &&
        ![selectedObject isKindOfClass:[QCCProjectGroup class]])
        
        return NO;

    if (menuItem.tag == QCCTreeMenuDelete && selectedObject.root)
        return NO;
    
    return YES;
}

#pragma mark - Menu actions
// Create new items
- (IBAction) addFile:(id)sender {
    QCCProjectGroup *group = [self firstSelectedGroupOrNil];
    if (!group)
        return;

//    NSIndexPath *path = [self selectedPath];
    [_delegate addFileToObject:group completion:^(QCCProjectEssence *essence) {
        dispatch_async(dispatch_get_main_queue(), ^{
//            [self insertObject:essence atArrangedObjectIndexPath:path];
            [self reloadData];
            [_delegate asyncSave];
        });
    }];
}

// Create new folder
- (IBAction) addFolder:(id)sender {
    QCCProjectGroup *group = [self firstSelectedGroupOrNil];
    if (!group)
        return;
    
    [_delegate addFolderToObject:group completion:^(QCCProjectGroup *newGroup) {
        dispatch_async(dispatch_get_main_queue(), ^{
            //[self insertObject:newGroup atArrangedObjectIndexPath:[self selectedPath]];
            [self reloadData];
            [_delegate asyncSave];
        });
    }];
}

// Import from file system
- (IBAction) importToFolder:(id)sender {
    QCCProjectGroup *group = [self firstSelectedGroupOrNil];
    if (!group)
        return;
    
    [_delegate importEssencesToObject:group completion:^(NSArray *essences) {
        if ([essences count] > 0) {
            [self reloadData];
            [_delegate asyncSave];
        }
    }];
}

- (IBAction) removeNode:(id)sender {
    QCCProjectEssence *essence = [self firstSelectedEssenceOrNil];
    NSIndexPath *selectionIndexPath = self.selectionIndexPath;
    if (essence.root || !essence)
        return;
    
    [_delegate moveEssenceToTrash:essence completion:^(BOOL result, NSError *error) {
        if (result && !error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self removeObjectAtArrangedObjectIndexPath:selectionIndexPath];
                [_delegate asyncSave];
            });
        }
    }];
}


- (IBAction) showInFinder:(id)sender {
    QCCProjectEssence *essence = [self firstSelectedEssenceOrNil];
    if (essence)
        [_fileManagerDelegate showItemInFinder:essence completition:^(BOOL sucess) {}];
}

- (IBAction) openInEditor:(id)sender {

    QCCProjectEssence *essence = [self firstSelectedEssenceOrNil];
    if ([essence isKindOfClass:[QCCProjectGroup class]])
        return;
    
    
    if ([_delegate respondsToSelector:@selector(openFileWithObject:inTab:)])
        [_delegate openFileWithObject:essence inTab:YES];
}

- (NSIndexPath *) selectedPath {
    NSIndexPath *indexPath;
    
        indexPath = self.selectionIndexPath;
        indexPath = [indexPath indexPathByAddingIndex:[[[[self selectedObjects] objectAtIndex:0] children] count]];
    
    return indexPath;
    
}

- (NSIndexPath *) pathForObject:(id) object {
    NSIndexPath *indexPath;
    
    return indexPath;
    
}

#pragma mark - NSOutlineViewDelegate
- (void)outlineView:(NSOutlineView *)outlineView willDisplayCell:(id)cell forTableColumn:(NSTableColumn *)tableColumn item:(id)item {
    NSLog(@"outlineView: %@ cell: %@ item:%@", outlineView, cell, item);
}

- (NSTableRowView *)outlineView:(NSOutlineView *)outlineView rowViewForItem:(id)item {

    NSColor *selectedRowBackgroundColor;
    if ([outlineView isKindOfClass:[QCCOutlineView class]]) {
        QCCOutlineView *sourceTreeOutlineView = (QCCOutlineView*) outlineView;
        selectedRowBackgroundColor = [sourceTreeOutlineView selectedRowBackgroundColor];
    }
    
    QCCSourceTreeRowView *rowView = [[QCCSourceTreeRowView alloc] initWithFrame:NSZeroRect];
    rowView.selectedBackgroundColor = selectedRowBackgroundColor;
    return rowView;
}

#pragma mark - NSOutlineViewDataSource
- (void)outlineView:(NSOutlineView *)outlineView setObjectValue:(id)object forTableColumn:(NSTableColumn *)tableColumn byItem:(id)item {
}


- (QCCProjectEssence *) firstSelectedEssenceOrNil {
    id object = [self.selectedObjects firstObject];
    
    if ([object isKindOfClass:[QCCProjectEssence class]]){
        QCCProjectEssence * essence  = (QCCProjectEssence *) object;
        return essence;
    }
    
    return nil;
}


- (QCCProjectGroup *) firstSelectedGroupOrNil {
    QCCProjectEssence *object = [self firstSelectedEssenceOrNil];
    if ([object isKindOfClass:[QCCProjectGroup class]]){
        QCCProjectGroup * group  = (QCCProjectGroup *) object;
        return group;
    }
    return nil;
}
#pragma mark - Working with model
- (void) reloadData {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self rearrangeObjects];
    });
}

- (NSIndexPath*)indexPathOfObject:(id)anObject {
    return [self indexPathOfObject:anObject inNodes:[[self arrangedObjects] childNodes]];
}

- (NSIndexPath*)indexPathOfObject:(id)anObject inNodes:(NSArray*)nodes {
    for(NSTreeNode* node in nodes) {
        if([[node representedObject] isEqual:anObject])
            return [node indexPath];
        if([[node childNodes] count]) {
            NSIndexPath* path = [self indexPathOfObject:anObject inNodes:[node childNodes]];
            if(path)
                return path;
        }
    }
    return nil;
}


- (NSTreeNode*) nodeForObject:(id)anObject {
    return [self nodeForObject:anObject inNodes:[[self arrangedObjects] childNodes]];
}

- (NSTreeNode*)nodeForObject:(id)anObject inNodes:(NSArray*)nodes {
    
    for(NSTreeNode* node in nodes) {
        if([[node representedObject] isEqual:anObject])
            return node;
        
        if([[node childNodes] count])
            return [self nodeForObject:anObject inNodes:[node childNodes]];
    }
    
    return nil;
}

@end


