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

    private var initialCollection: SuggestedCollectionPresentation {
        presentation.collections[0]
    }

    private var activeCollection: SuggestedCollectionPresentation {
        presentation.collections.first { $0.id == selectedCollectionID }
            ?? initialCollection
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
            Color(hex: activeCollection.story.accentHex)
                .overlay(.black.opacity(0.06))
                .animation(.easeInOut(duration: 0.28), value: activeCollection.id)

            VStack(alignment: .leading, spacing: GravitySpacing.space32) {
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
                selectedCollectionID = initialCollection.id
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel(presentation.title)
    }

    private var header: some View {
        HStack(alignment: .center, spacing: GravitySpacing.space12) {
            Text(presentation.title)
                .font(GravityFont.expressiveSemiBold.fixedFont(size: 24))
                .tracking(-0.45)
                .lineLimit(1)

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
        // The visual card is deliberately narrower than the viewport. Each
        // snapping page owns half of the gutter so adjacent cards always peek
        // on both sides without their full-bleed media touching.
        let pageWidth = max(width - 56, 296)
        let availableHeight = height
            - foregroundTopPadding
            - FeedCardStyle.foregroundBottomPadding
            - 110
        let pageHeight = min(availableHeight, max(pageWidth * 1.62, 480))

        return ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: 0) {
                ForEach(presentation.collections) { collection in
                    collectionCard(
                        collection,
                        width: pageWidth,
                        height: pageHeight
                    )
                        .clipShape(RoundedRectangle(cornerRadius: GravityRadius.r28, style: .continuous))
                        .overlay {
                            RoundedRectangle(cornerRadius: GravityRadius.r28, style: .continuous)
                                .strokeBorder(.white.opacity(0.18), lineWidth: 0.5)
                        }
                        .padding(.horizontal, GravitySpacing.space8)
                        .id(collection.id)
                }
            }
            .scrollTargetLayout()
        }
        // 12pt scroll inset + the page-owned 8pt half-gutter places the
        // first card on the same 20pt leading line as the avatar and header.
        .contentMargins(.horizontal, GravitySpacing.space12, for: .scrollContent)
        .scrollTargetBehavior(.viewAligned(limitBehavior: .always))
        .scrollPosition(id: $selectedCollectionID, anchor: .center)
        .frame(height: pageHeight)
    }

    private func collectionCard(
        _ collection: SuggestedCollectionPresentation,
        width: CGFloat,
        height: CGFloat
    ) -> some View {
        Button {
            HapticFeedback.light.fire()
            onOpenCollection(collection.story)
        } label: {
            ZStack(alignment: .bottomLeading) {
                collectionMedia(collection)
                    .frame(width: width, height: height)

                LinearGradient(
                    stops: [
                        .init(color: .clear, location: 0.42),
                        .init(color: Color(hex: collection.story.accentHex).opacity(0.30), location: 0.66),
                        .init(color: Color(hex: collection.story.accentHex).opacity(0.96), location: 1),
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )

                VStack(alignment: .leading, spacing: GravitySpacing.space6) {
                    Text(collection.story.title)
                        .font(GravityFont.expressiveSemiBold.fixedFont(size: 21))
                        .tracking(-0.3)
                        .lineLimit(1)
                    Text(collection.story.subtitle)
                        .font(GravityFont.regular.fixedFont(size: 14))
                        .foregroundStyle(.white.opacity(0.84))
                        .lineLimit(2)

                    Text(collection.story.destinationLabel)
                        .font(GravityFont.semiBold.fixedFont(size: 15))
                        .frame(maxWidth: .infinity)
                        .frame(height: 46)
                        .background(.white.opacity(0.16), in: Capsule())
                        .overlay { Capsule().strokeBorder(.white.opacity(0.14), lineWidth: 0.5) }
                        .padding(.top, GravitySpacing.space8)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .foregroundStyle(.white)
                .padding(GravitySpacing.space16)
                .gravityShadow(GravityShadows.feedText)
            }
            .frame(width: width, height: height)
            .contentShape(Rectangle())
            .shadow(color: .black.opacity(0.16), radius: 18, y: 6)
        }
        .buttonStyle(PressScaleButtonStyle(scale: 0.985))
        .matchedTransitionSource(id: collection.id, in: namespace) { source in
            source.clipShape(RoundedRectangle(cornerRadius: GravityRadius.r28, style: .continuous))
        }
        .accessibilityLabel("\(collection.story.title). \(collection.story.subtitle)")
        .accessibilityHint(collection.story.destinationLabel)
    }

    @ViewBuilder
    private func collectionMedia(_ collection: SuggestedCollectionPresentation) -> some View {
        Image(collection.heroAssetName)
            .resizable()
            .scaledToFill()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .clipped()
    }
}
