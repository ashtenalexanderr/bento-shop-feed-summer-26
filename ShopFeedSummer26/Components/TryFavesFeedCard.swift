import SwiftUI

enum TryFavesExperience {
    /// World ID, feed entry ID, and shared-view transition source for the
    /// "Try your faves" prototype.
    static let cardID = "try-your-faves"
}

/// The Home feed entry for the Try your faves world: the seed avatar on its
/// stage with a slice of the shopper's try-on-ready favorites.
///
/// The tiles, radii, and type here are the same ones the world uses, so the
/// zoom into the world changes scale and nothing else.
struct TryFavesFeedCard: View {
    let width: CGFloat
    let height: CGFloat
    var foregroundTopPadding: CGFloat = GravitySpacing.space20
    var titleTrailingPadding: CGFloat = 0
    var worldChromeVisibleBottom: CGFloat? = nil
    let onTap: () -> Void

    /// The home card presents the seed outfit as a pre-generated look.
    @State private var garments = TryFavesCatalog.seedLookGarments
    @State private var service = TryFavesLookService.shared

    var body: some View {
        Button {
            HapticFeedback.light.fire()
            onTap()
        } label: {
            ZStack {
                TryFavesStyle.canvas

                // The buyer's seed photograph fills the card edge to edge —
                // the bundled photograph until their generated seed lands.
                if let seed = service.seedRenderImage() {
                    Image(uiImage: seed)
                        .resizable()
                        .scaledToFill()
                        .frame(width: width, height: height)
                        .clipped()
                }

                VStack(alignment: .leading, spacing: GravitySpacing.space12) {
                    Spacer(minLength: 80)
                    title
                    garmentRow
                }
                // Match the shared World-card behavior: while this card is
                // travelling, lift only its bottom chrome above navigation;
                // once snapped, let the title and products hug the card edge.
                .visualEffect { content, proxy in
                    content.offset(
                        y: worldChromeVisibleBottom.map { limit in
                            -max(
                                0,
                                proxy.frame(in: .scrollView(axis: .vertical)).maxY - limit
                            )
                        } ?? 0
                    )
                }
                .padding(.horizontal, FeedCardStyle.foregroundHorizontalPadding)
                .padding(.top, foregroundTopPadding)
                .padding(.bottom, GravitySpacing.space24)
            }
            .frame(width: width, height: height)
            .clipShape(RoundedRectangle(cornerRadius: FeedCardStyle.cornerRadius, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: FeedCardStyle.cornerRadius, style: .continuous)
                    .strokeBorder(TryFavesStyle.tileBorder, lineWidth: 0.5)
            }
            .compositingGroup()
            .shadow(color: .black.opacity(0.07), radius: 16, y: 3)
        }
        .buttonStyle(.plain)
        // Pre-generate the active buyer's seed first, then every other
        // buyer's in the background, so switching profiles lands on a
        // customized photograph instead of the bundled fallback.
        .task(id: BuyerPreviewStore.shared.selected.id) {
            service.syncBuyerIfNeeded()
            service.ensureSeed()
            service.ensureAllSeeds()
        }
        .accessibilityLabel("Try on your favorites")
        .accessibilityHint("Opens your avatar to style saved products into looks")
    }

    private var title: some View {
        Text("Try on your favorites")
            .feedCardTitleStyle()
            .foregroundStyle(TryFavesStyle.stageText)
            .multilineTextAlignment(.leading)
            .lineLimit(3)
            .padding(.trailing, titleTrailingPadding)
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    static func garmentRailHeight(for cardWidth: CGFloat) -> CGFloat {
        (cardWidth
            - FeedCardStyle.foregroundHorizontalPadding * 2
            - GravitySpacing.space8 * 2) / 3
    }

    private var garmentRow: some View {
        let tileSide = Self.garmentRailHeight(for: width)

        return HStack(alignment: .top, spacing: GravitySpacing.space8) {
            ForEach(garments) { garment in
                TryFavesProductTile(
                    garment: garment,
                    width: tileSide,
                    accessory: .price
                )
            }
        }
    }
}

#Preview("Try faves feed card") {
    TryFavesFeedCard(width: 345, height: 590) {}
        .padding()
        .background(Color(hex: "#EAE6E1"))
}
