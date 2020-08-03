module Mapper
   
    using ..Model

    const STORE = Dict{Int64, Album}()
    const COUNTER = Ref{Int64}(0)

    function store!(album)
        if haskey(STORE, album.id)
            # updating
            STORE[album.id] = album
        else
            # creating new
            album.id = COUNTER[] += 1
            STORE[album.id] = album
        end
        return
    end

    function get(id)
        return STORE[id]
    end

    function delete(id)
        delete!(STORE, id)
        return
    end

    function getAllAlbums()
        return collect(values(STORE))
    end 
end