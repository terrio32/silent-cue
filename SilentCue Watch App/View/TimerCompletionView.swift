import SwiftUI

struct TimerCompletionView: View {
    // アニメーション用の状態変数
    @State private var appearAnimation = false

    var body: some View {
        ZStack {
            ScrollView {
                VStack {
                    notifyEndTimeView

                    Spacer(minLength: 13)

                    closeButton

                    Spacer(minLength: 18)

                    timerSummaryView

                    // 下部のスペースを調整
                    Spacer(minLength: 20)
                }
                .padding(.bottom)
            }
        }
        .navigationBarBackButtonHidden(true)
        .onAppear {
            // アニメーションを開始
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                appearAnimation = true
            }
        }
    }

    private var notifyEndTimeView: some View {
        VStack {
            Image(systemName: "bell.and.waves.left.and.right")
                .font(.system(size: 40))
                .foregroundStyle(.primary)

            Spacer()
                .frame(height: 8)

            // キャプション
            Text("終了時刻")
                .font(.system(size: 14))
                .foregroundStyle(.secondary)

            Text(formatTime(Date()))
                .font(.system(size: 24))
                .foregroundStyle(.primary)
        }
        .opacity(appearAnimation ? 1.0 : 0.0)
        .offset(y: appearAnimation ? 0 : 20)
        .animation(.easeInOut(duration: 0.5).delay(0.2), value: appearAnimation)
    }

    private var closeButton: some View {
        Button(action: {}) {
            Text("閉じる")
                .font(.system(size: 16, weight: .medium))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10.5)
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
        .opacity(appearAnimation ? 1.0 : 0.0)
        .animation(.easeInOut(duration: 0.4), value: appearAnimation)
    }

    private var timerSummaryView: some View {
        VStack {
            // 開始時刻
            VStack(spacing: 4) {
                HStack {
                    Text("開始時刻")
                        .font(.system(size: 16))
                        .foregroundStyle(.secondary)
                    Spacer()
                }

                HStack {
                    Text(formatTime(Date()))
                        .font(.system(size: 18, weight: .medium, design: .rounded))
                        .foregroundStyle(.primary)
                    Spacer()
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)

            Divider()
                .background(Color.primary.opacity(0.1))
                .padding(.horizontal, 8)

            // 使用時間
            VStack(spacing: 4) {
                HStack {
                    Text("タイマー時間")
                        .font(.system(size: 14))
                        .foregroundStyle(.secondary)
                    Spacer()
                }

                HStack {
                    Text("5分")
                        .font(.system(size: 18, weight: .medium, design: .rounded))
                        .foregroundStyle(.primary)
                    Spacer()
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
        }
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.secondary.opacity(0.07))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(Color.secondary.opacity(0.15), lineWidth: 1)
        )
        .padding(.horizontal)
        .opacity(appearAnimation ? 1.0 : 0.0)
        .offset(y: appearAnimation ? 0 : 20)
        .animation(.easeInOut(duration: 0.5).delay(0.3), value: appearAnimation)
    }

    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
}

#if DEBUG
    #Preview {
        TimerCompletionView()
    }
#endif
