### A Pluto.jl notebook ###
# v0.20.13

using Markdown
using InteractiveUtils

# ╔═╡ 4ea34a20-6cd6-11f0-328e-a197b1716a60
begin
import Pkg
Pkg.activate(Base.current_project())

using Revise
import DynamicQuantities as DQ
using Unitful
using UnitfulAstro
end

# ╔═╡ 526d7c68-b081-45cb-bae7-cba8fd88decc
# DQ.@register_unit Jy 1e-26 * DQ.u"W/m^2/Hz"

# ╔═╡ f76faed0-489e-4a27-8dbe-328945df613a
struct LogUnit{R}
	zero_point::typeof(DQ.u"Jy")
	basedim::DQ.Dimensions{R}
	name::Symbol
end

# ╔═╡ 68291dba-61bd-4783-9819-677404349fc2
# This immediately converts to regular Dimensions
Base.:*(value::Number, unit::LogUnit) = unit.zero_point / exp10(value / 2.5)

# ╔═╡ 1261294e-5532-4c59-bbbe-0c75601b6a71
x1 = 5u"V_mag"; x1, x1.val

# ╔═╡ d69bd683-8f1e-4e32-82ae-908030f5e6e0
x2 = 0u"V_mag"; x2, x2.val

# ╔═╡ 6fc64b88-c1e3-4561-9f71-c17e0347fe37
@which DQ.uconvert(DQ.us"cm", 3DQ.u"m")

# ╔═╡ 54effaa5-6852-4eb3-a9d0-bfd2dc92955d
(3u"V_mag") - (7u"V_mag")

# ╔═╡ 5e06fd1e-e1e7-4d27-8d6a-a93138860fcc
223DQ.u"Jy" / DQ.u"Jy"

# ╔═╡ 3d1de5a4-4930-4fff-a536-63927c5c5f3f
function DQ.uconvert(qout::LogUnit, q)
	-2.5 * log10(q / qout.zero_point)
end

# ╔═╡ 5b7e3b89-8030-44f2-acdb-ecffb0992389
function Base.:(|>)(
    q,
    qout::LogUnit
)
    return DQ.uconvert(qout, q)
end


# ╔═╡ eb726108-5ce2-4977-872c-350e312293b8
(3u"V_mag" - 7u"V_mag") |> u"Jy"

# ╔═╡ 70cd09c6-f28a-4cb2-aaf1-b7d743493c36
223u"Jy" |> u"V_mag"

# ╔═╡ 8be14e3e-326e-4800-91e2-b12a4507559c
module LogUnits
	import DynamicQuantities as DQ
	import ..LogUnit
	
	const V_mag = LogUnit(
		3640.0 * DQ.u"Jy",
		DQ.Dimensions{DQ.DEFAULT_DIM_BASE_TYPE}(mass=1, time=-2),
		Symbol("Johnson V mag"),
	)
	
	function map_to_scope(sym::Symbol)
		return V_mag
	end
end

# ╔═╡ fc0f64e4-e8d4-4be4-8a79-f95acf92ac01
Base.show(io::IO, unit::LogUnit) = print(io, unit.name)

# ╔═╡ 0eb3118b-03bf-469c-99ce-c7d04b599aab
macro ul_str(s)
	ex = LogUnits.map_to_scope(Meta.parse(s))
	return esc(ex)
end

# ╔═╡ 2a3575db-0343-4afc-8878-5fed949871ab
(3ul"V_mag"  - 7ul"V_mag") |> DQ.us"Jy"

# ╔═╡ 23ac0e61-7b31-4f6a-8e6a-534233c5e04b
223*DQ.u"Jy" |> ul"V_mag"

# ╔═╡ 4506efa1-a142-487a-a98c-2c70370ba044
(ul"V_mag").zero_point

# ╔═╡ Cell order:
# ╠═4ea34a20-6cd6-11f0-328e-a197b1716a60
# ╠═1261294e-5532-4c59-bbbe-0c75601b6a71
# ╠═d69bd683-8f1e-4e32-82ae-908030f5e6e0
# ╠═526d7c68-b081-45cb-bae7-cba8fd88decc
# ╠═f76faed0-489e-4a27-8dbe-328945df613a
# ╠═2a3575db-0343-4afc-8878-5fed949871ab
# ╠═eb726108-5ce2-4977-872c-350e312293b8
# ╠═70cd09c6-f28a-4cb2-aaf1-b7d743493c36
# ╠═23ac0e61-7b31-4f6a-8e6a-534233c5e04b
# ╠═6fc64b88-c1e3-4561-9f71-c17e0347fe37
# ╠═54effaa5-6852-4eb3-a9d0-bfd2dc92955d
# ╠═5e06fd1e-e1e7-4d27-8d6a-a93138860fcc
# ╠═68291dba-61bd-4783-9819-677404349fc2
# ╠═4506efa1-a142-487a-a98c-2c70370ba044
# ╠═3d1de5a4-4930-4fff-a536-63927c5c5f3f
# ╠═5b7e3b89-8030-44f2-acdb-ecffb0992389
# ╠═8be14e3e-326e-4800-91e2-b12a4507559c
# ╠═fc0f64e4-e8d4-4be4-8a79-f95acf92ac01
# ╠═0eb3118b-03bf-469c-99ce-c7d04b599aab
