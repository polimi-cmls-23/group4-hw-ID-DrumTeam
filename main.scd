(
var heart, door, steps, stepForest, stepForest2, wind, howl, chains, choir;
var b1, b2, b3, b4, b5, b6;
var sndOrg, envOrg;
var durArray, sigG, envG, harms, harmAmp, delayS, delay, outSig, outG, mfreqG;
var sigF, envF, noise, noiseEnv, filterEnv;
var envP, fbIn, sndP;
var envSB, in, ina, synca, octa, inb, syncb, octb, octave, sndSB;
var freqarray, amparray, decarray, exciterMB, sndMB;
var envV, sigV;
var freqarrayAD, amparrayAD, decarrayAD, exciterAD, sndAD;
var exciterH, root, octaveH, sndH;

var oscBass, filterBass, envBass, filterBassEnv, sndBass, chorusfx;

var aminH = [440, 493.88, 523.25, 587.33, 659.25, 698.46, 830.61];
var bell = [415.30, 440, 523.25, 698.46];
var drone = [55, 82.41];

var backgroundColor;
var fog1, fog2, fog3, fog4, red;
var bgH, bgF, bgC, bgS;
var volume1, volume2, volume3, slider1, slider2, slider3;
var width = 400, height = 400;
var xspeed = 0.4, x2speed = 0.5, x3speed = 0.2, x4speed = 0.3;
var x = -400, x2 = 1200, x3 = -800, x4 = 1300, op = 0.0;
var modeH, modeF, modeC, modeR, fontButton, colorLight, colorDark;
var sndBell, ring, ringEnv, ringFreqs, strike, strikeEnv, strikeMod, hum, humEnv;

var volumeG, volumeV, volumeB, volumeP, volumeBass, volumeD, volumeH, volumeT, volumeO;

var ascii;

var probDoor = [0, 0, 0, 0, 0, 0, 0, 0, 0, 1];
var probSteps = [0,0,0,0,0,0,0,0.5];
var probHowl = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1];
var probWind = [0, 0, 0, 1];
var probChains = [0, 1];
var probChoir = [0, 0, 0, 1];

~houseActive = 0;
~forestActive = 0;
~churchActive = 0;

~ampG = 0.75;
~ampV = 0.1;
~ampB = 0.05;
~ampP = 0.1;
~ampWind = 1;
~ampBass = 0.1;
~ampD = 0.5;
~ampH = 0.1;
~ampT = 0.05;
~ampO = 0.25;
~ampChoir = 1;

~bpm = 70;

(
SynthDef (\heart, {
	b = Buffer.read(s,"C:/Users/alice/Desktop/HeartBeat.wav");
	heart = PlayBuf.ar(2, b);
	Out.ar(0, heart);
}).add;
);

(
SynthDef (\door, {arg amp;
    b1 = Buffer.read(s,"C:/Users/alice/Desktop/porta.wav");
    door = PlayBuf.ar(2, b1) * amp;
    Out.ar(0, door);
}).add;
);

(
SynthDef (\steps, {arg amp;
    b2 = Buffer.read(s,"C:/Users/alice/Desktop/passi.wav");
    steps = PlayBuf.ar(2, b2) * amp * 0.5;
    Out.ar(0, steps);
}).add;
);

(
SynthDef (\stepsForest1, {arg amp;
    b3 = Buffer.read(s,"C:/Users/alice/Desktop/passi_foresta.wav");
    stepForest = PlayBuf.ar(2, b3) * amp;
    Out.ar(0, stepForest);
}).add;
);

(
SynthDef (\stepsForest2, {arg amp;
    b4 = Buffer.read(s,"C:/Users/alice/Desktop/passi_foresta_2.wav");
    stepForest2 = PlayBuf.ar(2, b4) * amp * 0.5;
    Out.ar(0, stepForest2);
}).add;
);

(
SynthDef (\howl, {arg amp;
    b5 = Buffer.read(s,"C:/Users/alice/Desktop/ululato.wav");
    howl = PlayBuf.ar(2, b5) * amp;
    Out.ar(0, howl);
}).add;
);

(
SynthDef (\wind, {arg amp;
    b6 = Buffer.read(s,"C:/Users/alice/Desktop/vento.wav");
    wind = PlayBuf.ar(2, b6) * amp;
    Out.ar(0, wind);
}).add;
);

(
SynthDef (\chains, {arg amp;
	b = Buffer.read(s,"C:/Users/alice/Desktop/chains.wav");
	chains = PlayBuf.ar(2, b) * 0.75 * amp;
	Out.ar(0, chains);
}).add;
);

(
SynthDef (\choir, {arg amp;
	b = Buffer.read(s,"C:/Users/alice/Desktop/choir.wav");
	choir = PlayBuf.ar(2, b) * 0.5 * amp;
	Out.ar(0, choir);
}).add;
);

(
SynthDef(\bell, {
	arg
	//Standard Values
	freq = 440, out = 0, amp = 0.1, pan = 0, rel = 2, curve = \lin,
	//ring Controls (wobbleDepth goes from 0 to 1)
	ringAmp = 1, ringRel = 0.9, wobbleDepth = 0.6, wobbleMin = 1, wobbleMax = 1.8,
	//strike Controls
	strikeAmp = 1, strikeDec = 0.01, strikeRel = 0.04, strikeDepth = 0.028, strikeHarmonic = ~bpm/10,
	//hum Controls
	humAmp = 0.5, humAtt = 0.5, humDec = 0.5, humRel = 1;

	ringFreqs = [2, 3, 4.1, 5.43, 6.8, 8.21];

	ringEnv = Env.new(
		            levels: [1, 0.3, 0.2, 0],
		            times: [1/3, 1/3, 1/3] * ringRel * rel,
		            curve: curve).kr;

	ring = SinOsc.ar(
		            freq: ringFreqs * freq,
		            mul: Array.series(6, 1, -0.1) * ringEnv);

	ring = ring * LFTri.ar(
		            freq: {Rand(wobbleMin, wobbleMax)}.dup(6)).range((1 - wobbleDepth), 1);

	strikeEnv = Env.new(
		            levels: [1, 0.1, 0],
		            times: [strikeDec, strikeRel * rel],
		            curve: curve).kr;

	strikeMod = LFNoise1.ar(freq * 36).range(1/ (strikeDepth + 1), strikeDepth + 1);

	strike = SinOsc.ar(
                    freq: freq * strikeHarmonic * strikeMod,
		            mul: strikeEnv);

	humEnv = Env.new(
		            levels: [0, 1, 0.8, 0],
		            times: [humAtt, humDec, humRel * rel],
		            curve: curve).kr;

	hum = SinOsc.ar(
		            freq: freq * [1.01, 0.47],
		            mul: humEnv);

	sndBell = Mix.ar((ring * ringAmp) + (strike * strikeAmp) + (hum * humAmp)) * amp;

	DetectSilence.ar(in: sndBell, doneAction: 2);

	sndBell = sndBell * 0.5;

    Out.ar(out, Pan2.ar(sndBell, pan));
}
).add;
);

(
SynthDef(\organReed, {
    arg
	//Standard Values
	out = 0, pan = 0, freq = 440, amp = 0.3, gate = 1, att = 0.3, rel = 0.3,
	//Depth and Rate Controls (pwmDepth and amDepth range from 0 to 1)
	ranDepth = 0.04, pwmRate = ~bpm/1000, pwmDepth = 0.1, amDepth = 0.05, amRate = 5,
	//Other Controls
	nyquist = 18000, fHarmonic = 0.82, fFreq = 2442, rq = 0.3, hiFreq = 1200, hirs = 1, hidb = 1;

	// The same envelope controls both the resonant freq and the amplitude
    envOrg = Env.asr(
		attackTime: att,
		sustainLevel: amp,
		releaseTime: rel).ar(gate: gate, doneAction: 2);

    // pulse with modulating width
	sndOrg = Pulse.ar(
		freq: TRand.ar(lo: 2.pow(-1 * ranDepth), hi: 2.pow(ranDepth), trig: gate) * freq,
		width: LFNoise1.kr(freq: pwmRate, mul: pwmDepth).range(0, 1),
		mul: 0.0625);  //Incereasing this lessens the impact of the BPF

    // add a little "grit" to the reed
    //original used snd = Disintegrator.ar(snd, 0.5, 0.7);
	sndOrg = Latch.ar(sndOrg, Impulse.ar(nyquist * 2));

    // a little ebb and flow in volume
	sndOrg = sndOrg * LFNoise2.kr(freq: amRate).range((1 - amDepth), 1);

	//Filtering (BHiShelf intensifies the buzzing)
	sndOrg = sndOrg + BPF.ar(in: sndOrg, freq: envOrg.linexp(0, amp, fFreq * fHarmonic, fFreq), rq: rq);
    sndOrg = BHiShelf.ar(in: sndOrg, freq: hiFreq, rs: hirs, db: hidb);

	//Output
	sndOrg = Mix.ar(sndOrg * envOrg);

    Out.ar(out, Pan2.ar(sndOrg, pan));

}).add;
);

(
SynthDef (\glass, {|freq, amp, pan, out|
	delay = ~bpm/60000;
	mfreqG = ~bpm/60;
	durArray = [0.2, 0.1, 0.06, 0.05, 0.05, 0.05, 0.04, 0.03, 0.02];
	envG = Array.fill(9, {arg i; Env.perc(0.01, durArray[i], 0.025, -4).kr()});
	harms = [1, 1.5, 2, 3, 4, 5, 6, 7, 8];
	harmAmp = [1, 0.4, 0.3, 0.2, 0.4, 0.1, 0.1, 0.1];
	sigG = harms * freq;
	sigG = SinOsc.ar(sigG) * envG * harmAmp;
	sigG = Mix(sigG);
	sigG = RHPF.ar(sigG * amp, 6000, 0.1);
	sigG = Pan2.ar(sigG, pan);
	sigG = sigG + LocalIn.ar(2);
	sigG = FreeVerb.ar(sigG, 0.4, 0.1);
	delayS = CombL.ar(sigG, 0.2, delay, 1.0);
	outSig = Mix.ar(sigG*0.6, delayS*0.4);
	outG = DelayN.ar(outSig,0.02,SinOsc.kr(mfreqG,0,0.005,0.005));
	LocalOut.ar(0.4*outG);
	outG = Mix.ar([outG*0.3, outSig*0.7]);
	Out.ar(out, outSig) * Env.perc(0.01, 0.3).kr(doneAction: 2);
}).add;
);

(
SynthDef (\flute, {|freq, amp, dur, pan, out|
	envF = Env([0, 1, 0.55, 0.55, 0], [1, 1.2, dur - 1.2, 1]).kr();
	noiseEnv = Env([0, 0.53, 0.55, 0.45, 0], [0.4, 1.2, dur - 1.2, 0.1]).kr();
	filterEnv = Env([0, 0.6, 0.3, 0.3, 0], [0.1, 3, dur - 3, 1]).kr();
	amp = amp * LinLin.kr(SinOsc.kr(2), -1, 1, 0.7, 1);
	noise = BrownNoise.ar(0.02) * noiseEnv;
	noise = BLowPass.ar(noise, 4000, 1, 0.45);
	sigF = Saw.ar(freq) * envF;
	sigF = BLowPass4.ar(sigF, 2000 * filterEnv, 1, 0.3);
	sigF = BHiPass4.ar(sigF, 300, 0.1);
	sigF = Mix([sigF, noise]);
	sigF = Pan2.ar(sigF * amp, pan, 0.6);
	sigF = FreeVerb.ar(sigF, 0.3, 0.3);
	Out.ar(out, sigF) * Env.linen(1, dur + 2, 1, 0.5, \sin).kr(doneAction: 2);
}).add;
);

(
SynthDef(\pad, {
	arg
	// Standard Values
	out = 0, amp = 0.15, gate = 1, freq = 100, pan = 0,
	// Envelope Controls
	att = 3, dec = 1, sus = 1, rel = 10, crv = 0,
	// Reverb Controls (all go from 0 to 1)
	reverbMix = 0.75, roomSize = 0.9, damp = 0.5,
	// Other Controls (interval is in semitones)
	sampleRate = 20, notes = 6, interval = 7;

	// Set up the Envelopes
	envP = Env.adsr(
		attackTime: att,
		decayTime: dec,
		sustainLevel: sus,
		releaseTime: rel,
		curve: crv).ar(gate: gate);

	// Receive and Sample the feedback
	fbIn = Latch.ar(
		in: (LocalIn.ar + 1)/2,
		trig: Impulse.ar(
			freq: sampleRate));
	fbIn = (fbIn * notes.abs * envP).round(1);
	fbIn = (fbIn * interval).midiratio;

	// Make The Sound
	sndP = LFTri.ar(
		freq: freq * fbIn,
		mul: envP);

	// Feedback the Sound
	LocalOut.ar(sndP);

	// Reverb the Sound
	sndP = FreeVerb.ar(
		in:  sndP,
		mix: reverbMix,
		room: roomSize,
		damp: damp);

	//Filter the Sound
	sndP = RHPF.ar(
		in: sndP,
		freq: freq,
		rq: 0.5);
	sndP = LPF.ar(
		in: sndP,
		freq: [62, 125, 250, 500, 1000, 2000, 4000, 8000, 16000],
		mul: 1/9);

	// Output Stuff
	sndP = Limiter.ar(sndP);
	Out.ar(out, Pan2.ar(sndP * amp, pan));
}
).add;
);

(
SynthDef(\bass, {
	arg out = 0, pan = 0, freq = 110, amp = 0.1, gate = 1, cutoff = 1000, gain = 2.0, lagamount = 0.01, att = 0.001, dec = 0.3, sus = 0.9, rel = 0.2, chorus = 0.7;

	oscBass = Mix(VarSaw.ar(
		freq: freq.lag(lagamount) * [1.0, 1.001, 2.0],
		iphase: Rand(0.0,1.0) ! 3,
		width: Rand(0.5,0.75) ! 3,
		mul: 0.5));

	filterBassEnv = EnvGen.ar(
		envelope: Env.asr(0.2, 1, 0.2),
		gate: gate);

	filterBass =  MoogFF.ar(
		in: oscBass,
		freq: cutoff * (1.0 + (0.5 * filterBassEnv)),
		gain: gain);

	envBass = EnvGen.ar(
		envelope: Env.adsr(0.001, 0.3, 0.9, 0.2, amp),
		gate: gate,
		doneAction: 2);

	sndBass = (0.7 * filterBass + (0.3 * filterBass.distort)) * envBass;

	chorusfx = Mix.fill(7, {

		var maxdelaytime = ~bpm/10000;
		DelayC.ar(
			in: sndBass,
			maxdelaytime: maxdelaytime,
			delaytime: LFNoise1.kr(
				freq: Rand(4.5, 10.5),
				mul: 0.25 * maxdelaytime,
				add: 0.75 * maxdelaytime)
		)
	});
	sndBass = sndBass + (chorusfx * chorus);
	Out.ar(out, Pan2.ar(sndBass, pan));
}
).add;
);

(
SynthDef(\musicBox, {
	arg
	// Standard values
	out = 0, freq = 1000, amp = 0.1, att = 0, dec = 1, rel = 3, pan = 0,
	// Other controls
	decCoef = 0.25, ampSlope = 3, filterfreq = 4000, expRatio = 2,
	// These controls go from 0 to 1
	position = 0.1, thresh = 0.75, mix = 0.1, size = 0.6, revdamp = 0;

// Modal Stuff:
	// Array of frequencies, determined by solutions to the dynamic beam equation
	freqarray = Array.fill(30, { arg i; i + 0.5});
        freqarray[0] = 0.59686416;
	    freqarray[1] = 1.49417561;
	    freqarray[2] = 2.50024695;
	    freqarray = freqarray/0.59686416; // Normalize to freqarray[0] = 1

	// Array of amplitudes
	amparray = Array.fill(30, { arg i;
		if (freqarray[i] > 20000)
		    { 0 }
		    {
			    sin(((i + 1) * pi) * position) *
		        (ampSlope * (freqarray[i]).log2).dbamp
		    }
	});

	// Array of Decay times
	decarray = Array.fill(30, { arg i;
		exp(-1 * i * decCoef)
	});
	decarray = decarray/decarray[0];

	// Hit the object
	exciterMB = Decay2.ar(
		in: Impulse.ar(0),
		attackTime: att,
		decayTime: dec,
		mul: 0.1);

	// Bank of resonators
	sndMB = Klank.ar(
		specificationsArrayRef: Ref.new([freqarray, amparray, decarray]),
		input: exciterMB,
		freqscale: freq,
		decayscale: rel);

// Other stuff:
	sndMB = Mix.ar(sndMB);
	// High pass filter to make it more lofi
	sndMB = HPF.ar(
		in: sndMB,
		freq: filterfreq);
	// Expander to cheaply alter the overall decay curve
	sndMB = CompanderD.ar(
		in: sndMB,
		thresh: thresh,
		slopeBelow: 1,
		slopeAbove: expRatio);
	// Reverb for a more haunted, metalic sound
	sndMB = FreeVerb.ar(
		in: sndMB,
		mix: mix,
		room: size,
		damp: revdamp);
	sndMB = Limiter.ar(sndMB * amp);

	DetectSilence.ar(in: sndMB, doneAction: 2);

	Out.ar(out, Pan2.ar(sndMB, pan));
}).add;
);

(
SynthDef(\violin, {
	| freq = 440, gate=1, amp=0.25 |
	envV = EnvGen.kr(Env.asr(0.1, 1, 0.1), gate, doneAction:2);
	sigV = VarSaw.ar(
		freq,
		width:LFNoise2.kr(1).range(0.2, 0.8)*SinOsc.kr(5, (~bpm/60)-1).range(0.7,0.8))*0.25;
	sigV = sigV * envV * amp;
	Out.ar(0, sigV!2);
}).add;
);

(
SynthDef(\abstractDrum, {
	arg
	// Standard values
	out = 0, freq = 140, amp = 1, pan = 0, att = 0.001, dec = 0.01, rel = 1,
	// Other Controls (position goes from 0 to 1)
	position = 0.5, ampSlope = 3, decCoef = 0.15, hiFreqSus = 0;


	// Setting up arrays for Klank
	freqarrayAD = Array.fill(8, {
		arg i = 1;
		(
			Array.fill((i + 1), {
				arg j;
				(j + 1).pow(2)
			}) +
			(i + 1).pow(2)
		).sqrt

	});
	freqarrayAD = freqarrayAD.flatten/(2.sqrt);

	amparrayAD = Array.fill(36, {
		arg i;
		if (freqarrayAD[i] > 20000)
			{ 0 }
			{
			    sin(((i + 1) * pi) * position) *
		        (ampSlope * (freqarrayAD[i]).log2).dbamp
		    }
	});
	amparrayAD = amparrayAD/ampSlope;

	decarrayAD = Array.fill(36, {
		arg i;
		exp(-1 * i * decCoef) + hiFreqSus
	});
	decarrayAD = decarrayAD/decarrayAD[0];

	// Exciter
	exciterAD = Decay2.ar(
		in: Impulse.ar(0),
		attackTime: att,
		decayTime: dec,
		mul: 0.005); // This keeps the volume at a sane level

	// The actual sound-makey part
	sndAD = Klank.ar(
		specificationsArrayRef:
		    Ref.new([freqarrayAD, amparrayAD, decarrayAD]),
		input: exciterAD,
		freqscale: freq,
		decayscale: rel);

	// Output Stuff
	sndAD = Mix.ar(sndAD * amp * 2);
	sndAD = Limiter.ar(sndAD);

	DetectSilence.ar(in: sndAD, doneAction: 2);

	Out.ar(out, Pan2.ar(sndAD, pan));
}).add;
);

(
SynthDef(\harpsichord, {
	arg
	//Standard Values
	out = 0, amp = 0.1, freq = 440, pan = 0, rel = 5,
	//Pluck arguments (blend goes from 0 to 1)
	trig = 1, coef = 0.1, blend = 0.6;


        // You can use white noise here, but Pink is more realistic
	exciterH = PinkNoise.ar(amp);

	// Fundamental
        root = Pluck.ar(
	        in: exciterH,
	        trig: trig,
	        maxdelaytime: 1/freq,
	        delaytime: 1/freq,
	        decaytime: rel,
	        coef: coef,
	        mul: blend
        );

	// Octave Above
	octaveH = Pluck.ar(
	        in: exciterH,
	        trig: trig,
	        maxdelaytime: 1/(2 * freq),
	        delaytime: 1/(2 * freq),
	        decaytime: rel,
	        coef: coef,
	        mul: (1 - blend)
        );

	// Output Stuff
	sndH = Mix.ar(root + octaveH);
	sndH = Limiter.ar(sndH);

    DetectSilence.ar(in: sndH, doneAction: 2);

	Out.ar(out, Pan2.ar(sndH, pan));
}
).add;
);

(
colorLight = Color.fromHexString("#c0c5ce");
colorDark = Color.fromHexString("#180000");

fontButton = Font.new("Open Sans", 15, true);

backgroundColor = Color.fromHexString("#000000");

bgH = Image.open("/pictures/haunted_house.jpg");
bgF = Image.open("/pictures/scary_forest.jpg");
bgC = Image.open("/pictures/abandoned_church.jpg");
bgS = Image.open("/pictures/background_start.jpg");

fog1 = Image.open("/pictures/fog1.png");
fog2 = Image.open("/pictures/fog2.png");
fog3 = Image.open("/pictures/fog3.png");
fog4 = Image.open("/pictures/fog4.png");
red = Image.open("/pictures/red.png");

a = Window.new("Hollow Hearts", bounds: Rect(128, 90, 1350, 750)).background_(backgroundColor);
v = UserView.new(a, Rect(0, 0, 1350, 750)).backgroundImage_(bgS);

v.animate = true;

v.drawFunc = {
    if(x>1200, {x = -1200});
	if(x2<(-1200), {x2 = 1200});
	if(x3>1200, {x3 = -1000});
	if(x4<(-1200), {x4 = 1000});
	if(~pulse==1, { op = 1.0}, { op = 0.75});

    x = x+xspeed;
	x2 = x2-x2speed;
	x3 = x3+x3speed;
	x4 = x4 - x4speed;

	Pen.drawImage( Point(x, 250), fog1, opacity:0.4);
	Pen.drawImage( Point(x2, 250), fog2, opacity:0.4);
	Pen.drawImage( Point(x3, 250), fog3, opacity:0.7);
	Pen.drawImage( Point(x4, 250), fog4, opacity:0.7);
	Pen.drawImage( Point(0,0), red, opacity:op);
};

volumeG = ControlSpec(0, 1);
volumeV = ControlSpec(0, 0.3);
volumeB = ControlSpec(0, 0.2);
volumeBass = ControlSpec(0, 0.3);
volumeD = ControlSpec(0, 1);
volumeP = ControlSpec(0, 2);
volumeH = ControlSpec(0, 0.3);
volumeT = ControlSpec(0, 0.15);
volumeO = ControlSpec(0, 2);

slider1 = Slider(a, Rect(1100, 300, 200, 20)).background_(Color.fromHexString("#180000")).knobColor_(Color.fromHexString("#180000"));
slider2 = Slider(a, Rect(1100, 370, 200, 20)).background_(Color.fromHexString("#180000")).knobColor_(Color.fromHexString("#180000"));
slider3 = Slider(a, Rect(1100, 440, 200, 20)).background_(Color.fromHexString("#180000")).knobColor_(Color.fromHexString("#180000"));

slider1.maxSize = Size(200, 20);
slider2.maxSize = Size(200, 20);
slider3.maxSize = Size(200, 20);

slider1.visible = false;
slider2.visible = false;
slider3.visible = false;

modeH = Button(a, Rect(10, 500, 250, 30)).font_(fontButton);
modeF = Button(a, Rect(10, 540, 250, 30)).font_(fontButton);
modeC = Button(a, Rect(10, 580, 250, 30)).font_(fontButton);
modeR = Button(a, Rect(10, 620, 250, 30)).font_(fontButton);

modeR.visible = false;

modeH.maxSize = Size(250,30);
modeH.states = [["HAUNTED HOUSE", colorLight, colorDark], ["HAUNTED HOUSE", colorDark, colorLight]];
modeH.action_({ arg butt;
	CmdPeriod.run;
	{m.value}.defer(0.01);
});
m = {
	v.backgroundImage = bgH;
	i = 1;
	modeH.states = [["HAUNTED HOUSE", colorDark, colorLight]];
	modeF.states = [["SCARY FOREST", colorLight, colorDark]];
	modeC.states = [["ABANDONED CHURCH", colorLight, colorDark]];
	~houseActive = 1;
	~forestActive = 0;
	~churchActive = 0;
	slider1.visible = true;
	slider2.visible = true;
	slider3.visible = true;
	modeR.visible = true;
	slider1.value = volumeG.unmap(0.75);
	slider1.action_({
		~ampG = volumeG.map(slider1.value);
	});
	slider2.value = volumeV.unmap(0.1);
	slider2.action_({
		~ampV = volumeV.map(slider2.value);
	});
	slider3.value = volumeB.unmap(0.05);
	slider3.action_({
		~ampB = volumeB.map(slider3.value);
	});
	Synth(\door, [amp: 0.5]);
};

modeF.maxSize = Size(250,30);
modeF.states = [["SCARY FOREST", colorLight, colorDark], ["SCARY FOREST", colorDark, colorLight]];
modeF.action_({ arg butt;
	CmdPeriod.run;
	{h.value}.defer(0.01);
});
h = {
	v.backgroundImage = bgF;
	i = 1;
	modeF.states = [["SCARY FOREST", colorDark, colorLight]];
	modeH.states = [["HAUNTED HOUSE", colorLight, colorDark]];
	modeC.states = [["ABANDONED CHURCH", colorLight, colorDark]];
	~forestActive = 1;
	~houseActive = 0;
	~churchActive = 0;
	slider1.visible = true;
	slider2.visible = true;
	slider3.visible = true;
	modeR.visible = true;
	slider1.value = volumeD.unmap(0.5);
	slider1.action_({
		~ampD = volumeD.map(slider1.value);
	});
	slider2.value = volumeBass.unmap(0.1);
	slider2.action_({
		~ampBass = volumeBass.map(slider2.value);
	});
	slider3.value = volumeP.unmap(1);
	slider3.action_({
		~ampWind = volumeP.map(slider3.value);
	});
	j = drone.choose;
	~pad1 = Synth(\pad, [freq: j, amp: ~ampP, pan: 0, out: 0]);
    ~pad2 = Synth(\pad, [freq: j*(2**(7/12)), amp: ~ampP, pan: 0, out: 0]);
};

modeC.maxSize = Size(250,30);
modeC.states = [["ABANDONED CHURCH", colorLight, colorDark], ["ABANDONED CHURCH", colorDark, colorLight]];
modeC.action_({ arg butt;
	CmdPeriod.run;
	{g.value}.defer(0.01);
});
g = {
	v.backgroundImage = bgC;
	i = 1;
	modeC.states = [["ABANDONED CHURCH", colorDark, colorLight]];
	modeH.states = [["HAUNTED HOUSE", colorLight, colorDark]];
	modeF.states = [["SCARY FOREST", colorLight, colorDark]];
	~churchActive = 1;
	~houseActive = 0;
	~forestActive = 0;
	slider1.visible = true;
	slider2.visible = true;
	slider3.visible = true;
	modeR.visible = true;
	slider1.value = volumeT.unmap(0.3);
	slider1.action_({
		~ampT = volumeT.map(slider1.value);
	});
	slider2.value = volumeH.unmap(0.1);
	slider2.action_({
		~ampH = volumeH.map(slider2.value);
	});
	slider3.value = volumeO.unmap(1);
	slider3.action_({
		~ampChoir = volumeO.map(slider3.value);
	});
	j = drone.choose*4;
    ~org1 = Synth(\organReed, [freq: j, amp: ~ampO, pan:0]);
    ~org2 = Synth(\organReed, [freq: j*(2**(7/12)), amp: ~ampO, pan:0]);
};

modeR.maxSize = Size(250,30);
modeR.states = [["RUN AWAY", colorLight, colorDark]];
modeR.action_({ arg butt;
	CmdPeriod.run;
	{f.value}.defer(0.01);
});
f = {
	v.backgroundImage = bgS;
	modeC.states = [["ABANDONED CHURCH", colorLight, colorDark]];
	modeH.states = [["HAUNTED HOUSE", colorLight, colorDark]];
	modeF.states = [["SCARY FOREST", colorLight, colorDark]];
	~houseActive = 0;
	~churchActive = 0;
	~forestActive = 0;
	modeR.visible = false;
	slider1.visible = false;
	slider2.visible = false;
	slider3.visible = false;
};

a.onClose_({
	~port.close;
	CmdPeriod.run;
});

~getValues.play;

a.front;

);

i = 1;
s.options.memSize = 81920;
~port = SerialPort.new("COM3", 9600);
~charArray = [ ];
~getValues = Routine.new({
{
		ascii = ~port.read.asAscii;
		if(ascii.isDecDigit,{~charArray = ~charArray.add(ascii)});
		if(ascii == $a,{
			~value= ~charArray.collect(_.digit).convertDigits;
			~charArray = [ ];
 		});
		if(ascii == $b,{
            ~pulse= ~charArray.collect(_.digit).convertDigits;
            ~charArray = [ ];
            if (~pulse ==1, {
                Synth(\heart);
				if (~houseActive==1, {
					Synth(\musicBox, [freq: bell.choose*2, amp: ~ampB*[0,1].choose, pan: i%3-1, out: 0]);
				});
                if (~forestActive==1, {
					Synth(\bass, [freq: drone.choose*2, amp:~ampBass, 0]);
					Synth(\abstractDrum, [freq: bell.choose/2, amp:~ampD*[0,1].choose]);
                });
                if (~churchActive==1, {
                    k = aminH.choose/2;
                    Synth(\harpsichord, [freq: k/2, amp:~ampH*[0,1].choose, pan:0]);
                    Synth(\harpsichord, [freq: k*8*(2**(7/12)), amp:~ampH, pan:0]);
                });
				if (i%2 == 0, {
					if (~houseActive==1, {
						Synth(\glass, [freq: aminH.choose*2, amp: ~ampG*[0,1].choose, pan: i%3-1, out: 0]);
						~vi.free;
						~vi = Synth(\violin, [freq: aminH.choose/2, amp:~ampV]);
					});
					if (~churchActive==1, {
						j = drone.choose*4;
						~org1.set(\freq, j);
						~org2.set(\freq, j*(2**(7/12)));
						Synth(\bell, [freq: bell.choose*2, amp: ~ampT*[0,1].choose, pan: i%3-1, out: 0]);
					});
				});
				if (i%4==0, {
                    if (~houseActive==1, {
                        Synth(\flute, [freq: drone.choose/2, amp: 0.9, pan: 1-i%3, out: 0]);
                        Synth(\steps, [amp: probSteps.choose;]);
                    });
                    if (~forestActive==1, {
                        Synth(\howl, [amp: probHowl.choose;]);
						~pad1.free;
						~pad2.free;
						j = drone.choose;
						~pad1 = Synth(\pad, [freq: j, amp: ~ampP, pan: 0, out: 0]);
						~pad2 = Synth(\pad, [freq: j*(2**(7/12)), amp: ~ampP, pan: 0, out: 0]);
						Synth(\wind, [amp: ~ampWind * probWind.choose;]);
                    });
                });
				if (i==16,{
                    j = [2**(7/12),2**(-7/12),2**(5/12), 2**(-1/12), 2**(-4/12)].choose;
                    aminH = aminH*j;
                    drone = drone*j;
                    bell = bell*j;
                    i=0;
					if (~houseActive==1, {
						Synth(\door, [amp: probDoor.choose;]);
					});
                    if (~forestActive==1, {
                        [Synth(\stepsForest1, [amp: probSteps.choose;]),
							Synth(\stepsForest2, [amp: probSteps.choose;])].choose;
                    });
					if (~churchActive==1, {
						Synth(\choir, [amp: ~ampChoir * probChoir.choose;]);
						Synth(\chains, [amp: probChains.choose;]);
					});
                });
				i = i+1;
			},  {
				if (~houseActive==1, {
					Synth(\musicBox, [freq: bell.choose*2, amp: ~ampB*[0, 0, 1].choose, pan: i%3-1, out: 0]);
				});
				if (~forestActive==1, {
					Synth(\abstractDrum, [freq: bell.choose, amp:0.4*[0,1].choose]);
				});
				if (i%2 ==0 && ~forestActive==1, {
					Synth(\bass, [freq: drone.choose*2, ~ampBass, 0]);
				});
			});
		});
		if(ascii == $c,{
			~bpm = ~charArray.collect(_.digit).convertDigits;
			~charArray = [ ];
		});
	}.loop;
});
)