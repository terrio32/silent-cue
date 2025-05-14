import SCShared

/// ハプティクスの状態を管理する
struct HapticsState: Equatable {
    var isActive = false
    var hapticType: HapticType = .standard
    var isPreviewingHaptic = false
    var previewTargetHapticType: HapticType? = nil
}
