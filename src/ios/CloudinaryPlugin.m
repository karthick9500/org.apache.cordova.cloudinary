#import "CloudinaryPlugin.h"
#import <Cordova/CDVPluginResult.h>
#import "Cloudinary.h"
#import <AssetsLibrary/AssetsLibrary.h>


@implementation CloudinaryPlugin

- (void)uploadImage:(CDVInvokedUrlCommand*)command
{
    NSString* imagePath = [command argumentAtIndex:0];
    //NSLog(@"Image path: %@", imagePath);

    CLCloudinary *cloudinary = [self getCloudinary:command];
    NSDictionary* uploadOptions = [self getUploadOptions:command];
    
    CLUploader *uploader = [[CLUploader alloc] init:cloudinary delegate:self];
    
    [uploader upload:imagePath options:uploadOptions withCompletion:^(NSDictionary *successResult, NSString *errorResult, NSInteger code, id context) {
        if (successResult) {
            NSString* publicId = [successResult valueForKey:@"public_id"];
            NSLog(@"Block upload success. Public ID=%@, Full result=%@", publicId, successResult);
            
            CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:successResult];
            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
            
        } else {
            
            NSLog(@"La vara mamo: %@", errorResult);
            
            CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:successResult];
            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        }
    } andProgress:^(NSInteger bytesWritten, NSInteger totalBytesWritten, NSInteger totalBytesExpectedToWrite, id context) {
        NSLog(@"Block upload progress: %ld/%ld (+%ld)", (long)totalBytesWritten, (long)totalBytesExpectedToWrite, (long)bytesWritten);
    }];

    // NSURL *asseturl = [NSURL URLWithString:imagePath];
    
    
    // ALAssetsLibraryAssetForURLResultBlock resultblock = ^(ALAsset *myasset)
    // {
    //     NSLog(@"Si pude");
        
    //     ALAssetRepresentation *rep = [myasset defaultRepresentation];
    //     Byte *buffer = (Byte*)malloc(rep.size);
    //     NSUInteger buffered = [rep getBytes:buffer fromOffset:0.0 length:rep.size error:nil];
    //     NSData *data = [NSData dataWithBytesNoCopy:buffer length:buffered freeWhenDone:YES];
        
    //     CLCloudinary *cloudinary = [self getCloudinary:command];
    //     NSDictionary* uploadOptions = [self getUploadOptions:command];
        
    //     CLUploader *uploader = [[CLUploader alloc] init:cloudinary delegate:self];
        
    //     [uploader upload:data options:uploadOptions withCompletion:^(NSDictionary *successResult, NSString *errorResult, NSInteger code, id context) {
    //         if (successResult) {
    //             NSString* publicId = [successResult valueForKey:@"public_id"];
    //             NSLog(@"Block upload success. Public ID=%@, Full result=%@", publicId, successResult);
                
    //             CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:successResult];
    //             [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
                
    //         } else {
                
    //             NSLog(@"La vara mamo: %@", errorResult);
                
    //             CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:successResult];
    //             [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    //         }
    //     } andProgress:^(NSInteger bytesWritten, NSInteger totalBytesWritten, NSInteger totalBytesExpectedToWrite, id context) {
    //         NSLog(@"Block upload progress: %ld/%ld (+%ld)", (long)totalBytesWritten, (long)totalBytesExpectedToWrite, (long)bytesWritten);
    //     }];
    // };
    
    // //
    // ALAssetsLibraryAccessFailureBlock failureblock  = ^(NSError *myerror)
    // {
    //     NSLog(@"booya, cant get image - %@",[myerror localizedDescription]);
        
    //     NSDictionary* errorDic = [ [NSDictionary alloc]
    //                               initWithObjectsAndKeys :
    //                               false, @"success",
    //                               [myerror localizedDescription], @"message",
    //                               nil
    //                               ];
        
    //     CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:errorDic];
    //     [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    // };
    
    // if(imagePath && [imagePath length])
    // {
    //     ALAssetsLibrary* assetslibrary = [[ALAssetsLibrary alloc] init];
    //     [assetslibrary  assetForURL:asseturl
    //                     resultBlock:resultblock
    //                    failureBlock:failureblock];
    // }
}

//Read the cloudinary connection config settings
- (CLCloudinary*) getCloudinary:(CDVInvokedUrlCommand*)command
{
    NSMutableDictionary* config = [command.arguments objectAtIndex:3];
    NSString* cloudName = nil;
    NSString* apiKey = nil;
    NSString* apiSecret = nil;
    
    if(config != nil) {
        
        cloudName = (NSString*)[config objectForKey:@"cloudName"];
        apiKey = (NSString*)[config objectForKey:@"apiKey"];
        apiSecret = (NSString*)[config objectForKey:@"apiSecret"];
        
        if([cloudName length] == 0 || [apiKey length] == 0 || [apiSecret length] == 0) {
            
            NSBundle* mainBundle = [NSBundle mainBundle];
            cloudName = [mainBundle objectForInfoDictionaryKey:@"CloudinaryCloudName"];
            apiKey = [mainBundle objectForInfoDictionaryKey:@"CloudinaryApiKey"];
            apiSecret = [mainBundle objectForInfoDictionaryKey:@"CloudinaryApiSecret"];
        }
    }
    
    NSLog(@"Cloudianry cloud name: %@", cloudName);
    NSLog(@"Cloudianry api key: %@", apiKey);
    NSLog(@"Cloudianry api secret: %@", apiSecret);
    
    CLCloudinary *cloudinary = [[CLCloudinary alloc] init];
    [cloudinary.config setValue:cloudName forKey:@"cloud_name"];
    [cloudinary.config setValue:apiKey forKey:@"api_key"];
    [cloudinary.config setValue:apiSecret forKey:@"api_secret"];
    return cloudinary;
}

- (NSDictionary*) getUploadOptions:(CDVInvokedUrlCommand*)command
{
    NSDictionary* uploadOptions = @{};
    NSMutableDictionary* measures = [command.arguments objectAtIndex:1];
    NSString* imageTags = [command argumentAtIndex:2];
    
    //Check for measures
    if(measures != nil) {
        
        NSObject* height = [measures objectForKey:@"height"];
        NSObject* width = [measures objectForKey:@"width"];
        
        if(height != nil && width != nil) {
            NSLog(@"Tenemos dimensiones!");
        }
        else {
            NSLog(@"No hay dimensiones");
        }
    }
    
    if([imageTags length] != 0) {
        //[uploadOptions setValue:imageTags forKey:@"tags"];
    }
    
    return uploadOptions;
}

@end
