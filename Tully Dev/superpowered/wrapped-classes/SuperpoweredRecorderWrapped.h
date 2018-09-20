//
//  SuperpoweredRecorderWrapped.h
//  Tully Dev
//
//  Created by Kathan on 01/07/18.
//  Copyright © 2018 Tully. All rights reserved.
//

//#ifndef SuperpoweredRecorderWrapped_h
//#define SuperpoweredRecorderWrapped_h
//
//#import <Foundation/Foundation.h>

#import <UIKit/UIKit.h>


@interface SuperpoweredRecorderWrapped : NSObject

//-(id)init:(NSString*)str sampleRate:(uint)sampleRate;
//-(void)start: (NSString*)str;
//-(void)stop;

- (void)initializeData:(NSString*)path1 : (NSString*)path2;
- (void)onPlayPause:(int)play;
- (void)onCrossFader:(float)crossValue;
- (void)onVolumeChange:(float)vol1 : (float)vol2: (float)delta;
- (void)playAudio:(int)index;
- (void)pauseAudio:(int)index;
- (NSString *)currentPlayerTimeA;
- (NSString *)currentPlayerTimeB;
- (IBAction)onFxSelect:(id)sender;
- (void)stopPlay;

@end

//#endif /* SuperpoweredRecorderWrapped_h */
