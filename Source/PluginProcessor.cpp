/*
  ==============================================================================

    This file contains the basic framework code for a JUCE plugin processor.

  ==============================================================================
*/

#include "PluginProcessor.h"
#include "PluginEditor.h"


//==============================================================================
HeartBitAudioProcessor::HeartBitAudioProcessor()
#ifndef JucePlugin_PreferredChannelConfigurations
: AudioProcessor(
          BusesProperties()
#if !JucePlugin_IsMidiEffect
#if !JucePlugin_IsSynth
              .withInput("Input", juce::AudioChannelSet::stereo(), true)
#endif
              .withOutput("Output", juce::AudioChannelSet::stereo(), true)
#endif
              ),
#else
    :
#endif
      parameters(*this, 
                nullptr, 
                juce::Identifier("LowpassAndHighpassPlugin"),
                {std::make_unique<juce::AudioParameterFloat>(
                    "cutoff_frequency", 
                    "Cutoff Frequency",
                    juce::NormalisableRange{20.f, 
                                            20000.f, 
                                            0.1f, 
                                            0.2f, 
                                            false},
                    500.f),
                 std::make_unique<juce::AudioParameterBool>(
                    "highpass", 
                    "Highpass", 
                    false)}) {
  cutoffFrequencyParameter =
      parameters.getRawParameterValue("cutoff_frequency");
  highpassParameter = parameters.getRawParameterValue("highpass");
}

HeartBitAudioProcessor::~HeartBitAudioProcessor()
{
}

//==============================================================================
const juce::String HeartBitAudioProcessor::getName() const
{
    return JucePlugin_Name;
}

bool HeartBitAudioProcessor::acceptsMidi() const
{
   #if JucePlugin_WantsMidiInput
    return true;
   #else
    return false;
   #endif
}

bool HeartBitAudioProcessor::producesMidi() const
{
   #if JucePlugin_ProducesMidiOutput
    return true;
   #else
    return false;
   #endif
}

bool HeartBitAudioProcessor::isMidiEffect() const
{
   #if JucePlugin_IsMidiEffect
    return true;
   #else
    return false;
   #endif
}

double HeartBitAudioProcessor::getTailLengthSeconds() const
{
    return 0.0;
}

int HeartBitAudioProcessor::getNumPrograms()
{
    return 1;   // NB: some hosts don't cope very well if you tell them there are 0 programs,
                // so this should be at least 1, even if you're not really implementing programs.
}

int HeartBitAudioProcessor::getCurrentProgram()
{
    return 0;
}

void HeartBitAudioProcessor::setCurrentProgram (int index)
{
}

const juce::String HeartBitAudioProcessor::getProgramName (int index)
{
    return {};
}

void HeartBitAudioProcessor::changeProgramName (int index, const juce::String& newName)
{
}

//==============================================================================
void HeartBitAudioProcessor::prepareToPlay (double sampleRate, int samplesPerBlock)
{
    // Use this method as the place to do any pre-playback
    // initialisation that you need..
    filter.setSamplingRate(static_cast<float>(sampleRate));
}

void HeartBitAudioProcessor::releaseResources()
{
    // When playback stops, you can use this as an opportunity to free up any
    // spare memory, etc.
}

#ifndef JucePlugin_PreferredChannelConfigurations
bool HeartBitAudioProcessor::isBusesLayoutSupported (const BusesLayout& layouts) const
{
  #if JucePlugin_IsMidiEffect
    juce::ignoreUnused (layouts);
    return true;
  #else
    // This is the place where you check if the layout is supported.
    // In this template code we only support mono or stereo.
    // Some plugin hosts, such as certain GarageBand versions, will only
    // load plugins that support stereo bus layouts.
    if (layouts.getMainOutputChannelSet() != juce::AudioChannelSet::mono()
     && layouts.getMainOutputChannelSet() != juce::AudioChannelSet::stereo())
        return false;

    // This checks if the input layout matches the output layout
   #if ! JucePlugin_IsSynth
    if (layouts.getMainOutputChannelSet() != layouts.getMainInputChannelSet())
        return false;
   #endif

    return true;
  #endif
}
#endif

void HeartBitAudioProcessor::processBlock (juce::AudioBuffer<float>& buffer, juce::MidiBuffer& midiMessages)
{
    juce::ScopedNoDenormals noDenormals;
    auto totalNumInputChannels  = getTotalNumInputChannels();
    auto totalNumOutputChannels = getTotalNumOutputChannels();

    // In case we have more outputs than inputs, this code clears any output
    // channels that didn't contain input data, (because these aren't
    // guaranteed to be empty - they may contain garbage).
    // This is here to avoid people getting screaming feedback
    // when they first compile a plugin, but obviously you don't need to keep
    // this code if your algorithm always overwrites all the output channels.
    for (auto i = totalNumInputChannels; i < totalNumOutputChannels; ++i)
        buffer.clear (i, 0, buffer.getNumSamples());
    
    // retrieve and set the parameter values
    const auto cutoffFrequency = cutoffFrequencyParameter->load();
    // in C++, std::atomic<T> to T conversion is equivalent to a load
    const auto highpass = *highpassParameter < 0.5f ? false : true;
    filter.setCutoffFrequency(cutoffFrequency);
    filter.setHighpass(highpass);

    // perform the filtering
    filter.processBlock(buffer, midiMessages);
    
    // This is the place where you'd normally do the guts of your plugin's
    // audio processing...
    // Make sure to reset the state if your inner loop is processing
    // the samples and the outer loop is handling the channels.
    // Alternatively, you can process the samples with the channels
    // interleaved by keeping the same state.
    for (int channel = 0; channel < totalNumInputChannels; ++channel)
    {
        auto* channelData = buffer.getWritePointer (channel);

        // ..do something to the data...
    }
}






//==============================================================================
bool HeartBitAudioProcessor::hasEditor() const
{
    return true; // (change this to false if you choose to not supply an editor)
}

juce::AudioProcessorEditor* HeartBitAudioProcessor::createEditor()
{
    return new HeartBitAudioProcessorEditor (*this, parameters);
}

//==============================================================================
void HeartBitAudioProcessor::getStateInformation (juce::MemoryBlock& destData)
{
    // You should use this method to store your parameters in the memory block.
    // You could do that either as raw data, or use the XML or ValueTree classes
    // as intermediaries to make it easy to save and load complex data.
}

void HeartBitAudioProcessor::setStateInformation (const void* data, int sizeInBytes)
{
    // You should use this method to restore your parameters from this memory block,
    // whose contents will have been created by the getStateInformation() call.
}

//==============================================================================
// This creates new instances of the plugin..
juce::AudioProcessor* JUCE_CALLTYPE createPluginFilter()
{
    return new HeartBitAudioProcessor();
}