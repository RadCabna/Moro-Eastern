import SwiftUI

struct DishDetailView: View {
    let dish: Dish

    @Environment(\.dismiss)    private var dismiss
    @Environment(AppState.self) private var appState

    @State private var scrolledPhotoID: Int? = 0
    @State private var showEdit = false
    private var photoIndex: Int { scrolledPhotoID ?? 0 }

    var body: some View {
        ZStack {
            Image("background").resizable().ignoresSafeArea()

            VStack(spacing: 0) {
                heroSection

                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: screenHeight * 0.022) {
                        if !dish.description.isEmpty { descriptionSection }
                        if !dish.ingredients.filter({ !$0.name.isEmpty }).isEmpty { ingredientsSection }
                        if !dish.steps.filter({ !$0.isEmpty }).isEmpty { stepsSection }
                    }
                    .padding(.horizontal, screenHeight * 0.022)
                    .padding(.top, screenHeight * 0.028)
                    .padding(.bottom, screenHeight * 0.16)
                }
            }
            .ignoresSafeArea(edges: .top)

            overlayControls
        }
        .navigationBarHidden(true)
        .navigationDestination(isPresented: $showEdit) {
            AddDishView(editing: dish)
        }
        .onAppear   { appState.hideBar() }
        .onDisappear { appState.showBar() }
    }

    // MARK: – Hero

    private var heroSection: some View {
        ZStack(alignment: .bottom) {
            // Photo carousel
            if dish.images.isEmpty {
                ZStack {
                    Color.white.opacity(0.06)
                    Image(systemName: "fork.knife")
                        .font(.system(size: screenHeight * 0.06))
                        .foregroundColor(.white.opacity(0.3))
                }
                .frame(width: screenWidth, height: screenHeight * 0.48)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 0) {
                        ForEach(dish.images.indices, id: \.self) { i in
                            Image(uiImage: dish.images[i])
                                .resizable()
                                .scaledToFill()
                                .frame(width: screenWidth, height: screenHeight * 0.48)
                                .clipped()
                                .id(i)
                        }
                    }
                    .scrollTargetLayout()
                }
                .scrollTargetBehavior(.paging)
                .scrollPosition(id: $scrolledPhotoID)
                .frame(width: screenWidth, height: screenHeight * 0.48)
                .scrollDisabled(dish.images.count < 2)
            }

            // Gradient
            LinearGradient(
                stops: [
                    .init(color: .clear, location: 0),
                    .init(color: Color(red: 0.04, green: 0.06, blue: 0.14).opacity(0.6), location: 0.4),
                    .init(color: Color(red: 0.04, green: 0.06, blue: 0.14), location: 1),
                ],
                startPoint: .top, endPoint: .bottom
            )
            .frame(height: screenHeight * 0.28)
            .allowsHitTesting(false)

            // Name / price / country / badges / dots
            VStack(alignment: .leading, spacing: 0) {
                // Name + Price
                HStack(alignment: .firstTextBaseline) {
                    Text(dish.name)
                        .font(.sfProSemibold(screenHeight * 0.042))
                        .foregroundColor(.white)
                        .lineLimit(2)
                    Spacer()
                    if !dish.price.isEmpty {
                        Text("$\(dish.price)")
                            .font(.sfProSemibold(screenHeight * 0.026))
                            .foregroundColor(.white.opacity(0.85))
                    }
                }
                .padding(.horizontal, screenHeight * 0.022)

                // Country + taste badges row
                HStack(alignment: .center) {
                    HStack(spacing: screenHeight * 0.006) {
                        Image("geoIcon")
                            .resizable()
                            .scaledToFit()
                            .frame(width: screenHeight * 0.02, height: screenHeight * 0.02)
                        Text(dish.country.uppercased())
                            .font(.sfProSemibold(screenHeight * 0.016))
                            .foregroundColor(.white.opacity(0.75))
                    }
                    Spacer()
                    // Taste badges horizontal row
                    HStack(spacing: screenHeight * 0.006) {
                        ForEach(dish.tasteProfiles, id: \.self) { taste in
                            tasteBadge(taste)
                        }
                    }
                }
                .padding(.top, screenHeight * 0.006)
                .padding(.horizontal, screenHeight * 0.022)

                // Page indicators
                if dish.images.count > 1 {
                    pageDotsView
                        .padding(.top, screenHeight * 0.014)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.bottom, screenHeight * 0.022)
            .allowsHitTesting(false)
        }
        .frame(height: screenHeight * 0.48)
        .clipped()
    }

    private func tasteBadge(_ taste: TasteProfile) -> some View {
        HStack(spacing: screenHeight * 0.005) {
            Image(taste.iconName)
                .resizable()
                .scaledToFit()
                .frame(width: screenHeight * 0.017, height: screenHeight * 0.017)
            Text(taste.rawValue.uppercased())
                .font(.sfProSemibold(screenHeight * 0.012))
                .foregroundColor(.white)
        }
        .padding(.horizontal, screenHeight * 0.01)
        .padding(.vertical, screenHeight * 0.006)
        .background(
            RoundedRectangle(cornerRadius: screenHeight * 0.016)
                .fill(Color.black.opacity(0.65))
                .overlay(
                    RoundedRectangle(cornerRadius: screenHeight * 0.016)
                        .stroke(taste.badgeColor, lineWidth: 1.5)
                )
        )
    }

    // MARK: – Page Dots

    private var pageDotsView: some View {
        let count     = dish.images.count
        let hMargin   = screenHeight * 0.022
        let gap       = screenHeight * 0.01
        let indWidth  = (screenWidth - hMargin * 2 - gap * CGFloat(count - 1)) / CGFloat(count)
        let indHeight = screenHeight * 0.006

        return HStack(spacing: gap) {
            ForEach(dish.images.indices, id: \.self) { i in
                RoundedRectangle(cornerRadius: indHeight / 2)
                    .fill(i == photoIndex ? Color.white : Color.white.opacity(0.35))
                    .frame(width: indWidth, height: indHeight)
                    .animation(.easeInOut(duration: 0.25), value: photoIndex)
            }
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: – Overlay Controls

    private var editButton: some View {
        Button { showEdit = true } label: {
            Image("editButton")
                .resizable()
                .scaledToFit()
                .frame(width: screenHeight * 0.052, height: screenHeight * 0.052)
        }
        .buttonStyle(.plain)
    }

    private var overlayControls: some View {
        VStack {
            HStack {
                glassCircleButton(icon: "chevron.left") { dismiss() }
                Spacer()
                editButton
            }
            .padding(.horizontal, screenHeight * 0.022)
            .padding(.top, screenHeight * 0.014)
            Spacer()
        }
    }

    private func glassCircleButton(icon: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
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
                Image(systemName: icon)
                    .font(.system(size: screenHeight * 0.018, weight: .semibold))
                    .foregroundColor(.white)
            }
        }
        .buttonStyle(.plain)
    }

    // MARK: – Description

    private var descriptionSection: some View {
        sectionBlock {
            VStack(alignment: .leading, spacing: screenHeight * 0.012) {
                sectionTitle("Description")
                Text("\"\(dish.description)\"")
                    .font(.sfProSemibold(screenHeight * 0.016))
                    .foregroundColor(.white.opacity(0.75))
                    .lineSpacing(4)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    // MARK: – Ingredients

    private var ingredientsSection: some View {
        let filtered = dish.ingredients.filter { !$0.name.isEmpty }

        return sectionBlock {
            VStack(spacing: 0) {
                // Header on white rounded rect
                HStack {
                    HStack(spacing: screenHeight * 0.008) {
                        Image("dishIngridientIcon")
                            .resizable()
                            .scaledToFit()
                            .frame(width: screenHeight * 0.022, height: screenHeight * 0.022)
                        Text("INGREDIENTS")
                            .font(.sfProSemibold(screenHeight * 0.016))
                            .foregroundColor(Color("textColor_1"))
                    }
                    Spacer()
                    Text("QT.")
                        .font(.sfProSemibold(screenHeight * 0.016))
                        .foregroundColor(Color("textColor_1"))
                }
                .padding(.horizontal, screenHeight * 0.022)
                .padding(.vertical, screenHeight * 0.015)
                .background(
                    RoundedRectangle(cornerRadius: screenHeight * 0.04)
                        .fill(Color.white)
                )

                ForEach(filtered) { ingredient in
                    VStack(spacing: 0) {
                        Divider()
                            .background(Color.white.opacity(0.1))
                            .padding(.horizontal, screenHeight * 0.014)
                        HStack {
                            Text(ingredient.name)
                                .font(.sfProSemibold(screenHeight * 0.017))
                                .foregroundColor(.white)
                            Spacer()
                            Text(ingredient.quantity)
                                .font(.sfProSemibold(screenHeight * 0.017))
                                .foregroundColor(.white.opacity(0.65))
                        }
                        .padding(.horizontal, screenHeight * 0.022)
                        .padding(.vertical, screenHeight * 0.016)
                    }
                }
                Spacer(minLength: screenHeight * 0.008)
            }
        }
    }

    // MARK: – Steps

    private var stepsSection: some View {
        let filtered = dish.steps.filter { !$0.isEmpty }

        return sectionBlock {
            VStack(alignment: .leading, spacing: screenHeight * 0.016) {
                HStack(spacing: screenHeight * 0.01) {
                    Image(systemName: "list.bullet")
                        .font(.system(size: screenHeight * 0.02, weight: .semibold))
                        .foregroundColor(Color("textColor_1"))
                    Text("Recipe Steps")
                        .font(.sfProSemibold(screenHeight * 0.022))
                        .foregroundColor(.white)
                }

                ForEach(filtered.indices, id: \.self) { i in
                    HStack(alignment: .top, spacing: screenHeight * 0.014) {
                        ZStack {
                            Circle()
                                .fill(Color("textColor_1"))
                                .frame(width: screenHeight * 0.028, height: screenHeight * 0.028)
                            Text("\(i + 1)")
                                .font(.sfProSemibold(screenHeight * 0.015))
                                .foregroundColor(.white)
                        }
                        .padding(.top, screenHeight * 0.002)

                        Text(filtered[i])
                            .font(.sfProSemibold(screenHeight * 0.016))
                            .foregroundColor(.white.opacity(0.85))
                            .lineSpacing(3)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
        }
    }

    // MARK: – Helpers

    private func sectionBlock<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        content()
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(screenHeight * 0.022)
            .background(
                ZStack {
                    TransparentBlurView()
                    Color(red: 0.06, green: 0.08, blue: 0.18).opacity(0.6)
                    RoundedRectangle(cornerRadius: screenHeight * 0.022)
                        .stroke(
                            AngularGradient(stops: glassStops, center: .center),
                            lineWidth: 1.5
                        )
                }
                .clipShape(RoundedRectangle(cornerRadius: screenHeight * 0.022))
            )
    }

    private func sectionTitle(_ text: String) -> some View {
        Text(text)
            .font(.sfProSemibold(screenHeight * 0.022))
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
}

#Preview {
    NavigationStack {
        DishDetailView(dish: Dish(
            name: "Tagine",
            country: "Morocco",
            price: "25",
            tasteProfiles: [.spicy, .aromatic],
            ingredients: [
                Ingredient(name: "Lamb Shoulder (Cubed)", quantity: "1 kg"),
                Ingredient(name: "Ras El Hanout",         quantity: "2tb sp"),
                Ingredient(name: "Dried Apricots",        quantity: "150 g"),
            ],
            steps: [
                "Marinate the lamb in Ras El Hanout, olive oil, and crushed garlic for at least 4 hours.",
                "Heat your clay tagine over a low flame. Brown the lamb in small batches.",
                "Add the saffron-infused water, cover and simmer slowly for 1.5 hours until tender.",
            ],
            description: "A savory and spiced Moroccan classic, featuring tender meat with a hint of honey."
        ))
    }
    .environment(AppState())
    .environment(DishStore())
}
