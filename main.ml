(* https://stackoverflow.com/a/8373836/712889 *)
let index_string s1 s2 =
  let re = Str.regexp_string s2
  in
  try Str.search_forward re s1 0
  with Not_found -> -1

module RequestBuffer = struct
  let buffer_length = 1024

  let rec recv_until socket buffer needle =
    (* TODO: We don't need to check the entire buffer, just
       the characters we've added to the buffer *)
    let index = index_string buffer needle in
    if index > -1 then
      (* TODO: String.split_in_two *)
      (
        String.sub buffer 0 index,

        let start_index = index + (String.length needle) in
        String.sub buffer start_index ((String.length buffer) - start_index)
      )
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

type request_line = { meth: string ;
                      path: string ;
                      version: string ;
                    }
type request = { line: request_line ;
                 headers: (string, string) Hashtbl.t ;
               }

let recv_request_line socket =
  let (line, buffer) = RequestBuffer.recv_line socket "" in
  match (String.split_on_char ' ' line) with
  | [meth ; path ; version] -> (
      { meth = meth ;
        path = path ;
        version = version ;
      },
      buffer)
  | _ -> raise (Invalid_argument ("Invalid request line: " ^ line))

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

let () =
  let max_connections = 8 in
  let port = 1337 in
  let my_addr = Unix.inet_addr_of_string "127.0.0.1" in
  let s_descr = Unix.socket Unix.PF_INET Unix.SOCK_STREAM 0 in

  Unix.setsockopt s_descr Unix.SO_REUSEADDR true;
  Unix.bind s_descr (Unix.ADDR_INET(my_addr, port));
  Unix.listen s_descr max_connections;

  (* loop dis *)
  let (conn_socket, conn_addr) = Unix.accept s_descr in

  let req = recv_request conn_socket in
  print_endline (req.line.meth ^ " " ^ req.line.path);
  Hashtbl.iter (fun k v -> (print_endline (k ^ " -> " ^ v))) req.headers;
