SerialPort.listDevices
s.options.memSize = 81920;

(
var heart;
var envBell, sndBell, exciterBell;
var sndOrg, envOrg;
var durArray, sigG, envG, harms, harmAmp, delayS, delay, outSig, outG, mfreqG;
var sigF, envF, noise, noiseEnv, filterEnv;
var sigP, sig1P, sig2P, sig3P, phaser, envP, noiseP, noise2, noiseEnvP, filterEnvP, filterLFO, buff;
   var envSB, in, ina, synca, octa, inb, syncb, octb, octave, sndSB;
	var freqarray, amparray, decarray, exciterMB, sndMB;
	var scratch, envV, pwm, sndV;
	var freqarrayAD, amparrayAD, decarrayAD, exciterAD, sndAD;
	var exciterH, root, octaveH, sndH;


var aminH = [440, 493.88, 523.25, 587.33, 659.25, 698.46, 830.61];
var bell = [415.30, 440, 523.25, 698.46];
var drone = [55, 82.41];

var backgroundColor;
var fog1, fog2, fog3, fog4;
var bgH, bgF, bgC, bgS;
var volume1, volume2, volume3, slider1, slider2, slider3;
var width = 400, height = 400;
var xspeed = 0.4, x2speed = 0.5, x3speed = 0.2, x4speed = 0.3;
var x = -400, x2 = 1200, x3 = -800, x4 = 1300;
var modeH, modeF, modeC, modeR, fontButton, colorLight, colorDark;

var volumeG, volumeV, volumeB, volumeP, volumeBass, volumeD, volumeH, volumeT, volumeO;

var ascii;

~houseActive = 0;
~forestActive = 0;
~churchActive = 0;

~ampG = 0.75;
~ampV = 0.1;
~ampB = 0.1;
~ampP = 0.9;
~ampBass = 1;
~ampD = 0.5;
~ampH = 0.1;
~ampT = 0.3;
~ampO = 0.25;

~bpm = 70;



(
SynthDef (\heart, {
	b = Buffer.read(s,"C:/Users/alice/Desktop/HeartBeat.wav");
	heart = PlayBuf.ar(2, b);
	Out.ar(0, heart);
}).add;
);

(
SynthDef(\tubularBell, {
	arg freq = 440, amp = 0.1, pan = 0, out = 0, att = 0.005, rel = 9, exciterRel = 0.05;

	envBell = Env.perc(att, exciterRel, 0.05).kr;

	exciterBell = GrayNoise.ar(envBell);

	sndBell = DynKlank.ar(
		specificationsArrayRef:
	        	Ref.new([
	        		[1.013, 1.512, 2.113, 2.525, 3.35, 4.57, 6.48],   // harmonics
			        [1, 0.78, 0.89, 0.63, 0.31, 0.56, 0.25], // amplitudes
		        	[1, 0.9, 0.8, 0.65, 0.45, 0.3, 0.1]     // ring times
		        ]),
		input: exciterBell,
		freqscale: freq,
		decayscale: rel
	);

	sndBell = LPF.ar(sndBell, freq * 9.5);

	DetectSilence.ar(
		        in: sndBell,
		        amp: 0.001,
		        time: 0.5,
		        doneAction: 2
		    );

	Out.ar(out, Pan2.ar(sndBell, pan, amp));
}).add;
);

(
SynthDef("organReed", {
    arg
	//Standard Values
	out = 0, pan = 0, freq = 440, amp = 0.3, gate = 1, att = 0.3, rel = 0.3,
	//Depth and Rate Controls (pwmDepth and amDepth range from 0 to 1)
	ranDepth = 0.04, pwmRate = 0.06, pwmDepth = 0.1, amDepth = 0.05, amRate = 5,
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
SynthDef (\pad, {|freq, amp, dur, pan, out|
	envP = Env([0, 1, 1, 1, 0], [0.6, 0.5, dur, 4], \sin).kr();
	noiseEnvP = Env([0, 1, 1, 1, 0], [0.6, 0.5, dur, 4], \sin).kr();
	filterEnvP = Env([0, 1, 1, 0.1], [1, dur, 4], \sin).kr();
	filterLFO = SinOsc.ar(0.25, 0, 100);
	sig1P = Pan2.ar(Saw.ar((freq - 2) + SinOsc.kr(5, mul: 3), 0.4), -1) * envP;
	sig2P = Pan2.ar(Saw.ar((freq + 2) + SinOsc.kr(5, mul: 3), 0.4), 1) * envP;
	sig3P = Saw.ar((freq * 2) + SinOsc.kr(5, mul: 3), 0.4) * envP;
	sigP = Mix([sig1P, sig2P, sig3P]);
	sigP = RLPF.ar(sigP, 1000, 1, 0.6);
	noiseP = Pan2.ar(PinkNoise.ar(0.4) * noiseEnvP, -1);
	noise2 = Pan2.ar(DelayL.ar(PinkNoise.ar(0.4) * noiseEnvP, 0.3, 0.2), 1);
	noiseP = Mix([noiseP, noise2]);
	noiseP = RLPF.ar(noiseP, 4000, 1);
	noiseP = RHPF.ar(noiseP, 250, 1);
	sigP = Mix([sigP, noiseP]);
	sigP = RLPF.ar(sigP, (700 + filterLFO) * filterEnvP, 0.4, 0.1);
	phaser = Mix(Array.fill(4, {AllpassC.ar(sigP, 1, SinOsc.ar(0.3, 0, 0.005, 0.0051), 0, 0.8)}));
	sigP = sigP + phaser;
	sigP = FreeVerb.ar(sigP, 0.9, 0.9);
	sigP = Pan2.ar(sigP, pan, 0.3);
	Out.ar(out, sigP * amp) * Env([0, 1, 1, 1, 0], [0.6, 0.5, dur + 3, 4], \sin).kr(doneAction: 2);
}).add;
);

(
SynthDef(\subBass, {
    arg
	//Blend goes from 0 to 1
	out = 0, amp = 0.5, pan = 0, freq = 440, att = 0.001, rel = 1, curve = 8, blend = 0.5;

	//A slightly rounded percussive envelope
	envSB = Env.perc(att, rel, amp, [curve, -1 * curve]).kr(doneAction: 2);

	/*  Input wave +/- 90 degrees - To use SinOsc.ar, replace:
	        -"iphase:  0" with "phase: pi/2"
	        -"iphase:  1" with "phase: 0"
	        -"iphase: -1" with "phase: pi"   */
	in = LFPar.ar(freq: freq * 2, iphase: 0);
	ina = LFPar.ar(freq: freq * 2, iphase: 1);
	inb = LFPar.ar(freq: freq * 2, iphase: -1);

	//Two square waves exactly out of phase and an octave below the input wave
	synca = LFPulse.ar(freq: freq, iphase: 0);
	syncb = LFPulse.ar(freq: freq, iphase: 0.5);

	//This smoothly swaps between outputting the +90 degree wave and -90 degree wave
	octa = ina * synca;
	octb = inb * syncb;
	octave = Mix.ar([octa, octb]);

	//Mixer stage, volume adjustments, envelope, and output
	sndSB = Mix.ar([octave * blend, in * (blend - 1)]);
    sndSB = LeakDC.ar(sndSB);
	sndSB = Limiter.ar(in: sndSB, level: 1);
	sndSB = sndSB * envSB;


	Out.ar(out, Pan2.ar(sndSB, pan));
}).add;
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
	arg
	//Standard Definitions
	freq = 440, gate = 1, amp = 1, pan = 0, out = 0, att = 0.1, dec = 0.1, sus = 0.3, rel = 0,
	//Vibrato Controls
	vRate = 4.6, vDepth = 0.02, vAtt = 0.15, vRateVar = 0.25, vDepthVar = 0.05,
	//PWM Controls (pwmMax and pwmMin are 0 - 1)
	pwmVarRate = 2, pwmMin = 0.7, pwmMax = 0.8, pwmRate = 5,
	//Other Controls
	bridgeFreq = 2500, scratchDepth = 0.15;


	scratch = 1.015 + Env.perc(att, dec * 1.25, scratchDepth).kr;

	envV = Env.adsr(att, dec, sus, rel).kr(gate: gate, doneAction: 2);

	freq = Vibrato.kr(
		            freq: freq,
		            rate: vRate,
		            depth: vDepth,
	            	delay: (att + dec),
		            onset: vAtt,
		            rateVariation: vRateVar,
		            depthVariation: vDepthVar
            	);

	pwm = SinOsc.kr(freq: pwmRate, phase: Rand(0.0, 1.0)).range(pwmMin, pwmMax);
	pwm = pwm * LFNoise2.kr(pwmVarRate).range(0.2, 0.8);

	sndV = VarSaw.ar(
		freq: Lag.kr(freq) * LFPulse.ar(freq * 1.5).range(1/scratch, scratch),
		width: pwm,
		mul: amp
	);

	sndV = (sndV * 0.7) + BPF.ar(sndV, bridgeFreq, 2, 2);
	sndV = sndV + HPF.ar(sndV, bridgeFreq * 2);
	sndV = sndV * envV;
	Out.ar(out, Pan2.ar(sndV, pan));
}
).add;
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

//colorLight = Color.fromHexString("#a7adba");
colorLight = Color.fromHexString("#c0c5ce");
//colorDark = Color.fromHexString("#4f5b66");
colorDark = Color.fromHexString("#343d46");

fontButton = Font.new("Open Sans", 15, true);

backgroundColor = Color.fromHexString("#000000");

//bgH = Image.open("C:/Users/alice/Desktop/casa2.jpg");
//bgF = Image.open("C:/Users/alice/Desktop/foresta2.jpg");
//bgC = Image.open("C:/Users/alice/Desktop/chiesa2.jpg");
//bgS = Image.open("C:/Users/alice/Desktop/sfondoiniziale font3.jpg");
bgH = Image.open("/Users/riccardopomarico/Desktop/computer music - languages and systems/homework 3/sfondo.jpg");
bgF = Image.open("/Users/riccardopomarico/Desktop/computer music - languages and systems/homework 3/sfondof.jpg");
bgC = Image.open("/Users/riccardopomarico/Desktop/computer music - languages and systems/homework 3/sfondoc.jpg");
bgS = Image.open("/Users/riccardopomarico/Desktop/computer music - languages and systems/homework 3/sfondoiniziale.jpg");

fog1 = Image.open("/Users/riccardopomarico/Desktop/computer music - languages and systems/homework 3/fog1.png");
fog2 = Image.open("/Users/riccardopomarico/Desktop/computer music - languages and systems/homework 3/fog2.png");
fog3 = Image.open("/Users/riccardopomarico/Desktop/computer music - languages and systems/homework 3/fog3.png");
fog4 = Image.open("/Users/riccardopomarico/Desktop/computer music - languages and systems/homework 3/fog4.png");
//fog1 = Image.open("C:/Users/alice/Desktop/fog1.png");
//fog2 = Image.open("C:/Users/alice/Desktop/fog2.png");
//fog3 = Image.open("C:/Users/alice/Desktop/fog3.png");
//fog4 = Image.open("C:/Users/alice/Desktop/fog4.png");

a = Window.new("Hollow Hearts", bounds: Rect(128, 90, 1350, 750)).background_(backgroundColor);
v = UserView.new(a, Rect(0, 0, 1350, 750)).backgroundImage_(bgS);

v.animate = true;

v.drawFunc = {

    if(x>1200, {x = -1200});
	if(x2<(-1200), {x2 = 1200});
	if(x3>1200, {x3 = -1000});
	if(x4<(-1200), {x4 = 1000});

    x = x+xspeed;
	x2 = x2-x2speed;
	x3 = x3+x3speed;
	x4 = x4 - x4speed;

 Pen.drawImage( Point(x, 250), fog1, opacity:0.4);
 Pen.drawImage( Point(x2, 250), fog2, opacity:0.4);
	 Pen.drawImage( Point(x3, 250), fog3, opacity:0.7);
	 Pen.drawImage( Point(x4, 250), fog4, opacity:0.7);

};


volumeG = ControlSpec(0, 0.75);
volumeV = ControlSpec(0, 0.1);
volumeB = ControlSpec(0, 0.1);
volumeBass = ControlSpec(0, 1);
volumeD = ControlSpec(0, 0.5);
volumeP = ControlSpec(0, 0.9);
volumeH = ControlSpec(0, 0.1);
volumeT = ControlSpec(0, 0.3);
volumeO = ControlSpec(0, 0.25);

// slider1 = Slider(a, Rect(1000, 300, 300, 40)).background_(backgroundColor);
slider1 = Slider(a, Rect(1100, 300, 200, 20));
slider2 = Slider(a, Rect(1100, 370, 200, 20));
slider3 = Slider(a, Rect(1100, 440, 200, 20));

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
	v.backgroundImage = bgH;
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
	slider3.value = volumeB.unmap(0.1);
	slider3.action_({
		~ampB = volumeB.map(slider3.value);
	});
});

modeF.maxSize = Size(250,30);
modeF.states = [["SCARY FOREST", colorLight, colorDark], ["SCARY FOREST", colorDark, colorLight]];
modeF.action_({ arg butt;
	v.backgroundImage = bgF;
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
	slider2.value = volumeBass.unmap(1);
	slider2.action_({
		~ampBass = volumeBass.map(slider2.value);
	});
	slider3.value = volumeP.unmap(0.9);
	slider3.action_({
		~ampP = volumeP.map(slider3.value);
	});
});

modeC.maxSize = Size(250,30);
modeC.states = [["ABANDONED CHURCH", colorLight, colorDark], ["ABANDONED CHURCH", colorDark, colorLight]];
modeC.action_({ arg butt;
	v.backgroundImage = bgC;
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
	slider3.value = volumeO.unmap(0.25);
	slider3.action_({
		~ampO = volumeO.map(slider3.value);
	});
});

modeR.maxSize = Size(250,30);
modeR.states = [["RUN AWAY", colorLight, colorDark]];
modeR.action_({ arg butt;
	v.backgroundImage = bgS;
	modeC.states = [["ABANDONED CHURCH", colorLight, colorDark]];
	modeH.states = [["HAUNTED HOUSE", colorLight, colorDark]];
	modeF.states = [["SCARY FOREST", colorLight, colorDark]];
	~churchActive = 0;
	~houseActive = 0;
	~forestActive = 0;
	modeR.visible = false;
	slider1.visible = false;
	slider2.visible = false;
	slider3.visible = false;
});

a.onClose_({
	~port.close;
	CmdPeriod.run;
});

~getValues.play;

a.front;

);


// var ascii;
/*var aminH = [440, 493.88, 523.25, 587.33, 659.25, 698.46, 830.61];
var bell = [415.30, 440, 523.25, 698.46];
var drone = [55, 82.41];*/
i = 0;
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

				if (~forestActive==1, {
					Synth(\subBass, [freq: drone.choose*2, 1, 0]);
					// Synth(\subBass, [freq: drone.choose*2, amp:~ampBass, 0]);
				});
				if (~churchActive==1, {
					j = drone.choose*4;
					/*Synth(\organReed, [freq: j, amp:0.25, pan:0]);
					Synth(\organReed, [freq: j*(2**(7/12)), amp:0.25, pan:0]);*/
					Synth(\organReed, [freq: j, amp: ~ampO, pan:0]);
					Synth(\organReed, [freq: j*(2**(7/12)), amp: ~ampO, pan:0]);

				});
				if (~churchActive==1, {
					j = aminH.choose/2;
					/*Synth(\harpsichord, [freq: j/2, amp:0.1*[0,1].choose, pan:0]);
					Synth(\harpsichord, [freq: j*8*(2**(7/12)), amp:0.1, pan:0]);*/
					Synth(\harpsichord, [freq: j/2, amp:~ampH*[0,1].choose, pan:0]);
					Synth(\harpsichord, [freq: j*8*(2**(7/12)), amp:~ampH, pan:0]);
				});
				/*if (~houseActive==1, {
					/*Synth(\violin, [freq: aminH.choose*2, amp:0.1]);*/
					Synth(\violin, [freq: aminH.choose*2, amp:~ampV]);
				});*/
				if (~forestActive==1, {
					/*Synth(\abstractDrum, [freq: bell.choose/2, amp:0.5*[0,1].choose]);*/
					Synth(\abstractDrum, [freq: bell.choose/2, amp:~ampD*[0,1].choose]);
				});
				if (i%2 == 0  ,{
					postln("siamo in i % 2");
					if (~houseActive==1, {
						/*Synth(\glass, [freq: aminH.choose*2, amp: 0.75*[0,1].choose, pan: i%3-1, out: 0]);*/
						postln("amp: " + ~ampG);
						Synth(\glass, [freq: aminH.choose*2, amp: ~ampG*[0,1].choose, pan: i%3-1, out: 0]);
					});
					if (~houseActive==1, {
						/*Synth(\musicBox, [freq: bell.choose*2, amp: 0.1*[0,1].choose, pan: i%3-1, out: 0]);*/
						Synth(\musicBox, [freq: bell.choose*2, amp: ~ampB*[0,1].choose, pan: i%3-1, out: 0]);
					});
					if (~churchActive==1, {
						/*Synth(\tubularBell, [freq: bell.choose*4, amp: 0.3*[0,1].choose, pan: i%3-1, out: 0]);*/
						Synth(\tubularBell, [freq: bell.choose*4, amp: ~ampT*[0,1].choose, pan: i%3-1, out: 0]);
					});
				});
				if (i%4==0,  {
					if (~houseActive==1, {
						Synth(\flute, [freq: drone.choose/2, amp: 0.9, pan: 1-i%3, out: 0]);
					});
					if (~forestActive==1, {
						j = drone.choose*4;
						/*Synth(\pad, [freq: j, amp: 0.9, pan: 1-i%3, out: 0]);
						Synth(\pad, [freq: j*(2**(7/12)), amp: 0.9, pan: 1-i%3, out: 0]);*/
						Synth(\pad, [freq: j, amp: ~ampP, pan: 1-i%3, out: 0]);
						Synth(\pad, [freq: j*(2**(7/12)), amp: ~ampP, pan: 1-i%3, out: 0]);
					});
				});
				if (i==16,{
					j = [2**(7/12),2**(-7/12),2**(5/12), 2**(-1/12), 2**(-4/12)].choose;
					aminH = aminH*j;
					drone = drone*j;
					bell = bell*j;
					i=0;
				});
				i = i+1;
			},  {
				if (~forestActive==1, {
					Synth(\abstractDrum, [freq: bell.choose, amp:0.4*[0,1].choose]);
				});
				if (i%2 ==0 && ~forestActive==1, {
					Synth(\subBass, [freq: drone.choose*2, 1, 0]);
				});
			});


		});
		if(ascii == $c,{
			~bpm= ~charArray.collect(_.digit).convertDigits;
			~charArray = [ ];
		});
	}.loop;
});

)

