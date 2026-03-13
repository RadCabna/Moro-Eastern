import SwiftUI
import PhotosUI

struct AddMarketView: View {
    var editing: Market? = nil

    @Environment(\.dismiss) private var dismiss
    @Environment(AppState.self) private var appState
    @Environment(MarketStore.self) private var store

    @State private var showDeleteAlert = false

    @State private var marketName  = ""
    @State private var country     = ""
    @State private var dateOfVisit: Date? = nil
    @State private var showDatePicker = false

    @State private var selectedPhotoItems: [PhotosPickerItem] = []
    @State private var selectedImages: [UIImage] = []
    @State private var showPhotoSourceDialog = false
    @State private var showPhotoLibrary      = false
    @State private var showCamera            = false
    @State private var cameraUnavailableAlert = false

    @State private var scent = ""
    @State private var sound = ""
    @State private var color = ""

    @State private var purchases: [Purchase] = [Purchase()]
    @State private var proTip = ""
    @State private var showValidation = false

    private var isFormValid: Bool {
        !marketName.isEmpty && !country.isEmpty &&
        dateOfVisit != nil &&
        !scent.isEmpty && !sound.isEmpty && !color.isEmpty
    }

    private let scents = ["Leather", "Spice", "Orange Blossom"]
    private let sounds = ["Distant Ouds", "Chanting", "Copper Smithing"]
    private let colors = ["Indigo", "Ochre", "Burnished Gold"]

    private var dateFormatted: String {
        guard let date = dateOfVisit else { return "DD/MM/YYYY" }
        let f = DateFormatter()
        f.dateFormat = "dd/MM/yyyy"
        return f.string(from: date)
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            Image("background")
                .resizable()
                .ignoresSafeArea()

            VStack(spacing: 0) {
                header
                scrollContent
            }

            saveButton
                .padding(.horizontal, screenHeight * 0.02)
                .padding(.bottom, screenHeight * 0.05)
        }
        .ignoresSafeArea(edges: .bottom)
        .navigationBarHidden(true)
        .sheet(isPresented: $showDatePicker) { datePickerSheet }
        .photosPicker(isPresented: $showPhotoLibrary,
                      selection: $selectedPhotoItems,
                      maxSelectionCount: 10,
                      matching: .images)
        .fullScreenCover(isPresented: $showCamera) {
            CameraImagePicker(images: $selectedImages)
        }
        .confirmationDialog("Add Photo", isPresented: $showPhotoSourceDialog, titleVisibility: .visible) {
            Button("Camera") {
                requestCameraAccess { granted in
                    if granted {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                            showCamera = true
                        }
                    } else {
                        cameraUnavailableAlert = true
                    }
                }
            }
            Button("Photo Library") { showPhotoLibrary = true }
            Button("Cancel", role: .cancel) {}
        }
        .alert("Camera Unavailable", isPresented: $cameraUnavailableAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Please allow camera access in Settings to take photos.")
        }
        .onChange(of: selectedPhotoItems) { loadPhotos() }
        .scrollDismissesKeyboard(.interactively)
        .onAppear {
            appState.hideBar()
            if let m = editing {
                marketName     = m.name
                country        = m.country
                dateOfVisit    = m.dateOfVisit
                selectedImages = m.images
                scent          = m.scent
                sound          = m.sound
                color          = m.color
                purchases      = m.purchases.isEmpty ? [Purchase()] : m.purchases
                proTip         = m.proTip
            }
        }
        .onDisappear { appState.showBar() }
        .alert("Delete Market?", isPresented: $showDeleteAlert) {
            Button("Delete", role: .destructive) {
                guard let m = editing else { return }
                dismiss()
                DispatchQueue.main.async {
                    self.store.delete(m)
                    self.appState.popToRootMarket = true
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This entry will be permanently removed from your diary.")
        }
    }

    // MARK: – Header

    private var header: some View {
        ZStack {
            Text(editing == nil ? "Add New Market" : "Edit Market")
                .font(.sfProSemibold(screenHeight * 0.025))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .center)

            HStack {
                backButton
                    .padding(.leading, screenHeight * 0.025)
                Spacer()
            }
        }
        .padding(.top, screenHeight * 0.02)
        .padding(.bottom, screenHeight * 0.02)
    }

    // MARK: – Scroll

    private var scrollContent: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: screenHeight * 0.02) {
                generalBlock
                sensoryBlock
                purchasesBlock
                proTipBlock
            }
            .padding(.horizontal, screenHeight * 0.02)
            .padding(.top, screenHeight * 0.01)
            .padding(.bottom, editing != nil ? screenHeight * 0.24 : screenHeight * 0.14)
        }
        .scrollDismissesKeyboard(.interactively)
        .hideKeyboardOnTap()
    }

    // MARK: – General Information

    private var generalBlock: some View {
        block {
            VStack(alignment: .leading, spacing: screenHeight * 0.018) {
                sectionHeader(icon: "mappin.and.ellipse", title: "General information")

                fieldLabel("Market Name")
                styledField("Market", text: $marketName)

                fieldLabel("Country")
                styledField("Name country", text: $country)

                fieldLabel("Date of Visit")
                dateField

                fieldLabel("Image")
                imageSection
            }
        }
    }

    private var dateField: some View {
        let hasError = showValidation && dateOfVisit == nil
        return VStack(alignment: .leading, spacing: screenHeight * 0.006) {
            Button { showDatePicker = true } label: {
                HStack {
                    Text(dateFormatted)
                        .font(.sfProSemibold(screenHeight * 0.018))
                        .foregroundColor(dateOfVisit == nil ? .white.opacity(0.35) : .white)
                    Spacer()
                    Image(systemName: "calendar")
                        .foregroundColor(.white.opacity(0.5))
                        .font(.system(size: screenHeight * 0.02))
                }
                .padding(.horizontal, screenHeight * 0.022)
                .padding(.vertical, screenHeight * 0.016)
                .background(Capsule().fill(Color.white.opacity(0.07)))
                .overlay(Capsule().stroke(hasError ? Color.red.opacity(0.8) : Color.clear, lineWidth: 1.5))
            }
            .buttonStyle(.plain)

            if hasError {
                Text("You need to fill in this field")
                    .font(.sfProSemibold(screenHeight * 0.014))
                    .foregroundColor(.red.opacity(0.85))
                    .padding(.horizontal, screenHeight * 0.022)
            }
        }
    }

    private var imageSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: screenHeight * 0.012) {
                Button { showPhotoSourceDialog = true } label: {
                    Image("addPhoto")
                        .resizable()
                        .scaledToFit()
                        .frame(width: screenHeight * 0.1, height: screenHeight * 0.1)
                }
                .buttonStyle(.plain)

                ForEach(selectedImages.indices, id: \.self) { i in
                    Image(uiImage: selectedImages[i])
                        .resizable()
                        .scaledToFill()
                        .frame(width: screenHeight * 0.1, height: screenHeight * 0.1)
                        .clipShape(RoundedRectangle(cornerRadius: screenHeight * 0.018))
                        .overlay(alignment: .topTrailing) {
                            Button { selectedImages.remove(at: i) } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.system(size: screenHeight * 0.025))
                                    .foregroundColor(.red)
                                    .background(Color.white.clipShape(Circle()))
                            }
                            .offset(x: screenHeight * 0.01, y: -screenHeight * 0.01)
                        }
                }
            }
            .padding(.top, screenHeight * 0.015)
            .padding(.bottom, screenHeight * 0.005)
        }
    }

    // MARK: – Sensory Impressions

    private var sensoryBlock: some View {
        block {
            VStack(alignment: .leading, spacing: screenHeight * 0.02) {
                sectionHeader(icon: "sparkles", title: "Sensory Impressions")

                DropdownPickerView(title: "Scents", iconSystemName: "leaf.fill",    options: scents, selection: $scent, showError: showValidation && scent.isEmpty)
                DropdownPickerView(title: "Sounds", iconSystemName: "music.note",   options: sounds, selection: $sound, showError: showValidation && sound.isEmpty)
                DropdownPickerView(title: "Colors", iconSystemName: "paintpalette", options: colors, selection: $color, showError: showValidation && color.isEmpty)
            }
        }
    }

    // MARK: – Notable Purchases

    private var purchasesBlock: some View {
        block {
            VStack(alignment: .leading, spacing: screenHeight * 0.016) {
                sectionHeader(icon: "bag", title: "Notable Purchases")

                HStack {
                    Text("Item")
                        .font(.sfProSemibold(screenHeight * 0.016))
                        .foregroundColor(.white.opacity(0.5))
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Text("Price")
                        .font(.sfProSemibold(screenHeight * 0.016))
                        .foregroundColor(.white.opacity(0.5))
                        .frame(width: screenHeight * 0.1, alignment: .leading)
                }
                .padding(.horizontal, screenHeight * 0.006)

                ForEach($purchases) { $purchase in
                    purchaseRow(purchase: $purchase)
                }

                Button {
                    purchases.append(Purchase())
                } label: {
                    HStack(spacing: screenHeight * 0.008) {
                        Image(systemName: "plus.circle")
                            .foregroundColor(Color("textColor_1"))
                            .font(.system(size: screenHeight * 0.02))
                        Text("Add another item")
                            .font(.sfProSemibold(screenHeight * 0.018))
                            .foregroundColor(Color("textColor_1"))
                    }
                }
                .buttonStyle(.plain)
                .padding(.top, screenHeight * 0.005)
            }
        }
    }

    private func purchaseRow(purchase: Binding<Purchase>) -> some View {
        HStack(spacing: screenHeight * 0.01) {
            Button {
                purchases.removeAll { $0.id == purchase.wrappedValue.id }
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.red.opacity(0.85))
                    .font(.system(size: screenHeight * 0.025))
            }
            .buttonStyle(.plain)

            TextField(
                text: purchase.item,
                prompt: Text("Item").foregroundStyle(Color.white.opacity(0.35))
            ) {}
                .font(.sfProSemibold(screenHeight * 0.017))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.horizontal, screenHeight * 0.018)
                .padding(.vertical, screenHeight * 0.013)
                .background(Capsule().fill(Color.white.opacity(0.07)))

            TextField(
                text: purchase.price,
                prompt: Text("0").foregroundStyle(Color.white.opacity(0.35))
            ) {}
                .font(.sfProSemibold(screenHeight * 0.017))
                .foregroundColor(.white)
                .keyboardType(.decimalPad)
                .frame(width: screenHeight * 0.08)
                .padding(.horizontal, screenHeight * 0.018)
                .padding(.vertical, screenHeight * 0.013)
                .background(Capsule().fill(Color.white.opacity(0.07)))

            Text("$")
                .font(.sfProSemibold(screenHeight * 0.02))
                .foregroundColor(.white.opacity(0.6))
        }
    }

    // MARK: – Pro Tip

    private var proTipBlock: some View {
        block {
            VStack(alignment: .leading, spacing: screenHeight * 0.016) {
                sectionHeader(icon: "lightbulb", title: "Pro Tip")

                TextField(
                    text: $proTip,
                    prompt: Text("What would you tell a fellow travel?")
                        .foregroundStyle(Color.white.opacity(0.35)),
                    axis: .vertical
                ) {}
                    .font(.sfProSemibold(screenHeight * 0.018))
                    .foregroundColor(.white)
                    .lineLimit(3...6)
                    .padding(.horizontal, screenHeight * 0.022)
                    .padding(.vertical, screenHeight * 0.016)
                    .background(
                        RoundedRectangle(cornerRadius: screenHeight * 0.04)
                            .fill(Color.white.opacity(0.07))
                    )
            }
        }
    }

    // MARK: – Save Button

    private var saveButton: some View {
        VStack(spacing: screenHeight * 0.012) {
            // Save
            Button {
                if isFormValid { saveMarket() }
                else { withAnimation(.easeInOut(duration: 0.2)) { showValidation = true } }
            } label: {
                Text("SAVE TO DIARY")
                    .font(.sfProSemibold(screenHeight * 0.02))
                    .foregroundColor(isFormValid ? .white : Color(white: 0.5))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, screenHeight * 0.02)
                    .background(Capsule().fill(isFormValid ? Color("textColor_1") : Color(white: 0.25)))
            }
            .buttonStyle(.plain)
            .animation(.easeInOut(duration: 0.25), value: isFormValid)

            // Delete (edit mode only)
            if editing != nil {
                Button { showDeleteAlert = true } label: {
                    Text("DELETE")
                        .font(.sfProSemibold(screenHeight * 0.02))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, screenHeight * 0.02)
                        .background(Capsule().fill(Color.red.opacity(0.75)))
                }
                .buttonStyle(.plain)
            }
        }
    }

    // MARK: – Date Picker Sheet

    private var datePickerSheet: some View {
        VStack(spacing: screenHeight * 0.02) {
            DatePicker(
                "",
                selection: Binding(
                    get: { dateOfVisit ?? Date() },
                    set: { dateOfVisit = $0 }
                ),
                displayedComponents: .date
            )
            .datePickerStyle(.graphical)
            .tint(Color("textColor_1"))
            .padding()

            Button("Done") { showDatePicker = false }
                .font(.sfProSemibold(screenHeight * 0.02))
                .foregroundColor(Color("textColor_1"))
                .padding(.bottom, screenHeight * 0.02)
        }
        .presentationDetents([.medium])
    }

    // MARK: – Back Button

    private var backButton: some View {
        Button { dismiss() } label: {
            ZStack {
                TransparentBlurView()
                    .clipShape(Circle())
                    .frame(width: screenHeight * 0.052, height: screenHeight * 0.052)
                    .overlay(
                        Circle()
                            .stroke(
                                AngularGradient(
                                    stops: [
                                        .init(color: .white.opacity(0.7),  location: 0.00),
                                        .init(color: .gray.opacity(0.35),  location: 0.12),
                                        .init(color: .black.opacity(0.05), location: 0.22),
                                        .init(color: .white.opacity(0.7),  location: 0.33),
                                        .init(color: .gray.opacity(0.35),  location: 0.45),
                                        .init(color: .black.opacity(0.05), location: 0.55),
                                        .init(color: .white.opacity(0.7),  location: 0.66),
                                        .init(color: .gray.opacity(0.35),  location: 0.78),
                                        .init(color: .black.opacity(0.05), location: 0.88),
                                        .init(color: .white.opacity(0.7),  location: 1.00),
                                    ],
                                    center: .center
                                ),
                                lineWidth: 1.5
                            )
                    )

                Image(systemName: "chevron.left")
                    .font(.system(size: screenHeight * 0.018, weight: .semibold))
                    .foregroundColor(.white)
            }
        }
        .buttonStyle(.plain)
    }

    // MARK: – Helpers

    @ViewBuilder
    private func block<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        let radius = screenHeight * 0.025
        content()
            .padding(screenHeight * 0.02)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                TransparentBlurView()
                    .clipShape(RoundedRectangle(cornerRadius: radius))
            )
            .overlay(
                RoundedRectangle(cornerRadius: radius)
                    .stroke(
                        AngularGradient(
                            stops: [
                                .init(color: .white.opacity(0.7),  location: 0.00),
                                .init(color: .gray.opacity(0.35),  location: 0.12),
                                .init(color: .black.opacity(0.05), location: 0.22),
                                .init(color: .white.opacity(0.7),  location: 0.33),
                                .init(color: .gray.opacity(0.35),  location: 0.45),
                                .init(color: .black.opacity(0.05), location: 0.55),
                                .init(color: .white.opacity(0.7),  location: 0.66),
                                .init(color: .gray.opacity(0.35),  location: 0.78),
                                .init(color: .black.opacity(0.05), location: 0.88),
                                .init(color: .white.opacity(0.7),  location: 1.00),
                            ],
                            center: .center
                        ),
                        lineWidth: 1.5
                    )
            )
    }

    private func sectionHeader(icon: String, title: String) -> some View {
        VStack(alignment: .leading, spacing: screenHeight * 0.012) {
            HStack(spacing: screenHeight * 0.01) {
                Image(systemName: icon)
                    .foregroundColor(Color("textColor_1"))
                    .font(.system(size: screenHeight * 0.024))
                Text(title)
                    .font(.sfProSemibold(screenHeight * 0.025))
                    .foregroundColor(.white)
            }
            Divider().background(Color.white.opacity(0.15))
        }
    }

    private func fieldLabel(_ text: String) -> some View {
        Text(text)
            .font(.sfProSemibold(screenHeight * 0.018))
            .foregroundColor(.white)
    }

    private func styledField(_ placeholder: String, text: Binding<String>) -> some View {
        let hasError = showValidation && text.wrappedValue.isEmpty
        return VStack(alignment: .leading, spacing: screenHeight * 0.006) {
            TextField(
                text: text,
                prompt: Text(placeholder).foregroundStyle(Color.white.opacity(0.35))
            ) {}
                .font(.sfProSemibold(screenHeight * 0.018))
                .foregroundColor(.white)
                .tint(Color("textColor_1"))
                .padding(.horizontal, screenHeight * 0.022)
                .padding(.vertical, screenHeight * 0.016)
                .background(Capsule().fill(Color.white.opacity(0.07)))
                .overlay(Capsule().stroke(hasError ? Color.red.opacity(0.8) : Color.clear, lineWidth: 1.5))

            if hasError {
                Text("You need to fill in this field")
                    .font(.sfProSemibold(screenHeight * 0.014))
                    .foregroundColor(.red.opacity(0.85))
                    .padding(.horizontal, screenHeight * 0.022)
            }
        }
    }

    // MARK: – Actions

    private func loadPhotos() {
        Task {
            var loaded: [UIImage] = []
            for item in selectedPhotoItems {
                if let data = try? await item.loadTransferable(type: Data.self),
                   let img = UIImage(data: data) {
                    loaded.append(img)
                }
            }
            await MainActor.run { selectedImages = loaded }
        }
    }

    private func saveMarket() {
        let market = Market(
            id: editing?.id ?? UUID(),
            name: marketName,
            country: country,
            dateOfVisit: dateOfVisit,
            images: selectedImages,
            scent: scent,
            sound: sound,
            color: color,
            purchases: purchases.filter { !$0.item.isEmpty },
            proTip: proTip
        )
        let isEdit = editing != nil
        dismiss()
        DispatchQueue.main.async {
            if isEdit {
                self.store.update(market)
                self.appState.popToRootMarket = true
            } else {
                self.store.add(market)
            }
        }
    }
}

#Preview {
    NavigationStack {
        AddMarketView()
    }
    .environment(AppState())
    .environment(MarketStore())
}
