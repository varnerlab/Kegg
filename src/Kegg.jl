module Kegg

# include -
include("Include.jl")

# export methods -
export get_reactions_for_ec_number
export get_ec_number_for_gene
export get_sequence_for_gene
export get_sequence_for_protein

# export types -
export Reaction
export Sequence

end # module
