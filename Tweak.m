#import <UIKit/UIKit.h>

@interface UIApplication (_ah)
-(float)currentBacklightLevel;
@end

@interface SBBrightnessController : NSObject {
	BOOL _debounce;
}
+(id)sharedBrightnessController;
-(float)_calcButtonRepeatDelay;
-(void)adjustBacklightLevel:(BOOL)level;
-(void)_setBrightnessLevel:(float)level showHUD:(BOOL)hud;
-(void)setBrightnessLevel:(float)level;
-(void)increaseBrightnessAndRepeat;
-(void)decreaseBrightnessAndRepeat;
-(void)cancelBrightnessEvent;
@end

static BOOL enabled = FALSE;
NSString *message;

%subclass BrightnessIcon : SBApplicationIcon

-(void)launch {
	enabled = !enabled;
	if (enabled) {
		message = @"Volume buttons will now change brightness level";
	} else {
		message = @"Volume buttons will now have default behavior";
	}
	UIAlertView *alertview = [[UIAlertView alloc] init];
	[alertview setTitle:@"Mode Changed"];
	[alertview setMessage:message];
	[alertview addButtonWithTitle:@"Dismiss"];
	[alertview show];
	[alertview release];
}

%end


%hook VolumeControl

-(void)increaseVolume {
	if (enabled) {
        float currentBrightnessLevel = [[UIApplication sharedApplication] currentBacklightLevel];
        if (currentBrightnessLevel == 1.0f) {
            [[%c(SBBrightnessController) sharedBrightnessController] _setBrightnessLevel:1.0f showHUD:TRUE];
        } else {
            [[%c(SBBrightnessController) sharedBrightnessController] _setBrightnessLevel:currentBrightnessLevel + 0.0625f showHUD:TRUE];
        }
    } else {
        %orig;
    }
}

-(void)decreaseVolume {
	if (enabled) {
        float currentBrightnessLevel = [[UIApplication sharedApplication] currentBacklightLevel];
        if (currentBrightnessLevel == 0.0f) {
            [[%c(SBBrightnessController) sharedBrightnessController] _setBrightnessLevel:0.0f showHUD:TRUE];
        } else {
            [[%c(SBBrightnessController) sharedBrightnessController] _setBrightnessLevel:currentBrightnessLevel - 0.0625f showHUD:TRUE];
            
        }
    } else {
        %orig;
    }
}

%end