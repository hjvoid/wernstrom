//
//  SynthView.swift
//  wernstrom
//
//  Created by Hugo Jeffreys on 03/10/2025.
//

import SwiftUI
import AudioKit
import Combine
import AudioKitEX
import Keyboard
import Tonic
import SoundpipeAudioKit
import Controls

struct SynthView: View {
    @StateObject var conductor = SynthEngine()
    var body: some View {
        ZStack { RadialGradient(gradient: Gradient(colors: [.blue.opacity(0.5), .black]), center: .center, startRadius: 2, endRadius: 650).edgesIgnoringSafeArea(.all)
            VStack {
                HStack {
                    VStack {
                        Text("Filter\n\(Int(conductor.cutoff))").multilineTextAlignment(.center).padding(.top, 10)
                        CustomKnob(value: $conductor.cutoff, range: 12.0 ... 12_000.0).frame(maxWidth:150).padding(.bottom, 10)
                    }
                    VStack {
                        Text("Attack\n\(String(format: "%.2f", conductor.env.attackDuration))").multilineTextAlignment(.center).padding(.top, 10)
                        CustomKnob(value: $conductor.env.attackDuration, range: 0.0 ... 10.0).frame(maxWidth:150).padding(.bottom, 10)
                    }
                    VStack {
                        Text("Decay\n\(String(format: "%.2f", conductor.env.decayDuration))").multilineTextAlignment(.center).padding(.top, 10)
                        CustomKnob(value: $conductor.env.decayDuration, range: 0.0 ... 10.0).frame(maxWidth:150).padding(.bottom, 10)
                    }
                    VStack {
                        Text("Sustain\n\(String(format: "%.2f", conductor.env.sustainLevel))").multilineTextAlignment(.center).padding(.top, 10)
                        CustomKnob(value: $conductor.env.sustainLevel, range: 0.0 ... 1.0).frame(maxWidth:150).padding(.bottom, 10)
                    }
                    VStack {
                        Text("Release\n\(String(format: "%.2f", conductor.env.releaseDuration))").multilineTextAlignment(.center).padding(.top, 10)
                        CustomKnob(value: $conductor.env.releaseDuration, range: 0.0 ... 10.0).frame(maxWidth:150).padding(.bottom, 10)
                    }
                    VStack {
                        Text("Reverb\n\(String(format: "%.2f", conductor.reverbMix * 100))").multilineTextAlignment(.center).padding(.top, 10)
                        CustomKnob(value: $conductor.reverbMix, range: 0.0 ... 1.0).frame(maxWidth:150).padding(.bottom, 10)
                    }
                }.padding(10)
                HStack {
                    Button(action: { conductor.octave = max(-2, conductor.octave - 1) }) {
                        Image(systemName: "arrowtriangle.backward.fill").foregroundColor(.white)
                    }
//                    Text("Octave: \(conductor.octave)").frame(maxWidth:150)
                    OLEDDisplay(title: "Octave: ", value: "\(conductor.octave)", icon: Image(systemName: "waveform.path.ecg"), style: .ice)
                        .frame(maxWidth:250, maxHeight: 50)
                    Button(action: { conductor.octave = min(3, conductor.octave + 1) }) {
                        Image(systemName: "arrowtriangle.forward.fill").foregroundColor(.white)
                    }
                }.frame(maxWidth: 400).padding(10)
                
                Keyboard(
                    layout: .piano(pitchRange: Pitch(60)...Pitch(83)),
                    latching: false,
                    noteOn: { pitch, point in
                        conductor.noteOn(pitch: pitch, point: point)
                    },
                    noteOff: { pitch in
                        conductor.noteOff(pitch: pitch)
                    }
                )
                .frame(maxHeight: 150)
                .padding()

            }
        }.onDisappear() { self.conductor.engine.stop() }
    }
}

#Preview {
    SynthView()
}
