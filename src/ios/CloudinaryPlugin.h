#import <Cordova/CDVPlugin.h>

@interface CloudinaryPlugin : CDVPlugin

- (void)uploadImage:(CDVInvokedUrlCommand*)command;

@end
