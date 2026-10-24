import host.sim.template.Split
import host.sim.dispatch.BridgeNewData
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

/-! # The route's bridge points (seg.json v2)

`routeBridges P` (`tpl_case_split … bridging (routeBridges P)`) finds the bridge points of the
bridge lemmas (`host.sim.dispatch.Bridge*`) at a state of the load world's projection, given the
addresses framed so far, and gives each its patched template:

* `spread` (`Disp.BridgeSpread`): a framed array returned into the last spread of an array
  literal; the state's own step, its new array framed;
* `len` (`Disp.bridge_len`): a framed array received by a `length` member frame; patched to the
  fresh table entry `P.lens a` (the target length) (`lenPatch`);
* `slice` (`Disp.bridge_slice`): `Array.prototype.slice` called on a framed array; patched to an
  empty array, framed (`slicePatch`);
* `typed` (`Disp.bridge_typed`): `new Int32Array(chunk)` of a framed chunk; patched to two
  placeholders, both framed (`typedPatch`, `Disp.typedSP`);
* `ptr` (`Disp.bridge_ptr`): `ptr(view)` of a typed placeholder; patched to the pointer into its
  buffer placeholder (`ptrPatch`);
* `newdata` (`Disp.bridge_newdata`): a `dlopen` symbol called with a pointer into a framed buffer
  placeholder first; the patched step `Disp.newDataS` with bytes `P.bsT` (`newdataPatch`), run in
  the case's world;
* `size` (`Full.fullBridgeSize`): the `mlx_array_size` call of `MlxArray.size` (`Number(C.mlx_array_size(h))`,
  array.ts:238) with `Number`'s argument frame on top (`Disp.sizeParts`), of an array whose shape is symbolic;
  the patched transition `Disp.sizeS` (the native call, `Number`'s argument frame, `Number`: three steps).

The generated modules state each patch (`<X>.patchB<k>`) and the lemma's hypotheses at the bridge
state (`bridgeFacts.ts`) by kernel evaluation of the functions below. Nothing here is trusted. -/

namespace Host.Ts.Sim.Template.Bridge
open Host.Ts Host.Ts.Sim

/-! ## The patched templates -/

/-- B-len: the member frame popped, the fresh reference `Sv.tab.length` with entry `e` returned. -/
def lenPatch {S : Type} (s : St S) (Sv : SSrv) (e : SymE) : St S × SSrv :=
  ({ s with stack := s.stack.tail }.ret (.num (.ref Sv.tab.length)), { Sv with tab := Sv.tab ++ [e] })

/-- B-slice: an empty array. -/
def slicePatch {S : Type} (s : St S) (Sv : SSrv) : St S × SSrv :=
  ((newArray s []).2.ret (.obj (newArray s []).1), Sv)

/-- B-typed: the two placeholders (`Disp.typedSP`). -/
def typedPatch (F : Ffi) (s : St F.S) (Sv : SSrv) (proto : Nat) : St F.S × SSrv := (Disp.typedSP F s proto, Sv)

/-- B-ptr: the pointer into the buffer placeholder `b` at offset `off`. -/
def ptrPatch {S : Type} (s : St S) (Sv : SSrv) (b off : Nat) : St S × SSrv := (s.ret (.ptr (.js b) off), Sv)

/-- B-newdata: the patched step `Disp.newDataS` with the template's bytes `bsT`. -/
def newdataPatch (F : Ffi) (s : St F.S) (Sv : SSrv) (bsT : List Byte) : Option (St F.S × SSrv) :=
  match ndParts s with
  | some (name, rt, tys, rest, b) => interpS (Disp.newDataS F s name rt tys rest b bsT).run Sv
  | none => none

/-! ## The bridge states -/

/-- The top frame is a `length` member read. -/
def isLenFrame : List Frame → Bool
  | .e (.member k _) :: _ => keyEq k kLength
  | _ => false

/-- The callee of a call state, when it is a function object. -/
def calleeKind {S : Type} (s : St S) (f : Val) : Option Kind :=
  match f with
  | .obj fa => (s.obj? fa).map (·.kind)
  | _ => none

/-- `Array.prototype.slice` called on `a`. -/
def isSliceOf {S : Type} (s : St S) (a : Nat) : Bool :=
  match s.ctl with
  | .call f (.obj a') _ => Nat.beq a' a && (match calleeKind s f with
    | some (.fn (.native (.arr .slice) _)) => true
    | _ => false)
  | _ => false

/-- `new Int32Array(…)`: the typed array's prototype. -/
def typedProto {S : Type} (s : St S) : Option Nat :=
  match s.ctl with
  | .construct f _ _ => match calleeKind s f with
    | some (.fn (.native (.buf .typedCtor) [.num (.lit cF), .num (.lit pF)])) =>
      if F64.toIndex? cF == some 4 then F64.toIndex? pF else none
    | _ => none
  | _ => none

/-- `ptr(view)`: the view. -/
def ptrView {S : Type} (s : St S) : Option Nat :=
  match s.ctl with
  | .call f _ args => match calleeKind s f, Host.Ts.arg args 0 with
    | some (.fn (.native (.ffi .ptr) _)), .obj ta => some ta
    | _, _ => none
  | _ => none

/-- The `dlopen` symbol a call state calls. -/
def symCallName {S : Type} (s : St S) : Option Name :=
  match s.ctl with
  | .call (.obj fsym) _ _ => match s.obj? fsym with
    | some fo => match fo.kind with
      | .fn (.native (.ffi .symbol) (.str name :: _)) => some name
      | _ => none
    | none => none
  | _ => none

/-- B-size's call has `Number`'s argument frame on top and its array's shape is symbolic (over a concrete
shape the template's and the target's returns agree and the call is an ordinary step). -/
def sizeSym (s : St Host.Load.LSt) : Bool :=
  match Disp.sizeParts s with
  | some (_, _, _, _, _, _, [.big h]) => match s.aux.ffi.mlx.arrs.get h.toNat with
    | some n => match s.aux.ffi.mlx.nodes.get n with
      | some nd => nd.shape.any fun d => match d with | .sym _ => true | _ => false
      | none => false
    | none => false
  | _ => false

/-- The parameters of the route's bridges: the kinds to look for, B-len's table entry per framed
array (the target's length at the valuation), B-newdata's template bytes. -/
structure RouteB where
  kinds : List String := ["spread", "len", "slice", "typed", "ptr", "newdata", "size"]
  lens : List (Nat × SymE) := []
  bsT : List Byte := []

def symJ : SymE → String
  | .var v => s!".var {v}"
  | e => s!"({fmtSym e})"

/-- The bridge points at `s` (its server `Sv`), with the addresses `frames` framed so far. -/
def routeBridges (P : RouteB) (frames : List Nat) (s : St Host.Load.LSt) (Sv : SSrv) : Option BridgeHit :=
  let on (k : String) := P.kinds.contains k
  if on "size" && symCallName s == some chars!"mlx_array_size" && sizeSym s then
    match Disp.sizeParts s with
    | some (fsym, ta, nf, name, rt, _, _) =>
      some { kind := "size", size := true, extra := [("fsym", Lean.toJson fsym), ("ta", Lean.toJson ta),
        ("nf", Lean.toJson nf), ("name", Lean.toJson (String.ofList name)), ("rt", Lean.toJson (String.ofList rt))] }
    | none => none
  else
  match s.ctl, s.stack with
  | .ret (.obj a), .l (.spread _ [] _) :: _ =>
    if on "spread" && frames.contains a then some { kind := "spread" } else none
  | .ret (.obj a), stk =>
    if on "len" && isLenFrame stk && frames.contains a then
      match P.lens.find? (·.1 == a) with
      | some (_, e) => some { kind := "len", patch := some (let (t, Sv') := lenPatch s Sv e; (t, Sv'.tab.drop Sv.tab.length)),
                              extra := [("entry", Lean.toJson (symJ e))] }
      | none => none
    else none
  | .call _ (.obj a) _, _ =>
    if on "slice" && frames.contains a && isSliceOf s a then
      some { kind := "slice", patch := some ((slicePatch s Sv).1, []), frames := [s.next],
             extra := [("frames", Lean.toJson [s.next])] }
    else if on "newdata" then
      match ndParts s with
      | some (_, _, _, _, b) => if frames.contains b then some { kind := "newdata", ndBytes := some P.bsT, extra := [("buf", Lean.toJson b)] } else none
      | none => none
    else none
  | .construct _ args _, _ =>
    match typedProto s, Host.Ts.arg args 0 with
    | some proto, .obj ch =>
      if on "typed" && frames.contains ch then
        some { kind := "typed", patch := some ((typedPatch Host.Load.ffi s Sv proto).1, []), frames := [s.next, s.next + 1],
               extra := [("proto", Lean.toJson proto), ("buf", Lean.toJson s.next), ("frames", Lean.toJson [s.next, s.next + 1])] }
      else none
    | _, _ => none
  | .call _ _ _, _ =>
    match ptrView s with
    | some ta =>
      if on "ptr" && frames.contains ta && frames.contains (ta - 1) then
        some { kind := "ptr", patch := some ((ptrPatch s Sv (ta - 1) 0).1, []),
               extra := [("buf", Lean.toJson (ta - 1)), ("off", Lean.toJson (0 : Nat))] }
      else if on "newdata" then
        match ndParts s with
        | some (_, _, _, _, b) => if frames.contains b then some { kind := "newdata", ndBytes := some P.bsT, extra := [("buf", Lean.toJson b)] } else none
        | none => none
      else none
    | none =>
      if on "newdata" then
        match ndParts s with
        | some (_, _, _, _, b) => if frames.contains b then some { kind := "newdata", ndBytes := some P.bsT, extra := [("buf", Lean.toJson b)] } else none
        | none => none
      else none
  | _, _ => none

end Host.Ts.Sim.Template.Bridge

namespace Host.Ts.Sim.Template

/-- A call of the closure at `a` (at depth `d`, when given): a kernel evaluation, where `isCallOf`'s `#<address>` form
parses the address with `String.toNat?`. -/
def isCallAtB {S : Type} (s : St S) (a : Nat) (d : Option Nat) : Bool :=
  match s.ctl with
  | .call (.obj b) _ _ => Nat.beq b a && d.all (· == s.stack.length)
  | _ => false

end Host.Ts.Sim.Template
