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
uexpand(m::MagUnit) = (m.zero_point / exp10(0.4 * m.value))

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

    const bol_Mag = MagUnit(
        1.0,
        3.0128e28u"W",
        Symbol("bol Mag"),
    )

    const bol_mag = MagUnit(
        1.0,
        2.518_021_002e-8u"W/m^2",
        Symbol("bol Mag"),
    )

    const U_mag = MagUnit(
        1.0,
        1810u"Jy",
        Symbol("Johnson U mag"),
    )

    const B_mag = MagUnit(
        1.0,
        4260u"Jy",
        Symbol("Johnson B mag"),
    )

    const V_mag = MagUnit(
        1.0,
        3640u"Jy",
        Symbol("Johnson V mag"),
    )

    const R_mag = MagUnit(
        1.0,
        3080u"Jy",
        Symbol("Johnson R mag"),
    )

    const I_mag = MagUnit(
        1.0,
        2550u"Jy",
        Symbol("Johnson I mag"),
    )

    const J_mag = MagUnit(
        1.0,
        1600u"Jy",
        Symbol("Johnson J mag"),
    )

    const H_mag = MagUnit(
        1.0,
        1080u"Jy",
        Symbol("Johnson H mag"),
    )

    const K_mag = MagUnit(
        1.0,
        670u"Jy",
        Symbol("Johnson K mag"),
    )

    const g_mag = MagUnit(
        1.0,
        3730u"Jy",
        Symbol("Gunn g mag"),
    )

    const r_mag = MagUnit(
        1.0,
        4490u"Jy",
        Symbol("Gunn r mag"),
    )

    const i_mag = MagUnit(
        1.0,
        4760u"Jy",
        Symbol("Gunn i mag"),
    )

    const z_mag = MagUnit(
        1.0,
        4810u"Jy",
        Symbol("Gunn z mag"),
    )

    function map_to_scope(sym::Symbol)
        if sym == Symbol("AB_mag")
            return AB_mag
        elseif sym == Symbol("bol_Mag")
            return bol_Mag
        elseif sym == Symbol("bol_mag")
            return bol_mag
        elseif sym == Symbol("U_mag")
            return U_mag
        elseif sym == Symbol("B_mag")
            return B_mag
        elseif sym == Symbol("V_mag")
            return V_mag
        elseif sym == Symbol("R_mag")
            return R_mag
        elseif sym == Symbol("I_mag")
            return I_mag
        elseif sym == Symbol("J_mag")
            return J_mag
        elseif sym == Symbol("H_mag")
            return H_mag
        elseif sym == Symbol("K_mag")
            return K_mag
        elseif sym == Symbol("g_mag")
            return g_mag
        elseif sym == Symbol("r_mag")
            return r_mag
        elseif sym == Symbol("i_mag")
            return i_mag
        elseif sym == Symbol("z_mag")
            return z_mag
        else
            throw(ArgumentError("Symbol $sym not found in `LogUnits`."))
        end
    end
end

macro ul_str(s)
    ex = LogUnits.map_to_scope(Meta.parse(s))
    return esc(ex)
end
