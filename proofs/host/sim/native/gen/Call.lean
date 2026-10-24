import host.sim.native.Call
import host.sim.native.gen.Update
namespace Host.Ts.Sim.G
open Host.Mlx.Ffi (Dim Prim Node Cfg Clo Trace Pending dimOf)

/-! `host.sim.native.Call` for the general native relation `G.MR` (`host.sim.native.gen.Rel`):
the same statements and proofs, with the pre-load band bound `NB` threaded through. -/

def MCallR (P : LoadP) (NB : Nat) (M : Map) (n : Nat) : NRes → NRes → Prop
  | none, _ => True
  | some (x, r, ws), some (y, r', ws') => MR P NB M n x y ∧ r' = M.ret r ∧ ws' = ws.map M.write
  | some _, none => False

def MPost (P : LoadP) (NB : Nat) (M : Map) (ν : Nat → F64) (S : SSrv) (C : CSrv) :
    Map → SSrv → CSrv → NRes → NRes → Prop :=
  fun M' S' C' r r' => Grow M ν S C M' S' C' ∧ MCallR P NB M' S'.tab.length r r'

/-- The load world's postcondition. -/
def LPost (P : LoadP) (NB : Nat) (M : Map) (ν : Nat → F64) (S : SSrv) (C : CSrv) :
    Map → SSrv → CSrv → Option (Host.Load.LSt × Ret × List (Nat × Nat × List Byte)) →
      Option (Host.Load.LSt × Ret × List (Nat × Nat × List Byte)) → Prop :=
  fun M' S' C' r r' => Grow M ν S C M' S' C' ∧ CallR (F := Host.Load.ffi) (LoadR P NB) M' S'.tab.length r r'

/-- **Lift.** An mlx call simulation is a load-world call simulation. -/
theorem mlx_lift {P : LoadP} {NB : Nat} {M : Map} {ν : Nat → F64} {S : SSrv} {C : CSrv} {x y : Host.Load.LSt}
    {name : Name} {args args' : List Arg} (hr : LoadR P NB M S.tab.length x y) (hm : Host.Load.isMlx name = true)
    (h : MSim (MPost P NB M ν S C) S C (Host.Mlx.Ffi.call x.mlx name args) (Host.Mlx.Ffi.call y.mlx name args')) :
    MSim (LPost P NB M ν S C) S C (Host.Load.call x name args) (Host.Load.call y name args') := by
  rw [Host.Load.call_mlx x name args hm, Host.Load.call_mlx y name args' hm]
  refine MSim.bind h fun M' S' C' a b hab => ?_
  obtain ⟨hg, hc⟩ := hab
  cases a with
  | none =>
    cases b with
    | none => exact MSim.pure ⟨hg, trivial⟩
    | some q => obtain ⟨_, _, _⟩ := q; exact MSim.pure ⟨hg, trivial⟩
  | some p =>
    obtain ⟨m, r, ws⟩ := p
    cases b with
    | none => exact hc.elim
    | some q =>
      obtain ⟨m', r', ws'⟩ := q
      obtain ⟨hmr, hr', hws⟩ := hc
      refine MSim.pure ⟨hg, ⟨?_, hr', hws⟩⟩
      exact ⟨hr.host, fun k hk => by rw [hg.ext.region]; exact hr.hostReg k hk, hr.hostLt,
        fun a => by rw [hg.ext.region, hg.ext.a]; exact hr.cbr a, hmr⟩

section

variable {P : LoadP} {NB : Nat} {M : Map} {ν : Nat → F64} {S : SSrv} {C : CSrv}

/-- Both sides return. -/
theorem msim_okW {x' y' : NSt} {r : Ret} {ws : List (Nat × Nat × List Byte)} (hs : Srv M ν S C)
    (hr : MR P NB M S.tab.length x' y') :
    MSim (MPost P NB M ν S C) S C (Host.Mlx.Ffi.okW x' r ws) (Host.Mlx.Ffi.okW y' (M.ret r) (ws.map M.write)) :=
  MSim.pure ⟨Grow.refl hs, hr, rfl, rfl⟩

theorem msim_ok {x' y' : NSt} {r : Ret} (hs : Srv M ν S C) (hr : MR P NB M S.tab.length x' y') :
    MSim (MPost P NB M ν S C) S C (Host.Mlx.Ffi.ok x' r) (Host.Mlx.Ffi.ok y' (M.ret r)) :=
  msim_okW (ws := []) hs hr

/-- The source is stuck. -/
theorem msim_stuck (hs : Srv M ν S C) (m' : Host.Ts.M NRes) (hm' : ∃ b, ∀ γ k, m' γ k = k b) :
    MSim (MPost P NB M ν S C) S C Host.Mlx.Ffi.stuck m' := by
  obtain ⟨b, hb⟩ := hm'
  intro γ δ Q k k' hk
  have := hk M S C none b ⟨Grow.refl hs, trivial⟩
  show FSim Q S C (k none) (m' δ k')
  rw [hb]; exact this

end

section

variable {P : LoadP} {NB : Nat} {M : Map} {n : Nat} {x y : NSt} (hr : MR P NB M n x y)

include hr

theorem MR.hdOk_spec {a : Arg} (h : hdOk x a = true) :
    ∃ k, a = .big (Int.ofNat k) ∧ PH x k ∧ M.arg a = .big (Int.ofNat (M.handle k)) := by
  cases a with
  | big i =>
    simp only [hdOk, Bool.and_eq_true, decide_eq_true_eq, isPH_iff] at h
    refine ⟨i.toNat, by rw [Int.ofNat_eq_natCast, Int.toNat_of_nonneg h.1], h.2, ?_⟩
    show Arg.big (M.big i) = _
    have := (hr.present _ h.2).1
    rw [Int.ofNat_eq_natCast, Int.toNat_of_nonneg h.1] at this
    rw [this]
  | _ => cases h

theorem MR.big_fixed {i : Int} (h : bigOk P i = true) : M.big i = i := by
  simp only [bigOk, Bool.or_eq_true, decide_eq_true_eq] at h
  rcases h with h | ⟨h1, h2⟩
  · exact hr.bigFix i h
  · exact hr.bigFixHi i h1 h2

theorem MR.natOk_argInt {a : Arg} (h : natOk P a = true) :
    Host.Mlx.Ffi.argInt (M.arg a) = Host.Mlx.Ffi.argInt a := by
  cases a with
  | big i =>
    simp only [natOk] at h
    show some (M.big i) = some i
    rw [hr.big_fixed h]
  | num x => cases x with
    | lit _ => rfl
    | ref _ => cases h
  | null => rfl
  | _ => cases h

theorem MR.natOk_argNat {a : Arg} (h : natOk P a = true) :
    Host.Mlx.Ffi.argNat (M.arg a) = Host.Mlx.Ffi.argNat a := by
  unfold Host.Mlx.Ffi.argNat; rw [hr.natOk_argInt h]

theorem MR.handle_pos {k : Nat} (hp : PH x k) : M.handle k ≠ 0 := Nat.ne_of_gt (hr.himg k hp).1

theorem MR.nodeId? {k : Nat} (hp : PH x k) : y.nodeId? (M.handle k) = (x.nodeId? k).map M.node := by
  unfold Host.Mlx.Ffi.St.nodeId?
  have h1 : Nat.beq (M.handle k) 0 = false := by
    cases h : Nat.beq (M.handle k) 0
    · rfl
    · exact absurd (Nat.eq_of_beq_eq_true h) (hr.handle_pos hp)
  have h2 : Nat.beq k 0 = false := by
    cases h : Nat.beq k 0
    · rfl
    · exact absurd (Nat.eq_of_beq_eq_true h) (hr.PH_ne_zero hp)
  rw [h1, h2]
  exact hr.arrs k hp

theorem MR.obj? {k : Nat} (hp : PH x k) : y.obj? (M.handle k) = (x.obj? k).map M.nobj := hr.objs k hp

theorem MR.node? {k : Nat} {nd : Node} (hn : x.node? k = some nd) :
    ∃ i nd', x.arrs.get k = some i ∧ x.nodes.get i = some nd ∧ y.node? (M.handle k) = some nd' ∧
      NodeR P M i nd nd' := by
  unfold Host.Mlx.Ffi.St.node? at hn
  cases ha : x.arrs.get k with
  | none => rw [ha] at hn; cases hn
  | some i =>
    rw [ha] at hn
    have hp : PH x k := .inl (by rw [ha]; rfl)
    obtain ⟨nd', h1, h2⟩ := hr.nodes i nd hn
    refine ⟨i, nd', rfl, hn, ?_, h2⟩
    unfold Host.Mlx.Ffi.St.node?
    rw [hr.arrs k hp, ha]
    exact h1

end

end Host.Ts.Sim.G
