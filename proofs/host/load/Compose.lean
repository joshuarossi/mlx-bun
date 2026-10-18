import host.ts.Chunk

namespace Host.Ts
open Lean Elab Command Meta

/-- Compose an existing checked chain through separately checked prefix
theorems. Each prefix uses the preceding theorem by name, so checking the
last prefix does not revisit a growing nested proof term. No states are
chosen and no execution is evaluated by this command. -/
elab "host_chain_run_staged " p:ident : command =>
  liftTermElabM <| withOptions (fun o => o.setBool `Elab.async false) do
    let pre := (← getCurrNamespace) ++ p.getId
    let ks ← unsafe evalConst (List Nat) (pre ++ `ks)
    if ks.isEmpty then throwError "host_chain_run_staged: empty chain"
    let name (tag : String) (i : Nat) := pre ++ Name.mkSimple s!"{tag}{i}"
    let F := mkConst (pre ++ `F)
    let sTy := mkApp (mkConst ``St) (mkApp (mkConst ``Ffi.S) F)
    let srvTy := mkConst ``SSrv
    let pairTy := mkApp2 (mkConst ``Prod [.zero, .zero]) sTy srvTy
    let run (fuel : Nat) := mkAppN (mkConst ``runS) #[F, mkRawNatLit fuel,
      mkConst (name "s" 0), mkConst (name "S" 0)]
    let result (i : Nat) := mkApp2 (mkConst ``Option.some [.zero]) pairTy
      (mkApp4 (mkConst ``Prod.mk [.zero, .zero]) sTy srvTy
        (mkConst (name "s" i)) (mkConst (name "S" i)))
    let mut total := 0
    let mut proof : Option Lean.Expr := none
    for (k,i) in ks.zipIdx do
      let next := mkConst (name "c" i)
      let value := match proof with
        | none => next
        | some previous => mkAppN (mkConst ``runS_trans) #[F, mkRawNatLit total, mkRawNatLit k,
            mkConst (name "s" 0), mkConst (name "s" i), mkConst (name "s" (i+1)),
            mkConst (name "S" 0), mkConst (name "S" i), mkConst (name "S" (i+1)), previous, next]
      total := total+k
      let prefixName := name "prefixRun" (i+1)
      let type ← mkEq (run total) (result (i+1))
      addDecl (.thmDecl { name := prefixName, levelParams := [], type, value })
      proof := some (mkConst prefixName)
    let some value := proof | throwError "host_chain_run_staged: empty chain"
    let type ← mkEq (run total) (result ks.length)
    addDecl (.thmDecl { name := pre ++ `run, levelParams := [], type, value })

end Host.Ts
