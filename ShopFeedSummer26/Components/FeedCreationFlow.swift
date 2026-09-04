import SwiftUI

private struct CreatedFeed: Codable, Hashable, Identifiable {
    let id: String
    let name: String
    let sourceCategoryID: String
    let storyIDs: [String]

    var topic: BuyerFeedTopic {
        BuyerFeedTopic(
            id: id,
            label: name,
            sourceCategoryID: sourceCategoryID,
            storyIDs: storyIDs,
            evidence: .discovery
        )
    }
}

private struct BuyerFeedCustomization: Codable {
    var createdFeeds: [CreatedFeed] = []
    var orderedFeedIDs: [String] = []
    var hiddenAuthoredFeedIDs: Set<String> = []
}

/// Prototype persistence for shopper-authored feeds. State is intentionally
/// scoped by preview buyer so a feed created for one dossier never leaks into
/// another buyer's navigation.
@Observable
@MainActor
final class CustomFeedStore {
    static let shared = CustomFeedStore()

    private static let defaultsKey = "customFeedsByPreviewBuyer"
    private static let fixedFeedIDs: Set<String> = ["for-you", "following", "deals"]

    private var customizationByBuyerID: [String: BuyerFeedCustomization]

    private init() {
        if let data = UserDefaults.standard.data(forKey: Self.defaultsKey),
           let decoded = try? JSONDecoder().decode(
               [String: BuyerFeedCustomization].self,
               from: data
           ) {
            customizationByBuyerID = decoded
        } else {
            customizationByBuyerID = [:]
        }
    }

    func navigationTopics(
        for buyerID: String,
        authoredTopics: [BuyerFeedTopic]
    ) -> [BuyerFeedTopic] {
        guard let forYou = authoredTopics.first(where: { $0.id == "for-you" })
            ?? authoredTopics.first else {
            return []
        }
        return [forYou] + managedTopics(for: buyerID, authoredTopics: authoredTopics)
    }

    func managedTopics(
        for buyerID: String,
        authoredTopics: [BuyerFeedTopic]
    ) -> [BuyerFeedTopic] {
        let customization = customizationByBuyerID[buyerID] ?? BuyerFeedCustomization()
        let authored = authoredTopics.filter { !Self.fixedFeedIDs.contains($0.id) }
        let created = customization.createdFeeds.map(\.topic)
        let available = (authored + created).filter {
            !customization.hiddenAuthoredFeedIDs.contains($0.id)
        }
        let byID = Dictionary(uniqueKeysWithValues: available.map { ($0.id, $0) })
        let availableIDs = Set(byID.keys)
        let persistedOrder = customization.orderedFeedIDs.filter(availableIDs.contains)
        let newIDs = available.map(\.id).filter { !persistedOrder.contains($0) }
        return (persistedOrder + newIDs).compactMap { byID[$0] }
    }

    @discardableResult
    func createFeed(
        named rawName: String,
        for buyerID: String,
        using placeholderSource: BuyerFeedTopic
    ) -> BuyerFeedTopic? {
        let name = rawName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !name.isEmpty else { return nil }

        var customization = customizationByBuyerID[buyerID] ?? BuyerFeedCustomization()
        let feed = CreatedFeed(
            id: "created-feed-\(UUID().uuidString.lowercased())",
            name: name,
            sourceCategoryID: placeholderSource.sourceCategoryID,
            storyIDs: placeholderStoryIDs(
                from: placeholderSource.storyIDs,
                offset: customization.createdFeeds.count
            )
        )
        customization.createdFeeds.append(feed)
        customization.orderedFeedIDs.append(feed.id)
        customizationByBuyerID[buyerID] = customization
        persist()
        return feed.topic
    }

    func moveFeed(
        _ feedID: String,
        to targetID: String,
        for buyerID: String,
        authoredTopics: [BuyerFeedTopic]
    ) {
        guard feedID != targetID else { return }
        var orderedIDs = managedTopics(
            for: buyerID,
            authoredTopics: authoredTopics
        ).map(\.id)
        guard let sourceIndex = orderedIDs.firstIndex(of: feedID),
              let targetIndex = orderedIDs.firstIndex(of: targetID) else { return }

        orderedIDs.remove(at: sourceIndex)
        orderedIDs.insert(feedID, at: targetIndex)

        var customization = customizationByBuyerID[buyerID] ?? BuyerFeedCustomization()
        customization.orderedFeedIDs = orderedIDs
        customizationByBuyerID[buyerID] = customization
        persist()
    }

    func deleteFeed(
        _ feedID: String,
        for buyerID: String,
        authoredTopics: [BuyerFeedTopic]
    ) {
        guard !Self.fixedFeedIDs.contains(feedID) else { return }
        var customization = customizationByBuyerID[buyerID] ?? BuyerFeedCustomization()

        if customization.createdFeeds.contains(where: { $0.id == feedID }) {
            customization.createdFeeds.removeAll { $0.id == feedID }
        } else if authoredTopics.contains(where: { $0.id == feedID }) {
            customization.hiddenAuthoredFeedIDs.insert(feedID)
        }
        customization.orderedFeedIDs.removeAll { $0 == feedID }
        customizationByBuyerID[buyerID] = customization
        persist()
    }

    private func placeholderStoryIDs(from storyIDs: [String], offset: Int) -> [String] {
        guard !storyIDs.isEmpty else { return [] }
        let count = min(2, storyIDs.count)
        return (0..<count).map { index in
            storyIDs[(offset + index) % storyIDs.count]
        }
    }

    private func persist() {
        guard let data = try? JSONEncoder().encode(customizationByBuyerID) else { return }
        UserDefaults.standard.set(data, forKey: Self.defaultsKey)
    }
}

struct CreateFeedSheet: View {
    let onCreate: (String) -> Void

    private static let commonEnglishGivenNames = "|aaron|abigail|adam|alex|alexander|alexis|alice|amanda|amber|amy|andrew|angela|anna|anthony|arthur|ashley|ava|ben|benjamin|bethany|brandon|brian|brittany|cameron|carl|caroline|carolyn|charles|charlotte|chloe|chris|christian|christopher|claire|daniel|david|deborah|diana|dominic|donna|dylan|edward|eleanor|elizabeth|ella|ellie|emily|emma|eric|ethan|evelyn|faith|george|grace|hannah|harry|hazel|heather|henry|holly|ian|isaac|isabella|jack|jacob|james|jane|jason|jennifer|jessica|joan|joe|john|jonathan|jordan|joseph|joshua|julia|julian|justin|karen|katherine|katie|kevin|kimberly|laura|lauren|leo|leon|liam|lily|linda|lisa|logan|lucas|lucy|luke|madeline|madison|margaret|maria|mark|mary|mason|matthew|megan|melissa|mia|michael|michelle|nancy|natalie|nicholas|nicole|noah|oliver|olivia|owen|pamela|patrick|paul|penelope|peter|rachel|rebecca|richard|robert|rose|ruby|ryan|samantha|samuel|sarah|scarlett|sean|sebastian|sophia|sophie|stephanie|stephen|susan|taylor|thomas|timothy|victoria|violet|william|willow|zachary|"

    @Environment(\.dismiss) private var dismiss
    @FocusState private var nameFieldIsFocused: Bool
    @State private var name = ""
    @State private var removedLeonMatch = false

    private var trimmedName: String {
        name.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var detectsLeon: Bool {
        trimmedName.range(of: "leon", options: [.caseInsensitive, .diacriticInsensitive]) != nil
    }

    private var showsLeonPersona: Bool {
        detectsLeon && !removedLeonMatch
    }

    private var detectsEnglishPersonalName: Bool {
        trimmedName.lowercased().split(whereSeparator: { !$0.isLetter }).contains { token in
            Self.commonEnglishGivenNames.contains("|\(token)|")
        }
    }

    private var showsPersonaOptions: Bool {
        detectsLeon || detectsEnglishPersonalName
    }

    var body: some View {
        sheetSurface
            .padding(.horizontal, GravitySpacing.space8)
            .padding(.bottom, GravitySpacing.space8)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
            .background(Color.black.opacity(0.18).ignoresSafeArea())
            .presentationBackground(.clear)
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    nameFieldIsFocused = true
                }
            }
    }

    private var sheetSurface: some View {
        VStack(spacing: 0) {
            VStack(spacing: GravitySpacing.space40) {
                header
                nameField
                if showsPersonaOptions {
                    personaOptions
                }
            }
            .padding(.horizontal, GravitySpacing.space16)
            .padding(.top, GravitySpacing.space20)
            .padding(.bottom, showsPersonaOptions ? GravitySpacing.space44 : 64)

            Text("Shop will use this name to shape your feed. You can fine-tune it anytime.")
                .gravityTextStyle(GravityTypography.caption)
                .foregroundStyle(GravityColors.textTertiary)
                .multilineTextAlignment(.center)
                .frame(width: 295, height: 32, alignment: .top)
                .padding(.horizontal, GravitySpacing.space20)
                .padding(.bottom, GravitySpacing.space16)
        }
        .frame(maxWidth: .infinity)
        .background {
            RoundedRectangle(cornerRadius: GravityRadius.r40, style: .continuous)
                .fill(GravityColors.bgFill)
        }
        .clipShape(RoundedRectangle(cornerRadius: GravityRadius.r40, style: .continuous))
        .shadow(
            color: GravityColors.shadow200,
            radius: GravitySpacing.space24,
            y: GravitySpacing.space4
        )
        .onChange(of: name) { oldValue, newValue in
            if oldValue != newValue && !detectsLeon {
                removedLeonMatch = false
            }
        }
    }

    private var header: some View {
        HStack {
            sheetIconButton(
                icon: .leftChevron,
                foreground: GravityColors.text,
                background: GravityColors.bgFill,
                accessibilityLabel: "Close"
            ) {
                dismiss()
            }

            Spacer()

            sheetIconButton(
                icon: .checkmark,
                foreground: GravityColors.textFixedLight,
                background: GravityColors.bgFillBrand,
                accessibilityLabel: "Create feed"
            ) {
                guard !trimmedName.isEmpty else { return }
                HapticFeedback.medium.fire()
                onCreate(trimmedName)
            }
            .disabled(trimmedName.isEmpty)
        }
    }

    private var nameField: some View {
        TextField("Photography", text: $name)
            .font(GravityFont.bold.fixedFont(size: 36))
            .tracking(GravityLetterSpacing.slammed)
            .foregroundStyle(GravityColors.text)
            .multilineTextAlignment(.center)
            .textInputAutocapitalization(.words)
            .autocorrectionDisabled()
            .submitLabel(.done)
            .focused($nameFieldIsFocused)
            .frame(height: 42)
            .accessibilityLabel("Feed name")
            .onSubmit {
                guard !trimmedName.isEmpty else { return }
                onCreate(trimmedName)
            }
    }

    private var personaOptions: some View {
        HStack(spacing: GravitySpacing.space6) {
            if showsLeonPersona {
                leonPersonaChip
                    .transition(.scale.combined(with: .opacity))
            }
            createPersonaChip
        }
        .frame(height: GravitySpacing.space40)
        .animation(.easeOut(duration: 0.16), value: showsLeonPersona)
    }

    private var leonPersonaChip: some View {
        HStack(spacing: GravitySpacing.space8) {
            Image("leon-persona", bundle: .main)
                .resizable()
                .scaledToFill()
                .frame(width: GravitySpacing.space32, height: GravitySpacing.space32)
                .clipShape(Circle())
                .overlay {
                    Circle().strokeBorder(GravityColors.borderImage, lineWidth: 0.5)
                }
            Text("Leon")
                .gravityTextStyle(GravityTypography.buttonMedium)
                .foregroundStyle(GravityColors.text)
        }
        .padding(.leading, GravitySpacing.space4)
        .padding(.trailing, GravitySpacing.space16)
        .frame(height: GravitySpacing.space40)
        .background(GravityColors.bgFill, in: Capsule())
        .overlay { Capsule().strokeBorder(GravityColors.borderSecondary, lineWidth: 0.5) }
        .shadow(color: GravityColors.shadow100, radius: GravitySpacing.space8, y: GravitySpacing.space2)
        .overlay(alignment: .topTrailing) {
            Button {
                HapticFeedback.light.fire()
                removedLeonMatch = true
            } label: {
                GravityIcon.minusSign.image
                    .resizable()
                    .scaledToFit()
                    .frame(width: 12, height: 12)
                    .foregroundStyle(GravityColors.text)
                    .frame(width: GravitySpacing.space20, height: GravitySpacing.space20)
                    .background(GravityColors.bgFill.opacity(0.85), in: Circle())
                    .overlay { Circle().strokeBorder(GravityColors.borderSecondary, lineWidth: 0.5) }
                    .shadow(color: GravityColors.shadow200, radius: GravitySpacing.space12, y: GravitySpacing.space4)
            }
            .buttonStyle(PressScaleButtonStyle())
            .offset(x: 5, y: -5)
            .accessibilityLabel("Remove Leon persona")
        }
    }

    private var createPersonaChip: some View {
        Button {
            HapticFeedback.light.fire()
        } label: {
            HStack(spacing: 0) {
                GravityIcon.plusSign.image
                    .resizable()
                    .scaledToFit()
                    .frame(width: GravitySpacing.space24, height: GravitySpacing.space24)
                    .foregroundStyle(GravityColors.textTertiary)
                    .frame(width: GravitySpacing.space32, height: GravitySpacing.space32)
                Text("Create new persona")
                    .gravityTextStyle(GravityTypography.buttonMedium)
                    .foregroundStyle(GravityColors.text)
            }
            .padding(.leading, GravitySpacing.space4)
            .padding(.trailing, GravitySpacing.space12)
            .frame(height: GravitySpacing.space40)
            .background(GravityColors.bgFill, in: Capsule())
            .overlay {
                Capsule()
                    .stroke(
                        Color.black.opacity(0.16),
                        style: StrokeStyle(lineWidth: 1, dash: [4, 4])
                    )
            }
        }
        .buttonStyle(PressScaleButtonStyle())
        .accessibilityHint("Persona creation is not available in this prototype")
    }

    private func sheetIconButton(
        icon: GravityIcon,
        foreground: Color,
        background: Color,
        accessibilityLabel: String,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            icon.image
                .resizable()
                .scaledToFit()
                .frame(width: GravitySpacing.space20, height: GravitySpacing.space20)
                .foregroundStyle(foreground)
                .frame(width: GravitySpacing.space44, height: GravitySpacing.space44)
                .background(background, in: Circle())
                .overlay { Circle().strokeBorder(GravityColors.borderSecondary, lineWidth: 0.5) }
                .shadow(color: GravityColors.shadow100, radius: GravitySpacing.space8, y: GravitySpacing.space2)
        }
        .buttonStyle(PressScaleButtonStyle())
        .accessibilityLabel(accessibilityLabel)
    }
}

struct FeedManagerSheet: View {
    @Environment(\.dismiss) private var dismiss

    @Bindable var store: CustomFeedStore
    let buyerID: String
    let authoredTopics: [BuyerFeedTopic]
    let selectedFeedID: String
    let onCreateNew: () -> Void
    let onDeleteSelectedFeed: () -> Void

    @State private var pendingDeletion: BuyerFeedTopic?

    private var feeds: [BuyerFeedTopic] {
        store.managedTopics(for: buyerID, authoredTopics: authoredTopics)
    }

    private var sheetHeight: CGFloat {
        min(620, max(260, 170 + CGFloat(feeds.count) * 52))
    }

    var body: some View {
        VStack(spacing: 0) {
            managerHeader

            List {
            ForEach(feeds) { feed in
                feedRow(feed)
                    .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 20))
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                        Button(role: .destructive) {
                            pendingDeletion = feed
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                    .dropDestination(for: String.self) { draggedIDs, _ in
                        guard let draggedID = draggedIDs.first else { return false }
                        store.moveFeed(
                            draggedID,
                            to: feed.id,
                            for: buyerID,
                            authoredTopics: authoredTopics
                        )
                        HapticFeedback.light.fire()
                        return true
                    }
            }

                Button {
                    HapticFeedback.light.fire()
                    onCreateNew()
                } label: {
                    HStack(spacing: GravitySpacing.space10) {
                        Image("icon-plus-sign-small", bundle: .main)
                            .renderingMode(.template)
                            .resizable()
                            .scaledToFit()
                            .frame(width: GravitySpacing.space16, height: GravitySpacing.space16)
                            .foregroundStyle(GravityColors.textBrand)
                            .frame(width: GravitySpacing.space36, height: GravitySpacing.space36)
                            .background(Color(hex: "#EFEAFF"), in: Circle())

                        Text("Create new feed")
                            .gravityTextStyle(GravityTypography.subtitle)
                            .foregroundStyle(GravityColors.textBrand)
                    }
                    .frame(maxWidth: .infinity, minHeight: GravitySpacing.space36, alignment: .leading)
                }
                .buttonStyle(.plain)
                .listRowInsets(EdgeInsets(top: 8, leading: 20, bottom: 8, trailing: 20))
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            .contentMargins(.top, 0, for: .scrollContent)
        }
        .background(GravityColors.bgFill)
        .alert(
            "Delete feed?",
            isPresented: Binding(
                get: { pendingDeletion != nil },
                set: { if !$0 { pendingDeletion = nil } }
            ),
            presenting: pendingDeletion
        ) { feed in
            Button("Cancel", role: .cancel) {
                pendingDeletion = nil
            }
            Button("Delete", role: .destructive) {
                store.deleteFeed(
                    feed.id,
                    for: buyerID,
                    authoredTopics: authoredTopics
                )
                if feed.id == selectedFeedID {
                    onDeleteSelectedFeed()
                }
                pendingDeletion = nil
            }
        } message: { feed in
            Text("“\(feed.label)” will be removed from your feeds.")
        }
        .presentationDetents([.height(sheetHeight)])
        .presentationCornerRadius(GravityRadius.r40)
        .presentationDragIndicator(.visible)
        .presentationBackground(GravityColors.bgFill)
    }

    private var managerHeader: some View {
        HStack(alignment: .center, spacing: GravitySpacing.space12) {
            VStack(alignment: .leading, spacing: 2) {
                Text("Manage feeds")
                    .gravityTextStyle(GravityTypography.headerBold)
                    .foregroundStyle(GravityColors.text)
                Text("Hold and drag to reorder")
                    .gravityTextStyle(GravityTypography.caption)
                    .foregroundStyle(GravityColors.textSecondary)
            }

            Spacer()

            Button {
                dismiss()
            } label: {
                GravityIcon.cross.image
                    .resizable()
                    .scaledToFit()
                    .frame(width: GravitySpacing.space16, height: GravitySpacing.space16)
                    .foregroundStyle(GravityColors.text)
                    .frame(width: GravitySpacing.space36, height: GravitySpacing.space36)
                    .background(GravityColors.bgFillSecondary, in: Circle())
            }
            .buttonStyle(PressScaleButtonStyle())
            .accessibilityLabel("Close feed manager")
        }
        .padding(.horizontal, GravitySpacing.space20)
        .padding(.top, GravitySpacing.space20)
        .padding(.bottom, GravitySpacing.space8)
    }

    private func feedRow(_ feed: BuyerFeedTopic) -> some View {
        HStack(spacing: GravitySpacing.space10) {
            Image(systemName: "line.3.horizontal")
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(GravityColors.textTertiary)
                .frame(width: GravitySpacing.space20, height: GravitySpacing.space36)

            feedBadge(feed)

            Text(feed.label)
                .gravityTextStyle(GravityTypography.subtitle)
                .foregroundStyle(GravityColors.text)
                .lineLimit(1)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(minHeight: GravitySpacing.space36)
        .contentShape(Rectangle())
        .draggable(feed.id)
    }

    private func feedBadge(_ feed: BuyerFeedTopic) -> some View {
        let treatment = feedBadgeTreatment(for: feed)
        return Image(systemName: treatment.symbol)
            .font(.system(size: 15, weight: .semibold))
            .foregroundStyle(treatment.foreground)
            .frame(width: GravitySpacing.space36, height: GravitySpacing.space36)
            .background(treatment.background, in: Circle())
    }

    private func feedBadgeTreatment(
        for feed: BuyerFeedTopic
    ) -> (symbol: String, foreground: Color, background: Color) {
        let value = "\(feed.id) \(feed.label)".lowercased()
        if value.contains("hat") || value.contains("cap") {
            return ("baseball.cap.fill", Color(hex: "#6A4330"), Color(hex: "#EEE0D5"))
        }
        if value.contains("living") || value.contains("home") || value.contains("design") {
            return ("sofa.fill", Color(hex: "#405846"), Color(hex: "#DDE8DF"))
        }
        if value.contains("style") || value.contains("essential") {
            return ("tshirt.fill", Color(hex: "#5C4665"), Color(hex: "#E9DFED"))
        }
        if value.contains("wellness") || value.contains("training") || value.contains("skin") {
            return ("heart.fill", Color(hex: "#864D52"), Color(hex: "#F1DFE0"))
        }
        if value.contains("food") || value.contains("coffee") || value.contains("morning") {
            return ("cup.and.saucer.fill", Color(hex: "#79562E"), Color(hex: "#F2E4CE"))
        }
        if value.contains("outdoor") || value.contains("bird") || value.contains("trail") {
            return ("mountain.2.fill", Color(hex: "#466044"), Color(hex: "#DCE7D7"))
        }
        if value.contains("tech") || value.contains("sim") {
            return ("display", Color(hex: "#405A70"), Color(hex: "#DEE8EF"))
        }
        return ("sparkles", Color(hex: "#5433EB"), Color(hex: "#EFEAFF"))
    }
}

extension HomePage {
    func createFeed(named name: String) {
        guard let placeholderSource = buyerPreview.navigationTopics.first,
              let topic = customFeedStore.createFeed(
                named: name,
                for: buyerPreview.selected.id,
                using: placeholderSource
              ) else { return }

        showsFeedCreator = false
        selectTopic(topic)
    }

    func openFeedCreatorFromManager() {
        showsFeedManager = false
        Task { @MainActor in
            try? await Task.sleep(for: .milliseconds(350))
            showsFeedCreator = true
        }
    }
}
