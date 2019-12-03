//
//  CDVDocumentPicker.m
//  CordovaLib
//
//  Created by Vinoy Alexander on 9/15/17.
//
//

#import "CDVDocumentPicker.h"

@implementation CDVDocumentPicker

CDVInvokedUrlCommand *commandGlobal;
CDVPluginResult *pluginResultGlobal;

- (void)pickFromICloud:(CDVInvokedUrlCommand*)command
{
    
    CDVPluginResult* pluginResult = nil;
    pluginResultGlobal = pluginResult;
    
    commandGlobal = command;
    
    UIDocumentPickerViewController *documentPicker = [[UIDocumentPickerViewController alloc] initWithDocumentTypes:@[@"public.data"]
                                                                                                            inMode:UIDocumentPickerModeImport];
    documentPicker.delegate = self;
    
    documentPicker.modalPresentationStyle = UIModalPresentationFormSheet;
    
    [self.viewController presentViewController:documentPicker animated:YES completion:^{
        if (@available(iOS 11.0, *)) {
            documentPicker.allowsMultipleSelection = true;
        } else {
            // Fallback on earlier versions
        }
    }];
}

#pragma mark - iCloud files
- (void)documentPicker:(UIDocumentPickerViewController *)controller didPickDocumentAtURL:(NSURL *)url {
    /*if (controller.documentPickerMode == UIDocumentPickerModeImport) {
     
     long long int fileSize = [[[NSFileManager defaultManager] attributesOfItemAtPath:[url path] error:nil][NSFileSize] longLongValue];
     
     NSDictionary *fileDictionary = @{ @"name" : [[[url lastPathComponent] componentsSeparatedByString:@"."] objectAtIndex:0],
     @"type" : [self mimeTypeForFileAtPath:[url path]],
     @"url":[url absoluteString],
     @"size":[NSString stringWithFormat:@"%lld",fileSize],
     @"extension":[[[url lastPathComponent] componentsSeparatedByString:@"."] objectAtIndex:1]
     };
     
     //NSLog(@"dict - %llu",fileSize);
     
     pluginResultGlobal = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:fileDictionary];
     
     [self.commandDelegate sendPluginResult:pluginResultGlobal callbackId:commandGlobal.callbackId];
     }*/
    
    if (controller.documentPickerMode == UIDocumentPickerModeImport) {
        
        NSMutableArray *mutArray = [[NSMutableArray alloc] init];
        
        NSDictionary *fileDictionary;
        NSMutableDictionary *resultantDictionary = [[NSMutableDictionary alloc] init];
        [resultantDictionary setObject:[NSNumber numberWithBool:NO] forKey:@"folderSelection"];
            long long int fileSize = [[[NSFileManager defaultManager] attributesOfItemAtPath:[url path] error:nil][NSFileSize] longLongValue];
            
            NSLog(@"type=%@",[self mimeTypeForFileAtPath:[url path]]);
            

                fileDictionary = @{ @"name" :[[[url lastPathComponent] componentsSeparatedByString:@"."] objectAtIndex:0] ,
                                    @"type" : [self mimeTypeForFileAtPath:[url path]],
                                    @"url":[url absoluteString],
                                    @"size":[NSString stringWithFormat:@"%lld",fileSize],
                                    @"extension":[url pathExtension]
                                    };
                [mutArray addObject:fileDictionary];
        
        
        [resultantDictionary setValue:mutArray forKey:@"icloudArray"];
        
        NSLog(@"resultant -> %@",resultantDictionary);
        
        pluginResultGlobal = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:(NSDictionary *)resultantDictionary];
        [self.commandDelegate sendPluginResult:pluginResultGlobal callbackId:commandGlobal.callbackId];
    }
}

- (void)documentPickerWasCancelled:(UIDocumentPickerViewController *)controller {
    pluginResultGlobal = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"documentPickerWasCancelled"];
    
    [self.commandDelegate sendPluginResult:pluginResultGlobal callbackId:commandGlobal.callbackId];
}

- (void)documentPicker:(UIDocumentPickerViewController *)controller didPickDocumentsAtURLs:(NSArray <NSURL *>*)urls  {
    
    NSLog(@"URLS -> %@",urls);
    
    if (controller.documentPickerMode == UIDocumentPickerModeImport) {
        
        NSMutableArray *mutArray = [[NSMutableArray alloc] init];
        
        NSDictionary *fileDictionary;
        NSMutableDictionary *resultantDictionary = [[NSMutableDictionary alloc] init];
        [resultantDictionary setObject:[NSNumber numberWithBool:NO] forKey:@"folderSelection"];
        
        for (NSURL *url in urls) {
            long long int fileSize = [[[NSFileManager defaultManager] attributesOfItemAtPath:[url path] error:nil][NSFileSize] longLongValue];
            
            NSLog(@"type=%@",[self mimeTypeForFileAtPath:[url path]]);
            
            if (![self mimeTypeForFileAtPath:[url path]]) {
                NSLog(@"folder selected");
                [resultantDictionary setObject:[NSNumber numberWithBool:YES] forKey:@"folderSelection"];
            }
            else {
                fileDictionary = @{ @"name" :[[[url lastPathComponent] componentsSeparatedByString:@"."] objectAtIndex:0] ,
                                    @"type" : [self mimeTypeForFileAtPath:[url path]],
                                    @"url":[url absoluteString],
                                    @"size":[NSString stringWithFormat:@"%lld",fileSize],
                                    @"extension":[url pathExtension]
                                    };
                [mutArray addObject:fileDictionary];
            }
        }
        
        [resultantDictionary setValue:mutArray forKey:@"icloudArray"];
        
        NSLog(@"resultant -> %@",resultantDictionary);
        
        pluginResultGlobal = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:(NSDictionary *)resultantDictionary];
        [self.commandDelegate sendPluginResult:pluginResultGlobal callbackId:commandGlobal.callbackId];
    }
}

- (NSString*) mimeTypeForFileAtPath: (NSString *) path {
    // NSURL will read the entire file and may exceed available memory if the file is large enough. Therefore, we will write the first fiew bytes of the file to a head-stub for NSURL to get the MIMEType from.
    if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
        return nil;
    }
    
    NSFileHandle *readFileHandle = [NSFileHandle fileHandleForReadingAtPath:path];
    NSData *fileHead = [readFileHandle readDataOfLength:100]; // we probably only need 2 bytes. we'll get the first 100 instead.
    
    NSString *tempPath = [NSHomeDirectory() stringByAppendingPathComponent: @"tmp/fileHead.tmp"];
    
    [[NSFileManager defaultManager] removeItemAtPath:tempPath error:nil]; // delete any existing version of fileHead.tmp
    if ([fileHead writeToFile:tempPath atomically:YES])
    {
        NSURL* fileUrl = [NSURL fileURLWithPath:path];
        NSURLRequest* fileUrlRequest = [[NSURLRequest alloc] initWithURL:fileUrl cachePolicy:NSURLCacheStorageNotAllowed timeoutInterval:1];
        
        NSError* error = nil;
        NSURLResponse* response = nil;
        [NSURLConnection sendSynchronousRequest:fileUrlRequest returningResponse:&response error:&error];
        [[NSFileManager defaultManager] removeItemAtPath:tempPath error:nil];
        return [response MIMEType];
    }
    return nil;
}

@end
