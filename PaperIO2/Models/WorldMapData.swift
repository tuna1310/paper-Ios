import CoreGraphics
import Foundation

/// Continent groupings for World Conquest progression.
enum ContinentRegion: String, CaseIterable, Codable, Identifiable {
    case northAmerica = "NORTH AMERICA"
    case southAmerica = "SOUTH AMERICA"
    case europe = "EUROPE"
    case africa = "AFRICA"
    case asia = "ASIA"
    case oceania = "OCEANIA"

    var id: String { rawValue }

    var displayName: String { rawValue }
}

/// Country / territory node displayed on the interactive World Map.
struct WorldCountry: Identifiable, Hashable {
    let id: String
    let name: String
    let flagEmoji: String
    let continent: ContinentRegion
    /// Normalized map points in [0...1] x [0...1] equirectangular-style projection.
    let polygons: [[CGPoint]]
    /// Label & hero bubble anchor in normalized [0...1] x [0...1] space.
    let anchor: CGPoint

    static func == (lhs: WorldCountry, rhs: WorldCountry) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

/// Vector silhouettes for countries & background landmasses across all continents.
enum WorldMapCatalog {
    static let allCountries: [WorldCountry] = [
        // MARK: North & Central America
        WorldCountry(
            id: "canada",
            name: "Canada",
            flagEmoji: "🇨🇦",
            continent: .northAmerica,
            polygons: [
                [p(0.10, 0.14), p(0.24, 0.10), p(0.32, 0.18), p(0.35, 0.25), p(0.29, 0.30), p(0.18, 0.31), p(0.12, 0.24)],
                // Arctic islands like the video intro
                [p(0.24, 0.06), p(0.30, 0.05), p(0.31, 0.11), p(0.25, 0.12)],
                [p(0.31, 0.09), p(0.36, 0.08), p(0.38, 0.16), p(0.33, 0.17)]
            ],
            anchor: p(0.23, 0.22)
        ),
        WorldCountry(
            id: "greenland",
            name: "Greenland",
            flagEmoji: "🇬🇱",
            continent: .northAmerica,
            polygons: [
                [p(0.37, 0.05), p(0.47, 0.04), p(0.49, 0.14), p(0.42, 0.23), p(0.38, 0.17)]
            ],
            anchor: p(0.43, 0.13)
        ),
        WorldCountry(
            id: "usa",
            name: "United States",
            flagEmoji: "🇺🇸",
            continent: .northAmerica,
            polygons: [
                [p(0.14, 0.31), p(0.31, 0.30), p(0.34, 0.36), p(0.29, 0.43), p(0.20, 0.43), p(0.14, 0.38)],
                // Alaska
                [p(0.05, 0.16), p(0.11, 0.14), p(0.12, 0.21), p(0.06, 0.22)]
            ],
            anchor: p(0.24, 0.37)
        ),
        WorldCountry(
            id: "mexico",
            name: "Mexico",
            flagEmoji: "🇲🇽",
            continent: .northAmerica,
            polygons: [
                [p(0.16, 0.43), p(0.24, 0.43), p(0.26, 0.50), p(0.23, 0.52), p(0.18, 0.48)]
            ],
            anchor: p(0.21, 0.47)
        ),
        WorldCountry(
            id: "guatemala",
            name: "Guatemala",
            flagEmoji: "🇬🇹",
            continent: .northAmerica,
            polygons: [
                [p(0.23, 0.51), p(0.26, 0.51), p(0.26, 0.54), p(0.23, 0.54)]
            ],
            anchor: p(0.245, 0.525)
        ),
        WorldCountry(
            id: "cuba",
            name: "Cuba",
            flagEmoji: "🇨🇺",
            continent: .northAmerica,
            polygons: [
                [p(0.27, 0.46), p(0.32, 0.47), p(0.32, 0.49), p(0.27, 0.48)]
            ],
            anchor: p(0.295, 0.475)
        ),
        WorldCountry(
            id: "panama",
            name: "Panama",
            flagEmoji: "🇵🇦",
            continent: .southAmerica,
            polygons: [
                [p(0.255, 0.545), p(0.295, 0.55), p(0.295, 0.575), p(0.26, 0.57)]
            ],
            anchor: p(0.278, 0.56)
        ),

        // MARK: South America (8 countries matching "SOUTH AMERICA 3/8")
        WorldCountry(
            id: "colombia",
            name: "Colombia",
            flagEmoji: "🇨🇴",
            continent: .southAmerica,
            polygons: [
                [p(0.285, 0.57), p(0.33, 0.56), p(0.34, 0.63), p(0.29, 0.63)]
            ],
            anchor: p(0.31, 0.60)
        ),
        WorldCountry(
            id: "venezuela",
            name: "Venezuela",
            flagEmoji: "🇻🇪",
            continent: .southAmerica,
            polygons: [
                [p(0.325, 0.555), p(0.37, 0.565), p(0.365, 0.615), p(0.33, 0.61)]
            ],
            anchor: p(0.348, 0.585)
        ),
        WorldCountry(
            id: "peru",
            name: "Peru",
            flagEmoji: "🇵🇪",
            continent: .southAmerica,
            polygons: [
                [p(0.28, 0.63), p(0.32, 0.64), p(0.325, 0.72), p(0.285, 0.70)]
            ],
            anchor: p(0.30, 0.675)
        ),
        WorldCountry(
            id: "brazil",
            name: "Brazil",
            flagEmoji: "🇧🇷",
            continent: .southAmerica,
            polygons: [
                [p(0.32, 0.61), p(0.42, 0.63), p(0.44, 0.72), p(0.37, 0.78), p(0.325, 0.71)]
            ],
            anchor: p(0.375, 0.69)
        ),
        WorldCountry(
            id: "bolivia",
            name: "Bolivia",
            flagEmoji: "🇧🇴",
            continent: .southAmerica,
            polygons: [
                [p(0.315, 0.71), p(0.355, 0.715), p(0.35, 0.77), p(0.315, 0.76)]
            ],
            anchor: p(0.335, 0.74)
        ),
        WorldCountry(
            id: "chile",
            name: "Chile",
            flagEmoji: "🇨🇱",
            continent: .southAmerica,
            polygons: [
                [p(0.295, 0.75), p(0.315, 0.76), p(0.315, 0.90), p(0.295, 0.89)]
            ],
            anchor: p(0.305, 0.82)
        ),
        WorldCountry(
            id: "argentina",
            name: "Argentina",
            flagEmoji: "🇦🇷",
            continent: .southAmerica,
            polygons: [
                [p(0.315, 0.77), p(0.365, 0.78), p(0.35, 0.91), p(0.315, 0.89)]
            ],
            anchor: p(0.34, 0.84)
        ),

        // MARK: Europe
        WorldCountry(
            id: "uk",
            name: "United Kingdom",
            flagEmoji: "🇬🇧",
            continent: .europe,
            polygons: [
                [p(0.47, 0.24), p(0.50, 0.23), p(0.505, 0.30), p(0.47, 0.30)]
            ],
            anchor: p(0.488, 0.27)
        ),
        WorldCountry(
            id: "france",
            name: "France",
            flagEmoji: "🇫🇷",
            continent: .europe,
            polygons: [
                [p(0.48, 0.31), p(0.53, 0.30), p(0.535, 0.36), p(0.485, 0.36)]
            ],
            anchor: p(0.51, 0.335)
        ),
        WorldCountry(
            id: "spain",
            name: "Spain",
            flagEmoji: "🇪🇸",
            continent: .europe,
            polygons: [
                [p(0.46, 0.36), p(0.51, 0.36), p(0.505, 0.41), p(0.46, 0.405)]
            ],
            anchor: p(0.482, 0.385)
        ),
        WorldCountry(
            id: "germany",
            name: "Germany",
            flagEmoji: "🇩🇪",
            continent: .europe,
            polygons: [
                [p(0.53, 0.27), p(0.57, 0.27), p(0.57, 0.34), p(0.53, 0.34)]
            ],
            anchor: p(0.55, 0.305)
        ),
        WorldCountry(
            id: "italy",
            name: "Italy",
            flagEmoji: "🇮🇹",
            continent: .europe,
            polygons: [
                [p(0.53, 0.35), p(0.565, 0.35), p(0.58, 0.42), p(0.55, 0.42)]
            ],
            anchor: p(0.555, 0.385)
        ),
        WorldCountry(
            id: "nordics",
            name: "Scandinavia",
            flagEmoji: "🇸🇪",
            continent: .europe,
            polygons: [
                [p(0.53, 0.14), p(0.60, 0.13), p(0.59, 0.25), p(0.525, 0.24)]
            ],
            anchor: p(0.56, 0.19)
        ),

        // MARK: Africa
        WorldCountry(
            id: "morocco",
            name: "Morocco",
            flagEmoji: "🇲🇦",
            continent: .africa,
            polygons: [
                [p(0.45, 0.43), p(0.51, 0.43), p(0.51, 0.50), p(0.44, 0.50)]
            ],
            anchor: p(0.478, 0.465)
        ),
        WorldCountry(
            id: "egypt",
            name: "Egypt",
            flagEmoji: "🇪🇬",
            continent: .africa,
            polygons: [
                [p(0.54, 0.43), p(0.60, 0.43), p(0.60, 0.51), p(0.54, 0.51)]
            ],
            anchor: p(0.57, 0.47)
        ),
        WorldCountry(
            id: "nigeria",
            name: "Nigeria",
            flagEmoji: "🇳🇬",
            continent: .africa,
            polygons: [
                [p(0.48, 0.51), p(0.55, 0.51), p(0.55, 0.59), p(0.46, 0.58)]
            ],
            anchor: p(0.51, 0.55)
        ),
        WorldCountry(
            id: "kenya",
            name: "Kenya",
            flagEmoji: "🇰🇪",
            continent: .africa,
            polygons: [
                [p(0.56, 0.54), p(0.62, 0.54), p(0.61, 0.65), p(0.55, 0.64)]
            ],
            anchor: p(0.585, 0.59)
        ),
        WorldCountry(
            id: "south_africa",
            name: "South Africa",
            flagEmoji: "🇿🇦",
            continent: .africa,
            polygons: [
                [p(0.52, 0.68), p(0.59, 0.67), p(0.58, 0.79), p(0.53, 0.78)]
            ],
            anchor: p(0.555, 0.73)
        ),

        // MARK: Asia
        WorldCountry(
            id: "russia",
            name: "Russia",
            flagEmoji: "🇷🇺",
            continent: .asia,
            polygons: [
                [p(0.60, 0.13), p(0.89, 0.12), p(0.92, 0.24), p(0.75, 0.29), p(0.60, 0.27)]
            ],
            anchor: p(0.75, 0.20)
        ),
        WorldCountry(
            id: "india",
            name: "India",
            flagEmoji: "🇮🇳",
            continent: .asia,
            polygons: [
                [p(0.67, 0.39), p(0.74, 0.40), p(0.72, 0.54), p(0.68, 0.51)]
            ],
            anchor: p(0.705, 0.455)
        ),
        WorldCountry(
            id: "china",
            name: "China",
            flagEmoji: "🇨🇳",
            continent: .asia,
            polygons: [
                [p(0.71, 0.29), p(0.84, 0.28), p(0.85, 0.41), p(0.73, 0.41)]
            ],
            anchor: p(0.78, 0.35)
        ),
        WorldCountry(
            id: "vietnam",
            name: "Vietnam",
            flagEmoji: "🇻🇳",
            continent: .asia,
            polygons: [
                [p(0.77, 0.43), p(0.81, 0.44), p(0.81, 0.55), p(0.78, 0.54)]
            ],
            anchor: p(0.792, 0.49)
        ),
        WorldCountry(
            id: "korea",
            name: "South Korea",
            flagEmoji: "🇰🇷",
            continent: .asia,
            polygons: [
                [p(0.85, 0.34), p(0.88, 0.34), p(0.88, 0.39), p(0.85, 0.39)]
            ],
            anchor: p(0.865, 0.365)
        ),
        WorldCountry(
            id: "japan",
            name: "Japan",
            flagEmoji: "🇯🇵",
            continent: .asia,
            polygons: [
                [p(0.89, 0.31), p(0.93, 0.30), p(0.92, 0.40), p(0.88, 0.40)]
            ],
            anchor: p(0.905, 0.355)
        ),

        // MARK: Oceania
        WorldCountry(
            id: "australia",
            name: "Australia",
            flagEmoji: "🇦🇺",
            continent: .oceania,
            polygons: [
                [p(0.78, 0.65), p(0.91, 0.64), p(0.92, 0.78), p(0.80, 0.79)]
            ],
            anchor: p(0.85, 0.715)
        ),
        WorldCountry(
            id: "new_zealand",
            name: "New Zealand",
            flagEmoji: "🇳🇿",
            continent: .oceania,
            polygons: [
                [p(0.93, 0.77), p(0.97, 0.76), p(0.96, 0.85), p(0.92, 0.84)]
            ],
            anchor: p(0.945, 0.805)
        )
    ]

    static func country(id: String) -> WorldCountry {
        allCountries.first { $0.id == id } ?? allCountries.first { $0.id == "panama" } ?? allCountries[0]
    }

    private static func p(_ x: CGFloat, _ y: CGFloat) -> CGPoint {
        CGPoint(x: x, y: y)
    }
}
