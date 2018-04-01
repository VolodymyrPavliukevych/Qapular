//
//  QCCDeploymentConfiguration+QCCPropertyConfiguratorDataSource.m
//  QCCDeploymentConfigurationKit
//
//  Created by Vladimir Pavliukevych
//  Copyright © Vladimir Pavliukevych. All rights reserved.
//

#import "QCCDeploymentConfiguration+QCCPropertyConfiguratorDataSource.h"
#import "QCCDeploymentConfiguration+UTCoreTypes.h"

@implementation QCCDeploymentConfiguration (QCCPropertyConfiguratorDataSource)

#pragma mark QCCPropertyConfiguratorDataSource

- (nonnull NSDictionary <NSString *, NSString *>*) keyList {
    
    static NSMutableDictionary *localization;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        
        localization = [NSMutableDictionary new];
        
        for (NSString *key in [self defaultFrontPropertyList]) {
            NSString *value = [self defaultFrontPropertyList][key][QCConfigurationPropertyKeyLocalizationKey];
            if (value)
                localization[key] = value;
        }
    });
    
    return localization;
}

- (nonnull NSDictionary <NSString *, NSString *>*) actionList {
    return [self.dataSource actionKeyList];
}

- (nonnull NSDictionary <NSString *, NSString *>*) UTTypeList {
    return [[self class] UTIPropertyDictionary];
}

- (NSDictionary <NSString *, NSDictionary *>*) defaultFrontPropertyList {
    
    return @{@"%DASH_STRING_PROPERTY%": @{QCCBaseConfigurationElementTypeKey : QCConfigurationPropertyKey,
                                          QCConfigurationPropertyKeyKey: @"%DASH_STRING_PROPERTY%",
                                          QCConfigurationPropertyValueKey: @"-",
                                          QCCBuildConfigurationUTIStringKey: [[self class] identifierForUTType:kUTTypeSourceCode],
                                          QCConfigurationPropertyActionKeyKey : @[@"%CLEAR%", @"%INDEX%", @"%ANALYZE%", @"%COMPILE%", @"%UPLOAD%", @"%RUN%", @"%DEBUG%", @"%ERASE%"],
                                          QCConfigurationPropertyTypeKey : @(PropertyTypeFront),
                                          QCConfigurationPropertyKeyLocalizationKey: @"Dashed string property."},
             
             @"%DOUBLE_DASH_STRING_PROPERTY%": @{QCCBaseConfigurationElementTypeKey : QCConfigurationPropertyKey,
                                          QCConfigurationPropertyKeyKey: @"%DOUBLE_DASH_STRING_PROPERTY%",
                                          QCConfigurationPropertyValueKey: @"--",
                                          QCCBuildConfigurationUTIStringKey: [[self class] identifierForUTType:kUTTypeSourceCode],
                                          QCConfigurationPropertyActionKeyKey : @[@"%CLEAR%", @"%INDEX%", @"%ANALYZE%", @"%COMPILE%", @"%UPLOAD%", @"%RUN%", @"%DEBUG%", @"%ERASE%"],
                                          QCConfigurationPropertyTypeKey : @(PropertyTypeFront),
                                          QCConfigurationPropertyKeyLocalizationKey: @"Double dashed string property."},
             
             @"%SIMPLE_STRING%": @{QCCBaseConfigurationElementTypeKey : QCConfigurationPropertyKey,
                                   QCConfigurationPropertyKeyKey: @"%SIMPLE_STRING%",
                                   QCConfigurationPropertyValueKey: @"",
                                   QCCBuildConfigurationUTIStringKey: [[self class] identifierForUTType:kUTTypeSourceCode],
                                   QCConfigurationPropertyActionKeyKey : @[@"%CLEAR%", @"%INDEX%", @"%ANALYZE%", @"%COMPILE%", @"%UPLOAD%", @"%RUN%", @"%DEBUG%", @"%ERASE%"],
                                   QCConfigurationPropertyTypeKey : @(PropertyTypeFront),
                                   QCConfigurationPropertyKeyLocalizationKey: @"Simple string property."},
             
             @"%GCC_ENABLE_OPTION%": @{QCCBaseConfigurationElementTypeKey : QCConfigurationPropertyKey,
                                       QCConfigurationPropertyKeyKey: @"%GCC_ENABLE_OPTION%",
                                       QCConfigurationPropertyValueKey: @"-f",
                                       QCCBuildConfigurationUTIStringKey: [[self class] identifierForUTType:kUTTypeSourceCode],
                                       QCConfigurationPropertyActionKeyKey : @[@"%CLEAR%", @"%INDEX%", @"%ANALYZE%", @"%COMPILE%", @"%UPLOAD%", @"%RUN%", @"%DEBUG%", @"%ERASE%"],
                                       QCConfigurationPropertyTypeKey : @(PropertyTypeFront),
                                       QCConfigurationPropertyKeyLocalizationKey: @"Enable GCC options flag."},
             
             @"%GCC_DISABLE_OPTION%": @{QCCBaseConfigurationElementTypeKey : QCConfigurationPropertyKey,
                                        QCConfigurationPropertyKeyKey: @"%GCC_DISABLE_OPTION%",
                                        QCConfigurationPropertyValueKey: @"-fno-",
                                        QCCBuildConfigurationUTIStringKey: [[self class] identifierForUTType:kUTTypeSourceCode],
                                        QCConfigurationPropertyActionKeyKey : @[@"%CLEAR%", @"%INDEX%", @"%ANALYZE%", @"%COMPILE%", @"%UPLOAD%", @"%RUN%", @"%DEBUG%", @"%ERASE%"],
                                        QCConfigurationPropertyTypeKey : @(PropertyTypeFront),
                                        QCConfigurationPropertyKeyLocalizationKey: @"Disable GCC options flag."},
             
             @"%GCC_ENABLE_WARNING%": @{QCCBaseConfigurationElementTypeKey : QCConfigurationPropertyKey,
                                        QCConfigurationPropertyKeyKey: @"%GCC_ENABLE_WARNING%",
                                        QCConfigurationPropertyValueKey: @"-W",
                                        QCCBuildConfigurationUTIStringKey: [[self class] identifierForUTType:kUTTypeSourceCode],
                                        QCConfigurationPropertyActionKeyKey : @[@"%CLEAR%", @"%INDEX%", @"%ANALYZE%", @"%COMPILE%", @"%UPLOAD%", @"%RUN%", @"%DEBUG%", @"%ERASE%"],
                                        QCConfigurationPropertyTypeKey : @(PropertyTypeFront),
                                        QCConfigurationPropertyKeyLocalizationKey: @"Enable GCC warning flag."},
             
             @"%GCC_DISABLE_WARNING%": @{QCCBaseConfigurationElementTypeKey : QCConfigurationPropertyKey,
                                         QCConfigurationPropertyKeyKey: @"%GCC_DISABLE_WARNING%",
                                         QCConfigurationPropertyValueKey: @"-Wno-",
                                         QCCBuildConfigurationUTIStringKey: [[self class] identifierForUTType:kUTTypeSourceCode],
                                         QCConfigurationPropertyActionKeyKey : @[@"%CLEAR%", @"%INDEX%", @"%ANALYZE%", @"%COMPILE%", @"%UPLOAD%", @"%RUN%", @"%DEBUG%", @"%ERASE%"],
                                         QCConfigurationPropertyTypeKey : @(PropertyTypeFront),
                                         QCConfigurationPropertyKeyLocalizationKey: @"Disable GCC warning flag."},
             
             @"%OPTIMIZATIONS_LEVEL%": @{QCCBaseConfigurationElementTypeKey : QCConfigurationPropertyKey,
                                         QCConfigurationPropertyKeyKey: @"%OPTIMIZATIONS_LEVEL%",
                                         QCConfigurationPropertyValueKey: @"-O",
                                         QCCBuildConfigurationUTIStringKey: [[self class] identifierForUTType:kUTTypeSourceCode],
                                         QCConfigurationPropertyActionKeyKey : @[@"%CLEAR%", @"%INDEX%", @"%ANALYZE%", @"%COMPILE%", @"%UPLOAD%", @"%RUN%", @"%DEBUG%", @"%ERASE%"],
                                         QCConfigurationPropertyTypeKey : @(PropertyTypeFront),
                                         QCConfigurationPropertyKeyLocalizationKey: @"GCC Optimizations level."},
             
             @"%GCC_INCLUDE_PATH%": @{QCCBaseConfigurationElementTypeKey : QCConfigurationPropertyKey,
                                      QCConfigurationPropertyKeyKey: @"%GCC_INCLUDE_PATH%",
                                      QCConfigurationPropertyValueKey: @"-I",
                                      QCCBuildConfigurationUTIStringKey: [[self class] identifierForUTType:kUTTypeSourceCode],
                                      QCConfigurationPropertyActionKeyKey : @[@"%CLEAR%", @"%INDEX%", @"%ANALYZE%", @"%COMPILE%", @"%UPLOAD%", @"%RUN%", @"%DEBUG%", @"%ERASE%"],
                                      QCConfigurationPropertyTypeKey : @(PropertyTypeFront),
                                      QCConfigurationPropertyKeyLocalizationKey: @"GCC Include search Path."},
             
             @"%GCC_SYS_ROOT_PATH%": @{QCCBaseConfigurationElementTypeKey : QCConfigurationPropertyKey,
                                       QCConfigurationPropertyKeyKey: @"%GCC_SYS_ROOT_PATH%",
                                       QCConfigurationPropertyValueKey: @"--sysroot=",
                                       QCCBuildConfigurationUTIStringKey: [[self class] identifierForUTType:kUTTypeSourceCode],
                                       QCConfigurationPropertyActionKeyKey : @[@"%CLEAR%", @"%INDEX%", @"%ANALYZE%", @"%COMPILE%", @"%UPLOAD%", @"%RUN%", @"%DEBUG%", @"%ERASE%"],
                                       QCConfigurationPropertyTypeKey : @(PropertyTypeFront),
                                       QCConfigurationPropertyKeyLocalizationKey: @"GCC dir as the logical root directory for headers and libraries"},
             
             @"%GCC_INCLUDE_AND_SYS_ROOT_PATH%": @{QCCBaseConfigurationElementTypeKey : QCConfigurationPropertyKey,
                                                   QCConfigurationPropertyKeyKey: @"%GCC_INCLUDE_AND_SYS_ROOT_PATH%",
                                                   QCConfigurationPropertyValueKey: @"-isysroot",
                                                   QCCBuildConfigurationUTIStringKey: [[self class] identifierForUTType:kUTTypeSourceCode],
                                                   QCConfigurationPropertyActionKeyKey : @[@"%CLEAR%", @"%INDEX%", @"%ANALYZE%", @"%COMPILE%", @"%UPLOAD%", @"%RUN%", @"%DEBUG%", @"%ERASE%"],
                                                   QCConfigurationPropertyTypeKey : @(PropertyTypeFront),
                                                   QCConfigurationPropertyKeyLocalizationKey: @"GCC dir as the logical root directory for headers and libraries"},
             
             @"%GCC_LIBRARY_PATH%": @{QCCBaseConfigurationElementTypeKey : QCConfigurationPropertyKey,
                                      QCConfigurationPropertyKeyKey: @"%GCC_LIBRARY_PATH%",
                                      QCConfigurationPropertyValueKey: @"-l",
                                      QCCBuildConfigurationUTIStringKey: [[self class] identifierForUTType:kUTTypeSourceCode],
                                      QCConfigurationPropertyActionKeyKey : @[@"%CLEAR%", @"%INDEX%", @"%ANALYZE%", @"%COMPILE%", @"%UPLOAD%", @"%RUN%", @"%DEBUG%", @"%ERASE%"],
                                      QCConfigurationPropertyTypeKey : @(PropertyTypeFront),
                                      QCConfigurationPropertyKeyLocalizationKey: @"GCC library Search Path."},
             
             @"%GCC_LIBRARY_DIR_PATH%": @{QCCBaseConfigurationElementTypeKey : QCConfigurationPropertyKey,
                                          QCConfigurationPropertyKeyKey: @"%GCC_LIBRARY_DIR_PATH%",
                                          QCConfigurationPropertyValueKey: @"-L",
                                          QCCBuildConfigurationUTIStringKey: [[self class] identifierForUTType:kUTTypeSourceCode],
                                          QCConfigurationPropertyActionKeyKey : @[@"%CLEAR%", @"%INDEX%", @"%ANALYZE%", @"%COMPILE%", @"%UPLOAD%", @"%RUN%", @"%DEBUG%", @"%ERASE%"],
                                          QCConfigurationPropertyTypeKey : @(PropertyTypeFront),
                                          QCConfigurationPropertyKeyLocalizationKey: @"GCC Library dir search Path."},
             
             @"%DETERMINE_LANGUAGE_STANDARD%": @{QCCBaseConfigurationElementTypeKey : QCConfigurationPropertyKey,
                                                 QCConfigurationPropertyKeyKey: @"%DETERMINE_LANGUAGE_STANDARD%",
                                                 QCConfigurationPropertyValueKey: @"-std=",
                                                 QCCBuildConfigurationUTIStringKey: [[self class] identifierForUTType:kUTTypeSourceCode],
                                                 QCConfigurationPropertyActionKeyKey : @[@"%CLEAR%", @"%INDEX%", @"%ANALYZE%", @"%COMPILE%", @"%UPLOAD%", @"%RUN%", @"%DEBUG%", @"%ERASE%"],
                                                 QCConfigurationPropertyTypeKey : @(PropertyTypeFront),
                                                 QCConfigurationPropertyKeyLocalizationKey: @"Determine the language standard."},
             
             @"%GCC_PREDEFINE_MACRO%": @{QCCBaseConfigurationElementTypeKey : QCConfigurationPropertyKey,
                                         QCConfigurationPropertyKeyKey: @"%GCC_PREDEFINE_MACRO%",
                                         QCConfigurationPropertyValueKey: @"-D",
                                         QCCBuildConfigurationUTIStringKey: [[self class] identifierForUTType:kUTTypeSourceCode],
                                         QCConfigurationPropertyActionKeyKey : @[@"%CLEAR%", @"%INDEX%", @"%ANALYZE%", @"%COMPILE%", @"%UPLOAD%", @"%RUN%", @"%DEBUG%", @"%ERASE%"],
                                         QCConfigurationPropertyTypeKey : @(PropertyTypeFront),
                                         QCConfigurationPropertyKeyLocalizationKey: @"Predefine name as a macro, with definition."},
             
             @"%MENTION_HEADER_FILES_OPTION%": @{QCCBaseConfigurationElementTypeKey : QCConfigurationPropertyKey,
                                                 QCConfigurationPropertyKeyKey: @"%MENTION_HEADER_FILES_OPTION%",
                                                 QCConfigurationPropertyValueKey: @"-M",
                                                 QCCBuildConfigurationUTIStringKey: [[self class] identifierForUTType:kUTTypeSourceCode],
                                                 QCConfigurationPropertyActionKeyKey : @[@"%CLEAR%", @"%INDEX%", @"%ANALYZE%", @"%COMPILE%", @"%UPLOAD%", @"%RUN%", @"%DEBUG%", @"%ERASE%"],
                                                 QCConfigurationPropertyTypeKey : @(PropertyTypeFront),
                                                 QCConfigurationPropertyKeyLocalizationKey: @"Preprocessor mention header files option."},
             
             @"%AVR_IMPLEMENTATION_OPTION%": @{QCCBaseConfigurationElementTypeKey : QCConfigurationPropertyKey,
                                               QCConfigurationPropertyKeyKey: @"%AVR_IMPLEMENTATION_OPTION%",
                                               QCConfigurationPropertyValueKey: @"-mmcu=",
                                               QCCBuildConfigurationUTIStringKey: [[self class] identifierForUTType:kUTTypeSourceCode],
                                               QCConfigurationPropertyActionKeyKey : @[@"%CLEAR%", @"%INDEX%", @"%ANALYZE%", @"%COMPILE%", @"%UPLOAD%", @"%RUN%", @"%DEBUG%", @"%ERASE%"],
                                               QCConfigurationPropertyTypeKey : @(PropertyTypeFront),
                                               QCConfigurationPropertyKeyLocalizationKey: @"AVR implementations option."},
             
             @"%GCC_LANGUAGE_SPECIFICATION%": @{QCCBaseConfigurationElementTypeKey : QCConfigurationPropertyKey,
                                                QCConfigurationPropertyKeyKey: @"%GCC_LANGUAGE_SPECIFICATION%",
                                                QCConfigurationPropertyValueKey: @"-x",
                                                QCCBuildConfigurationUTIStringKey: [[self class] identifierForUTType:kUTTypeSourceCode],
                                                QCConfigurationPropertyActionKeyKey : @[@"%CLEAR%", @"%INDEX%", @"%ANALYZE%", @"%COMPILE%", @"%UPLOAD%", @"%RUN%", @"%DEBUG%", @"%ERASE%"],
                                                QCConfigurationPropertyTypeKey : @(PropertyTypeFront),
                                                QCConfigurationPropertyKeyLocalizationKey: @"GCC language specification."},
             
             @"%GCC_MACHINE_ARCHITECTURE%": @{QCCBaseConfigurationElementTypeKey : QCConfigurationPropertyKey,
                                                QCConfigurationPropertyKeyKey: @"%GCC_MACHINE_ARCHITECTURE%",
                                                QCConfigurationPropertyValueKey: @"-march=",
                                                QCCBuildConfigurationUTIStringKey: [[self class] identifierForUTType:kUTTypeSourceCode],
                                                QCConfigurationPropertyActionKeyKey : @[@"%CLEAR%", @"%INDEX%", @"%ANALYZE%", @"%COMPILE%", @"%UPLOAD%", @"%RUN%", @"%DEBUG%", @"%ERASE%"],
                                                QCConfigurationPropertyTypeKey : @(PropertyTypeFront),
                                                QCConfigurationPropertyKeyLocalizationKey: @"Machine architecture Generate instructions for the machine type cpu-type."}
             
             
             
             
             };
    
    
    
}

@end
