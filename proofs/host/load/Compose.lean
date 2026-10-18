import host.ts.Chunk
import host.ts.LinkChain

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

theorem linkRun_initial {S : Type} (cx : LinkCx S) (w : S) {fuel : Nat}
    {x0 last : LinkSt S} (initial : LinkSt.init w = x0)
    (run : linkRun cx 0 fuel x0 = some last) :
    linkRun cx 0 fuel (LinkSt.init w) = some last := by
  rw [initial]
  exact run

/-- Compose existing one-action link theorems using named prefixes, then
derive the original link and boot statements. -/
elab "link_chain_run_staged " p:ident : command =>
  liftTermElabM <| withOptions (fun o => o.setBool `Elab.async false) do
    let pre := (← getCurrNamespace) ++ p.getId
    let ns ← unsafe evalConst (List Nat) (pre ++ `ns)
    if ns.isEmpty then throwError "link_chain_run_staged: empty chain"
    let name (tag : String) (i : Nat) := pre ++ Name.mkSimple s!"{tag}{i}"
    let x0 := mkConst (name "x" 0)
    let xTy ← inferType x0
    let sTy := xTy.appArg!
    let cx := mkConst (pre ++ `cx)
    let w := mkConst (pre ++ `w)
    let run (fuel : Nat) (start : Lean.Expr) := mkAppN (mkConst ``linkRun)
      #[sTy, cx, mkRawNatLit 0, mkRawNatLit fuel, start]
    let result (i : Nat) := mkApp2 (mkConst ``Option.some [.zero]) xTy (mkConst (name "x" i))
    let mut total := 0
    let mut proof : Option Lean.Expr := none
    for (n,i) in ns.zipIdx do
      let next := mkConst (name "l" i)
      let value := match proof with
        | none => next
        | some previous => mkAppN (mkConst ``linkRun_trans) #[sTy, cx, mkRawNatLit 0,
            mkRawNatLit total, mkRawNatLit n, x0, mkConst (name "x" i),
            mkConst (name "x" (i+1)), previous, next]
      total := total+n
      let prefixName := name "prefixLink" (i+1)
      let type ← mkEq (run total x0) (result (i+1))
      addDecl (.thmDecl { name := prefixName, levelParams := [], type, value })
      proof := some (mkConst prefixName)
    let some value := proof | throwError "link_chain_run_staged: empty chain"
    let type ← mkEq (run total x0) (result ns.length)
    addDecl (.thmDecl { name := pre ++ `link0, levelParams := [], type, value })
    let initial := mkApp2 (mkConst ``LinkSt.init) sTy w
    let initialType ← mkEq initial x0
    addDecl (.thmDecl { name := pre ++ `x0_eq, levelParams := [], type := initialType, value := ← mkEqRefl initial })
    let last := mkConst (name "x" ns.length)
    let value := mkAppN (mkConst ``linkRun_initial) #[sTy, cx, w, mkRawNatLit total, x0, last,
      mkConst (pre ++ `x0_eq), mkConst (pre ++ `link0)]
    let type ← mkEq (run total initial) (result ns.length)
    addDecl (.thmDecl { name := pre ++ `link, levelParams := [], type, value })
    let done := mkApp2 (mkConst ``LinkSt.done) sTy last
    let type ← mkEq done (mkConst ``Bool.true)
    addDecl (.thmDecl { name := pre ++ `done, levelParams := [], type, value := ← mkEqRefl done })
    let value := mkAppN (mkConst ``boot_of_link) #[sTy, cx, w, mkRawNatLit total, last,
      mkConst (pre ++ `link), mkConst (pre ++ `done)]
    addDecl (.thmDecl { name := pre ++ `booted, levelParams := [], type := ← inferType value, value })

end Host.Ts
