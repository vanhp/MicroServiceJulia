module MusicAlbums

export Model, Mapper, Services, Resources, Client

include("connectionPools.jl")
using .ConnectionPools

include("workers.jl")
using .Workers

include("model.jl")
using .Model

include("auth.jl")
using .Auth

include("contexts.jl")
using .Contexts

include("mapper.jl")
using .Mapper

include("services.jl")
using .Service

include("resources.jl")
using .Resource

include("../Client/client.jl")
using .Client

function run(dbfile, authkeysfile)
    Workers.init()
    Mapper.init(dbfile)
    Auth.init(authkeysfile)
    Resource.run()
end

end # module
