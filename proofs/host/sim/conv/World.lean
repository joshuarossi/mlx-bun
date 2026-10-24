import host.sim.conv.Call
import host.sim.world.Book
namespace Host.Ts.Sim.Conv
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Stage Host.Ts.Sim.Prefill

/-! # The stage conversions as `CutConv`s of the world layer

`host.sim.world.Book`'s `CutConv` is a 0-step cut step whose related pair may change its map,
valuation and context (`CutConv.step`). Isolate and merge are conversions (`conv_isolate`,
`conv_merge`); `cut_isolate`, `cut_merge` (`host.sim.conv.Call`) are their `CutConv.step`s, and a
stage call is `(conv_isolate …).step.trans (cut_stage …) |>.convR (conv_merge …)`. Over a world
`Wd` (`Wd.F`, `Wd.R P r`) they hold as stated: the theorems are generic in the FFI and the native
relation. -/

section
variable {F : Ffi} {FR FR0 : Map → Nat → F.S → F.S → Prop} {FS : Map → F.S → F.S → Prop}
  {W W0 : Nat → Option WFrame} {stk : List Frame} {ok : St F.S → SSrv → Bool}
  {NK : Map → F.S → F.S → F.S → Prop}
  {σ : Map} {θ : Nat → SymE} {rs : List Frame} {wr : List Nat} {s sr : St F.S} {tab : List SymE}
  {Q : SegInst F → Prop}

/-- **Isolate is a conversion.** -/
theorem conv_isolate (T : StageTpl F ok) {B : SegInst F → Prop}
    (hiso : ∀ c : SegInst F, Q c → B c → Iso F FS σ θ c.K rs T.s0 T.S0 s ⟨tab, []⟩)
    (hFS : ∀ M x y z, FS σ x y → FR M tab.length y z → FR0 (M.after σ) T.S0.tab.length x z)
    (hg : ∀ c : SegInst F, Q c → B c → Good (Shift.valuation θ c.ν) T.S0.oracle)
    (hroom : ∀ c : SegInst F, Q c → B c → c.t.next - T.s0.next < Sim.bound) :
    CutConv ((Cut.mk s tab (relB F FR W stk Q)).with B)
      ((Cut.mk T.s0 T.S0.tab (atCall F FR FR0 W W0 stk (fun c => Q c ∧ B c) σ θ rs s ⟨tab, []⟩ T.S0)).with
        fun _ => True) := by
  rintro c ⟨hc, hq⟩ hb
  exact ⟨⟨c.M.after σ, Shift.valuation θ c.ν, isoCtx c.K T.s0 c.t, c.t, c.C⟩, rfl, rfl,
    ⟨c, hc, ⟨hq, hb⟩, rfl, isolate (W0 := W0) (hFS c.M) hc (hiso c hq hb) (hg c hq hb) (hroom c hq hb)⟩, trivial⟩

/-- **Merge is a conversion.** -/
theorem conv_merge (T : StageTpl F ok) (hfoot : StageFoot wr T.s0 T.s2)
    (hmer : Mer σ (σ.res T.S0.tab.length tab.length) rs wr T.s0 s T.s2 sr)
    {es : List SymE} (hesl : es.length = T.S2.tab.length - T.S0.tab.length)
    (νr : (Nat → F64) → Nat → F64) {Q' B' : SegInst F → Prop}
    (hiso : ∀ c : SegInst F, Q c → Iso F FS σ θ c.K rs T.s0 T.S0 s ⟨tab, []⟩)
    (hνS : ∀ ν, ∀ e ∈ tab, e.eval (νr ν) = e.eval ν)
    (hes : ∀ ν j e, nth? es j = some e → ∃ e2, nth? T.S2.tab (T.S0.tab.length + j) = some e2 ∧
      e.eval (νr ν) = e2.eval (Shift.valuation θ ν))
    (hFM : ∀ (c y : SegInst F), Q c → Ext (c.M.after σ) y.M T.S0.tab.length →
      RelB F FR0 W0 (rs.map c.M.frame ++ stk) y.M (Shift.valuation θ c.ν) (isoCtx c.K T.s0 c.t) T.s2 T.S2 y.t y.C →
      NK (c.M.after σ) T.s0.ffi c.t.ffi y.t.ffi →
      FR (c.M.glue y.M tab.length T.S0.tab.length) (tab.length + es.length) sr.ffi y.t.ffi)
    (hQ : ∀ (c y : SegInst F), Q c → CSrv.Le c.C y.C → NK (c.M.after σ) T.s0.ffi c.t.ffi y.t.ffi →
      RelB F FR W stk (c.M.glue y.M tab.length T.S0.tab.length) (νr c.ν) c.K sr ⟨tab ++ es, []⟩ y.t y.C →
      Q' ⟨c.M.glue y.M tab.length T.S0.tab.length, νr c.ν, c.K, y.t, y.C⟩ ∧
        B' ⟨c.M.glue y.M tab.length T.S0.tab.length, νr c.ν, c.K, y.t, y.C⟩) :
    CutConv ((Cut.mk T.s2 T.S2.tab (atRet F FR FR0 W W0 stk Q σ θ rs s ⟨tab, []⟩ T.s0 T.S0 T.S2 NK)).with
        fun _ => True)
      ((Cut.mk sr (tab ++ es) (relB F FR W stk Q')).with B') := by
  intro y hy _
  obtain ⟨t', C', hrun, y', ht, hC, hR, hB⟩ :=
    cut_merge T hfoot hmer hesl νr hiso hνS hes hFM hQ y.t y.C ⟨y, rfl, rfl, hy, trivial⟩
  simp only [runC, runWith_zero, Option.some.injEq, Prod.mk.injEq] at hrun
  obtain ⟨rfl, rfl⟩ := hrun
  exact ⟨y', ht, hC, hR, hB⟩

end

end Host.Ts.Sim.Conv
