public protocol EnumOptionSet: OptionSet {
    associatedtype Option: RawRepresentable<RawValue>
}

extension EnumOptionSet {
    public init(_ option: Option) {
        self.init(rawValue: option.rawValue)
    }

    public init(_ options: some Sequence<Option>) {
        self = []

        for option in options {
            formUnion(.init(option))
        }
    }
}

extension EnumOptionSet where RawValue: FixedWidthInteger {
    public var count: Int {
        rawValue.nonzeroBitCount
    }
}

extension EnumOptionSet where Option: CaseIterable, RawValue: Equatable {
    public var options: [Option] {
        .init(Option.allCases.filter { option in option.rawValue == self.rawValue })
    }
}

@attached(member, names: arbitrary)
@attached(extension, conformances: EnumOptionSet)
public macro OptionSet() = #externalMacro(
    module: "EnumOptionSetMacros",
    type: "OptionSetMacro")

