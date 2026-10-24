import host.sim.full.BridgeCall

/-! # The bridge's own calls in the full world

`mbane_input`, `mbane_output`, `mbane_eval_async`, `mbane_wait` and `mbane_free` decode their program
handle through the load world's host objects, which the relation keeps (`G.LoadR.host`, the host
regions fixed), and act on the bridge alone (`BRel.input`, …): the full world's call is pure, the
mlx state and the observers' states unchanged (`fullOpSim`). -/

namespace Host.Ts.Sim.Full
open Host.Ts Host.Ts.Sim Host.Load.Layers

/-- The bridge's own call `name`: its handle argument and its action on the bridge. -/
def bridgeOp (name : Name) (args : List Arg) : Option (Arg × (BSt → Nat → Option (BSt × Ret))) :=
  bif nameEq name chars!"mbane_input" then (match args with | [h, i] => some (h, fun b n => Host.Mlx.FfiAne.input b n i) | _ => none)
  else bif nameEq name chars!"mbane_output" then (match args with | [h] => some (h, Host.Mlx.FfiAne.output) | _ => none)
  else bif nameEq name chars!"mbane_eval_async" then (match args with | [h] => some (h, Host.Mlx.FfiAne.evalAsync) | _ => none)
  else bif nameEq name chars!"mbane_wait" then (match args with | [h, _, _] => some (h, Host.Mlx.FfiAne.wait) | _ => none)
  else bif nameEq name chars!"mbane_free" then (match args with | [h] => some (h, Host.Mlx.FfiAne.free) | _ => none)
  else none

/-- A bridge call's action on related bridges gives related results, the bridge's activity kept and a
literal return. -/
def OpRel (F F' : BSt → Nat → Option (BSt × Ret)) : Prop :=
  ∀ (M : Map) (nx ny : Nat) (b b' : BSt) (n : Nat) (b1 : BSt) (r : Ret), BRel M nx ny b b' → F b n = some (b1, r) →
    ∃ b1', F' b' n = some (b1', r) ∧ BRel M nx ny b1 b1' ∧ b1.active = b.active ∧ ∀ M' : Map, M'.ret r = r

theorem input_fixed {b b1 : BSt} {n : Nat} {i : Arg} {r : Ret} (e : Host.Mlx.FfiAne.input b n i = some (b1, r)) :
    b1.active = b.active ∧ ∀ M : Map, M.ret r = r := by
  unfold Host.Mlx.FfiAne.input at e
  split at e
  · simp only [Bool.cond_eq_ite] at e
    split at e <;> (simp only [Option.some.injEq, Prod.mk.injEq] at e; obtain ⟨rfl, rfl⟩ := e; exact ⟨rfl, fun _ => rfl⟩)
  · cases e

theorem output_fixed {b b1 : BSt} {n : Nat} {r : Ret} (e : Host.Mlx.FfiAne.output b n = some (b1, r)) :
    b1.active = b.active ∧ ∀ M : Map, M.ret r = r := by
  unfold Host.Mlx.FfiAne.output at e
  cases hp : Host.Mlx.FfiAne.program? b n with
  | none => rw [hp] at e; cases e
  | some qp => rw [hp] at e; cases e; exact ⟨rfl, fun _ => rfl⟩

theorem evalAsync_fixed {b b1 : BSt} {n : Nat} {r : Ret} (e : Host.Mlx.FfiAne.evalAsync b n = some (b1, r)) :
    b1.active = b.active ∧ ∀ M : Map, M.ret r = r := by
  unfold Host.Mlx.FfiAne.evalAsync at e
  split at e
  · simp only [Bool.cond_eq_ite] at e
    repeat' split at e
    all_goals first
      | (simp only [Option.some.injEq, Prod.mk.injEq] at e; obtain ⟨rfl, rfl⟩ := e; exact ⟨rfl, fun _ => rfl⟩)
      | cases e
  · cases e

theorem wait_fixed {b b1 : BSt} {n : Nat} {r : Ret} (e : Host.Mlx.FfiAne.wait b n = some (b1, r)) :
    b1.active = b.active ∧ ∀ M : Map, M.ret r = r := by
  unfold Host.Mlx.FfiAne.wait at e
  split at e
  · simp only [Bool.cond_eq_ite] at e
    split at e <;> (simp only [Option.some.injEq, Prod.mk.injEq] at e; obtain ⟨rfl, rfl⟩ := e; exact ⟨rfl, fun _ => rfl⟩)
  · cases e

theorem free_fixed {b b1 : BSt} {n : Nat} {r : Ret} (e : Host.Mlx.FfiAne.free b n = some (b1, r)) :
    b1.active = b.active ∧ ∀ M : Map, M.ret r = r := by
  unfold Host.Mlx.FfiAne.free at e
  cases hp : Host.Mlx.FfiAne.program? b n with
  | none => rw [hp] at e; cases e
  | some qp =>
    rw [hp] at e
    obtain ⟨q, p⟩ := qp
    simp only [Option.map_some, Option.some.injEq] at e
    cases hh : Nat.beq p.holders 1 <;> rw [hh] at e <;> simp only [Bool.cond_false, Bool.cond_true] at e <;>
      (simp only [Prod.mk.injEq] at e; obtain ⟨rfl, rfl⟩ := e; exact ⟨rfl, fun _ => rfl⟩)

theorem opRel_input (i i' : Arg) (hi : Host.Mlx.Ffi.argInt i' = Host.Mlx.Ffi.argInt i) :
    OpRel (fun b n => Host.Mlx.FfiAne.input b n i) (fun b n => Host.Mlx.FfiAne.input b n i') := by
  intro M nx ny b b' n b1 r h e
  have e' : Host.Mlx.FfiAne.input b n i' = some (b1, r) := by
    unfold Host.Mlx.FfiAne.input at e ⊢; rw [hi]; exact e
  obtain ⟨b1', e1, h1⟩ := h.input e'
  exact ⟨b1', e1, h1, input_fixed e⟩

theorem opRel_output : OpRel Host.Mlx.FfiAne.output Host.Mlx.FfiAne.output := fun _ _ _ _ _ _ _ _ h e => by
  obtain ⟨b1', e1, h1⟩ := h.output e; exact ⟨b1', e1, h1, output_fixed e⟩

theorem opRel_evalAsync : OpRel Host.Mlx.FfiAne.evalAsync Host.Mlx.FfiAne.evalAsync := fun _ _ _ _ _ _ _ _ h e => by
  obtain ⟨b1', e1, h1⟩ := h.evalAsync e; exact ⟨b1', e1, h1, evalAsync_fixed e⟩

theorem opRel_wait : OpRel Host.Mlx.FfiAne.wait Host.Mlx.FfiAne.wait := fun _ _ _ _ _ _ _ _ h e => by
  obtain ⟨b1', e1, h1⟩ := h.wait e; exact ⟨b1', e1, h1, wait_fixed e⟩

theorem opRel_free : OpRel Host.Mlx.FfiAne.free Host.Mlx.FfiAne.free := fun _ _ _ _ _ _ _ _ h e => by
  obtain ⟨b1', e1, h1⟩ := h.free e; exact ⟨b1', e1, h1, free_fixed e⟩

/-- The bridge calls' arguments the map keeps: `mbane_input`'s index. -/
def bridgeOpOk (P : LoadP) (name : Name) (args : List Arg) : Bool :=
  bif nameEq name chars!"mbane_input" then (match args with | [_, i] => natOk P i | _ => true) else true

theorem bridgeOp_map {P : LoadP} {NB : Nat} {M : Map} {k : Nat} {x y : NSt} (hr : G.MR P NB M k x y) {name : Name}
    {args : List Arg} (hok : bridgeOpOk P name args = true) {h : Arg} {F : BSt → Nat → Option (BSt × Ret)}
    (e : bridgeOp name args = some (h, F)) :
    ∃ F', bridgeOp name (args.map M.arg) = some (M.arg h, F') ∧ OpRel F F' := by
  unfold bridgeOp at e ⊢
  unfold bridgeOpOk at hok
  cases h1 : nameEq name chars!"mbane_input"
  · simp only [h1, Bool.cond_false] at e ⊢
    cases h2 : nameEq name chars!"mbane_output" <;> simp only [h2, Bool.cond_false, Bool.cond_true] at e ⊢
    · cases h3 : nameEq name chars!"mbane_eval_async" <;> simp only [h3, Bool.cond_false, Bool.cond_true] at e ⊢
      · cases h4 : nameEq name chars!"mbane_wait" <;> simp only [h4, Bool.cond_false, Bool.cond_true] at e ⊢
        · cases h5 : nameEq name chars!"mbane_free" <;> simp only [h5, Bool.cond_false, Bool.cond_true] at e ⊢
          · cases e
          · match args, e with
            | [a], e => cases e; exact ⟨_, rfl, opRel_free⟩
        · match args, e with
          | [a, _, _], e => cases e; exact ⟨_, rfl, opRel_wait⟩
      · match args, e with
        | [a], e => cases e; exact ⟨_, rfl, opRel_evalAsync⟩
    · match args, e with
      | [a], e => cases e; exact ⟨_, rfl, opRel_output⟩
  · simp only [h1, Bool.cond_true] at e hok ⊢
    match args, e, hok with
    | [a, i], e, hok =>
      cases e
      exact ⟨_, rfl, opRel_input i (M.arg i) (G.MR.natOk_argInt hr hok)⟩

/-! ## In the full world -/

theorem ane_call_op (a : Host.Load.Ane.ASt) {name : Name} {args : List Arg} (hm : Host.Load.isMlx name = false)
    (hc : nameEq name chars!"mbane_program_create" = false) {h : Arg} {F : BSt → Nat → Option (BSt × Ret)}
    (hb : bridgeOp name args = some (h, F)) :
    Host.Load.Ane.call a name args = Host.Load.Ane.onHandle a h (F a.bridge) := by
  unfold bridgeOp at hb
  unfold Host.Load.Ane.call
  simp only [hm, hc, Bool.cond_false]
  cases h1 : nameEq name chars!"mbane_input" <;> simp only [h1, Bool.cond_false, Bool.cond_true] at hb ⊢
  · cases h2 : nameEq name chars!"mbane_output" <;> simp only [h2, Bool.cond_false, Bool.cond_true] at hb ⊢
    · cases h3 : nameEq name chars!"mbane_eval_async" <;> simp only [h3, Bool.cond_false, Bool.cond_true] at hb ⊢
      · cases h4 : nameEq name chars!"mbane_wait" <;> simp only [h4, Bool.cond_false, Bool.cond_true] at hb ⊢
        · cases h5 : nameEq name chars!"mbane_free" <;> simp only [h5, Bool.cond_false, Bool.cond_true] at hb ⊢
          · cases hb
          · match args, hb with
            | [a0], hb => cases hb; rfl
        · match args, hb with
          | [a0, _, _], hb => cases hb; rfl
      · match args, hb with
        | [a0], hb => cases hb; rfl
    · match args, hb with
      | [a0], hb => cases hb; rfl
  · match args, hb with
    | [a0, i], hb => cases hb; rfl

/-- A bridge call's result in the Neural Engine world. -/
def opRes (a : Host.Load.Ane.ASt) (h : Arg) (f : Nat → Option (BSt × Ret)) : Res Host.Load.Ane.ASt :=
  match Host.Load.Ane.handleN a.base.host h with
  | some n => (f n).map fun (b, r) => ({ a with bridge := b }, r, [])
  | none => none

theorem onHandle_eq (a : Host.Load.Ane.ASt) (h : Arg) (f : Nat → Option (BSt × Ret)) :
    Host.Load.Ane.onHandle a h f = .pure (opRes a h f) := by
  unfold Host.Load.Ane.onHandle opRes
  cases Host.Load.Ane.handleN a.base.host h with
  | none => rfl
  | some n =>
    dsimp only
    cases f n with
    | none => rfl
    | some q => obtain ⟨b, r⟩ := q; rfl

theorem full_call_op (p : FF.S) {name : Name} {args : List Arg} (hm : Host.Load.isMlx name = false)
    (hc : nameEq name chars!"mbane_program_create" = false) {h : Arg} {F : BSt → Nat → Option (BSt × Ret)}
    (hb : bridgeOp name args = some (h, F)) :
    FF.call p name args = .pure (liftF p name args (opRes p.1.1 h (F p.1.1.bridge))) := by
  rw [full_call_eq]
  funext γ k
  show symCall p.1.1 name args γ _ = _
  unfold symCall
  rw [ane_call_op p.1.1 hm hc hb, onHandle_eq]
  show (match opRes p.1.1 h (F p.1.1.bridge) with
    | some r => Host.Ts.M.pure (some r)
    | none => bif Host.Load.isMlx name && !nameEq name Host.Mlx.FfiAne.payloadName then _ else Host.Ts.M.pure none) γ _ = _
  cases opRes p.1.1 h (F p.1.1.bridge) with
  | some r => rfl
  | none => simp only [hm, Bool.false_and, Bool.cond_false]; rfl

theorem objArgH_ext (hs : Host.Load.HostSt) (r : Nat) :
    Host.Load.objArgH hs (.extPtr r 0) = bif Nat.beq (r % 4) 3 then hs.objs.get (r / 4) else none := rfl

theorem handleN_map {P : LoadP} {NB : Nat} {M : Map} {n : Nat} {x y : Host.Load.LSt} (hr : G.LoadR P NB M n x y)
    {h : Arg} {k : Nat} (e : Host.Load.Ane.handleN x.host h = some k) : Host.Load.Ane.handleN y.host (M.arg h) = some k := by
  rw [hr.host]
  match h, e with
  | .extPtr r 0, e =>
    unfold Host.Load.Ane.handleN at e ⊢
    rw [objArgH_ext] at e
    show (match Host.Load.objArgH x.host (.extPtr (M.region r) 0) with
      | some (.ane n) => some n
      | _ => none) = some k
    rw [objArgH_ext]
    cases h3 : Nat.beq (r % 4) 3
    · rw [h3, Bool.cond_false] at e; cases e
    · rw [h3, Bool.cond_true] at e
      have hr3 : r % 4 = 3 := Nat.eq_of_beq_eq_true h3
      have hobj : (x.host.objs.get (r / 4)).isSome = true := by
        cases g : x.host.objs.get (r / 4) with
        | none => rw [g] at e; cases e
        | some _ => rfl
      have hlt := hr.hostLt (r / 4) hobj
      have hreg := hr.hostReg (r / 4) hlt
      rw [show 4 * (r / 4) + 3 = r by omega] at hreg
      rw [hreg, h3, Bool.cond_true]
      exact e

/-- **A bridge call with the bridge active.** -/
theorem fullOpSim {P : LoadP} {NB : Nat} {M : Map} {ν : Nat → F64} {S : SSrv} {C : CSrv} {x y : FF.S}
    {name : Name} {args : List Arg} (hsrv : Srv M ν S C) (hr : FullRX P NB M S.tab.length x y)
    (hact : (bridgeOf x).active = true) (hm : Host.Load.isMlx name = false)
    (hc : nameEq name chars!"mbane_program_create" = false) (hsym : Host.Mlx.Ffi.symOf name = none)
    (hok : bridgeOpOk P name args = true) {h : Arg} {F : BSt → Nat → Option (BSt × Ret)}
    (hb : bridgeOp name args = some (h, F)) :
    MSim (fun M' S' C' r r' => Grow M ν S C M' S' C' ∧ CallR (F := FF) (FullRX P NB) M' S'.tab.length r r') S C
      (FF.call x name args) (FF.call y name (args.map M.arg)) := by
  have hbA := hr.bridge.active hact
  obtain ⟨F', hb', hF⟩ := bridgeOp_map hr.load.mlx hok hb
  rw [full_call_op x hm hc hb, full_call_op y hm hc hb']
  unfold opRes
  cases hn : Host.Load.Ane.handleN x.1.1.base.host h with
  | none => exact MSim.pure ⟨Grow.refl hsrv, trivial⟩
  | some n =>
    rw [show Host.Load.Ane.handleN y.1.1.base.host (M.arg h) = some n from handleN_map hr.load hn]
    dsimp only
    cases e : F x.1.1.bridge n with
    | none => exact MSim.pure ⟨Grow.refl hsrv, trivial⟩
    | some q =>
      obtain ⟨b1, r⟩ := q
      obtain ⟨b1', e', h1, ha1, hret⟩ := hF M _ _ _ _ n b1 r hbA.rel e
      rw [e']
      simp only [Option.map_some, liftF_some]
      refine MSim.pure ⟨Grow.refl hsrv, ⟨?_, (hret M).symm, rfl⟩⟩
      refine ⟨hr.load, .inr ⟨ha1.trans hact, ⟨h1, hbA.dense⟩⟩, ?_, ?_, hr.pend⟩
      · rw [show (fun e => liveCall e x.1.1.base.mlx name args) = some from
          funext fun e => liveCall_other e _ _ _ fun s _ hs _ => by rw [hsym] at hs; cases hs]
        rw [show (fun e => liveCall e y.1.1.base.mlx name (args.map M.arg)) = some from
          funext fun e => liveCall_other e _ _ _ fun s _ hs _ => by rw [hsym] at hs; cases hs]
        intro fx hx
        cases hxe : x.1.2 with
        | none => rw [hxe] at hx; cases hx
        | some fx0 =>
          rw [hxe, Option.bind_some] at hx
          cases hx
          obtain ⟨fy, hy, hf⟩ := hr.live fx hxe
          exact ⟨fy, by rw [show y.1.2 = some fy from hy, Option.bind_some], hf⟩
      · rw [show (fun k => kernCall k x.1.1.base.mlx name args r) = some from
          funext fun k => kernCall_none k _ _ _ _ hsym]
        rw [show (fun k => kernCall k y.1.1.base.mlx name (args.map M.arg) r) = some from
          funext fun k => kernCall_none k _ _ _ _ hsym]
        intro kx hx
        cases hxe : x.2 with
        | none => rw [hxe] at hx; cases hx
        | some kx0 =>
          rw [hxe, Option.bind_some] at hx
          cases hx
          obtain ⟨ky, hy, hk⟩ := hr.kern kx hxe
          exact ⟨ky, by rw [show y.2 = some ky from hy, Option.bind_some], hk⟩

end Host.Ts.Sim.Full
