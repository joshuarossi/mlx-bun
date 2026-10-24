import host.sim.full.BridgeBack
import host.sim.full.BridgeRaise

/-! # The one-step theorems of the full world with the Neural Engine bridge

At `FullRXD` (`FullRX` at a raise of `P`): for a band-free `P` the calls and continuations are checked
and simulated at the band raised to the template's node counter (`FullRXD.top`), where every node
fully corresponds; otherwise at `P` (`okCallFXD`, `fullCallSimXD`; `okBackFX`, `fullBackSimXD`, the
bridge inactive or active). The one-step theorems of `Disp.okJSK` follow (`fullStepSim*XDK`). -/

namespace Host.Ts.Sim.Full
open Host.Ts Host.Ts.Sim

theorem callR_mono {R R' : Map → Nat → FF.S → FF.S → Prop} (h : ∀ M n x y, R M n x y → R' M n x y) {M : Map}
    {n : Nat} {r r' : Option (FF.S × Ret × List (Nat × Nat × List Byte))} (hc : CallR (F := FF) R M n r r') :
    CallR (F := FF) R' M n r r' := by
  rcases r with _ | ⟨x', r1, ws⟩ <;> rcases r' with _ | ⟨y', r2, ws'⟩
  · trivial
  · trivial
  · exact hc
  · exact ⟨h _ _ _ _ hc.1, hc.2⟩

/-- **The accepted calls at a raise**: for a band-free `P`, `okCallFX2` at the band raised to the
template's node counter; otherwise at `P`. -/
def okCallFXD (P : LoadP) (x : FF.S) (name : Name) (args : List Arg) : Bool :=
  bif decide (P.NL = P.N0) then okCallFX2 (P.raise (mlxOf x).nnext) x name args else okCallFX2 P x name args

/-- **The native-call simulation with the bridge at a raise.** -/
theorem fullCallSimXD (P : LoadP) (NB : Nat) : FfiCallSim FF (FullRXD P NB) (okCallFXD P) smallFX2 where
  call := by
    intro M ν S C x y name args hsrv hr hok hsupp hsm
    unfold okCallFXD at hok
    by_cases hb : P.NL = P.N0
    · rw [show decide (P.NL = P.N0) = true from decide_eq_true hb, Bool.cond_true] at hok
      obtain ⟨hrr, hP⟩ := hr.top hb
      refine MSim.mono ((fullCallSimX2 _ NB).call M ν S C x y name args hsrv hrr hok hsupp hsm) ?_
      exact fun M' S' C' r r' h => ⟨h.1, callR_mono (fun _ _ _ _ h => ⟨_, hP, h⟩) h.2⟩
    · rw [show decide (P.NL = P.N0) = false from decide_eq_false hb, Bool.cond_false] at hok
      refine MSim.mono ((fullCallSimX2 P NB).call M ν S C x y name args hsrv (hr.self hb) hok hsupp hsm) ?_
      exact fun M' S' C' r r' h => ⟨h.1, callR_mono (fun _ _ _ _ h => FullRX.toXD h) h.2⟩

/-- **The full world's accepted continuations with the bridge**: a band-free `P` and the general check
at the band raised to the node counter. -/
def okBackFX (P : LoadP) (x : FF.S) (a : Arg) : Bool :=
  decide (P.NL = P.N0) && G.backOkG (P.raise (mlxOf x).nnext) (mlxOf x) a

/-- **The full world's continuation simulation with the bridge at a raise.** -/
theorem fullBackSimXD (P : LoadP) (NB : Nat) : FfiBackSim FF (FullRXD P NB) (okBackFX P) where
  back := by
    intro M ν S C x y a hsrv hr hok _
    simp only [okBackFX, Bool.and_eq_true, decide_eq_true_eq] at hok
    obtain ⟨hb, hg⟩ := hok
    obtain ⟨hrr, hP⟩ := hr.top hb
    have hgl := G.mlx_liftB hrr.load (G.sim_traceBack hsrv hrr.load.mlx hg)
    cases hact : (bridgeOf x).active
    · refine MSim.mono (fullBackOf (hrr.toR hact) hact hgl) ?_
      exact fun M' S' C' r r' h => ⟨h.1, callR_mono (fun _ _ _ _ h => ⟨_, hP, h.toX⟩) h.2⟩
    · have hF : ∀ i, Full (P.raise (mlxOf x).nnext) i := fun i => by
        show i < (mlxOf x).nnext ∨ (mlxOf x).nnext ≤ i; omega
      refine MSim.mono (fullBackOfA hrr hF hact hgl) ?_
      exact fun M' S' C' r r' h => ⟨h.1, callR_mono (fun _ _ _ _ h => ⟨_, hP, h⟩) h.2⟩

/-- The full world's acceptance parameters with the bridge at a raise. -/
abbrev fullJSPXX (P : LoadP) (VB : Nat → Nat) (framed : List Nat) (wide : List (Nat × WFrame) := []) : Disp.JSP FF :=
  { okCall := okCallFXD P, smallB := smallFX2B VB, lo := P.lo, hi := P.E, framed := framed,
    isHandle := fullIsHandle, isRegion := fullIsRegion, wide := wide }

section
variable (P : LoadP) (NB : Nat) (VB : Nat → Nat) (J : Disp.JSP FF) (hJ : J.okCall = okCallFXD P)
  (hsm : J.smallB = smallFX2B VB) (hlo : J.lo = P.lo) (hh : J.isHandle = fullIsHandle)
  (hg : J.isRegion = fullIsRegion)
include hJ hsm hlo hh hg

/-- **The one-step theorem of the full world with the bridge at a raise, with continuations**
(`Disp.okJSK`), under frames `W` and a stack base. -/
theorem fullStepSimXBXDK {W : Nat → Option WFrame} (stk : List Frame) (hW : Disp.Wp J W) :
    Disp.StepSimXVB FF (FullRXD P NB) (Disp.okJSK J (okBackFX P)) (Disp.Kp J) W stk (VBOkF VB) :=
  Disp.stepSimXVBK (fullFfiSimXD P NB) (fullBackSimXD P NB) (by rw [hJ]; exact fullCallSimXD P NB)
    (fun _ _ _ _ _ hν hb => smallFX2B_sound hν (by rw [hsm] at hb; exact hb))
    (fullRXD_laws P NB) fullLawful (fullNativeFactsXD P NB J hlo hh hg) hW

/-- The one-step theorem with the bridge at a raise with continuations for any reached state, under
frames and a stack base. -/
theorem fullStepSimXLBXDK {W : Nat → Option WFrame} (stk : List Frame) (hW : Disp.Wp J W) :
    Disp.StepSimXLB FF (FullRXD P NB) (Disp.okJSK J (okBackFX P)) (Disp.Kp J) W stk (VBOkF VB) :=
  Disp.stepSimXLBK (fullFfiSimXD P NB) (fullBackSimXD P NB) (by rw [hJ]; exact fullCallSimXD P NB)
    (fun _ _ _ _ _ hν hb => smallFX2B_sound hν (by rw [hsm] at hb; exact hb))
    (fullRXD_laws P NB) fullLawful (fullNativeFactsXD P NB J hlo hh hg) hW

/-- The one-step theorem with the bridge at a raise with continuations for any reached state. -/
theorem fullStepSimXLXDK : Disp.StepSimXL FF (FullRXD P NB) (Disp.okJSK J (okBackFX P)) (Disp.Kp J) (VBOkF VB) :=
  Disp.stepSimXLK (fullFfiSimXD P NB) (fullBackSimXD P NB) (by rw [hJ]; exact fullCallSimXD P NB)
    (fun _ _ _ _ _ hν hb => smallFX2B_sound hν (by rw [hsm] at hb; exact hb))
    (fullRXD_laws P NB) fullLawful (fullNativeFactsXD P NB J hlo hh hg)

end

end Host.Ts.Sim.Full
