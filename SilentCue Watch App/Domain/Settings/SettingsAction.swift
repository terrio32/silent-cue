import ComposableArchitecture
import SCShared

/// 設定画面に関連するアクション
enum SettingsAction: Equatable {
    // 設定の読み込み関連
    case loadSettings
    case settingsLoaded(hapticType: HapticType)

    // 設定の変更関連
    case selectHapticType(HapticType)
    case saveSettings // selectHapticType からもこれが呼ばれる

    // ナビゲーション関連
    case backButtonTapped
}
