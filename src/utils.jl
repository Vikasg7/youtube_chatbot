module Utils

using Dates

escapeAmpersand(str::String) = replace(str, "&" => "^&")

timeInMS() = floor(Int64, Dates.time())

function isnumber(x) 
   try
      all([x] .|> [!isnan, !isinf, isreal]) 
   catch
      false
   end
end

function repeatedly(fn::Function, interval::Union{Integer, Float64})
   while true
      fn()
      sleep(interval)
   end
end

end