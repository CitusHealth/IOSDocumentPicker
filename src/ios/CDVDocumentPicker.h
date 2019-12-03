//
//  CDVDocumentPicker.h
//  CordovaLib
//
//  Created by Vinoy Alexander on 9/15/17.
//
//
#import <Cordova/CDVPlugin.h>

@interface CDVDocumentPicker : CDVPlugin <UIDocumentPickerDelegate>
- (void)pickFromICloud:(CDVInvokedUrlCommand*)command;
@end
