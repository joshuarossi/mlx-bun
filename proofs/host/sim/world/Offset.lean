import host.sim.world.Book
import host.sim.dispatch.OkJs
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
set_option autoImplicit false
namespace Host.Ts.Sim.Prefill
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-- The whole-chunk forwards, a nonempty tail, and the singleton final. -/
def prefillForwardCalls (L : Nat) : Nat :=
  drains L + (if tailRows L = 0 then 0 else 1) + 1

theorem prefill_forward_calls_le_length {L : Nat} (h1 : 1 ≤ L) (hL : L ≤ 349525) :
    prefillForwardCalls L ≤ L := by
  have hc : 1 ≤ chunkC L := by
    rcases chunkC_cases hL with h | h | h | h | h | h <;> rw [h] <;> decide
  have hd : drains L ≤ drains L * chunkC L := by
    calc
      drains L = drains L * 1 := (Nat.mul_one _).symm
      _ ≤ drains L * chunkC L := Nat.mul_le_mul_left _ hc
  have hs := drains_tail L
  by_cases ht : tailRows L = 0
  · simp only [prefillForwardCalls, ite_eq_left ht]
    omega
  · simp only [prefillForwardCalls, ite_eq_right ht]
    omega

theorem prefill_drains_le_4095 {L : Nat} (hL : L ≤ 262143) : drains L ≤ 4095 := by
  have hc : 64 ≤ chunkC L := by
    rcases chunkC_cases (by omega : L ≤ 349525) with h | h | h | h | h | h <;> rw [h] <;> decide
  have hd : drains L * 64 ≤ drains L * chunkC L := Nat.mul_le_mul_left _ hc
  have hs := drains_tail L
  omega

/-- The supported schedule has at most 4095 whole chunks, one tail, and one final. -/
theorem prefill_forward_calls_le_4097 {L : Nat} (hL : L ≤ 262143) :
    prefillForwardCalls L ≤ 4097 := by
  have hcount := prefill_drains_le_4095 hL
  by_cases ht : tailRows L = 0 <;> simp only [prefillForwardCalls, ht, ite_true, ite_false] <;> omega

/-- Different forward families may have different checked net offset increments. -/
def prefillOffsetBudget (base dDrain dTail dFinal L : Nat) : Nat :=
  base + drains L * dDrain + (if tailRows L = 0 then 0 else dTail) + dFinal

theorem prefill_offset_budget_le {base dDrain dTail dFinal L : Nat} (hL : L ≤ 262143) :
    prefillOffsetBudget base dDrain dTail dFinal L ≤ base + 4095 * dDrain + dTail + dFinal := by
  have hm := Nat.mul_le_mul_right dDrain (prefill_drains_le_4095 hL)
  by_cases ht : tailRows L = 0 <;>
    simp only [prefillOffsetBudget, ht, ite_true, ite_false] <;> omega


/-- The context limit gives a tighter whole-chunk count for each setup class. -/
def SetupClass.maxDrains : SetupClass → Nat
  | .early => 0
  | .h0 => 5
  | .h1 => 21
  | .h2 => 85
  | .h3 => 341
  | .h4 => 1365
  | .h5 => 4095

theorem prefill_drains_le_class {L : Nat} {c : SetupClass} (hL : L ≤ 262143) (ha : c.Applies L) :
    drains L ≤ c.maxDrains := by
  have hlimit : L ≤ 349525 := by omega
  have hs := drains_tail L
  cases c <;> simp only [SetupClass.Applies, SetupClass.maxDrains] at ha ⊢
  all_goals
    have hc := chunkC_eq L hlimit
    (repeat' split at hc) <;> rw [hc] at hs <;> omega

theorem prefill_offset_budget_le_class {base dDrain dTail dFinal L : Nat} {c : SetupClass}
    (hL : L ≤ 262143) (ha : c.Applies L) :
    prefillOffsetBudget base dDrain dTail dFinal L ≤ base + c.maxDrains * dDrain + dTail + dFinal := by
  have hm := Nat.mul_le_mul_right dDrain (prefill_drains_le_class hL ha)
  by_cases ht : tailRows L = 0 <;>
    simp only [prefillOffsetBudget, ht, ite_true, ite_false] <;> omega

theorem prefill_js_room_by_class {base dDrain dTail dFinal L D next limit : Nat} {c : SetupClass}
    (hL : L ≤ 262143) (ha : c.Applies L)
    (hD : D ≤ prefillOffsetBudget base dDrain dTail dFinal L)
    (hroom : next + (base + c.maxDrains * dDrain + dTail + dFinal) < limit) :
    next + D < limit := by
  have := prefill_offset_budget_le_class (base := base) (dDrain := dDrain) (dTail := dTail)
    (dFinal := dFinal) hL ha
  omega

/-- Admission room still has to hold at the typed-construction site. -/
theorem prefill_js_room_by_schedule {base dDrain dTail dFinal L D next limit : Nat}
    (hL : L ≤ 262143) (hD : D ≤ prefillOffsetBudget base dDrain dTail dFinal L)
    (hroom : next + (base + 4095 * dDrain + dTail + dFinal) < limit) :
    next + D < limit := by
  have := prefill_offset_budget_le (base := base) (dDrain := dDrain) (dTail := dTail) (dFinal := dFinal) hL
  omega

/-- A checked per-cycle increment advances a cumulative offset budget. -/
theorem offset_budget_step {base stride k k' D D' delta : Nat}
    (hD : D ≤ base + k * stride) (hstep : D' ≤ D + delta)
    (hdelta : delta ≤ stride) (hk : k + 1 ≤ k') :
    D' ≤ base + k' * stride := by
  calc
    D' ≤ D + delta := hstep
    _ ≤ (base + k * stride) + stride := Nat.add_le_add hD hdelta
    _ = base + (k + 1) * stride := by simp only [Nat.add_mul, Nat.one_mul, Nat.add_assoc]
    _ ≤ base + k' * stride := Nat.add_le_add_left (Nat.mul_le_mul_right stride hk) base

/-- Keep a phase's checked allowance separate from the completed-cycle budget. -/
theorem offset_budget_room {base stride k kmax phase phaseMax limit D next : Nat}
    (hD : D ≤ base + k * stride + phase) (hk : k ≤ kmax) (hphase : phase ≤ phaseMax)
    (hroom : next + (base + kmax * stride + phaseMax) < limit) :
    next + D < limit := by
  have hm := Nat.mul_le_mul_right stride hk
  omega

/-- The JavaScript typed-construction room condition uses the actual counter offset. -/
theorem js_offset_room {next D cap limit : Nat} (hD : D ≤ cap) (hroom : next + cap < limit) :
    next + D < limit := by omega

/-- For an unchanged template and target, changing the map cannot reset the counter offset. -/
theorem rel_offset_unique {F : Ffi} {FR FR' : Map → Nat → F.S → F.S → Prop}
    {W W' : Nat → Option WFrame} {stk stk' : List Frame} {M M' : Map}
    {ν ν' : Nat → F64} {K K' : Ctx} {s t : St F.S} {S S' : SSrv} {C C' : CSrv}
    (h : RelB F FR W stk M ν K s S t C) (h' : RelB F FR' W' stk' M' ν' K' s S' t C') :
    K.D = K'.D := by
  have := h.offset
  have := h'.offset
  omega


/-- A restart to a lower canonical source counter moves the difference into the offset. -/
theorem rel_restart_offset {F : Ffi} {FR FR' : Map → Nat → F.S → F.S → Prop}
    {W W' : Nat → Option WFrame} {stk stk' : List Frame} {M M' : Map}
    {ν ν' : Nat → F64} {K K' : Ctx} {s s' t : St F.S} {S S' : SSrv} {C C' : CSrv}
    (h : RelB F FR W stk M ν K s S t C) (h' : RelB F FR' W' stk' M' ν' K' s' S' t C')
    (hnext : s'.next ≤ s.next) : K'.D = K.D + (s.next - s'.next) := by
  have := h.offset
  have := h'.offset
  omega

/-- An admission room condition bounds the actual target's heap counter. -/
theorem rel_js_target_bound {F : Ffi} {FR : Map → Nat → F.S → F.S → Prop}
    {W : Nat → Option WFrame} {stk : List Frame} {M : Map} {ν : Nat → F64}
    {K : Ctx} {s t : St F.S} {S : SSrv} {C : CSrv} {cap limit : Nat}
    (h : RelB F FR W stk M ν K s S t C) (hcap : K.D ≤ cap)
    (hroom : s.next + cap < limit) : t.next < limit := by
  have := h.offset
  omega

theorem rel_js_offset_blocked {F : Ffi} {FR : Map → Nat → F.S → F.S → Prop}
    {W : Nat → Option WFrame} {stk : List Frame} {M : Map} {ν : Nat → F64}
    {K : Ctx} {s t : St F.S} {S : SSrv} {C : CSrv} {cap limit : Nat}
    (h : RelB F FR W stk M ν K s S t C) (hcap : K.D ≤ cap) (ht : limit ≤ t.next) :
    ¬ s.next + cap < limit := by
  intro hroom
  exact Nat.not_lt_of_ge ht (rel_js_target_bound h hcap hroom)

section
variable {Wd : World}

theorem CutBookW.restart_indexed {Q : PrefPW Wd} {sA sF sB : St Wd.F.S}
    {frsA frsB : List Nat} {base stride k k' H N : Nat} {x x1 x' : SegInst Wd.F}
    (hb : CutBookW Wd Q sA frsA (base + k * stride) H N x)
    (hp : LoadPostW Wd sA sF sB Q.aP frsB Q.fixA x x1 x')
    (hdelta : sF.next - sB.next ≤ stride) (hk : k + 1 ≤ k') :
    CutBookW Wd Q sB frsB (base + k' * stride)
      (H + ((Wd.toMlx sF.ffi).next - (Wd.toMlx sB.ffi).next))
      (N + ((Wd.toMlx sF.ffi).nnext - (Wd.toMlx sB.ffi).nnext)) x' := by
  apply (hb.restart hp).mono _ (Nat.le_refl _) (Nat.le_refl _)
  exact offset_budget_step (Nat.le_refl _) (Nat.le_refl _) hdelta hk

/-- An entry book supplies a chosen admission margin once its offset budget fits it. -/
theorem CutBookW.kpJ {Q : PrefPW Wd} {s0 : St Wd.F.S} {frs : List Nat}
    {D H N cap : Nat} {x : SegInst Wd.F}
    (hb : CutBookW Wd Q s0 frs D H N x) (J : Disp.JSP Wd.F)
    (hlo : J.lo = Wd.lo Q.P) (hhi : J.hi = Wd.E Q.P) (hframes : J.framed = frs)
    (hcap : D ≤ cap) : Disp.KpJ J cap x.K := by
  refine ⟨⟨hb.lo.trans hlo.symm, hb.hi.trans hhi.symm, ?_⟩, Nat.le_trans hb.D hcap⟩
  intro a
  rw [hframes]
  exact hb.framed a

/-- The existing reusable drain cut admits its accumulated, rather than initial-setup, offset. -/
theorem prefCutW.kpJ {pc : Cut Wd.F} {Q : PrefPW Wd} {frs : List Nat}
    {PV : Nat → Nat → Nat → Nat → F64} {C : Nat} {W : PrefCtr}
    {Gp : Nat → SegInst Wd.F → Prop} {k cap : Nat} {x : SegInst Wd.F}
    (hb : (prefCutW pc Q frs PV C W Gp k).B x) (J : Disp.JSP Wd.F)
    (hlo : J.lo = Wd.lo Q.P) (hhi : J.hi = Wd.E Q.P) (hframes : J.framed = frs)
    (hcap : W.D0 + k * W.ΔJ ≤ cap) : Disp.KpJ J cap x.K :=
  hb.2.1.kpJ J hlo hhi hframes hcap

end
end Host.Ts.Sim.Prefill
