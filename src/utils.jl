module Utils

using Dates

escapeAmpersand(str::String) = replace(str, "&" => "^&")

timeInMS() = floor(Int64, Dates.time())

end