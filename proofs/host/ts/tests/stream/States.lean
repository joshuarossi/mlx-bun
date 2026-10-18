import host.ts.Stream
namespace Host.Ts.Tests.Stream
open Host.Ts

def source : String := r#"
export let out = null;
const forwarded = [17, 18];
const m = new Map();
m.set("first", 1);
m.set("second", 2);
m.set("first", 3);
m.delete("second");
m.set("second", 4);
const names = ["z", "aa", "a", "aa"];
names.sort();
out = [m.get("first"), m.get("second"), m.size, names.join(","), [...m.keys()].join(",")];
"#
source_parse source
source_ast

def initial : Option (St Unit) := boot () [⟨chars!"main.ts", ast⟩] [] chars!"main.ts"
set_option maxHeartbeats 0 in
host_stream P : nullFfi, initial, [], (fun _ => F64.ofNat 0), 0, 0 chunks [1000, 200, 800, 1000] abs 1, 2, "forwarded"
end Host.Ts.Tests.Stream
