import host.load.Stream
namespace Host.Load.ReadTail
open Lean Elab Command Meta Host.Ts

/-- The native MLX record inside a serialized machine state. Its token queue is
inline; heap and graph pages can remain named constants. -/
partial def nativeState? (e : Lean.Expr) : Option Lean.Expr :=
  if e.isAppOfArity ``Host.Mlx.Ffi.St.mk 13 then some e else
  match e with
  | .app f a => (nativeState? f).orElse fun _ => nativeState? a
  | .mdata _ b => nativeState? b
  | _ => none

partial def dropList (n : Nat) (e : Lean.Expr) : Except String Lean.Expr :=
  match n with
  | 0 => .ok e
  | n + 1 => match e.getAppFn, e.getAppArgs with
    | .const ``List.cons _, #[_, _, r] => dropList n r
    | _, _ => .error "the native token queue has too few known heads"

/-- Replace precisely the unused queue suffix, preserving every known head.
Nothing outside the token field of the native MLX state is abstracted. -/
partial def replaceSuffix (suffix tail : Lean.Expr) (e : Lean.Expr) : Except String Lean.Expr :=
  if e == suffix then .ok tail else
  match e.getAppFn, e.getAppArgs with
  | .const ``List.cons ls, #[ty, h, r] => do
    pure (mkApp3 (mkConst ``List.cons ls) ty h (← replaceSuffix suffix tail r))
  | _, _ => .error "the native token queue has consumed the abstracted suffix"

def abstractTail (suffix tail : Lean.Expr) (e : Lean.Expr) : Except String Lean.Expr := do
  let some native := nativeState? e | throw "the state has no inline MLX native record"
  let args := native.getAppArgs
  let tokens ← replaceSuffix suffix tail args[5]!
  let replacement := mkAppN native.getAppFn (args.set! 5 tokens)
  pure (e.replace fun t => if t == native then some replacement else none)

private def chainName (pre : Lean.Name) (tag : String) (i : Nat) : Lean.Name :=
  pre ++ Lean.Name.mkSimple (tag ++ toString i)

private def stateValue (pre : Lean.Name) (i : Nat) : TermElabM Lean.Expr := do
  match ← getConstInfo (chainName pre "s" i) with
  | .defnInfo d => whnf d.value
  | _ => throwError "host_read_tail: the boundary must be a state definition"

/-- Abstract an unused readback suffix over boundaries `i … j`. `keep` is the
number of known next-read heads at boundary `i`; the remainder is arbitrary.
The command chooses state functions only. `host_chunk_read_tail` checks them. -/
elab "host_read_tail " p:ident i:num ", " j:num " keep " keep:num : command => liftTermElabM do
  let pre := (← getCurrNamespace) ++ p.getId
  let first ← stateValue pre i.getNat
  let some native := nativeState? first | throwError "host_read_tail: no native MLX state"
  let suffix ← match dropList keep.getNat native.getAppArgs[5]! with
    | .ok e => pure e
    | .error e => throwError "host_read_tail: {e}"
  let listTy := mkApp (mkConst ``List [.zero]) (mkConst ``NumV)
  let stTy ← inferType (mkConst (chainName pre "s" i.getNat))
  addDecl (.defnDecl { name := pre ++ `tokenBase, levelParams := [], type := listTy, value := suffix, hints := .regular 0, safety := .safe })
  for k in [i.getNat:j.getNat + 1] do
    let value ← stateValue pre k
    let body ← withLocalDeclD `tail listTy fun tail => do
      let body ← match abstractTail suffix tail value with
        | .ok e => pure e
        | .error e => throwError "host_read_tail: boundary {k}: {e}"
      mkLambdaFVars #[tail] body
    addDecl (.defnDecl { name := chainName pre "ta" k, levelParams := [], type := ← mkArrow listTy stTy, value := body, hints := .regular 0, safety := .safe })

/-- A checked chunk for every remaining readback suffix. The known head remains
in the start state; reading beyond it leaves the kernel stuck and fails.
`tac<k>` is universal and `tc<k>` specializes to the original chosen suffix. -/
elab "host_chunk_read_tail " p:ident i:num : command => liftTermElabM do
  let pre := (← getCurrNamespace) ++ p.getId
  let k := i.getNat
  let ks ← unsafe evalConst (List Nat) (pre ++ `ks)
  let some n := ks[k]? | throwError "host_chunk_read_tail: no chunk {k}"
  let F := mkConst (pre ++ `F)
  let stTy := mkApp (mkConst ``St) (mkApp (mkConst ``Ffi.S) F)
  let pairTy := mkApp2 (mkConst ``Prod [.zero, .zero]) stTy (mkConst ``SSrv)
  let optionTy := mkApp (mkConst ``Option [.zero]) pairTy
  let listTy := mkApp (mkConst ``List [.zero]) (mkConst ``NumV)
  let eqAt (a b : Lean.Expr) :=
    let lhs := mkAppN (mkConst ``runS) #[F, mkRawNatLit n, a, mkConst (chainName pre "S" k)]
    let rhs := mkApp2 (mkConst ``Option.some [.zero]) pairTy (mkApp4 (mkConst ``Prod.mk [.zero, .zero]) stTy (mkConst ``SSrv) b (mkConst (chainName pre "S" (k + 1))))
    (mkApp3 (mkConst ``Eq [.succ .zero]) optionTy lhs rhs, lhs)
  let (ty, lhs) := eqAt (mkApp (mkConst (chainName pre "ta" k)) (.bvar 0)) (mkApp (mkConst (chainName pre "ta" (k + 1))) (.bvar 0))
  addDecl (.thmDecl { name := chainName pre "tac" k, levelParams := [], type := .forallE `tail listTy ty .default, value := .lam `tail listTy (mkApp2 (mkConst ``Eq.refl [.succ .zero]) optionTy lhs) .default })
  let (ty, _) := eqAt (mkConst (chainName pre "s" k)) (mkConst (chainName pre "s" (k + 1)))
  addDecl (.thmDecl { name := chainName pre "tc" k, levelParams := [], type := ty, value := mkApp (mkConst (chainName pre "tac" k)) (mkConst (pre ++ `tokenBase)) })

end Host.Load.ReadTail

namespace Host.Load.ReadTail
open Lean Elab Command Meta Host.Ts

private partial def listValues (e : Lean.Expr) : TermElabM (List Lean.Expr) := do
  let e ← whnf e
  match e.getAppFn, e.getAppArgs with
  | .const ``List.nil _, _ => pure []
  | .const ``List.cons _, #[_, h, r] => return h :: (← listValues r)
  | _, _ => throwError "host_forward_frame: array elements are not a concrete list"

private def arrayElements (pre : Lean.Name) (i a : Nat) : TermElabM Lean.Expr := do
  let e ← whnf (← mkAppM ``arrayOf #[mkConst (pre ++ `F), mkConst (chainName pre "s" i), mkRawNatLit a])
  match e.getAppFn, e.getAppArgs with
  | .const ``Option.some _, #[_, p] =>
    let p ← whnf p
    match p.getAppFn, p.getAppArgs with
    | .const ``Prod.mk _, #[_, _, _, es] => pure es
    | _, _ => throwError "host_forward_frame: unexpected array result"
  | _, _ => throwError "host_forward_frame: address {a} is not an array at boundary {i}"

/-- Add a forwarded-array prefix parameter on top of the native queue suffix.
Each state is a small wrapper around `ta<i>`, updating only this caller array.
`qbase<i>` checks that the two concrete inputs recover the original state. -/
elab "host_forward_frame " p:ident i:num ", " j:num " array " a:term : command => liftTermElabM do
  let pre := (← getCurrNamespace) ++ p.getId
  let address ← unsafe evalExpr Nat (mkConst ``Nat) (← instantiateMVars (← Term.elabTermAndSynthesize a (some (mkConst ``Nat))))
  let base ← arrayElements pre i.getNat address
  let baseValues ← listValues base
  let valList := mkApp (mkConst ``List [.zero]) (mkConst ``Val)
  let numList := mkApp (mkConst ``List [.zero]) (mkConst ``NumV)
  let stTy ← inferType (mkConst (chainName pre "s" i.getNat))
  addDecl (.defnDecl { name := pre ++ `forwardBase, levelParams := [], type := valList, value := base, hints := .regular 0, safety := .safe })
  for k in [i.getNat:j.getNat + 1] do
    let es ← listValues (← arrayElements pre k address)
    unless es.length ≥ baseValues.length do throwError "host_forward_frame: the array shrank at boundary {k}"
    let body ← withLocalDeclD `fw valList fun fw => withLocalDeclD `tail numList fun tail => do
      let values := (es.drop baseValues.length).foldl (fun acc x => mkApp3 (mkConst ``List.append [.zero]) (mkConst ``Val) acc (mkApp3 (mkConst ``List.cons [.zero]) (mkConst ``Val) x (mkApp (mkConst ``List.nil [.zero]) (mkConst ``Val)))) fw
      let st ← mkAppM ``setArray #[mkConst (pre ++ `F), mkApp (mkConst (chainName pre "ta" k)) tail, mkRawNatLit address, values]
      mkLambdaFVars #[fw, tail] st
    let fnTy ← mkArrow valList (← mkArrow numList stTy)
    addDecl (.defnDecl { name := chainName pre "qa" k, levelParams := [], type := fnTy, value := body, hints := .regular 0, safety := .safe })
    let original := mkConst (chainName pre "s" k)
    let value := mkApp2 (mkConst (chainName pre "qa" k)) (mkConst (pre ++ `forwardBase)) (mkConst (pre ++ `tokenBase))
    addDecl (.thmDecl { name := chainName pre "qbase" k, levelParams := [], type := mkApp3 (mkConst ``Eq [.succ .zero]) stTy value original, value := mkApp2 (mkConst ``Eq.refl [.succ .zero]) stTy original })

/-- Kernel-check one body for every forwarded prefix and every unused native
readback suffix. The specialized theorem refers to the original state constants. -/
elab "host_chunk_forward_frame " p:ident i:num : command => liftTermElabM do
  let pre := (← getCurrNamespace) ++ p.getId
  let k := i.getNat
  let ks ← unsafe evalConst (List Nat) (pre ++ `ks)
  let some n := ks[k]? | throwError "host_chunk_forward_frame: no chunk {k}"
  let F := mkConst (pre ++ `F)
  let stTy := mkApp (mkConst ``St) (mkApp (mkConst ``Ffi.S) F)
  let pairTy := mkApp2 (mkConst ``Prod [.zero, .zero]) stTy (mkConst ``SSrv)
  let optionTy := mkApp (mkConst ``Option [.zero]) pairTy
  let valList := mkApp (mkConst ``List [.zero]) (mkConst ``Val)
  let numList := mkApp (mkConst ``List [.zero]) (mkConst ``NumV)
  let eqAt (a b : Lean.Expr) :=
    let lhs := mkAppN (mkConst ``runS) #[F, mkRawNatLit n, a, mkConst (chainName pre "S" k)]
    let rhs := mkApp2 (mkConst ``Option.some [.zero]) pairTy (mkApp4 (mkConst ``Prod.mk [.zero, .zero]) stTy (mkConst ``SSrv) b (mkConst (chainName pre "S" (k + 1))))
    (mkApp3 (mkConst ``Eq [.succ .zero]) optionTy lhs rhs, lhs)
  let (ty, value) ← withLocalDeclD `fw valList fun fw => withLocalDeclD `tail numList fun tail => do
    let (ty, lhs) := eqAt (mkApp2 (mkConst (chainName pre "qa" k)) fw tail) (mkApp2 (mkConst (chainName pre "qa" (k + 1))) fw tail)
    return (← mkForallFVars #[fw, tail] ty, ← mkLambdaFVars #[fw, tail] (mkApp2 (mkConst ``Eq.refl [.succ .zero]) optionTy lhs))
  addDecl (.thmDecl { name := chainName pre "qac" k, levelParams := [], type := ty, value })
  let (ty, _) := eqAt (mkConst (chainName pre "s" k)) (mkConst (chainName pre "s" (k + 1)))
  addDecl (.thmDecl { name := chainName pre "qtc" k, levelParams := [], type := ty, value := mkApp2 (mkConst (chainName pre "qac" k)) (mkConst (pre ++ `forwardBase)) (mkConst (pre ++ `tokenBase)) })

end Host.Load.ReadTail
