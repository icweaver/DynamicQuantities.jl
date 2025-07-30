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

# ╔═╡ 1261294e-5532-4c59-bbbe-0c75601b6a71
x1 = 6u"V_mag"; x1.val

# ╔═╡ d69bd683-8f1e-4e32-82ae-908030f5e6e0
x2 = 5u"V_mag"; x2.val

# ╔═╡ 995e0b12-307c-4929-9afd-13404306734b
x2 - x1

# ╔═╡ f660e35e-5fc4-474a-a9f6-74889b318f3f
(x2.val - x1.val) |> u"V_mag"

# ╔═╡ a1910e75-6212-4efb-b835-02460a621de4
(3DQ.ua"degC") / (2DQ.ua"degF")

# ╔═╡ b87d0ae6-8789-4ae0-b495-abdd000b8797
DQ.ua"degF"

# ╔═╡ 526d7c68-b081-45cb-bae7-cba8fd88decc
DQ.@register_unit Jy 1e-26 * DQ.u"W/m^2/Hz"

# ╔═╡ 52eb2ec3-d555-4b3c-923d-865c3e8054cf
DQ.u"Jy" |> typeof

# ╔═╡ f76faed0-489e-4a27-8dbe-328945df613a
struct LogUnit{R}
	zero_point::typeof(DQ.u"Jy")
	basedim::DQ.Dimensions{R}
	name::Symbol
end

# ╔═╡ 8be14e3e-326e-4800-91e2-b12a4507559c
module LogUnits
	import DynamicQuantities as DQ
	import ..LogUnit
	
	const V_mag = LogUnit(
		3640.0 * DQ.u"Jy",
		DQ.Dimensions{DQ.DEFAULT_DIM_BASE_TYPE}(mass=1, time=-2),
		:V_mag
	)
	
	function map_to_scope(sym::Symbol)
		return 
	end
end

# ╔═╡ 0eb3118b-03bf-469c-99ce-c7d04b599aab
macro ul_str(s)
	ex = LogUnits.map_to_scope(Meta.parse(s))
	return esc(ex)
end

# ╔═╡ df7d52a8-36f0-4ff9-8b1b-30d628aaf865
ul"f"

# ╔═╡ Cell order:
# ╠═4ea34a20-6cd6-11f0-328e-a197b1716a60
# ╠═1261294e-5532-4c59-bbbe-0c75601b6a71
# ╠═d69bd683-8f1e-4e32-82ae-908030f5e6e0
# ╠═995e0b12-307c-4929-9afd-13404306734b
# ╠═f660e35e-5fc4-474a-a9f6-74889b318f3f
# ╠═a1910e75-6212-4efb-b835-02460a621de4
# ╠═b87d0ae6-8789-4ae0-b495-abdd000b8797
# ╠═526d7c68-b081-45cb-bae7-cba8fd88decc
# ╠═52eb2ec3-d555-4b3c-923d-865c3e8054cf
# ╠═f76faed0-489e-4a27-8dbe-328945df613a
# ╠═8be14e3e-326e-4800-91e2-b12a4507559c
# ╠═0eb3118b-03bf-469c-99ce-c7d04b599aab
# ╠═df7d52a8-36f0-4ff9-8b1b-30d628aaf865
