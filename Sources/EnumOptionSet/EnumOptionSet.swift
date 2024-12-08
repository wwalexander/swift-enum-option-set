@attached(member, names: arbitrary)
@attached(extension, conformances: OptionSet)
public macro OptionSet(enumName: String = "Options") = #externalMacro(module: "EnumOptionSetMacros", type: "OptionSetMacro")
