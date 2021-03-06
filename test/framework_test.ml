open Framework

let mock_response handlers request_line =
  let server =
    List.fold_left
      (fun acc handler -> handler acc)
      (create_server ())
      handlers in
  let req = Http.Request.request_of_line request_line in
  let mock_res =
    Http.Response.response_of_socket
      (Unix.socket Unix.PF_INET Unix.SOCK_STREAM 0) in

  route server req mock_res

let go () =
  assert(
    mock_response
      [get "/" (fun _ -> respond "Hello, world!")]
      "GET / HTTP/1.1"
    |> Http.Response.response_body
       = "Hello, world!"
  );

  assert(
    mock_response
      [
        get "/jordan" (fun _ -> respond "Hey it's jordan!") ;
        get "/:name" (fun req -> "Hello, " ^ (param req "name") ^ "!" |> respond) ;
      ]
      "GET /jordan HTTP/1.1"
    |> Http.Response.response_body
       = "Hey it's jordan!"
  );

  assert(
    mock_response
      [
        get "/jordan" (fun _ -> respond "Hey it's jordan!") ;
        get "/:name" (fun req -> "Hello, " ^ (param req "name") ^ "!" |> respond) ;
      ]
      "GET /alex HTTP/1.1"
    |> Http.Response.response_body
       = "Hello, alex!"
  );

  assert(
    mock_response
      [
        get "/" (fun _ -> respond "This is the index page") ;
        get "/:name" (fun req -> "Hello, " ^ (param req "name") ^ "!" |> respond) ;
      ]
      "GET /alex/profile /HTTP/1.1"
    |> Http.Response.response_status
       = 404
  );
