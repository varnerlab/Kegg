mutable struct Reaction

    ec_number::String
    kegg_reaction_number::String
    kegg_enzyme_name::String
    kegg_reaction_markup::String

    function Reaction()
		this = new()
	end
end

mutable struct Organism

    organism_id::String
    organism_code::String
    species_description::String
    species_taxonomy::String

    function Organism()
		this = new()
	end
end

mutable struct Sequence

    gene_location::String
    type::Symbol
    body::Array{SubString{String},1}
    header::String

    function Sequence()
		this = new()
	end
end
