import host.sim.compose.DecIter
namespace Host.Ts.Sim.Compose
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Prefill
section
variable {Wd : World} {A : Addr} {P : Wd.Par} {W : Nat → Option WFrame} {s0 : St Wd.F.S} {tab0 : List SymE}
  {fixA : List Nat} {Fr : LoopFramesA A}
variable (Wd A P W s0 tab0 fixA Fr) in
/-- Decode pieces whose halt entries use the exact frames already retained by the invariant. -/
structure DecodePiecesFramedW (ρ : Nat → F64) (T : Nat) (tk : Nat → Nat) (L : Nat) (toks : List NumV) (E0 : List Val)
    (B : LoopBase) (ΔJ ΔH ΔN : Nat) extends
    DecodeCasesW Wd A P W s0 tab0 fixA Fr ρ T tk L toks E0 B ΔJ ΔH ΔN where
  -- the final chains without EOS
  f0 : Halt4W Wd A P W s0 (Wd.finalStartW s0 tab0.length) (tab0 ++ [.var A.nxt]) [.num (.ref A.tok), .num (.ref tab0.length)]
  f1 : Halt4W Wd A P W s0 (Wd.finalStartW s0 tab0.length) (tab0 ++ [.var A.nxt]) [.num (.ref A.tok), .num (.ref tab0.length)]
  f2 : Halt4W Wd A P W s0 (Wd.finalStartW s0 tab0.length) (tab0 ++ [.var A.nxt]) [.num (.ref A.tok), .num (.ref tab0.length)]
  c0 : FinalOk false false f0.O
  c1 : FinalOk true false f1.O
  c2 : FinalOk false true f2.O
  qF : ∀ p1 (K : Ctx), K.fr = frA A s0 Fr.X p1 (E0 ++ (toks.take (T - 2 - 1)).map Val.num) →
    K.lo = Wd.lo P → K.hi = Wd.E P →
    f0.QA (valL ρ T tk L (T - 2) (tk T)) K ∧ f1.QA (valL ρ T tk L (T - 2) (tk T)) K ∧
      f2.QA (valL ρ T tk L (T - 2) (tk T)) K
  -- the EOS exit at a loop cut
  x : Halt2W Wd A P W s0 s0 tab0 []
  cX : ExitOk x.O
  qX : ∀ k, 2 ≤ k → k < T → ∀ nx p1 (K : Ctx), nx ≤ 2 ^ 20 →
    K.fr = frA A s0 Fr.X p1 (E0 ++ (toks.take (k - 1 - 1)).map Val.num) →
    K.lo = Wd.lo P → K.hi = Wd.E P → x.QA (valL ρ T tk L (k - 1) nx) K
  sX : StopAtW W A x.sE
  -- the EOS final chains
  e0 : Halt4W Wd A P W s0 (Wd.finalStartW s0 tab0.length) (tab0 ++ [.var A.nxt]) [.num (.ref A.tok)]
  e1 : Halt4W Wd A P W s0 (Wd.finalStartW s0 tab0.length) (tab0 ++ [.var A.nxt]) [.num (.ref A.tok)]
  c0E : FinalEOk false e0.O
  c1E : FinalEOk true e1.O
  qE : ∀ p1 (K : Ctx), K.fr = frA A s0 Fr.X p1 (E0 ++ (toks.take (T - 2 - 1)).map Val.num) →
    K.lo = Wd.lo P → K.hi = Wd.E P →
    e0.QA (valL ρ T tk L (T - 2) (tk T)) K ∧ e1.QA (valL ρ T tk L (T - 2) (tk T)) K
  s0E : StopAtW W A e0.sE
  s1E : StopAtW W A e1.sE


end
end Host.Ts.Sim.Compose
