const _DEFAULT_DATE_FORMAT = dateformat"dd/mm/yyyy"
const _DEFAULT_DATETIME_FORMAT = dateformat"dd/mm/yyyy HH:MM"

const HEADERS = Pair{String, String}[
    "User-Agent" => "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36",
    "Accept-Language" => "en-US,en;q=0.9",
    "Connection" => "keep-alive",
    "Upgrade-Insecure-Requests" => "1",
]


_clear_cache() = empty!(CACHE)

_sanitize_number_string(s::AbstractString) = replace(s, "." => "", "," => ".", "%" => "")
_sanitize_date_string(s::AbstractString) = replace(s, r"\s+" => " ") |> strip

_sanitize_int(s::AbstractString) = parse(Int, _sanitize_number_string(s))

function _sanitize_float(s::AbstractString; as_percentage::Bool = false) :: Float64
    parsed = parse(Float64, _sanitize_number_string(s))
    return as_percentage ? parsed / 100 : parsed
end


function _parse_date(s::AbstractString; format::DateFormat = _DEFAULT_DATE_FORMAT) :: Date
    return Date(_sanitize_date_string(s), format)
end


function _parse_date_time(s::AbstractString; format::DateFormat = _DEFAULT_DATETIME_FORMAT) :: DateTime
    return DateTime(_sanitize_date_string(s), format)
end


function _extract_link_from_attributes(node::Gumbo.HTMLNode) :: Union{Missing, AbstractString}
    match = eachmatch(Selector("a"), node)
    return isempty(match) ? missing : only(match).attributes["href"]
end


"""
    decode_cfemail(cfemail::AbstractString) :: String

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
function decode_cfemail(cfemail::AbstractString) :: String
    bytes = hex2bytes(cfemail)
    key = first(bytes)
    return String(Char.(bytes[2:end] .⊻ key))
end


function get_html_from_url(; url::String, encoding::String = "UTF-8") :: String
    if url in keys(CACHE)
        decoded = CACHE[url]
    else
        html_bytes = HTTP.get(url, headers = HEADERS).body
        decoded = StringEncodings.decode(html_bytes, encoding)
        CACHE[url] = decoded
    end
    return decoded
end
