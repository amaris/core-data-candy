//
// Copyright © 2018-present Amaris Software.
//

/// Speficy the expected results when fetching: all, first, first nth elements..
public struct FetchTarget<F: Fetchable, OutputValue: FetchResult> {
    let type: TargetType

    var limit: Int? {
        if case let .firstNth(limit) = type {
            return limit
        } else {
            return nil
        }
    }
}

public extension FetchTarget {
    enum TargetType {
        case all, firstNth(limit: Int)
    }
}

public extension FetchTarget {

    /// Retrieve all the matches
    static func all<F: Fetchable>() -> FetchTarget<F, [F]> {
        return FetchTarget<F, [F]>(type: .all)
    }

    /// Retrieve the first match
    static func first<F: Fetchable>() -> FetchTarget<F, F?> {
        return FetchTarget<F, F?>(type: .firstNth(limit: 1))
    }

    /// Retrieve the first nth matches
    static func first<F: Fetchable>(nth limit: Int) -> FetchTarget< F, [F]> {
        return FetchTarget<F, [F]>(type: .firstNth(limit: limit))
    }
}
