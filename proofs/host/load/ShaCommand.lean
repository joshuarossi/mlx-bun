import host.load.Sha
import host.load.Native
import host.ts.Memo

namespace Host.Load.Sha
open Host.Ts Lean Elab Command Meta

private def addData (name : Lean.Name) (type value : Lean.Expr) : TermElabM Unit :=
  addDecl (.defnDecl { name, levelParams := [], type, value, hints := .regular 0, safety := .safe })

private def addChecked (name : Lean.Name) (type value : Lean.Expr) : TermElabM Unit :=
  addDecl (.thmDecl { name, levelParams := [], type, value })

private def indexed (pre : Lean.Name) (tag : String) (i : Nat) : Lean.Name :=
  pre ++ Name.mkSimple s!"{tag}{i}"

private def natListTy : Lean.Expr := mkApp (mkConst ``List [.zero]) (mkConst ``Nat)

/-- Native SHA values are candidate data. Each original compression block is
checked separately, then the original `shaBlocks` equations compose them. -/
private def checkHash (pre : Lean.Name) (msgExpr : Lean.Expr) (msg : List Nat) : TermElabM Unit := do
  let started ← IO.monoMsNow
  addData (pre ++ `msg) natListTy msgExpr
  let padded := pad msg
  unless padded.length % 64 == 0 do throwError "sha256_checked: invalid candidate padding"
  let blocks := (List.range (padded.length/64)).map fun i => (padded.drop (i*64)).take 64
  let count := blocks.length
  addData (indexed pre "h" 0) natListTy (mkConst ``shaH0)
  let mut h := shaH0
  for (block,i) in blocks.zipIdx do
    addData (indexed pre "b" i) natListTy (toExpr block)
    h := shaBlock h block
    addData (indexed pre "h" (i+1)) natListTy (toExpr h)
    let lhs := mkApp2 (mkConst ``shaBlock) (mkConst (indexed pre "h" i)) (mkConst (indexed pre "b" i))
    addChecked (indexed pre "block" i) (← mkEq lhs (mkConst (indexed pre "h" (i+1)))) (← mkEqRefl lhs)
    Meta.resetCache
    if i % 64 == 0 then logInfo m!"sha256_checked {pre}: block {i+1}/{count} checked"
  addData (indexed pre "tail" count) natListTy (toExpr ([] : List Nat))
  let blocksE (fuel : Nat) (h bs : Lean.Expr) := mkApp3 (mkConst ``shaBlocks) (mkRawNatLit fuel) h bs
  let final := mkConst (indexed pre "h" count)
  let finalLhs := blocksE 1 final (mkConst (indexed pre "tail" count))
  addChecked (indexed pre "suffix" count) (← mkEq finalLhs final) (← mkEqRefl finalLhs)
  for i in (List.range count).reverse do
    let block := mkConst (indexed pre "b" i)
    let rest := mkConst (indexed pre "tail" (i+1))
    let tail ← mkAppM ``List.append #[block,rest]
    addData (indexed pre "tail" i) natListTy tail
    let length ← mkAppM ``List.length #[block]
    addChecked (indexed pre "length" i) (← mkEq length (mkRawNatLit 64)) (← mkEqRefl length)
    let one := mkAppN (mkConst ``blocks_step) #[mkConst (indexed pre "h" i),block,rest,
      mkConst (indexed pre "h" (i+1)),mkRawNatLit (count-i),mkConst (indexed pre "length" i),
      mkConst (indexed pre "block" i)]
    let composed ← mkEqTrans one (mkConst (indexed pre "suffix" (i+1)))
    let lhs := blocksE (count-i+1) (mkConst (indexed pre "h" i)) (mkConst (indexed pre "tail" i))
    addChecked (indexed pre "suffix" i) (← mkEq lhs final) composed
    Meta.resetCache
  let input := mkConst (pre ++ `msg)
  let tail := mkConst (indexed pre "tail" 0)
  let padding := mkApp (mkConst ``pad) input
  addChecked (pre ++ `padding) (← mkEq padding tail) (← mkEqRefl padding)
  let fuel := mkApp2 (mkConst ``Nat.add) (mkApp2 (mkConst ``Nat.div)
    (mkApp2 (mkConst ``len) (mkConst ``Nat) tail) (mkRawNatLit 64)) (mkRawNatLit 1)
  addChecked (pre ++ `count) (← mkEq fuel (mkRawNatLit (count+1))) (← mkEqRefl fuel)
  let value := mkAppN (mkConst ``sha256_of_blocks) #[input,tail,final,mkRawNatLit (count+1),
    mkConst (pre ++ `padding),mkConst (pre ++ `count),mkConst (indexed pre "suffix" 0)]
  let digest := h.flatMap (beBytes 4)
  addData (pre ++ `digest) natListTy (toExpr digest)
  addChecked (pre ++ `checked) (← mkEq (mkApp (mkConst ``sha256) input) (mkConst (pre ++ `digest))) value
  logInfo m!"sha256_checked {pre}: {msg.length} bytes, {count} original blocks, {(← IO.monoMsNow)-started} ms"

elab "sha256_checked " p:ident " : " msg:term : command =>
  liftTermElabM <| withOptions (fun o => o.setBool `Elab.async false) do
    let value ← instantiateMVars (← Term.elabTermAndSynthesize msg (some natListTy))
    let native ← unsafe evalExpr (List Nat) natListTy value
    checkHash ((← getCurrNamespace) ++ p.getId) value native

private unsafe def chooseState (value : Lean.Expr) : TermElabM (St LSt) := do
  let (native,_) ← (ConstructorDecode.decode value).run {}
  return unsafeCast native

/-- Check the actual SHA host call at a named micro-boundary. The message
projection, every compression block, and the resulting machine step are
kernel checked against the supplied states. -/
elab "host_sha256_step " p:ident i:num : command =>
  liftTermElabM <| withOptions (fun o => o.setBool `Elab.async false) do
    let pre := (← getCurrNamespace) ++ p.getId
    let i := i.getNat
    let F := mkConst (pre ++ `F)
    let s := mkConst (indexed pre "s" i)
    let next := mkConst (indexed pre "s" (i+1))
    let srv := mkConst (indexed pre "S" i)
    let nsrv := mkConst (indexed pre "S" (i+1))
    let state ← unsafe chooseState s
    let (f,this,args) ← match state.ctl with
      | .call (.obj f) this args => pure (f,this,args)
      | _ => throwError "host_sha256_step: expected an object call"
    let some obj := state.obj? f | throwError "host_sha256_step: missing function"
    let .fn (.native (.host .sha256) data) := obj.kind | throwError "host_sha256_step: expected SHA host function"
    let .pure (some parts) := M.run (elemsOf Host.Load.ffi state (arg args 0)) | throwError "host_sha256_step: unsupported parts"
    let some bss := parts.mapM (partBytes Host.Load.ffi state) | throwError "host_sha256_step: unsupported part bytes"
    let hash := pre ++ Name.mkSimple s!"hash{i}"
    let valListTy := mkApp (mkConst ``List [.zero]) (mkConst ``Val)
    addData (hash ++ `parts) valListTy (toExpr parts)
    addData (hash ++ `bss) (mkApp (mkConst ``List [.zero]) natListTy) (toExpr bss)
    let input ← mkAppM ``List.flatten #[mkConst (hash ++ `bss)]
    let eqProof (tag : Lean.Name) (lhs rhs : Lean.Expr) : TermElabM Lean.Expr := do
      addChecked (hash ++ tag) (← mkEq lhs rhs) (← mkEqRefl lhs)
      return mkConst (hash ++ tag)
    let ctl ← mkAppM ``St.ctl #[s]
    let hc ← eqProof `control ctl (toExpr state.ctl)
    let ho ← eqProof `function (← mkAppM ``St.obj? #[s,mkRawNatLit f]) (toExpr (some obj))
    let hn ← eqProof `native (mkApp (mkConst ``Obj.kind) (toExpr obj)) (toExpr obj.kind)
    let parts := mkConst (hash ++ `parts)
    let hp ← eqProof `parts_checked (mkApp3 (mkConst ``elemsOf) F s (toExpr (arg args 0)))
      (← mkAppM ``M.pure #[← mkAppM ``Option.some #[parts]])
    let bytesFn := mkApp2 (mkConst ``partBytes) F s
    let hbLhs ← mkAppM ``List.mapM #[bytesFn,parts]
    let hb ← eqProof `bytes_checked hbLhs (← mkAppM ``Option.some #[mkConst (hash ++ `bss)])
    logInfo m!"host_sha256_step {pre} {i}: actual message projection checked"
    checkHash hash input bss.flatten
    let value := mkAppN (mkConst ``step_sha256) #[F,s,mkRawNatLit f,toExpr this,toExpr args,toExpr data,
      parts,toExpr obj,mkConst (hash ++ `bss),mkConst (hash ++ `digest),hc,ho,hn,hp,hb,mkConst (hash ++ `checked)]
    let stepLhs := mkApp2 (mkConst ``step) F s
    let ret ← mkAppM ``St.ret #[s,← mkAppM ``Val.str #[mkApp (mkConst ``hexBytes) (mkConst (hash ++ `digest))]]
    addChecked (hash ++ `step) (← mkEq stepLhs (← mkAppM ``M.pure #[ret])) value
    let halt := mkApp (mkConst ``isHalt) ctl
    let hh ← eqProof `nonhalt halt (mkConst ``Bool.false)
    let proof := mkAppN (mkConst ``runS_one_of_step) #[F,s,ret,srv,hh,mkConst (hash ++ `step)]
    let lhs := mkAppN (mkConst ``runS) #[F,mkRawNatLit 1,s,srv]
    let rhs ← mkAppM ``Option.some #[← mkAppM ``Prod.mk #[next,nsrv]]
    addChecked (indexed pre "c" i) (← mkEq lhs rhs) proof
    logInfo m!"host_sha256_step {pre} {i}: actual call and endpoint checked"

end Host.Load.Sha
