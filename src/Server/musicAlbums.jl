module MusicAlbums

export Model, Mapper, Services, Resources, Client

include("model.jl")
using .Model

include("mapper.jl")
using .Mapper

include("services.jl")
using .Services

include("resources.jl")
using .Resources

include("../Client/client.jl")
using .Client

function run()
    Resources.run()
    
end

end # module
