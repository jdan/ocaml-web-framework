module RequestBuffer = struct
  let buffer_length = 1024

  (* https://stackoverflow.com/a/8373836/712889 *)
  let index_string s1 s2 =
    let re = Str.regexp_string s2
    in
    try Str.search_forward re s1 0
    with Not_found -> -1

  let rec recv_until socket buffer needle =
    (* TODO: We don't need to check the entire buffer, just
       the characters we've added to the buffer *)
    let index = index_string buffer needle in
    if index > -1 then
      (* TODO: String.split_in_two *)
      let str = String.sub buffer 0 index in
      let remaining_buffer =
        let start_index = index + (String.length needle) in
        String.sub buffer start_index ((String.length buffer) - start_index)

      in (str, remaining_buffer)
    else
      let in_bytes = Bytes.create buffer_length in
      match (Unix.recv socket in_bytes 0 buffer_length []) with
      | 0 -> ("", buffer)
      | length ->
        recv_until
          socket
          (buffer ^ (String.sub in_bytes 0 length))
          needle

  let recv_line socket buffer =
    recv_until socket buffer "\r\n"
end

module Request = struct
  type request_line = { meth: string ;
                        path: string ;
                        version: string ;
                      }
  type request = { line: request_line ;
                   headers: (string, string) Hashtbl.t ;
                 }

  let req_method req = req.line.meth
  let req_path req = req.line.path

  let line_of_string line =
    match (String.split_on_char ' ' line) with
    | [meth ; path ; version] ->
      { meth = meth ;
        path = path ;
        version = version ;
      }
    | _ -> raise (Invalid_argument ("Invalid request line: " ^ line))

  let request_of_line line = { line = line_of_string line ;
                               headers = Hashtbl.create 10 ;
                             }

  let recv_request_line socket =
    let (line, buffer) = RequestBuffer.recv_line socket "" in
    (line_of_string line, buffer)

  let recv_request_headers socket buffer =
    let headers = Hashtbl.create 10 in
    let rec inner buffer =
      let (line, new_buffer) = RequestBuffer.recv_line socket buffer in
      if line = "" then headers
      else
        match (Str.split_delim (Str.regexp_string ": ") line) with
        | [key ; value] -> begin
            Hashtbl.add headers key value;
            inner new_buffer
          end
        | _ -> raise (Invalid_argument ("Invalid header: " ^ line))
    in
    inner buffer

  let recv_request socket =
    let (line, buffer) = recv_request_line socket in
    let headers = recv_request_headers socket buffer in
    { line = line ;
      headers = headers ;
    }
end

module Response = struct
  type response = { socket: Unix.file_descr ;
                    status: int ;
                    headers: (string, string) Hashtbl.t ;
                    body: string ;
                  }

  let response_body response = response.body

  let response_status response = response.status

  let response_of_socket socket =
    let headers = Hashtbl.create 10 in
    Hashtbl.add headers "X-Served-By" "OCamlNet";
    { socket = socket ;
      status = 200 ;
      headers = headers ;
      body = "" ;
    }

  let send_line res line =
    let with_return = line ^ "\r\n" in
    ignore (Unix.send res.socket with_return 0 (String.length with_return) [])

  let phrase_of_status_code = function
    | 200 -> "OK"
    | 404 -> "Not found"
    | _ -> "Unknown"

  let send_headers res =
    Hashtbl.iter
      (fun k v ->
         send_line res (Printf.sprintf "%s: %s" k v))
      res.headers

  let send res =
    send_line
      res
      (Printf.sprintf "HTTP/1.1 %d %s"
         res.status
         (phrase_of_status_code res.status));
    send_headers res;
    send_line res "";
    send_line res res.body

  let set_status status res =
    { res with status = status }

  let set_header k v res =
    Hashtbl.add res.headers k v;
    res

  let set_body body res =
    ignore (set_header "Content-Length" (string_of_int (String.length body)) res);
    { res with
      body = body ;
    }

  let send_string str res =
    send (set_body str res)

end

type handler = Request.request -> Response.response -> unit

let create_server port (handler: handler) =
  let max_connections = 8 in
  let my_addr = Unix.inet_addr_of_string "127.0.0.1" in
  let s_descr = Unix.socket Unix.PF_INET Unix.SOCK_STREAM 0 in

  Unix.setsockopt s_descr Unix.SO_REUSEADDR true;
  Unix.bind s_descr (Unix.ADDR_INET(my_addr, port));
  Unix.listen s_descr max_connections;

  while true do
    let (conn_socket, conn_addr) = Unix.accept s_descr in
    let req = Request.recv_request conn_socket in
    let res = Response.response_of_socket conn_socket in

    print_endline
      (Printf.sprintf "%s %s" (Request.req_method req) (Request.req_path req));
    handler req res
  done
