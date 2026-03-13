import SwiftUI

struct DropdownPickerView: View {
    let title: String
    let iconSystemName: String
    let options: [String]
    @Binding var selection: String
    var showError: Bool = false
    @State private var isExpanded = false

    var body: some View {
        VStack(alignment: .leading, spacing: screenHeight * 0.012) {
            rowLabel
            dropdownButton

            if isExpanded {
                optionsList
            }

            if showError {
                errorLabel
            }
        }
    }

    private var rowLabel: some View {
        HStack(spacing: screenHeight * 0.01) {
            Image(systemName: iconSystemName)
                .foregroundColor(Color("textColor_1"))
                .font(.system(size: screenHeight * 0.02))
            Text(title)
                .font(.sfProSemibold(screenHeight * 0.02))
                .foregroundColor(.white)
        }
    }

    private var dropdownButton: some View {
        Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                isExpanded.toggle()
            }
        } label: {
            HStack {
                Text(selection.isEmpty ? "Choose" : selection)
                    .font(.sfProSemibold(screenHeight * 0.018))
                    .foregroundColor(selection.isEmpty ? .white.opacity(0.35) : .white)
                Spacer()
                Image(systemName: "chevron.down")
                    .font(.system(size: screenHeight * 0.016, weight: .semibold))
                    .foregroundColor(.white.opacity(0.6))
                    .rotationEffect(isExpanded ? .degrees(180) : .zero)
                    .animation(.spring(response: 0.3, dampingFraction: 0.8), value: isExpanded)
            }
            .padding(.horizontal, screenHeight * 0.022)
            .padding(.vertical, screenHeight * 0.016)
            .background(Capsule().fill(Color.white.opacity(0.07)))
            .overlay(
                Capsule()
                    .stroke(showError ? Color.red.opacity(0.8) : Color.clear, lineWidth: 1.5)
            )
        }
        .buttonStyle(.plain)
    }

    private var optionsList: some View {
        VStack(spacing: 0) {
            ForEach(options, id: \.self) { option in
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        selection = option
                        isExpanded = false
                    }
                } label: {
                    HStack {
                        Text(option)
                            .font(.sfProSemibold(screenHeight * 0.018))
                            .foregroundColor(.white)
                        Spacer()
                        if selection == option {
                            Image(systemName: "checkmark")
                                .font(.system(size: screenHeight * 0.016, weight: .semibold))
                                .foregroundColor(Color("textColor_1"))
                        }
                    }
                    .padding(.horizontal, screenHeight * 0.018)
                    .padding(.vertical, screenHeight * 0.015)
                }
                .buttonStyle(.plain)

                if option != options.last {
                    Divider().background(Color.white.opacity(0.1))
                }
            }
        }
        .background(
            RoundedRectangle(cornerRadius: screenHeight * 0.025)
                .fill(Color.white.opacity(0.05))
        )
    }

    private var errorLabel: some View {
        Text("You need to fill in this field")
            .font(.sfProSemibold(screenHeight * 0.014))
            .foregroundColor(.red.opacity(0.85))
            .padding(.horizontal, screenHeight * 0.022)
    }
}
