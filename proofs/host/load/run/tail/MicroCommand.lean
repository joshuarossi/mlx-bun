import host.load.run.tail.Command
import host.load.Micro
import host.load.Sha
namespace Host.Load.Run.Tail
open Lean Elab Command Meta Host.Ts Host.Load Host.Load.Sha

/-! Subdivided decode chunks for an arbitrary unread suffix. Native restoration
(`host_micro_states`) only chooses intermediate boundaries; every transition is
still a kernel equation, and each outer chunk keeps its original statement. -/

private def nm (pre : Lean.Name) (tag : String) (i : Nat) : Lean.Name :=
  pre ++ Lean.Name.mkSimple (tag ++ toString i)

private def listTy : Lean.Expr := mkApp (mkConst ``List [.zero]) (mkConst ``NumV)

private def addThm (name : Lean.Name) (type value : Lean.Expr) : CoreM Unit :=
  addDecl (.thmDecl { name, levelParams := [], type, value })

/-- `tail_alias Q := P at k₁ … kₙ`: `Q.F`, `Q.ks`, `Q.s<k>` and `Q.S<k>` name
`P`'s, so subdivided chains (`Q.micro<k>`) do not reuse `P.micro<k>` names. -/
elab "tail_alias " q:ident " := " p:ident " at " ks:num* : command => liftTermElabM do
  let ns ← getCurrNamespace
  let tgt := ns ++ q.getId
  let src := ns ++ p.getId
  let alias (n m : Lean.Name) (compile : Bool) : TermElabM Unit := do
    let type := (← getConstInfo m).type
    let d := Declaration.defnDecl { name := n, levelParams := [], type, value := mkConst m, hints := .regular 0, safety := .safe }
    addDecl d
    if compile then compileDecl d
  alias (tgt ++ `F) (src ++ `F) false
  alias (tgt ++ `ks) (src ++ `ks) true
  for k in ks do
    alias (nm tgt "s" k.getNat) (nm src "s" k.getNat) false
    alias (nm tgt "S" k.getNat) (nm src "S" k.getNat) false

private def chunkTypes (pre : Lean.Name) : Lean.Expr × Lean.Expr × Lean.Expr :=
  let F := mkConst (pre ++ `F)
  let stTy := mkApp (mkConst ``St) (mkApp (mkConst ``Ffi.S) F)
  let pairTy := mkApp2 (mkConst ``Prod [.zero, .zero]) stTy (mkConst ``SSrv)
  (stTy, pairTy, mkApp (mkConst ``Option [.zero]) pairTy)

private def chunkEq (pre : Lean.Name) (k n : Nat) (a b : Lean.Expr) : Lean.Expr :=
  let (stTy, pairTy, optionTy) := chunkTypes pre
  let lhs := mkAppN (mkConst ``runS) #[mkConst (pre ++ `F), mkRawNatLit n, a, mkConst (nm pre "S" k)]
  let rhs := mkApp2 (mkConst ``Option.some [.zero]) pairTy (mkApp4 (mkConst ``Prod.mk [.zero, .zero]) stTy (mkConst ``SSrv) b (mkConst (nm pre "S" (k + 1))))
  mkApp3 (mkConst ``Eq [.succ .zero]) optionTy lhs rhs

/-- `tail_chunk_from P k := h`: `P.tac<k>` (the statement of
`host_chunk_read_tail_eager P k`) from `h : ∀ tail, …` over defeq aliases of its
endpoints, and its specialization `P.tc<k>`. -/
elab "tail_chunk_from " p:ident i:num " := " h:ident : command => liftTermElabM do
  let pre := (← getCurrNamespace) ++ p.getId
  let k := i.getNat
  let ks ← unsafe evalConst (List Nat) (pre ++ `ks)
  let some n := ks[k]? | throwError "tail_chunk_from: no chunk {k}"
  let hName ← realizeGlobalConstNoOverloadWithInfo h
  let ty := chunkEq pre k n (mkApp (mkConst (nm pre "ta" k)) (.bvar 0)) (mkApp (mkConst (nm pre "ta" (k + 1))) (.bvar 0))
  addThm (nm pre "tac" k) (.forallE `tail listTy ty .default) (.lam `tail listTy (mkApp (mkConst hName) (.bvar 0)) .default)
  addThm (nm pre "tc" k) (chunkEq pre k n (mkConst (nm pre "s" k)) (mkConst (nm pre "s" (k + 1))))
    (mkApp (mkConst (nm pre "tac" k)) (mkConst (pre ++ `tokenBase)))

private unsafe def chooseState (value : Lean.Expr) : TermElabM (St LSt) := do
  let (native, _) ← (ConstructorDecode.decode value).run {}
  return unsafeCast native

private def natListTy : Lean.Expr := mkApp (mkConst ``List [.zero]) (mkConst ``Nat)

private def addData (n : Lean.Name) (type value : Lean.Expr) : TermElabM Unit :=
  addDecl (.defnDecl { name := n, levelParams := [], type, value, hints := .regular 0, safety := .safe })

/-- `sha256_checked`'s block checks for a message chosen natively, without
evaluating the message term: `pre.checked : sha256 pre.msg = pre.digest`. -/
private def checkHash (pre : Lean.Name) (msgExpr : Lean.Expr) (msg : List Nat) : TermElabM Unit := do
  addData (pre ++ `msg) natListTy msgExpr
  let padded := pad msg
  unless padded.length % 64 == 0 do throwError "host_sha256_step_tail: invalid candidate padding"
  let blocks := (List.range (padded.length / 64)).map fun i => (padded.drop (i * 64)).take 64
  let count := blocks.length
  addData (nm pre "h" 0) natListTy (mkConst ``shaH0)
  let mut h := shaH0
  for (block, i) in blocks.zipIdx do
    addData (nm pre "b" i) natListTy (toExpr block)
    h := shaBlock h block
    addData (nm pre "h" (i + 1)) natListTy (toExpr h)
    let lhs := mkApp2 (mkConst ``shaBlock) (mkConst (nm pre "h" i)) (mkConst (nm pre "b" i))
    addThm (nm pre "block" i) (← mkEq lhs (mkConst (nm pre "h" (i + 1)))) (← mkEqRefl lhs)
    Meta.resetCache
  addData (nm pre "tail" count) natListTy (toExpr ([] : List Nat))
  let blocksE (fuel : Nat) (h bs : Lean.Expr) := mkApp3 (mkConst ``shaBlocks) (mkRawNatLit fuel) h bs
  let final := mkConst (nm pre "h" count)
  let finalLhs := blocksE 1 final (mkConst (nm pre "tail" count))
  addThm (nm pre "suffix" count) (← mkEq finalLhs final) (← mkEqRefl finalLhs)
  for i in (List.range count).reverse do
    let block := mkConst (nm pre "b" i)
    let rest := mkConst (nm pre "tail" (i + 1))
    addData (nm pre "tail" i) natListTy (← mkAppM ``List.append #[block, rest])
    let length ← mkAppM ``List.length #[block]
    addThm (nm pre "length" i) (← mkEq length (mkRawNatLit 64)) (← mkEqRefl length)
    let one := mkAppN (mkConst ``blocks_step) #[mkConst (nm pre "h" i), block, rest,
      mkConst (nm pre "h" (i + 1)), mkRawNatLit (count - i), mkConst (nm pre "length" i), mkConst (nm pre "block" i)]
    let lhs := blocksE (count - i + 1) (mkConst (nm pre "h" i)) (mkConst (nm pre "tail" i))
    addThm (nm pre "suffix" i) (← mkEq lhs final) (← mkEqTrans one (mkConst (nm pre "suffix" (i + 1))))
    Meta.resetCache
  let input := mkConst (pre ++ `msg)
  let tail := mkConst (nm pre "tail" 0)
  let padding := mkApp (mkConst ``pad) input
  addThm (pre ++ `padding) (← mkEq padding tail) (← mkEqRefl padding)
  let fuel := mkApp2 (mkConst ``Nat.add) (mkApp2 (mkConst ``Nat.div)
    (mkApp2 (mkConst ``len) (mkConst ``Nat) tail) (mkRawNatLit 64)) (mkRawNatLit 1)
  addThm (pre ++ `count) (← mkEq fuel (mkRawNatLit (count + 1))) (← mkEqRefl fuel)
  let value := mkAppN (mkConst ``sha256_of_blocks) #[input, tail, final, mkRawNatLit (count + 1),
    mkConst (pre ++ `padding), mkConst (pre ++ `count), mkConst (nm pre "suffix" 0)]
  addData (pre ++ `digest) natListTy (toExpr (h.flatMap (beBytes 4)))
  addThm (pre ++ `checked) (← mkEq (mkApp (mkConst ``sha256) input) (mkConst (pre ++ `digest))) value

/-- `host_sha256_step` for every unread suffix: `Q.tac<i>` and `Q.tc<i>` for a
one-step SHA-256 host call. The message is chosen from the closed boundary; the
projection, every compression block and the step are kernel checked with the
suffix abstract. -/
elab "host_sha256_step_tail " p:ident i:num : command => liftTermElabM <| withOptions (fun o => o.setBool `Elab.async false) do
  let pre := (← getCurrNamespace) ++ p.getId
  let i := i.getNat
  let hash := pre ++ Name.mkSimple s!"hash{i}"
  let state ← unsafe chooseState (mkConst (nm pre "s" i))
  let (f, this, args) ← match state.ctl with
    | .call (.obj f) this args => pure (f, this, args)
    | _ => throwError "host_sha256_step_tail: expected an object call"
  let some obj := state.obj? f | throwError "host_sha256_step_tail: missing function"
  let .fn (.native (.host .sha256) data) := obj.kind | throwError "host_sha256_step_tail: expected SHA host function"
  let .pure (some parts) := M.run (elemsOf Host.Load.ffi state (arg args 0)) | throwError "host_sha256_step_tail: unsupported parts"
  let some bss := parts.mapM (partBytes Host.Load.ffi state) | throwError "host_sha256_step_tail: unsupported part bytes"
  addData (hash ++ `parts) (mkApp (mkConst ``List [.zero]) (mkConst ``Val)) (toExpr parts)
  addData (hash ++ `bss) (mkApp (mkConst ``List [.zero]) natListTy) (toExpr bss)
  checkHash hash (← mkAppM ``List.flatten #[mkConst (hash ++ `bss)]) bss.flatten
  let F := mkConst (pre ++ `F)
  let ks ← unsafe evalConst (List Nat) (pre ++ `ks)
  unless ks[i]? == some 1 do throwError "host_sha256_step_tail: chunk {i} is not one step"
  let srv := mkConst (nm pre "S" i)
  let parts := mkConst (hash ++ `parts)
  let (type, value) ← withLocalDeclD `tail listTy fun tail => do
    let s := mkApp (mkConst (nm pre "ta" i)) tail
    let next := mkApp (mkConst (nm pre "ta" (i + 1))) tail
    let eqProof (lhs rhs : Lean.Expr) : TermElabM Lean.Expr := do
      let α ← inferType lhs
      return eagerRefl (← getLevel α) α lhs rhs
    let ctl ← mkAppM ``St.ctl #[s]
    let hc ← eqProof ctl (toExpr state.ctl)
    let ho ← eqProof (← mkAppM ``St.obj? #[s, mkRawNatLit f]) (toExpr (some obj))
    let hn ← eqProof (mkApp (mkConst ``Obj.kind) (toExpr obj)) (toExpr obj.kind)
    let hp ← eqProof (mkApp3 (mkConst ``elemsOf) F s (toExpr (arg args 0)))
      (← mkAppM ``M.pure #[← mkAppM ``Option.some #[parts]])
    let hb ← eqProof (← mkAppM ``List.mapM #[mkApp2 (mkConst ``partBytes) F s, parts])
      (← mkAppM ``Option.some #[mkConst (hash ++ `bss)])
    let stepProof := mkAppN (mkConst ``step_sha256) #[F, s, mkRawNatLit f, toExpr this, toExpr args, toExpr data,
      parts, toExpr obj, mkConst (hash ++ `bss), mkConst (hash ++ `digest), hc, ho, hn, hp, hb, mkConst (hash ++ `checked)]
    let ret ← mkAppM ``St.ret #[s, ← mkAppM ``Val.str #[mkApp (mkConst ``hexBytes) (mkConst (hash ++ `digest))]]
    let hh ← eqProof (mkApp (mkConst ``isHalt) ctl) (mkConst ``Bool.false)
    let one := mkAppN (mkConst ``runS_one_of_step) #[F, s, ret, srv, hh, stepProof]
    let ty := chunkEq pre i 1 s next
    let some (α, lhs, rhs) := ty.eq? | throwError "host_sha256_step_tail: internal"
    let (_, pairTy, _) := chunkTypes pre
    let mid := mkApp2 (mkConst ``Option.some [.zero]) pairTy (mkApp4 (mkConst ``Prod.mk [.zero, .zero]) (mkApp (mkConst ``St) (mkApp (mkConst ``Ffi.S) F)) (mkConst ``SSrv) ret srv)
    let pf := mkAppN (mkConst ``Eq.trans [.succ .zero]) #[α, lhs, mid, rhs, one, eagerRefl (.succ .zero) α mid rhs]
    return (← mkForallFVars #[tail] ty, ← mkLambdaFVars #[tail] pf)
  addThm (nm pre "tac" i) type value
  addThm (nm pre "tc" i) (chunkEq pre i 1 (mkConst (nm pre "s" i)) (mkConst (nm pre "s" (i + 1))))
    (mkApp (mkConst (nm pre "tac" i)) (mkConst (pre ++ `tokenBase)))

end Host.Load.Run.Tail
