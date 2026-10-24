import host.sim.template.Walk
import host.load.Stream
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

/-! # The world a template command runs in

A template command (`host.sim.template.Build`, `Split`, `RestartCmd`, `Stage`, `Chain`)
runs the machine of one world `TWorld F` over the FFI `F`: the serializer of its native
state, the load world's state inside it (`toLoad`, `setLoad`: collection, symbolization
and the lockstep walks work on that projection, `TWorld.proj`), the lift of a load-world
state into it (`ofLoad`, for a template of this world cut from a load-world run), and, for
the native state beyond the load world's: the nodes it names (kept by collection), its
restriction to the kept handles and nodes, and its lockstep walk under the walk's maps.

`lfWorld` is the load world (`Host.Load.ffi`); every function is the identity, so the
commands behave exactly as before the world was a parameter. The full stack
(`Host.Load.Layers.full`) is `host.sim.template.FullWorld`. Nothing here is trusted: the
commands choose states, and every use of them is a kernel check. -/

namespace Host.Ts.Sim.Template
open Lean Meta Host.Ts Host.Load

structure TWorld (F : Ffi) where
  /-- The name the commands' `world` clause uses (`lf`, `full`). -/
  name : String
  /-- The constant `F` is (generated modules state their runs over it). -/
  ffiC : Lean.Name
  /-- The type expression of `F.S` (the serialized states' `St` parameter). -/
  tyS : Lean.Expr
  ser : F.S → Stream.GenM Lean.Expr
  toLoad : F.S → LSt
  setLoad : F.S → LSt → F.S
  /-- The native state of a template of this world cut from a load-world state. -/
  ofLoad : St LSt → F.S
  /-- Native nodes the state beyond the load world's names. -/
  extraNodes : F.S → List Nat
  /-- The state beyond the load world's, restricted to kept handles and nodes. -/
  restrict : F.S → (Nat → Bool) → (Nat → Bool) → F.S
  /-- The state beyond the load world's with its handle and node keys renamed (`none`: dropped), for a
  compaction (`tpl_chain`). -/
  renameExtra : F.S → (Nat → Option Nat) → (Nat → Option Nat) → F.S
  /-- The lockstep walk of the state beyond the load world's, after the main walk
  (`Ctx.s1`/`Ctx.s2` are the projections; the arguments the two native states). -/
  walkExtra : F.S → F.S → WM Unit
  /-- A one-line summary of the state beyond the load world's (command logs). -/
  describe : F.S → String
  /-- The module and constant of the generated modules' default acceptance function. -/
  okModule : String
  okName : String

namespace TWorld
variable {F : Ffi} (w : TWorld F)

/-- The machine state with the load world's native state. -/
def proj (s : St F.S) : St LSt :=
  ⟨s.heap, s.next, s.ctl, s.stack, ⟨s.aux.jobs, w.toLoad s.aux.ffi, s.aux.trace, s.aux.stores⟩⟩

/-- `s` with the JavaScript side and the load world's state of `l`. -/
def unproj (s : St F.S) (l : St LSt) : St F.S :=
  ⟨l.heap, l.next, l.ctl, l.stack, ⟨l.aux.jobs, w.setLoad s.aux.ffi l.aux.ffi, l.aux.trace, l.aux.stores⟩⟩

/-- A load-world state in this world (`ofLoad`), the JavaScript side unchanged. -/
def lift (s : St LSt) : St F.S :=
  ⟨s.heap, s.next, s.ctl, s.stack, ⟨s.aux.jobs, w.ofLoad s, s.aux.trace, s.aux.stores⟩⟩

/-- `St F.S` as an expression. -/
def stTy : Lean.Expr := mkApp (mkConst ``St) w.tyS

end TWorld

/-- The load world. -/
def lfWorld : TWorld Host.Load.ffi where
  name := "lf"
  ffiC := ``Host.Load.ffi
  tyS := mkConst ``LSt
  ser := fun x => Stream.StreamExpr.ser (α := LSt) x
  toLoad := fun x => x
  setLoad := fun _ l => l
  ofLoad := fun s => s.aux.ffi
  extraNodes := fun _ => []
  restrict := fun x _ _ => x
  renameExtra := fun x _ _ => x
  walkExtra := fun _ _ => pure ()
  describe := fun _ => ""
  okModule := "host.sim.template.ok.Ok"
  okName := "ok"

end Host.Ts.Sim.Template
