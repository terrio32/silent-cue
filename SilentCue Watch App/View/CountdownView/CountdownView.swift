import ComposableArchitecture
import SCShared
import SwiftUI

struct CountdownView: View {
    let store: StoreOf<TimerReducer>

    var body: some View {
        WithViewStore(store, observe: { $0 }, content: { viewStore in
            VStack {
                Spacer()

                timeDisplay(
                    displayTime: viewStore.displayTime,
                    remainingSeconds: viewStore.currentRemainingSeconds
                ).accessibilityIdentifier(SCAccessibilityIdentifiers.CountdownView.countdownTimeDisplay.rawValue)

                Spacer()

                cancelButton {
                    viewStore.send(.cancelTimer)
                }.accessibilityIdentifier(SCAccessibilityIdentifiers.CountdownView.cancelTimerButton.rawValue)
            }
            .navigationBarBackButtonHidden(true)
            .onAppear {
                if viewStore.isRunning {
                    viewStore.send(.updateTimerDisplay)
                }
            }
        })
    }

    @ViewBuilder
    private func timeDisplay(displayTime: String, remainingSeconds: Int) -> some View {
        VStack {
            Text(remainingSeconds >= 3600 ? "時間  :  分" : "分  :  秒")
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
