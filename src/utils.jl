module Utils

function escapeAmpersand(str::String)::String
   replace(str, "&" => "^&")
end

end