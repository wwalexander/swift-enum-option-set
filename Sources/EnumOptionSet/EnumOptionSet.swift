protocol EnumOptionSet: OptionSet {
    associatedtype Option: RawRepresentable<RawValue>
}

extension EnumOptionSet {
    init(_ option: Option) {
        self.init(rawValue: option.rawValue)
    }

    init(_ options: some Sequence<Option>) {
        self = []

        for option in options {
            formUnion(.init(option))
        }
    }
}

extension EnumOptionSet where RawValue: FixedWidthInteger {
    var count: Int {
        rawValue.nonzeroBitCount
    }
}

extension EnumOptionSet where Self: CaseIterable, Option: CaseIterable {
    static var allCases: [Self] {
        Option.allCases.map(Self.init)
    }
}

extension EnumOptionSet where Self: CaseIterable, Option: CaseIterable, RawValue: Equatable {
    var options: [Option] {
        .init(Option.allCases.filter { option in option.rawValue == self.rawValue })
    }
}

@attached(member, names: arbitrary)
@attached(extension, conformances: EnumOptionSet)
public macro OptionSet() = #externalMacro(
    module: "EnumOptionSetMacros",
    type: "OptionSetMacro")

