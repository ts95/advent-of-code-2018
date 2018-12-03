import Foundation

extension String {
    func matches(for pattern: String, options: NSRegularExpression.Options = []) throws -> [[String]] {
        let regex = try NSRegularExpression(pattern: pattern, options: options)
        let matches = regex.matches(in: self, options: [], range: NSRange(location: 0, length: self.utf16.count))
        let nsString = self as NSString
        return matches.map { match in
            return (0..<match.numberOfRanges).map { index in
                let range = match.range(at: index)
                return range.location != NSNotFound ? nsString.substring(with: range) : ""
            }
        }
    }
}

struct Rect {
    let x: Int
    let y: Int
    let width: Int
    let height: Int

    func enumeratedX() -> Range<Int> {
        return (x..<x+width)
    }

    func enumeratedY() -> Range<Int> {
        return (y..<y+height)
    }
}

typealias ClaimId = Int

struct Claim {
    let id: ClaimId
    let rect: Rect

    init?(line: String) throws {
        let pattern = "#(\\d+) @ (\\d+),(\\d+): (\\d+)x(\\d+)"
        guard let matches = try line.matches(for: pattern).first else { return nil }
        let intValues = matches.dropFirst().compactMap(Int.init)
        guard intValues.count == 5 else { return nil }
        id = intValues[0]
        rect = Rect(x: intValues[1], y: intValues[2],
                    width: intValues[3], height: intValues[4])
    }
}

struct FabricPiece {
    let inches: [[Set<ClaimId>]]
    let claims: [Claim]

    var squareInchesOfFabricInTwoOrMoreClaims: Int {
        return inches.lazy.flatMap { $0 }.filter { $0.count >= 2 }.count
    }

    var firstClaimIdThatDoesNotOverlapWithAnyOtherClaims: ClaimId? {
        for claim in claims {
            var noOverlaps = true
            for x in claim.rect.enumeratedX() {
                guard noOverlaps else { break }
                for y in claim.rect.enumeratedY() {
                    guard inches[y][x] == Set(arrayLiteral: claim.id) else {
                        noOverlaps = false
                        break
                    }
                }
            }
            if noOverlaps { return claim.id }
        }
        return nil
    }

    private init(inches: [[Set<ClaimId>]], claims: [Claim]) {
        self.inches = inches
        self.claims = claims
    }

    init(width: Int, height: Int, claims: [Claim]) {
        let columns = [Set<ClaimId>](repeating: [], count: width)
        var inches = [[Set<ClaimId>]](repeating: columns, count: height)
        for claim in claims {
            for x in claim.rect.enumeratedX() {
                for y in claim.rect.enumeratedY() {
                    inches[y][x].insert(claim.id)
                }
            }
        }
        self.init(inches: inches, claims: claims)
    }
}

do {
    let url = URL(fileURLWithPath: "input.txt")
    let input = try String(contentsOf: url)
    let lines = input.split(separator: "\n").map(String.init)
    let claims = try lines.compactMap(Claim.init)
    let fabricPiece = FabricPiece(width: 1000, height: 1000, claims: claims)
    print(fabricPiece.squareInchesOfFabricInTwoOrMoreClaims)
    print(fabricPiece.firstClaimIdThatDoesNotOverlapWithAnyOtherClaims ?? "No such claim ID exists")
} catch {
    print(error)
}

