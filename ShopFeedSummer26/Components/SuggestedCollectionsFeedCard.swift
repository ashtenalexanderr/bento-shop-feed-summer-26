import SwiftUI

/// A reusable feed-card format for a small set of personalized collection
/// destinations. The presentation owns its content; this view owns paging,
/// active-color transitions, and navigation affordances.
struct SuggestedCollectionsFeedCard: View {
    let presentation: SuggestedCollectionsPresentation
    let merchants: [SampleMerchant]
    let width: CGFloat
    let height: CGFloat
    let namespace: Namespace.ID
    var cornerRadius: CGFloat = FeedCardStyle.cornerRadius
    var bottomCornerRadius: CGFloat? = nil
    var foregroundTopPadding: CGFloat = GravitySpacing.space20
    var borderOpacity: Double = 0.12
    var shadowOpacity: Double = 1
    let onOpenCollection: (FeedStory) -> Void
    let onOverflowTap: () -> Void

    @State private var selectedCollectionID: String?

    private var activeCollection: FeedStory {
        presentation.collections.first { $0.id == selectedCollectionID }
            ?? presentation.collections[0]
    }

    private var cardShape: UnevenRoundedRectangle {
        UnevenRoundedRectangle(
            topLeadingRadius: cornerRadius,
            bottomLeadingRadius: bottomCornerRadius ?? cornerRadius,
            bottomTrailingRadius: bottomCornerRadius ?? cornerRadius,
            topTrailingRadius: cornerRadius,
            style: .continuous
        )
    }

    var body: some View {
        ZStack {
            Color(hex: activeCollection.accentHex)
                .overlay(.black.opacity(0.08))
                .animation(.easeInOut(duration: 0.28), value: activeCollection.id)

            VStack(alignment: .leading, spacing: GravitySpacing.space16) {
                header
                collectionPager
            }
            .padding(.top, foregroundTopPadding)
            .padding(.bottom, FeedCardStyle.foregroundBottomPadding)
        }
        .frame(width: width, height: height)
        .clipShape(cardShape)
        .overlay {
            cardShape.strokeBorder(.white.opacity(borderOpacity), lineWidth: 0.5)
        }
        .compositingGroup()
        .shadow(
            color: .black.opacity(0.12 * shadowOpacity),
            radius: 24,
            y: 4
        )
        .onAppear {
            if selectedCollectionID == nil {
                selectedCollectionID = presentation.collections.first?.id
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel(presentation.title)
    }

    private var header: some View {
        HStack(alignment: .top, spacing: GravitySpacing.space12) {
            VStack(alignment: .leading, spacing: GravitySpacing.space4) {
                Text(presentation.title)
                    .font(GravityFont.expressiveBold.fixedFont(size: 28))
                    .tracking(-0.6)
                    .lineLimit(1)
                Text(presentation.subtitle)
                    .font(GravityFont.regular.fixedFont(size: 15))
                    .foregroundStyle(.white.opacity(0.70))
                    .lineLimit(1)
            }

            Spacer(minLength: GravitySpacing.space8)

            Button {
                HapticFeedback.light.fire()
                onOverflowTap()
            } label: {
                Image("feedback-overflow")
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20, height: 20)
                    .foregroundStyle(.white)
                    .frame(width: GravitySpacing.space36, height: GravitySpacing.space36)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel("More")
        }
        .foregroundStyle(.white)
        .gravityShadow(GravityShadows.feedText)
        .padding(.horizontal, FeedCardStyle.foregroundHorizontalPadding)
    }

    private var collectionPager: some View {
        let pageWidth = max(width - 64, 280)
        let pageHeight = max(
            height - foregroundTopPadding - FeedCardStyle.foregroundBottomPadding - 92,
            420
        )

        return ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: GravitySpacing.space12) {
                ForEach(presentation.collections) { collection in
                    collectionCard(collection)
                        .frame(width: pageWidth, height: pageHeight)
                        .id(collection.id)
                }
            }
            .scrollTargetLayout()
        }
        .contentMargins(.horizontal, GravitySpacing.space32, for: .scrollContent)
        .scrollTargetBehavior(.viewAligned(limitBehavior: .always))
        .scrollPosition(id: $selectedCollectionID, anchor: .leading)
        .frame(height: pageHeight)
    }

    private func collectionCard(_ collection: FeedStory) -> some View {
        let resolvedProducts = collection.resolvedProducts(from: merchants)
        let hero = resolvedProducts.first

        return Button {
            HapticFeedback.light.fire()
            onOpenCollection(collection)
        } label: {
            VStack(alignment: .leading, spacing: 0) {
                collectionHero(hero, collection: collection)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)

                VStack(alignment: .leading, spacing: GravitySpacing.space6) {
                    Text(collection.title)
                        .font(GravityFont.expressiveBold.fixedFont(size: 22))
                        .tracking(-0.4)
                        .lineLimit(1)
                    Text(collection.subtitle)
                        .font(GravityFont.regular.fixedFont(size: 14))
                        .foregroundStyle(.white.opacity(0.76))
                        .lineLimit(2)

                    Text(collection.destinationLabel)
                        .font(GravityFont.semiBold.fixedFont(size: 15))
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                        .background(.white.opacity(0.14), in: Capsule())
                        .overlay { Capsule().strokeBorder(.white.opacity(0.12), lineWidth: 0.5) }
                        .padding(.top, GravitySpacing.space8)
                }
                .foregroundStyle(.white)
                .padding(GravitySpacing.space16)
                .gravityShadow(GravityShadows.feedText)
            }
            .background(Color(hex: collection.accentHex).opacity(0.74))
            .clipShape(RoundedRectangle(cornerRadius: GravityRadius.r28, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: GravityRadius.r28, style: .continuous)
                    .strokeBorder(.white.opacity(0.16), lineWidth: 0.5)
            }
            .shadow(color: .black.opacity(0.16), radius: 18, y: 6)
        }
        .buttonStyle(PressScaleButtonStyle(scale: 0.985))
        .matchedTransitionSource(id: collection.id, in: namespace) { source in
            source.clipShape(RoundedRectangle(cornerRadius: GravityRadius.r28, style: .continuous))
        }
        .accessibilityLabel("\(collection.title). \(collection.subtitle)")
        .accessibilityHint(collection.destinationLabel)
    }

    @ViewBuilder
    private func collectionHero(
        _ hero: ResolvedStoryProduct?,
        collection: FeedStory
    ) -> some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(hex: collection.accentHex).opacity(0.42),
                    .white.opacity(0.88),
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            if let hero {
                ProductImageView(product: hero.product, merchant: hero.merchant)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .clipped()
            } else {
                Image(systemName: "square.grid.2x2")
                    .font(.system(size: 54, weight: .light))
                    .foregroundStyle(.white.opacity(0.72))
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: GravityRadius.r24, style: .continuous))
    }
}
