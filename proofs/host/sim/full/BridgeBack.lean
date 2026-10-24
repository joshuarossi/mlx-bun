import host.sim.full.BridgeStep

/-! # A trace continuation with the Neural Engine bridge active

With the bridge active, the full world's continuation is the load world's followed by the
classification of the replayed nodes (`FfiAne.classify`) and the layers (`full_back_active`). On
related states with a band-free `P` the target classifies the image nodes (`BRel.classifyPost`), and
the relation after is the active one (`fullBackOfA`). -/

namespace Host.Ts.Sim.Full
open Host.Ts Host.Ts.Sim Host.Load.Layers
open Host.Mlx.Ffi.FullKeep (Keep)

/-- The bridge and the layers after the load world's continuation, with the bridge active. -/
def backContA (p : FF.S) (a : Arg) : Res Host.Load.LSt → Host.Ts.M (Res FF.S)
  | some (l, r, ws) => .pure (liftB p a ((Host.Mlx.FfiAne.classify (bridgeOf p) l.mlx
      (l.mlx.nnext - (mlxOf p).nnext) (mlxOf p).nnext).map fun b => ((⟨l, b⟩ : Host.Load.Ane.ASt), r, ws)))
  | none => .pure none

/-- **With the bridge active, the full world's continuation is the load world's followed by the
classification and the layers.** -/
theorem full_back_active (p : FF.S) (a : Arg) (ha : (bridgeOf p).active = true) :
    FF.back p a = Host.Ts.M.bind (Host.Load.back (toLoad p) a) (backContA p a) := by
  funext γ k
  rw [Observer.back_eq kern.total, Observer.back_eq live.total]
  show Host.Mlx.Ffi.back p.1.1.base.mlx a γ _ = Host.Mlx.Ffi.back p.1.1.base.mlx a γ _
  refine congrArg (Host.Mlx.Ffi.back p.1.1.base.mlx a γ) (funext fun o => ?_)
  rcases o with _ | ⟨m, r, ws⟩
  · rfl
  · show (Host.Ts.M.pure (bif p.1.1.bridge.active then _ else some (m, p.1.1.bridge, r, ws)) :
      Host.Ts.M (Option (Host.Mlx.Ffi.St × Host.Mlx.FfiAne.St × Ret × _))) γ _ = _
    rw [show p.1.1.bridge.active = true from ha, Bool.cond_true]
    show _ = (Host.Ts.M.pure (liftB p a ((Host.Mlx.FfiAne.classify p.1.1.bridge m
      (m.nnext - p.1.1.base.mlx.nnext) p.1.1.base.mlx.nnext).map fun b =>
        ((⟨{ p.1.1.base with mlx := m }, b⟩ : Host.Load.Ane.ASt), r, ws))) : Host.Ts.M (Res FF.S)) γ k
    cases Host.Mlx.FfiAne.classify p.1.1.bridge m (m.nnext - p.1.1.base.mlx.nnext) p.1.1.base.mlx.nnext <;> rfl

/-- **The layers after related load-world results of a continuation**, the bridges after related by `BR'`. -/
theorem full_back_postB {BR BR' : Map → FF.S → FF.S → Prop} {P : LoadP} {NB : Nat} {M M' : Map}
    {ν : Nat → F64} {S S' : SSrv} {C C' : CSrv} {x y : FF.S} {a : Arg} {l l' : Host.Load.LSt} {r r' : Ret}
    {ws ws' : List (Nat × Nat × List Byte)} {b1 b1' : BSt}
    (hr : FullRB BR P NB M S.tab.length x y) (hgr : Grow M ν S C M' S' C')
    (hcr : CallR (F := Host.Load.ffi) (G.LoadR P NB) M' S'.tab.length (some (l, r, ws)) (some (l', r', ws')))
    (kx : Keep (mlxOf x) l.mlx) (ky : Keep (mlxOf y) l'.mlx)
    (hbr : ∀ e e' k k', BR' M' (((⟨l, b1⟩ : Host.Load.Ane.ASt), e), k) (((⟨l', b1'⟩ : Host.Load.Ane.ASt), e'), k')) :
    MSim (fun M'' S'' C'' r r' => Grow M ν S C M'' S'' C'' ∧ CallR (F := FF) (FullRB BR' P NB) M'' S''.tab.length r r')
      S' C' (Host.Ts.M.pure (liftB x a (some (⟨l, b1⟩, r, ws))))
      (Host.Ts.M.pure (liftB y (M.arg a) (some (⟨l', b1'⟩, r', ws')))) := by
  obtain ⟨hlr, hr', hws⟩ := hcr
  have hob : ObsPost P NB M M' S.tab.length S'.tab.length (mlxOf x) (mlxOf y) l.mlx l'.mlx :=
    ⟨hr.load.mlx, hlr.mlx, hgr.ext, hgr.len, kx, ky⟩
  rw [liftB_some, liftB_some]
  exact MSim.pure ⟨hgr, ⟨hlr, hbr _ _ _ _, live_back hr.live hob hr.pend, kern_back hr.kern hob,
    hr.pend.step hr.load.mlx hlr.mlx hgr.ext kx⟩, hr', hws⟩

/-- **The layers after a load-world continuation simulation**, the bridge active and `P` band-free. -/
theorem fullBackOfA {P : LoadP} {NB : Nat} {M : Map} {ν : Nat → F64} {S : SSrv} {C : CSrv} {x y : FF.S} {a : Arg}
    (hr : FullRX P NB M S.tab.length x y) (hF : ∀ i, Full P i) (hact : (bridgeOf x).active = true)
    (hg : MSim (G.LPost P NB M ν S C) S C (Host.Load.back (toLoad x) a) (Host.Load.back (toLoad y) (M.arg a))) :
    MSim (fun M' S' C' r r' => Grow M ν S C M' S' C' ∧ CallR (F := FF) (FullRX P NB) M' S'.tab.length r r') S C
      (FF.back x a) (FF.back y (M.arg a)) := by
  have hbA := hr.bridge.active hact
  have hacty : (bridgeOf y).active = true := by rw [hbA.rel.active]; exact hact
  rw [full_back_active x a hact, full_back_active y _ hacty]
  have hg2 := MSim.both hg (loadFfiLawful.back _ _) (loadFfiLawful.back _ _)
  refine MSim.bind hg2 fun M' S' C' o o' hab => ?_
  obtain ⟨⟨hgr, hcr⟩, hra, hrb⟩ := hab
  rcases o with _ | ⟨l, r, ws⟩
  · rcases o' with _ | ⟨l', r', ws'⟩ <;> exact MSim.pure ⟨hgr, trivial⟩
  · rcases o' with _ | ⟨l', r', ws'⟩
    · exact hcr.elim
    · have kx := (load_back_keep _ a).1 S _ S' hra l r ws rfl
      have ky := (load_back_keep _ _).2 C _ C' hrb l' r' ws' rfl
      have hmx' := hcr.1.mlx
      have hd' : ∀ i, i < l.mlx.nnext → PN l.mlx i := fun i hi => by
        by_cases e : i < (mlxOf x).nnext
        · show (l.mlx.nodes.get i).isSome = true
          rw [kx.nodes i e]; exact hbA.dense i e
        · exact kx.dense i (Nat.not_lt.mp e) hi (by have := hmx'.xnnext_lt; omega)
      show MSim _ S' C' (Host.Ts.M.pure (liftB x a ((Host.Mlx.FfiAne.classify (bridgeOf x) l.mlx
          (l.mlx.nnext - (mlxOf x).nnext) (mlxOf x).nnext).map _)))
        (Host.Ts.M.pure (liftB y (M.arg a) ((Host.Mlx.FfiAne.classify (bridgeOf y) l'.mlx
          (l'.mlx.nnext - (mlxOf y).nnext) (mlxOf y).nnext).map _)))
      cases e : Host.Mlx.FfiAne.classify (bridgeOf x) l.mlx (l.mlx.nnext - (mlxOf x).nnext) (mlxOf x).nnext with
      | none => exact MSim.pure ⟨hgr, trivial⟩
      | some b1 =>
        obtain ⟨b1', e', hrel⟩ :=
          hbA.rel.classifyPost hr.load.mlx hmx' hgr.ext.node hF hbA.dense hd' kx.nnext e
        rw [e', Option.map_some, Option.map_some]
        exact full_back_postB hr hgr hcr kx ky
          (fun _ _ _ _ => .inr ⟨(classify_active _ _ e).trans hact, ⟨hrel, hd'⟩⟩)

end Host.Ts.Sim.Full
