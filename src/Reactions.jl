function get_reactions_for_ec_number(ec_number::String)::Union{Array{Reaction,1}, Nothing}

    # Check: does this contain a ec: prefix? Yes, chop it off -
    local_ec_number = ec_number
    if (occursin("ec:",ec_number) == true)
        local_ec_number = ec_number[4:end]
    end

    # initalize -
    record_array = Reaction[]

    # formulate url -
    linkage_url_string = "http://rest.kegg.jp/link/rn/$(local_ec_number)"

    # call to get linkage array -
    ec_rn_linkage_array = http_get_call_with_url(linkage_url_string)

    # if the server returned something, it should be in the form ec# rn#
    # we need the rn# to pull down the reaction string -
    if (length(ec_rn_linkage_array)>1)

        # ec_rn_linkage can have more than one association -
        # split around the \n, and then process each item
        P = reverse(split(chomp(ec_rn_linkage_array),'\n'))
        while (!isempty(P))

            # pop -
            local_record = pop!(P)

            # The second fragment is the rn# -
            # split around the \t
            rn_number = string(split(local_record,'\t')[2])

            # ok, run a second query to pull the reaction string down -
            reaction_string = chomp(http_get_call_with_url("http://rest.kegg.jp/list/$(rn_number)"))

            # if we have something in reaction string, create a string record -
            if (length(reaction_string)!=0)

                # create a new Reaction wrapper -
                reaction_wrapper = Reaction()

                # populate w/easy stuff -
                reaction_wrapper.ec_number = ec_number
                reaction_wrapper.kegg_reaction_number = rn_number

                # parse the body string -
                reaction_wrapper.kegg_enzyme_name = string(split(reaction_string,";")[1])
                reaction_wrapper.kegg_reaction_markup = chomp(string(split(reaction_string,";")[2]))

                # cache -
                push!(record_array,reaction_wrapper)
            end
        end
    end

    # check - zero entries?
    if (length(record_array) == 0)
        return nothing
    end

    # return list of records -
    return record_array
end

function get_ec_number_for_gene(gene_location::String)

    # TODO: check gene location string -

    # formulate the url -
    url_string = "http://rest.kegg.jp/link/ec/$(gene_location)"

    # get the sequence -
    ecdata = http_get_call_with_url(url_string)

    # check: do we have only the new line? Yes, then return nothing
    if (ecdata == "\n")
        return nothing
    end

    # ok, parse the response which is of the form: {gene_location}\t{ec_number}\n
    ec_number = string(split(ecdata,"\t")[2])

    # check - is the last char a new line?, Yes, cut it off -
    if (ec_number[end] == '\n')
        return ec_number[1:end-1]
    end

    # return this record -
    return ec_number
end


function write_ec_numbers_to_disk(path_to_input_gene_file::String,path_to_output_file::String,kegg_organism_code::String)

    # initalize -
    ec_number_buffer = String[]

    # get -
    gene_list = readdlm(path_to_input_gene_file,',')

    # how many genes do we have?
    (number_of_genes,number_of_cols) = size(gene_list)

    # create a progress meter -
    p = Progress(number_of_genes,color=:yellow)

    # start -
    @info "Downloading gene = ecnumber pairs from KEGG ..."

    # iterate through the list of tags -
    for gene_index = 1:number_of_genes

        # get the gene tag -
        gene_tag = String(gene_list[gene_index,2])

        # get the buffer -
        line_buffer = download_ec_number_from_kegg(gene_tag,kegg_organism_code)

        # check - does this have multiple records?
        P = split(line_buffer,'\n')
        number_of_fragments = length(P)
        for fragment_index = 1:number_of_fragments

            fragment_string = string(P[fragment_index])
            if (length(fragment_string)>0)

                # add line to overall buffer -
                push!(ec_number_buffer,fragment_string)

                # message -
                msg = "$(gene_tag) => $(fragment_string) ($(gene_index) of $(number_of_genes))"

                # update the progress bar -
                ProgressMeter.next!(p; showvalues = [(:status,msg)])
            end
        end
    end

    # dump to disk -
    open("$(path_to_output_file)/ec_numbers.dat", "w") do f

        for line_item in ec_number_buffer
            write(f,"$(line_item)\n")
        end
    end

    @info "Completed ...\r"

end

function write_protein_sequences_to_disk(path_to_input_gene_file::String, path_to_output_file::String, kegg_organism_code::String)

    # get -
    gene_list = readdlm(path_to_input_gene_file,',')

    # how many genes do we have?
    (number_of_genes, number_of_cols) = size(gene_list)

    # start -
    @info "Downloading protein sequences from KEGG ..."

    # create a progress meter -
    p = Progress(number_of_genes,color=:yellow)

    # iterate through the list of tags -
    for gene_index = 1:number_of_genes

        # get the gene tag -
        gene_tag = String(gene_list[gene_index,2])

        # get the buffer -
        buffer = download_protein_sequence_from_kegg(gene_tag, kegg_organism_code)

        # dump to disk -
        file_name = "$(path_to_output_file)/P_$(gene_tag).seq"
        writedlm(file_name,buffer)

        # update the progress bar -
        ProgressMeter.next!(p; showvalues = [(:gene_index,("$(gene_index) of $(number_of_genes)")), (:gene,gene_tag)])
    end

    @info "Completed ...\r"
end

function write_gene_sequences_to_disk(path_to_input_gene_file::String,path_to_output_file::String,kegg_organism_code::String)

    # get -
    gene_list = readdlm(path_to_input_gene_file,',')

    # how many genes do we have?
    (number_of_genes, number_of_cols) = size(gene_list)

    # start -
    @info "Downloading gene sequences from KEGG ..."

    # create a progress meter -
    p = Progress(number_of_genes,color=:yellow)

    # iterate through the list of tags -
    for gene_index in 1:number_of_genes

        # get the gene tag -
        gene_tag = String(gene_list[gene_index,2])

        # get the buffer -
        buffer = download_gene_sequence_from_kegg(gene_tag,kegg_organism_code)

        # dump to disk -
        file_name = "$(path_to_output_file)/$(gene_tag).seq"
        writedlm(file_name,buffer)

        # update the progress bar -
        ProgressMeter.next!(p; showvalues = [(:gene_index,("$(gene_index) of $(number_of_genes)")), (:gene,gene_tag)])

        # message -
        # msg = "$(gene_tag) => downloaded ($(gene_index) of $(number_of_genes))"
        # println(msg)
    end

    @info "Completed ...\r"
end

function write_gene_symbols_to_disk(cobra_dictionary, path_to_output_gene_file::String, organism_id::String)

    # get list of genes from the cobra_dictionary -
    gene_list = cobra_dictionary["genes"]


    # initialize buffer -
    gene_index = 1
    gene_name_buffer = String[]
    for gene_name in gene_list
        line = "$(gene_index),$(organism_id):$(gene_name)"
        push!(gene_name_buffer,line)
        gene_index = gene_index + 1
    end

    # dump to disk -
    open("$(path_to_output_gene_file)", "w") do f

        for line_item in gene_name_buffer
            write(f,"$(line_item)\n")
        end
    end

    # start -
    @info "Wrote gene symbols to $(path_to_output_gene_file)"
end
