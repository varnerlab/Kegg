function http_get_call_with_url(url::String)::String

    # should we check if this string is formatted as a URL?
    if (occursin("http://",url) == false)
        throw(ArgumentError("url $(url) is not properly formatted"))
    end

    # ok, so we are going to make a HTTP GET call with the URL that was passed in -
    response = HTTP.request("GET",url)

    # ok, so let's check if we are getting a 200 back -
    if (response.status == 200)
        return String(response.body)
    else
        # create an error, and throw it back to the caller -
        throw(ErrorException("http status flag $(response.status) was returned from url $(url)"))
    end
end
