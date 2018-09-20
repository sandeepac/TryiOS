//
//  SuperpoweredRecorderWrapped.m
//  Tully Dev
//
//  Created by Kathan on 01/07/18.
//  Copyright © 2018 Tully. All rights reserved.
//

//#import <Foundation/Foundation.h>

//#include <functional>
//#include <string>
//#include <sstream>
//#include <iostream>

#import "SuperpoweredRecorder.h"
#import "SuperpoweredRecorderWrapped.h"
#import "SuperpoweredAdvancedAudioPlayer.h"
#import "SuperpoweredFilter.h"
#import "SuperpoweredRoll.h"
#import "SuperpoweredFlanger.h"
#import "SuperpoweredIOSAudioIO.h"
#import "SuperpoweredSimple.h"
#import <stdlib.h>



#define HEADROOM_DECIBEL 3.0f
static const float headroom = powf(10.0f, -HEADROOM_DECIBEL * 0.025);
bool playerAEOF = false;
bool playerBEOF = false;

bool flag = false;


//@interface SuperpoweredRecorderWrapped (){
//    SuperpoweredRecorder *_wrapped;
//}
//@end

@implementation SuperpoweredRecorderWrapped{
    SuperpoweredAdvancedAudioPlayer *playerA, *playerB;
    SuperpoweredIOSAudioIO *output;
    unsigned char activeFx;
    float *stereoBuffer, crossValue, volA, volB;
    unsigned int lastSamplerate;
}


void playerEventCallbackA(void *clientData, SuperpoweredAdvancedAudioPlayerEvent event, void *value) {
    SuperpoweredRecorderWrapped *self = (__bridge SuperpoweredRecorderWrapped *)clientData;
    if (event == SuperpoweredAdvancedAudioPlayerEvent_LoadSuccess) {
        //self->playerA->setBpm(126.0f);
        //self->playerA->setFirstBeatMs(353);
        self->playerA->setPosition(self->playerA->firstBeatMs, false, false);
    }else if(event == SuperpoweredAdvancedAudioPlayerEvent_LoadError){
        NSLog(@"getting some error");
        NSDictionary *myData = @{@"index" : @"0"};
        [[NSNotificationCenter defaultCenter] postNotificationName:@"audioSuperPowerError" object:nil userInfo:myData];
    }else if (event == SuperpoweredAdvancedAudioPlayerEvent_EOF){
        playerAEOF = true;
        self->playerA->pause();
    }
}

void playerEventCallbackB(void *clientData, SuperpoweredAdvancedAudioPlayerEvent event, void *value) {
    SuperpoweredRecorderWrapped *self = (__bridge SuperpoweredRecorderWrapped *)clientData;
    if (event == SuperpoweredAdvancedAudioPlayerEvent_LoadSuccess) {
        //self->playerB->setBpm(123.0f);
//        self->playerB->setFirstBeatMs(40);
        self->playerB->setPosition(self->playerB->firstBeatMs, false, false);
    }else if(event == SuperpoweredAdvancedAudioPlayerEvent_LoadError){
        NSLog(@"getting some error");
        NSDictionary *myData = @{@"index" : @"1"};
        [[NSNotificationCenter defaultCenter] postNotificationName:@"audioSuperPowerError" object:nil userInfo:myData];
    }else if (event == SuperpoweredAdvancedAudioPlayerEvent_EOF){
        playerBEOF = true;
        self->playerB->pause();
    }
}

// This is where the Superpowered magic happens.
static bool audioProcessing(void *clientdata, float **buffers, unsigned int inputChannels, unsigned int outputChannels, unsigned int numberOfSamples, unsigned int samplerate, uint64_t hostTime) {
    __unsafe_unretained SuperpoweredRecorderWrapped *self = (__bridge SuperpoweredRecorderWrapped *)clientdata;
    if (samplerate != self->lastSamplerate) { // Has samplerate changed?
        self->lastSamplerate = samplerate;
        self->playerA->setSamplerate(samplerate);
        self->playerB->setSamplerate(samplerate);
    };
    
    bool masterIsA = (self->crossValue <= 0.5f);
    float masterBpm = masterIsA ? self->playerA->currentBpm : self->playerB->currentBpm; // Players will sync to this tempo.
    double msElapsedSinceLastBeatA = self->playerA->msElapsedSinceLastBeat; // When playerB needs it, playerA has already stepped this value, so save it now.
    
    bool silence = !self->playerA->process(self->stereoBuffer, false, numberOfSamples, self->volA, masterBpm, self->playerB->msElapsedSinceLastBeat);
    if (self->playerB->process(self->stereoBuffer, !silence, numberOfSamples, self->volB, masterBpm, msElapsedSinceLastBeatA)) silence = false;
    
    if (!silence) SuperpoweredDeInterleave(self->stereoBuffer, buffers[0], buffers[1], numberOfSamples); // The stereoBuffer is ready now, let's put the finished audio into the requested buffers.
    return !silence;
}

- (void) initializeData:(NSString*)path1 :(NSString*)path2 {

    playerAEOF = false;
    playerBEOF = false;
    
    NSURL *url1 = [[NSURL alloc] initWithString:path1];
    NSURL *url2 = [[NSURL alloc] initWithString:path2];
    
    lastSamplerate = activeFx = 0;
    crossValue = volB = 0.0f;
    volA = 1.0f * headroom;
    if (posix_memalign((void **)&stereoBuffer, 16, 4096 + 128) != 0) abort(); // Allocating memory, aligned to 16.
    playerA = new SuperpoweredAdvancedAudioPlayer((__bridge void *)self, playerEventCallbackA, 44100, 0);
    playerA->open([url1 fileSystemRepresentation]);
    
    playerB = new SuperpoweredAdvancedAudioPlayer((__bridge void *)self, playerEventCallbackB, 44100, 0);
    playerB->open([url2 fileSystemRepresentation]);
    
    playerA->syncMode = playerB->syncMode = SuperpoweredAdvancedAudioPlayerSyncMode_TempoAndBeat;
    
    output = [[SuperpoweredIOSAudioIO alloc] initWithDelegate:(id<SuperpoweredIOSAudioIODelegate>)self preferredBufferSize:12 preferredMinimumSamplerate:44100 audioSessionCategory:AVAudioSessionCategoryPlayback channels:2 audioProcessingCallback:audioProcessing clientdata:(__bridge void *)self];
    [output start];
}

- (void)dealloc {
    delete playerA;
    delete playerB;
    free(stereoBuffer);
#if !__has_feature(objc_arc)
    [output release];
    [super dealloc];
#endif
}

- (void)interruptionStarted {}
- (void)recordPermissionRefused {}
- (void)mapChannels:(multiOutputChannelMap *)outputMap inputMap:(multiInputChannelMap *)inputMap externalAudioDeviceName:(NSString *)externalAudioDeviceName outputsAndInputs:(NSString *)outputsAndInputs {}

- (void)interruptionEnded { // If a player plays Apple Lossless audio files, then we need this. Otherwise unnecessary.
    playerA->onMediaserverInterrupt();
    playerB->onMediaserverInterrupt();
}

- (void)onPlayPause:(int)play {
   // UIButton *button = (UIButton *)sender;
    if(play == 0){
        playerA->pause();
        playerB->pause();
    }else{
        bool masterIsA = (crossValue <= 0.5f);
        playerAEOF = false;
        playerBEOF = false;
        playerA->play(!masterIsA);
        playerB->play(masterIsA);
    }
    //button.selected = playerA->playing;
}

- (void)stopPlay{
    playerA->pause();
    playerB->pause();
    [output stop];
    free(stereoBuffer);
}

- (void)playAudio:(int)index{
    bool masterIsA = (crossValue <= 0.5f);
    playerAEOF = false;
    playerBEOF = false;
    if(index == 0){
        playerA->play(!masterIsA);
    }else{
        playerB->play(masterIsA);
    }
}

- (void)pauseAudio:(int)index{
    if(index == 0){
        playerA->pause();
    }else{
        playerB->pause();
    }
}



- (NSString *) currentPlayerTimeA{
    int a1 = playerA->positionSeconds;
    int a2 = (playerA->playing ? 1 : 0);
    int a3 = (playerAEOF ? 1 : 0);
    int a4 = playerA->durationSeconds;
    NSString* n1 = [NSString stringWithFormat:@"%i", a1];
    NSString* n2 = [NSString stringWithFormat:@"%i", a2];
    NSString* n3 = [NSString stringWithFormat:@"%i", a3];
    NSString* n4 = [NSString stringWithFormat:@"%i", a4];
    NSString* data = [NSString stringWithFormat: @"%@,%@,%@,%@", n1, n2, n3, n4];
    return data;
}

- (NSString *)currentPlayerTimeB{
    int a1 = playerB->positionSeconds;
    int a2 = (playerB->playing ? 1 : 0);
    int a3 = (playerBEOF ? 1 : 0);
    int a4 = playerB->durationSeconds;
    NSString* n1 = [NSString stringWithFormat:@"%i", a1];
    NSString* n2 = [NSString stringWithFormat:@"%i", a2];
    NSString* n3 = [NSString stringWithFormat:@"%i", a3];
    NSString* n4 = [NSString stringWithFormat:@"%i", a4];
    NSString* data = [NSString stringWithFormat: @"%@,%@,%@,%@", n1, n2, n3, n4];
    return data;
}

//onVolumeChange

- (void)onVolumeChange:(float)vol1 : (float)vol2 : (float)delta {
    crossValue = delta;
    volA = vol1;
    volB = vol2;
}


- (void)onCrossFader:(float)crossValue {
    //crossValue = ((UISlider *)sender).value;
    
    NSLog(@"Value of hello = %f", crossValue);
    if (crossValue < 0.01f) {
        volA = 1.0f * headroom;
        volB = 0.0f;
    } else if (crossValue > 0.99f) {
        volA = 0.0f;
        volB = 1.0f * headroom;
    } else { // constant power curve
        volA = cosf(M_PI_2 * crossValue) * headroom;
        volB = cosf(M_PI_2 * (1.0f - crossValue)) * headroom;
    };
}

static inline float floatToFrequency(float value) {
    static const float min = logf(20.0f) / logf(10.0f);
    static const float max = logf(20000.0f) / logf(10.0f);
    static const float range = max - min;
    return powf(10.0f, value * range + min);
}

- (IBAction)onFxSelect:(id)sender {
    activeFx = ((UISegmentedControl *)sender).selectedSegmentIndex;
}

@end

