import host.sim.Run
import host.ts.Stream
namespace Host.Ts.Sim
open Lean Elab Command Meta

/-! # Checked chunks of a template stream

A template stream `T` (`host_stream`) provides boundary states `T.s<i>`, servers
`T.S<i>` and chunk sizes `T.ks`. `sim_chunk T ok i` proves
`T.k<i> : runOk T.F ok kᵢ T.s<i> T.S<i> = some (T.s<i+1>, T.S<i+1>)` by the kernel
alone (`Eq.refl`): the run and every accepted state are checked by evaluation.
`sim_chain_run T ok` composes them into `T.okRun`. -/

private def chainName (pre : Lean.Name) (s : String) (i : Nat) : Lean.Name := pre ++ Lean.Name.mkSimple (s ++ toString i)

private def chainKs (pre : Lean.Name) : MetaM (List Nat) := unsafe evalConst (List Nat) (pre ++ `ks)

private def stTy (pre : Lean.Name) : Lean.Expr := mkApp (mkConst ``St) (mkApp (mkConst ``Ffi.S) (mkConst (pre ++ `F)))

private def runOkE (pre ok : Lean.Name) (k i : Nat) : Lean.Expr :=
  mkAppN (mkConst ``runOk) #[mkConst (pre ++ `F), mkConst ok, mkRawNatLit k, mkConst (chainName pre "s" i), mkConst (chainName pre "S" i)]

private def someStE (pre : Lean.Name) (i : Nat) : Lean.Expr :=
  let pTy := mkApp2 (mkConst ``Prod [.zero, .zero]) (stTy pre) (mkConst ``SSrv)
  mkApp2 (mkConst ``Option.some [.zero]) pTy
    (mkApp4 (mkConst ``Prod.mk [.zero, .zero]) (stTy pre) (mkConst ``SSrv) (mkConst (chainName pre "s" i)) (mkConst (chainName pre "S" i)))

private def optPTy (pre : Lean.Name) : Lean.Expr :=
  mkApp (mkConst ``Option [.zero]) (mkApp2 (mkConst ``Prod [.zero, .zero]) (stTy pre) (mkConst ``SSrv))

elab "sim_chunk " p:ident ok:ident i:num : command => liftTermElabM do
  let pre := (← getCurrNamespace) ++ p.getId
  let okN ← realizeGlobalConstNoOverloadWithInfo ok
  let i := i.getNat
  let ks ← chainKs pre
  let some k := ks[i]? | throwError "no chunk {i}"
  let lhs := runOkE pre okN k i
  let ty := mkApp3 (mkConst ``Eq [.succ .zero]) (optPTy pre) lhs (someStE pre (i + 1))
  let value := mkApp2 (mkConst ``Eq.refl [.succ .zero]) (optPTy pre) lhs
  addDecl (.thmDecl { name := chainName pre "k" i, levelParams := [], type := ty, value := value })

elab "sim_chain_run " p:ident ok:ident : command => liftTermElabM do
  let pre := (← getCurrNamespace) ++ p.getId
  let okN ← realizeGlobalConstNoOverloadWithInfo ok
  let ks ← chainKs pre
  let F := mkConst (pre ++ `F)
  let mut fuel := ks.head!
  let mut pf := mkConst (chainName pre "k" 0)
  let mut i := 1
  for k in ks.tail do
    pf := mkAppN (mkConst ``runOk_trans) #[F, mkConst okN, mkRawNatLit fuel, mkRawNatLit k,
      mkConst (chainName pre "s" 0), mkConst (chainName pre "s" i), mkConst (chainName pre "s" (i + 1)),
      mkConst (chainName pre "S" 0), mkConst (chainName pre "S" i), mkConst (chainName pre "S" (i + 1)),
      pf, mkConst (chainName pre "k" i)]
    fuel := fuel + k
    i := i + 1
  let ty := mkApp3 (mkConst ``Eq [.succ .zero]) (optPTy pre) (runOkE pre okN fuel 0) (someStE pre ks.length)
  addDecl (.thmDecl { name := pre ++ `okRun, levelParams := [], type := ty, value := pf })

end Host.Ts.Sim
