import host.load.ReadTail
namespace Host.Ts.PrefixFrame
open Lean Elab Command Meta

private def chainName (pre : Lean.Name) (tag : String) (i : Nat) : Lean.Name :=
  pre ++ Lean.Name.mkSimple (tag ++ toString i)

private partial def listValues (e : Lean.Expr) : TermElabM (List Lean.Expr) := do
  let e ← whnf e
  match e.getAppFn, e.getAppArgs with
  | .const ``List.nil _, _ => pure []
  | .const ``List.cons _, #[_, h, r] => return h :: (← listValues r)
  | _, _ => throwError "host_prefix_frames: expected concrete array elements"

private def arrayValues (pre : Lean.Name) (i a : Nat) : TermElabM Lean.Expr := do
  let e ← whnf (← mkAppM ``arrayOf #[mkConst (pre ++ `F), mkConst (chainName pre "s" i), mkRawNatLit a])
  match e.getAppFn, e.getAppArgs with
  | .const ``Option.some _, #[_, p] =>
    let p ← whnf p
    match p.getAppFn, p.getAppArgs with
    | .const ``Prod.mk _, #[_, _, _, es] => pure es
    | _, _ => throwError "host_prefix_frames: malformed array result"
  | _, _ => throwError "host_prefix_frames: address {a} is not an array at boundary {i}"

/-- Frame several source arrays with one shared arbitrary prefix and the native
unread-token suffix supplied by `host_read_tail`. Their appended suffixes may differ.
Every `pfbase<i>` kernel-checks exact recovery of the chosen concrete boundary. -/
elab "host_prefix_frames " p:ident i:num ", " j:num " arrays " addresses:term : command => liftTermElabM do
  let pre := (← getCurrNamespace) ++ p.getId
  let listNat := mkApp (mkConst ``List [.zero]) (mkConst ``Nat)
  let addresses ← unsafe evalExpr (List Nat) listNat
    (← instantiateMVars (← Term.elabTermAndSynthesize addresses (some listNat)))
  let some first := addresses.head? | throwError "host_prefix_frames: expected at least one array"
  if (← getEnv).contains (pre ++ `prefixAddresses) then
    unless ← isDefEq (mkConst (pre ++ `prefixAddresses)) (toExpr addresses) do
      throwError "host_prefix_frames: the shared framed addresses changed"
  else
    addDecl (.defnDecl {
      name := pre ++ `prefixAddresses
      levelParams := []
      type := listNat
      value := toExpr addresses
      hints := .regular 0
      safety := .safe })
  let base ← if (← getEnv).contains (pre ++ `prefixBase) then
    pure (mkConst (pre ++ `prefixBase))
  else arrayValues pre i.getNat first
  let baseValues ← listValues base
  let valList := mkApp (mkConst ``List [.zero]) (mkConst ``Val)
  let numList := mkApp (mkConst ``List [.zero]) (mkConst ``NumV)
  let stTy ← inferType (mkConst (chainName pre "s" i.getNat))
  unless (← getEnv).contains (pre ++ `prefixBase) do
    addDecl (.defnDecl {
      name := pre ++ `prefixBase
      levelParams := []
      type := valList
      value := base
      hints := .regular 0
      safety := .safe })
  for k in [i.getNat:j.getNat + 1] do
    let suffixes ← addresses.mapM fun a => do
      let values ← listValues (← arrayValues pre k a)
      unless values.length ≥ baseValues.length do
        throwError "host_prefix_frames: array {a} shrank at boundary {k}"
      pure (a, values.drop baseValues.length)
    let body ← withLocalDeclD `fw valList fun fw => withLocalDeclD `tail numList fun tail => do
      let mut st := mkApp (mkConst (chainName pre "ta" k)) tail
      for (address, suffix) in suffixes do
        let values := suffix.foldl (fun acc x =>
          mkApp3 (mkConst ``List.append [.zero]) (mkConst ``Val) acc
            (mkApp3 (mkConst ``List.cons [.zero]) (mkConst ``Val) x
              (mkApp (mkConst ``List.nil [.zero]) (mkConst ``Val)))) fw
        st ← mkAppM ``setArray #[mkConst (pre ++ `F), st, mkRawNatLit address, values]
      mkLambdaFVars #[fw, tail] st
    let fnTy ← mkArrow valList (← mkArrow numList stTy)
    addDecl (.defnDecl {
      name := chainName pre "pfa" k
      levelParams := []
      type := fnTy
      value := body
      hints := .regular 0
      safety := .safe })
    let original := mkConst (chainName pre "s" k)
    let value := mkApp2 (mkConst (chainName pre "pfa" k)) (mkConst (pre ++ `prefixBase)) (mkConst (pre ++ `tokenBase))
    addDecl (.thmDecl {
      name := chainName pre "pfbase" k
      levelParams := []
      type := mkApp3 (mkConst ``Eq [.succ .zero]) stTy value original
      value := mkApp2 (mkConst ``Eq.refl [.succ .zero]) stTy original })

/-- Check an actual streamed chunk for every shared array prefix and unread token
suffix. A prefix read affecting control or an incorrect successor fails kernel checking. -/
elab "host_chunk_prefix_frames " p:ident i:num : command => liftTermElabM do
  let started ← IO.monoMsNow
  let pre := (← getCurrNamespace) ++ p.getId
  let k := i.getNat
  let ks ← unsafe evalConst (List Nat) (pre ++ `ks)
  let some n := ks[k]? | throwError "host_chunk_prefix_frames: no chunk {k}"
  let F := mkConst (pre ++ `F)
  let stTy := mkApp (mkConst ``St) (mkApp (mkConst ``Ffi.S) F)
  let pairTy := mkApp2 (mkConst ``Prod [.zero, .zero]) stTy (mkConst ``SSrv)
  let optionTy := mkApp (mkConst ``Option [.zero]) pairTy
  let valList := mkApp (mkConst ``List [.zero]) (mkConst ``Val)
  let numList := mkApp (mkConst ``List [.zero]) (mkConst ``NumV)
  let eqAt (a b : Lean.Expr) :=
    let lhs := mkAppN (mkConst ``runS) #[F, mkRawNatLit n, a, mkConst (chainName pre "S" k)]
    let rhs := mkApp2 (mkConst ``Option.some [.zero]) pairTy
      (mkApp4 (mkConst ``Prod.mk [.zero, .zero]) stTy (mkConst ``SSrv) b (mkConst (chainName pre "S" (k + 1))))
    (mkApp3 (mkConst ``Eq [.succ .zero]) optionTy lhs rhs, lhs)
  let (ty, value) ← withLocalDeclD `fw valList fun fw => withLocalDeclD `tail numList fun tail => do
    let (ty, lhs) := eqAt (mkApp2 (mkConst (chainName pre "pfa" k)) fw tail)
      (mkApp2 (mkConst (chainName pre "pfa" (k + 1))) fw tail)
    return (← mkForallFVars #[fw, tail] ty,
      ← mkLambdaFVars #[fw, tail] (mkApp2 (mkConst ``Eq.refl [.succ .zero]) optionTy lhs))
  addDecl (.thmDecl { name := chainName pre "pfac" k, levelParams := [], type := ty, value })
  let (ty, _) := eqAt (mkConst (chainName pre "s" k)) (mkConst (chainName pre "s" (k + 1)))
  addDecl (.thmDecl {
    name := chainName pre "pftc" k
    levelParams := []
    type := ty
    value := mkApp2 (mkConst (chainName pre "pfac" k)) (mkConst (pre ++ `prefixBase)) (mkConst (pre ++ `tokenBase)) })
  IO.println s!"prefix chunk {k} checked in {(← IO.monoMsNow) - started}ms"
  (← IO.getStdout).flush

/-- Compose the checked source chunks, retaining the same arbitrary caller prefix
and unread native suffix throughout the whole interval. -/
elab "host_chain_prefix_frames " p:ident i:num ", " j:num : command => liftTermElabM do
  let pre := (← getCurrNamespace) ++ p.getId
  let first := i.getNat
  let last := j.getNat
  unless first < last do throwError "host_chain_prefix_frames: expected a nonempty interval"
  let ks ← unsafe evalConst (List Nat) (pre ++ `ks)
  unless last ≤ ks.length do throwError "host_chain_prefix_frames: missing chunks"
  let F := mkConst (pre ++ `F)
  let valList := mkApp (mkConst ``List [.zero]) (mkConst ``Val)
  let numList := mkApp (mkConst ``List [.zero]) (mkConst ``NumV)
  let stTy := mkApp (mkConst ``St) (mkApp (mkConst ``Ffi.S) F)
  let pairTy := mkApp2 (mkConst ``Prod [.zero, .zero]) stTy (mkConst ``SSrv)
  let optionTy := mkApp (mkConst ``Option [.zero]) pairTy
  let (ty, value) ← withLocalDeclD `fw valList fun fw => withLocalDeclD `tail numList fun tail => do
    let state (k : Nat) := mkApp2 (mkConst (chainName pre "pfa" k)) fw tail
    let server (k : Nat) := mkConst (chainName pre "S" k)
    let chunk (k : Nat) := mkApp2 (mkConst (chainName pre "pfac" k)) fw tail
    let mut fuel := ks[first]!
    let mut proof := chunk first
    for k in [first + 1:last] do
      proof := mkAppN (mkConst ``runS_trans) #[F, mkRawNatLit fuel, mkRawNatLit ks[k]!,
        state first, state k, state (k + 1), server first, server k, server (k + 1), proof, chunk k]
      fuel := fuel + ks[k]!
    let lhs := mkAppN (mkConst ``runS) #[F, mkRawNatLit fuel, state first, server first]
    let rhs := mkApp2 (mkConst ``Option.some [.zero]) pairTy
      (mkApp4 (mkConst ``Prod.mk [.zero, .zero]) stTy (mkConst ``SSrv) (state last) (server last))
    let eq := mkApp3 (mkConst ``Eq [.succ .zero]) optionTy lhs rhs
    return (← mkForallFVars #[fw, tail] eq, ← mkLambdaFVars #[fw, tail] proof)
  addDecl (.thmDecl {
    name := pre ++ Lean.Name.mkSimple ("prefixRun" ++ toString first ++ "_" ++ toString last)
    levelParams := []
    type := ty
    value := value })

end Host.Ts.PrefixFrame
