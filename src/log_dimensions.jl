abstract type LogUnit end

struct MagUnit <: LogUnit
    zero_point::Quantity
    name::Symbol
end

Base.show(io::IO, unit::MagUnit) = print(io, unit.name)

# This immediately converts to regular Dimensions
Base.:*(value::Number, unit::MagUnit) = unit.zero_point / exp10(value / 2.5)

# Conversions
uconvert(qout::MagUnit, q::Quantity) = -2.5 * log10(q / qout.zero_point) * qout
Base.:(|>)(q, qout::MagUnit) = uconvert(qout, q)

module LogUnits
    import ..MagUnit
    import ..UnitsParse: @u_str

    const V_mag = MagUnit(
        3640.0u"Jy",
        Symbol("Johnson V mag"),
    )

    const B_mag = MagUnit(
        4260.0u"Jy",
        Symbol("Johnson B mag"),
    )

    function map_to_scope(sym::Symbol)
        if sym == Symbol("V_mag")
            return V_mag
        else
            return B_mag
        end
    end
end

macro ul_str(s)
    ex = LogUnits.map_to_scope(Meta.parse(s))
    return esc(ex)
end
