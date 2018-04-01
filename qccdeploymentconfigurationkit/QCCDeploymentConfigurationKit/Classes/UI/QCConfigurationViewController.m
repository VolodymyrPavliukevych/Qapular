//
//  QCConfigurationViewController.m
//  QCCDeploymentConfigurationKit
//
//  Created by Vladimir Pavliukevych
//  Copyright © Vladimir Pavliukevych. All rights reserved.
//

#import "QCConfigurationViewController.h"

#import "QCCProjectConfigurationContainer.h"
#import "QCCDeploymentConfiguration.h"
#import "QCCBoardConfigurationContainer.h"
#import "QCConfigurationProperty.h"
#import "QCConfigurationContainer.h"
#import "QCConfigurationPropertyNode.h"
#import "QCCPropertyValueColumn.h"
#import "QCConfigurationLevelNode.h"
#import "QCCDeploymentConfiguration+UTCoreTypes.h"
#import "QCCPropertyGroupCellView.h"

#import "QCCNewConfigurationWindowController.h"
#import "QCCPropertyConfiguratorWindowController.h"
#import "QCCDeploymentConfiguration+QCCPropertyConfiguratorDataSource.h"


static const CGFloat SplitViewMinWidth  =   40.0f;

typedef enum : NSUInteger {
    QCConfigurationTreeMenuAddDeployemntConfiguration   = 901,
    QCConfigurationTreeMenuAddBoardConfiguration        = 902,
    QCConfigurationTreeMenuRemove                       = 903
} QCConfigurationTreeMenu;


@interface QCConfigurationViewController () <NSOutlineViewDataSource, NSOutlineViewDelegate, NSSplitViewDelegate> {
    QCConfigurationLevelNode                *_rootElementNode;
    QCCNewConfigurationWindowController     *_newConfigurationWindowController;
    QCCPropertyConfiguratorWindowController *_propertyConfiguratorWindowController;
    
    
    IBOutlet    NSOutlineView   *_configurationTreeOutlineView;
    IBOutlet    NSOutlineView   *_configurationValuesOutlineView;
    IBOutlet    NSSplitView     *_splitView;
    
    IBOutlet    NSMenu          *_configurationTreeMenu;
    IBOutlet    NSMenu          *_configurationValuesMenu;
    
    IBOutlet    NSButton        *_addPropertyButton;
    IBOutlet    NSButton        *_removePropertyButton;
    
    NSMutableArray              *_propertyArray;
}

@end

@implementation QCConfigurationViewController

+ (instancetype) default {
    return [[QCConfigurationViewController alloc] initWithNibName:nil bundle:nil];
}

-(instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    NSBundle *frameworkBundle = [NSBundle bundleForClass:[QCConfigurationViewController class]];
    self = [super initWithNibName:NSStringFromClass([QCConfigurationViewController class]) bundle:frameworkBundle];
    if (self) {
        _propertyArray = [NSMutableArray new];
    }
    return self;
}

- (QCConfigurationLevelNode *) rootElementNode {
    
    if (_rootElementNode)
        return _rootElementNode;
    
    QCCProjectConfigurationContainer *projectConfigurationContainer = [[self deploymentConfiguration] projectConfigurationContainer];
    
    if (!projectConfigurationContainer)
        return nil;
    
    _rootElementNode = [QCConfigurationLevelNode treeNodeWithRepresentedObject:projectConfigurationContainer];
    
    return _rootElementNode;
}

#pragma mark - QCCDeploymentConfigurationDataSource
- (id <QCCDeploymentConfigurationDataSource>) deploymentConfigurationDataSource {
    return [[self deploymentConfiguration] dataSource];
}

#pragma mark - QCCDeploymentConfiguration
- (QCCDeploymentConfiguration *) deploymentConfiguration {
    return [self.deploymentConfigurationProvider deploymentConfiguration];
}


- (void) setDeploymentConfigurationProvider:(id<QCCDeploymentConfigurationProvider>)deploymentConfigurationProvider {
    _deploymentConfigurationProvider = deploymentConfigurationProvider;
    [_configurationTreeOutlineView reloadData];
}

#pragma mark - NSOutlineViewDataSource Helper
- (NSArray *) configurationTreeChildrenForItem:(id)item {
    if (!item)
        return @[[self rootElementNode]];
    else
        return [item childNodes];
}


#pragma mark - NSOutlineViewDataSource
-(NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item {
    if (outlineView == _configurationTreeOutlineView)
        return [[self configurationTreeChildrenForItem:item] count];
    
    if (outlineView == _configurationValuesOutlineView) {
        return [[self propertyForSelectedConfigurationTreeElement] count];
    }

    return 0;
}


-(id) outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(id)item {
    if (outlineView == _configurationTreeOutlineView) {
        NSArray *items = [self configurationTreeChildrenForItem:item];
        return ([items count] > index ? items[index] : nil);
    }
    
    if (outlineView == _configurationValuesOutlineView) {
        QCConfigurationContainer *container;
        if ([item isKindOfClass:[QCConfigurationLevelNode class]]) {
            QCConfigurationLevelNode *node = (QCConfigurationLevelNode *) item;
            container = [self containerForNode:node];
        }else if(!item) {
            container = [self latestSelectedConfigurationTreeElement];
        }
        
        QCConfigurationProperty *propeerty = [self propertyForContainer:container][index];
        QCConfigurationPropertyNode *propertyNode = [QCConfigurationPropertyNode treeNodeWithRepresentedObject:propeerty];
        [_propertyArray addObject:propertyNode];
        return propertyNode;
        
    }
    return nil;
}

- (id) outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(id)item {
    
    if ([item respondsToSelector:@selector(representedObject)]) {
        id element = [item representedObject];
        return element;
    }
    
    return nil;
}


-(BOOL)outlineView:(NSOutlineView *)outlineView isGroupItem:(id) item {
    if (outlineView == _configurationValuesOutlineView) {
        if ([item isKindOfClass:[QCConfigurationPropertyNode class]]) {
            QCConfigurationPropertyNode *propertyNode = (QCConfigurationPropertyNode *) item;
            return ([propertyNode.representedObject isKindOfClass:[NSDictionary class]]);
        }
    }
    
    return NO;
}


-(BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item {
    if ([item isKindOfClass:[QCConfigurationLevelNode class]]) {
        QCConfigurationLevelNode *element = (QCConfigurationLevelNode *) item;
        if ([element.representedObject isKindOfClass:[QCConfigurationContainer class]]) {
            return ([[self configurationTreeChildrenForItem:item] count] > 0);
        }
    }
    return NO;
}


-(NSView *)outlineView:(NSOutlineView *)outlineView viewForTableColumn:(NSTableColumn *)tableColumn item:(id)item {
    if (!tableColumn) {
        return [outlineView makeViewWithIdentifier:NSStringFromClass([QCCPropertyGroupCellView class]) owner:self];
    }
    return [outlineView makeViewWithIdentifier:tableColumn.identifier owner:self];
}



#pragma mark - NSSplitViewDelegate
- (BOOL)splitView:(NSSplitView *)splitView canCollapseSubview:(NSView *)subview {
    return NO;
}

- (CGFloat)splitView:(NSSplitView *)splitView constrainMinCoordinate:(CGFloat)proposedMinimumPosition ofSubviewAt:(NSInteger)dividerIndex {
    return SplitViewMinWidth;
}

- (CGFloat)splitView:(NSSplitView *)splitView constrainMaxCoordinate:(CGFloat)proposedMaximumPosition ofSubviewAt:(NSInteger)dividerIndex {
    return splitView.frame.size.width - SplitViewMinWidth;
}

- (CGFloat)splitView:(NSSplitView *)splitView constrainSplitPosition:(CGFloat)proposedPosition ofSubviewAt:(NSInteger)dividerIndex;{
    
    if (proposedPosition < SplitViewMinWidth)
        return SplitViewMinWidth;
    if (proposedPosition > splitView.frame.size.width - SplitViewMinWidth)
        return splitView.frame.size.width - SplitViewMinWidth;

    return proposedPosition;
}

-(void)outlineViewSelectionDidChange:(NSNotification *)notification {
    if (notification.object == _configurationTreeOutlineView) {
        dispatch_async(dispatch_get_main_queue(), ^{
            QCConfigurationLevelNode *element = [_configurationTreeOutlineView itemAtRow:[_configurationTreeOutlineView selectedRow]];
            QCConfigurationContainer *configurationContainer  = element.representedObject;
//            for (QCCBaseConfigurationElement *ch in [configurationContainer children]) {
//                if (![ch isKindOfClass:[QCConfigurationContainer class]]) {
                    [_propertyArray removeAllObjects];
                    [_configurationValuesOutlineView reloadData];
                    _removePropertyButton.enabled = NO;
                    _addPropertyButton.enabled = ([[configurationContainer class] canAddElementClass:[QCConfigurationProperty class]]);
//                }
//            }
        });
    }
    
    if(notification.object == _configurationValuesOutlineView) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (![[[self latestSelectedConfigurationTreeElement] class] canAddElementClass:[QCConfigurationProperty class]])
                return ;
            
            NSUInteger idx = [_configurationValuesOutlineView selectedRow];
            if (idx != UINT64_MAX)
                _removePropertyButton.enabled = YES;
            else
                _removePropertyButton.enabled = NO;
        });
    }
}

#pragma mark - Selection element
- (QCConfigurationContainer *) containerForNode:(QCConfigurationLevelNode *) node {
    if (node && [node isKindOfClass:[QCConfigurationLevelNode class]]) {
        if ([node.representedObject isKindOfClass:[QCConfigurationContainer class]])
            return node.representedObject;
    }
    return nil;
}

- (QCConfigurationContainer *) latestSelectedConfigurationTreeElement {
    QCConfigurationLevelNode *node = [_configurationTreeOutlineView itemAtRow:[_configurationTreeOutlineView selectedRow]];
    return [self containerForNode:node];
    
    return nil;
}

- (QCConfigurationLevelNode *) latestSelectedConfigurationNodeTree {
    QCConfigurationLevelNode *node = [_configurationTreeOutlineView itemAtRow:[_configurationTreeOutlineView selectedRow]];
    return node;
}

- (QCConfigurationPropertyNode *) selectedPropertyNodeTree {
    NSUInteger idx = [_configurationValuesOutlineView selectedRow];
    if (idx == UINT64_MAX)
        return nil;
    
    return [_configurationValuesOutlineView itemAtRow:idx];
}

- (QCConfigurationProperty *) selectedProperty {
    id object =  [[self selectedPropertyNodeTree] representedObject];
    if ([object isKindOfClass:[QCConfigurationProperty class]])
        return object;
    else
        return nil;
}


- (NSArray *) propertyForSelectedConfigurationTreeElement {
    return [self propertyForContainer:[self latestSelectedConfigurationTreeElement]];
}

- (NSArray *) propertyForContainer:(QCConfigurationContainer *) container {
    NSMutableArray *array = [NSMutableArray new];
    
    for (QCCBaseConfigurationElement *element in [container children]) {
        if ([element isKindOfClass:[QCConfigurationProperty class]]) {
            QCConfigurationProperty *property = (QCConfigurationProperty *) element;
            property.localizationDataSource = [self deploymentConfiguration].localizationDataSource;
            [array addObject:element];
        }
        
    }
        
    NSSortDescriptor *valueDescriptor = [[NSSortDescriptor alloc] initWithKey:@"UTIString" ascending:YES];
    NSArray *sortedArray = [array sortedArrayUsingDescriptors:@[valueDescriptor]];
    
    NSMutableArray *resultArray = [NSMutableArray new];

    NSString *previousUTI;
    for (QCConfigurationProperty *property in sortedArray) {
        if (![previousUTI isEqualToString:property.UTIString]){
            previousUTI = property.UTIString;
            NSString *UTIGroupTitle = [QCCDeploymentConfiguration UTIPropertyDictionary][previousUTI];
            [resultArray addObject:@{@"name" : (UTIGroupTitle ? UTIGroupTitle:previousUTI)}];
        }
        
        [resultArray addObject:property];
    }
    
    return resultArray;
}

#pragma mark - NSMenuDelegate
- (BOOL)validateMenuItem:(NSMenuItem *) menuItem {
    if (menuItem.menu == _configurationTreeMenu)
        return [self validateConfigurationTreeMenuItem:menuItem];
    
    
    return NO;
}

- (BOOL) validateConfigurationTreeMenuItem:(NSMenuItem *) menuItem {
    
    QCConfigurationContainer *container = [self latestSelectedConfigurationTreeElement];
    if (!container)
        return NO;
    
    switch (menuItem.tag) {
        case QCConfigurationTreeMenuAddBoardConfiguration:
            return [[container class] canAddElementClass:[QCCBoardConfigurationContainer class]];
            
        case QCConfigurationTreeMenuAddDeployemntConfiguration:
            return [[container class] canAddElementClass:[QCCDeploymentConfigurationContainer class]];
            
        case QCConfigurationTreeMenuRemove: {
            NSTreeNode *parentNode = [[self latestSelectedConfigurationNodeTree] parentNode];
            
            if (!parentNode)
                return NO;
            
            QCCBaseConfigurationElement *parentElement = parentNode.representedObject;
            return ([[parentElement class] canAddElement:container]);

        }
            return YES;

        default:
            return NO;
            break;
    }
    
    return NO;
}

#pragma mark - UI Actions
- (IBAction) addBoardNode:(NSMenuItem *) sender {
    __weak NSWindow *baseWindow = [[self view] window];
    __weak QCConfigurationViewController * wSelf = self;
    
    if (![wSelf latestSelectedConfigurationTreeElement])
        return;
    
    NewConfigurationCompletionBlock block = ^void (QCCNewConfigurationWindowController *controller,
                                                   NSString *name,
                                                   NSString *configuration,
                                                   NSString *actionKey,
                                                   NSString *propertyKey) {
        [baseWindow endSheet:controller.window];
        _newConfigurationWindowController = nil;
        
        if (!configuration)
            return;

        QCCBoardConfigurationContainer *boardContainer = [[wSelf deploymentConfiguration] boardConfigurationForIdentifier:configuration];
        [[wSelf deploymentConfiguration] addElement:boardContainer toContainer:[wSelf latestSelectedConfigurationTreeElement]];
        [[wSelf latestSelectedConfigurationNodeTree] updateBoardNode];
        [_configurationTreeOutlineView reloadData];
    };
    
    QCCNewConfigurationWindowController *newConfigurationWindowController =
    [self newConfigurationWindowControllerForType:QCCNewConfigurationTypeBoard
                                    comboBoxItems:[[self deploymentConfiguration] targetItems]
                                       completion:block];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [baseWindow beginSheet:newConfigurationWindowController.window completionHandler:nil];
    });
}


- (IBAction) addDeployemntNode:(NSMenuItem *) sender {
    
    __weak NSWindow *baseWindow = [[self view] window];
    __weak QCConfigurationViewController * wSelf = self;
    
    if (![wSelf latestSelectedConfigurationTreeElement])
        return;
    
    NewConfigurationCompletionBlock block = ^void (QCCNewConfigurationWindowController *controller,
                                                   NSString *name,
                                                   NSString *configuration,
                                                   NSString *actionKey,
                                                   NSString *propertyKey) {
        [baseWindow endSheet:controller.window];
        _newConfigurationWindowController = nil;
        
        if (!name)
            return;
        
        QCCDeploymentConfigurationContainer *configurationContainer = [QCCDeploymentConfiguration deploymentConfigurationWithName:name];
        [[wSelf deploymentConfiguration] addElement:configurationContainer toContainer:[wSelf latestSelectedConfigurationTreeElement]];
        QCConfigurationLevelNode *node = [QCConfigurationLevelNode treeNodeWithRepresentedObject:configurationContainer];
        [[[wSelf latestSelectedConfigurationNodeTree] mutableChildNodes] addObject:node];
        
        [_configurationTreeOutlineView reloadData];
        
    };
    
    QCCNewConfigurationWindowController *newConfigurationWindowController =
    [self newConfigurationWindowControllerForType:QCCNewConfigurationTypeDeployment
                                    comboBoxItems:nil
                                       completion:block];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [baseWindow beginSheet:newConfigurationWindowController.window completionHandler:nil];
    });
    
}


- (IBAction) removeProperty:(id)sender {

    QCConfigurationContainer *container = [self latestSelectedConfigurationTreeElement];
    QCConfigurationProperty *property = [self selectedProperty];
    [container removeChild:property];
    [_configurationValuesOutlineView reloadData];
}


- (IBAction) deleteLevelNode:(NSMenuItem *) sender {
    NSTreeNode *containerNode = [self latestSelectedConfigurationNodeTree];
    NSTreeNode *parentNode = [containerNode parentNode];
    QCConfigurationContainer *container = [self latestSelectedConfigurationTreeElement];
    
    if (!parentNode)
        return;
    
    QCConfigurationContainer *parentElement = parentNode.representedObject;
    if (![parentElement isKindOfClass:[QCConfigurationContainer class]])
        return;
    
    if (![[parentElement class] canAddElement:container])
        return;
    
    [parentElement removeChild:container];
    [[parentNode mutableChildNodes] removeObject:containerNode];
    [_configurationTreeOutlineView reloadData];
}


- (IBAction) addProperty:(id)sender {
    
    __weak NSWindow *baseWindow = [[self view] window];
    __weak QCConfigurationViewController * wSelf = self;
    
    if (![wSelf latestSelectedConfigurationTreeElement])
        return;
    
    
    PropertyConfiguratorCompletionBlock block = ^void (QCCPropertyConfiguratorWindowController * _Nonnull configuratorWindowController,
                                                       NSString * _Nonnull propertyValue,
                                                       NSString * _Nonnull propertyKey,
                                                       NSSet    * _Nonnull propertyActionList,
                                                       NSString * _Nonnull propertyUTTypeString,
                                                       BOOL isComplicatedValue,
                                                       PropertyType propertyType) {
        
        [baseWindow endSheet:configuratorWindowController.window];
        _newConfigurationWindowController = nil;
        
        if (propertyKey && propertyValue && propertyUTTypeString && propertyActionList) {
            
            QCCDeploymentConfiguration *dataSource = [wSelf deploymentConfiguration];
            
            NSString *localizationKey = [dataSource keyList][propertyKey];
            
            NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:@{QCCBaseConfigurationElementTypeKey : QCConfigurationPropertyKey,
                                                                                        QCConfigurationPropertyKeyKey: propertyKey,
                                                                                        QCConfigurationPropertyValueKey: propertyValue,
                                                                                        QCCBuildConfigurationUTIStringKey: propertyUTTypeString,
                                                                                        QCConfigurationPropertyActionKeyKey : [propertyActionList allObjects],
                                                                                        QCConfigurationPropertyTypeKey : @(propertyType),
                                                                                        QCConfigurationPropertyIsComplicatedValueKey : @(isComplicatedValue)
                                                                                        }];
            if (localizationKey)
                dict[QCConfigurationPropertyKeyLocalizationKey] = localizationKey;
            
            QCCBaseConfigurationElement *property = [QCCDeploymentConfiguration elementFromDictionary:dict];
            
            if(property) {
                [[wSelf deploymentConfiguration] addElement:property toContainer:[wSelf latestSelectedConfigurationTreeElement]];
                [_configurationValuesOutlineView reloadData];
            }
        }
    };
    
    _propertyConfiguratorWindowController = [[QCCPropertyConfiguratorWindowController alloc] initWithDataSource:[self deploymentConfiguration]
                                                                                                     completion:block];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [baseWindow beginSheet:_propertyConfiguratorWindowController.window completionHandler:nil];
    });

}

#pragma mark - New Element UI
- (QCCNewConfigurationWindowController *)newConfigurationWindowControllerForType:(QCCNewConfigurationType) type
                                                                   comboBoxItems:(NSDictionary *) comboBoxItems
                                                                      completion:(NewConfigurationCompletionBlock) block {
    
    if (_newConfigurationWindowController)
        return nil;

    _newConfigurationWindowController =  [[QCCNewConfigurationWindowController alloc] initWithType:type completion:block];
    [_newConfigurationWindowController setConfigurationComboBoxItems:comboBoxItems];
    
    return _newConfigurationWindowController;
}

@end



