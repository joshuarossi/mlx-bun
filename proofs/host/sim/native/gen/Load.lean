import host.sim.native.gen.Data
import host.sim.native.gen.Facts
import host.sim.native.gen.RebigR
import host.sim.LoadSim
import host.sim.extract.GrowRun
namespace Host.Ts.Sim.G
open Host.Ts

/-! # The general relation at the interpreter's interface

What the dispatcher's one-step theorem needs of the native relation, for `G.LoadR`: the
native-call simulations (`loadFfiSim`, `loadFfiCallSim` with `okCallSG`), the laws, the map facts
for a JavaScript parameter set whose handle band starts at `P.lo`, the target's growth, and the
one-step theorem itself. -/

/-- The native relation with the target's remaining readbacks `r`. -/
abbrev LR (P : LoadP) (NB : Nat) (r : List NumV) : Map → Nat → Host.Load.LSt → Host.Load.LSt → Prop :=
  LoadR { P with rest := r } NB

theorem loadNativeFacts (P : LoadP) (NB : Nat) (r : List NumV) (J : Disp.JSP LF) (hlo : J.lo = P.lo)
    (hh : J.isHandle = loadIsHandle) (hg : J.isRegion = loadIsRegion) : Disp.NativeFacts LF (LR P NB r) J where
  zero := fun _ _ _ _ hr i => hr.zero_fact i
  inj := fun _ _ _ _ hr i j hi hj he => by
    rw [hh] at hi hj; rw [hlo] at hj; exact hr.inj_fact i j hi hj he
  region := fun _ _ _ _ hr r r' h1 h2 he => by rw [hg] at h1 h2; exact hr.region_fact r r' h1 h2 he
  range := fun _ _ _ _ hr i hi => by rw [hh] at hi; exact hr.range_fact i hi
  host := fun _ _ _ _ hr r h3 hlt => hr.host_fact r h3 hlt
  cb := fun _ _ _ _ hr f hf => hr.cb_fact f hf

/-- The target's mlx state only grows. -/
theorem loadTargetPres (P : LoadP) (NB : Nat) (y0 : Host.Mlx.Ffi.St) :
    TargetPres LF (LoadR P NB) (fun y : Host.Load.LSt => Host.Mlx.Ffi.NGrow y0 y.mlx) where
  call _ _ _ _ name args C y' rr ws C' hr hq hrun :=
    hq.trans (Host.Load.call_g (fun h hh => (hr.mlx.yabsent h hh).2) name args C _ C' hrun y' rr ws rfl).2
  back _ _ _ _ a C y' rr ws C' hr hq hrun :=
    hq.trans (Host.Load.back_g (fun h hh => (hr.mlx.yabsent h hh).2) a C _ C' hrun y' rr ws rfl).2

/-- **The one-step theorem of the load world for the general relation**, for parameters `J`
accepting native calls by `okCallSG P` with the load world's deciders. -/
theorem loadStepSim (P : LoadP) (NB : Nat) (r : List NumV) (J : Disp.JSP LF) (hJ : J.okCall = okCallSG P)
    (hsm : J.smallB = smallLoadB loopVB) (hlo : J.lo = P.lo) (hh : J.isHandle = loadIsHandle)
    (hg : J.isRegion = loadIsRegion) :
    Disp.StepSimXV LF (LR P NB r) (Disp.okJS J) (Disp.Kp J) LoopVBOk := by
  have hC : FfiCallSim LF (LR P NB r) J.okCall smallLoad := by
    rw [hJ, ← okCallSG_rest P r]
    exact loadFfiCallSim _ _
  exact Disp.stepSimXV (loadFfiSim _ _) hC (fun _ _ _ _ _ hν hb => smallLoadB_sound (by rw [hsm] at hb; exact hb) hν)
    (loadR_laws _ _) loadFfiLawful (loadNativeFacts P NB r J hlo hh hg)

/-! ## Today's checks are general checks

Today's closure-apply check (`Host.Ts.Sim.NativeOk.clApply`: literal traces) implies the general
one when the template's compiled traces have present outputs (`TraceOutsPresent`, which the
fixed-id special case did not need): `okCallS P` accepts only calls `okCallSG P` accepts. -/

/-- The outputs of the template's compiled traces are present nodes. -/
def TraceOutsPresent (x : NSt) : Prop :=
  ∀ h cb pl sl ts, x.objs.get h = some (.clo (.compiled cb pl sl ts)) → ∀ t ∈ ts, ∀ a ∈ t.outs, PN x a

theorem clApplyG_of_clApply {P : LoadP} {NB : Nat} {M : Map} {n : Nat} {x y : NSt} (hr : MR P NB M n x y)
    (hout : TraceOutsPresent x) {args : List Arg} (h : Sim.NativeOk.clApply P x args = true) :
    NativeOk.clApplyG P x args = true := by
  unfold Sim.NativeOk.clApply at h
  unfold NativeOk.clApplyG
  split at h
  case h_2 => cases h
  rename_i o c v
  simp only [Bool.and_eq_true] at h ⊢
  obtain ⟨⟨⟨⟨ho, hc⟩, hv⟩, hE⟩, hm⟩ := h
  refine ⟨⟨⟨⟨ho, hc⟩, hv⟩, hE⟩, ?_⟩
  obtain ⟨ck, rfl, -, -⟩ := hr.hdOk_spec hc
  rw [argNat_nat, Option.bind_some] at hm ⊢
  cases hco : x.obj? ck with
  | none => rw [hco] at hm; cases hm
  | some oc =>
    rw [hco] at hm
    cases oc with
    | clo cl =>
      cases cl with
      | compiled cb pl sl ts =>
        cases hvo : (Host.Mlx.Ffi.argNat v).bind x.obj? with
        | none => rw [hvo] at hm; cases hm
        | some ov =>
          rw [hvo] at hm
          cases ov with
          | vec xs =>
            simp only [Bool.and_eq_true] at hm ⊢
            obtain ⟨⟨hxs, hts⟩, hft⟩ := hm
            have hxs' : ∀ k ∈ xs, litNode x k = true := fun k hk => List.all_eq_true.mp hxs k hk
            have tOk : ∀ t ∈ ts, (∀ a ∈ t.ins, a < P.NL ∧ litNode x a = true) ∧
                (∀ a ∈ t.order, rnodeOk P x a = true) ∧ x.nnext + t.order.length ≤ P.NE := by
              intro t ht
              have h := List.all_eq_true.mp hts t ht
              unfold traceOk at h
              rw [Bool.and_eq_true, Bool.and_eq_true, Bool.and_eq_true] at h
              obtain ⟨⟨⟨h1, -⟩, h3⟩, h4⟩ := h
              refine ⟨fun a ha => ?_, fun a ha => List.all_eq_true.mp h3 a ha, of_decide_eq_true h4⟩
              have := List.all_eq_true.mp h1 a ha
              rw [Bool.and_eq_true] at this
              exact ⟨of_decide_eq_true this.1, this.2⟩
            refine ⟨⟨List.all_eq_true.mpr fun k hk => MR.litNode_present (hxs' k hk),
              List.all_eq_true.mpr fun t ht => ?_⟩, ?_⟩
            · unfold traceOkG
              simp only [Bool.and_eq_true, Bool.or_eq_true, List.all_eq_true]
              refine ⟨⟨fun a ha => MR.litNode_present ((tOk t ht).1 a ha).2,
                fun a ha => hout ck cb pl sl ts hco t ht a ha⟩, .inr ⟨fun a ha => ((tOk t ht).1 a ha).2, hxs'⟩⟩
            · obtain ⟨r, hrm, e⟩ := findTrace_pure x sl xs ts fun t ht =>
                traceFits_pure x sl t xs (fun k hk => ((tOk t ht).1 k hk).2) hxs'
              rw [e] at hft ⊢
              cases r with
              | none => cases hft
              | some t =>
                obtain ⟨-, tOrd, tRoom⟩ := tOk t (hrm t rfl)
                simp only [Bool.and_eq_true, decide_eq_true_eq]
                refine ⟨rchk_of_lit ck t.order (t.ins.zip xs) (fun k hk => hr.nlt k hk) ?_ tOrd ?_, tRoom⟩
                · have := hr.nroom; omega
                · intro p hp
                  exact hxs' p.2 (List.of_mem_zip hp).2
          | _ => cases hm
      | _ => cases hm
    | _ => cases hm

theorem okCallSG_of_okCallS {P : LoadP} {NB : Nat} {M : Map} {n : Nat} {x y : Host.Load.LSt}
    (hr : LoadR P NB M n x y) (hout : TraceOutsPresent x.mlx) {name : Name} {args : List Arg}
    (h : okCallS P x name args = true) : okCallSG P x name args = true := by
  unfold okCallS at h
  unfold okCallSG
  simp only [Bool.or_eq_true, Bool.and_eq_true] at h ⊢
  rcases h with h | ⟨hm, h⟩
  · exact .inl h
  · refine .inr ⟨hm, ?_⟩
    cases hs : Host.Mlx.Ffi.symOf name with
    | none => rw [hs] at h; cases h
    | some s =>
      rw [hs] at h
      simp only at h ⊢
      cases s <;> first
        | exact clApplyG_of_clApply hr.mlx hout h
        | exact h

end Host.Ts.Sim.G
