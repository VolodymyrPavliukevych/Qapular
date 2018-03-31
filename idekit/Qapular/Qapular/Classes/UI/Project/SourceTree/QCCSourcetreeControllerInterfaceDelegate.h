//
//  QCCSourcetreeControllerInterfaceDelegate.h
//  Qapular Code Composer
//
//  Created by Volodymyr Pavliukevych.
//  Copyright (c) 2015 Qapular. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol QCCSourcetreeControllerInterfaceDelegate <NSObject>

- (void) invalidateItem:(id) item children:(BOOL) children;

// Unfortunately NSOutlineView reloadItem:reloadChildren: doesn't work with group
// So I add just reloadData
- (void) invalidateGroup:(id) group;

@end
