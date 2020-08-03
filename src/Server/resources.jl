module Resource

# Point the REST APIs to to actual functions that will do the tasks
# parsing the URI to translate the string to arguments
# it also Responsesible for create a new users and validate them
# and log them in to the system

using Dates, HTTP, JSON3
using ..Model, ..Service, ..Auth, ..Contexts, ..Workers

const ROUTER = HTTP.Router()

HTTP.@register(ROUTER, "POST", "/album", createAlbum)
createAlbum(req) = Service.createAlbum(JSON3.read(req.body))::Album

HTTP.@register(ROUTER, "GET", "/album/*", getAlbum)
getAlbum(req) = Service.getAlbum(parse(Int, HTTP.URIs.splitpath(req.target)[2]))::Album

HTTP.@register(ROUTER, "PUT", "/album/*", updateAlbum)
updateAlbum(req) = Service.updateAlbum(parse(Int, HTTP.URIs.splitpath(req.target)[2]), JSON3.read(req.body, Album))::Album

HTTP.@register(ROUTER, "DELETE", "/album/*", deleteAlbum)
deleteAlbum(req) = Service.deleteAlbum(parse(Int, HTTP.URIs.splitpath(req.target)[2]))

HTTP.@register(ROUTER, "GET", "/", pickAlbumToListen)
pickAlbumToListen(req) = fetch(Workers.@async(Service.pickAlbumToListen()::Album))

function contextHandler(req)
    withcontext(User(req)) do
        HTTP.Response(200, JSON3.write(HTTP.handle(ROUTER, req)))
    end
end

const AUTH_ROUTER = HTTP.Router(contextHandler)

function authenticate(user::User)
    resp = HTTP.Response(200, JSON3.write(user))
    return Auth.addtoken!(resp, user)
end


HTTP.@register(AUTH_ROUTER, "POST", "/user", createUser)
createUser(req) = authenticate(Service.createUser(JSON3.read(req.body))::User)

HTTP.@register(AUTH_ROUTER, "POST", "/user/login", loginUser)
loginUser(req) = authenticate(Service.loginUser(JSON3.read(req.body, User))::User)

function requestHandler(req)
    start = Dates.now(Dates.UTC)
    @info (timestamp=start, event="ServiceRequestBegin", tid=Threads.threadid(), 
            method=req.method, target=req.target)
    local resp
    try
        resp = HTTP.handle(AUTH_ROUTER, req)
    catch e
        if e isa Auth.Unauthenticated
            resp = HTTP.Response(401)
        else
            s = IOBuffer()
            showerror(s, e, catch_backtrace(); backtrace=true)
            errormsg = String(resize!(s.data, s.size))
            @error errormsg
            resp = HTTP.Response(500, errormsg)
        end
    end
    stop = Dates.now(Dates.UTC)
    @info (timestamp=stop, event="ServiceRequestEnd", tid=Threads.threadid(), 
            method=req.method, target=req.target, duration=Dates.value(stop - start), 
            status=resp.status, bodysize=length(resp.body))
    return resp
end

function run()
    HTTP.serve(requestHandler, "0.0.0.0", 8080)
end

end # module