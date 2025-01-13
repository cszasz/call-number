#import <Cordova/CDVPlugin.h>
#import "CFCallNumber.h"

@implementation CFCallNumber

+ (BOOL)available {
    return [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"tel://"]];
}

- (void) callNumber:(CDVInvokedUrlCommand*)command {
    
    [self.commandDelegate runInBackground:^{
        
        __block CDVPluginResult* pluginResult = nil;
        NSString* number = [command.arguments objectAtIndex:0];
        number = [number stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        
        if(![number hasPrefix:@"tel:"]){
            number =  [NSString stringWithFormat:@"tel:%@", number];
        }

        // run in mainthread as below 
        dispatch_async(dispatch_get_main_queue(), ^{
            if (![CFCallNumber available]) {
                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"NoFeatureCallSupported"];
            } else {
                NSURL *url = [NSURL URLWithString:number];
                if (url && [[UIApplication sharedApplication] canOpenURL:url]) {
                    if (@available(iOS 10.0, *)) {
                        [[UIApplication sharedApplication] openURL:url
                                                           options:@{}
                                                 completionHandler:^(BOOL success) {
                            if (success) {
                                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
                            } else {
                                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"CouldNotCallPhoneNumber"];
                            }
                        }];
                    } else {
                        // For iOS versions earlier than 10.0
                        if ([[UIApplication sharedApplication] openURL:url]) {
                            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
                        } else {
                            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"CouldNotCallPhoneNumber"];
                        }
                    }
                } else {
                    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"InvalidPhoneNumber"];
                }
            }
        });

        // return result
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        
    }];
}

- (void) isCallSupported:(CDVInvokedUrlCommand*)command {
    [self.commandDelegate runInBackground: ^{
        CDVPluginResult* pluginResult = [CDVPluginResult
                                         resultWithStatus:CDVCommandStatus_OK
                                         messageAsBool:[CFCallNumber available]];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
}

@end
