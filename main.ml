open Framework

let () =
  create_server ()
  |> get "/" (fun _ -> "This is the index page.")
  |> get "/:name" (fun params ->
      (Printf.sprintf "Hello, %s!" (List.assoc "name" params)))
  |> listen 1337
