#Dynamic viscosity of gases at low pressures, Pa*s
function dynvisc_gas(data, T)
	(;A,B,C,D,E) = data.DynVisc
	# VDI heat atlas 2010 D3.1 Equation (3)
	A+B*T+C*T^2+D*T^3+E*T^4 * ufac"Pa*s"
end

function dynvisc_mix(data, T, x)
    mumix = 0
    for i=1:data.ng
        mumix += x[i] * dynvisc_gas(data.Fluids[i], T)
    end
    mumix
end

#Thermal conductivity of gases at low pressures, W/(m*K)
function thermcond_gas(data, T)
	(;A,B,C,D,E) = data.ThermCond
	# VDI heat atlas 2010 D3.1 Equation (5)
	A+B*T+C*T^2+D*T^3+E*T^4 * ufac"W/(m*K)"
end

function thermcond_mix(data, T, x)
    lmix = 0
    for i=1:data.ng
        lmix += x[i] * thermcond_gas(data.Fluids[i], T)
    end
    lmix
end

#Molar heat capacity of ideal gases, J/(kg*K)
function heatcap_gas(data, T)
	(;A,B,C,D,E,F,G) = data.HeatCap
	# VDI heat atlas 2010 D3.1 Equation (10)
	T_ApT = (T/(A+T))
	(B+(C-B)*T_ApT^2*(1- (A/(A+T))*(D+E*T_ApT+F*T_ApT^2+G*T_ApT^3) ) ) * ph"R" / data.MW  * ufac"J/(kg*K)"
end

function heatcap_mix(data, T, x)
    cpmix = 0
    for i=1:data.ng
        cpmix += x[i] * heatcap_gas(data.Fluids[i], T)
    end
    cpmix
end

function molarweight_mix(data, x)
    wmix =0
    for i=1:data.ng
        wmix += x[i] * data.Fluids[i].MW
    end
    wmix
end

function density_idealgas(data, T, p, x)
	#p/(ph"R"*T)*data.MW*ufac"kg/m^3"
    p/(ph"R"*T)*molarweight_mix(data, x)*ufac"kg/m^3"
end

function binary_diff_coeff_gas(gas1, gas2, T, p)
    0.00143*T^1.75 * ( 1/(gas1.MW/ufac"g/mol")+1/(gas2.MW/ufac"g/mol") )^0.5 / (p/ufac"bar"*sqrt(2)*(gas1.ΔvF^(1.0/3.0)+gas2.ΔvF^(1.0/3.0))^2.0) *ufac"cm^2/s"
end

abstract type AbstractPropsCoeffs end

Base.@kwdef mutable struct PropsCoeffs <: AbstractPropsCoeffs
    A::Float64=1.0
	B::Float64=1.0
	C::Float64=1.0
	D::Float64=1.0
	E::Float64=1.0
	F::Float64=1.0
	G::Float64=1.0
end



abstract type AbstractFluidProps end

Base.@kwdef mutable struct FluidProps <: AbstractFluidProps
	name::String="Air"
	MW::Float64=28.96*ufac"g/mol"
    # Group contributions for the diffusion volumes in the Fuller method from VDI heat atlas 2010, D1 Table 9 (p.150)
    ΔvF::Float64=19.7 
	HeatCap::AbstractPropsCoeffs=PropsCoeffs(
	A=2548.9320,
	B=3.5248,
	C=-0.6366,
	D=-3.4281,
	E=49.8238,
	F=-120.3466,
	G=98.8658
	)
	ThermCond::AbstractPropsCoeffs=PropsCoeffs( 
	A=-0.908e-3,
	B=0.112e-3,
	C=-0.084333e-6,
	D=0.056964e-9,
	E=-0.015631e-12
	)
	DynVisc::AbstractPropsCoeffs=PropsCoeffs(
	A=-0.01702e-5,
	B=0.79965e-7,
	C=-0.72183e-10,
	D=0.04960e-12,
	E=-0.01388e-15
	)	
end

# all values taken from VDI heat atlas 2010 chapter D3
N2=FluidProps(
    name="N2",
	# D3.1 Table 1
	MW=28.01*ufac"g/mol",
    # Group contributions for the diffusion volumes in the Fuller method from VDI heat atlas 2010, D1 Table 9 (p.150)
    ΔvF=18.5, 
	# D3.1 Table 6
	HeatCap=PropsCoeffs(
	A=432.2027,
	B=3.5160,
	C=2.8021,
	D=-4.1924,
	E=42.0153,
	F=-114.2500,
	G=111.1019
	),
	# D3.1 Table 10
	ThermCond=PropsCoeffs(
	A=-0.133e-3,
	B=0.101e-3,
	C=-0.060650e-6,
	D=0.033610e-9,
	E=-0.0071e-12
	),
	# D3.1 Table 8
	DynVisc= PropsCoeffs(
	A=-0.01020e-5,
	B=0.74785e-7,
	C=-0.59037e-10,
	D=0.03230e-12,
	E=-0.00673e-15
)
);

# all values taken from VDI heat atlas 2010 chapter D3
Air=FluidProps(
    name="Air",
	# D3.1 Table 1
	MW=28.96*ufac"g/mol",
    # Group contributions for the diffusion volumes in the Fuller method from VDI heat atlas 2010, D1 Table 9 (p.150)
    ΔvF=19.7, 
	# D3.1 Table 6
	HeatCap=PropsCoeffs(
	A=2548.9320,
	B=3.5248,
	C=-0.6366,
	D=-3.4281,
	E=49.8238,
	F=-120.3466,
	G=98.8658
	),
	# D3.1 Table 10
	ThermCond=PropsCoeffs( 
	A=-0.908e-3,
	B=0.112e-3,
	C=-0.084333e-6,
	D=0.056964e-9,
	E=-0.015631e-12
	),
	# D3.1 Table 8
	DynVisc=PropsCoeffs(
	A=-0.01702e-5,
	B=0.79965e-7,
	C=-0.72183e-10,
	D=0.04960e-12,
	E=-0.01388e-15
)
);

# all values taken from VDI heat atlas 2010 chapter D3
H2=FluidProps(
    name="H2",
	# D3.1 Table 1
	MW=2.02*ufac"g/mol",
    # Group contributions for the diffusion volumes in the Fuller method from VDI heat atlas 2010, D1 Table 9 (p.150)
    ΔvF=6.12, 
	# D3.1 Table 6
	HeatCap=PropsCoeffs(
	A=392.8422,
	B=2.4906,
	C=-3.6262,
	D=-1.9624,
	E=35.6197,
	F=-81.3691,
	G=62.6668
	),
	# D3.1 Table 10
	ThermCond=PropsCoeffs( 
	A=0.651e-3,
	B=0.767e-3,
	C=-0.687050e-6,
	D=0.506510e-9,
	E=-0.138540e-12
	),
	# D3.1 Table 8
	DynVisc=PropsCoeffs(
	A=0.18024e-5,
	B=0.27174e-7,
	C=-0.13395e-10,
	D=0.00585e-12,
	E=-0.00104e-15
)
);

# all values taken from VDI heat atlas 2010 chapter D3
CO2=FluidProps(
    name="CO2" ,
	# D3.1 Table 1
	MW=44.01*ufac"g/mol",
    # Group contributions for the diffusion volumes in the Fuller method from VDI heat atlas 2010, D1 Table 9 (p.150)
    ΔvF=26.9, 
	# D3.1 Table 6
	HeatCap=PropsCoeffs(
	A=514.5073,
	B=3.4923,
	C=-0.9306,
	D=-6.0861,
	E=54.1586,
	F=-97.5157,
	G=70.9687
	),
	# D3.1 Table 10
	ThermCond=PropsCoeffs( 
	A=-3.882e-3,
	B=0.053e-3,
	C=0.071460e-6,
	D=-0.070310e-9,
	E=0.018090e-12
	),
	# D3.1 Table 8
	DynVisc=PropsCoeffs(
	A=-0.18024e-5,
	B=0.65989e-7,
	C=-0.37108e-10,
	D=0.01586e-12,
	E=-0.00300e-15
)
);

# all values taken from VDI heat atlas 2010 chapter D3
CO=FluidProps(
    name="CO",
	# D3.1 Table 1
	MW=28.01*ufac"g/mol",
    # Group contributions for the diffusion volumes in the Fuller method from VDI heat atlas 2010, D1 Table 9 (p.150)
    ΔvF=18.0, 
	# D3.1 Table 6
	HeatCap=PropsCoeffs(
	A=407.9796,
	B=3.5028,
	C=2.8524,
	D=-2.3018,
	E=32.9055,
	F=-100.1815,
	G=106.1141
	),
	# D3.1 Table 10
	ThermCond=PropsCoeffs( 
    A=-0.783e-3,
    B=0.103e-3,
    C=-0.067590e-6,
    D=0.039450e-9,
    E=-0.009470e-12
	),
	# D3.1 Table 8
	DynVisc=PropsCoeffs(
	A=0.01384e-5,
	B=0.74306e-7,
	C=-0.62996e-10,
	D=0.03948e-12,
	E=-0.01032e-15
)
);

# all values taken from VDI heat atlas 2010 chapter D3
H2O=FluidProps(
    name="H2O",
	# D3.1 Table 1
	MW=18.02*ufac"g/mol",
    # Group contributions for the diffusion volumes in the Fuller method from VDI heat atlas 2010, D1 Table 9 (p.150)
    ΔvF=13.1, 
	# D3.1 Table 6
	HeatCap=PropsCoeffs(
	A=706.3032,
	B=5.1703,
	C=-6.0865,
	D=-6.6011,
	E=36.2723,
	F=-63.0965,
	G=46.2085
	),
	# D3.1 Table 10
	ThermCond=PropsCoeffs( 
	A=13.918e-3,
	B=-0.047e-3,
	C=0.258066e-6,
	D=-0.183149e-9,
	E=0.055092e-12
	),
	# D3.1 Table 8
	DynVisc=PropsCoeffs(
	A=0.64966e-5,
	B=-0.15102e-7,
	C=1.15935e-10,
	D=0.10080e-12,
	E=0.03100e-15
)
);

# all values taken from VDI heat atlas 2010 chapter D3
CH4=FluidProps(
    name="CH4" ,
	# D3.1 Table 1
	MW=16.04*ufac"g/mol",
    # Group contributions for the diffusion volumes in the Fuller method from VDI heat atlas 2010, D1 Table 9 (p.150)
    ΔvF=25.14, 
	# D3.1 Table 6
	HeatCap=PropsCoeffs(
	A=1530.8043,
	B=4.2038,
	C=-16.6150,
	D=-3.5668,
	E=43.0563,
	F=-86.5507,
	G=65.5986
	),
	# D3.1 Table 10
	ThermCond=PropsCoeffs( 
	A=8.154e-3,
	B=0.008e-3,
	C=0.351530e-6,
	D=-0.338650e-9,
	E=0.140920e-12
	),
	# D3.1 Table 8
	DynVisc=PropsCoeffs(
	A=-0.07759e-5,
	B=0.50484e-7,
	C=-0.43101e-10,
	D=0.03118e-12,
	E=-0.00981e-15
)
);

# all values taken from VDI heat atlas 2010 chapter D3
Ar=FluidProps(
    name="Ar" ,
	# D3.1 Table 1
	MW=39.95*ufac"g/mol",
    # Group contributions for the diffusion volumes in the Fuller method from VDI heat atlas 2010, D1 Table 9 (p.150)
    ΔvF=16.2, 
	# D3.1 Table 6
	HeatCap=PropsCoeffs(
	A=0.0,
	B=2.5,
	C=2.5,
	D=0.0,
	E=0.0,
	F=0.0,
	G=0.0
	),
	# D3.1 Table 10
	ThermCond=PropsCoeffs( 
	A=4.303e-3,
	B=0.047e-3,
	C=-0.007780e-6,
	D=0.0,
	E=0.0
	),
	# D3.1 Table 8
	DynVisc=PropsCoeffs(
	A=0.16196e-5,
	B=0.81279e-7,
	C=-0.41263e-10,
	D=0.01668e-12,
	E=-0.00276e-15
)
);

