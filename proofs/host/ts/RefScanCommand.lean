import host.ts.RefScanElide
import host.ts.Memo
import host.ts.DecodeExpr

namespace Host.Ts.RefScan
open Lean Elab Command Meta

instance (priority := 20001) instToExprItemNamed : ToExpr Item :=
  ⟨serNamed serItem, mkConst ``Item⟩

deriving instance Lean.ToExpr for Task
deriving instance Lean.ToExpr for State

theorem checked_trans {a b c : State} {m n : Nat}
    (first : run m a = b) (second : run n b = c) : run (m+n) a = c := by
  rw [run_add, first, second]

private def scanName (pre : Lean.Name) (tag : String) (i : Nat) : Lean.Name :=
  pre ++ Name.mkSimple s!"{tag}{i}"

private def addScanDefinition (name : Lean.Name) (type value : Lean.Expr) : TermElabM Unit :=
  addDecl (.defnDecl { name, levelParams := [], type, value, hints := .regular 0, safety := .safe })

private def addScanProof (name : Lean.Name) (type value : Lean.Expr) : TermElabM Unit :=
  addDecl (.thmDecl { name, levelParams := [], type, value })

private unsafe def restoreModule (expr : Lean.Expr) : TermElabM (Module × Nat) := do
  let (value, cache) ← (ConstructorDecode.decode expr).run {}
  return (unsafeCast value, cache.values.size)

/-- Native code chooses only explicit task states. Each small transition and
each named prefix is checked by the ordinary kernel; `completed` then proves
the result for the original mutual reference scanner. -/
elab "ref_scan_checked " p:ident " : " source:term ", " width:num : command =>
  liftTermElabM <| withOptions (fun o => o.setBool `Elab.async false) do
    let width := width.getNat
    if width == 0 then throwError "ref_scan_checked: width must be positive"
    let pre := (← getCurrNamespace) ++ p.getId
    let moduleTy := mkApp (mkConst ``List [.zero]) (mkConst ``Item)
    let module ← instantiateMVars (← Term.elabTermAndSynthesize source (some moduleTy))
    astTabRef.set (← loadAstTab)
    Memo.reset
    let started ← IO.monoMsNow
    let (nativeModule, values) ← unsafe restoreModule module
    let restored ← IO.monoMsNow
    addScanDefinition (pre ++ `module) moduleTy module
    let stateTy := mkConst ``State
    let initialE := mkApp (mkConst ``initial) (mkConst (pre ++ `module))
    addScanDefinition (scanName pre "s" 0) stateTy initialE
    let firstState := mkConst (scanName pre "s" 0)
    let runE (n : Nat) (state : Lean.Expr) := mkApp2 (mkConst ``run) (mkRawNatLit n) state
    let mut state := initial nativeModule
    let mut previous := firstState
    let mut total := 0
    let mut count := 0
    let mut proof : Option Lean.Expr := none
    while !state.todo.isEmpty do
      if count >= 100000 then throwError "ref_scan_checked: candidate exceeded the chunk bound"
      state := run width state
      Memo.beginEpoch
      let nextName := scanName pre "s" (count+1)
      addScanDefinition nextName stateTy (toExpr state)
      let next := mkConst nextName
      let lhs := runE width previous
      let chunkName := scanName pre "c" count
      addScanProof chunkName (← mkEq lhs next) (← mkEqRefl lhs)
      let value := match proof with
        | none => mkConst chunkName
        | some prefixProof => mkAppN (mkConst ``checked_trans) #[firstState, previous, next,
            mkRawNatLit total, mkRawNatLit width, prefixProof, mkConst chunkName]
      total := total+width
      let prefixName := scanName pre "up" (count+1)
      addScanProof prefixName (← mkEq (runE total firstState) next) value
      proof := some (mkConst prefixName)
      previous := next
      count := count+1
    let value ← match proof with
      | some finalProof => pure finalProof
      | none => mkEqRefl (runE 0 firstState)
    addScanProof (pre ++ `run) (← mkEq (runE total initialE) previous) value
    let todo := mkApp (mkConst ``State.todo) previous
    let empty := mkApp (mkConst ``List.nil [.zero]) (mkConst ``Task)
    addScanProof (pre ++ `done) (← mkEq todo empty) (← mkEqRefl todo)
    let refs := mkApp (mkConst ``State.acc) previous
    addScanDefinition (pre ++ `refs) (mkApp (mkConst ``List [.zero]) (mkConst ``Nat)) refs
    let value := mkAppN (mkConst ``completed) #[mkConst (pre ++ `module), mkRawNatLit total,
      previous, mkConst (pre ++ `run), mkConst (pre ++ `done)]
    let lhs := mkApp (mkConst ``refsM) (mkConst (pre ++ `module))
    addScanProof (pre ++ `checked) (← mkEq lhs (mkConst (pre ++ `refs))) value
    Memo.reset
    logInfo m!"ref_scan_checked {pre}: {total} task steps, {count} checked chunks, {state.acc.length} references; restore {values} values in {restored-started} ms, total {(← IO.monoMsNow)-started} ms"

end Host.Ts.RefScan
