import host.ts.Memo
import host.ts.Link
namespace Host.Ts
open Lean Elab Command Meta

/-! # Chained linking, kernel-checked

`link_chain P : cx, w, [n₁, …, n_N]` adds the link states `P.x0 … P.xN`
(`P.x0` the realm over the FFI state `w`, `P.x(i+1)` after `nᵢ₊₁` more link
steps of `cx`, computed natively); `link_chunk P i` (one file each) adds
`P.l<i> : linkRun P.cx kᵢ nᵢ P.x<i> = some P.x<i+1>`, checked by the kernel
alone; `link_chain_run P` composes them into
`P.link : linkRun P.cx 0 (n₁ + … + n_N) (LinkSt.init P.w) = some P.xN` and,
when the last state is done, `P.booted : ∀ m ≥ …, bootL P.cx P.w m = some P.xN.st`.
As with `host_chain`, the elaborator only chooses the states. -/

instance : ToExpr LMod where
  toExpr m := mkAppN (mkConst ``LMod.mk) #[toExpr m.path, serNamed serModule m.items, toExpr m.own, toExpr m.ns, toExpr m.nsCell]
  toTypeExpr := mkConst ``LMod

instance {S : Type} [ToExpr S] : ToExpr (LinkSt S) where
  toExpr x := mkAppN (mkConst ``LinkSt.mk) #[toTypeExpr S, toExpr x.st, toExpr x.mods, toExpr x.order, toExpr x.bodies, toExpr x.done]
  toTypeExpr := mkApp (mkConst ``LinkSt) (toTypeExpr S)

/-- Serialized link states, memoizing modules and bodies by identity: consecutive
states share every module and body already linked. -/
unsafe def linkStatesImpl {S : Type} (cx : LinkCx S) (serS : S → Lean.Expr) (tyS : Lean.Expr) (w : S) (ns : List Nat) :
    Option (List (Lean.Expr × Bool)) :=
  letI : ToExpr S := ⟨serS, tyS⟩
  let ser (memo : Std.HashMap USize Lean.Expr) (x : LinkSt S) : Lean.Expr × Std.HashMap USize Lean.Expr :=
    let (mods, memo) := x.mods.foldr (fun m (acc, memo) =>
      let k := ptrAddrUnsafe m
      match memo[k]? with
      | some e => (mkApp3 (mkConst ``List.cons [.zero]) (mkConst ``LMod) e acc, memo)
      | none => let e := toExpr m; (mkApp3 (mkConst ``List.cons [.zero]) (mkConst ``LMod) e acc, memo.insert k e))
      (mkApp (mkConst ``List.nil [.zero]) (mkConst ``LMod), memo)
    let bTy := toTypeExpr (List Stmt × Env)
    let (bodies, memo) := x.bodies.foldr (fun b (acc, memo) =>
      let k := ptrAddrUnsafe b
      match memo[k]? with
      | some e => (mkApp3 (mkConst ``List.cons [.zero]) bTy e acc, memo)
      | none => let e := toExpr b; (mkApp3 (mkConst ``List.cons [.zero]) bTy e acc, memo.insert k e))
      (mkApp (mkConst ``List.nil [.zero]) bTy, memo)
    (mkAppN (mkConst ``LinkSt.mk) #[tyS, toExpr x.st, mods, toExpr x.order, bodies, toExpr x.done], memo)
  let rec go (k : Nat) (x : LinkSt S) (memo : Std.HashMap USize Lean.Expr) : List Nat → Option (List (Lean.Expr × Bool))
    | [] => some []
    | n :: ns => (linkRun cx k n x).bind fun x' =>
      let (e, memo) := ser memo x'
      (go (k + n) x' memo ns).map ((e, x'.done) :: ·)
  let x0 := LinkSt.init w
  let (e0, memo) := ser {} x0
  (go 0 x0 memo ns).map ((e0, x0.done) :: ·)

@[implemented_by linkStatesImpl]
opaque linkStates {S : Type} (cx : LinkCx S) (serS : S → Lean.Expr) (tyS : Lean.Expr) (w : S) (ns : List Nat) :
    Option (List (Lean.Expr × Bool))

theorem linkRun_trans {S : Type} (cx : LinkCx S) {k m n : Nat} {x₀ x₁ x₂ : LinkSt S}
    (h₁ : linkRun cx k m x₀ = some x₁) (h₂ : linkRun cx (k + m) n x₁ = some x₂) :
    linkRun cx k (m + n) x₀ = some x₂ := by
  rw [linkRun_add, h₁]; exact h₂

/-- A finished link boots with any larger step count. -/
theorem boot_of_link {S : Type} (cx : LinkCx S) (w : S) {K : Nat} {x : LinkSt S}
    (h : linkRun cx 0 K (LinkSt.init w) = some x) (hd : x.done = true) :
    ∀ m, K ≤ m → bootL cx w m = some x.st := by
  intro m hm
  obtain ⟨d, rfl⟩ := Nat.exists_eq_add_of_le hm
  unfold bootL
  rw [linkRun_add, h]
  simp [linkRun_done cx _ x hd]

private def lname (pre : Lean.Name) (s : String) (i : Nat) : Lean.Name := pre ++ Name.mkSimple (s ++ toString i)

elab "link_chain " p:ident " : " cx:term ", " w:term ", " ns:term fixed:((" fixed_ffi")?) : command => liftTermElabM do
  let pre := (← getCurrNamespace) ++ p.getId
  let wE ← instantiateMVars (← Term.elabTermAndSynthesize w none)
  let sTy ← instantiateMVars (← inferType wE)
  let cxTy := mkApp (mkConst ``LinkCx) sTy
  let cxE ← instantiateMVars (← Term.elabTermAndSynthesize cx (some cxTy))
  let nsV ← unsafe evalExpr (List Nat) (mkApp (mkConst ``List [.zero]) (mkConst ``Nat))
    (← instantiateMVars (← Term.elabTermAndSynthesize ns (some (mkApp (mkConst ``List [.zero]) (mkConst ``Nat)))))
  astTabRef.set (← loadAstTab)
  let sRed ← whnf sTy
  -- This opt-in mode chooses the original world term for every FFI field.
  -- It only saves repeated serialization: a host export that changes FFI
  -- makes the subsequent ordinary `link_chunk` equality fail.
  let serS ← if fixed.raw.getArgs.isEmpty then
      mkAppOptM ``Lean.ToExpr.toExpr #[sRed, none]
    else do
      let .const worldName [] := wE
        | throwError "link_chain fixed_ffi: expected a monomorphic named world"
      let levels := mkApp (mkConst ``List.nil [.zero]) (mkConst ``Lean.Level)
      let quotedWorld := mkApp2 (mkConst ``Lean.Expr.const) (toExpr worldName) levels
      pure (mkLambda `s .default sRed quotedWorld)
  let tyS ← mkAppOptM ``Lean.ToExpr.toTypeExpr #[sRed, none]
  Memo.reset
  let call := mkAppN (mkConst ``linkStates) #[sTy, cxE, serS, tyS, wE, toExpr nsV]
  let t0 ← IO.monoMsNow
  let some states ← unsafe evalExpr (Option (List (Lean.Expr × Bool))) (← inferType call) call
    | throwError "link_chain: a link step failed natively"
  let states := ShareCommon.shareCommon' states
  let xTy := mkApp (mkConst ``LinkSt) sTy
  let add (n : Lean.Name) (ty v : Lean.Expr) := addDecl (Declaration.defnDecl { name := n, levelParams := [], type := ty, value := v, hints := .regular 0, safety := .safe })
  add (pre ++ `cx) cxTy cxE
  add (pre ++ `w) sTy wE
  let nsTy := mkApp (mkConst ``List [.zero]) (mkConst ``Nat)
  addDecl (Declaration.defnDecl { name := pre ++ `ns, levelParams := [], type := nsTy, value := toExpr nsV, hints := .abbrev, safety := .safe })
  compileDecl (Declaration.defnDecl { name := pre ++ `ns, levelParams := [], type := nsTy, value := toExpr nsV, hints := .abbrev, safety := .safe })
  let mut i := 0
  for (e, _) in states do
    add (lname pre "x" i) xTy e
    i := i + 1
  let sizes := states.map fun (e, d) => toString (exprSize e) ++ "/" ++ toString (dagSize e) ++ (if d then "d" else "")
  logInfo m!"link_chain {pre}: {states.length} states, native {(← IO.monoMsNow) - t0} ms; tree/dag size {sizes}"

private def linkNs (pre : Lean.Name) : MetaM (List Nat) := unsafe evalConst (List Nat) (pre ++ `ns)

private def xTyOf (pre : Lean.Name) : MetaM Lean.Expr := do
  let some (.defnInfo d) := (← getEnv).find? (pre ++ `w) | throwError "no link chain {pre}"
  pure (mkApp (mkConst ``LinkSt) d.type)

private def linkRunE (pre : Lean.Name) (sTy : Lean.Expr) (k n : Nat) (x : Lean.Expr) : Lean.Expr :=
  mkAppN (mkConst ``linkRun) #[sTy, mkConst (pre ++ `cx), mkRawNatLit k, mkRawNatLit n, x]

private def someX (xTy x : Lean.Expr) : Lean.Expr := mkApp2 (mkConst ``Option.some [.zero]) xTy x

/-- `link_chunk P i`: `P.l<i> : linkRun P.cx kᵢ nᵢ P.x<i> = some P.x<i+1>` (kernel). -/
elab "link_chunk " p:ident i:num : command => liftTermElabM do
  let pre := (← getCurrNamespace) ++ p.getId
  let i := i.getNat
  let ns ← linkNs pre
  let some n := ns[i]? | throwError "no link chunk {i}"
  let k := (ns.take i).foldl (· + ·) 0
  let xTy ← xTyOf pre
  let sTy := xTy.appArg!
  let lhs := linkRunE pre sTy k n (mkConst (lname pre "x" i))
  let oTy := mkApp (mkConst ``Option [.zero]) xTy
  let ty := mkApp3 (mkConst ``Eq [.succ .zero]) oTy lhs (someX xTy (mkConst (lname pre "x" (i + 1))))
  addDecl (.thmDecl { name := lname pre "l" i, levelParams := [], type := ty, value := mkApp2 (mkConst ``Eq.refl [.succ .zero]) oTy lhs })

/-- `link_chain_run P`: `P.x0_eq`, `P.link` and (for a finished link) `P.booted`. -/
elab "link_chain_run " p:ident : command => liftTermElabM do
  let pre := (← getCurrNamespace) ++ p.getId
  let ns ← linkNs pre
  let xTy ← xTyOf pre
  let sTy := xTy.appArg!
  let x0 := mkConst (lname pre "x" 0)
  let xInit := mkApp2 (mkConst ``LinkSt.init) sTy (mkConst (pre ++ `w))
  let ty0 := mkApp3 (mkConst ``Eq [.succ .zero]) xTy xInit x0
  let pf0 := mkApp2 (mkConst ``Eq.refl [.succ .zero]) xTy xInit
  addDecl (.thmDecl { name := pre ++ `x0_eq, levelParams := [], type := ty0, value := pf0 })
  -- compose: linkRun cx 0 (n₁ + … + nᵢ) x0 = some xᵢ
  let mut fuel := ns.head!
  let mut pf := mkConst (lname pre "l" 0)
  let mut i := 1
  for n in ns.tail do
    pf := mkAppN (mkConst ``linkRun_trans) #[sTy, mkConst (pre ++ `cx), mkRawNatLit 0, mkRawNatLit fuel, mkRawNatLit n,
      x0, mkConst (lname pre "x" i), mkConst (lname pre "x" (i + 1)), pf, mkConst (lname pre "l" i)]
    fuel := fuel + n
    i := i + 1
  let oTy := mkApp (mkConst ``Option [.zero]) xTy
  let xN := mkConst (lname pre "x" ns.length)
  let ty := mkApp3 (mkConst ``Eq [.succ .zero]) oTy (linkRunE pre sTy 0 fuel x0) (someX xTy xN)
  addDecl (.thmDecl { name := pre ++ `link0, levelParams := [], type := ty, value := pf })
  let tyI := mkApp3 (mkConst ``Eq [.succ .zero]) oTy (linkRunE pre sTy 0 fuel xInit) (someX xTy xN)
  -- rewrite x0 to `LinkSt.init w`
  let motive ← withLocalDeclD `y xTy fun y => do
    mkLambdaFVars #[y] (mkApp3 (mkConst ``Eq [.succ .zero]) oTy (linkRunE pre sTy 0 fuel y) (someX xTy xN))
  let pfInit := mkAppN (mkConst ``Eq.mpr [.zero]) #[mkApp motive xInit, mkApp motive x0,
    mkAppN (mkConst ``congrArg [.succ .zero, .succ .zero]) #[xTy, mkSort .zero, xInit, x0, motive, mkConst (pre ++ `x0_eq)], mkConst (pre ++ `link0)]
  addDecl (.thmDecl { name := pre ++ `link, levelParams := [], type := tyI, value := pfInit })
  -- a finished link boots
  let doneE := mkAppN (mkConst ``LinkSt.done) #[sTy, xN]
  let boolT := mkConst ``Bool
  let doneTy := mkApp3 (mkConst ``Eq [.succ .zero]) boolT doneE (mkConst ``Bool.true)
  addDecl (.thmDecl { name := pre ++ `done, levelParams := [], type := doneTy, value := mkApp2 (mkConst ``Eq.refl [.succ .zero]) boolT doneE })
  let bootPf := mkAppN (mkConst ``boot_of_link) #[sTy, mkConst (pre ++ `cx), mkConst (pre ++ `w), mkRawNatLit fuel, xN,
    mkConst (pre ++ `link), mkConst (pre ++ `done)]
  addDecl (.thmDecl { name := pre ++ `booted, levelParams := [], type := ← inferType bootPf, value := bootPf })

end Host.Ts
