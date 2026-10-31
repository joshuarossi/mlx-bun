import host.sim.compose.Glue
import host.sim.dispatch.BridgeLen
import host.sim.template.Bridges

namespace Host.Ts.Sim.Compose
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Prefill

/-! A framed array's length bridge as an actual one-step cut transition. -/

section
variable {F : Ffi} {FR : Map → Nat → F.S → F.S → Prop}
  {W : Nat → Option WFrame} {sa sb : St F.S} {Sa Sb : SSrv}
  {Q B : SegInst F → Prop} {J : ICut F}
  {a : Nat} {opt : Bool} {fs : List Frame} {pre pre' xs : List Val} {o : Obj} {e : SymE}

/-- The checked length patch is the source representation of the target's actual length read.
The caller supplies the prompt-prefix bookkeeping and the destination cut's bookkeeping. -/
theorem cut_len (hFR : FRLaws FR)
    (hctl : sa.ctl = .ret (.obj a))
    (hstack : sa.stack = .e (.member kLength opt) :: fs)
    (hobj : sa.obj? a = some o) (hkind : o.kind = .array (pre ++ xs))
    (hpatch : Template.Bridge.lenPatch sa Sa e = (sb, Sb))
    (hframe : ∀ c, Q c → B c → c.K.fr a = some (pre, pre'))
    (hval : ∀ c, Q c → B c → e.eval c.ν = F64.ofNat (pre'.length + xs.length))
    (hQ : ∀ (c : SegInst F) (M' : Map) (t' : St F.S), Q c → B c →
      RelB F FR W [] c.M c.ν c.K sa ⟨Sa.tab, []⟩ c.t c.C → Ext c.M M' Sa.tab.length →
      RelB F FR W [] M' c.ν c.K sb ⟨Sb.tab, []⟩ t' c.C →
      J.R ⟨M', c.ν, c.K, t', c.C⟩ J.s0 ⟨J.tab0, []⟩ ∧ J.B ⟨M', c.ν, c.K, t', c.C⟩) :
    CutStep ((Cut.mk sa Sa.tab (Conv.relB F FR W [] Q)).with B) J 1 := by
  rintro t C ⟨c, rfl, rfl, ⟨hc, hq⟩, hb⟩
  have hsb : sb = ({ sa with stack := fs }.ret (.num (.ref Sa.tab.length))) := by
    have hp := congrArg Prod.fst hpatch
    simpa only [Template.Bridge.lenPatch, hstack, List.tail_cons] using hp.symm
  have htab : Sb.tab = Sa.tab ++ [e] := by
    have hp := congrArg (fun p : St F.S × SSrv => p.2.tab) hpatch
    exact hp.symm
  obtain ⟨hrun, hext, hrel⟩ := Disp.bridge_len hc hFR hctl hstack (hframe c hq hb) hobj hkind e (hval c hq hb)
  let t' : St F.S := { c.t with stack := fs.map c.M.frame ++ [] }.ret (natV (pre'.length + xs.length))
  have hrel' : RelB F FR W []
      (c.M.setNum Sa.tab.length (.lit (F64.ofNat (pre'.length + xs.length)))) c.ν c.K
      sb ⟨Sb.tab, []⟩ t' c.C := by
    rw [hsb, htab]
    exact hrel
  have hh : isHalt c.t.ctl = false := by
    have hx : RelXB F FR W [] c.M c.ν c.K sa ⟨Sa.tab, []⟩ c.t c.C := .inl hc
    rw [hx.isHalt, hctl]
    rfl
  obtain ⟨hR, hB⟩ := hQ c _ t' hq hb hc hext hrel'
  exact ⟨t', c.C, runC_one hh hrun, ⟨_, c.ν, c.K, t', c.C⟩, rfl, rfl, hR, hB⟩

end
end Host.Ts.Sim.Compose
