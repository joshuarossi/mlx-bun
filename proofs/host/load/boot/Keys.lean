import host.load.boot.States
set_option Elab.async false
namespace Host.Load.Boot
open Lean Elab Command Meta Host.Ts Host.Load Host.Load.Layers

/-! # The keys of the observer's states at `loadDone`

`boot_w_keys P k`: the handles the boot's object frees released before boundary `k`
(`P.obfrKeys`, oldest first) and the kernels' recorded flags (`P.obkrKeys`), read natively from the
trace of `P.a<k> []`; `P.obfr_keys`, `P.obkr_keys`: the boundary's freed set and kernel flags are
their insertions into the empty store (each checked by the kernel). -/

private def nm (pre : Lean.Name) (tag : String) (i : Nat) : Lean.Name :=
  pre ++ Lean.Name.mkSimple (tag ++ toString i)

private partial def charsOf (e : Lean.Expr) : MetaM (List Char) := do
  let e ← whnf e
  match e.getAppFn, e.getAppArgs with
  | .const ``List.nil _, _ => return []
  | .const ``List.cons _, #[_, h, t] =>
    let k ← whnf (mkApp (mkConst ``Char.toNat) h)
    let some n := k.rawNatLit? <|> k.nat? | throwError "boot_w_keys: not a character literal"
    return Char.ofNat n :: (← charsOf t)
  | _, _ => throwError "boot_w_keys: not a name literal"

private def natOf (e : Lean.Expr) : MetaM Nat := do
  let v ← whnf e
  let some n := v.rawNatLit? <|> v.nat? | throwError "boot_w_keys: not a number {v}"
  return n

private def optOf (e : Lean.Expr) : MetaM (Option Lean.Expr) := do
  let r ← whnf e
  if r.isAppOfArity ``Option.none 1 then return none
  unless r.isAppOfArity ``Option.some 2 do throwError "boot_w_keys: not an option {r}"
  return some r.appArg!

private partial def listE (e : Lean.Expr) : MetaM (Array Lean.Expr) := do
  let e ← whnf e
  match e.getAppFn, e.getAppArgs with
  | .const ``List.nil _, _ => return #[]
  | .const ``List.cons _, #[_, h, t] => return #[h] ++ (← listE t)
  | _, _ => throwError "boot_w_keys: not a list"

private def addDef (name : Lean.Name) (type value : Lean.Expr) : CoreM Unit :=
  addDecl (.defnDecl { name, levelParams := [], type, value, hints := .regular 0, safety := .safe })

private def addThm (name : Lean.Name) (type value : Lean.Expr) : CoreM Unit :=
  addDecl (.thmDecl { name, levelParams := [], type, value })

/-- Insert `keys` (with values) into the empty store, oldest first. -/
def insAll {α : Type} (keys : List (Nat × α)) : PTrie α := keys.foldl (fun t p => t.set p.1 p.2) PTrie.nil

elab "boot_w_keys " p:ident k:num : command => liftTermElabM <| withOptions (fun o => o.setBool `Elab.async false) do
  let pre := (← getCurrNamespace) ++ p.getId
  let st := mkApp (mkConst (nm pre "a" k.getNat)) (mkApp (mkConst ``List.nil [.zero]) (mkConst ``Val))
  let evs ← listE (← mkAppM ``St.trace #[st])
  let mut fr : Array Nat := #[]
  let mut kr : Array (Nat × Bool × Bool) := #[]
  for ev in evs.reverse do
    let ev ← whnf ev
    let sym ← charsOf (ev.getArg! 0)
    let args ← listE (ev.getArg! 1)
    match Host.Mlx.Ffi.symOf sym with
    | some x =>
      if args.size == 1 && isObjFree x then
        match ← optOf (mkApp (mkConst ``Host.Mlx.Ffi.argNat) args[0]!) with
        | some h => let h ← natOf h; if h != 0 then fr := fr.push h
        | none => throwError "boot_w_keys: a free of no handle"
      if x matches .kernelNew then
        let r ← whnf (ev.getArg! 2)
        unless r.isAppOfArity ``Ret.big 1 do throwError "boot_w_keys: kernel return"
        let h ← natOf (mkApp (mkConst ``Int.toNat) r.appArg!)
        let some rc ← optOf (mkApp (mkConst ``Host.Mlx.Ffi.argBool) args[5]!) | throwError "boot_w_keys: flag"
        let some ao ← optOf (mkApp (mkConst ``Host.Mlx.Ffi.argBool) args[6]!) | throwError "boot_w_keys: flag"
        let rc ← whnf rc
        let ao ← whnf ao
        kr := kr.push (h, rc.isConstOf ``Bool.true, ao.isConstOf ``Bool.true)
    | none => pure ()
  let unitTy := mkConst ``Unit
  let frE := toExpr (fr.toList.map fun h => (h, ()))
  let bb := mkApp2 (mkConst ``Prod [.zero, .zero]) (mkConst ``Bool) (mkConst ``Bool)
  let krE := toExpr (kr.toList.map fun (h, a, b) => (h, (a, b)))
  let frTy := mkApp (mkConst ``List [.zero]) (mkApp2 (mkConst ``Prod [.zero, .zero]) (mkConst ``Nat) unitTy)
  let krTy := mkApp (mkConst ``List [.zero]) (mkApp2 (mkConst ``Prod [.zero, .zero]) (mkConst ``Nat) bb)
  addDef (pre ++ `obfrKeys) frTy frE
  addDef (pre ++ `obkrKeys) krTy krE
  let lhsF := mkConst (nm pre "obfr" k.getNat)
  let rhsF := mkApp2 (mkConst ``insAll) unitTy (mkConst (pre ++ `obfrKeys))
  let tyF ← mkEq lhsF rhsF
  addThm (pre ++ `obfr_keys) tyF (Run.Tail.eagerRefl (.succ .zero) (mkApp (mkConst ``PTrie) unitTy) lhsF rhsF)
  let lhsK ← mkAppM ``KRec.flags #[mkConst (nm pre "obkr" k.getNat)]
  let rhsK := mkApp2 (mkConst ``insAll) bb (mkConst (pre ++ `obkrKeys))
  addThm (pre ++ `obkr_keys) (← mkEq lhsK rhsK) (Run.Tail.eagerRefl (.succ .zero) (mkApp (mkConst ``PTrie) bb) lhsK rhsK)
  let lhsT ← mkAppM ``KRec.targs #[mkConst (nm pre "obkr" k.getNat)]
  let rhsT := mkApp (mkConst ``PTrie.nil) (mkApp (mkConst ``List [.zero]) (mkApp2 (mkConst ``Prod [.zero, .zero])
    (mkApp (mkConst ``List [.zero]) (mkConst ``Char)) (mkConst ``TArg)))
  addThm (pre ++ `obkr_targs) (← mkEq lhsT rhsT) (Run.Tail.eagerRefl (.succ .zero) (← inferType rhsT) lhsT rhsT)
  logInfo m!"boot_w_keys: {fr.size} released handles, {kr.size} kernels {kr.toList}"

end Host.Load.Boot

namespace Host.Load.Run.Prompt

set_option maxRecDepth 1000000 in
boot_w_keys P 2818

end Host.Load.Run.Prompt
