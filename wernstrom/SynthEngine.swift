//
//  SynthEngine.swift
//  wernstrom
//
//  Created by Hugo Jeffreys on 02/10/2025.
//

import SwiftUI
import AudioKit
import Combine
import AudioKitEX
import Keyboard
import Tonic
import SoundpipeAudioKit
import Controls

struct MorphingOscillatorData {
    var frequency: AUValue = 440
    var octaveFrequency: AUValue = 440
    var amplitude: AUValue = 0.2
}

class SynthEngine: ObservableObject {
    
    let engine = AudioEngine()
    @Published var octave = 1
    let filter : MoogLadder
    @Published var env : AmplitudeEnvelope
    var notes = Array(repeating: 0, count: 11)
    @Published var cutoff = AUValue(20_000) {
        didSet { filter.cutoffFrequency = AUValue(cutoff) }
    }
    
    var osc = [
        MorphingOscillator(index:0.75,detuningOffset: -0.5),
        MorphingOscillator(index:0.75,detuningOffset: 0.5),
        MorphingOscillator(index:2.75)
    ]
    
    init() {
        filter = MoogLadder(Mixer(osc[0],osc[1],osc[2]), cutoffFrequency: 20_000)
        env = AmplitudeEnvelope(filter, attackDuration: 0.0, decayDuration: 1.0, sustainLevel: 0.0, releaseDuration: 0.25)
        engine.output = env
        try? engine.start()
    }
    
    @Published var data = MorphingOscillatorData() {
        didSet {
            for i in 0...2 {
                osc[i].start()
                osc[i].$amplitude.ramp(to: data.amplitude, duration: 0)
            }
            osc[0].$frequency.ramp(to: data.frequency, duration: 0.1)
            osc[1].$frequency.ramp(to: data.frequency, duration: 0.1)
            osc[2].$frequency.ramp(to: data.octaveFrequency, duration: 0.1)
        }
    }
    
    func noteOn(pitch: Pitch, point: CGPoint) {
        env.closeGate()
        data.frequency = AUValue(pitch.midiNoteNumber).midiNoteToFrequency()
        data.octaveFrequency = AUValue(pitch.midiNoteNumber-12).midiNoteToFrequency()
        for num in 0 ... 10 {
            if notes[num] == 0 {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) { self.env.openGate() }
                notes[num] = pitch.intValue
                break
            }
        }
    }
    
    func noteOff(pitch: Pitch) {
        for num in 0 ... 10 { //closeGate if all fingers are off
            if notes[num] == pitch.intValue { notes[num] = 0 }
            if Set(notes).count <= 1 {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) { self.env.closeGate() }
            }
        }
    }
}
