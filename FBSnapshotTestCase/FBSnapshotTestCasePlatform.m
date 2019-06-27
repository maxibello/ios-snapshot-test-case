/*
 *  Copyright (c) 2017-2018, Uber Technologies, Inc.
 *  Copyright (c) 2015-2018, Facebook, Inc.
 *
 *  This source code is licensed under the MIT license found in the
 *  LICENSE file in the root directory of this source tree.
 *
 */

#import <FBSnapshotTestCase/FBSnapshotTestCasePlatform.h>
#import <UIKit/UIKit.h>

BOOL FBSnapshotTestCaseIs64Bit(void)
{
#if __LP64__
    return YES;
#else
    return NO;
#endif
}

NSOrderedSet *FBSnapshotTestCaseDefaultSuffixes(void)
{
    if (FBSnapshotTestCaseIs64Bit()) {
        return [NSOrderedSet orderedSetWithObject:@"_64"];
    } else {
        return [NSOrderedSet orderedSetWithObject:@"_32"];
    }
}

NSString *FBFileNameIncludeNormalizedFileNameFromOption(NSString *fileName, FBSnapshotTestCaseFileNameIncludeOption option)
{
    if (getenv("IS_UI_TESTING")) {
        #if TARGET_IPHONE_SIMULATOR
                NSString *deviceName = NSProcessInfo.processInfo.environment[@"SIMULATOR_DEVICE_NAME"];
                NSString *screenWidth = NSProcessInfo.processInfo.environment[@"SIMULATOR_MAINSCREEN_WIDTH"];
                NSString *screenHeight = NSProcessInfo.processInfo.environment[@"SIMULATOR_MAINSCREEN_HEIGHT"];
        
                fileName = [NSString stringWithFormat:@"%@_%@_%@x%@", fileName, deviceName, screenWidth, screenHeight];
        #else
                struct utsname systemInfo;
                NSString *model = [NSString stringWithCString:systemInfo.machine
                                                     encoding:NSUTF8StringEncoding];
                fileName = [NSString stringWithFormat:@"%@_%@_%@", fileName, model, os];
        #endif
    } else {
        if ((option & FBSnapshotTestCaseFileNameIncludeOptionDevice) == FBSnapshotTestCaseFileNameIncludeOptionDevice) {
            UIDevice *device = [UIDevice currentDevice];
            fileName = [fileName stringByAppendingFormat:@"_%@", device.model];
        }
        
        if ((option & FBSnapshotTestCaseFileNameIncludeOptionOS) == FBSnapshotTestCaseFileNameIncludeOptionOS) {
            UIDevice *device = [UIDevice currentDevice];
            NSString *os = device.systemVersion;
            fileName = [fileName stringByAppendingFormat:@"_%@", os];
        }
        
        if ((option & FBSnapshotTestCaseFileNameIncludeOptionScreenSize) == FBSnapshotTestCaseFileNameIncludeOptionScreenSize) {
            CGSize screenSize = [UIScreen mainScreen].bounds.size;
            fileName = [fileName stringByAppendingFormat:@"_%.0fx%.0f", screenSize.width, screenSize.height];
        }
    }

    NSMutableCharacterSet *invalidCharacters = [NSMutableCharacterSet new];
    [invalidCharacters formUnionWithCharacterSet:[NSCharacterSet whitespaceCharacterSet]];
    [invalidCharacters formUnionWithCharacterSet:[NSCharacterSet punctuationCharacterSet]];
    NSArray *validComponents = [fileName componentsSeparatedByCharactersInSet:invalidCharacters];
    fileName = [validComponents componentsJoinedByString:@"_"];

    if ((option & FBSnapshotTestCaseFileNameIncludeOptionScreenScale) == FBSnapshotTestCaseFileNameIncludeOptionScreenScale) {
        CGFloat screenScale = [[UIScreen mainScreen] scale];
        fileName = [fileName stringByAppendingFormat:@"@%.fx", screenScale];
    }

    return fileName;
}
