//
//  QCCDeploymentConfiguration+UTCoreTypes.m
//  QCCDeploymentConfigurationKit
//
//  Created by Vladimir Pavliukevych
//  Copyright © Vladimir Pavliukevych. All rights reserved.
//

#import "QCCDeploymentConfiguration+UTCoreTypes.h"

@implementation QCCDeploymentConfiguration (UTCoreTypes)

+ (NSDictionary *) UTIPropertyDictionary {
    
    static dispatch_once_t onceToken;
    static NSMutableDictionary *propertyDictionary;
    dispatch_once(&onceToken, ^{
        
        propertyDictionary = [NSMutableDictionary new];
        NSString *identifier = [self identifierForUTType:kUTTypeSourceCode];
        NSString *description = [self descriptionForUTType:kUTTypeSourceCode];
        if (identifier && description)
            propertyDictionary[identifier] = description;
        
        identifier = [self identifierForUTType:kUTTypeAssemblyLanguageSource];
        description = [self descriptionForUTType:kUTTypeAssemblyLanguageSource];
        if (identifier && description)
            propertyDictionary[identifier] = description;
        
        identifier = [self identifierForUTType:kUTTypeCSource];
        description = [self descriptionForUTType:kUTTypeCSource];
        if (identifier && description)
            propertyDictionary[identifier] = description;
        
        identifier = [self identifierForUTType:kUTTypeObjectiveCSource];
        description = [self descriptionForUTType:kUTTypeObjectiveCSource];
        if (identifier && description)
            propertyDictionary[identifier] = description;
        
        
        identifier = [self identifierForUTType:kUTTypeCPlusPlusSource];
        description = [self descriptionForUTType:kUTTypeCPlusPlusSource];
        if (identifier && description)
            propertyDictionary[identifier] = description;
        
        identifier = [self identifierForUTType:kUTTypeObjectiveCPlusPlusSource];
        description = [self descriptionForUTType:kUTTypeObjectiveCPlusPlusSource];
        if (identifier && description)
            propertyDictionary[identifier] = description;
        
        identifier = [self identifierForUTType:kUTTypeCHeader];
        description = [self descriptionForUTType:kUTTypeCHeader];
        if (identifier && description)
            propertyDictionary[identifier] = description;
        
        identifier = [self identifierForUTType:kUTTypeCPlusPlusHeader];
        description = [self descriptionForUTType:kUTTypeCPlusPlusHeader];
        if (identifier && description)
            propertyDictionary[identifier] = description;

        identifier = [self identifierForUTType:kUTTypeArchive];
        description = [self descriptionForUTType:kUTTypeArchive];
        if (identifier && description)
            propertyDictionary[identifier] = description;
        
        identifier = [self identifierForUTType:kUTTypeContent];
        description = [self descriptionForUTType:kUTTypeContent];
        if (identifier && description)
            propertyDictionary[identifier] = description;
    });
    
    
    return propertyDictionary;
}

+ (NSString *) identifierForUTType:(CFStringRef) type {
    CFDictionaryRef utiDecl = UTTypeCopyDeclaration(type);
    CFStringRef identifier = CFDictionaryGetValue(utiDecl, kUTTypeIdentifierKey);
    return (__bridge NSString *)(identifier);
}

+ (NSString *) descriptionForUTType:(CFStringRef) type {
    CFDictionaryRef utiDecl = UTTypeCopyDeclaration(type);
    CFStringRef description = CFDictionaryGetValue(utiDecl, kUTTypeDescriptionKey);
    return (__bridge NSString *)(description);
}

@end
