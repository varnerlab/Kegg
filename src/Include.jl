# - LOAD SYSTEM PACKAGES ------------------------------------------------------- #
using HTTP
# ------------------------------------------------------------------------------ #

# constants -
const path_to_package = dirname(pathof(@__MODULE__))

# - LOCAL FILES ---------------------------------------------------------------- #
include("Types.jl")
include("Network.jl")
include("Reactions.jl")
include("Sequence.jl")
include("Lists.jl")
# ------------------------------------------------------------------------------ #
