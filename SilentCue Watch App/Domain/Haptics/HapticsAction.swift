import ComposableArchitecture
import SCShared

/// ハプティックスに関連するすべてのアクション
enum HapticsAction: Equatable {
    // 振動の制御
    case startHaptic(HapticType)
    case stopHaptic

    // 設定画面でのハプティックプレビュー
    case startPreview(HapticType)
    case previewTick
    case stopPreview

    // 設定
    case updateHapticSettings(type: HapticType)
}
