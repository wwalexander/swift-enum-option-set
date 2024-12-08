import Testing
@testable import EnumOptionSet

@OptionSet
struct SundaeToppings {
    enum Option: Int {
        case nuts
        case cherry
        case fudge
    }
}

@Test func example() {
    let _: [SundaeToppings.Option] = [
        .nuts,
        .cherry,
        .fudge,
    ]

    let _: [SundaeToppings] = [
        .nuts,
        .cherry,
        .fudge,
        .init(),
        .init(.nuts),
        .init(.cherry),
        .init(.fudge),
        .init(rawValue: 0),
        .init(rawValue: 1),
        .init(rawValue: 2),
        [],
        [.nuts],
        [.cherry],
        [.fudge],
        [.nuts, .cherry],
        [.nuts, .cherry, .fudge],
    ]
}
