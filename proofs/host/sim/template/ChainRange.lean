import host.sim.Chunk
namespace Host.Ts.Sim.Template
open Lean Elab Command Meta Host.Ts Host.Ts.Sim

/-! # Composing a range of checked chunks

`sim_chain_range T ok a b N` composes the checked chunks `T.k<a>` … `T.k<b-1>`
(`sim_chunk T ok i`) into
`T.N : runOk T.F ok (kₐ + … + k_{b-1}) T.s<a> T.S<a> = some (T.s<b>, T.S<b>)`. -/

private def nm (pre : Lean.Name) (s : String) (i : Nat) : Lean.Name := pre ++ Lean.Name.mkSimple (s ++ toString i)

elab "sim_chain_range " p:ident ok:ident a:num b:num n:ident : command => liftTermElabM do
  let pre := (← getCurrNamespace) ++ p.getId
  let okN ← realizeGlobalConstNoOverloadWithInfo ok
  let a := a.getNat
  let b := b.getNat
  unless a < b do throwError "sim_chain_range: empty range"
  let ks ← unsafe evalConst (List Nat) (pre ++ `ks)
  unless b ≤ ks.length do throwError "sim_chain_range: no chunk {b - 1}"
  let F := mkConst (pre ++ `F)
  let stTy := mkApp (mkConst ``St) (mkApp (mkConst ``Ffi.S) F)
  let pTy := mkApp2 (mkConst ``Prod [.zero, .zero]) stTy (mkConst ``SSrv)
  let s i := mkConst (nm pre "s" i)
  let S i := mkConst (nm pre "S" i)
  let mut fuel := ks[a]!
  let mut pf := mkConst (nm pre "k" a)
  for i in [a + 1:b] do
    pf := mkAppN (mkConst ``runOk_trans) #[F, mkConst okN, mkRawNatLit fuel, mkRawNatLit ks[i]!,
      s a, s i, s (i + 1), S a, S i, S (i + 1), pf, mkConst (nm pre "k" i)]
    fuel := fuel + ks[i]!
  let lhs := mkAppN (mkConst ``runOk) #[F, mkConst okN, mkRawNatLit fuel, s a, S a]
  let rhs := mkApp2 (mkConst ``Option.some [.zero]) pTy (mkApp4 (mkConst ``Prod.mk [.zero, .zero]) stTy (mkConst ``SSrv) (s b) (S b))
  let ty := mkApp3 (mkConst ``Eq [.succ .zero]) (mkApp (mkConst ``Option [.zero]) pTy) lhs rhs
  addDecl (.thmDecl { name := pre ++ n.getId, levelParams := [], type := ty, value := pf })

end Host.Ts.Sim.Template
