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

# ╔═╡ a679bc98-3252-4e79-96a5-dc202b514a64
36.4 == 3640 / 10^(5/2.5)

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
function Base.:*(value::Number, unit::LogUnit)
    new_value = unit.zero_point / exp10(value / 2.5)
    # Always use Float64 for temperature conversions to avoid precision issues
	return new_value #Quantity(new_value, unit.basedim)
end

# ╔═╡ 1261294e-5532-4c59-bbbe-0c75601b6a71
x1 = 5u"V_mag"; x1, x1.val

# ╔═╡ d69bd683-8f1e-4e32-82ae-908030f5e6e0
x2 = 0u"V_mag"; x2, x2.val

# ╔═╡ 4fbbf8a9-0ade-4f44-98d6-ced9fcbdaa8f
5 == 2.5 * log10(3640 / 36.4)

# ╔═╡ eb726108-5ce2-4977-872c-350e312293b8
(3u"V_mag" - 7u"V_mag") |> u"Jy"

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
(3 * ul"V_mag"  - 7 * ul"V_mag") |> DQ.us"Jy"

# ╔═╡ Cell order:
# ╠═4ea34a20-6cd6-11f0-328e-a197b1716a60
# ╠═1261294e-5532-4c59-bbbe-0c75601b6a71
# ╠═d69bd683-8f1e-4e32-82ae-908030f5e6e0
# ╠═4fbbf8a9-0ade-4f44-98d6-ced9fcbdaa8f
# ╠═a679bc98-3252-4e79-96a5-dc202b514a64
# ╠═526d7c68-b081-45cb-bae7-cba8fd88decc
# ╠═f76faed0-489e-4a27-8dbe-328945df613a
# ╠═2a3575db-0343-4afc-8878-5fed949871ab
# ╠═eb726108-5ce2-4977-872c-350e312293b8
# ╠═68291dba-61bd-4783-9819-677404349fc2
# ╠═8be14e3e-326e-4800-91e2-b12a4507559c
# ╠═fc0f64e4-e8d4-4be4-8a79-f95acf92ac01
# ╠═0eb3118b-03bf-469c-99ce-c7d04b599aab
