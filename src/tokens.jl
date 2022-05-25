module Tokens

using JSON3
using JSON3:StructTypes
using ..Data

StructTypes.StructType(::Type{Data.AccessToken}) = StructTypes.Struct()

function read(json::String)::Data.AccessToken
   JSON3.read(json, Data.AccessToken)
end

function read_from_file(fPath::String)::Data.RefreshToken
   open(fPath) do io
      Base.read(io, String)
   end
end

function save_to_file(fPath::String, rtkn::Data.RefreshToken)
   open(fPath, "w") do io
      write(io, rtkn)
   end
end

end