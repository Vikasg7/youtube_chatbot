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

function timer(fn::Function, delay=0; interval=0.1)
   sleep(delay)
   while true
      fn()
      interval == 0 && break
      sleep(interval)
   end
end

# Race tasks and error channels until first error
function raceError(fs...)
   err = Channel(1)
   for f in fs
      if f isa Channel
         @async put!(err, fetch(f))
      end
      if f isa Task
         @async try
            fetch(f)
         catch ex
            put!(err, (ex, catch_backtrace()))
         end
      end
   end
   fetch(err)
end

end