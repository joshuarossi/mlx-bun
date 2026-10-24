import host.load.nat.Run
import host.load.LayerLift
namespace Host.Ts.FfiNat
open Host.Ts Host.Mlx Host.Ts.Sim BufSim Host.Load Host.Load.Layers Host.Load.LayerLift

/-! # Machine runs of the load world in the layer stack

* `lift_runC`, `lift_runS`: every run of the load world (`Host.Load.ffi`)
  from a state whose native state is `l` is a run of the full stack
  (`Layers.full`) from the same machine state with native state
  `start ⟨l, b⟩` (any inactive bridge `b`), with the same server, the same
  JavaScript side at the end, and a final native state whose load-world state
  is the run's (`toLoad`) and whose bridge is inactive. Bridge calls other than
  a create and surface wraps are stuck in the load world (`load_stuck`), so a
  load run makes none.
* `lift_route`: the same for a route in `source_tokens`'s form (a boot, then
  every run past `N` ending in a normal halt).
* `proj_runC`, `proj_runS`: every run of a world with an observer (in
  particular of `full` over the liveness layer, and of the liveness layer over
  the symbolic-shape world) is a run of the world below from the projected
  state, with the same JavaScript side.

Whether the layers accepted the run is the final state's verdict
(`Layers.accepted`). -/

/-! ## Native calls from lawful computations -/

section
variable {F1 F2 : Ffi} [FfiRel F1 F2]

/-- A call simulation from lawful computations whose completed runs are simulated. -/
theorem callSim_of {m1 : M (Option (F1.S × Ret × Writes))} {m2 : M (Option (F2.S × Ret × Writes))}
    (h1 : Lawful m1) (h2 : Lawful m2)
    (hs : ∀ S o S', interpS m1.run S = some (some o, S') →
      ∃ o2, interpS m2.run S = some (some o2, S') ∧ CRel.r (some o) (some o2))
    (hc : ∀ C o C', interpC m1.run C = some (some o, C') →
      ∃ o2, interpC m2.run C = some (some o2, C') ∧ CRel.r (some o) (some o2)) :
    CallSim m1 m2 := by
  refine ⟨fun γ1 γ2 Q k1 k2 hn hk => ⟨fun S v S'' e => ?_, fun C v C'' e => ?_⟩⟩
  · rw [h1.1] at e
    cases hr : interpS m1.run S with
    | none => rw [hr] at e; cases e
    | some p =>
      obtain ⟨o1, S1⟩ := p
      rw [hr, Option.bind_some] at e
      cases o1 with
      | none => rw [hn.1] at e; cases e
      | some o =>
        obtain ⟨o2, h2r, hrel⟩ := hs S o S1 hr
        obtain ⟨v2, hv2, hq⟩ := (hk _ _ hrel).s _ _ _ e
        exact ⟨v2, by rw [h2.1, h2r, Option.bind_some]; exact hv2, hq⟩
  · rw [h1.2] at e
    cases hr : interpC m1.run C with
    | none => rw [hr] at e; cases e
    | some p =>
      obtain ⟨o1, C1⟩ := p
      rw [hr, Option.bind_some] at e
      cases o1 with
      | none => rw [hn.2] at e; cases e
      | some o =>
        obtain ⟨o2, h2r, hrel⟩ := hc C o C1 hr
        obtain ⟨v2, hv2, hq⟩ := (hk _ _ hrel).c _ _ _ e
        exact ⟨v2, by rw [h2.2, h2r, Option.bind_some]; exact hv2, hq⟩

end

/-! ## Server runs as steps -/

theorem interp_sym {α : Type} {t : Free α} {S : SSrv} {a : α} {S' : SSrv} :
    interp t (.sym S) = some (a, .sym S') ↔ interpS t S = some (a, S') := by
  simp only [interp, Option.map_eq_some_iff]
  constructor
  · rintro ⟨⟨a', S''⟩, h, he⟩
    simp only [Prod.mk.injEq, Srv.sym.injEq] at he
    obtain ⟨rfl, rfl⟩ := he
    exact h
  · intro h
    exact ⟨(a, S'), h, rfl⟩

theorem interp_conc {α : Type} {t : Free α} {C : CSrv} {a : α} {C' : CSrv} :
    interp t (.conc C) = some (a, .conc C') ↔ interpC t C = some (a, C') := by
  simp only [interp, Option.map_eq_some_iff]
  constructor
  · rintro ⟨⟨a', C''⟩, h, he⟩
    simp only [Prod.mk.injEq, Srv.conc.injEq] at he
    obtain ⟨rfl, rfl⟩ := he
    exact h
  · intro h
    exact ⟨(a, C'), h, rfl⟩

/-! ## Names -/

private def B : Nat := 2097152

theorem packAux_eq : ∀ (cs : List Char) (n : Nat), packAux cs n = n * B ^ cs.length + packAux cs 0
  | [], n => by simp [packAux]
  | c :: cs, n => by
    simp only [packAux, List.length_cons]
    rw [packAux_eq cs, packAux_eq cs (Nat.add (Nat.mul 0 2097152) c.toNat)]
    show (n * B + c.toNat) * B ^ cs.length + packAux cs 0 =
      n * B ^ (cs.length + 1) + ((0 * B + c.toNat) * B ^ cs.length + packAux cs 0)
    rw [Nat.pow_succ, Nat.zero_mul, Nat.zero_add, Nat.add_mul, Nat.mul_assoc, Nat.mul_comm B (B ^ cs.length),
      Nat.add_assoc]

theorem toNat_lt (c : Char) : c.toNat < B := by
  have h := c.valid
  simp only [UInt32.isValidChar, Nat.isValidChar] at h
  show c.val.toNat < 2097152
  omega

theorem packAux_lt : ∀ (cs : List Char), packAux cs 0 < B ^ cs.length
  | [] => by simp [packAux]
  | c :: cs => by
    simp only [packAux, List.length_cons]
    rw [packAux_eq cs]
    have h1 := packAux_lt cs
    have h2 := toNat_lt c
    have hB : (0 : Nat) < B ^ cs.length := Nat.pos_of_ne_zero (by simp [B])
    simp only [Nat.add_eq, Nat.mul_eq, Nat.zero_mul, Nat.zero_add, Nat.pow_succ]
    calc c.toNat * B ^ cs.length + packAux cs 0 < c.toNat * B ^ cs.length + B ^ cs.length := by omega
      _ = (c.toNat + 1) * B ^ cs.length := (Nat.succ_mul _ _).symm
      _ ≤ B * B ^ cs.length := Nat.mul_le_mul_right _ h2
      _ = B ^ cs.length * B := Nat.mul_comm _ _

theorem pack_eq_packAux : ∀ (cs : List Char) (n : Nat),
    List.rec (motive := fun _ => Nat → Nat) (fun n => n) (fun c _ ih n => ih (Nat.add (Nat.mul n 2097152) c.toNat)) cs n =
      packAux cs n
  | [], _ => rfl
  | _ :: cs, _ => pack_eq_packAux cs _

theorem pack_eq (cs : List Char) : pack cs = B ^ cs.length + packAux cs 0 := by
  unfold pack
  rw [pack_eq_packAux, packAux_eq]
  simp

theorem packAux0_inj : ∀ (a b : List Char), a.length = b.length → packAux a 0 = packAux b 0 → a = b
  | [], [], _, _ => rfl
  | c :: a, d :: b, hl, h => by
    simp only [List.length_cons, Nat.add_right_cancel_iff] at hl
    simp only [packAux, Nat.add_eq, Nat.mul_eq, Nat.zero_mul, Nat.zero_add] at h
    rw [packAux_eq a, packAux_eq b, hl] at h
    have ha := packAux_lt a
    have hb := packAux_lt b
    rw [hl] at ha
    have hcd : c.toNat = d.toNat := by
      have e1 := Nat.add_mul_div_right (packAux a 0) c.toNat (Nat.pos_of_ne_zero (by simp [B] : B ^ b.length ≠ 0))
      have e2 := Nat.add_mul_div_right (packAux b 0) d.toNat (Nat.pos_of_ne_zero (by simp [B] : B ^ b.length ≠ 0))
      rw [Nat.div_eq_of_lt ha, Nat.zero_add] at e1
      rw [Nat.div_eq_of_lt hb, Nat.zero_add] at e2
      rw [← e1, ← e2, Nat.add_comm (packAux a 0), Nat.add_comm (packAux b 0), h]
    have hv : packAux a 0 = packAux b 0 := by rw [hcd] at h; omega
    rw [Char.toNat_inj.mp hcd, packAux0_inj a b hl hv]
  | [], _ :: _, hl, _ => by simp at hl
  | _ :: _, [], hl, _ => by simp at hl

theorem pack_inj {a b : List Char} (h : pack a = pack b) : a = b := by
  rw [pack_eq, pack_eq] at h
  have ha := packAux_lt a
  have hb := packAux_lt b
  have hl : a.length = b.length := by
    rcases Nat.lt_trichotomy a.length b.length with hlt | hl | hlt
    · exfalso
      have : B ^ a.length * B ≤ B ^ b.length := by
        rw [← Nat.pow_succ]; exact Nat.pow_le_pow_right (by simp [B]) hlt
      have : B ^ a.length + packAux a 0 < B ^ a.length * B := by
        have : B ^ a.length * 2 ≤ B ^ a.length * B := Nat.mul_le_mul_left _ (by simp [B])
        omega
      omega
    · exact hl
    · exfalso
      have : B ^ b.length * B ≤ B ^ a.length := by
        rw [← Nat.pow_succ]; exact Nat.pow_le_pow_right (by simp [B]) hlt
      have : B ^ b.length + packAux b 0 < B ^ b.length * B := by
        have : B ^ b.length * 2 ≤ B ^ b.length * B := Nat.mul_le_mul_left _ (by simp [B])
        omega
      omega
  rw [hl] at h
  exact packAux0_inj a b hl (by omega)

theorem nameEq_eq {a b : List Char} (h : nameEq a b = true) : a = b := by
  unfold nameEq at h
  exact pack_inj (Nat.eq_of_beq_eq_true h)

/-! ## The load world is stuck on the bridge's other calls and on surface wraps -/

/-- The names the load world's host serves (other than its pseudo-calls). -/
def hostNames : List Name :=
  [chars!"getenv", chars!"setenv", chars!"MTLCreateSystemDefaultDevice", chars!"sel_registerName",
    chars!"objc_msgSend", chars!"mmap", chars!"munmap", chars!"mbane_program_create"]

theorem hostCall_stuck (l : LSt) (name : Name) (args : List Arg) (hp : name.head? ≠ some '%')
    (hall : hostNames.all (fun n => !nameEq name n) = true) : Host.Load.hostCall l name args = M.pure none := by
  simp only [hostNames, List.all_cons, List.all_nil, Bool.and_true, Bool.and_eq_true, Bool.not_eq_true'] at hall
  obtain ⟨h1, h2, h3, h4, h5, h6, h7, h8⟩ := hall
  unfold Host.Load.hostCall
  split
  · simp at hp
  · simp only [h1, h2, h3, h4, h5, h6, h7, h8, Bool.cond_false]
    rfl

/-- A bridge name other than the create: not MLX, not served by the host. -/
theorem bridge_stuck (l : LSt) (name : Name) (args : List Arg) (hm : isMlx name = false)
    (hp : name.head? ≠ some '%') (hall : hostNames.all (fun n => !nameEq name n) = true) :
    Host.Load.call l name args = M.pure none := by
  unfold Host.Load.call
  rw [hm, Bool.cond_false]
  exact hostCall_stuck l name args hp hall

theorem load_stuck (l : LSt) (name : Name) (args : List Arg) (hf : aneFree (.call name args) = false) :
    Host.Load.call l name args = M.pure none := by
  simp only [aneFree, Bool.and_eq_false_iff, Bool.not_eq_false', Bool.or_eq_false_iff] at hf
  rcases hf with hp | ⟨hb, hc⟩
  · cases nameEq_eq hp
    have h1 : isMlx FfiAne.payloadName = true := by decide +kernel
    have h2 : (Host.Mlx.Ffi.symOf FfiAne.payloadName).isNone = true := by decide +kernel
    unfold Host.Load.call Host.Mlx.Ffi.call
    rw [Option.isNone_iff_eq_none.mp h2, h1, Bool.cond_true]
    rfl
  · simp only [Ane.bridgeSym, Bool.or_eq_true] at hb
    rcases hb with ((((h | h) | h) | h) | h) | h
    · rw [h] at hc; cases hc
    all_goals
      cases nameEq_eq h
      exact bridge_stuck l _ args (by decide +kernel) (by decide +kernel) (by decide +kernel)

/-! ## The lift: the load world simulated by the full stack -/

/-- Load-world and full-world native states: the full state's load-world state, inactive bridge. -/
def LiftR (l : LSt) (p : full.S) : Prop := toLoad p = l ∧ p.1.1.bridge.active = false

@[reducible] def liftRel : FfiRel Host.Load.ffi full := ⟨LiftR⟩

attribute [local instance] liftRel

/-- A completed load-world step, in the full world. -/
theorem crel_some {r : Ret} {ws : Writes} {l : LSt} {p : full.S} (h : LiftR l p) :
    @CRel.r (Option (Host.Load.ffi.S × Ret × Writes)) (Option (full.S × Ret × Writes))
      (@CRel.option _ _ (@CRel.prod _ _ _ _ (@CRel.ffi _ _ liftRel) CRel.eq)) (some (l, r, ws)) (some (p, r, ws)) := by
  show LiftR l p ∧ (r, ws) = (r, ws)
  exact ⟨h, rfl⟩

theorem lift_step {l : LSt} {p : full.S} (hp : LiftR l p) {a : Act} {l' : LSt} {r : Ret} {ws : Writes}
    {X X' : Srv} (hf : aneFree a = true)
    (ht : interp (runAct Host.Load.ffi l a).run X = some (some (l', r, ws), X')) :
    ∃ p', interp (runAct full p a).run X = some (some (p', r, ws), X') ∧ LiftR l' p' := by
  obtain ⟨⟨⟨base, br⟩, e1⟩, e2⟩ := p
  obtain ⟨hl, hb⟩ := hp
  simp only [toLoad] at hl hb
  subst hl
  let t : LayerLift.Step LSt := ⟨base, a, l', r, ws, X, X'⟩
  have h1 := ane_step (t := t) hb hf ht
  have h2 := sym_step h1
  have h3 := Observer.step_ok live.total symLawful (e := e1) h2 (total_upd live _ _)
  have h4 := Observer.step_ok kern.total (Observer.lawful live.total symLawful) (e := e2) h3 (total_upd kern _ _)
  refine ⟨_, h4, rfl, ?_⟩
  show (aneBridge br t).active = false
  rw [aneBridge_active]
  exact hb

theorem liftSim : FfiSim Host.Load.ffi full where
  read := fun l p ⟨hl, _⟩ => by
    subst hl
    rfl
  addr := rfl
  call := fun l p name args hp => by
    refine callSim_of (loadFfiLawful.call _ _ _)
      ((Observer.lawful kern.total (Observer.lawful live.total symLawful)).call _ _ _) ?_ ?_
    · intro S o S' h
      obtain ⟨l', r, ws⟩ := o
      cases hf : aneFree (.call name args)
      · have e : interpS (Host.Load.ffi.call l name args).run S = some (none, S) := by
          rw [show Host.Load.ffi.call l name args = Host.Load.call l name args from rfl, load_stuck l name args hf]; rfl
        rw [e] at h
        simp at h
      · obtain ⟨p', h', hp'⟩ := lift_step (a := .call name args) hp hf (interp_sym.mpr h)
        exact ⟨(p', r, ws), interp_sym.mp h', crel_some hp'⟩
    · intro C o C' h
      obtain ⟨l', r, ws⟩ := o
      cases hf : aneFree (.call name args)
      · have e : interpC (Host.Load.ffi.call l name args).run C = some (none, C) := by
          rw [show Host.Load.ffi.call l name args = Host.Load.call l name args from rfl, load_stuck l name args hf]; rfl
        rw [e] at h
        simp at h
      · obtain ⟨p', h', hp'⟩ := lift_step (a := .call name args) hp hf (interp_conc.mpr h)
        exact ⟨(p', r, ws), interp_conc.mp h', crel_some hp'⟩
  back := fun l p a hp => by
    refine callSim_of (loadFfiLawful.back _ _)
      ((Observer.lawful kern.total (Observer.lawful live.total symLawful)).back _ _) ?_ ?_
    · intro S o S' h
      obtain ⟨l', r, ws⟩ := o
      obtain ⟨p', h', hp'⟩ := lift_step (a := .back a) hp rfl (interp_sym.mpr h)
      exact ⟨(p', r, ws), interp_sym.mp h', crel_some hp'⟩
    · intro C o C' h
      obtain ⟨l', r, ws⟩ := o
      obtain ⟨p', h', hp'⟩ := lift_step (a := .back a) hp rfl (interp_conc.mpr h)
      exact ⟨(p', r, ws), interp_conc.mp h', crel_some hp'⟩

attribute [local instance] liftSim

/-- **The machine-run lift.** A concrete-server run of the load world is a run of the full stack from the
same machine state with native state `start ⟨l, b⟩` (`b` inactive), with the same server and JavaScript
side; the final full state's load-world state is the run's and its bridge is inactive. -/
theorem lift_runC (n : Nat) (s : St LSt) (b : FfiAne.St) (hb : b.active = false) (C : CSrv) (t : St LSt) (C' : CSrv)
    (h : runC Host.Load.ffi n s C = some (t, C')) :
    ∃ y, runC full n (s.reFfi (start ⟨s.ffi, b⟩)) C = some (t.reFfi y, C') ∧ toLoad y = t.ffi ∧
      y.1.1.bridge.active = false :=
  @runC_sim Host.Load.ffi full liftRel liftSim n s (start ⟨s.ffi, b⟩) (show LiftR _ _ from ⟨rfl, hb⟩) C t C' h |>.imp fun _ h => ⟨h.1, h.2.1, h.2.2⟩

theorem lift_runS (n : Nat) (s : St LSt) (b : FfiAne.St) (hb : b.active = false) (S : SSrv) (t : St LSt) (S' : SSrv)
    (h : runS Host.Load.ffi n s S = some (t, S')) :
    ∃ y, runS full n (s.reFfi (start ⟨s.ffi, b⟩)) S = some (t.reFfi y, S') ∧ toLoad y = t.ffi ∧
      y.1.1.bridge.active = false :=
  @runS_sim Host.Load.ffi full liftRel liftSim n s (start ⟨s.ffi, b⟩) (show LiftR _ _ from ⟨rfl, hb⟩) S t S' h |>.imp fun _ h => ⟨h.1, h.2.1, h.2.2⟩

/-! ## Runs that have halted -/

theorem runC_halt (F : Ffi) : ∀ (n : Nat) (s : St F.S) (C : CSrv), isHalt s.ctl = true → runC F n s C = some (s, C)
  | 0, _, _, _ => rfl
  | n + 1, s, C, h => by
    unfold runC
    rw [runWith_succ, h]
    rfl

theorem runC_add (F : Ffi) (m : Nat) : ∀ (n : Nat) (s : St F.S) (C : CSrv) (t : St F.S) (C' : CSrv),
    runC F n s C = some (t, C') → isHalt t.ctl = true → runC F (n + m) s C = some (t, C')
  | 0, s, C, t, C', h, hh => by
    simp only [runC, runWith_zero, Option.some.injEq, Prod.mk.injEq] at h
    obtain ⟨rfl, rfl⟩ := h
    rw [Nat.zero_add]
    exact runC_halt F m s C hh
  | n + 1, s, C, t, C', h, hh => by
    rw [show n + 1 + m = (n + m) + 1 by omega]
    unfold runC at h ⊢
    rw [runWith_succ] at h ⊢
    cases hs : isHalt s.ctl
    · simp only [hs, Bool.cond_false] at h ⊢
      cases hst : interpC (step F s).run C with
      | none => rw [hst] at h; cases h
      | some p =>
        obtain ⟨s1, C1⟩ := p
        rw [hst] at h
        simp only [St.rebuild_eq] at h ⊢
        exact runC_add F m n s1 C1 t C' h hh
    · simp only [hs, Bool.cond_true] at h ⊢
      exact h

/-- **The route's runs in the stack.** A load-world run that reaches the halted state `final` for every
run length past `N` (as `source_tokens` states of the route) is, for every such length, a run of the
full stack from the same machine state with native state `start ⟨s.ffi, b⟩`, ending in `final`'s
JavaScript side with a native state `y` whose load-world state is `final`'s. Every statement of
`source_tokens` about the final machine state and its MLX state holds of it; whether the layers accepted
the run is `Layers.accepted y`. -/
theorem lift_eventually {s : St LSt} {C : CSrv} {N : Nat} {final : St LSt} {C' : CSrv} (b : FfiAne.St)
    (hb : b.active = false) (h : ∀ n, N ≤ n → runC Host.Load.ffi n s C = some (final, C'))
    (hh : isHalt final.ctl = true) :
    ∃ y, (∀ n, N ≤ n → runC full n (s.reFfi (start ⟨s.ffi, b⟩)) C = some (final.reFfi y, C')) ∧
      toLoad y = final.ffi ∧ y.1.1.bridge.active = false := by
  obtain ⟨y, h1, h2, h3⟩ := lift_runC N s b hb C final C' (h N (Nat.le_refl N))
  refine ⟨y, fun n hn => ?_, h2, h3⟩
  have := runC_add full (n - N) N _ C _ C' h1 hh
  rw [Nat.add_sub_cancel' hn] at this
  exact this

/-- **The route in the stack**, in `source_tokens`'s form: if booting gives a start state from which
every load-world run past `N` ends in the normally halted `final`, the boot gives some `s` and every
full-stack run past `N` from `s` with native state `start ⟨s.ffi, b⟩` ends in `final`'s JavaScript side,
with a native state `y` whose load-world state is `final`'s (so every statement of `source_tokens` about
`final` and its MLX state holds of the lifted run) and whose bridge is inactive. The layers' verdict on
the run is `accepted y`. -/
theorem lift_route {boot : Option (St LSt)} {C : CSrv} {N : Nat} {final : St LSt} {C' : CSrv} (b : FfiAne.St)
    (hb : b.active = false) (h : ∀ n, N ≤ n → boot.bind (fun s => runC Host.Load.ffi n s C) = some (final, C'))
    (hh : ∃ v, final.ctl = .halt (.normal v)) :
    ∃ s y, boot = some s ∧ (∀ n, N ≤ n → runC full n (s.reFfi (start ⟨s.ffi, b⟩)) C = some (final.reFfi y, C')) ∧
      toLoad y = final.ffi ∧ y.1.1.bridge.active = false := by
  cases hbt : boot with
  | none => have := h N (Nat.le_refl N); rw [hbt] at this; cases this
  | some s =>
    have hr : ∀ n, N ≤ n → runC Host.Load.ffi n s C = some (final, C') := fun n hn => by
      have := h n hn; rw [hbt] at this; exact this
    obtain ⟨v, hv⟩ := hh
    obtain ⟨y, h1, h2, h3⟩ := lift_eventually b hb hr (by rw [hv]; rfl)
    exact ⟨s, y, rfl, h1, h2, h3⟩

end Host.Ts.FfiNat

namespace Host.Ts.FfiNat
open Host.Ts Host.Mlx Host.Ts.Sim BufSim Host.Load Host.Load.Layers Host.Load.LayerLift

/-! ## Projections: a world with an observer simulated by the world below -/

/-- States of a world with an observer and of the world below: the observed state's first component. -/
@[reducible] def projRel {F : Ffi} (O : Layers.Observer F) : FfiRel O.ffi F := ⟨fun p x => p.1 = x⟩

section
variable {F : Ffi} (O : Layers.Observer F)

theorem proj_sem {m : M (Res F.S)} (hm : Lawful m) (g : F.S → Ret → Option O.E) :
    (∀ S o S', interpS (M.bind m fun ob => M.pure (O.post g ob)).run S = some (some o, S') →
      ∃ o2, interpS m.run S = some (some o2, S') ∧ @CRel.r _ _ (@CRel.option _ _ (@CRel.prod _ _ _ _
        (@CRel.ffi _ _ (projRel O)) CRel.eq)) (some o) (some o2)) ∧
    (∀ C o C', interpC (M.bind m fun ob => M.pure (O.post g ob)).run C = some (some o, C') →
      ∃ o2, interpC m.run C = some (some o2, C') ∧ @CRel.r _ _ (@CRel.option _ _ (@CRel.prod _ _ _ _
        (@CRel.ffi _ _ (projRel O)) CRel.eq)) (some o) (some o2)) := by
  refine ⟨fun S o S' h => ?_, fun C o C' h => ?_⟩
  · have h' : interpS (m _ fun ob => Free.pure (O.post g ob)) S = some (some o, S') := h
    rw [hm.1] at h'
    cases hr : interpS m.run S with
    | none => rw [hr] at h'; cases h'
    | some q =>
      obtain ⟨ob, S1⟩ := q
      rw [hr, Option.bind_some, interpS_pure] at h'
      simp only [Option.some.injEq, Prod.mk.injEq] at h'
      obtain ⟨hpo, rfl⟩ := h'
      obtain ⟨⟨x', e'⟩, r, ws⟩ := o
      obtain ⟨rfl, -⟩ := (O.post_some).mp hpo
      exact ⟨(x', r, ws), rfl, rfl, rfl⟩
  · have h' : interpC (m _ fun ob => Free.pure (O.post g ob)) C = some (some o, C') := h
    rw [hm.2] at h'
    cases hr : interpC m.run C with
    | none => rw [hr] at h'; cases h'
    | some q =>
      obtain ⟨ob, C1⟩ := q
      rw [hr, Option.bind_some, interpC_pure] at h'
      simp only [Option.some.injEq, Prod.mk.injEq] at h'
      obtain ⟨hpo, rfl⟩ := h'
      obtain ⟨⟨x', e'⟩, r, ws⟩ := o
      obtain ⟨rfl, -⟩ := (O.post_some).mp hpo
      exact ⟨(x', r, ws), rfl, rfl, rfl⟩

theorem projSim (hF : FfiLawful F) : @FfiSim O.ffi F (projRel O) := by
  letI := projRel O
  refine { read := fun p x h => ?_, addr := rfl, call := fun p x name args h => ?_, back := fun p x a h => ?_ }
  · cases h; rfl
  · cases h
    exact callSim_of ((Observer.lawful O hF).call _ _ _) (hF.call _ _ _)
      (proj_sem O (hF.call _ _ _) _).1 (proj_sem O (hF.call _ _ _) _).2
  · cases h
    exact callSim_of ((Observer.lawful O hF).back _ _) (hF.back _ _)
      (proj_sem O (hF.back _ _) _).1 (proj_sem O (hF.back _ _) _).2

/-- **Projection.** A run of the world with the observer is a run of the world below from the projected
state, with the same server and JavaScript side; the final states project. -/
theorem proj_runC (hF : FfiLawful F) (n : Nat) (s : St O.ffi.S) (C : CSrv) (t : St O.ffi.S) (C' : CSrv)
    (h : runC O.ffi n s C = some (t, C')) : runC F n (s.reFfi s.ffi.1) C = some (t.reFfi t.ffi.1, C') := by
  letI := projRel O
  haveI := projSim O hF
  obtain ⟨y, h1, h2⟩ := runC_sim n s s.ffi.1 rfl C t C' h
  have h2 : t.ffi.1 = y := h2
  rw [h2]; exact h1

theorem proj_runS (hF : FfiLawful F) (n : Nat) (s : St O.ffi.S) (S : SSrv) (t : St O.ffi.S) (S' : SSrv)
    (h : runS O.ffi n s S = some (t, S')) : runS F n (s.reFfi s.ffi.1) S = some (t.reFfi t.ffi.1, S') := by
  letI := projRel O
  haveI := projSim O hF
  obtain ⟨y, h1, h2⟩ := runS_sim n s s.ffi.1 rfl S t S' h
  have h2 : t.ffi.1 = y := h2
  rw [h2]; exact h1

end

/-- A run of the full stack is a run of the symbolic-shape world (the observers dropped). -/
theorem full_proj_runC (n : Nat) (s : St full.S) (C : CSrv) (t : St full.S) (C' : CSrv)
    (h : runC full n s C = some (t, C')) : runC symFfi n (s.reFfi s.ffi.1.1) C = some (t.reFfi t.ffi.1.1, C') := by
  have h1 := proj_runC kern.total (Observer.lawful live.total symLawful) n s C t C' h
  exact proj_runC live.total symLawful n _ C _ C' h1

end Host.Ts.FfiNat
