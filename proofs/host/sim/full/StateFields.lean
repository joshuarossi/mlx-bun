import host.sim.full.DropTokens
import Lean

/-! # Field views of stored full-world states

A stored state's FFI is a literal product whose bridge may be the thunk `Boot.replay log`. Comparing
two states through projections makes the kernel compare whole structures first, and that replays
the bridge. `state_fields V from s` names the load, bridge, liveness and kernel-record terms of the
stored constructor as abbreviations and proves `s.ffi` equal to their product, so each field is then
compared on its own and the bridge by its checked lemma. -/

namespace Host.Ts.Sim.Full
open Host.Ts Host.Load.Layers

/-- A start state with the old state's non-FFI fields, its token queue replaced, and the other FFI
fields equal, is that old state with its tokens replaced. -/
theorem start_of_fields {a b : St FF.S} {ts : List NumV} {la lb : Host.Load.LSt}
    {ba bb : Host.Mlx.FfiAne.St} {va vb : Option _} {ka kb : Option _}
    (ha : a.ffi = ((⟨la, ba⟩, va), ka)) (hb : b.ffi = ((⟨lb, bb⟩, vb), kb))
    (hrest : a.setFfi b.ffi = b)
    (hl : la = { lb with mlx := { lb.mlx with tokens := ts } })
    (hbr : ba = bb) (hv : va = vb) (hk : ka = kb) :
    a = b.setFfi (fullSetTokens b.ffi ts) := by
  subst hl hbr hv hk
  have hf : a.ffi = fullSetTokens b.ffi ts := by rw [ha, hb]; rfl
  rw [← hf, ← hrest]
  cases a
  rfl

end Host.Ts.Sim.Full

namespace Host.Ts.Sim.Template
open Lean Elab Command Meta

private def fieldCtor (e : Lean.Expr) (ctor : Lean.Name) (arity : Nat) : MetaM Lean.Expr := do
  let mut e := e
  for _ in [0:32] do
    e := e.headBeta
    match e with
    | .mdata _ b => e := b
    | _ =>
      if e.isAppOfArity ctor arity then return e
      let .const n us := e.getAppFn | throwError "state_fields: expected {ctor}, got {e.getAppFn}"
      let ci ← getConstInfo n
      let some v := ci.value? | throwError "state_fields: no body for {n}"
      e := mkAppN (v.instantiateLevelParams ci.levelParams us) e.getAppArgs
  throwError "state_fields: alias bound exceeded"

/-- `V.load`, `V.bridge`, `V.live`, `V.krec` and `V.ffi_eq : s.ffi = ((⟨V.load, V.bridge⟩, V.live), V.krec)`.
The abbreviation hints make the kernel unfold the view rather than a bridge thunk. -/
elab "state_fields " dest:ident " from " src:ident : command => liftTermElabM do
  let raw := mkConst (← realizeGlobalConstNoOverloadWithInfo src)
  let some body := (← getConstInfo raw.constName!).value? | throwError "state_fields: no data body"
  let st ← fieldCtor body ``Host.Ts.St.mk 6
  let aux ← fieldCtor st.getAppArgs[5]! ``Host.Ts.Aux.mk 5
  let outer ← fieldCtor aux.getAppArgs[2]! ``Prod.mk 4
  let inner ← fieldCtor outer.getAppArgs[2]! ``Prod.mk 4
  let ane ← fieldCtor inner.getAppArgs[2]! ``Host.Load.Ane.ASt.mk 2
  let pre := (← getCurrNamespace) ++ dest.getId
  let define (s : Lean.Name) (ty v : Lean.Expr) : MetaM Lean.Expr := do
    let n := pre ++ s
    addDecl (.defnDecl (mkDefinitionValEx n [] ty v .abbrev .safe [n]))
    return mkConst n
  let load ← define `load (mkConst ``Host.Load.LSt) ane.getAppArgs[0]!
  let bridge ← define `bridge (mkConst ``Host.Mlx.FfiAne.St) ane.getAppArgs[1]!
  let live ← define `live inner.getAppArgs[1]! inner.getAppArgs[3]!
  let krec ← define `krec outer.getAppArgs[1]! outer.getAppArgs[3]!
  let ane' := mkApp2 ane.getAppFn load bridge
  let inner' := mkApp4 inner.getAppFn inner.getAppArgs[0]! inner.getAppArgs[1]! ane' live
  let outer' := mkApp4 outer.getAppFn outer.getAppArgs[0]! outer.getAppArgs[1]! inner' krec
  let ffi ← mkAppM ``Host.Ts.St.ffi #[raw]
  addDecl (.thmDecl { name := pre ++ `ffi_eq, levelParams := [], type := ← mkEq ffi outer', value := ← mkEqRefl ffi })

end Host.Ts.Sim.Template
