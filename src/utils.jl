module Utils

escapeAmpersand(str::String) = replace(str, "&" => "^&")

end