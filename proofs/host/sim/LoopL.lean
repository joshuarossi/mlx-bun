import host.sim.LoopGen
import host.sim.CasesL
namespace Host.Ts.Sim
open Host.Ts Host.Ts.Sim.Template

/-! # The loop invariant after a prompt of length `L`

`LoopInvL … L … i` is the loop invariant at iteration `i` after a prompt of `L` tokens: the
template start related to the target at the valuation `valL` (offset `L + i + 1`, capacity
`capL (L + i + 1)`). The obligations on the further invariant (`LoopGStepL`, `FinalGStepL`,
`ExitGStepL`, `FinalEGStepL`) and the steps (`loop_stepL`, `loop_allL`, `loop_all_toL`,
`final_stepL`, `exit_stepL`, `finalE_stepL`) are the generic ones (`host.sim.LoopGen`) at
`valL`; a loop case's restart grows the capacity exactly when the offset is a multiple of 256
(`hgrow`). At `L = 1` every definition is the existing one (`LoopInvL_one`, `LoopGStepL_one`,
`FinalGStepL_one`, `ExitGStepL_one`, `FinalEGStepL_one`). -/

/-! ## The definitions -/

/-- **The loop invariant at iteration `i` after a prompt of length `L`.** -/
abbrev LoopInvL (Gx : Nat → Map → St LF.S → CSrv → Prop) (P : LoadP) (s0 : St LF.S) (tab0 : List SymE)
    (fixA : List Nat) (L : Nat) (ρ : Nat → F64) (T : Nat) (tk : Nat → Nat) (toks : List NumV) (E0 : List Val)
    (ΔJ ΔH ΔN : Nat) (i : Nat) (t : St LF.S) (C : CSrv) : Prop :=
  LoopInvV Gx P s0 tab0 fixA (valL ρ T tk L) tk toks E0 ΔJ ΔH ΔN i t C

/-- The obligation of loop case `c` at iteration `i` after a prompt of length `L`. -/
abbrev LoopGStepL (Gx : Nat → Map → St LF.S → CSrv → Prop) {ok : St LF.S → SSrv → Bool} {P : LoadP}
    {s0 : St LF.S} {tab0 : List SymE} {fixA : List Nat} (c : LoopCase ok P s0 tab0 fixA) (L : Nat) (ρ : Nat → F64)
    (T : Nat) (tk : Nat → Nat) (toks : List NumV) (i : Nat) : Prop :=
  LoopGStepV Gx c (valL ρ T tk L) toks i

/-- The obligation of a final case after a prompt of length `L`. -/
abbrev FinalGStepL (Gx : Nat → Map → St LF.S → CSrv → Prop) (P : LoadP) (fixA : List Nat)
    {okA okB : St LF.S → SSrv → Bool} {s0 : St LF.S} {tab0 : List SymE} {cE aN : Nat}
    (fc : FinalCase okA okB s0 tab0 cE aN) (L : Nat) (ρ : Nat → F64) (T : Nat) (tk : Nat → Nat)
    (toks : List NumV) (G : St LF.S → CSrv → Prop) : Prop :=
  FinalGStepV Gx P fixA fc (valL ρ T tk L) T tk toks G

/-- The obligation of the EOS exit at iteration `i` after a prompt of length `L`. -/
abbrev ExitGStepL (Gx : Nat → Map → St LF.S → CSrv → Prop) (P : LoadP) (fixA : List Nat)
    {okA okB : St LF.S → SSrv → Bool} {s0 : St LF.S} {tab0 : List SymE} {cE aN : Nat}
    (ec : ExitCase okA okB s0 s0 tab0 cE aN []) (L : Nat) (ρ : Nat → F64) (T : Nat) (tk : Nat → Nat)
    (toks : List NumV) (i : Nat) (G : St LF.S → CSrv → Prop) : Prop :=
  ExitGStepV Gx P fixA ec (valL ρ T tk L) toks i G

/-- The obligation of an EOS final case after a prompt of length `L`. -/
abbrev FinalEGStepL (Gx : Nat → Map → St LF.S → CSrv → Prop) (P : LoadP) (fixA : List Nat)
    {okA okB : St LF.S → SSrv → Bool} {s0 : St LF.S} {tab0 : List SymE} {cE aN : Nat}
    (ec : ExitCase okA okB s0 (finalStart s0 tab0.length) (tab0 ++ [.var 17]) cE aN [.num (.ref 79)])
    (L : Nat) (ρ : Nat → F64) (T : Nat) (tk : Nat → Nat) (toks : List NumV) (G : St LF.S → CSrv → Prop) : Prop :=
  FinalEGStepV Gx P fixA ec (valL ρ T tk L) T tk toks G

/-! ## The steps -/

/-- **One loop iteration after a prompt of length `L`.** The case's restart grows the
capacity exactly when the offset `L + i + 1` is a multiple of 256. -/
theorem loop_stepL {Gx : Nat → Map → St LF.S → CSrv → Prop} {ok : St LF.S → SSrv → Bool} {P : LoadP}
    {s0 : St LF.S} {tab0 : List SymE} {fixA : List Nat} {jsP : Disp.JSP LF} {VBOk : (Nat → F64) → Prop}
    (hsim : ∀ r, Disp.StepSimXV LF (LR P r) ok (Disp.Kp jsP) VBOk)
    (hjlo : jsP.lo = P.lo) (hjhi : jsP.hi = P.E) (hjfr : jsP.framed = [2673447, 12502])
    (st : LoopStart P s0 tab0) (c : LoopCase ok P s0 tab0 fixA)
    {L : Nat} {ρ : Nat → F64} {T : Nat} {tk : Nat → Nat} {toks : List NumV} {E0 : List Val} {ΔJ ΔH ΔN : Nat}
    {i : Nat} {t : St LF.S} {C : CSrv}
    (hinv : LoopInvL Gx P s0 tab0 fixA L ρ T tk toks E0 ΔJ ΔH ΔN i t C) (hi1 : 1 ≤ i) (hlen : i < toks.length)
    (hgood : ∀ nx, Good (valL ρ T tk L i nx) c.S0.oracle)
    (hVB : ∀ nx, nx ≤ 2 ^ 20 → VBOk (valL ρ T tk L i nx))
    (hgrow : c.grow = decide ((L + i + 1) % 256 = 0)) (hpb : L + i + 2 < 2 ^ 30) (hcb : capL (L + i + 1) < 2 ^ 30)
    (htk : tk (i + 2) ≤ 2 ^ 20)
    (hdJ : c.s1.next - s0.next ≤ ΔJ) (hdH : c.s1.ffi.mlx.next - s0.ffi.mlx.next ≤ ΔH)
    (hdN : c.s1.ffi.mlx.nnext - s0.ffi.mlx.nnext ≤ ΔN)
    (hJ : i * ΔJ < Sim.bound) (hH : s0.ffi.mlx.next + i * ΔH + (P.E - s0.ffi.mlx.next) < 2 ^ 46)
    (hN : s0.ffi.mlx.nnext + i * ΔN + (P.NE - s0.ffi.mlx.nnext) < 2 ^ 62)
    (hng : ∀ (r : List NumV) (M : Map) (ν : Nat → F64) (K : Ctx) (n : Nat) (s t s1 t1 : St LF.S) (S S1 : SSrv)
      (C C1 : CSrv), Disp.Kp jsP K → VBOk ν → Rel LF (LR P r) M ν K s S t C → ok s S = true →
      runOk LF ok n s S = some (s1, S1) → runC LF n t C = some (t1, C1) → Host.Mlx.Ffi.NGrow t.ffi.mlx t1.ffi.mlx)
    (hG : LoopGStepL Gx c L ρ T tk toks i) :
    ∃ t' C', runC LF c.n t C = some (t', C') ∧ LoopInvL Gx P s0 tab0 fixA L ρ T tk toks E0 ΔJ ΔH ΔN (i + 1) t' C' :=
  loop_stepV hsim hjlo hjhi hjfr st c hinv hi1 hlen hgood hVB (fun _ => next_valL c.grow c.theta hpb hcb hgrow) htk
    hdJ hdH hdN hJ hH hN hng hG

/-- **The loop up to iteration `J` after a prompt of length `L`.** -/
theorem loop_all_toL {Gx : Nat → Map → St LF.S → CSrv → Prop} {ok : St LF.S → SSrv → Bool} {P : LoadP}
    {s0 : St LF.S} {tab0 : List SymE} {fixA : List Nat} {jsP : Disp.JSP LF} {VBOk : (Nat → F64) → Prop}
    (hsim : ∀ r, Disp.StepSimXV LF (LR P r) ok (Disp.Kp jsP) VBOk)
    (hjlo : jsP.lo = P.lo) (hjhi : jsP.hi = P.E) (hjfr : jsP.framed = [2673447, 12502])
    (st : LoopStart P s0 tab0) (sel : Nat → LoopCase ok P s0 tab0 fixA)
    {L : Nat} {ρ : Nat → F64} {T : Nat} {tk : Nat → Nat} {toks : List NumV} {E0 : List Val} {ΔJ ΔH ΔN : Nat}
    (J : Nat) (hJT : J + 2 ≤ T) (hlen : T - 2 ≤ toks.length)
    (hgood : ∀ i, 1 ≤ i → i < J → ∀ nx, Good (valL ρ T tk L i nx) (sel i).S0.oracle)
    (hVB : ∀ i, 1 ≤ i → i < J → ∀ nx, nx ≤ 2 ^ 20 → VBOk (valL ρ T tk L i nx))
    (hgrow : ∀ i, (sel i).grow = decide ((L + i + 1) % 256 = 0)) (hLT : L + T + 256 < 2 ^ 30)
    (htk : ∀ j, j ≤ T → tk j ≤ 2 ^ 20)
    (hdJ : ∀ i, (sel i).s1.next - s0.next ≤ ΔJ) (hdH : ∀ i, (sel i).s1.ffi.mlx.next - s0.ffi.mlx.next ≤ ΔH)
    (hdN : ∀ i, (sel i).s1.ffi.mlx.nnext - s0.ffi.mlx.nnext ≤ ΔN)
    (hJ : T * ΔJ < Sim.bound) (hH : s0.ffi.mlx.next + T * ΔH + (P.E - s0.ffi.mlx.next) < 2 ^ 46)
    (hN : s0.ffi.mlx.nnext + T * ΔN + (P.NE - s0.ffi.mlx.nnext) < 2 ^ 62)
    (hng : ∀ (r : List NumV) (M : Map) (ν : Nat → F64) (K : Ctx) (n : Nat) (s t s1 t1 : St LF.S) (S S1 : SSrv)
      (C C1 : CSrv), Disp.Kp jsP K → VBOk ν → Rel LF (LR P r) M ν K s S t C → ok s S = true →
      runOk LF ok n s S = some (s1, S1) → runC LF n t C = some (t1, C1) → Host.Mlx.Ffi.NGrow t.ffi.mlx t1.ffi.mlx)
    (hG : ∀ i, 1 ≤ i → i < J → LoopGStepL Gx (sel i) L ρ T tk toks i)
    {t : St LF.S} {C : CSrv} (h1 : LoopInvL Gx P s0 tab0 fixA L ρ T tk toks E0 ΔJ ΔH ΔN 1 t C) (hJ1 : 1 ≤ J) :
    ∃ t' C', runC LF (iterSteps (fun i => (sel i).n) 1 (J - 1)) t C = some (t', C') ∧
      LoopInvL Gx P s0 tab0 fixA L ρ T tk toks E0 ΔJ ΔH ΔN J t' C' :=
  loop_all_toV hsim hjlo hjhi hjfr st sel J hJT hlen hgood hVB
    (fun i _ hiJ _ => next_valL (sel i).grow (sel i).theta (by omega)
      (by have := capL_le (L + i + 1); omega) (hgrow i))
    htk hdJ hdH hdN hJ hH hN hng hG h1 hJ1

/-- **All loop iterations after a prompt of length `L`**: the invariant at iteration 1 gives
the invariant at the final iteration `T - 2`. -/
theorem loop_allL {Gx : Nat → Map → St LF.S → CSrv → Prop} {ok : St LF.S → SSrv → Bool} {P : LoadP}
    {s0 : St LF.S} {tab0 : List SymE} {fixA : List Nat} {jsP : Disp.JSP LF} {VBOk : (Nat → F64) → Prop}
    (hsim : ∀ r, Disp.StepSimXV LF (LR P r) ok (Disp.Kp jsP) VBOk)
    (hjlo : jsP.lo = P.lo) (hjhi : jsP.hi = P.E) (hjfr : jsP.framed = [2673447, 12502])
    (st : LoopStart P s0 tab0) (sel : Nat → LoopCase ok P s0 tab0 fixA)
    {L : Nat} {ρ : Nat → F64} {T : Nat} {tk : Nat → Nat} {toks : List NumV} {E0 : List Val} {ΔJ ΔH ΔN : Nat}
    (hT : 3 ≤ T) (hlen : T - 2 ≤ toks.length)
    (hgood : ∀ i, 1 ≤ i → i + 2 < T → ∀ nx, Good (valL ρ T tk L i nx) (sel i).S0.oracle)
    (hVB : ∀ i, 1 ≤ i → i + 2 < T → ∀ nx, nx ≤ 2 ^ 20 → VBOk (valL ρ T tk L i nx))
    (hgrow : ∀ i, (sel i).grow = decide ((L + i + 1) % 256 = 0)) (hLT : L + T + 256 < 2 ^ 30)
    (htk : ∀ j, j ≤ T → tk j ≤ 2 ^ 20)
    (hdJ : ∀ i, (sel i).s1.next - s0.next ≤ ΔJ) (hdH : ∀ i, (sel i).s1.ffi.mlx.next - s0.ffi.mlx.next ≤ ΔH)
    (hdN : ∀ i, (sel i).s1.ffi.mlx.nnext - s0.ffi.mlx.nnext ≤ ΔN)
    (hJ : T * ΔJ < Sim.bound) (hH : s0.ffi.mlx.next + T * ΔH + (P.E - s0.ffi.mlx.next) < 2 ^ 46)
    (hN : s0.ffi.mlx.nnext + T * ΔN + (P.NE - s0.ffi.mlx.nnext) < 2 ^ 62)
    (hng : ∀ (r : List NumV) (M : Map) (ν : Nat → F64) (K : Ctx) (n : Nat) (s t s1 t1 : St LF.S) (S S1 : SSrv)
      (C C1 : CSrv), Disp.Kp jsP K → VBOk ν → Rel LF (LR P r) M ν K s S t C → ok s S = true →
      runOk LF ok n s S = some (s1, S1) → runC LF n t C = some (t1, C1) → Host.Mlx.Ffi.NGrow t.ffi.mlx t1.ffi.mlx)
    (hG : ∀ i, 1 ≤ i → i + 2 < T → LoopGStepL Gx (sel i) L ρ T tk toks i)
    {t : St LF.S} {C : CSrv} (h1 : LoopInvL Gx P s0 tab0 fixA L ρ T tk toks E0 ΔJ ΔH ΔN 1 t C) :
    ∃ t' C', runC LF (iterSteps (fun i => (sel i).n) 1 (T - 3)) t C = some (t', C') ∧
      LoopInvL Gx P s0 tab0 fixA L ρ T tk toks E0 ΔJ ΔH ΔN (T - 2) t' C' :=
  loop_allV hsim hjlo hjhi hjfr st sel hT hlen hgood hVB
    (fun i _ hiT _ => next_valL (sel i).grow (sel i).theta (by omega)
      (by have := capL_le (L + i + 1); omega) (hgrow i))
    htk hdJ hdH hdN hJ hH hN hng hG h1

/-- **The final iteration after a prompt of length `L`.** -/
theorem final_stepL {Gx : Nat → Map → St LF.S → CSrv → Prop} {G : St LF.S → CSrv → Prop}
    {okA okB : St LF.S → SSrv → Bool} {P : LoadP} {s0 : St LF.S} {tab0 : List SymE}
    {fixA : List Nat} {jsPA jsPB : Disp.JSP LF} {VBOk : (Nat → F64) → Prop} {cE aN : Nat}
    (hsimA : ∀ r, Disp.StepSimXV LF (LR P r) okA (Disp.Kp jsPA) VBOk)
    (hsimB : ∀ r, Disp.StepSimXV LF (LR P r) okB (Disp.Kp jsPB) VBOk)
    (hngA : ∀ (r : List NumV) (M : Map) (ν : Nat → F64) (K : Ctx) (n : Nat) (s t s1 t1 : St LF.S) (S S1 : SSrv)
      (C C1 : CSrv), Disp.Kp jsPA K → VBOk ν → Rel LF (LR P r) M ν K s S t C → okA s S = true →
      runOk LF okA n s S = some (s1, S1) → runC LF n t C = some (t1, C1) → Host.Mlx.Ffi.NGrow t.ffi.mlx t1.ffi.mlx)
    (hngB : ∀ (r : List NumV) (M : Map) (ν : Nat → F64) (K : Ctx) (n : Nat) (s t s1 t1 : St LF.S) (S S1 : SSrv)
      (C C1 : CSrv), Disp.Kp jsPB K → VBOk ν → Rel LF (LR P r) M ν K s S t C → okB s S = true →
      runOk LF okB n s S = some (s1, S1) → runC LF n t C = some (t1, C1) → Host.Mlx.Ffi.NGrow t.ffi.mlx t1.ffi.mlx)
    (hsimAL : ∀ r, Disp.StepSimXL LF (LR P r) okA (Disp.Kp jsPA) VBOk)
    (hngAL : ∀ (r : List NumV) (M : Map) (ν : Nat → F64) (K : Ctx) (s t s1 t1 : St LF.S) (S S1 : SSrv) (C C1 : CSrv),
      Disp.Kp jsPA K → VBOk ν → RelX LF (LR P r) M ν K s S t C → isHalt s.ctl = false → okA s S = true →
      interpS (step LF s).run S = some (s1, S1) → interpC (step LF t).run C = some (t1, C1) →
      Host.Mlx.Ffi.NGrow t.ffi.mlx t1.ffi.mlx)
    (hjA : jsPA.lo = P.lo ∧ jsPA.hi = P.E ∧ jsPA.framed = [2673447, 12502])
    (hjB : jsPB.lo = P.lo ∧ jsPB.hi = P.E ∧ jsPB.framed = [2673447, 12502, aN])
    (st : LoopStart P s0 tab0) (fc : FinalCase okA okB s0 tab0 cE aN)
    (hfr17 : ∀ e ∈ tab0, e.noVar 17 = true) (hcE : cE ∈ fixA) (hb : 12502 ∈ fixA)
    (haN1 : aN ≠ 2673447) (haN2 : aN ≠ 12502)
    {L : Nat} {ρ : Nat → F64} {T : Nat} {tk : Nat → Nat} {toks : List NumV} {E0 : List Val} {ΔJ ΔH ΔN : Nat}
    {t : St LF.S} {C : CSrv} {env : Env} {nm : Name}
    (hinv : LoopInvL Gx P s0 tab0 fixA L ρ T tk toks E0 ΔJ ΔH ΔN (T - 2) t C) (hT : 3 ≤ T)
    (hlen : T - 1 ≤ toks.length)
    (hgood : Good (valL ρ T tk L (T - 2) (tk T)) fc.S0.oracle) (hVB : VBOk (valL ρ T tk L (T - 2) (tk T)))
    (henv : lookupEnv nm env = some cE) (hG : FinalGStepL Gx P fixA fc L ρ T tk toks G) :
    ∃ tF CF v, runC LF (fc.nA + 1 + 1 + fc.nB) t C = some (tF, CF) ∧ tF.ctl = .halt (.normal v) ∧
      (bindingOf tF env nm).bind (Host.Load.Extract.elements tF) = some (E0 ++ (toks.take (T - 1)).map Val.num) ∧
      CSrv.Le C CF ∧ G tF CF :=
  final_stepV hsimA hsimB hngA hngB hsimAL hngAL hjA hjB st fc hfr17 hcE hb haN1 haN2 (fun _ => upd_valL _) hinv hT
    hlen hgood hVB henv hG

/-- **EOS at a loop cut after a prompt of length `L`.** -/
theorem exit_stepL {Gx : Nat → Map → St LF.S → CSrv → Prop} {G : St LF.S → CSrv → Prop}
    {okA okB : St LF.S → SSrv → Bool} {P : LoadP} {s0 : St LF.S} {tab0 : List SymE}
    {fixA : List Nat} {jsPA jsPB : Disp.JSP LF} {VBOk : (Nat → F64) → Prop} {cE aN : Nat}
    (hsimA : ∀ r, Disp.StepSimXV LF (LR P r) okA (Disp.Kp jsPA) VBOk)
    (hsimB : ∀ r, Disp.StepSimXV LF (LR P r) okB (Disp.Kp jsPB) VBOk)
    (hngA : ∀ (r : List NumV) (M : Map) (ν : Nat → F64) (K : Ctx) (n : Nat) (s t s1 t1 : St LF.S) (S S1 : SSrv)
      (C C1 : CSrv), Disp.Kp jsPA K → VBOk ν → Rel LF (LR P r) M ν K s S t C → okA s S = true →
      runOk LF okA n s S = some (s1, S1) → runC LF n t C = some (t1, C1) → Host.Mlx.Ffi.NGrow t.ffi.mlx t1.ffi.mlx)
    (hngB : ∀ (r : List NumV) (M : Map) (ν : Nat → F64) (K : Ctx) (n : Nat) (s t s1 t1 : St LF.S) (S S1 : SSrv)
      (C C1 : CSrv), Disp.Kp jsPB K → VBOk ν → Rel LF (LR P r) M ν K s S t C → okB s S = true →
      runOk LF okB n s S = some (s1, S1) → runC LF n t C = some (t1, C1) → Host.Mlx.Ffi.NGrow t.ffi.mlx t1.ffi.mlx)
    (hsimAL : ∀ r, Disp.StepSimXL LF (LR P r) okA (Disp.Kp jsPA) VBOk)
    (hngAL : ∀ (r : List NumV) (M : Map) (ν : Nat → F64) (K : Ctx) (s t s1 t1 : St LF.S) (S S1 : SSrv) (C C1 : CSrv),
      Disp.Kp jsPA K → VBOk ν → RelX LF (LR P r) M ν K s S t C → isHalt s.ctl = false → okA s S = true →
      interpS (step LF s).run S = some (s1, S1) → interpC (step LF t).run C = some (t1, C1) →
      Host.Mlx.Ffi.NGrow t.ffi.mlx t1.ffi.mlx)
    (hjA : jsPA.lo = P.lo ∧ jsPA.hi = P.E ∧ jsPA.framed = [2673447, 12502])
    (hjB : jsPB.lo = P.lo ∧ jsPB.hi = P.E ∧ jsPB.framed = [2673447, 12502, aN])
    (ec : ExitCase okA okB s0 s0 tab0 cE aN []) (hcE : cE ∈ fixA) (hb : 12502 ∈ fixA) (haN2 : aN ≠ 12502)
    {L : Nat} {ρ : Nat → F64} {T : Nat} {tk : Nat → Nat} {toks : List NumV} {E0 : List Val} {ΔJ ΔH ΔN : Nat}
    {i : Nat} {t : St LF.S} {C : CSrv} {env : Env} {nm : Name}
    (hinv : LoopInvL Gx P s0 tab0 fixA L ρ T tk toks E0 ΔJ ΔH ΔN i t C)
    (hgood : ∀ nx, Good (valL ρ T tk L i nx) ec.S0.oracle)
    (hVB : ∀ nx, nx ≤ 2 ^ 20 → VBOk (valL ρ T tk L i nx))
    (henv : lookupEnv nm env = some cE) (hG : ExitGStepL Gx P fixA ec L ρ T tk toks i G) :
    ∃ tF CF v, runC LF ec.n t C = some (tF, CF) ∧ tF.ctl = .halt (.normal v) ∧
      (bindingOf tF env nm).bind (Host.Load.Extract.elements tF) = some (E0 ++ (toks.take (i - 1)).map Val.num) ∧
      CSrv.Le C CF ∧ G tF CF ∧
      ∃ MF ν KF, Rel LF (LR P (toks.drop i)) MF ν KF ec.sF ec.SF tF CF ∧ ∀ a ∈ fixA, MF.a a = a :=
  exit_stepV hsimA hsimB hngA hngB hsimAL hngAL hjA hjB ec hcE hb haN2 hinv hgood hVB henv hG

/-- **EOS at the last token after a prompt of length `L`.** -/
theorem finalE_stepL {Gx : Nat → Map → St LF.S → CSrv → Prop} {G : St LF.S → CSrv → Prop}
    {okA okB : St LF.S → SSrv → Bool} {P : LoadP} {s0 : St LF.S} {tab0 : List SymE}
    {fixA : List Nat} {jsPA jsPB : Disp.JSP LF} {VBOk : (Nat → F64) → Prop} {cE aN : Nat}
    (hsimA : ∀ r, Disp.StepSimXV LF (LR P r) okA (Disp.Kp jsPA) VBOk)
    (hsimB : ∀ r, Disp.StepSimXV LF (LR P r) okB (Disp.Kp jsPB) VBOk)
    (hngA : ∀ (r : List NumV) (M : Map) (ν : Nat → F64) (K : Ctx) (n : Nat) (s t s1 t1 : St LF.S) (S S1 : SSrv)
      (C C1 : CSrv), Disp.Kp jsPA K → VBOk ν → Rel LF (LR P r) M ν K s S t C → okA s S = true →
      runOk LF okA n s S = some (s1, S1) → runC LF n t C = some (t1, C1) → Host.Mlx.Ffi.NGrow t.ffi.mlx t1.ffi.mlx)
    (hngB : ∀ (r : List NumV) (M : Map) (ν : Nat → F64) (K : Ctx) (n : Nat) (s t s1 t1 : St LF.S) (S S1 : SSrv)
      (C C1 : CSrv), Disp.Kp jsPB K → VBOk ν → Rel LF (LR P r) M ν K s S t C → okB s S = true →
      runOk LF okB n s S = some (s1, S1) → runC LF n t C = some (t1, C1) → Host.Mlx.Ffi.NGrow t.ffi.mlx t1.ffi.mlx)
    (hsimAL : ∀ r, Disp.StepSimXL LF (LR P r) okA (Disp.Kp jsPA) VBOk)
    (hngAL : ∀ (r : List NumV) (M : Map) (ν : Nat → F64) (K : Ctx) (s t s1 t1 : St LF.S) (S S1 : SSrv) (C C1 : CSrv),
      Disp.Kp jsPA K → VBOk ν → RelX LF (LR P r) M ν K s S t C → isHalt s.ctl = false → okA s S = true →
      interpS (step LF s).run S = some (s1, S1) → interpC (step LF t).run C = some (t1, C1) →
      Host.Mlx.Ffi.NGrow t.ffi.mlx t1.ffi.mlx)
    (hjA : jsPA.lo = P.lo ∧ jsPA.hi = P.E ∧ jsPA.framed = [2673447, 12502])
    (hjB : jsPB.lo = P.lo ∧ jsPB.hi = P.E ∧ jsPB.framed = [2673447, 12502, aN])
    (st : LoopStart P s0 tab0)
    (ec : ExitCase okA okB s0 (finalStart s0 tab0.length) (tab0 ++ [.var 17]) cE aN [.num (.ref 79)])
    (hfr17 : ∀ e ∈ tab0, e.noVar 17 = true) (hcE : cE ∈ fixA) (hb : 12502 ∈ fixA) (haN2 : aN ≠ 12502)
    {L : Nat} {ρ : Nat → F64} {T : Nat} {tk : Nat → Nat} {toks : List NumV} {E0 : List Val} {ΔJ ΔH ΔN : Nat}
    {t : St LF.S} {C : CSrv} {env : Env} {nm : Name}
    (hinv : LoopInvL Gx P s0 tab0 fixA L ρ T tk toks E0 ΔJ ΔH ΔN (T - 2) t C) (hT : 3 ≤ T)
    (hlen : T - 1 ≤ toks.length)
    (hgood : Good (valL ρ T tk L (T - 2) (tk T)) ec.S0.oracle) (hVB : VBOk (valL ρ T tk L (T - 2) (tk T)))
    (henv : lookupEnv nm env = some cE) (hG : FinalEGStepL Gx P fixA ec L ρ T tk toks G) :
    ∃ tF CF v, runC LF ec.n t C = some (tF, CF) ∧ tF.ctl = .halt (.normal v) ∧
      (bindingOf tF env nm).bind (Host.Load.Extract.elements tF) = some (E0 ++ (toks.take (T - 2)).map Val.num) ∧
      CSrv.Le C CF ∧ G tF CF ∧
      ∃ MF ν KF, Rel LF (LR P (toks.drop (T - 1))) MF ν KF ec.sF ec.SF tF CF ∧ ∀ a ∈ fixA, MF.a a = a :=
  finalE_stepV hsimA hsimB hngA hngB hsimAL hngAL hjA hjB st ec hfr17 hcE hb haN2 (fun _ => upd_valL _) hinv hT hlen
    hgood hVB henv hG

/-! ## The prompt of length 1 -/

section One
variable {Gx : Nat → Map → St LF.S → CSrv → Prop} {P : LoadP} {s0 : St LF.S} {tab0 : List SymE} {fixA : List Nat}
  {ρ : Nat → F64} {T : Nat} {tk : Nat → Nat} {toks : List NumV} {G : St LF.S → CSrv → Prop}

/-- The existing invariant is the generic one at `val1`. -/
theorem LoopInv_eq (E0 : List Val) (ΔJ ΔH ΔN i : Nat) (t : St LF.S) (C : CSrv) :
    LoopInv Gx P s0 tab0 fixA ρ T tk toks E0 ΔJ ΔH ΔN i t C =
      LoopInvV Gx P s0 tab0 fixA (val1 ρ T tk) tk toks E0 ΔJ ΔH ΔN i t C := rfl

/-- **`LoopInvL` at `L = 1` is `LoopInv`.** -/
theorem LoopInvL_one (E0 : List Val) (ΔJ ΔH ΔN i : Nat) (t : St LF.S) (C : CSrv) :
    LoopInvL Gx P s0 tab0 fixA 1 ρ T tk toks E0 ΔJ ΔH ΔN i t C ↔
      LoopInv Gx P s0 tab0 fixA ρ T tk toks E0 ΔJ ΔH ΔN i t C := by
  rw [LoopInv_eq, LoopInvL, valL_one]

theorem LoopGStep_eq {ok : St LF.S → SSrv → Bool} (c : LoopCase ok P s0 tab0 fixA) (i : Nat) :
    LoopGStep Gx c ρ T tk toks i = LoopGStepV Gx c (val1 ρ T tk) toks i := rfl

/-- **`LoopGStepL` at `L = 1` is `LoopGStep`.** -/
theorem LoopGStepL_one {ok : St LF.S → SSrv → Bool} (c : LoopCase ok P s0 tab0 fixA) (i : Nat) :
    LoopGStepL Gx c 1 ρ T tk toks i ↔ LoopGStep Gx c ρ T tk toks i := by
  rw [LoopGStep_eq, LoopGStepL, valL_one]

/-- The final iteration's valuation of `LoopInv` (`T ≥ 2`). -/
theorem val1_final (hT : 2 ≤ T) (nx : Nat) :
    val1 ρ T tk (T - 2) nx = loopVal ρ T T (T - 2) (cap (T - 2)) (tk (T - 1)) (tk (T - 2)) nx := by
  unfold val1
  rw [show T - 2 + 2 = T by omega, show T - 2 + 1 = T - 1 by omega]

theorem FinalGStep_iff {okA okB : St LF.S → SSrv → Bool} {cE aN : Nat} (fc : FinalCase okA okB s0 tab0 cE aN)
    (hT : 2 ≤ T) :
    FinalGStep Gx P fixA fc ρ T tk toks G ↔ FinalGStepV Gx P fixA fc (val1 ρ T tk) T tk toks G := by
  unfold FinalGStep FinalGStepV
  simp only [val1_final hT]

/-- **`FinalGStepL` at `L = 1` is `FinalGStep`.** -/
theorem FinalGStepL_one {okA okB : St LF.S → SSrv → Bool} {cE aN : Nat} (fc : FinalCase okA okB s0 tab0 cE aN)
    (hT : 2 ≤ T) : FinalGStepL Gx P fixA fc 1 ρ T tk toks G ↔ FinalGStep Gx P fixA fc ρ T tk toks G := by
  rw [FinalGStep_iff fc hT, FinalGStepL, valL_one]

theorem ExitGStep_eq {okA okB : St LF.S → SSrv → Bool} {cE aN : Nat} (ec : ExitCase okA okB s0 s0 tab0 cE aN [])
    (i : Nat) : ExitGStep Gx P fixA ec ρ T tk toks i G = ExitGStepV Gx P fixA ec (val1 ρ T tk) toks i G := rfl

/-- **`ExitGStepL` at `L = 1` is `ExitGStep`.** -/
theorem ExitGStepL_one {okA okB : St LF.S → SSrv → Bool} {cE aN : Nat} (ec : ExitCase okA okB s0 s0 tab0 cE aN [])
    (i : Nat) : ExitGStepL Gx P fixA ec 1 ρ T tk toks i G ↔ ExitGStep Gx P fixA ec ρ T tk toks i G := by
  rw [ExitGStep_eq, ExitGStepL, valL_one]

theorem FinalEGStep_iff {okA okB : St LF.S → SSrv → Bool} {cE aN : Nat}
    (ec : ExitCase okA okB s0 (finalStart s0 tab0.length) (tab0 ++ [.var 17]) cE aN [.num (.ref 79)])
    (hT : 2 ≤ T) :
    FinalEGStep Gx P fixA ec ρ T tk toks G ↔ FinalEGStepV Gx P fixA ec (val1 ρ T tk) T tk toks G := by
  unfold FinalEGStep FinalEGStepV
  simp only [val1_final hT]

/-- **`FinalEGStepL` at `L = 1` is `FinalEGStep`.** -/
theorem FinalEGStepL_one {okA okB : St LF.S → SSrv → Bool} {cE aN : Nat}
    (ec : ExitCase okA okB s0 (finalStart s0 tab0.length) (tab0 ++ [.var 17]) cE aN [.num (.ref 79)])
    (hT : 2 ≤ T) : FinalEGStepL Gx P fixA ec 1 ρ T tk toks G ↔ FinalEGStep Gx P fixA ec ρ T tk toks G := by
  rw [FinalEGStep_iff ec hT, FinalEGStepL, valL_one]

end One

end Host.Ts.Sim
