module Token

using JSON3
using JSON3:StructTypes
using ..Data

StructTypes.StructType(::Type{Data.Token}) = StructTypes.Struct()

function read(json::String)::Data.Token
   JSON3.read(json, Data.Token)
end

end