import host.route.HandRho
import host.route.DecVal
import host.route.cert.Row.Hooks
import host.sim.template.a4hand.Hand
import host.sim.template.EndGenG
import host.sim.compose.ShortFix
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
set_option autoImplicit false
namespace Host.Route.PrefGraph
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Load Host.Load.Program Host.Load.Run.Prompt Host.Load.Run.Tpl
open Host.Mlx Host.Mlx.FfiEval Host.Mlx.SimGraph
open Host.Mlx.SimGraph.Iter (TplInputs)
open Host.Route.Cert.Row (rowToks rowCr)
open Host.Route (decVal_range)
open Inference Inference.Contracts.Mlx Inference.Models.Qwen

/-! # POST's end to the decode template

`hand_hval`: every variable the template's table reads has, at the loop's second iteration, the value the walk's substitution gives it at POST's
end. `hand_dec`: `postHandoff` at `Hand.walk`, from POST's cut. -/

/-- The variables the table reads. -/
def handClass (v : Nat) : Bool :=
  Nat.ble v 16 || (Nat.ble 20 v && Nat.ble v 26) || (Nat.ble 102 v && Nat.ble v 109) || (Nat.ble 114 v && Nat.ble v 161)

/-- A convolution cache's length through the template's two iterations. -/
def conv2 (j : Nat) : SymE :=
  .un .int32 (.bin .sub (.bin .add (.un .int32 (.bin .sub (.bin .add (.var j) (.lit (F64.ofNat 1))) (.lit (F64.ofNat 1))))
    (.lit (F64.ofNat 1))) (.lit (F64.ofNat 1)))

kernel_rfl hand_used : HandP.R.used.all handClass = true
kernel_rfl theta_9 : Hand.θ 9 = .bin .add (.bin .add (.var 11) (.lit (F64.ofNat 1))) (.lit (F64.ofNat 1))
kernel_rfl theta_10 : Hand.θ 10 = .lit (F64.ofNat 1)
kernel_rfl theta_11 : Hand.θ 11 = .lit (F64.ofNat 1)
kernel_rfl theta_12 : Hand.θ 12 = .lit (F64.ofNat 1)
kernel_rfl theta_13 : Hand.θ 13 = .lit (F64.ofNat 0)
kernel_rfl theta_14 : Hand.θ 14 = .var 2
kernel_rfl theta_15 : Hand.θ 15 = .var 1
kernel_rfl theta_21 : Hand.θ 21 = .var 200
kernel_rfl theta_id : ([0, 1, 2, 3, 4, 5, 6, 7, 8, 16, 20, 22, 23, 24, 25, 26] : List Nat).all (fun j => decide (Hand.θ j = .var j)) = true
kernel_rfl theta_trace : (List.range 8).all (fun i => decide (Hand.θ (102 + i) = .var (249 + i))) = true
kernel_rfl theta_conv : (List.range 48).all (fun i => decide (Hand.θ (114 + i) = conv2 (201 + i))) = true

theorem theta_of_id {j : Nat} (h : j ∈ ([0, 1, 2, 3, 4, 5, 6, 7, 8, 16, 20, 22, 23, 24, 25, 26] : List Nat)) : Hand.θ j = .var j :=
  of_decide_eq_true (List.all_eq_true.mp theta_id j h)

theorem traceVals : (List.range 8).all (fun i => (decVal (102 + i)).isSome && decide (tailVal (249 + i) = decVal (102 + i))) = true := by decide

theorem convVals : (List.range 48).all (fun i => decide (decVal (114 + i) = some 3) && decide (tailVal (201 + i) = some 3)) = true := by decide

theorem decVal_low {j : Nat} (h : j < 102) : decVal j = none := by
  cases hd : decVal j with
  | none => rfl
  | some k =>
    have := decVal_range hd
    omega

theorem handVal_low {L j : Nat} (h1 : 1 ≤ j) (h8 : j ≤ 8) : handVal L j = none := by
  have hj : j = 1 ∨ j = 2 ∨ j = 3 ∨ j = 4 ∨ j = 5 ∨ j = 6 ∨ j = 7 ∨ j = 8 := by omega
  rcases hj with rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl <;> (unfold handVal; cases Nat.ble L 2 <;> rfl)

theorem handRho_free {T L j : Nat} {tk : Nat → Nat} (hd : decVal j = none) (hne : Nat.beq j 21 = false) (hh : handVal L j = none) :
    handRho T L tk j = machVal T tk j := by
  unfold handRho
  rw [hd]
  dsimp only
  rw [hne]
  dsimp only [cond]
  rw [hh]

theorem handRho_hand {T L j k : Nat} {tk : Nat → Nat} (hd : decVal j = none) (hne : Nat.beq j 21 = false) (hh : handVal L j = some k) :
    handRho T L tk j = F64.ofNat k := by
  unfold handRho
  rw [hd]
  dsimp only
  rw [hne]
  dsimp only [cond]
  rw [hh]

theorem valL_rest {ρ : Nat → F64} {T L : Nat} {tk : Nat → Nat} {i nx j : Nat} (h : 17 < j) : valL ρ T tk L i nx j = ρ j :=
  loopVal_rest j (by omega) (.inr h)

theorem conv2_eval {ν : Nat → F64} {j : Nat} (h : ν j = F64.ofNat 3) : (conv2 j).eval ν = F64.ofNat 3 := by
  simp only [conv2, SymE.eval, h]
  rw [conv_value]
  exact conv_value

section
variable {T L : Nat} {tk : Nat → Nat} {ν : Nat → F64}

/-- **Each variable the table reads.** -/
theorem hand_val (hL1 : 1 ≤ L) (hL2 : L ≤ 224) (h11 : ν 11 = F64.ofNat L) (h16 : ν 16 = F64.ofNat (capL L))
    (hres : ∀ j, j < 9 → ν j = machVal T tk j) (hdims : ∀ v k, tailVal v = some k → ν v = F64.ofNat k)
    (hhand : ∀ v k, handVal L v = some k → ν v = F64.ofNat k) (v : Nat) (hc : handClass v = true) :
    valL (handRho T L tk) T tk L 1 0 v = (Hand.θ v).eval ν := by
  simp only [handClass, Bool.or_eq_true, Bool.and_eq_true, Nat.ble_eq] at hc
  rcases hc with ((hv | ⟨h1, h2⟩) | ⟨h1, h2⟩) | ⟨h1, h2⟩
  · by_cases h0 : v = 0
    · subst h0
      rw [theta_of_id (by decide)]
      show F64.ofNat T = ν 0
      rw [hres 0 (by decide)]
      simp [machVal]
    by_cases h8 : v ≤ 8
    · have hm : v ∈ ([0, 1, 2, 3, 4, 5, 6, 7, 8, 16, 20, 22, 23, 24, 25, 26] : List Nat) := by
        have hj : v = 1 ∨ v = 2 ∨ v = 3 ∨ v = 4 ∨ v = 5 ∨ v = 6 ∨ v = 7 ∨ v = 8 := by omega
        rcases hj with rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl <;> decide
      rw [theta_of_id hm]
      show loopVal _ _ _ _ _ _ _ _ v = ν v
      rw [loopVal_rest v h0 (.inl (by omega)), hres v (by omega)]
      exact handRho_free (decVal_low (by omega)) (by
        have : v ≠ 21 := by omega
        exact beq_false this) (handVal_low (by omega) h8)
    · have hj : v = 9 ∨ v = 10 ∨ v = 11 ∨ v = 12 ∨ v = 13 ∨ v = 14 ∨ v = 15 ∨ v = 16 := by omega
      rcases hj with rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl
      · rw [theta_9]
        show F64.ofNat (L + 1 + 1) = F64.add (F64.add (ν 11) (F64.ofNat 1)) (F64.ofNat 1)
        rw [h11, F64.add_ofNat53 L 1 (by omega), F64.add_ofNat53 (L + 1) 1 (by omega)]
      · rw [theta_10]; rfl
      · rw [theta_11]; rfl
      · rw [theta_12]; rfl
      · rw [theta_13]; rfl
      · rw [theta_14]
        show F64.ofNat (tk (1 + 1)) = ν 2
        rw [hres 2 (by decide)]
        simp [machVal]
      · rw [theta_15]
        show F64.ofNat (tk 1) = ν 1
        rw [hres 1 (by decide)]
        simp [machVal]
      · rw [theta_of_id (by decide)]
        show F64.ofNat (capL (L + 1 + 1)) = ν 16
        rw [h16]
        congr 1
        unfold capL
        omega
  · by_cases h21 : v = 21
    · subst h21
      rw [theta_21, valL_rest (by decide)]
      obtain ⟨k, hk⟩ : ∃ k, handVal L 200 = some k := by
        unfold handVal
        cases Nat.ble L 2 <;> exact ⟨_, rfl⟩
      show handRho T L tk 21 = ν 200
      rw [hhand 200 k hk]
      unfold handRho
      show (match handVal L 200 with
        | some k => F64.ofNat k
        | none => machVal T tk 21) = _
      rw [hk]
    · have hj : v = 20 ∨ v = 22 ∨ v = 23 ∨ v = 24 ∨ v = 25 ∨ v = 26 := by omega
      have hk : ∃ k, handVal L v = some k := by
        rcases hj with rfl | rfl | rfl | rfl | rfl | rfl <;> (unfold handVal; cases Nat.ble L 2 <;> exact ⟨_, rfl⟩)
      obtain ⟨k, hk⟩ := hk
      have hm : v ∈ ([0, 1, 2, 3, 4, 5, 6, 7, 8, 16, 20, 22, 23, 24, 25, 26] : List Nat) := by
        rcases hj with rfl | rfl | rfl | rfl | rfl | rfl <;> decide
      rw [theta_of_id hm, valL_rest (by omega)]
      show handRho T L tk v = ν v
      rw [hhand v k hk]
      exact handRho_hand (decVal_low (by omega)) (beq_false h21) hk
  · obtain ⟨i, rfl⟩ : ∃ i, v = 102 + i := ⟨v - 102, by omega⟩
    have hi : i < 8 := by omega
    have hmem : i ∈ List.range 8 := List.mem_range.mpr hi
    have hθ : Hand.θ (102 + i) = .var (249 + i) := of_decide_eq_true (List.all_eq_true.mp theta_trace i hmem)
    have hv := List.all_eq_true.mp traceVals i hmem
    simp only [Bool.and_eq_true, decide_eq_true_eq] at hv
    obtain ⟨k, hk⟩ := Option.isSome_iff_exists.mp hv.1
    rw [hθ, valL_rest (by omega)]
    show handRho T L tk (102 + i) = ν (249 + i)
    rw [hdims (249 + i) k (hv.2.trans hk), handRho_pin hk]
  · obtain ⟨i, rfl⟩ : ∃ i, v = 114 + i := ⟨v - 114, by omega⟩
    have hi : i < 48 := by omega
    have hmem : i ∈ List.range 48 := List.mem_range.mpr hi
    have hθ : Hand.θ (114 + i) = conv2 (201 + i) := of_decide_eq_true (List.all_eq_true.mp theta_conv i hmem)
    have hv := List.all_eq_true.mp convVals i hmem
    simp only [Bool.and_eq_true, decide_eq_true_eq] at hv
    rw [hθ, valL_rest (by omega), conv2_eval (hdims (201 + i) 3 hv.2)]
    exact handRho_pin hv.1

theorem nth?_mem' {α : Type} : ∀ {l : List α} {i : Nat} {e : α}, nth? l i = some e → e ∈ l
  | [], _, _, h => by cases h
  | a :: _, 0, _, h => by
    obtain rfl := Option.some.inj h
    exact List.mem_cons_self
  | _ :: _, i + 1, _, h => List.mem_cons_of_mem _ (nth?_mem' (i := i) h)

/-- **The table at the loop's second iteration is the table at the walk's substitution.** -/
theorem hand_hval (hL1 : 1 ≤ L) (hL2 : L ≤ 224) (h11 : ν 11 = F64.ofNat L) (h16 : ν 16 = F64.ofNat (capL L))
    (hres : ∀ j, j < 9 → ν j = machVal T tk j) (hdims : ∀ v k, tailVal v = some k → ν v = F64.ofNat k)
    (hhand : ∀ v k, handVal L v = some k → ν v = F64.ofNat k) (i : Nat) (e : SymE)
    (he : nth? DEC4_ord.S0.tab i = some e) :
    e.eval (valL (handRho T L tk) T tk L 1 0) = e.eval (Shift.valuation Hand.θ ν) :=
  eval_of_readsOnly (u := fun v => HandP.R.used.contains v)
    (fun v hv => hand_val hL1 hL2 h11 h16 hres hdims hhand v
      (List.all_eq_true.mp hand_used v (List.contains_iff_mem.mp hv))) e
    (List.all_eq_true.mp Hand.reads e (nth?_mem' he))

end

/-- The route's frames over the decode template. -/
theorem framesG_X (q : List Val) : (framesG DEC4_ord.s0 q).X 2665 = some (arrOf DEC4_ord.s0 2665, q) := rfl

theorem framesG_wide (q : List Val) (a : Nat) (h : wideG a ≠ none) : (framesG DEC4_ord.s0 q).X a ≠ none := by
  change (bif Nat.beq a 2665 then some (arrOf DEC4_ord.s0 2665, q) else bif (wideG a).isSome then some ([], []) else none) ≠ none
  cases Nat.beq a 2665
  · cases hw : wideG a with
    | none => exact absurd hw h
    | some w => simp
  · simp

theorem framesG_dom (q : List Val) (a : Nat) (h : (framesG DEC4_ord.s0 q).X a ≠ none) : a = 2665 ∨ wideG a ≠ none := by
  change (bif Nat.beq a 2665 then some (arrOf DEC4_ord.s0 2665, q) else bif (wideG a).isSome then some ([], []) else none) ≠ none at h
  cases h1 : Nat.beq a 2665 with
  | true => exact .inl (Nat.eq_of_beq_eq_true h1)
  | false =>
    rw [h1] at h
    cases hw : wideG a with
    | none => rw [hw] at h; exact absurd rfl h
    | some w => exact .inr (by simp)

theorem tail_dom (a : Nat) : a ∈ (Host.Load.Run.Tpl.PostOk.J).framed ↔ a = 2665 ∨ wideG a ≠ none := by
  show a ∈ 2665 :: 4910 :: ghostAddrs ↔ _
  rw [List.mem_cons, ← wideG_mem_iff, Option.isSome_iff_ne_none]

theorem hand_fix {a : Nat} (h : a ∈ Host.Ts.Sim.Compose.shortFixP) : Hand.κ.a a = a :=
  Nat.eq_of_beq_eq_true (List.all_eq_true.mp Hand.fixS a h)

section
variable {C : M1Max.Contract} {P : MlxPrefillContract C} {KR : RouteKernelContract C} {NE : NeuralEngine}
  {net : Host.Mlx.SimGraph.Ref.AneNet} {env : FfiEval.Env InKey} {π : List Nat}

/-- **POST's end gives the decode cut's invariant.** -/
theorem hand_dec {NB T cap nI : Nat} {tk : Nat → Nat} {I : TplInputs} {B : LoopBase} (hNB : NB ≤ 20000)
    (hL1 : 1 ≤ π.length) (hL2 : π.length ≤ 224)
    (hkr : Hand.κ.node I.read = rowToks π.length 1) (hkf : Hand.κ.node I.fed = rowToks π.length 2)
    (hkc : I.caches.map (fun p => (p.1.map Hand.κ.node, p.2.map Hand.κ.node)) = rowCr 2 π.length)
    (hBD : cap ≤ B.D) (hBH : 2 ^ 40 + 65536 ≤ B.H) (hBN : 2 ^ 40 + 65536 ≤ B.N) {x : SegInst FF}
    (hx : (Host.Ts.Sim.Compose.Post.indexedCut NB T tk cap nI π PRE_pl_r2.s448 PRE_pl_r2.S448).R x PRE_pl_r2.s448
      ⟨PRE_pl_r2.S448.tab, []⟩)
    (hb : (Host.Ts.Sim.Compose.Post.indexedCut NB T tk cap nI π PRE_pl_r2.s448 PRE_pl_r2.S448).B x)
    (hfrom : FromLoad T tk x) (he : x.M.a 12504 = 12504)
    (hm : memPost P KR NE net env π 2 rowToks (rowCr 2) π.length x) :
    ∃ kind, (decCutFirstFb NB addrPrompt (machGxV P KR NE net env π kind NB I) wideG Hand.Pd (framesG DEC4_ord.s0 (π.map natV))
      DEC4_ord.s0 DEC4_ord.S0.tab Host.Ts.Sim.Compose.shortFixP (valL (handRho T π.length tk) T tk π.length) tk
      (.ref 2 :: machReads T tk) [.num (.ref 1)] B).Inv x.t x.C := by
  obtain ⟨γ, hr, hbk⟩ := hx
  have hw := Hand.walk
  have hK := hbk.context.1
  have hnE := hw.nE
  have hnnE := hw.nnE
  have hfix : ∀ a ∈ Host.Ts.Sim.Compose.shortFixP, x.M.a a = a := by
    intro a ha
    have hj : a = 2586 ∨ a = 2589 ∨ a = 12504 ∨ a = 2590 := by simpa [Host.Ts.Sim.Compose.shortFixP] using ha
    rcases hj with rfl | rfl | rfl | rfl
    · exact hb.2.1.1
    · exact hb.2.1.2
    · exact he
    · exact hbk.emittedAnchor
  exact postHandoff (Pd := Hand.Pd) (H := 65536) (N := 65536) hw hNB (framesG_X _) (framesG_wide _) (framesG_dom _)
    (fun a ha => hand_fix ha) hkr hkf hkc (by decide) (by decide) hBD (by omega) (by omega)
    hr.ofJ hbk.prompt (fun a => (hK.2.2 a).trans (tail_dom a)) hK.1 hK.2.1 hbk.context.2 hbk.offsetLow hbk.reserved hb.2.2
    (hand_hval hL1 hL2 hbk.offsetValue hbk.capValue hbk.reserved hbk.dims hbk.hand) hfrom hfix hm

end

end Host.Route.PrefGraph
