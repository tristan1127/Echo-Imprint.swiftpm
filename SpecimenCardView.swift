import SwiftUI

struct SpecimenCardView: View {
    let specimen: Specimen

    var body: some View {
        HStack(spacing: 14) {
            SoundOrganismView(
                amplitude: specimen.amplitude,
                frequency: specimen.frequency,
                rhythm: specimen.rhythm,
                size: 80,
                isFrozen: true,
                frozenGrowth: specimen.growth
            )
            .allowsHitTesting(false)

            VStack(alignment: .leading, spacing: 6) {
                Text(specimen.timeLabel)
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(Color(.systemGray))

                Text("Sound Memory")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(Color(.label))
            }

            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, minHeight: 100, maxHeight: 100)
        .padding(.horizontal, 14)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .shadow(color: Color.black.opacity(0.06), radius: 10, x: 0, y: 4)
    }
}

