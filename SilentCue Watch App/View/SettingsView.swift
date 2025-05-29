import SwiftUI
import ComposableArchitecture
import SCCoordinator

struct SettingsView: View {
    let store: StoreOf<SCCoordinator>
    @State private var selectedHapticType = "Type1"
    let hapticTypes = ["Type1", "Type2", "Type3"]

    var body: some View {
        List {
            Section(header: Text("Vibration Type")) {
                ForEach(hapticTypes, id: \.self) { hapticType in
                    Button(action: {
                        selectedHapticType = hapticType
                    }) {
                        HStack {
                            Text(hapticType)
                            Spacer()
                            if hapticType == selectedHapticType {
                                Image(systemName: "circle.fill")
                                    .foregroundStyle(Color.green.opacity(0.7))
                                    .transition(.opacity)
                                    .animation(.spring(), value: selectedHapticType)
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle("Settings")
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    ViewStore(store).send(.pop)
                } label: {
                    Image(systemName: "chevron.left")
                        .aspectRatio(contentMode: .fit)
                }
            }
        }
    }
}

#if DEBUG
    #Preview {
        NavigationStack {
            SettingsView(
                store: Store(
                    initialState: SCCoordinator.State(),
                    reducer: { SCCoordinator() }
                )
            )
        }
    }
#endif
