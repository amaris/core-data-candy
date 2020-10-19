//
// Copyright © 2018-present Amaris Software.
//

/// Speficy the expected results when fetching: all, first, first nth elements..
public struct FetchTarget<InputValue: DatabaseFieldValue, F: Fetchable, OutputValue: FetchResult> {
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
    static func all<Value: DatabaseFieldValue, F: Fetchable>() -> FetchTarget<Value, F, [F]> {
        return FetchTarget<Value, F, [F]>(type: .all)
    }

    /// Retrieve the first match
    static func first<Value: DatabaseFieldValue, F: Fetchable>() -> FetchTarget<Value, F, F?> {
        return FetchTarget<Value, F, F?>(type: .firstNth(limit: 1))
    }

    /// Retrieve the first nth matches
    static func first<Value: DatabaseFieldValue, F: Fetchable>(nth limit: Int) -> FetchTarget<Value, F, [F]> {
        return FetchTarget<Value, F, [F]>(type: .firstNth(limit: limit))
    }
}
