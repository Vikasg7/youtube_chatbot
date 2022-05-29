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

# Race tasks or error channels until first error
function raceError(fetchables...)
   err = Channel(1)
   for fetchable in fetchables
      if fetchable isa Channel
         @async put!(err, fetch(fetchable))
      end
      if fetchable isa Task
         @async try
            fetch(fetchable)
         catch ex
            put!(err, (ex, catch_backtrace()))
         end
      end
   end
   fetch(err)
end

end