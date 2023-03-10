module FixedBed

using LessUnitful

include("physprops.jl")
export AbstractFluidProps, FluidProps, AbstractPropsCoeffs, PropsCoeffs
export dynvisc_gas, thermcond_gas, heatcap_gas, density_idealgas, binary_diff_coeff_gas
export dynvisc_mix, heatcap_mix, molarweight_mix, dynvisc_thermcond_mix
export Air, N2, Ar, H2, CO2, CO, H2O, CH4


include("modelprops.jl")
#export AbstractModelData, ModelData, RePrPe, kbed, hsf, DK_eff
export AbstractModelData, RePrPe, kbed, hsf, DK_eff


include("kinetics.jl")
export AbstractKineticsData, ri, S3P, XuFroment1989
end
