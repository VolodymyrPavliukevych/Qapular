//
//  QCCProjectProcessor+Launcher.h
//  Qapular
//
//  Created by Volodymyr Pavliukevych.
//  Copyright © 2014 Volodymyr Pavliukevych. All rights reserved.
//

#import "QCCProjectProcessor.h"

@interface QCCProjectProcessor (Launcher) <QCCProcessDocumentProtocol>

#pragma mark - Action helper
- (void (^ _Nonnull)(BaseAction * _Nonnull, NSProgress * _Nonnull, NSError * _Nullable)) actionProgressClosure;
- (void (^ _Nonnull)(BaseAction * _Nonnull, BasePhase * _Nonnull, NSDictionary<NSString *, NSString *> * _Nonnull)) actionReportClosure;
@end
