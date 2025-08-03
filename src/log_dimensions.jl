using TestItems: @testitem, @testmodule, @testsnippet

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

Base.isapprox(m1::MagUnit, m2::MagUnit; atol=zero(m1.value), kwargs...) = isapprox(ustrip(m1), ustrip(m2); atol=ustrip(atol), kwargs...)
Base.isapprox(m1::MagUnit, q2::UnionAbstractQuantity; atol=zero(q2), kwargs...) = isapprox(uexpand(m1), uexpand(q2); atol=uexpand(atol), kwargs...)
Base.isapprox(q1::UnionAbstractQuantity, m2::MagUnit; kwargs...) = isapprox(m2, q1; kwargs...)

Base.:*(value::Number, m::MagUnit) = MagUnit(value, m.zero_point, m.name)
Base.:/(m::MagUnit, value) = (uexpand(m) / value) |> oneunit(m)
function Base.:+(m1::MagUnit, m2::MagUnit)
    if m1.name == m2.name
        return (uexpand(m1) + uexpand(m2)) |> oneunit(m1)
    else
        throw(MethodError(+, (m1, m2)))
    end
end
Base.:+(m1::MagUnit, q2::UnionAbstractQuantity) = uexpand(m1) + q2
Base.:+(q2::UnionAbstractQuantity, m1::MagUnit) = m1 + q2
@unstable function Base.:-(m2::MagUnit, m1::MagUnit)
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

    const AB_mag = MagUnit(
        1.0,
        3631u"Jy",
        Symbol("AB mag"),
    )

    const V_mag = MagUnit(
        1.0,
        3640u"Jy",
        Symbol("Johnson V mag"),
    )

    const B_mag = MagUnit(
        1.0,
        4260u"Jy",
        Symbol("Johnson B mag"),
    )

    function map_to_scope(sym::Symbol)
        # TODO: add remaining filters
        if sym == Symbol("AB_mag")
            return AB_mag
        elseif sym == Symbol("B_mag")
            return B_mag
        elseif sym == Symbol("V_mag")
            return V_mag
        else
            throw(ArgumentError("Symbol $sym not found in `LogUnits`."))
        end
    end
end

macro ul_str(s)
    ex = LogUnits.map_to_scope(Meta.parse(s))
    return esc(ex)
end

# Tests
@testsnippet DQ begin
    using DynamicQuantities

    const u = DynamicQuantities.Units
    const ul = DynamicQuantities.LogUnits
end

@testitem "Conversions" setup=[DQ] begin
    @test isapprox(3631u.Jy, 0*ul.AB_mag, atol=0.001*ul.AB_mag)
    @test isapprox(36.31*u.Jy, 5*ul.AB_mag, atol=0.001*ul.AB_mag)
    @test isapprox(363.1*u.mJy, 10*ul.AB_mag, atol=0.001*ul.AB_mag)
    @test isapprox(3.631*u.mJy, 15*ul.AB_mag, atol=0.001*ul.AB_mag)
    @test isapprox(5*ul.AB_mag + 5*ul.AB_mag,  4.247425010840047*ul.AB_mag, atol=0.001*ul.AB_mag)
    @test isapprox(5*ul.AB_mag / 100, 10*ul.AB_mag, atol=0.001*ul.AB_mag)
    # TODO: patch src/utils.jl for this? Doing uexpand manually for now
    @test_broken isapprox(5*ul.AB_mag + 10*u.Jy, 46.31*u.Jy, atol=0.001*ul.AB_mag)
    @test isapprox(5*ul.AB_mag + 10*u.Jy, 46.31*u.Jy, atol=uexpand(0.001*ul.AB_mag))
end

@testitem "Zero-point" setup=[DQ] begin
    @test isapprox(1ul.V_mag, 3640u.Jy; atol=0.001ul.V_mag)
end

@testitem "Algebraic operations" setup=[DQ] begin
    @test iszero(1ul.B_mag - 1ul.V_mag)
    @test isapprox(5*ul.B_mag - 1ul.V_mag, 4)
    @test isapprox(1ul.B_mag - 5*ul.V_mag, -4)
    @test isapprox(1ul.B_mag - 0.5*ul.V_mag, 0.5)
    @test_throws MethodError 1ul.B_mag + 2ul.V_mag
    @test_throws MethodError 1ul.B_mag * 2ul.V_mag
    @test_throws MethodError 1ul.B_mag / 2ul.V_mag
    @test_throws MethodError 1ul.B_mag // 2ul.V_mag
end
