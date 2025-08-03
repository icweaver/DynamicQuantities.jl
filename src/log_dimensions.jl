using TestItems: @testitem, @testmodule

abstract type LogUnit{T} end

struct MagUnit{T<:Real} <: LogUnit{T}
    value::T
    zero_point::Quantity{Float64, Dimensions{DEFAULT_DIM_BASE_TYPE}}
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
uconvert(qout::UnionAbstractQuantity{<:Any, <:SymbolicDimensions}, m::MagUnit) = uconvert(qout, uexpand(m))
uconvert(mout::MagUnit, m::MagUnit) = uconvert(mout, uexpand(m))

# Convenience
Base.:(|>)(m, mout::MagUnit) = uconvert(mout, m)
Base.:(|>)(m::UnionAbstractQuantity{<:Any, <:SymbolicDimensions}, mout::MagUnit) = uconvert(mout, m)
Base.:(|>)(m::MagUnit, mout::UnionAbstractQuantity{<:Any, <:SymbolicDimensions}) = uconvert(mout, m)
Base.:(|>)(m::MagUnit, mout::MagUnit) = uconvert(mout, m)

# Some basic patches
Base.one(unit::LogUnit) = one(m.value)
Base.oneunit(m::MagUnit) = MagUnit(one(m.value), m.zero_point, m.name)
ustrip(unit::LogUnit) = unit.value

Base.isapprox(m1::MagUnit, m2::MagUnit; atol=(zero ∘ ustrip)(m1.value), kwargs...) = isapprox(ustrip(m1), ustrip(m2); atol, kwargs...)
Base.isapprox(m1::MagUnit, q2::UnionAbstractQuantity; atol=zero(q2), kwargs...) = isapprox(uexpand(m1), uexpand(q2); atol=uexpand(atol), kwargs...)
Base.isapprox(q1::UnionAbstractQuantity, m2::MagUnit; kwargs...) = isapprox(m2, q1; kwargs...)

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
@testmodule DQ begin
    using DynamicQuantities

    const u = DynamicQuantities.Units
    const ul = DynamicQuantities.LogUnits
end

@testitem "Zero-point" setup=[DQ] begin

    @test isapprox(1DQ.ul.V_mag, 3640DQ.u.Jy; atol=0.001DQ.ul.V_mag)
end

@testitem "Algebraic operations" begin
end
