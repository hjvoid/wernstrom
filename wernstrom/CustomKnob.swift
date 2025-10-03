//
//  CustomKnob.swift
//  wernstrom
//
//  Created by Hugo Jeffreys on 03/10/2025.
//

import SwiftUI
import Controls

/// Knob in which you start by tapping in its bound and change the value by either horizontal or vertical motion
public struct CustomKnob: View {
    @Binding var value: Float
    var range: ClosedRange<Float> = 0.0 ... 1.0

    var backgroundColor: Color = .gray
    var foregroundColor: Color = .orange

    /// Initialize the knob with a bound value and range
    /// - Parameters:
    ///   - value: value being controlled
    ///   - range: range of the value
    public init(value: Binding<Float>, range: ClosedRange<Float> = 0.0 ... 1.0) {
        _value = value
        self.range = range
    }

    var normalizedValue: Double {
        Double((value - range.lowerBound) / (range.upperBound - range.lowerBound))
    }

    var offsetX: CGFloat {
        -sin(normalizedValue * 1.6 * .pi + 0.2 * .pi) / 2.0 * 0.75
    }

    var offsetY: CGFloat {
        cos(normalizedValue * 1.6 * .pi + 0.2 * .pi) / 2.0 * 0.75
    }


    public var body: some View {
        Control(value: $value, in: range,
                geometry: .twoDimensionalDrag(xSensitivity: 1, ySensitivity: 1)) { geo in
            ZStack(alignment: .center) {
                Circle()
                        .fill(
                            RadialGradient(
                                gradient: Gradient(stops: [
                                    .init(color: .gray.opacity(0.85), location: 0.0),
                                    .init(color: .gray.opacity(0.7),  location: 0.45),
                                    .init(color: .black,              location: 1.0)
                                ]),
                                center: .center,
                                startRadius: 0,
                                endRadius: min(geo.size.width, geo.size.height) * 0.55
                            )
                        )
                        // subtle outer shadow for lift
                        .shadow(radius: geo.size.width * 0.06, y: geo.size.width * 0.02)
                        // slight inner edge (fake inner shadow)
                        .overlay(
                            Circle()
                                .stroke(
                                    LinearGradient(colors: [
                                        .gray.opacity(0.4), .black.opacity(0.3)
                                    ], startPoint: .bottom, endPoint: .top),
                                    lineWidth: geo.size.width * 0.06
                                )
                                .blur(radius: 0.5)
                                .padding(geo.size.width * 0.03)
                        )
                        // soft specular highlight
                        .overlay(
                            Circle()
                                .strokeBorder(
                                      LinearGradient(colors: [.orange.opacity(normalizedValue), .black.opacity(0.3)],
                                                     startPoint: .bottom, endPoint: .top),
                                      lineWidth: geo.size.width * 0.06
                                    )
                                .stroke(
                                    LinearGradient(colors: [
                                        .white.opacity(0.35), .clear
                                    ], startPoint: .topLeading, endPoint: .bottomTrailing),
                                    lineWidth: geo.size.width * 0.03
                                )
                                .blendMode(.screen)
                                .padding(geo.size.width * 0.06)
                                .opacity(0.9)
                        )

                    // Indicator: gives an old-school metal feel
                    Rectangle()
                        .fill(
                            LinearGradient(colors: [.white, .gray, .black],
                                           startPoint: .top, endPoint: .bottom)
                        )
                        .frame(width: geo.size.width / 20, height: geo.size.height / 4)
                        .rotationEffect(Angle(radians: normalizedValue * 1.6 * .pi + 0.2 * .pi))
                        .offset(x: offsetX * Double(geo.size.width),
                                y: offsetY * Double(geo.size.height))
                }
                .drawingGroup()
        }
        .aspectRatio(CGSize(width: 1, height: 1), contentMode: .fit)

    }
}


extension CustomKnob {
    /// Modifier to change the background color of the knob
    /// - Parameter backgroundColor: background color
    public func backgroundColor(_ backgroundColor: Color) -> CustomKnob {
        var copy = self
        copy.backgroundColor = backgroundColor
        return copy
    }

    /// Modifier to change the foreground color of the knob
    /// - Parameter foregroundColor: foreground color
    public func foregroundColor(_ foregroundColor: Color) -> CustomKnob {
        var copy = self
        copy.foregroundColor = foregroundColor
        return copy
    }
}

#Preview {
    KnobPreview()
}

private struct KnobPreview: View {
    @State var v: Float = 0.5
    var body: some View {
        CustomKnob(value: $v)
            .frame(width: 140, height: 140)
    }
}
