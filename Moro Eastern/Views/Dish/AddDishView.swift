import SwiftUI
import PhotosUI

struct AddDishView: View {
    var editing: Dish? = nil

    @Environment(\.dismiss)    private var dismiss
    @Environment(AppState.self)  private var appState
    @Environment(DishStore.self) private var store

    @State private var showDeleteAlert = false

    @State private var dishName    = ""
    @State private var country     = ""
    @State private var price       = ""
    @State private var tastes: Set<TasteProfile> = []

    @State private var selectedPhotoItems: [PhotosPickerItem] = []
    @State private var selectedImages: [UIImage] = []
    @State private var showPhotoSourceDialog  = false
    @State private var showPhotoLibrary       = false
    @State private var showCamera             = false
    @State private var cameraUnavailableAlert = false

    @State private var ingredients: [Ingredient] = [Ingredient()]
    @State private var steps: [String] = [""]
    @State private var descriptionText = ""

    @State private var showValidation = false

    private var isFormValid: Bool {
        !dishName.isEmpty && !country.isEmpty
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            Image("background").resizable().ignoresSafeArea()

            VStack(spacing: 0) {
                header
                ScrollView(showsIndicators: false) {
                    VStack(spacing: screenHeight * 0.022) {
                        generalBlock
                        ingredientsBlock
                        stepsBlock
                        descriptionBlock
                    }
                    .padding(.horizontal, screenHeight * 0.022)
                    .padding(.top, screenHeight * 0.018)
                    .padding(.bottom, editing != nil ? screenHeight * 0.24 : screenHeight * 0.14)
                }
                .scrollDismissesKeyboard(.interactively)
                .hideKeyboardOnTap()
            }

            saveButton
                .padding(.horizontal, screenHeight * 0.02)
                .padding(.bottom, screenHeight * 0.05)
        }
        .ignoresSafeArea(edges: .bottom)
        .navigationBarHidden(true)
        .scrollDismissesKeyboard(.interactively)
        .photosPicker(isPresented: $showPhotoLibrary,
                      selection: $selectedPhotoItems,
                      maxSelectionCount: 6,
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
        .onAppear {
            appState.hideBar()
            if let d = editing {
                dishName        = d.name
                country         = d.country
                price           = d.price
                tastes          = Set(d.tasteProfiles)
                selectedImages  = d.images
                ingredients     = d.ingredients.isEmpty ? [Ingredient()] : d.ingredients
                steps           = d.steps.isEmpty ? [""] : d.steps
                descriptionText = d.description
            }
        }
        .onDisappear { appState.showBar() }
        .alert("Delete Dish?", isPresented: $showDeleteAlert) {
            Button("Delete", role: .destructive) {
                guard let d = editing else { return }
                dismiss()
                DispatchQueue.main.async {
                    self.store.delete(d)
                    self.appState.popToRootDish = true
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
            Text(editing == nil ? "Add New Dish" : "Edit Dish")
                .font(.sfProSemibold(screenHeight * 0.025))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .center)
            HStack {
                backButton.padding(.leading, screenHeight * 0.025)
                Spacer()
            }
        }
        .padding(.top, screenHeight * 0.02)
        .padding(.bottom, screenHeight * 0.02)
    }

    // MARK: – Back Button

    private var backButton: some View {
        Button { dismiss() } label: {
            ZStack {
                TransparentBlurView()
                    .clipShape(Circle())
                    .frame(width: screenHeight * 0.052, height: screenHeight * 0.052)
                    .overlay(
                        Circle().stroke(
                            AngularGradient(stops: glassStops, center: .center),
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

    // MARK: – General Information

    private var generalBlock: some View {
        blockContainer(icon: "dishGeneralIcon", title: "General Information") {
            VStack(spacing: screenHeight * 0.014) {
                labeledField("Dish Name",       placeholder: "Saffron infused lamb mansaf", text: $dishName)
                labeledField("Country Of Origin", placeholder: "Jordan",                    text: $country)
                labeledField("Price ($)",        placeholder: "25$",                        text: $price,
                             keyboard: .decimalPad)

                // Taste Profile
                VStack(alignment: .leading, spacing: screenHeight * 0.012) {
                    fieldLabel("Taste Profile")
                    tasteGrid
                }

                // Images
                VStack(alignment: .leading, spacing: screenHeight * 0.012) {
                    fieldLabel("Image")
                    imageRow
                }
            }
        }
    }

    // Taste profile — horizontal scroll, each item same size as photo button
    private var tasteGrid: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: screenHeight * 0.012) {
                ForEach(TasteProfile.allCases, id: \.self) { taste in
                    tasteCell(taste)
                }
            }
        }
    }

    private func tasteCell(_ taste: TasteProfile) -> some View {
        let selected = tastes.contains(taste)
        return Button {
            if selected { tastes.remove(taste) } else { tastes.insert(taste) }
        } label: {
            VStack(spacing: screenHeight * 0.008) {
                ZStack {
                    RoundedRectangle(cornerRadius: screenHeight * 0.028)
                        .fill(selected ? Color("textColor_1").opacity(0.25) : Color.white.opacity(0.07))
                        .frame(width: screenHeight * 0.1, height: screenHeight * 0.1)
                        .overlay(
                            RoundedRectangle(cornerRadius: screenHeight * 0.028)
                                .stroke(selected ? Color("textColor_1") : Color.white.opacity(0.15), lineWidth: 1.5)
                        )
                    Image(taste.iconName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: screenHeight * 0.048, height: screenHeight * 0.048)
                }
                Text(taste.rawValue)
                    .font(.sfProSemibold(screenHeight * 0.013))
                    .foregroundColor(selected ? Color("textColor_1") : .white.opacity(0.75))
                    .lineLimit(1)
                    .frame(width: screenHeight * 0.1)
            }
        }
        .buttonStyle(.plain)
        .animation(.easeInOut(duration: 0.15), value: selected)
    }

    // Image picker row
    private var imageRow: some View {
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
                                    .font(.system(size: screenHeight * 0.022))
                                    .foregroundColor(.red)
                                    .background(Circle().fill(Color.black.opacity(0.4)))
                            }
                            .offset(x: screenHeight * 0.01, y: -screenHeight * 0.01)
                        }
                }
            }
            .padding(.vertical, screenHeight * 0.008)
        }
    }

    // MARK: – Ingredients

    private var ingredientsBlock: some View {
        blockContainer(icon: "dishIngridientIcon", title: "Main Ingredients") {
            VStack(spacing: 0) {
                // Header row
                HStack {
                    Text("Ingredient")
                        .font(.sfProSemibold(screenHeight * 0.015))
                        .foregroundColor(.white.opacity(0.55))
                    Spacer()
                    Text("Qt.")
                        .font(.sfProSemibold(screenHeight * 0.015))
                        .foregroundColor(.white.opacity(0.55))
                        .frame(width: screenHeight * 0.1)
                }
                .padding(.bottom, screenHeight * 0.01)

                ForEach($ingredients) { $ingredient in
                    ingredientRow($ingredient)
                }

                Button {
                    ingredients.append(Ingredient())
                } label: {
                    HStack(spacing: screenHeight * 0.008) {
                        Image(systemName: "plus.circle")
                            .font(.system(size: screenHeight * 0.018))
                        Text("Add another ingredient")
                            .font(.sfProSemibold(screenHeight * 0.016))
                    }
                    .foregroundColor(Color("textColor_1"))
                    .padding(.top, screenHeight * 0.014)
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .buttonStyle(.plain)
            }
        }
    }

    private func ingredientRow(_ ingredient: Binding<Ingredient>) -> some View {
        HStack(spacing: screenHeight * 0.01) {
            // Delete button (shown only when > 1 ingredient)
            if ingredients.count > 1 {
                Button {
                    ingredients.removeAll { $0.id == ingredient.wrappedValue.id }
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: screenHeight * 0.02))
                        .foregroundColor(.red.opacity(0.8))
                }
                .buttonStyle(.plain)
            }

            TextField(
                text: ingredient.name,
                prompt: Text("Ingredient").foregroundStyle(Color.white.opacity(0.3))
            ) {}
                .font(.sfProSemibold(screenHeight * 0.016))
                .foregroundColor(.white)
                .tint(Color("textColor_1"))
                .padding(.horizontal, screenHeight * 0.016)
                .padding(.vertical, screenHeight * 0.014)
                .background(Capsule().fill(Color.white.opacity(0.07)))
                .frame(maxWidth: .infinity)

            TextField(
                text: ingredient.quantity,
                prompt: Text("Qt.").foregroundStyle(Color.white.opacity(0.3))
            ) {}
                .font(.sfProSemibold(screenHeight * 0.016))
                .foregroundColor(.white)
                .tint(Color("textColor_1"))
                .multilineTextAlignment(.center)
                .padding(.horizontal, screenHeight * 0.012)
                .padding(.vertical, screenHeight * 0.014)
                .background(Capsule().fill(Color.white.opacity(0.07)))
                .frame(width: screenHeight * 0.1)
        }
        .padding(.bottom, screenHeight * 0.01)
    }

    // MARK: – Preparation Steps

    private var stepsBlock: some View {
        blockContainer(icon: "dishStpsIcon", title: "Preparation Steps") {
            VStack(spacing: screenHeight * 0.012) {
                ForEach(steps.indices, id: \.self) { i in
                    stepRow(index: i)
                }

                Button {
                    steps.append("")
                } label: {
                    HStack(spacing: screenHeight * 0.008) {
                        Image(systemName: "plus.circle")
                            .font(.system(size: screenHeight * 0.018))
                        Text("Add step")
                            .font(.sfProSemibold(screenHeight * 0.016))
                    }
                    .foregroundColor(Color("textColor_1"))
                    .padding(.top, screenHeight * 0.006)
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .buttonStyle(.plain)
            }
        }
    }

    private func stepRow(index: Int) -> some View {
        let isLast = index == steps.count - 1
        return HStack(alignment: .top, spacing: screenHeight * 0.01) {
            if isLast && steps.count > 1 {
                Button {
                    steps.remove(at: index)
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: screenHeight * 0.02))
                        .foregroundColor(.red.opacity(0.8))
                }
                .buttonStyle(.plain)
                .padding(.top, screenHeight * 0.012)
            } else {
                ZStack {
                    Circle()
                        .fill(Color("textColor_1"))
                        .frame(width: screenHeight * 0.026, height: screenHeight * 0.026)
                    Text("\(index + 1)")
                        .font(.sfProSemibold(screenHeight * 0.014))
                        .foregroundColor(.white)
                }
                .padding(.top, screenHeight * 0.012)
            }

            TextField(
                text: Binding(
                    get: { steps[index] },
                    set: { steps[index] = $0 }
                ),
                prompt: Text("Describe step…").foregroundStyle(Color.white.opacity(0.3)),
                axis: .vertical
            ) {}
                .font(.sfProSemibold(screenHeight * 0.016))
                .foregroundColor(.white)
                .tint(Color("textColor_1"))
                .lineLimit(2...5)
                .padding(.horizontal, screenHeight * 0.016)
                .padding(.vertical, screenHeight * 0.014)
                .background(
                    RoundedRectangle(cornerRadius: screenHeight * 0.018)
                        .fill(Color.white.opacity(0.07))
                )
        }
    }

    // MARK: – Description

    private var descriptionBlock: some View {
        blockContainer(icon: nil, title: "Description") {
            TextField(
                text: $descriptionText,
                prompt: Text("Add a short description of the dish…")
                    .foregroundStyle(Color.white.opacity(0.3)),
                axis: .vertical
            ) {}
                .font(.sfProSemibold(screenHeight * 0.016))
                .foregroundColor(.white)
                .tint(Color("textColor_1"))
                .lineLimit(3...8)
                .padding(.horizontal, screenHeight * 0.018)
                .padding(.vertical, screenHeight * 0.015)
                .background(
                    RoundedRectangle(cornerRadius: screenHeight * 0.02)
                        .fill(Color.white.opacity(0.07))
                )
        }
    }

    // MARK: – Save Button

    private var saveButton: some View {
        VStack(spacing: screenHeight * 0.012) {
            // Save
            Button {
                guard isFormValid else { showValidation = true; return }
                let dish = Dish(
                    id: editing?.id ?? UUID(),
                    name: dishName,
                    country: country,
                    price: price,
                    tasteProfiles: Array(tastes),
                    images: selectedImages,
                    ingredients: ingredients.filter { !$0.name.isEmpty },
                    steps: steps.filter { !$0.isEmpty },
                    description: descriptionText
                )
                let isEdit = editing != nil
                dismiss()
                DispatchQueue.main.async {
                    if isEdit {
                        self.store.update(dish)
                        self.appState.popToRootDish = true
                    } else {
                        self.store.add(dish)
                    }
                }
            } label: {
                Text("SAVE")
                    .font(.sfProSemibold(screenHeight * 0.02))
                    .foregroundColor(isFormValid ? .white : Color(white: 0.5))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, screenHeight * 0.018)
                    .background(Capsule().fill(isFormValid ? Color("textColor_1") : Color(white: 0.25)))
            }
            .animation(.easeInOut(duration: 0.25), value: isFormValid)

            // Delete (edit mode only)
            if editing != nil {
                Button { showDeleteAlert = true } label: {
                    Text("DELETE")
                        .font(.sfProSemibold(screenHeight * 0.02))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, screenHeight * 0.018)
                        .background(Capsule().fill(Color.red.opacity(0.75)))
                }
                .buttonStyle(.plain)
            }
        }
    }

    // MARK: – Reusable Helpers

    private func blockContainer<Content: View>(
        icon: String?,
        title: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: screenHeight * 0.018) {
            HStack(spacing: screenHeight * 0.01) {
                if let icon {
                    Image(icon)
                        .resizable()
                        .scaledToFit()
                        .frame(width: screenHeight * 0.028, height: screenHeight * 0.028)
                }
                Text(title)
                    .font(.sfProSemibold(screenHeight * 0.022))
                    .foregroundColor(.white)
            }
            content()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(screenHeight * 0.022)
        .background(
            ZStack {
                TransparentBlurView()
                RoundedRectangle(cornerRadius: screenHeight * 0.025)
                    .stroke(AngularGradient(stops: glassStops, center: .center), lineWidth: 1.5)
            }
            .clipShape(RoundedRectangle(cornerRadius: screenHeight * 0.025))
        )
    }

    private func labeledField(
        _ label: String,
        placeholder: String,
        text: Binding<String>,
        keyboard: UIKeyboardType = .default
    ) -> some View {
        let hasError = showValidation && text.wrappedValue.isEmpty
            && (label == "Dish Name" || label == "Country Of Origin")

        return VStack(alignment: .leading, spacing: screenHeight * 0.006) {
            fieldLabel(label)
            TextField(
                text: text,
                prompt: Text(placeholder).foregroundStyle(Color.white.opacity(0.3))
            ) {}
                .font(.sfProSemibold(screenHeight * 0.017))
                .foregroundColor(.white)
                .tint(Color("textColor_1"))
                .keyboardType(keyboard)
                .padding(.horizontal, screenHeight * 0.022)
                .padding(.vertical, screenHeight * 0.015)
                .background(Capsule().fill(Color.white.opacity(0.07)))
                .overlay(Capsule().stroke(hasError ? Color.red.opacity(0.8) : Color.clear, lineWidth: 1.5))

            if hasError {
                Text("You need to fill in this field")
                    .font(.sfProSemibold(screenHeight * 0.013))
                    .foregroundColor(.red.opacity(0.85))
                    .padding(.horizontal, screenHeight * 0.022)
            }
        }
    }

    private func fieldLabel(_ text: String) -> some View {
        Text(text)
            .font(.sfProSemibold(screenHeight * 0.017))
            .foregroundColor(.white)
    }

    private var glassStops: [Gradient.Stop] {[
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
    ]}

    // MARK: – Load Photos

    private func loadPhotos() {
        Task {
            var loaded: [UIImage] = []
            for item in selectedPhotoItems {
                if let data = try? await item.loadTransferable(type: Data.self),
                   let img  = UIImage(data: data) {
                    loaded.append(img)
                }
            }
            await MainActor.run { selectedImages = loaded }
        }
    }
}

#Preview {
    NavigationStack {
        AddDishView()
    }
    .environment(AppState())
    .environment(DishStore())
}
