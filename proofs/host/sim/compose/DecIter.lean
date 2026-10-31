import host.sim.compose.Loop
namespace Host.Ts.Sim.Compose
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin.Cls (DecKind)

section
variable {Wd : World} {A : Addr} {Gx : Nat → Map → St Wd.F.S → CSrv → Prop}
  {W : Nat → Option WFrame} {P : Wd.Par} {Fr : LoopFramesA A} {s0 : St Wd.F.S}
  {tab0 : List SymE} {fixA : List Nat} {ρ : Nat → F64} {T L : Nat} {tk : Nat → Nat}
  {toks : List NumV} {E0 : List Val} {B : LoopBase} {ΔJ ΔH ΔN : Nat}

/-- The universal decode iterations from the six cases alone. -/
theorem DecodeCasesW.itersW
    (D : DecodeCasesW Wd A P W s0 tab0 fixA Fr ρ T tk L toks E0 B ΔJ ΔH ΔN)
    (hE : Wd.EndLaws) (hA : A.nxt = 17) (st : LoopStartW Wd A P s0 tab0)
    (hLT : L + T < 2 ^ 29) (hlen : T - 2 ≤ toks.length)
    (htk : ∀ j, j ≤ T → tk j ≤ 2 ^ 20) (htv : ∀ j, j ≤ T → tk j ≤ 248319)
    (hJ : T * ΔJ + B.D < Sim.bound)
    (hH : (Wd.toMlx s0.ffi).next + T * ΔH + B.H + (Wd.E P - (Wd.toMlx s0.ffi).next) < 2 ^ 46)
    (hN : (Wd.toMlx s0.ffi).nnext + T * ΔN + B.N + (Wd.NE P - (Wd.toMlx s0.ffi).nnext) < 2 ^ 62)
    (hG : ∀ k i, DecSel T L tk k i → (∀ j, 1 ≤ j → j ≤ i + 1 → tk j ≠ 248044) →
      LoopGStepGW Gx W Fr (D.cs k).e (D.cs k).g (valL ρ T tk L) toks i) :
    DecodeItersW (DecodeInvW Wd A Gx W P Fr s0 tab0 fixA (valL ρ T tk L) tk toks E0 B ΔJ ΔH ΔN) T tk :=
  Host.Ts.Sim.Compose.itersW hE hA st D.cs D.gr hLT hlen htk htv hJ hH hN hG

end
end Host.Ts.Sim.Compose
