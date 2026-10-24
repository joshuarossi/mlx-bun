import host.load.boot.World
import host.load.PromptStream
import host.load.ReadTail
namespace Host.Load.Boot
open Lean Elab Command Meta Host.Ts Host.Ts.Stream Host.Load Host.Load.Sha Host.Load.Layers

/-! # Commands for the boot in `W`

The prompt stream `P` (`run/prompt/States`) holds the boot's boundary states `P.a<k> fw` and
servers `P.S<k>`. These commands check the same chunks in `W`, the boundary states with the
observer's state beside the load world's (`obsSt`). They only build terms; the kernel checks
every theorem.

* `boot_w_states P`: the observer's states at the boundaries, `P.ob<k> : OSt`, chosen from the
  trace of `P.a<k> []`: the log of program creates (numbered and their shares decoded as
  `FfiAne.ofTrace` does), the handles object frees release, the kernels' flags. Each is
  named per boundary (`P.oblog<k>`, `P.obfr<k>`, `P.obkr<k>`) as the previous one's updates, so a chunk
  check compares them by name. A wrong choice fails a chunk check.
* `boot_tail_states P keep 2`: the boundary states over every unread readback suffix, `P.at<k> fw tail`
  (`P.a<k> fw` with its native token queue after the two known heads replaced by `tail`, as
  `host_read_tail`), and the fixed suffix `P.tokenBase`;
* `boot_w_chunk P i`: `P.obc<i> : ∀ fw tail, runS W kᵢ (obsSt (P.at<i> fw tail) P.ob<i>) P.S<i> =
  some (obsSt (P.at<i+1> fw tail) P.ob<i+1>, P.S<i+1>)`, by eager `Eq.refl` (a read beyond the known heads
  leaves the kernel stuck);
* `boot_w_micro P i, A chunks [k₀, …]`: the same through subdivided steps, the intermediate states
  chosen by a native run from the boot (`PromptStream.promptBoot`);
* `boot_w_run P`: `P.obRun`, the chunks composed through named prefixes. -/

private def nm (pre : Lean.Name) (tag : String) (i : Nat) : Lean.Name :=
  pre ++ Lean.Name.mkSimple (tag ++ toString i)

private def valL : Lean.Expr := mkApp (mkConst ``List [.zero]) (mkConst ``Val)

private def one : Level := .succ .zero

private def addThm (name : Lean.Name) (type value : Lean.Expr) : CoreM Unit :=
  addDecl (.thmDecl { name, levelParams := [], type, value })

private def addDef (name : Lean.Name) (type value : Lean.Expr) : CoreM Unit :=
  addDecl (.defnDecl { name, levelParams := [], type, value, hints := .regular 0, safety := .safe })

private def eqE (u : Level) (α a b : Lean.Expr) : Lean.Expr := mkApp3 (mkConst ``Eq [u]) α a b

private partial def natE (e : Lean.Expr) : Option Nat :=
  match e with
  | .lit (.natVal n) => some n
  | .mdata _ b => natE b
  | _ => if e.isAppOfArity ``OfNat.ofNat 3 then natE e.appFn!.appArg! else none

private partial def natListE (e : Lean.Expr) : Option (List Nat) :=
  match e.getAppFn, e.getAppArgs with
  | .const ``List.nil _, #[_] => some []
  | .const ``List.cons _, #[_, h, t] => do pure ((← natE h) :: (← natListE t))
  | _, _ => none

private def constNats (n : Lean.Name) : MetaM (List Nat) := do
  let some v := (← getConstInfo n).value? | throwError "{n} has no value"
  let some l := natListE v | throwError "{n} is not a literal list of numbers"
  pure l

/-! ## Terms -/

private def wSt : Lean.Expr := mkApp (mkConst ``St) (mkApp (mkConst ``Ffi.S) (mkConst ``W))
private def pTy : Lean.Expr := mkApp2 (mkConst ``Prod [.zero, .zero]) wSt (mkConst ``SSrv)
private def oTy : Lean.Expr := mkApp (mkConst ``Option [.zero]) pTy
private def oStTy : Lean.Expr := mkConst ``OSt

private def obsE (s w : Lean.Expr) : Lean.Expr := mkApp2 (mkConst ``obsSt) s w

/-- `runS W n a S = some (b, T)` and its left side. -/
private def wEq (n : Nat) (a s b t : Lean.Expr) : Lean.Expr × Lean.Expr :=
  let lhs := mkAppN (mkConst ``runS) #[mkConst ``W, mkRawNatLit n, a, s]
  let rhs := mkApp2 (mkConst ``Option.some [.zero]) pTy (mkApp4 (mkConst ``Prod.mk [.zero, .zero]) wSt (mkConst ``SSrv) b t)
  (eqE one oTy lhs rhs, lhs)

/-! ## The trace -/

/-- The trace of a boundary state (an argument of its `Aux.mk`). -/
private def traceOf (pre : Lean.Name) (k : Nat) : MetaM Lean.Expr := do
  let c ← getConstInfo (nm pre "a" k)
  let some v := c.value? | throwError "boot_w: {nm pre "a" k} has no value"
  let b ← whnfR (v.bindingBody!.instantiate1 (mkApp (mkConst ``List.nil [.zero]) (mkConst ``Val)))
  unless b.isAppOfArity ``St.mk 6 do throwError "boot_w: {nm pre "a" k} is not a state literal"
  let aux ← whnfR b.appArg!
  unless aux.isAppOfArity ``Aux.mk 5 do throwError "boot_w: {nm pre "a" k}'s aux is not a literal"
  pure (aux.getArg! 3)

/-- The events of trace `t` before its tail `stop`, newest first, with their positions in `t`. -/
private partial def newEvents (t stop : Lean.Expr) : MetaM (Array (Lean.Expr × Nat)) := do
  let mut out := #[]
  let mut cur := t
  let mut i := 0
  repeat
    if cur == stop then break
    match cur with
    | .const n _ =>
      let some v := (← getConstInfo n).value? | throwError "boot_w: trace constant {n} has no value"
      cur := v
    | _ =>
      match cur.getAppFn, cur.getAppArgs with
      | .const ``List.cons _, #[_, h, tl] =>
        out := out.push (h, i)
        i := i + 1
        cur := tl
      | _, _ => throwError "boot_w: the trace does not end in the previous boundary's"
  return out

private partial def charsOf (e : Lean.Expr) : MetaM (List Char) := do
  let e ← whnf e
  match e.getAppFn, e.getAppArgs with
  | .const ``List.nil _, _ => return []
  | .const ``List.cons _, #[_, h, t] =>
    let k ← whnf (mkApp (mkConst ``Char.toNat) h)
    let some n := k.rawNatLit? <|> k.nat? | throwError "boot_w: not a character literal"
    return Char.ofNat n :: (← charsOf t)
  | _, _ => throwError "boot_w: not a name literal"

private def evalOptNat (e : Lean.Expr) : MetaM (Option Nat) := do
  let r ← whnf e
  if r.isAppOfArity ``Option.none 1 then return none
  unless r.isAppOfArity ``Option.some 2 do throwError "boot_w: not an option {r}"
  let v ← whnf r.appArg!
  let some n := v.rawNatLit? <|> v.nat? | throwError "boot_w: not a number {v}"
  return some n

private def evalOptBool (e : Lean.Expr) : MetaM (Option Bool) := do
  let r ← whnf e
  if r.isAppOfArity ``Option.none 1 then return none
  unless r.isAppOfArity ``Option.some 2 do throwError "boot_w: not an option {r}"
  let v ← whnf r.appArg!
  if v.isConstOf ``Bool.true then return some true
  if v.isConstOf ``Bool.false then return some false
  throwError "boot_w: not a boolean {v}"

private partial def listE (e : Lean.Expr) : MetaM (Array Lean.Expr) := do
  let e ← whnfR e
  match e.getAppFn, e.getAppArgs with
  | .const ``List.nil _, _ => return #[]
  | .const ``List.cons _, #[_, h, t] => return #[h] ++ (← listE t)
  | _, _ => throwError "boot_w: not a list literal"

/-- A natural-number pair `C r 0` (an `extPtr` argument, a `ptr` return). -/
private def regionOf (c : Lean.Name) (e : Lean.Expr) : MetaM (Option Nat) := do
  let e ← whnfR e
  unless e.isAppOfArity c 2 do return none
  let some r ← (do let v ← whnf (e.getArg! 0); pure (v.rawNatLit? <|> v.nat?)) | return none
  let o ← whnf (e.getArg! 1)
  unless (o.rawNatLit? <|> o.nat?) == some 0 do return none
  return some r

/-! ## The observer's states chosen from the trace -/

structure Ch where
  br : Lean.Expr
  fr : Lean.Expr
  kr : Lean.Expr
  n : Nat
  regions : List (Nat × Nat)
  brC : Bool := false
  frC : Bool := false
  krC : Bool := false

private def dfltEvent : Lean.Expr :=
  mkApp3 (mkConst ``Event.mk) (mkApp (mkConst ``List.nil [.zero]) (mkConst ``Char))
    (mkApp (mkConst ``List.nil [.zero]) (mkConst ``Arg)) (mkConst ``Ret.void)

private def symCreate : List Char := chars!"mbane_program_create"

/-- The observer's update for one event `ev` (an `Event.mk` literal; `ref` an expression of it the
kernel reduces cheaply), as the observer computes it on an accepted call. -/
private def chStep (c : Ch) (ev ref : Lean.Expr) : MetaM Ch := do
  unless ev.isAppOfArity ``Event.mk 3 do throwError "boot_w: not an event literal {ev}"
  let sym ← charsOf (ev.getArg! 0)
  let args ← listE (ev.getArg! 1)
  let ret := ev.getArg! 2
  let mut c := c
  match Host.Mlx.Ffi.symOf sym with
  | some x =>
    if args.size == 1 && isObjFree x then
      match ← evalOptNat (mkApp (mkConst ``Host.Mlx.Ffi.argNat) args[0]!) with
      | some 0 => pure ()
      | some h => c := { c with fr := mkApp3 (mkApp (mkConst ``PTrie.set) (mkConst ``Unit)) c.fr (mkRawNatLit h) (mkConst ``Unit.unit), frC := true }
      | none => throwError "boot_w: a free of no handle"
    match x with
    | .kernelNew =>
      let r ← whnfR ret
      if args.size == 7 && r.isAppOfArity ``Ret.big 1 then
        let hv ← whnf (mkApp (mkConst ``Int.toNat) r.appArg!)
        let some h := hv.rawNatLit? <|> hv.nat? | throwError "boot_w: kernel handle"
        let some rc ← evalOptBool (mkApp (mkConst ``Host.Mlx.Ffi.argBool) args[5]!) | throwError "boot_w: kernel flag"
        let some ao ← evalOptBool (mkApp (mkConst ``Host.Mlx.Ffi.argBool) args[6]!) | throwError "boot_w: kernel flag"
        let flags := mkApp (mkConst ``KRec.flags) c.kr
        let pair := mkApp4 (mkConst ``Prod.mk [.zero, .zero]) (mkConst ``Bool) (mkConst ``Bool) (toExpr rc) (toExpr ao)
        let flags' := mkApp4 (mkConst ``PTrie.set) (mkApp2 (mkConst ``Prod [.zero, .zero]) (mkConst ``Bool) (mkConst ``Bool))
          flags (mkRawNatLit h) pair
        c := { c with kr := mkApp2 (mkConst ``KRec.mk) flags' (mkApp (mkConst ``KRec.targs) c.kr), krC := true }
    | .cfgNew | .cfgDtype | .cfgInt | .kernelApply => throwError "boot_w: a kernel configuration call (not chosen)"
    | _ => pure ()
  | none => pure ()
  if nameEq sym symCreate then
    let share ← if args.size == 12 then do
        match ← regionOf ``Arg.extPtr args[8]! with
        | some r => pure ((c.regions.find? fun (x, _) => x == r).map Prod.snd)
        | none => pure none
      else pure none
    let regions ← do
      match ← regionOf ``Ret.ptr ret with
      | some r => pure ((r, c.n) :: c.regions)
      | none => pure c.regions
    let argsTy := mkApp (mkConst ``List [.zero]) (mkConst ``Arg)
    let shTy := mkApp (mkConst ``Option [.zero]) (mkConst ``Nat)
    let inner := mkApp4 (mkConst ``Prod.mk [.zero, .zero]) argsTy shTy (mkApp (mkConst ``Event.args) ref) (toExpr share)
    let entry := mkApp4 (mkConst ``Prod.mk [.zero, .zero]) (mkConst ``Nat) (mkApp2 (mkConst ``Prod [.zero, .zero]) argsTy shTy)
      (mkRawNatLit c.n) inner
    let entryTy := mkApp2 (mkConst ``Prod [.zero, .zero]) (mkConst ``Nat) (mkApp2 (mkConst ``Prod [.zero, .zero]) argsTy shTy)
    let br := mkApp3 (mkConst ``List.cons [.zero]) entryTy entry c.br
    c := { c with br, n := c.n + 1, regions, brC := true }
  return c

/-- A reference to position `i` of trace `t`. -/
private def refAt (t : Lean.Expr) (i : Nat) : Lean.Expr :=
  mkApp4 (mkConst ``List.getD [.zero]) (mkConst ``Event) t (mkRawNatLit i) dfltEvent

/-- Name the changed components `pre.ob*<k>` and the state `pre.ob<k>`. -/
private def nameCh (pre : Lean.Name) (k : Nat) (c : Ch) (prev : Option Nat) : CoreM Ch := do
  let def1 (tag : String) (ty : Lean.Expr) (e : Lean.Expr) (changed : Bool) : CoreM Lean.Expr := do
    match prev, changed with
    | some p, false => addDef (nm pre tag k) ty (mkConst (nm pre tag p))
    | _, _ => addDef (nm pre tag k) ty e
    pure (mkConst (nm pre tag k))
  let br ← def1 "oblog" (mkConst ``BLog) c.br c.brC
  let fr ← def1 "obfr" (mkApp (mkConst ``PTrie) (mkConst ``Unit)) c.fr c.frC
  let kr ← def1 "obkr" (mkConst ``KRec) c.kr c.krC
  let some' (α e : Lean.Expr) := mkApp2 (mkConst ``Option.some [.zero]) α e
  let w := mkApp4 (mkConst ``Prod.mk [.zero, .zero]) (mkConst ``BLog)
    (mkApp2 (mkConst ``Prod [.zero, .zero]) (mkApp (mkConst ``Option [.zero]) (mkApp (mkConst ``PTrie) (mkConst ``Unit)))
      (mkApp (mkConst ``Option [.zero]) (mkConst ``KRec))) br
    (mkApp4 (mkConst ``Prod.mk [.zero, .zero]) (mkApp (mkConst ``Option [.zero]) (mkApp (mkConst ``PTrie) (mkConst ``Unit)))
      (mkApp (mkConst ``Option [.zero]) (mkConst ``KRec)) (some' (mkApp (mkConst ``PTrie) (mkConst ``Unit)) fr)
      (some' (mkConst ``KRec) kr))
  addDef (nm pre "ob" k) oStTy w
  return { c with br, fr, kr, brC := false, frC := false, krC := false }

private def initCh : Ch :=
  { br := mkApp (mkConst ``List.nil [.zero]) (mkApp2 (mkConst ``Prod [.zero, .zero]) (mkConst ``Nat)
      (mkApp2 (mkConst ``Prod [.zero, .zero]) (mkApp (mkConst ``List [.zero]) (mkConst ``Arg))
        (mkApp (mkConst ``Option [.zero]) (mkConst ``Nat)))), fr := mkApp (mkConst ``PTrie.nil) (mkConst ``Unit),
    kr := mkConst ``KRec.empty, n := 0, regions := [] }

/-- The chooser's state at boundary `k` (unnamed components), walking the trace from boundary 0. -/
private def chAt (pre : Lean.Name) (k : Nat) : MetaM Ch := do
  let mut c := initCh
  let mut prevT ← traceOf pre 0
  for j in [1:k + 1] do
    let t ← traceOf pre j
    if t != prevT then
      let evs ← newEvents t prevT
      for (ev, i) in evs.reverse do
        c ← chStep c ev (refAt t i)
    prevT := t
  return c

elab "boot_w_states " p:ident : command => liftTermElabM <| withOptions (fun o => o.setBool `Elab.async false) do
  let pre := (← getCurrNamespace) ++ p.getId
  let ks ← constNats (pre ++ `ks)
  let t0 ← traceOf pre 0
  unless t0.isAppOf ``List.nil do throwError "boot_w_states: boundary 0 has calls in its trace"
  let mut c ← nameCh pre 0 initCh none
  let mut prevT := t0
  for k in [1:ks.length + 1] do
    let t ← traceOf pre k
    if t != prevT then
      let evs ← newEvents t prevT
      for (ev, i) in evs.reverse do
        c ← chStep c ev (refAt t i)
    c ← nameCh pre k c (some (k - 1))
    prevT := t
    Meta.resetCache
  logInfo m!"boot_w_states: {ks.length + 1} boundaries, {c.n} program creates"

/-! ## Boundary states over every unread readback suffix -/

private def numL : Lean.Expr := mkApp (mkConst ``List [.zero]) (mkConst ``NumV)

/-- The fixed suffix of the token queue after its `keep` known heads (`P.tokenBase`) and the boundary
states over every suffix `tail` (`P.at<k> fw tail`, `P.a<k>`'s token suffix replaced by `tail`;
nothing outside the token field of the native MLX state is abstracted, `ReadTail.abstractTail`). -/
elab "boot_tail_states " p:ident " keep " kp:num : command => liftTermElabM <| withOptions (fun o => o.setBool `Elab.async false) do
  let pre := (← getCurrNamespace) ++ p.getId
  let ks ← constNats (pre ++ `ks)
  let stTy := mkApp (mkConst ``St) (mkConst ``LSt)
  withLocalDeclD `fw valL fun fw => do
    let v0 := (← getConstInfo (nm pre "a" 0)).value!
    let some native := ReadTail.nativeState? (v0.beta #[fw]) | throwError "boot_tail_states: no native MLX state"
    let suffix ← match ReadTail.dropList kp.getNat native.getAppArgs[5]! with
      | .ok e => pure e
      | .error e => throwError "boot_tail_states: {e}"
    addDef (pre ++ `tokenBase) numL suffix
    for k in [0:ks.length + 1] do
      let v := (← getConstInfo (nm pre "a" k)).value!
      let body ← withLocalDeclD `tail numL fun tail => do
        let e ← match ReadTail.abstractTail suffix tail (v.beta #[fw]) with
          | .ok e => pure e
          | .error e => throwError "boot_tail_states: boundary {k}: {e}"
        mkLambdaFVars #[fw, tail] e
      addDef (nm pre "at" k) (← mkArrow valL (← mkArrow numL stTy)) body
      Meta.resetCache

/-! ## Chunks -/

private def stA (pre : Lean.Name) (k : Nat) (fw tail : Lean.Expr) : Lean.Expr :=
  obsE (mkApp2 (mkConst (nm pre "at" k)) fw tail) (mkConst (nm pre "ob" k))

private def withFT {α : Type} (k : Lean.Expr → Lean.Expr → TermElabM α) : TermElabM α :=
  withLocalDeclD `fw valL fun fw => withLocalDeclD `tail numL fun tail => k fw tail

private def eagerOf (body : Lean.Expr) : MetaM Lean.Expr := do
  let some (α, a, b) := body.eq? | throwError "boot_w: not an equation"
  pure (Run.Tail.eagerRefl one α a b)

elab "boot_w_chunk " p:ident i:num : command => liftTermElabM do
  let pre := (← getCurrNamespace) ++ p.getId
  let k := i.getNat
  let ks ← constNats (pre ++ `ks)
  let some n := ks[k]? | throwError "boot_w_chunk: no chunk {k}"
  withFT fun fw tail => do
    let (body, _) := wEq n (stA pre k fw tail) (mkConst (nm pre "S" k)) (stA pre (k + 1) fw tail) (mkConst (nm pre "S" (k + 1)))
    addThm (nm pre "obc" k) (← mkForallFVars #[fw, tail] body) (← mkLambdaFVars #[fw, tail] (← eagerOf body))

/-! ## Subdivided chunks -/

private def absAt (g : G) (s : St LSt) (addr i : Nat) : TermElabM (Lean.Expr × G) := do
  let some ob := s.obj? addr | throwError "boot_w_micro: no object at {addr}"
  let .array _ := ob.kind | throwError "boot_w_micro: {addr} is not an array"
  let s' := s.setObj addr { ob with kind := .array [absSentinel] }
  Memo.beginEpoch
  let r : Lean.Expr × Host.Ts.Stream.G ← liftM ((Host.Ts.Stream.stE (S := LSt) (fun x => StreamExpr.ser x) (mkConst ``LSt) s' (some addr)).run { g with idx := i, count := 0, defs := #[] } : IO _)
  let (aE, g) := r
  let body := absReplace (toExpr absSentinel) aE
  unless body.hasLooseBVars do throwError "boot_w_micro: the abstracted array was not found at boundary {i}"
  return (body, g)

private def natListTy : Lean.Expr := mkApp (mkConst ``List [.zero]) (mkConst ``Nat)

private def checkHash (pre : Lean.Name) (msgExpr : Lean.Expr) (msg : List Nat) : TermElabM Unit := do
  addDef (pre ++ `msg) natListTy msgExpr
  let padded := pad msg
  unless padded.length % 64 == 0 do throwError "boot_w_micro: invalid SHA-256 padding"
  let blocks := (List.range (padded.length / 64)).map fun i => (padded.drop (i * 64)).take 64
  let count := blocks.length
  addDef (nm pre "h" 0) natListTy (mkConst ``shaH0)
  let mut h := shaH0
  for (block, i) in blocks.zipIdx do
    addDef (nm pre "b" i) natListTy (toExpr block)
    h := shaBlock h block
    addDef (nm pre "h" (i + 1)) natListTy (toExpr h)
    let lhs := mkApp2 (mkConst ``shaBlock) (mkConst (nm pre "h" i)) (mkConst (nm pre "b" i))
    addThm (nm pre "block" i) (← mkEq lhs (mkConst (nm pre "h" (i + 1)))) (← mkEqRefl lhs)
    Meta.resetCache
  addDef (nm pre "tail" count) natListTy (toExpr ([] : List Nat))
  let blocksE (fuel : Nat) (h bs : Lean.Expr) := mkApp3 (mkConst ``shaBlocks) (mkRawNatLit fuel) h bs
  let final := mkConst (nm pre "h" count)
  let finalLhs := blocksE 1 final (mkConst (nm pre "tail" count))
  addThm (nm pre "suffix" count) (← mkEq finalLhs final) (← mkEqRefl finalLhs)
  for i in (List.range count).reverse do
    let block := mkConst (nm pre "b" i)
    let rest := mkConst (nm pre "tail" (i + 1))
    addDef (nm pre "tail" i) natListTy (← mkAppM ``List.append #[block, rest])
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
  addDef (pre ++ `digest) natListTy (toExpr (h.flatMap (beBytes 4)))
  addThm (pre ++ `checked) (← mkEq (mkApp (mkConst ``sha256) input) (mkConst (pre ++ `digest))) value

/-- A one-step piece whose step calls the native SHA-256 host function, in `W` (states `s`, `t` and
servers over the local prompt and suffix): its equation and proof. -/
private def shaStepW (hash : Lean.Name) (state : St LSt) (s t srv nextS : Lean.Expr) :
    TermElabM (Option (Lean.Expr × Lean.Expr)) := do
  let .call (.obj f) this args := state.ctl | return none
  let some obj := state.obj? f | return none
  let .fn (.native (.host .sha256) data) := obj.kind | return none
  let .pure (some parts) := M.run (elemsOf Host.Load.ffi state (arg args 0)) | throwError "boot_w_micro: unsupported SHA-256 parts"
  let some bss := parts.mapM (partBytes Host.Load.ffi state) | throwError "boot_w_micro: unsupported SHA-256 part bytes"
  addDef (hash ++ `parts) valL (toExpr parts)
  addDef (hash ++ `bss) (mkApp (mkConst ``List [.zero]) natListTy) (toExpr bss)
  checkHash hash (← mkAppM ``List.flatten #[mkConst (hash ++ `bss)]) bss.flatten
  let F := mkConst ``W
  let partsE := mkConst (hash ++ `parts)
  let eqProof (lhs rhs : Lean.Expr) : TermElabM Lean.Expr := do
    let α ← inferType lhs
    return Run.Tail.eagerRefl (← getLevel α) α lhs rhs
  let ctl ← mkAppM ``St.ctl #[s]
  let hc ← eqProof ctl (toExpr state.ctl)
  let ho ← eqProof (← mkAppM ``St.obj? #[s, mkRawNatLit f]) (toExpr (some obj))
  let hn ← eqProof (mkApp (mkConst ``Obj.kind) (toExpr obj)) (toExpr obj.kind)
  let hp ← eqProof (mkApp3 (mkConst ``elemsOf) F s (toExpr (arg args 0)))
    (← mkAppM ``M.pure #[← mkAppM ``Option.some #[partsE]])
  let hb ← eqProof (← mkAppM ``List.mapM #[mkApp2 (mkConst ``partBytes) F s, partsE])
    (← mkAppM ``Option.some #[mkConst (hash ++ `bss)])
  let stepProof := mkAppN (mkConst ``step_sha256) #[F, s, mkRawNatLit f, toExpr this, toExpr args, toExpr data,
    partsE, toExpr obj, mkConst (hash ++ `bss), mkConst (hash ++ `digest), hc, ho, hn, hp, hb, mkConst (hash ++ `checked)]
  let ret ← mkAppM ``St.ret #[s, ← mkAppM ``Val.str #[mkApp (mkConst ``hexBytes) (mkConst (hash ++ `digest))]]
  let hh ← eqProof (mkApp (mkConst ``isHalt) ctl) (mkConst ``Bool.false)
  let oneStep := mkAppN (mkConst ``runS_one_of_step) #[F, s, ret, srv, hh, stepProof]
  let (ty, lhs) := wEq 1 s srv t nextS
  let mid := mkApp2 (mkConst ``Option.some [.zero]) pTy (mkApp4 (mkConst ``Prod.mk [.zero, .zero]) wSt (mkConst ``SSrv) ret srv)
  let some (_, _, rhs) := ty.eq? | throwError "boot_w_micro: internal"
  let pf := mkAppN (mkConst ``Eq.trans [one]) #[oTy, lhs, mid, rhs, oneStep, Run.Tail.eagerRefl one oTy mid rhs]
  return some (ty, pf)

private def microW (pre : Lean.Name) (i addr : Nat) (sizes : List Nat) : TermElabM Unit := do
  let ks ← constNats (pre ++ `ks)
  let some fuel := ks[i]? | throwError "boot_w_micro: no outer chunk {i}"
  unless sizes.all (· > 0) && sizes.foldl (· + ·) 0 == fuel do
    throwError "boot_w_micro: chunks must be positive and sum to the outer fuel {fuel}"
  astTabRef.set (← loadAstTab)
  Memo.reset
  let micro := pre ++ Lean.Name.mkSimple s!"obmicro{i}"
  let suffix := (← getConstInfo (pre ++ `tokenBase)).value!
  -- the chooser at boundary `i` (named by `boot_w_states`) and the chunk's events, oldest first
  let c0 ← chAt pre i
  let c0 : Ch := { c0 with br := mkConst (nm pre "oblog" i), fr := mkConst (nm pre "obfr" i), kr := mkConst (nm pre "obkr" i) }
  let tI ← traceOf pre i
  let tN ← traceOf pre (i + 1)
  let evs0 ← if tN == tI then pure #[] else newEvents tN tI
  let evs := evs0.reverse
  let some b := PromptStream.promptBoot | throwError "boot_w_micro: the boot failed"
  let srv0 : SSrv := ⟨Decode.tab, []⟩
  let some (s0, c0s) := runFast Host.Load.ffi ((ks.take i).foldl (· + ·) 0) b srv0
    | throwError "boot_w_micro: the run to chunk {i} is stuck"
  unless c0s.tab.length == Decode.tab.length do throwError "boot_w_micro: the run to chunk {i} extends the table"
  let base := s0.trace.length
  let stTy := mkApp (mkConst ``St) (mkConst ``LSt)
  withFT fun fw tail => do
  let mut s := s0
  let mut srv := c0s
  let mut g : G := { pre := micro }
  let mut ch := c0
  let mut used := 0
  let mut prevA := stA pre i fw tail
  let mut prevS := mkConst (nm pre "S" i)
  let mut consumed := 0
  let mut composed : Option Lean.Name := none
  for (k, j) in sizes.zipIdx do
    let before := s
    let some (s', c') := runFast Host.Load.ffi k s srv
      | throwError "boot_w_micro: stuck after {consumed} steps of chunk {i}"
    s := s'
    srv := c'
    let last := j + 1 == sizes.length
    let (nextA, nextS) ← if last then pure (stA pre (i + 1) fw tail, mkConst (nm pre "S" (i + 1))) else do
      let (body, g') ← absAt g s addr (j + 1)
      for (n, ty, v) in g'.defs do addDef n ty v
      let bodyT ← match ReadTail.abstractTail suffix tail (body.instantiate1 fw) with
        | .ok e => pure e
        | .error e => throwError "boot_w_micro: piece {j + 1}: {e}"
      addDef (nm micro "at" (j + 1)) (← mkArrow valL (← mkArrow numL stTy)) (← mkLambdaFVars #[fw, tail] bodyT)
      g := sweep { g' with defs := #[] } #[body]
      -- the observer's state after this piece's calls
      let upto := s.trace.length - base
      for (ev, idx) in evs.extract used upto do
        ch ← chStep ch ev (refAt tN idx)
      used := upto
      ch ← nameCh micro (j + 1) ch none
      pure (obsE (mkApp2 (mkConst (nm micro "at" (j + 1))) fw tail) (mkConst (nm micro "ob" (j + 1))), mkConst (nm pre "S" i))
    let (body, _) := wEq k prevA prevS nextA nextS
    let sha ← if k == 1 then shaStepW (micro ++ Lean.Name.mkSimple s!"hash{j}") before prevA nextA prevS nextS
      else pure none
    let (ty, pf) ← match sha with
      | some p => pure p
      | none => pure (body, ← eagerOf body)
    addThm (nm micro "obc" j) (← mkForallFVars #[fw, tail] ty) (← mkLambdaFVars #[fw, tail] pf)
    let step := mkApp2 (mkConst (nm micro "obc" j)) fw tail
    let startA := stA pre i fw tail
    let startS := mkConst (nm pre "S" i)
    let value := match composed with
      | none => step
      | some q => mkAppN (mkConst ``runS_trans) #[mkConst ``W, mkRawNatLit consumed, mkRawNatLit k, startA, prevA, nextA,
          startS, prevS, nextS, mkApp2 (mkConst q) fw tail, step]
    let (ty, _) := wEq (consumed + k) startA startS nextA nextS
    addThm (nm micro "up" (j + 1)) (← mkForallFVars #[fw, tail] ty) (← mkLambdaFVars #[fw, tail] value)
    composed := some (nm micro "up" (j + 1))
    consumed := consumed + k
    prevA := nextA
    prevS := nextS
    Meta.resetCache
  let some q := composed | throwError "boot_w_micro: no chunks"
  let (ty, _) := wEq fuel (stA pre i fw tail) (mkConst (nm pre "S" i)) (stA pre (i + 1) fw tail) (mkConst (nm pre "S" (i + 1)))
  addThm (nm pre "obc" i) (← mkForallFVars #[fw, tail] ty) (← mkLambdaFVars #[fw, tail] (mkApp2 (mkConst q) fw tail))
  Memo.reset

elab "boot_w_micro " p:ident i:num ", " addr:num " chunks " "[" cs:num,* "]" : command =>
  liftTermElabM <| withOptions (fun o => o.setBool `Elab.async false) do
    microW ((← getCurrNamespace) ++ p.getId) i.getNat addr.getNat (cs.getElems.map (·.getNat)).toList

/-! ## Composition -/

/-- `P.obRun : ∀ fw tail, runS W (k₀ + … + k_{N-1}) (obsSt (P.at0 fw tail) P.ob0) P.S0 =
some (obsSt (P.at<N> fw tail) P.ob<N>, P.S<N>)` through named prefixes. -/
elab "boot_w_run " p:ident : command =>
  liftTermElabM <| withOptions (fun o => o.setBool `Elab.async false) do
    let pre := (← getCurrNamespace) ++ p.getId
    let ks ← constNats (pre ++ `ks)
    let S (k : Nat) := mkConst (nm pre "S" k)
    withFT fun fw tail => do
    let mut total := 0
    let mut prev : Option Lean.Name := none
    for (k, i) in ks.zipIdx do
      let step := mkApp2 (mkConst (nm pre "obc" i)) fw tail
      let value := match prev with
        | none => step
        | some q => mkAppN (mkConst ``runS_trans) #[mkConst ``W, mkRawNatLit total, mkRawNatLit k, stA pre 0 fw tail,
            stA pre i fw tail, stA pre (i + 1) fw tail, S 0, S i, S (i + 1), mkApp2 (mkConst q) fw tail, step]
      total := total + k
      let (ty, _) := wEq total (stA pre 0 fw tail) (S 0) (stA pre (i + 1) fw tail) (S (i + 1))
      addThm (nm pre "obPrefix" (i + 1)) (← mkForallFVars #[fw, tail] ty) (← mkLambdaFVars #[fw, tail] value)
      prev := some (nm pre "obPrefix" (i + 1))
    let some q := prev | throwError "boot_w_run: empty chain"
    let (ty, _) := wEq total (stA pre 0 fw tail) (S 0) (stA pre ks.length fw tail) (S ks.length)
    addThm (pre ++ `obRun) (← mkForallFVars #[fw, tail] ty) (← mkLambdaFVars #[fw, tail] (mkApp2 (mkConst q) fw tail))

end Host.Load.Boot
