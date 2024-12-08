import Testing
@testable import EnumOptionSet

@OptionSet<Int>
struct SundaeToppings {
    private enum Option: Int {
        case nuts
        case cherry
        case fudge
    }
}
