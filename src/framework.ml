type req = Http.Request.request * Router.params

type res = Http.Response.response

type route = { meth: string ;
               pattern: string ;
               handler: req -> res -> res ;
             }

type server = { routes: route list }

let create_server () = { routes = [] }

let not_found req res =
  res
  |> Http.Response.set_status 404
  |> Http.Response.set_body
    (Printf.sprintf "Unknown path %s" (Http.Request.req_path req))

let route server req =
  let rec inner routes =
    match routes with
    | [] -> not_found req
    | item :: rest -> begin
        if item.meth = Http.Request.req_method req then
          match Router.match_pattern item.pattern (Http.Request.req_path req) with
          | None -> inner rest
          | Some params -> item.handler (req, params)
        else
          not_found req
      end
  in inner (List.rev server.routes)

let get pattern handler server =
  { routes = { meth = "GET" ;
               pattern = pattern ;
               handler = handler ;
             }
             :: server.routes
  }

let post pattern handler server =
  { routes = { meth = "POST" ;
               pattern = pattern ;
               handler = handler ;
             }
             :: server.routes
  }

let respond str res =
  res
  |> Http.Response.set_header "Content-Type" "text/html"
  |> Http.Response.set_body str

let param (_, params) key = List.assoc key params

let listen port server =
  Http.create_server
    port
    (fun req res -> route server req res |> Http.Response.send)
