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
    @Published var octave = 0
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
    
    let reverb: CostelloReverb
    let dryWet: DryWetMixer
    @Published var reverbMix: AUValue = 0.3 {
        didSet { dryWet.balance = reverbMix }
    }
    
    
    init() {
        let filter = MoogLadder(Mixer(osc[0],osc[1],osc[2]), cutoffFrequency: 20_000)
        let env = AmplitudeEnvelope(filter, attackDuration: 0.0, decayDuration: 1.0, sustainLevel: 0.0, releaseDuration: 0.25)
        let reverb = CostelloReverb(env, feedback: 0.6, cutoffFrequency: 4_000)
        let dryWet = DryWetMixer(env, reverb, balance: 0.3)
        
        self.filter = filter
        self.env =  env
        self.reverb = reverb
        self.dryWet = dryWet
        
        engine.output = dryWet
        env.start()
        reverb.start()
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
        let transposed = max(0, min(127, Int(pitch.midiNoteNumber) + octave * 12))
        
        env.closeGate()
        data.frequency = AUValue(transposed).midiNoteToFrequency()
        data.octaveFrequency = AUValue(max(0, transposed - 12)).midiNoteToFrequency()
        for num in 0 ... 10 {
            if notes[num] == 0 {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) { self.env.openGate() }
                notes[num] = transposed
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
