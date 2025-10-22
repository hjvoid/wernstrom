//
//  DisplayView.swift
//  wernstrom
//
//  Created by Hugo Jeffreys on 22/10/2025.
//

import SwiftUI

struct OLEDDisplay: View {
    public struct Style: Equatable {
        public var glass: Color
        public var bezel: Color
        public var text: Color
        public var glow: Color
        public var accent: Color
        public var scanlineOpacity: Double
        public var flickerAmount: Double
        

        public init(
            glass: Color,
            bezel: Color,
            text: Color,
            glow: Color,
            accent: Color,
            scanlineOpacity: Double = 0.18,
            flickerAmount: Double = 0.02
        ) {
            self.glass = glass
            self.bezel = bezel
            self.text = text
            self.glow = glow
            self.accent = accent
            self.scanlineOpacity = scanlineOpacity
            self.flickerAmount = flickerAmount
        }


        // Presets
        public static let amber = Style(
        glass: Color(red: 0.08, green: 0.05, blue: 0.0),
        bezel: Color(red: 0.06, green: 0.06, blue: 0.06),
        text: Color(red: 1.0, green: 0.77, blue: 0.33),
        glow: Color(red: 1.0, green: 0.62, blue: 0.12),
        accent: Color(red: 1.0, green: 0.86, blue: 0.55)
        )
        public static let mint = Style(
        glass: Color(red: 0.0, green: 0.04, blue: 0.04),
        bezel: Color(red: 0.06, green: 0.07, blue: 0.07),
        text: Color(red: 0.76, green: 1.0, blue: 0.89),
        glow: Color(red: 0.29, green: 1.0, blue: 0.79),
        accent: Color(red: 0.6, green: 1.0, blue: 0.9)
        )
        public static let ice = Style(
        glass: Color(red: 0.02, green: 0.03, blue: 0.06),
        bezel: Color(red: 0.07, green: 0.08, blue: 0.1),
        text: Color(red: 0.86, green: 0.95, blue: 1.0),
        glow: Color(red: 0.29, green: 0.63, blue: 1.0),
        accent: Color(red: 0.7, green: 0.85, blue: 1.0)
        )
    }

    public var title: String
    public var value: String?
    public var status: String?
    public var icon: Image?
    public var style: Style


    public init(title: String, value: String? = nil, status: String? = nil, icon: Image? = nil, style: Style = .amber) {
        self.title = title
        self.value = value
        self.status = status
        self.icon = icon
        self.style = style
    }


    public var body: some View {
        ZStack {
                Bezel(style: style)
                Glass(style: style)
                Content(title: title, value: value, status: status, icon: icon, style: style)
                Scanlines(opacity: style.scanlineOpacity)
                Vignette()
            }
            .compositingGroup()
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
            .stroke(style.bezel.opacity(0.9), lineWidth: 1.5)
            )
            .shadow(color: style.glow.opacity(0.25), radius: 20, x: 0, y: 10)
            .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
            .fill(style.bezel)
            .shadow(radius: 14, x: 0, y: 6)
            )
        }
    }

// MARK: - Subviews
private struct Bezel: View {
    var style: OLEDDisplay.Style
    var body: some View {
        RoundedRectangle(cornerRadius: 20, style: .continuous)
            .fill(
                LinearGradient(colors: [
                    style.bezel.opacity(0.95),
                    style.bezel.opacity(0.8)
                ], startPoint: .top, endPoint: .bottom)
            )
            .overlay(
        RoundedRectangle(cornerRadius: 20, style: .continuous)
            .stroke(style.bezel.opacity(0.6), lineWidth: 2)
        )
    }
}


private struct Glass: View {
    var style: OLEDDisplay.Style
    var body: some View {
    RoundedRectangle(cornerRadius: 16, style: .continuous)
            .inset(by: 6)
            .fill(style.glass)
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .inset(by: 6)
                    .stroke(style.glow.opacity(0.15), lineWidth: 1)
            )
    // Curved specular highlight
            .overlay(
    RoundedRectangle(cornerRadius: 16, style: .continuous)
        .inset(by: 6)
        .fill(
    LinearGradient(colors: [Color.white.opacity(0.18), .clear], startPoint: .topLeading, endPoint: .bottom))
        .blendMode(.screen)
        .mask(
    RoundedRectangle(cornerRadius: 16, style: .continuous)
        .inset(by: 6)
            )
        )
    }
}

private struct Content: View {
var title: String
var value: String?
var status: String?
var icon: Image?
var style: OLEDDisplay.Style


@State private var flicker: Double = 1.0


var body: some View {
    TimelineView(.animation(minimumInterval: 1/24)) { _ in
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 10) {
                if let icon { icon.resizable().scaledToFit().frame(width: 20, height: 20) }
                Text(title.uppercased())
                    .font(.system(.caption, design: .rounded).weight(.semibold))
                    .opacity(0.9)
                Spacer()
            }
            .foregroundStyle(style.accent.opacity(0.9))

            
            HStack(alignment: .firstTextBaseline, spacing: 12) {
                if let value {
                    Text(value)
                        .font(.system(size: 44, weight: .semibold, design: .rounded))
                        .monospacedDigit()
                        .lineLimit(1)
                        .minimumScaleFactor(0.6)
                        .overlay(GlowText(text: value, color: style.glow))
                }
                Spacer()
            }
            .foregroundStyle(style.text)


            if let status {
                Text(status)
                    .font(.system(.footnote, design: .rounded).weight(.regular))
                    .foregroundStyle(style.accent.opacity(0.85))
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .opacity(1.0 - style.flickerAmount + (style.flickerAmount * Foundation.sin(Date.timeIntervalSinceReferenceDate.truncatingRemainder(dividingBy: .pi * 2.0))))
        }
    }
}


private struct GlowText: View {
    var text: String
    var color: Color
    var body: some View {
        Text(text)
            .font(.system(size: 44, weight: .semibold, design: .rounded))
            .monospacedDigit()
            .foregroundStyle(color)
            .blur(radius: 8)
            .opacity(0.7)
            .allowsHitTesting(false)
    }
}




private struct Scanlines: View {
    var opacity: Double
    var speed: CGFloat = 24 // pixels per second


    var body: some View {
        TimelineView(.animation(minimumInterval: 1/60)) { context in
            Canvas { canvas, size in
                let spacing: CGFloat = 3.0
                // Drive motion from time, not state animation
                let t = context.date.timeIntervalSinceReferenceDate
                let phase = (CGFloat(t) * speed).truncatingRemainder(dividingBy: spacing)


                var y: CGFloat = phase
                while y < size.height {
                    let rect = CGRect(x: 0, y: y, width: size.width, height: 1)
                    canvas.fill(Path(rect), with: .color(.white.opacity(opacity)))
                    y += spacing
                }
            }
            .mask(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .inset(by: 6)
            )
            .blendMode(.overlay)
        }
        .allowsHitTesting(false)
    }
}

private struct Vignette: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 16, style: .continuous)
            .inset(by: 6)
            .strokeBorder(.black.opacity(0.35), lineWidth: 10)
            .blur(radius: 12)
            .blendMode(.multiply)
            .allowsHitTesting(false)
    }
}

// MARK: - Demo
struct OLEDDisplay_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 24) {
            OLEDDisplay(title: "CUTOFF", value: "12.3 kHz", icon: Image(systemName: "waveform.path.ecg"), style: .amber)
                .frame(width: 340, height: 140)
            OLEDDisplay(title: "RESONANCE", value: "63%", status: "MOD +12", icon: Image(systemName: "dot.radiowaves.right"), style: .mint)
                .frame(width: 340, height: 140)
            OLEDDisplay(title: "LFO", value: "3.2 Hz", status: "SINE · SYNC", icon: Image(systemName: "aqi.medium"), style: .ice)
                .frame(width: 340, height: 140)
        }
        .padding()
        .background(Color.black)
        .preferredColorScheme(.dark)
        .previewLayout(.sizeThatFits)
    }
}
