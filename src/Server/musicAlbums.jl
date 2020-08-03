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


include("auth.jl")
using .Auth

include("contexts.jl")
using .Contexts


function run(dbfile, authkeysfile)
    Mapper.init(dbfile)
    Auth.init(authkeysfile)
    Resource.run()
end



end # module
