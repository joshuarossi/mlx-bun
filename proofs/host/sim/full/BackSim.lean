import host.sim.full.Back
import host.sim.full.Raise
import host.sim.dispatch.OkBack

/-! # The full world's trace continuation at a raise

A `JSCallback` that recorded a trace returns to `traceBack` (`back`). The full world's continuation
is the load world's with the bridge inactive (`full_back_load`), followed by the layers: the
liveness layer frees the tracer vector allocated just before the pending id (`live_back`, the
adjacency `G.PendReg.reg` keeps), the kernel-recording layer keeps its record.

The recorded trace names fresh nodes, so the relation after it is at a raise: from a band-free `P`
(`P.NL = P.N0`, decided), `FullRD` raises to the node counter before the continuation (`FullR.raise`),
where every recorded node is pre-loop and the general check `G.backOkG` applies (`okBackF`,
`fullBackSimD`). The one-step theorems of `Disp.okJSK` follow (`fullStepSim*DK`). -/

namespace Host.Ts.Sim.G
open Host.Ts.Sim.BufSim (Lawful)

/-- **Lift.** An mlx continuation simulation is a load-world continuation simulation. -/
theorem mlx_liftB {P : LoadP} {NB : Nat} {M : Map} {ν : Nat → F64} {S : SSrv} {C : CSrv} {x y : Host.Load.LSt}
    {a a' : Arg} (hr : LoadR P NB M S.tab.length x y)
    (h : MSim (MPost P NB M ν S C) S C (Host.Mlx.Ffi.back x.mlx a) (Host.Mlx.Ffi.back y.mlx a')) :
    MSim (LPost P NB M ν S C) S C (Host.Load.back x a) (Host.Load.back y a') := by
  unfold Host.Load.back
  refine MSim.bind h fun M' S' C' o o' hab => ?_
  obtain ⟨hg, hc⟩ := hab
  cases o with
  | none =>
    cases o' with
    | none => exact MSim.pure ⟨hg, trivial⟩
    | some q => obtain ⟨_, _, _⟩ := q; exact MSim.pure ⟨hg, trivial⟩
  | some p =>
    obtain ⟨m, r, ws⟩ := p
    cases o' with
    | none => exact hc.elim
    | some q =>
      obtain ⟨m', r', ws'⟩ := q
      obtain ⟨hmr, hr', hws⟩ := hc
      refine MSim.pure ⟨hg, ⟨?_, hr', hws⟩⟩
      exact ⟨hr.host, fun k hk => by rw [hg.ext.region]; exact hr.hostReg k hk, hr.hostLt,
        fun a => by rw [hg.ext.region, hg.ext.a]; exact hr.cbr a, hmr⟩

end Host.Ts.Sim.G

namespace Host.Ts.Sim.Full
open Host.Ts Host.Ts.Sim Host.Load.Layers
open Host.Mlx.Ffi.FullKeep (Keep AllX KRes)

/-! ## The continuation through the layers -/

/-- The layers' result for a Neural Engine world result of a continuation from `p`. -/
def liftB (p : FF.S) (a : Arg) (o : Res Host.Load.Ane.ASt) : Res FF.S :=
  kern.total.post (fun x' r => kern.total.onBack p.2 p.1 x' a r)
    (live.total.post (fun x' r => live.total.onBack p.1.2 p.1.1 x' a r) o)

theorem liftB_some (p : FF.S) (a : Arg) (a' : Host.Load.Ane.ASt) (r : Ret) (ws : List (Nat × Nat × List Byte)) :
    liftB p a (some (a', r, ws)) =
      some (((a', p.1.2.bind fun e => liveBack e p.1.1.base.mlx), p.2.bind fun k => some k), r, ws) := by
  simp only [liftB, Observer.post, Option.map]

/-- The layers after the load world's continuation, with the bridge inactive. -/
def backCont (p : FF.S) (a : Arg) : Res Host.Load.LSt → Host.Ts.M (Res FF.S)
  | some (l, r, ws) => .pure (liftB p a (some (⟨l, bridgeOf p⟩, r, ws)))
  | none => .pure none

theorem backCont_some (p : FF.S) (a : Arg) (l : Host.Load.LSt) (r : Ret) (ws : List (Nat × Nat × List Byte)) :
    backCont p a (some (l, r, ws)) = .pure (liftB p a (some (⟨l, bridgeOf p⟩, r, ws))) := rfl

theorem backCont_none (p : FF.S) (a : Arg) : backCont p a none = .pure none := rfl

/-- **With the bridge inactive, the full world's continuation is the load world's followed by the
layers.** -/
theorem full_back_load (p : FF.S) (a : Arg) (ha : (bridgeOf p).active = false) :
    FF.back p a = Host.Ts.M.bind (Host.Load.back (toLoad p) a) (backCont p a) := by
  funext γ k
  rw [Observer.back_eq kern.total, Observer.back_eq live.total]
  show Host.Mlx.Ffi.back p.1.1.base.mlx a γ _ = Host.Mlx.Ffi.back p.1.1.base.mlx a γ _
  refine congrArg (Host.Mlx.Ffi.back p.1.1.base.mlx a γ) (funext fun o => ?_)
  rcases o with _ | ⟨m, r, ws⟩
  · rfl
  · show (Host.Ts.M.pure (bif p.1.1.bridge.active then _ else some (m, p.1.1.bridge, r, ws)) :
      Host.Ts.M (Option (Host.Mlx.Ffi.St × Host.Mlx.FfiAne.St × Ret × _))) γ _ = _
    rw [show p.1.1.bridge.active = false from ha, Bool.cond_false]
    rfl

theorem load_back_keep (x : Host.Load.LSt) (a : Arg) :
    AllX (fun o => ∀ l r ws, o = some (l, r, ws) → Keep x.mlx l.mlx) (Host.Load.back x a) := by
  unfold Host.Load.back
  refine Host.Mlx.Ffi.FullKeep.AllX.bind (NativeLawful.traceBack_l _ _) (Host.Mlx.Ffi.FullKeep.back_k _ _)
    fun o ho => ?_
  rcases o with _ | ⟨m, r, ws⟩
  · exact Host.Mlx.Ffi.FullKeep.AllX.pure fun _ _ _ e => by cases e
  · exact Host.Mlx.Ffi.FullKeep.AllX.pure fun _ _ _ e => by cases e; exact ho _ rfl

/-! ## The observers -/

section
variable {P : LoadP} {NB : Nat} {M M' : Map} {n n' : Nat} {x y x' y' : NSt}

/-- **The liveness layer's continuation**: the tracer vector freed at its image. -/
theorem live_back {ex ey : Option (PTrie Unit)} (hl : LiveR M x y ex ey) (h : ObsPost P NB M M' n n' x y x' y')
    (hp : G.PendReg M x y) :
    LiveR M' x' y' (ex.bind fun e => liveBack e x) (ey.bind fun e => liveBack e y) := by
  intro fx' hx'
  cases hex : ex with
  | none => rw [hex] at hx'; cases hx'
  | some fx =>
    rw [hex, Option.bind_some] at hx'
    obtain ⟨fy, hey, hf⟩ := hl fx hex
    rw [hey, Option.bind_some]
    cases hpx : x.pending with
    | nil =>
      have hpy : y.pending = [] := by rw [h.pre.pending, hpx]; rfl
      unfold liveBack at hx' ⊢
      rw [hpx] at hx'
      rw [hpy]
      cases hx'
      exact ⟨fy, rfl, hf.keep h⟩
    | cons p rest =>
      have hpy : y.pending = M.pend p :: rest.map M.pend := by rw [h.pre.pending, hpx]; rfl
      unfold liveBack at hx'
      rw [hpx] at hx'
      dsimp only at hx'
      split at hx'
      · rename_i v hxo hfx
        cases hx'
        have hid : (M.pend p).id - 1 = M.handle (p.id - 1) := by
          have := (hp.reg p (by rw [hpx]; exact List.mem_cons_self ..)).2.2
          show M.handle p.id - 1 = _
          omega
        have hk : (x.objs.get (p.id - 1)).isSome = true := by rw [hxo]; rfl
        have hyo : y.objs.get (M.handle (p.id - 1)) = some (.vec (v.map M.node)) := by
          rw [h.pre.objs _ (.inr hk), hxo]; rfl
        have hfy : fy.get (M.handle (p.id - 1)) = none := by rw [hf.img _ hk, hfx]
        refine ⟨_, ?_, hf.free h hk⟩
        unfold liveBack
        rw [hpy]
        dsimp only
        rw [hid, hyo, hfy]
      · cases hx'

/-- The kernel-recording layer's continuation keeps the record. -/
theorem kern_back {ex ey : Option KRec} (hk : KernR M n x y ex ey) (h : ObsPost P NB M M' n n' x y x' y') :
    KernR M' n' x' y' (ex.bind fun k => some k) (ey.bind fun k => some k) := by
  intro kx hx
  cases hex : ex with
  | none => rw [hex] at hx; cases hx
  | some k =>
    rw [hex, Option.bind_some] at hx
    cases hx
    obtain ⟨ky, hey, hr⟩ := hk kx hex
    exact ⟨ky, by rw [hey]; rfl, hr.keep h⟩

end

/-- **The layers after related load-world results of a continuation.** -/
theorem full_back_post {P : LoadP} {NB : Nat} {M M' : Map} {ν : Nat → F64} {S S' : SSrv} {C C' : CSrv}
    {x y : FF.S} {a : Arg} {l l' : Host.Load.LSt} {r r' : Ret} {ws ws' : List (Nat × Nat × List Byte)}
    (hr : FullR P NB M S.tab.length x y) (hgr : Grow M ν S C M' S' C')
    (hcr : CallR (F := Host.Load.ffi) (G.LoadR P NB) M' S'.tab.length (some (l, r, ws)) (some (l', r', ws')))
    (kx : Keep (mlxOf x) l.mlx) (ky : Keep (mlxOf y) l'.mlx) :
    MSim (fun M'' S'' C'' r r' => Grow M ν S C M'' S'' C'' ∧ CallR (F := FF) (FullR P NB) M'' S''.tab.length r r')
      S' C' (Host.Ts.M.pure (liftB x a (some (⟨l, bridgeOf x⟩, r, ws))))
      (Host.Ts.M.pure (liftB y (M.arg a) (some (⟨l', bridgeOf y⟩, r', ws')))) := by
  obtain ⟨hlr, hr', hws⟩ := hcr
  have hob : ObsPost P NB M M' S.tab.length S'.tab.length (mlxOf x) (mlxOf y) l.mlx l'.mlx :=
    ⟨hr.load.mlx, hlr.mlx, hgr.ext, hgr.len, kx, ky⟩
  rw [liftB_some, liftB_some]
  exact MSim.pure ⟨hgr, ⟨hlr, ⟨hr.bridge.1, hr.bridge.2⟩, live_back hr.live hob hr.pend, kern_back hr.kern hob,
    hr.pend.step hr.load.mlx hlr.mlx hgr.ext kx⟩, hr', hws⟩

/-- **The layers after a load-world continuation simulation**, the bridge inactive. -/
theorem fullBackOf {P : LoadP} {NB : Nat} {M : Map} {ν : Nat → F64} {S : SSrv} {C : CSrv} {x y : FF.S} {a : Arg}
    (hr : FullR P NB M S.tab.length x y) (hact : (bridgeOf x).active = false)
    (hg : MSim (G.LPost P NB M ν S C) S C (Host.Load.back (toLoad x) a) (Host.Load.back (toLoad y) (M.arg a))) :
    MSim (fun M' S' C' r r' => Grow M ν S C M' S' C' ∧ CallR (F := FF) (FullR P NB) M' S'.tab.length r r') S C
      (FF.back x a) (FF.back y (M.arg a)) := by
  have hacty : (bridgeOf y).active = false := by rw [hr.bridge.1]; exact hact
  rw [full_back_load x a hact, full_back_load y _ hacty]
  have hg2 := MSim.both hg (loadFfiLawful.back _ _) (loadFfiLawful.back _ _)
  refine MSim.bind hg2 fun M' S' C' o o' hab => ?_
  obtain ⟨⟨hgr, hcr⟩, hra, hrb⟩ := hab
  rcases o with _ | ⟨l, r, ws⟩
  · rw [backCont_none]
    rcases o' with _ | ⟨l', r', ws'⟩
    · rw [backCont_none]; exact MSim.pure ⟨hgr, trivial⟩
    · rw [backCont_some]; exact MSim.pure ⟨hgr, trivial⟩
  · rcases o' with _ | ⟨l', r', ws'⟩
    · exact hcr.elim
    · rw [backCont_some, backCont_some]
      exact full_back_post hr hgr hcr ((load_back_keep _ a).1 S _ S' hra l r ws rfl)
        ((load_back_keep _ _).2 C _ C' hrb l' r' ws' rfl)

/-! ## At a raise -/

theorem FullR.raise {P : LoadP} {NB : Nat} {M : Map} {n : Nat} {x y : FF.S} (hr : FullR P NB M n x y)
    (hb : P.NL = P.N0) {k : Nat} (hk0 : P.N0 ≤ k) (hk : k ≤ (mlxOf x).nnext) : FullR (P.raise k) NB M n x y :=
  ⟨hr.load.raise hb hk0 hk, hr.bridge, hr.live, hr.kern, hr.pend⟩

/-- **The full world's accepted continuations**: a band-free `P`, the bridge inactive, and the
general check at the band raised to the node counter. -/
def okBackF (P : LoadP) (x : FF.S) (a : Arg) : Bool :=
  decide (P.NL = P.N0) && !(bridgeOf x).active && G.backOkG (P.raise (mlxOf x).nnext) (mlxOf x) a

/-- **The full world's continuation simulation at a raise.** -/
theorem fullBackSimD (P : LoadP) (NB : Nat) : FfiBackSim FF (FullRD P NB) (okBackF P) where
  back := by
    intro M ν S C x y a hsrv hr hok _
    obtain ⟨P', hP, hr⟩ := hr
    simp only [okBackF, Bool.and_eq_true, decide_eq_true_eq, Bool.not_eq_true'] at hok
    obtain ⟨⟨hb, hact⟩, hg⟩ := hok
    have hP' : P'.NL = P'.N0 ∧ P.N0 ≤ P'.N0 ∧ P'.raise (mlxOf x).nnext = P.raise (mlxOf x).nnext := by
      rcases hP with rfl | ⟨k, -, hk, rfl⟩
      · exact ⟨hb, Nat.le_refl _, rfl⟩
      · exact ⟨rfl, hk, rfl⟩
    obtain ⟨hb1, hb2, hb3⟩ := hP'
    have hn : P'.N0 ≤ (mlxOf x).nnext := hr.load.mlx.nband.2
    have hrr : FullR (P.raise (mlxOf x).nnext) NB M S.tab.length x y := by
      rw [← hb3]; exact hr.raise hb1 hn (Nat.le_refl _)
    refine MSim.mono (fullBackOf hrr hact (G.mlx_liftB hrr.load (G.sim_traceBack hsrv hrr.load.mlx hg))) ?_
    intro M' S' C' r r' h
    obtain ⟨hgr, hc⟩ := h
    refine ⟨hgr, ?_⟩
    rcases r with _ | ⟨x', r1, ws⟩ <;> rcases r' with _ | ⟨y', r2, ws'⟩
    · trivial
    · trivial
    · exact hc
    · exact ⟨⟨_, .inr ⟨(mlxOf x).nnext, hb, Nat.le_trans hb2 hn, rfl⟩, hc.1⟩, hc.2⟩

/-! ## The one-step theorems with continuations -/

/-- **The one-step theorem of the full world at a raise with continuations** (`Disp.okJSK`), under
frames `W` and a stack base. -/
theorem fullStepSimXBDK (P : LoadP) (NB : Nat) (VB : Nat → Nat) (J : Disp.JSP FF) (hJ : J.okCall = okCallFSD P)
    (hsm : J.smallB = smallFSB VB) (hlo : J.lo = P.lo) (hh : J.isHandle = fullIsHandle)
    (hg : J.isRegion = fullIsRegion) {W : Nat → Option WFrame} (stk : List Frame) (hW : Disp.Wp J W) :
    Disp.StepSimXVB FF (FullRD P NB) (Disp.okJSK J (okBackF P)) (Disp.Kp J) W stk (VBOkF VB) := by
  have hC : FfiCallSim FF (FullRD P NB) J.okCall smallFS := by rw [hJ]; exact fullCallSimSDD P NB
  exact Disp.stepSimXVBK (fullFfiSimD P NB) (fullBackSimD P NB) hC
    (fun _ _ _ _ _ hν hb => smallFSB_sound hν (by rw [hsm] at hb; exact hb))
    (fullRD_laws P NB) fullLawful (fullNativeFactsD P NB J hlo hh hg) hW

/-- The one-step theorem at a raise with continuations for any reached state, under frames and a
stack base. -/
theorem fullStepSimXLBDK (P : LoadP) (NB : Nat) (VB : Nat → Nat) (J : Disp.JSP FF) (hJ : J.okCall = okCallFSD P)
    (hsm : J.smallB = smallFSB VB) (hlo : J.lo = P.lo) (hh : J.isHandle = fullIsHandle)
    (hg : J.isRegion = fullIsRegion) {W : Nat → Option WFrame} (stk : List Frame) (hW : Disp.Wp J W) :
    Disp.StepSimXLB FF (FullRD P NB) (Disp.okJSK J (okBackF P)) (Disp.Kp J) W stk (VBOkF VB) := by
  have hC : FfiCallSim FF (FullRD P NB) J.okCall smallFS := by rw [hJ]; exact fullCallSimSDD P NB
  exact Disp.stepSimXLBK (fullFfiSimD P NB) (fullBackSimD P NB) hC
    (fun _ _ _ _ _ hν hb => smallFSB_sound hν (by rw [hsm] at hb; exact hb))
    (fullRD_laws P NB) fullLawful (fullNativeFactsD P NB J hlo hh hg) hW

/-- The one-step theorem at a raise with continuations for any reached state. -/
theorem fullStepSimXLDK (P : LoadP) (NB : Nat) (VB : Nat → Nat) (J : Disp.JSP FF) (hJ : J.okCall = okCallFSD P)
    (hsm : J.smallB = smallFSB VB) (hlo : J.lo = P.lo) (hh : J.isHandle = fullIsHandle)
    (hg : J.isRegion = fullIsRegion) :
    Disp.StepSimXL FF (FullRD P NB) (Disp.okJSK J (okBackF P)) (Disp.Kp J) (VBOkF VB) :=
  Disp.stepSimXLK (fullFfiSimD P NB) (fullBackSimD P NB) (by rw [hJ]; exact fullCallSimSDD P NB)
    (fun _ _ _ _ _ hν hb => smallFSB_sound hν (by rw [hsm] at hb; exact hb))
    (fullRD_laws P NB) fullLawful (fullNativeFactsD P NB J hlo hh hg)

end Host.Ts.Sim.Full
