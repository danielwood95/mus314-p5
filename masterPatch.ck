60 => float baseFreq;
[0, 2, 4, 7, 9, 12] @=> int offsets[];
[0.5, 0.5625, 0.625, 0.75, .83333] @=> float ratios[];

OscRecv in;
5557 => in.port;
in.listen();
in.event("/playCollision") @=> OscEvent event;

spork~ receive();
10::minute => now;

fun void receive() {
    while(true) {
        event => now;
        while (event.nextMsg() != 0) {
            spork~ playCollision();
        }
    }
}

fun void playBell() {
    SndBuf buf => Envelope bufEnv => dac;
    me.sourceDir() + "/chimeC.wav" => string filename;
    buf.read(filename);
    buf.gain(0.1);

    bufEnv.keyOn();
    buf.pos(0);
    buf.rate(ratios[Math.random2(0, ratios.cap() - 1)]);
    500::ms => now;
    bufEnv.keyOff();
    100::ms => now;
}

fun void playCollision() {
    Math.random2(0, 3) => int random;
    if (random < 3) {
        playBell();
    } else {
        playSaw();
    }
}

fun void modulate(BlitSaw s, float freq) {
    SinOsc modulator => blackhole;
    modulator.freq(1.0);
    1.5 => float modAmount;

    while(true) {
        s.freq((modulator.last() * modAmount) + freq);
        1::samp => now;
    }
}

fun void playSaw() {
    BlitSaw s => LPF f => ADSR e => Dyno d => dac;
    Std.mtof(baseFreq + offsets[Math.random2(0, offsets.cap()-1)]) => float freq;
    s.gain(0.15);
    f.freq(700);
    e.set(600::ms, 400::ms, 0.3, 1000::ms);
    d.limit();

    spork~ modulate(s, freq);

    e.keyOn();
    1000::ms => now;
    e.keyOff();
    1000::ms => now;
}
