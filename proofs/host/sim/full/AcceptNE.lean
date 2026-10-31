import host.sim.full.BridgeJs
import host.sim.dispatch.OkFill
import host.sim.template.FullOk

/-! # The acceptance of Neural Engine rows

A layer over the unchanged base, for chains whose bridge goes active. On top of `okCallFXD`'s calls it
accepts the first bridge calls before the first wrap (`okCallFOpI`), the first wrap with the template's
nodes present from 1 (`denseB1`, `okCallFW1`: `Ffi.init` starts the node counter at 1 and node 0 is
never created) and the calls the symbolic-shape layer completes with the bridge active (`okCallFAS`, whose
numeric premise `smallFN2B` adds `symAfterB`). The row count at variable 10 is bounded by `rowVB R`. -/

namespace Host.Ts.Sim.Full
open Host.Ts Host.Ts.Sim Host.Load.Layers

/-- Variable 10, a chain's row count, is at most `R`; the others as in `loopVB`. -/
def rowVB (R : Nat) : Nat → Nat := fun v => bif Nat.beq v 10 then R else 2 ^ 20

/-- The template's counter is positive and its nodes from 1 up to the counter are present, decided. -/
def denseB1 (x : NSt) : Bool :=
  Nat.ble 1 x.nnext && (List.range' 1 (x.nnext - 1)).all fun i => (x.nodes.get i).isSome

/-- A surface wrap: from the active bridge, or the first, a clean bridge and the nodes present from 1. -/
def okCallFW1 (P : LoadP) (x : FF.S) (name : Name) (args : List Arg) : Bool :=
  Host.Load.isMlx name && nameEq name Host.Mlx.FfiAne.payloadName && (Host.Mlx.Ffi.symOf name).isNone &&
    wrapOk P (mlxOf x) args && ((bridgeOf x).active || (bridgeClean (bridgeOf x) && denseB1 (mlxOf x)))

/-- A bridge call with the bridge inactive. -/
def okCallFOpI (P : LoadP) (x : FF.S) (name : Name) (args : List Arg) : Bool :=
  !(bridgeOf x).active && !Host.Load.isMlx name && !nameEq name chars!"mbane_program_create" &&
    (Host.Mlx.Ffi.symOf name).isNone && (bridgeOp name args).isSome && bridgeOpOk P name args

/-- A call the symbolic-shape layer completes, with the bridge active. -/
def okCallFAS (P : LoadP) (x : FF.S) (name : Name) (args : List Arg) : Bool :=
  (bridgeOf x).active && decide (P.NL = P.N0) && Host.Load.isMlx name &&
    !nameEq name Host.Mlx.FfiAne.payloadName && G.symShapeOk P (mlxOf x) name args &&
    obsOk (mlxOf x) name args && afterOk (bridgeOf x) (mlxOf x) name args

/-- **The accepted calls of a Neural Engine row.** -/
def okCallFN2 (P : LoadP) (x : FF.S) (name : Name) (args : List Arg) : Bool :=
  okCallFW1 P x name args || okCallFOpI P x name args ||
    bif (bridgeOf x).active then
      bif G.symPath (mlxOf x) name args then okCallFAS P x name args else okCallFA P x name args
    else okCallFS P x name args

/-- `okCallFN2` at a raise, as `okCallFXD`. -/
def okCallFND (P : LoadP) (x : FF.S) (name : Name) (args : List Arg) : Bool :=
  bif decide (P.NL = P.N0) then okCallFN2 (P.raise (mlxOf x).nnext) x name args else okCallFN2 P x name args

/-- The template's completed call has a result and the bridge classifies it. -/
@[irreducible] def symAfterB (S : SSrv) (x : FF.S) (name : Name) (args : List Arg) : Bool :=
  match interpS (loadCallSym (toLoad x) name args).run S with
  | some (some (l, _, _), _) => (Host.Mlx.FfiAne.after (bridgeOf x) (mlxOf x) l.mlx name args).isSome
  | some (none, _) => false
  | none => true

/-- **The numeric premise's decider of a Neural Engine row.** -/
@[irreducible] def smallFN2B (VB : Nat → Nat) (S : SSrv) (x : FF.S) (name : Name) (args : List Arg) : Bool :=
  bif (bridgeOf x).active && G.symPath (mlxOf x) name args then
    G.symShapeSmallB VB S (mlxOf x) name args && symAfterB S x name args
  else smallFX2B VB S x name args

/-- The acceptance parameters of a Neural Engine row. -/
abbrev fullJSPXN (P : LoadP) (VB : Nat → Nat) (framed : List Nat) (wide : List (Nat × WFrame) := []) : Disp.JSP FF :=
  { okCall := okCallFND P, smallB := smallFN2B VB, lo := P.lo, hi := P.E, framed := framed,
    isHandle := fullIsHandle, isRegion := fullIsRegion, wide := wide, smallBackB := smallBackFB VB }

end Host.Ts.Sim.Full

namespace Host.Ts.Sim.Template
open Host.Ts Host.Ts.Sim

/-- A Neural Engine row's acceptance parameters at load parameters `P`, the row count at most `R`. -/
abbrev fullJSPPN (P : LoadP) (R : Nat) (framed : List Nat) (wide : List (Nat × WFrame)) : Disp.JSP Host.Load.Layers.full :=
  Full.fullJSPXN P (Full.rowVB R) framed wide

end Host.Ts.Sim.Template
