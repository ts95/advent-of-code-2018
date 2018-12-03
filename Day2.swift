func checksum(of ids: [String]) -> Int {
    var occurredTwice = 0
    var occurredThrice = 0
    for id in ids {
        var counts = [Character : Int]()
        for c in id {
            counts[c] = (counts[c] ?? 0) + 1
        }
        if counts.contains(where: { $0.value == 2 }) {
            occurredTwice += 1
        }
        if counts.contains(where: { $0.value == 3 }) {
            occurredThrice += 1
        }
    }
    return occurredTwice * occurredThrice
}

func firstIdWithHammingDistanceOfOne(for ids: [String]) -> String? {
    func hammingDistance(between a: String, and b: String) -> [Int] {
        return zip(a.enumerated(), b).compactMap { (x, y) in
            return x.element != y ? x.offset : nil
        }
    }
    for innerId in ids {
        for outerId in ids {
            let indices = hammingDistance(between: innerId, and: outerId)
            if indices.count == 1, let index = indices.first {
                var result = outerId
                result.remove(at: .init(encodedOffset: index))
                return result
            }
        }
    }
    return nil
}

do {
    let url = URL(fileURLWithPath: "input.txt")
    let input = try String(contentsOf: url)
    let ids = input.split(separator: "\n").map(String.init)
    print(checksum(of: ids))
    print(firstIdWithHammingDistanceOfOne(for: ids) ?? "No ID found")
} catch {
    print(error)
}

