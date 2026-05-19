import SwiftUI

struct ShipSkinPickerView: View {
    @EnvironmentObject private var progress: GameProgressStore

    var body: some View {
        SettingsSectionCard(title: "Ship Style", subtitle: "Unlock styles with stars") {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(ShipSkin.all) { skin in
                        skinCell(skin)
                    }
                }
                .padding(.vertical, 2)
            }
        }
    }

    private func skinCell(_ skin: ShipSkin) -> some View {
        let unlocked = skin.isUnlocked(totalStars: progress.totalStarsEarned)
        let selected = progress.selectedShipSkin == skin.id

        return ShipSkinOptionCell(
            skin: skin,
            unlocked: unlocked,
            selected: selected
        ) {
            guard unlocked else { return }
            HapticService.lightTap()
            progress.selectShipSkin(skin)
        }
    }
}
