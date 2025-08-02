using TestItems: @testitem

abstract type LogUnit end

struct MagUnit <: LogUnit
    value::Float64
    zero_point::Quantity
    name::Symbol
end

Base.show(io::IO, unit::MagUnit) = print(io, unit.value, " ", unit.name)

# Conversions
"""
    uexpand(m::MagUnit)

Expand  the logarithmic units in a quantity with symbolic dimensions to their base SI form.
"""
uexpand(m::MagUnit) = (m.zero_point / exp10(m.value / 2.5))

function uconvert(mout::MagUnit, x)
    @assert mout.value == 1.0 "You tried converting to $(mout), a `MagUnit` with a non-unit value."
    return -2.5 * log10(uexpand(x) / mout.zero_point) * mout
end
uconvert(qout::UnionAbstractQuantity{<:Any, <:Dimensions}, m::MagUnit) = uconvert(qout, uexpand(m))
uconvert(mout::MagUnit, m::MagUnit) = uconvert(mout, uexpand(m))

# Convenience
Base.:(|>)(m, mout::MagUnit) = uconvert(mout, m)
Base.:(|>)(m::MagUnit, mout) = uconvert(mout, m)
Base.:(|>)(m::MagUnit, mout::MagUnit) = uconvert(mout, m)

# Basic patches
Base.one(m::MagUnit) = one(m.value)
Base.oneunit(m::MagUnit) = MagUnit(one(m.value), m.zero_point, m.name)

Base.:*(value::Number, m::MagUnit) = MagUnit(value, m.zero_point, m.name)

function Base.:-(m2::MagUnit, m1::MagUnit)
    if m2.name == m1.name
        return (uexpand(m2) - uexpand(m1)) |> oneunit(m2)
    else
        return m2.value - m1.value
    end
end

# Define astronomical magnitude units
module LogUnits
    import ..MagUnit
    import ..UnitsParse: @u_str

    const V_mag = MagUnit(
        1.0,
        3640.0u"Jy",
        Symbol("Johnson V mag"),
    )

    const B_mag = MagUnit(
        1.0,
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

# Tests
@testitem "Zero point" begin
    using DynamicQuantities

    @test isapprox(2u"cm", 2u"cm")
end
