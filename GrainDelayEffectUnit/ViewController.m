//
//  ViewController.m
//  GrainDelayEffectUnit
//
//  Created by Thibault Mounes on 03/06/2016.
//  Copyright © 2016 Thibault Mounes. All rights reserved.
//

#import "ViewController.h"
#import "TheAmazingAudioEngine.h"
#import "AEPlaythroughChannel.h"
#import "Heavy_SynthTest2.h"


void printHook(double timestampMs, const char *printLabel, const char *msgString, void *userData) {
    printf("[@ %.3fms] %s: %s\n", timestampMs, printLabel, msgString);
}


// interface stands for "CLASS" in objective C

@interface ViewController ()

/* Mandatory elements to process sound within an app */

{
    Hv_SynthTest2 *context; //heavy uploaded patch name (Here "SynthTest2")
}

//AE elements -> "the amazing audio engine" : does all the work I would take hours to learn at the moment.

@property AEAudioController *audioController;           //contains the main audio engine, manages the audio doing the "dirty" work
@property AEPlaythroughChannel *playthroughChannel;     //provides audio monitoring
@property AEBlockFilter *blockFilter;                   //class which allows to process audio with blocks

/* Graphic Elements */
- (IBAction)slider1ValueChanged:(UISlider *)sender;
- (IBAction)slider2ValueChanged:(UISlider *)sender;
- (IBAction)slider3ValueChanged:(UISlider *)sender;
- (IBAction)slider4ValueChanged:(UISlider *)sender;
- (IBAction)sliderFeedbackValueChanged:(UISlider *)sender;
- (IBAction)slider6ValueChanged:(UISlider *)sender;
- (IBAction)switchValueChanged:(UISegmentedControl *)sender;
- (IBAction)slider7ValueChanged:(UISlider *)sender;
- (IBAction)oscAmpSliderValueChanged:(UISlider *)sender;
- (IBAction)lfoFreqSliderValueChanged:(UISlider *)sender;
- (IBAction)lfoAmpSliderValueChanged:(UISlider *)sender;
- (IBAction)lfoToggleValueChanged:(UISwitch *)sender;
- (IBAction)presetChange:(UISegmentedControl *)sender;

@property (weak, nonatomic) IBOutlet UISegmentedControl *inputSwitchFeedback;
@property (weak, nonatomic) IBOutlet UISlider *oscFreqFeedback;
@property (weak, nonatomic) IBOutlet UISlider *oscAmpFeedback;
@property (weak, nonatomic) IBOutlet UISlider *lfoFreqFeedback;
@property (weak, nonatomic) IBOutlet UISlider *lfoAmpFeedback;
@property (weak, nonatomic) IBOutlet UISwitch *lfoSwitchfeedback;
@property (weak, nonatomic) IBOutlet UISlider *grainSizeFeedback;
@property (weak, nonatomic) IBOutlet UISlider *pitchFeedback;
@property (weak, nonatomic) IBOutlet UISlider *randPitchFeedback;
@property (weak, nonatomic) IBOutlet UISlider *delayTimeFeedback;
@property (weak, nonatomic) IBOutlet UISlider *feedbackFeedback;
@property (weak, nonatomic) IBOutlet UISlider *dryWetFeedback;




@end



@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    double sampleRate = 44100.0;
    
    // Heavy setup
    
    context = hv_SynthTest2_new(sampleRate);
    hv_setPrintHook(context, &printHook);   // set print hook
    
    int numInputChannels = hv_getNumInputChannels(context);
    int numOutputChannels = hv_getNumOutputChannels(context);
    
    // AE AudioController setup
    
    AudioStreamBasicDescription asbd = [AEAudioController nonInterleavedFloatStereoAudioDescription];   //describes audio streams format (interleaved,non interleaved,inline)
    self.audioController = [[AEAudioController alloc] initWithAudioDescription:asbd inputEnabled:YES];   //audiocontroller allocation, initialization, input active/inactive
    self.audioController.preferredBufferDuration = 0.005;   //linked to frame size through sample rate
    
    // AE Playthrough Channel setup
    
    self.playthroughChannel = [[AEPlaythroughChannel alloc] init];
    [self.audioController addChannels:@[self.playthroughChannel]];
    [self.audioController addInputReceiver:self.playthroughChannel];
    
    // AE Block Filter (audio process
    
    self.blockFilter =
    [AEBlockFilter filterWithBlock:^(AEAudioFilterProducer producer, void *producerToken, const AudioTimeStamp *time, UInt32 frames, AudioBufferList *audio)
     {
         
         // Pull audio from microphone
         OSStatus status = producer(producerToken, audio, &frames);
         if ( status != noErr ) return;
         
         // Now filter audio in 'audio'
         float *leftBuffer = (float *)audio->mBuffers[0].mData;
         float *rightBuffer = (float *)audio->mBuffers[1].mData;
         
         float *inputBuffers[2] = {leftBuffer, rightBuffer};
         float **outputBuffers = inputBuffers;
         
         hv_SynthTest2_process(context, inputBuffers, outputBuffers, frames);    //"applies" the pd patch, can take inputBuffer or/and outputBuffer
         
     }];
    
    [self.audioController addFilter:self.blockFilter toChannel:self.playthroughChannel];
    
    [self.audioController start:nil];
    
}

- (IBAction)slider1ValueChanged:(UISlider *)sender {
    float value = sender.value*29900 + 100;
    hv_sendFloatToReceiver(context, hv_stringToHash("grainSize"), value);
}

- (IBAction)slider2ValueChanged:(UISlider *)sender {
    float value = (sender.value * 2 - 1)*36;
    hv_sendFloatToReceiver(context, hv_stringToHash("pitch"), value);
}

- (IBAction)slider3ValueChanged:(UISlider *)sender {
    float value = sender.value*3;
    hv_sendFloatToReceiver(context, hv_stringToHash("randPitch"), value);
}

- (IBAction)slider4ValueChanged:(UISlider *)sender {
    float value = sender.value*2500;
    hv_sendFloatToReceiver(context, hv_stringToHash("delayTime"), value);
}

- (IBAction)sliderFeedbackValueChanged:(UISlider *)sender {
    float value = sender.value*0.99;
    hv_sendFloatToReceiver(context, hv_stringToHash("feedback"), value);
}

- (IBAction)slider6ValueChanged:(UISlider *)sender {
    float value = sender.value;
    hv_sendFloatToReceiver(context, hv_stringToHash("dryWet"), value);
}

- (IBAction)switchValueChanged:(UISegmentedControl *)sender {
    hv_sendBangToReceiver(context, hv_stringToHash("sourceSwitch"));
}

- (IBAction)slider7ValueChanged:(UISlider *)sender {
    float value = sender.value*5000;
    hv_sendFloatToReceiver(context, hv_stringToHash("oscFreq"), value);
}

- (IBAction)oscAmpSliderValueChanged:(UISlider *)sender {
    float value = sender.value*0.6;
    hv_sendFloatToReceiver(context, hv_stringToHash("oscAmp"), value);
}

- (IBAction)lfoFreqSliderValueChanged:(UISlider *)sender {
    float value = sender.value*25;
    hv_sendFloatToReceiver(context, hv_stringToHash("lfoFreq"), value);
}

- (IBAction)lfoAmpSliderValueChanged:(UISlider *)sender {
    float value = sender.value*1000;
    hv_sendFloatToReceiver(context, hv_stringToHash("lfoAmp"), value);
}

- (IBAction)lfoToggleValueChanged:(UISwitch *)sender {
    hv_sendBangToReceiver(context, hv_stringToHash("lfoToggle"));
}

- (IBAction)presetChange:(UISegmentedControl *)sender {
    long presetNumber = sender.selectedSegmentIndex;
    
    switch (presetNumber) {
        case 0:
            hv_sendFloatToReceiver(context, hv_stringToHash("pitch"), 6.);
            self.pitchFeedback.value = 0.583;
            hv_sendFloatToReceiver(context, hv_stringToHash("grainSize"), 20000.);
            self.grainSizeFeedback.value = 0.666;
            hv_sendFloatToReceiver(context, hv_stringToHash("randPitch"), 3.);
            self.randPitchFeedback.value = 1;
            hv_sendFloatToReceiver(context, hv_stringToHash("feedback"), 0.651);
            self.feedbackFeedback.value = 0.403;
            hv_sendFloatToReceiver(context, hv_stringToHash("dryWet"), 1.);
            self.dryWetFeedback.value = 1;
            hv_sendFloatToReceiver(context, hv_stringToHash("delayTime"), 32.);
            self.delayTimeFeedback.value = 0.0128;
            hv_sendFloatToReceiver(context, hv_stringToHash("lfoToggle"), 1.);
            [self.lfoSwitchfeedback setOn:YES];
            //hv_sendBangToReceiver(context, hv_stringToHash("lfoToggle"));
            hv_sendFloatToReceiver(context, hv_stringToHash("lfoFreq"), 1.);
            self.lfoFreqFeedback.value = 0.04;
            hv_sendFloatToReceiver(context, hv_stringToHash("lfoAmp"), 7.);
            self.lfoAmpFeedback.value = 0.007;
            hv_sendFloatToReceiver(context, hv_stringToHash("oscFreq"), 865.);
            self.oscFreqFeedback.value = 0.173;
            hv_sendFloatToReceiver(context, hv_stringToHash("oscAmp"), 0.3);
            self.oscAmpFeedback.value = 0.5;
            hv_sendFloatToReceiver(context, hv_stringToHash("sourceSwitch"), 1.);
            [self.inputSwitchFeedback setSelectedSegmentIndex:1];
            //hv_sendBangToReceiver(context, hv_stringToHash("sourceSwitch"));
            NSLog(@"preset 1 was pressed");
            
            break;
            
        case 1:
            hv_sendFloatToReceiver(context, hv_stringToHash("pitch"), 10.);
            self.pitchFeedback.value = 0.63;
            hv_sendFloatToReceiver(context, hv_stringToHash("grainSize"), 17286.);
            self.grainSizeFeedback.value = 0.575;
            hv_sendFloatToReceiver(context, hv_stringToHash("randPitch"), 3.);
            self.randPitchFeedback.value = 1;
            hv_sendFloatToReceiver(context, hv_stringToHash("feedback"), 0.69);                         self.feedbackFeedback.value = 0.69;
            hv_sendFloatToReceiver(context, hv_stringToHash("dryWet"), 1.);
            self.dryWetFeedback.value = 1;
            hv_sendFloatToReceiver(context, hv_stringToHash("delayTime"), 78.);
            self.delayTimeFeedback.value = 0.0312;
            hv_sendFloatToReceiver(context, hv_stringToHash("lfoToggle"), 0.);
            [self.lfoSwitchfeedback setOn:NO];
            //hv_sendBangToReceiver(context, hv_stringToHash("lfoToggle"));
            hv_sendFloatToReceiver(context, hv_stringToHash("lfoFreq"), 0.);
                        self.lfoFreqFeedback.value = 0.0;
            hv_sendFloatToReceiver(context, hv_stringToHash("lfoAmp"), 0.);
                        self.lfoAmpFeedback.value = 0.0;
            hv_sendFloatToReceiver(context, hv_stringToHash("oscFreq"), 0.);
                        self.oscFreqFeedback.value = 0.0;
            hv_sendFloatToReceiver(context, hv_stringToHash("oscAmp"), 0);
                        self.oscAmpFeedback.value = 0;
            hv_sendFloatToReceiver(context, hv_stringToHash("sourceSwitch"), 0.);
            [self.inputSwitchFeedback setSelectedSegmentIndex:0];
            //hv_sendBangToReceiver(context, hv_stringToHash("sourceSwitch"));
            NSLog(@"preset 2 was pressed");
            
            break;

        case 2:
            hv_sendFloatToReceiver(context, hv_stringToHash("pitch"), -8.);
            self.pitchFeedback.value = 0.389;
            hv_sendFloatToReceiver(context, hv_stringToHash("grainSize"), 24114.);
            self.grainSizeFeedback.value = 0.803;
            hv_sendFloatToReceiver(context, hv_stringToHash("randPitch"), 0.);
                        self.randPitchFeedback.value = 0;
            hv_sendFloatToReceiver(context, hv_stringToHash("feedback"), 0.99);
                        self.feedbackFeedback.value = 1;
            hv_sendFloatToReceiver(context, hv_stringToHash("dryWet"), 1.);
                        self.dryWetFeedback.value = 1;
            hv_sendFloatToReceiver(context, hv_stringToHash("delayTime"), 304.);
                        self.delayTimeFeedback.value = 0.122;
            hv_sendFloatToReceiver(context, hv_stringToHash("lfoToggle"), 0.);
            [self.lfoSwitchfeedback setOn:NO];
            //hv_sendBangToReceiver(context, hv_stringToHash("lfoToggle"));
            hv_sendFloatToReceiver(context, hv_stringToHash("lfoFreq"), 0.);
                        self.lfoFreqFeedback.value = 0.0;
            hv_sendFloatToReceiver(context, hv_stringToHash("lfoAmp"), 0.);
                        self.lfoAmpFeedback.value = 0.00;
            hv_sendFloatToReceiver(context, hv_stringToHash("oscFreq"), 0.);
                        self.oscFreqFeedback.value = 0.0;
            hv_sendFloatToReceiver(context, hv_stringToHash("oscAmp"), 0);
                        self.oscAmpFeedback.value = 0;
            hv_sendFloatToReceiver(context, hv_stringToHash("sourceSwitch"), 0.);
            [self.inputSwitchFeedback setSelectedSegmentIndex:0];
            //hv_sendBangToReceiver(context, hv_stringToHash("sourceSwitch"));
            NSLog(@"preset 3 was pressed");
            
            break;

        default:
            break;
    }
    
}

@end
