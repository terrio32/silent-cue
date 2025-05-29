import SwiftUI

struct CountdownView: View {
    @State private var displayTime = "05:00"
    @State private var remainingSeconds = 300

    var body: some View {
        VStack {
            Spacer()

            timeDisplay(
                displayTime: displayTime,
                remainingSeconds: remainingSeconds
            )

            Spacer()

            cancelButton {
                // Cancel action
            }
        }
        .navigationBarBackButtonHidden(true)
    }

    @ViewBuilder
    private func timeDisplay(displayTime: String, remainingSeconds: Int) -> some View {
        VStack {
            Text("分  :  秒")
                .font(.system(size: 14, weight: .regular))
                .foregroundStyle(.secondary)

            Text(displayTime)
                .font(.system(size: 40, weight: .semibold, design: .monospaced))
                .foregroundStyle(.primary)
        }
    }

    @ViewBuilder
    private func cancelButton(action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text("キャンセル")
                .foregroundStyle(.primary)
                .font(.system(size: 16))
        }
        .buttonStyle(.plain)
        .padding(.horizontal)
    }
}

#if DEBUG
    #Preview {
        CountdownView()
    }
#endif
