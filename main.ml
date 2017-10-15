open Framework;;

let () =
  create_server ()
  |> get "/" (fun _ req res -> Http.Response.send_string "index" res)
  |> get "/:name" (fun params req res ->
      Http.Response.send_string
        (Printf.sprintf "Hello, %s!" (List.assoc "name" params)) res)
  |> listen 1337
