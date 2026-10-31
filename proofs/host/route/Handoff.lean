import host.route.Final
import host.sim.conv.HandOff
import host.sim.full.HandleBand
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option autoImplicit false
namespace Host.Route
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill


/-- Moving the prefill relation to the decode handle boundary retains every symbolic and target state. -/
theorem prefillR_withLo {P : LoadP} {NB lo : Nat} {M : Map} {ν : Nat → F64}
    {K : Host.Ts.Sim.Ctx} {W : Nat → Option WFrame} {s t : St FF.S} {S : SSrv} {C : CSrv}
    (h : RelF FF (FullRXD P NB) W M ν K s S t C)
    (hpositive : 0 < lo) (hfixedBelow : ∀ i : Int, i < lo → M.big i = i)
    (hhandleImages : ∀ k, PH (mlxOf s.ffi) k → lo ≤ k → lo ≤ M.handle k)
    (hsourceNext : lo ≤ (mlxOf s.ffi).next) :
    RelF FF (FullRXD { P with lo := lo } NB) W M ν K s S t C :=
  { h with ffi := h.ffi.withLo hpositive hfixedBelow hhandleImages hsourceNext }

/-- POST retains the already read first token in addition to the unchanged decode cut. -/
def decCutFirstFb (NB : Nat) (A : Addr) (Gx : Nat → Map → St FF.S → CSrv → Prop)
    (W : Nat → Option WFrame) (Pd : LoadP) (Fr : LoopFramesA A) (s0 : St FF.S)
    (tab0 : List SymE) (fixA : List Nat) (V : LoopVals) (tk : Nat → Nat)
    (toks : List NumV) (E0 : List Val) (B : LoopBase) : ICut FF :=
  { decCutFb NB A Gx W Pd Fr s0 tab0 fixA V tk toks E0 B with
    B := fun x => (decCutFb NB A Gx W Pd Fr s0 tab0 fixA V tk toks E0 B).B x ∧
      x.C.val (.ref 1) = some (F64.ofNat (tk 1)) }

section
variable {NB : Nat} {A : Addr} {Gx : Nat → Map → St FF.S → CSrv → Prop}
  {W : Nat → Option WFrame} {Pd : LoadP} {Fr : LoopFramesA A} {s0 : St FF.S}
  {tab0 : List SymE} {fixA : List Nat} {V : LoopVals} {tk : Nat → Nat}
  {toks : List NumV} {E0 : List Val} {B : LoopBase}

theorem decCutFirstFb_forget :
    CutConv (decCutFirstFb NB A Gx W Pd Fr s0 tab0 fixA V tk toks E0 B)
      (decCutFb NB A Gx W Pd Fr s0 tab0 fixA V tk toks E0 B) :=
  fun x hr hb => ⟨x, rfl, rfl, hr, hb.1⟩

theorem decCutFirstFb_token {t : St FF.S} {C : CSrv}
    (h : (decCutFirstFb NB A Gx W Pd Fr s0 tab0 fixA V tk toks E0 B).Inv t C) :
    C.val (.ref 1) = some (F64.ofNat (tk 1)) := by
  obtain ⟨x, _, rfl, _, hb⟩ := h
  exact hb.2

/-- A pinned full relation supplies its own inactive-or-quiet bridge witness. -/
theorem decCutFb_of_rel {b0 : Host.Mlx.FfiAne.St} {x : SegInst FF}
    (hr : RelF FF (FullRFb b0 { Pd with rest := toks.drop 1 } NB) W x.M x.ν x.K
      s0 ⟨tab0, []⟩ x.t x.C)
    (hb : (loopCutW (fullWorldXD NB) A Gx W Pd Fr s0 tab0 fixA V tk toks E0 B).B x) :
    (decCutFb NB A Gx W Pd Fr s0 tab0 fixA V tk toks E0 B).Inv x.t x.C := by
  refine ⟨x, rfl, rfl, ⟨b0, ?_, hr⟩, hb⟩
  rw [← hr.ffi.bridge.2]
  exact hr.ffi.bridge.1.2

/-- The POST-to-decode seam, including the saved value of token one. -/
theorem decCutFirstFb_of_rel {b0 : Host.Mlx.FfiAne.St} {x : SegInst FF}
    (hr : RelF FF (FullRFb b0 { Pd with rest := toks.drop 1 } NB) W x.M x.ν x.K
      s0 ⟨tab0, []⟩ x.t x.C)
    (hb : (loopCutW (fullWorldXD NB) A Gx W Pd Fr s0 tab0 fixA V tk toks E0 B).B x)
    (hfirst : x.C.val (.ref 1) = some (F64.ofNat (tk 1))) :
    (decCutFirstFb NB A Gx W Pd Fr s0 tab0 fixA V tk toks E0 B).Inv x.t x.C := by
  obtain ⟨y, ht, hC, hyr, hyb⟩ := decCutFb_of_rel hr hb
  exact ⟨y, ht, hC, hyr, hyb, hC.symm ▸ hfirst⟩

end

/-- The generic checked handoff enters the route cut; POST supplies the shift and bookkeeping. -/
theorem decCutFirstFb_handoff {NB : Nat} {A : Addr}
    {Gx : Nat → Map → St FF.S → CSrv → Prop} {W : Nat → Option WFrame}
    {Pp Pd : LoadP} {Fr : LoopFramesA A} {s0 s1 t1 : St FF.S}
    {tab0 : List SymE} {S1 : SSrv} {fixA : List Nat} {V : LoopVals}
    {tk : Nat → Nat} {toks Eτ r : List NumV} {E0 : List Val} {B : LoopBase}
    {M1 κ : Map} {ν : Nat → F64} {K1 : Host.Ts.Sim.Ctx} {C1 : CSrv}
    {θ : Nat → SymE} {head : NumV}
    (hbandFree : Pp.NL = Pp.N0) (hlo : Pd.lo = Pp.lo) (hE : Pd.E = Pp.E)
    (hNE : Pd.NE = Pp.NE) (hNB : NB ≤ Pd.NL)
    (hrel : RelF FF (FullRXD { Pp with rest := r } NB) W M1 ν K1 s1 S1 t1 C1)
    (hqueue : (mlxOf s1.ffi).tokens = [head] ++ Eτ)
    (hdifferent : (s1.setFfi (fullSetTokens s1.ffi [head])).ffi ≠ s0.ffi)
    (hshift : ShiftD FF (fun σ x y => x = s0.ffi ∧ Conv.FullShiftH Pd tab0.length σ x y)
      κ θ (kpOf K1 W) W K1 s0 ⟨tab0, []⟩
      (s1.setFfi (fullSetTokens s1.ffi [head])) S1)
    (hbig : bigsOutB (mlxOf s0.ffi).next Pd.E (mlxOf s0.ffi) = true)
    (hfree : NoBigSt (fun i => ((mlxOf s0.ffi).next : Int) ≤ i ∧ i < Pd.E) s0.trace s0)
    (hband : ∀ i : Int, ((mlxOf s0.ffi).next : Int) ≤ i ∧ i < Pd.E →
      ¬ BigFixed K1.lo K1.hi i ∧ 0 ≤ i ∧ i < 2 ^ 56)
    (hheapRoom : t1.next - s0.next < Sim.bound)
    (hnativeRoom : NRoom Pd (Host.Load.Layers.toLoad s0.ffi) (Host.Load.Layers.toLoad t1.ffi))
    (hrest : Eτ.map M1.nv ++ r = toks.drop 1)
    (hbook : (loopCutW (fullWorldXD NB) A Gx W Pd Fr s0 tab0 fixA V tk toks E0 B).B
      ⟨((M1.after κ).rebig (mlxOf s0.ffi).next Pd.E (mlxOf t1.ffi).next),
       Shift.valuation θ ν,
       ⟨Shift.framedNext M1 K1 (s1.setFfi (fullSetTokens s1.ffi [head])),
        s0.trace, t1.trace, t1.next - s0.next, K1.lo, K1.hi⟩, t1, C1⟩)
    (hfirst : C1.val (.ref 1) = some (F64.ofNat (tk 1))) :
    (decCutFirstFb NB A Gx W Pd Fr s0 tab0 fixA V tk toks E0 B).Inv t1 C1 := by
  have hr := Conv.full_handoffTb NB (S0 := ⟨tab0, []⟩) hbandFree hlo hE hNE hNB hrel hqueue hdifferent
    hshift hbig hfree hband (fun _ h => nomatch h) hheapRoom hnativeRoom
  rw [hrest] at hr
  exact decCutFirstFb_of_rel hr hbook hfirst

end Host.Route
