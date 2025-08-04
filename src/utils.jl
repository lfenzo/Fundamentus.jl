function sanitize_float(s::T) :: Float64 where {T <: AbstractString}
    return parse(Float64, replace(s, "." => "", "," => "."))  # "1.000,00" -> 1000.00
end


"""
    decode_cfemail(cfemail::AbstractString) -> String

Decodes a Cloudflare-protected email string (`data-cfemail`) back into its original email address.

Cloudflare uses a simple obfuscation technique to hide email addresses in HTML by embedding
them as hexadecimal strings in the `data-cfemail` attribute. This protects them from basic
web scrapers.

The encoding works as follows:
- The first byte (2 hex digits) represents a random "key" byte.
- Each subsequent byte is the result of XOR'ing a character of the email with the key.
- To decode, each byte is XOR'ed again with the key to recover the original character.

# Arguments
- `cfemail::AbstractString`: A hexadecimal string from the `data-cfemail` attribute, e.g.
  `"fd8e898f889e89888f9899d09b8893998ebd9a9893949c91d39e9290d38b9e"`

# Returns
- The decoded email address as a `String`.
"""
function decode_cfemail(cfemail::String) :: String
    bytes = [parse(UInt8, cfemail[i:i + 1], base=16) for i in 1:2:length(cfemail) - 1]
    key = bytes[1]
    decoded_chars = Char[]
    for b in bytes[2:end]
        push!(decoded_chars, Char(b ⊻ key))
    end
    return join(decoded_chars)
end


function get_html_from_url(; url::String, encoding::String = "UTF-8") :: String
    if url in keys(CACHE)
        decoded = CACHE[url]
    else
        html_bytes = HTTP.get(url).body
        decoded = StringEncodings.decode(html_bytes, encoding)
        CACHE[url] = decoded
    end
    return decoded
end
