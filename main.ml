open Framework

let () =
  create_server ()
  |> get "/" (fun req -> respond "This is the index page.")
  |> get "/:name" (fun req ->
      Printf.sprintf "Hello, %s!" (param req "name") |> respond)
  |> listen 1337
