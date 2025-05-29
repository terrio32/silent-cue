import SwiftUI

struct SetTimerView: View {
    var onSettingsButtonTapped: () -> Void
    var onTimerStart: () -> Void
    @State private var selectedMinutes = 5

    var body: some View {
        ScrollView {
            Spacer(minLength: 18)
            // 時間選択エリア
            minutesPicker
            // 開始ボタン
            startButton
        }
        .scrollIndicators(.never)
        .navigationTitle("Silent Cue")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: onSettingsButtonTapped) {
                    Image(systemName: "gearshape.fill")
                        .resizable()
                        .frame(width: 16, height: 16)
                        .foregroundStyle(.white)
                }
            }
        }
    }

    private var minutesPicker: some View {
        HStack(spacing: 20) {
            Button(action: {}) {
                Image(systemName: "minus")
                    .font(.system(size: 20, weight: .bold))
                    .frame(width: 36, height: 36)
                    .background(
                        Circle()
                            .fill(Color.primary.opacity(0.15))
                    )
            }
            .buttonStyle(ControlButtonStyle())
            
            Text("\(selectedMinutes)")
                .font(.system(size: 32, weight: .semibold))
                .frame(width: 50)
            
            Button(action: {}) {
                Image(systemName: "plus")
                    .font(.system(size: 20, weight: .bold))
                    .frame(width: 36, height: 36)
                    .background(
                        Circle()
                            .fill(Color.primary.opacity(0.15))
                    )
            }
            .buttonStyle(ControlButtonStyle())
        }
        .frame(height: 60)
        .padding(.horizontal, 10)
    }

    private var startButton: some View {
        Button(action: onTimerStart) {
            Text("開始")
                .font(.system(size: 18, weight: .medium))
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.secondary.opacity(0.3))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.secondary.opacity(0.4), lineWidth: 1)
                )
                .foregroundStyle(.primary)
        }
        .buttonStyle(.plain)
        .padding(.horizontal)
        .padding(.top, 12)
    }
}

struct ControlButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .opacity(configuration.isPressed ? 0.8 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

#if DEBUG
    #Preview {
        NavigationView {
            SetTimerView(
                onSettingsButtonTapped: {},
                onTimerStart: {}
            )
        }
    }
#endif
