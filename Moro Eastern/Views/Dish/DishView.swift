import SwiftUI

struct DishView: View {
    @Environment(DishStore.self) private var store
    @Environment(AppState.self)  private var appState
    @State private var showAdd      = false
    @State private var selectedDish: Dish? = nil

    @State private var selectedCountry: String?      = nil
    @State private var selectedTaste: TasteProfile?  = nil
    @State private var showCountryFilter = false
    @State private var showTypeFilter    = false

    // Unique countries from saved dishes, sorted alphabetically
    private var availableCountries: [String] {
        Array(Set(store.dishes.map { $0.country }.filter { !$0.isEmpty })).sorted()
    }

    // Filtered dishes based on active filters, newest first
    private var filteredDishes: [Dish] {
        store.dishes
            .filter { dish in
                let countryOK = selectedCountry == nil || dish.country == selectedCountry
                let tasteOK   = selectedTaste   == nil || dish.tasteProfiles.contains(selectedTaste!)
                return countryOK && tasteOK
            }
            .sorted { $0.createdAt > $1.createdAt }
    }

    var body: some View {
        VStack(spacing: 0) {
            header
            filterRow
                .zIndex(1)
            if store.dishes.isEmpty {
                emptyState
            } else {
                dishList
            }
        }
        .navigationDestination(isPresented: $showAdd) {
            AddDishView()
        }
        .navigationDestination(item: $selectedDish) { dish in
            DishDetailView(dish: dish)
        }
        .onChange(of: appState.popToRootDish) {
            if appState.popToRootDish {
                selectedDish = nil
                appState.popToRootDish = false
            }
        }
    }

    // MARK: – Header

    private var header: some View {
        ZStack {
            Text("Cuisine Catalog")
                .font(.sfProSemibold(screenHeight * 0.025))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .center)

            HStack {
                Spacer()
                Button { showAdd = true } label: {
                    Image("plusButton")
                        .resizable()
                        .scaledToFit()
                        .frame(width: screenHeight * 0.052, height: screenHeight * 0.052)
                }
                .padding(.trailing, screenHeight * 0.025)
            }
        }
        .padding(.top, screenHeight * 0.02)
        .padding(.bottom, screenHeight * 0.016)
    }

    // MARK: – Filter Row

    private var filterRow: some View {
        HStack(spacing: screenHeight * 0.012) {
            Text("FILTER:")
                .font(.sfProSemibold(screenHeight * 0.016))
                .foregroundColor(.white.opacity(0.55))

            Spacer()

            filterChip(
                title: selectedCountry ?? "COUNTRY",
                isActive: selectedCountry != nil,
                isOpen: showCountryFilter
            ) {
                withAnimation(.easeInOut(duration: 0.2)) {
                    showCountryFilter.toggle()
                    if showCountryFilter { showTypeFilter = false }
                }
            }

            filterChip(
                title: selectedTaste?.rawValue ?? "TASTE",
                isActive: selectedTaste != nil,
                isOpen: showTypeFilter
            ) {
                withAnimation(.easeInOut(duration: 0.2)) {
                    showTypeFilter.toggle()
                    if showTypeFilter { showCountryFilter = false }
                }
            }
        }
        .padding(.horizontal, screenHeight * 0.025)
        .padding(.bottom, screenHeight * 0.012)
        // Country dropdown
        .overlay(alignment: .topTrailing) {
            if showCountryFilter {
                countryDropdown
                    .padding(.trailing, screenHeight * 0.025 + screenHeight * 0.13)
                    .padding(.top, screenHeight * 0.052)
            }
        }
        // Taste dropdown
        .overlay(alignment: .topTrailing) {
            if showTypeFilter {
                tasteDropdown
                    .padding(.trailing, screenHeight * 0.025)
                    .padding(.top, screenHeight * 0.052)
            }
        }
    }

    // Country dropdown — built from actual dish data
    private var countryDropdown: some View {
        let options = availableCountries
        return dropdownShell {
            if options.isEmpty {
                Text("No dishes yet")
                    .font(.sfProSemibold(screenHeight * 0.015))
                    .foregroundColor(.white.opacity(0.45))
                    .padding(screenHeight * 0.018)
            } else {
                ForEach(options, id: \.self) { country in
                    Button {
                        withAnimation(.easeInOut(duration: 0.15)) {
                            selectedCountry = selectedCountry == country ? nil : country
                            showCountryFilter = false
                        }
                    } label: {
                        HStack {
                            Text(country)
                                .font(.sfProSemibold(screenHeight * 0.016))
                                .foregroundColor(selectedCountry == country ? Color("textColor_1") : .white)
                            Spacer()
                            if selectedCountry == country {
                                Image(systemName: "checkmark")
                                    .font(.system(size: screenHeight * 0.014, weight: .semibold))
                                    .foregroundColor(Color("textColor_1"))
                            }
                        }
                        .padding(.horizontal, screenHeight * 0.018)
                        .padding(.vertical, screenHeight * 0.012)
                    }
                    .buttonStyle(.plain)

                    if country != options.last {
                        Divider().background(Color.white.opacity(0.1))
                            .padding(.horizontal, screenHeight * 0.012)
                    }
                }
            }
        }
    }

    // Taste dropdown — all TasteProfile cases with icons
    private var tasteDropdown: some View {
        dropdownShell {
            ForEach(TasteProfile.allCases, id: \.self) { taste in
                Button {
                    withAnimation(.easeInOut(duration: 0.15)) {
                        selectedTaste = selectedTaste == taste ? nil : taste
                        showTypeFilter = false
                    }
                } label: {
                    HStack(spacing: screenHeight * 0.012) {
                        Image(taste.iconName)
                            .resizable().scaledToFit()
                            .frame(width: screenHeight * 0.022, height: screenHeight * 0.022)
                        Text(taste.rawValue)
                            .font(.sfProSemibold(screenHeight * 0.016))
                            .foregroundColor(selectedTaste == taste ? taste.badgeColor : .white)
                        Spacer()
                        if selectedTaste == taste {
                            Image(systemName: "checkmark")
                                .font(.system(size: screenHeight * 0.014, weight: .semibold))
                                .foregroundColor(taste.badgeColor)
                        }
                    }
                    .padding(.horizontal, screenHeight * 0.018)
                    .padding(.vertical, screenHeight * 0.011)
                }
                .buttonStyle(.plain)

                if taste != TasteProfile.allCases.last {
                    Divider().background(Color.white.opacity(0.1))
                        .padding(.horizontal, screenHeight * 0.012)
                }
            }
        }
    }

    // Shared glass shell for both dropdowns
    @ViewBuilder
    private func dropdownShell<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            content()
        }
        .background(
            ZStack {
                TransparentBlurView()
                Color(red: 0.06, green: 0.08, blue: 0.18).opacity(0.85)
                RoundedRectangle(cornerRadius: screenHeight * 0.016)
                    .stroke(
                        AngularGradient(
                            stops: [
                                .init(color: .white.opacity(0.7),  location: 0.00),
                                .init(color: .gray.opacity(0.35),  location: 0.25),
                                .init(color: .black.opacity(0.05), location: 0.50),
                                .init(color: .white.opacity(0.7),  location: 0.75),
                                .init(color: .white.opacity(0.7),  location: 1.00),
                            ],
                            center: .center
                        ),
                        lineWidth: 1.5
                    )
            }
            .clipShape(RoundedRectangle(cornerRadius: screenHeight * 0.016))
        )
        .frame(width: screenHeight * 0.22)
        .zIndex(10)
        .transition(.opacity.combined(with: .scale(scale: 0.95, anchor: .topTrailing)))
    }

    private func filterChip(title: String, isActive: Bool, isOpen: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: screenHeight * 0.006) {
                Text(title)
                    .font(.sfProSemibold(screenHeight * 0.016))
                    .foregroundColor(isActive ? Color("textColor_1") : .white)
                    .lineLimit(1)
                Image(systemName: isOpen ? "chevron.up" : "chevron.down")
                    .font(.system(size: screenHeight * 0.013, weight: .semibold))
                    .foregroundColor(isActive ? Color("textColor_1") : .white.opacity(0.7))
            }
            .padding(.horizontal, screenHeight * 0.018)
            .padding(.vertical, screenHeight * 0.011)
            .background(
                Capsule()
                    .fill(Color("textColor_1").opacity(isActive ? 0.2 : 0.15))
                    .overlay(
                        Capsule()
                            .stroke(
                                isActive ? Color("textColor_1").opacity(0.6) : Color.white.opacity(0.15),
                                lineWidth: 1
                            )
                    )
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: – Dish List

    private var dishList: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: screenHeight * 0.018) {
                if filteredDishes.isEmpty {
                    // No results for active filter
                    VStack(spacing: screenHeight * 0.01) {
                        Text("No matches")
                            .font(.sfProSemibold(screenHeight * 0.026))
                            .foregroundColor(.white)
                        Text("Try a different filter")
                            .font(.sfProSemibold(screenHeight * 0.019))
                            .foregroundColor(.white.opacity(0.45))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, screenHeight * 0.12)
                } else {
                    ForEach(filteredDishes) { dish in
                        DishCardView(dish: dish) {
                            selectedDish = dish
                        }
                    }
                }
            }
            .padding(.horizontal, screenHeight * 0.022)
            .padding(.top, screenHeight * 0.01)
            .padding(.bottom, screenHeight * 0.16)
        }
    }

    // MARK: – Empty State

    private var emptyState: some View {
        VStack(spacing: screenHeight * 0.01) {
            Text("No Dish Yet")
                .font(.sfProSemibold(screenHeight * 0.03))
                .foregroundColor(.white)

            Text("Start your first dish")
                .font(.sfProSemibold(screenHeight * 0.022))
                .foregroundColor(.white.opacity(0.45))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    ZStack {
        Image("background").resizable().ignoresSafeArea()
        DishView()
    }
    .environment(DishStore())
}
