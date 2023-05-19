/*
  ==============================================================================

    This file contains the basic framework code for a JUCE plugin editor.

  ==============================================================================
*/

#pragma once

#include <JuceHeader.h>
#include "PluginProcessor.h"

//==============================================================================
/**
*/
class HeartBitAudioProcessorEditor  : public juce::AudioProcessorEditor,
                                      private juce::OSCReceiver,
                                      private juce::OSCReceiver::ListenerWithOSCAddress<juce::OSCReceiver::MessageLoopCallback>
{
public:
    HeartBitAudioProcessorEditor (HeartBitAudioProcessor&, juce::AudioProcessorValueTreeState& vts);
    ~HeartBitAudioProcessorEditor() override;

    //==============================================================================
    void paint (juce::Graphics&) override;
    void resized() override;

private:
    // This reference is provided as a quick way for your editor to
    // access the processor object that created it.
    HeartBitAudioProcessor& audioProcessor;
    juce::Slider cutoffFrequencySlider;
    std::unique_ptr<juce::AudioProcessorValueTreeState::SliderAttachment>
        cutoffFrequencyAttachment;
    juce::Label cutoffFrequencyLabel;

    juce::ToggleButton highpassButton;
    std::unique_ptr<juce::AudioProcessorValueTreeState::ButtonAttachment>
        highpassAttachment;
    juce::Label highpassButtonLabel;
    
    void HeartBitAudioProcessorEditor::showConnectionErrorMessage (const juce::String& messageText)
    {
        juce::AlertWindow::showMessageBoxAsync (juce::AlertWindow::WarningIcon,
                                                "Connection error",
                                                messageText,
                                                "OK");
    }

void HeartBitAudioProcessorEditor::oscMessageReceived (const juce::OSCMessage& message)
    {
        if (message.size() == 1 && message[0].isFloat32()) 
            cutoffFrequencySlider.setValue (juce::jlimit (200.0f, 20000.0f, message[0].getFloat32())); 
    }


    JUCE_DECLARE_NON_COPYABLE_WITH_LEAK_DETECTOR (HeartBitAudioProcessorEditor)
};

