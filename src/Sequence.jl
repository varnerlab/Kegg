# -- PRIVATE METHODS ----------------------------------------------------------- #
function process_gene_location(gene_location::String)::String

    # does the gene_location contain a .x?
    dot_index = findfirst(x->x=='.',gene_location)
    if (dot_index == nothing)
        return gene_location
    end

    # ok, we have a dot -
    bare_gene_location = gene_location[1:dot_index-1]

    # return -
    return bare_gene_location
end
# ------------------------------------------------------------------------------ #

# -- PUBLIC METHODS ------------------------------------------------------------ #
function get_sequence_for_gene(gene_location::String)::Union{Sequence,Nothing}

    # TODO: check gene string -

    # gene seq - cutoff the trailing .x -
    kegg_gene_location = process_gene_location(gene_location)

    # setup the url string -
    url_string = "http://rest.kegg.jp/get/$(kegg_gene_location)/ntseq"

    # get the sequence -
    # returns: {header}\n{sequence_body}\n{?}
    ntseq = http_get_call_with_url(url_string)
    if (length(ntseq) == 0)
        return nothing
    end

    # split on the newline -
    fragment_array = split(ntseq,'\n')

    # build new sequence type -
    sequence = Sequence()
    sequence.gene_location = kegg_gene_location
    sequence.type = :gene
    sequence.header = fragment_array[1]
    sequence.body = fragment_array[2:end-1]

    # return the sequence -
    return sequence
end

function get_sequence_for_protein(gene_location::String)::Union{Sequence,Nothing}

    # TODO: check gene string -

    # gene seq - cutoff the trailing .x -
    kegg_gene_location = process_gene_location(gene_location)

    # setup the url string -
    url_string = "http://rest.kegg.jp/get/$(kegg_gene_location)/aaseq"

    # get the sequence -
    # returns: {header}\n{sequence_body}\n{?}
    aaseq = http_get_call_with_url(url_string)
    if (length(aaseq) == 0)
        return nothing
    end

    # split on the newline -
    fragment_array = split(aaseq,'\n')

    # build new sequence type -
    sequence = Sequence()
    sequence.gene_location = kegg_gene_location
    sequence.type = :protein
    sequence.header = fragment_array[1]
    sequence.body = fragment_array[2:end-1]

    # return the sequence -
    return sequence
end
# ------------------------------------------------------------------------------ #
