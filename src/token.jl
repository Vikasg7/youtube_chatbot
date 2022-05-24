module Token

using JSON3
using JSON3:StructTypes
using ..Data

StructTypes.StructType(::Type{Data.Token}) = StructTypes.Struct()

function read(json::String)::Data.Token
   JSON3.read(json, Data.Token)
end

function write(fPath::String, tokn::Data.Token)
   open(fPath, "w") do io
      JSON3.write(io, tokn)
   end
end

end