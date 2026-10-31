import host.sim.compose.PreCall
import host.sim.conv.ReturnNum

namespace Host.Ts.Sim.Compose
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Prefill Host.Ts.Sim.Full
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

section
variable {F : Ffi} {FR : Map → Nat → F.S → F.S → Prop} {W : Nat → Option WFrame}
  {s : St F.S} {S : SSrv} {v : Nat} {x : F64} {Q B Q' B' : SegInst F → Prop}

/-- The chunk-size seam after compaction: bind fresh quantity variable `v`,
append it to the canonical table and abstract the literal return in zero steps. -/
theorem cut_abstractLit (hFR : FRLaws FR) (hctl : s.ctl = .ret (.num (.lit x)))
    (hfresh : ∀ e ∈ S.tab, e.noVar v = true)
    (hpost : ∀ c, Q c → B c →
      RelB F FR W [] c.M c.ν c.K s ⟨S.tab, []⟩ c.t c.C →
      Q' { c with M := c.M.setNum S.tab.length (.lit x), ν := upd c.ν v x } ∧
      B' { c with M := c.M.setNum S.tab.length (.lit x), ν := upd c.ν v x }) :
    CutConv ((Cut.mk s S.tab (Conv.relB F FR W [] Q)).with B)
      ((Cut.mk (s.ret (.num (.ref S.tab.length))) (S.tab ++ [.var v])
        (Conv.relB F FR W [] Q')).with B') := by
  rintro c ⟨hr, hq⟩ hb
  have ha := hr.abstractRetLit hFR hctl hfresh (fun _ h => nomatch h)
  obtain ⟨hq', hb'⟩ := hpost c hq hb hr
  exact ⟨{ c with M := c.M.setNum S.tab.length (.lit x), ν := upd c.ν v x },
    rfl, rfl, ⟨ha, hq'⟩, hb'⟩

/-- The same zero-step seam under the prefill's JavaScript pointer law. -/
theorem cut_abstractLitJ (hFR : FRLaws FR) (hctl : s.ctl = .ret (.num (.lit x)))
    (hfresh : ∀ e ∈ S.tab, e.noVar v = true)
    (hpost : ∀ c, Q c → B c →
      RelB F (Disp.FRJ FR) W [] c.M c.ν c.K s ⟨S.tab, []⟩ c.t c.C →
      Q' { c with M := c.M.setNum S.tab.length (.lit x), ν := upd c.ν v x } ∧
      B' { c with M := c.M.setNum S.tab.length (.lit x), ν := upd c.ν v x }) :
    CutConv ((Cut.mk s S.tab (Conv.relB F (Disp.FRJ FR) W [] Q)).with B)
      ((Cut.mk (s.ret (.num (.ref S.tab.length))) (S.tab ++ [.var v])
        (Conv.relB F (Disp.FRJ FR) W [] Q')).with B') := by
  rintro c ⟨hr, hq⟩ hb
  have ha := hr.abstractRetLitJ hFR hctl hfresh (fun _ h => nomatch h)
  obtain ⟨hq', hb'⟩ := hpost c hq hb hr
  exact ⟨{ c with M := c.M.setNum S.tab.length (.lit x), ν := upd c.ν v x },
    rfl, rfl, ⟨ha, hq'⟩, hb'⟩

end

/-- Binding the new result variable keeps old quantities and their bounds,
and records the result's quantity in the extended map. -/
theorem bindQuantity {VB : Nat → Nat} {ν : Nat → F64} {i : Cls.Inst} {m : List (Nat × Q)}
    {v c : Nat} {q : Q} (hVB : VBOkF VB ν) (hm : MapOk ν i m)
    (hfresh : ∀ p ∈ m, p.1 ≠ v) (hc : c = i.get q) (hbound : c ≤ VB v) :
    VBOkF VB (upd ν v (F64.ofNat c)) ∧ MapOk (upd ν v (F64.ofNat c)) i (m ++ [(v, q)]) := by
  constructor
  · intro w
    by_cases hw : w = v
    · subst w
      exact ⟨c, hbound, upd_self ν v (F64.ofNat c)⟩
    · rw [upd_other ν (F64.ofNat c) hw]
      exact hVB w
  · apply Conv.mapOk_iff'.2
    intro p hp
    rcases List.mem_append.mp hp with hp | hp
    · rw [upd_other ν (F64.ofNat c) (hfresh p hp)]
      exact (Conv.mapOk_iff'.1 hm) p hp
    · have he : p = (v, q) := List.mem_singleton.mp hp
      subst p
      rw [upd_self, hc]

end Host.Ts.Sim.Compose
