type route = { meth: string ;
               pattern: string ;
               handler: Router.params -> string ;
             }

type server = { routes: route list }

let create_server () = { routes = [] }

let not_found req res =
  res
  |> Http.Response.set_status 404
  |> Http.Response.send_string
    (Printf.sprintf "Unknown path %s" (Http.Request.req_path req))

let rec route routes req res =
  match routes with
  | [] -> not_found req res
  | item :: rest -> begin
      if item.meth = Http.Request.req_method req then
        match Router.match_pattern item.pattern (Http.Request.req_path req) with
        | None -> route rest req res
        | Some params -> Http.Response.send_string (item.handler params) res
      else
        not_found req res
    end

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

let listen port server =
  Http.create_server
    port
    (fun req res -> route (List.rev server.routes) req res)
