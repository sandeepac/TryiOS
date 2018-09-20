//
//  AudioAnalyzer.m
//  Tully Dev
//
//  Created by Kathan on 19/07/18.
//  Copyright © 2018 Tully. All rights reserved.
//

#import "AudioAnalyzer.h"
#import "SuperpoweredAnalyzer.h"
#import "SuperpoweredDecoder.h"
#import "SuperpoweredSimple.h"

int beat_load = 0;

@interface AudioAnalyzer ()

@end

@implementation AudioAnalyzer{
    
}


- (NSString *)analyze:(NSString*)path{
    NSURL *url1 = [[NSURL alloc] initWithString:path];
    NSLog(@"Value of hello = %@", path);
    
    SuperpoweredDecoder *decoder = new SuperpoweredDecoder();
    const char *openError = decoder->open([url1 fileSystemRepresentation], false, 0, 0);
    if (openError) {
        printf("Open error: %s\n", openError);
        delete decoder;
    };
    
    // Create the analyzer.
    SuperpoweredOfflineAnalyzer *analyzer = new SuperpoweredOfflineAnalyzer(decoder->samplerate, 0, decoder->durationSeconds);
    
    // Create a buffer for the 16-bit integer samples coming from the decoder.
    short int *intBuffer = (short int *)malloc(decoder->samplesPerFrame * 2 * sizeof(short int) + 32768);
    // Create a buffer for the 32-bit floating point samples required by the effect.
    float *floatBuffer = (float *)malloc(decoder->samplesPerFrame * 2 * sizeof(float) + 32768);
    
    // Processing.
    int progress = 0;
    while (true) {
        // Decode one frame. samplesDecoded will be overwritten with the actual decoded number of samples.
        unsigned int samplesDecoded = decoder->samplesPerFrame;
        if (decoder->decode(intBuffer, &samplesDecoded) == SUPERPOWEREDDECODER_ERROR) break;
        if (samplesDecoded < 1) break;
        
        // Convert the decoded PCM samples from 16-bit integer to 32-bit floating point.
        SuperpoweredShortIntToFloat(intBuffer, floatBuffer, samplesDecoded);
        
        // Submit samples to the analyzer.
        analyzer->process(floatBuffer, samplesDecoded);
        
        // Update the progress indicator.
        int p = int(((double)decoder->samplePosition / (double)decoder->durationSamples) * 100.0);
        if (progress != p) {
            progress = p;
            beat_load = p;
            NSDictionary *myData = @{@"data1" : [NSString stringWithFormat:@"%i", beat_load]};
            [[NSNotificationCenter defaultCenter] postNotificationName:@"beatLoaderNotification" object:nil userInfo:myData];
            //printf("\r%i%%", progress);
            fflush(stdout);
        }
    };
    
    // Get the result.
    unsigned char *averageWaveform = NULL, *lowWaveform = NULL, *midWaveform = NULL, *highWaveform = NULL, *peakWaveform = NULL, *notes = NULL;
    int waveformSize, overviewSize, keyIndex;
    char *overviewWaveform = NULL;
    float loudpartsAverageDecibel, peakDecibel, bpm, averageDecibel, beatgridStartMs = 0;
    analyzer->getresults(&averageWaveform, &peakWaveform, &lowWaveform, &midWaveform, &highWaveform, &notes, &waveformSize, &overviewWaveform, &overviewSize, &averageDecibel, &loudpartsAverageDecibel, &peakDecibel, &bpm, &beatgridStartMs, &keyIndex);
    
    const char *key = musicalChordNames[keyIndex];
    
    // Cleanup.
    delete decoder;
    delete analyzer;
    free(intBuffer);
    free(floatBuffer);
    
    // Do something with the result.
    
    NSString* n1 = [NSString stringWithFormat:@"%d", int(bpm)];
    NSString* n2 = [NSString stringWithFormat:@"%s", key];
    
    
    NSLog(@"\rBpm is %f, average loudness is %f db, peak volume is %f db.\n", bpm, loudpartsAverageDecibel, peakDecibel);
    
    // Done with the result, free memory.
    if (averageWaveform) free(averageWaveform);
    if (lowWaveform) free(lowWaveform);
    if (midWaveform) free(midWaveform);
    if (highWaveform) free(highWaveform);
    if (peakWaveform) free(peakWaveform);
    if (notes) free(notes);
    if (overviewWaveform) free(overviewWaveform);
    
    NSString* data = [NSString stringWithFormat: @"%@,%@", n1, n2];
    return data;
}

@end
