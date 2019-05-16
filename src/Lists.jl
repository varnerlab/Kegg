# --- PRIVATE METHODS ---------------------------------------------------------- #
function check_orgamism_code(organism_code::String)
end
# ------------------------------------------------------------------------------ #

# --- PUBLIC METHODS ----------------------------------------------------------- #
function get_gene_list_for_organism(organism_code::String)

    # check the organism_id -
    check_orgamism_code(organism_code)

end

function get_pathway_list_for_organism(organism_code::String)::Dict{String,String}

    # check the organism_id -
    check_orgamism_code(organism_code)
end


function build_metabolite_matching_table()::Union{Dict{String,String},Nothing}

    # initialize -
    metabolite_matching_table = Dict{String,String}()

    # build the url -
    url_string = "http://rest.kegg.jp/list/compound"

    # make the call -
    http_body = http_get_call_with_url(url_string)

    # ok, so no body?
    if (length(http_body) == 0)
        return nothing
    end

    # populate the table -
    records_array = split(http_body,"\n")
    for record in records_array

        # records take the form:
        # kegg_compound_id\t{Names;*}

        if (record != "")
            # split around the \t -
            kegg_compound_id = string(split(record,"\t")[1])
            compound_name_array = split(record,"\t")[2]
            if (occursin(";",compound_name_array) == true)

                # ok, so we have multiple possible names -
                synomym_array = split(compound_name_array,";")
                for synonum in synomym_array
                    metabolite_matching_table[lstrip(string(synonum))] = kegg_compound_id
                end
            else
                metabolite_matching_table[lstrip(string(compound_name_array))] = kegg_compound_id
            end
        end
    end

    # return -
    return metabolite_matching_table
end

function get_organism_codes()::Union{Dict{String,Organism},Nothing}

    # initialize -
    organism_dictionary = Dict{String,Organism}()

    # formulate the URL -
    url_string = "http://rest.kegg.jp/list/organism"

    # make the call -
    http_body = http_get_call_with_url(url_string)

    # ok, so no body?
    if (length(http_body) == 0)
        return nothing
    end

    # split along the newline -
    tokenized_body = split(http_body,"\n")
    for record in tokenized_body

        # record -
        # {Txxx}\t{organism code}\t{description}\t{species_taxonomy}

        # ok, we need to cut again, along the \t -
        field_array = split(record,"\t")

        # check, do we have 4 elements -
        if (length(field_array) == 4)

            # create new organism -
            organism_wrapper = Organism()
            organism_wrapper.organism_id = field_array[1]
            organism_wrapper.species_description = field_array[3]
            organism_wrapper.species_taxonomy = field_array[4]

            # # grab the organism_code -
            organism_code = field_array[2]
            organism_wrapper.organism_code = organism_code

            # cache -
            organism_dictionary[organism_code] = organism_wrapper
        end
    end

    # return -
    return organism_dictionary
end
# ------------------------------------------------------------------------------ #
