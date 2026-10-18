import host.ts.RenamePrefix
import host.load.tests.readtail.States
namespace Host.Ts.PrefixFrameTest

def readToken : Expr := .index (.id chars!"view") (.lit (.num chars!"0")) false

def pushToken (name : Name) : Stmt :=
  .expr (.call (.member (.id name) chars!"push" false) [.expr readToken] false)

/-- The actual uint32 FFI read feeds two caller arrays through the interpreter's
typed-array read and `Array.push`. The return lengths are discarded by statement frames. -/
def initialPair : List Nat × St Host.Mlx.Ffi.St :=
  let old := Host.Load.Tests.ReadTail.initialPair
  let buffer := match old.2.ctl with
    | .call _ _ (.ptr (.js b) _ :: _) => b
    | _ => 0
  let (emitted, s) := newArray old.2 [natV 17, natV 18]
  let (view, s) := s.allocObj (.typed .u32 buffer 0 1) (.obj (aTypedProtoOf .u32)) []
  let (f, s) := s.alloc (.cell (some (.obj old.1)))
  let (e, s) := s.alloc (.cell (some (.obj emitted)))
  let (v, s) := s.alloc (.cell (some (.obj view)))
  let env := [(chars!"forwarded", f), (chars!"emitted", e), (chars!"view", v)]
  ([old.1, emitted], { s with stack := [.s (.block [pushToken chars!"forwarded", pushToken chars!"emitted"] env)] })

def initial : Option (St Host.Mlx.Ffi.St) := some initialPair.2

set_option maxHeartbeats 0 in
host_stream P : Host.Mlx.Ffi.ffi, initial, (List.range 3).map SymE.var,
  (fun i => F64.ofNat (100 + i)), 10, 3

set_option maxRecDepth 1000000 in
host_stream_state P 0
set_option maxRecDepth 1000000 in
host_stream_state P 1
set_option maxRecDepth 1000000 in
host_stream_state P 2
set_option maxRecDepth 1000000 in
host_stream_state P 3

host_read_tail P 0, 3 keep 1
host_prefix_frames P 0, 3 arrays initialPair.1

set_option maxRecDepth 1000000 in
host_chunk_prefix_frames P 0
set_option maxRecDepth 1000000 in
host_chunk_prefix_frames P 1
set_option maxRecDepth 1000000 in
host_chunk_prefix_frames P 2

host_chain_prefix_frames P 0, 3

set_option maxRecDepth 1000000 in
theorem both_prefixes_grow (fw : List Val) (tail : List NumV) :
    (arrayOf Host.Mlx.Ffi.ffi (P.pfa3 fw tail) P.prefixAddresses[0]!).map Prod.snd = some (fw ++ [.num (.ref 0)]) ∧
    (arrayOf Host.Mlx.Ffi.ffi (P.pfa3 fw tail) P.prefixAddresses[1]!).map Prod.snd = some (fw ++ [.num (.ref 0)]) ∧
    (P.pfa3 fw tail).ffi.tokens = tail ∧
    (P.pfa3 fw tail).ctl = .halt (.normal .undef) := by
  exact ⟨rfl, rfl, rfl, rfl⟩

end Host.Ts.PrefixFrameTest
