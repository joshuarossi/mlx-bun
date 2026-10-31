import host.sim.template.Chain
import host.sim.template.FullWorld
import host.load.run.prompt.H88
set_option Elab.async false
namespace Host.Load.Run.Tpl

/-! Scratch (track A4, Phase B): the prompt route's decode cut at iteration 1's readback call (`itemUint32`, the second
call) for a 1-token prompt, full world: the state the decode template (`specs/prompt.json`) is cut from. -/

set_option maxRecDepth 1000000 in
set_option maxHeartbeats 0 in
tpl_chain DK0 from Host.Load.Run.Prompt.P.a2818, Host.Load.Run.Prompt.P.S2818 : "{\"skipTo\": {\"fn\": \"itemUint32\", \"count\": 3}, \"stop\": \"steps:0\", \"frames\": []}" (world := full, arg := ((List.replicate 1 9707).map Host.Ts.natV))

set_option maxRecDepth 1000000 in
host_stream_state DK0 0

set_option maxHeartbeats 0 in
open Lean Elab Command Meta Host.Ts Host.Ts.Sim Host.Ts.Sim.Template in
/-- The KV buffers' handles and shapes at the cut (the spec's capacity places). -/
elab "dk0_probe" : command => liftTermElabM do
  astTabRef.set (← loadAstTab)
  let (s, c, _) ← unsafe restoreAny (S := Host.Load.Layers.full.S) (mkConst `Host.Load.Run.Tpl.DK0.s0)
    (mkConst `Host.Load.Run.Tpl.DK0.S0) `Host.Load.Run.Tpl.DK0P
  let l := fullWorld.proj s
  let m := l.aux.ffi.mlx
  let mut out : Array String := #[s!"ctl {match l.ctl with | .call (.obj a) _ _ => (fnNameOf l a).getD s!"#{a}" | _ => "?"}, depth {l.stack.length}, next {l.next}, mlx next {m.next} nnext {m.nnext}, table {c.tab.length}, tokens {m.tokens.length}"]
  let objOf (a : Nat) : Option Obj := match l.heap.get a with | some (.obj o) => some o | _ => none
  let handleOf (a : Nat) : Option Nat := (objOf a).bind fun o => o.priv.findSome? fun ((_, n), p) => match p with
    | .data (.big h) _ _ => if n == chars!"handle" then some h.toNat else none
    | _ => none
  if let some lst := objOf 2672295 then
    if let .array es := lst.kind then
      for (e, i) in es.zipIdx do
        if let .obj a := e then
          if let some o := objOf a then
            let props := o.props.filterMap fun (k, p) => match k, p with
              | .str n, .data (.obj b) _ _ => some (String.ofList n, b)
              | _, _ => none
            for (n, b) in props do
              if let some h := handleOf b then
                let sh := (m.arrs.get h).bind m.nodes.get |>.map fun nd => nd.shape.map fun d => match d with | .lit k => toString k | .sym _ => "sym"
                out := out.push s!"layer {i} h{a}.{n} h{b} H{h} {sh}"
  IO.FS.writeFile "/tmp/a4/dk0.txt" ("\n".intercalate out.toList ++ "\n")

set_option maxHeartbeats 0 in
dk0_probe

end Host.Load.Run.Tpl
