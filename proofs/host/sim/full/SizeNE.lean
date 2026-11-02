import host.sim.full.LogRel
import host.sim.full.SizeJs

/-! # B-size with the bridge active

`mlx_array_size` returns the state it was called with (`loadCallSym_size_runS`, `loadCallSym_size_runC`) and is
not an evaluation (`evalCall_size`), so the bridge's update classifies no node and returns the bridge
(`after_size`). With the bridge active the full world's size call is therefore the completed load-world call with
both bridges unchanged (`fullSizeCallSimA`). The premise stays `SizePre`, decided by `sizePreB`:
`fullSizeCallSimX`, `fullSizeCallSimXD`, the frame `sizeCallSim_frame`, and the bridges `fullBridgeSizeJX` at
`Disp.FRJ (FullRXD P NB)` and `fullBridgeSizeJL` at `Disp.FRJ (FRL L (FullRXD P NB))`. -/

set_option maxRecDepth 100000
namespace Host.Ts.Sim.Full
open Host.Ts Host.Ts.Sim Host.Load.Layers
open Host.Mlx.Ffi.FullKeep (Keep)
open Host.Ts.Sim.BufSim (Lawful)
open Host.Mlx.Ffi.SymShape (callSym symShapeCall isSym)
open Host.Mlx.FfiAne (Effect)

/-! ## The size call is not an evaluation, and returns its state -/

theorem symOf_congr {a b : Name} (h : nameEq a b = true) : Host.Mlx.Ffi.symOf a = Host.Mlx.Ffi.symOf b := by
  have e : pack a = pack b := Nat.eq_of_beq_eq_true h
  unfold Host.Mlx.Ffi.symOf
  rw [e]

theorem evalCall_size {name : Name} (hsym : Host.Mlx.Ffi.symOf name = some .arraySize) (s : NSt) (args : List Arg) :
    Host.Mlx.FfiAne.evalCall s name args = .other := by
  have ne : ∀ c, Host.Mlx.Ffi.symOf c ≠ some .arraySize → nameEq name c = false := by
    intro c hc
    cases h : nameEq name c with
    | false => rfl
    | true => exact absurd (by rw [← symOf_congr h]; exact hsym) hc
  unfold Host.Mlx.FfiAne.evalCall
  rw [ne _ (by decide +kernel), ne _ (by decide +kernel), ne _ (by decide +kernel), ne _ (by decide +kernel),
    ne _ (by decide +kernel)]
  rfl

/-- **The bridge's update after a size call.** -/
theorem after_size {name : Name} (hsym : Host.Mlx.Ffi.symOf name = some .arraySize) (b : BSt) (s : NSt)
    (args : List Arg) : Host.Mlx.FfiAne.after b s s name args = some b := by
  unfold Host.Mlx.FfiAne.after
  rw [evalCall_size hsym, Nat.sub_self]
  rfl

/-- Every run returns the state `s`. -/
def SameOut (s : NSt) (m : Host.Ts.M (Option (NSt × Ret × List (Nat × Nat × List Byte)))) : Prop :=
  (∀ S q S', interpS m.run S = some (some q, S') → q.1 = s) ∧
    (∀ C q C', interpC m.run C = some (some q, C') → q.1 = s)

theorem sameOut_ok (s : NSt) (r : Ret) : SameOut s (Host.Mlx.Ffi.ok s r) := by
  constructor
  · intro S q S' h
    have h' : some (some (s, r, ([] : List (Nat × Nat × List Byte))), S) = some (some q, S') := h
    simp only [Option.some.injEq, Prod.mk.injEq] at h'
    rw [← h'.1]
  · intro C q C' h
    have h' : some (some (s, r, ([] : List (Nat × Nat × List Byte))), C) = some (some q, C') := h
    simp only [Option.some.injEq, Prod.mk.injEq] at h'
    rw [← h'.1]

theorem sameOut_stuck (s : NSt) : SameOut s Host.Mlx.Ffi.stuck := by
  constructor
  · intro S q S' h
    have h' : some ((none : Option (NSt × Ret × List (Nat × Nat × List Byte))), S) = some (some q, S') := h
    simp at h'
  · intro C q C' h
    have h' : some ((none : Option (NSt × Ret × List (Nat × Nat × List Byte))), C) = some (some q, C') := h
    simp at h'

theorem sameOut_bind {β : Type} {s : NSt} {D : Host.Ts.M β} {f : β → Host.Ts.M _} (hD : Lawful D)
    (hf : ∀ d, SameOut s (f d)) : SameOut s (Host.Ts.M.bind D f) := by
  constructor
  · intro S q S' h
    rw [run_bindS hD] at h
    cases hr : interpS D.run S with
    | none => rw [hr] at h; cases h
    | some p =>
      rw [hr] at h
      exact (hf p.1).1 _ _ _ h
  · intro C q C' h
    rw [run_bindC hD] at h
    cases hr : interpC D.run C with
    | none => rw [hr] at h; cases h
    | some p =>
      rw [hr] at h
      exact (hf p.1).2 _ _ _ h

theorem symShape_size_out (s : NSt) {name : Name} (hsym : Host.Mlx.Ffi.symOf name = some .arraySize) (a : Arg) :
    SameOut s (symShapeCall s name [a]) := by
  unfold symShapeCall
  rw [hsym]
  dsimp only
  cases hnd : (Host.Mlx.Ffi.argNat a).bind s.node? with
  | none => exact sameOut_stuck s
  | some nd =>
    dsimp only
    cases hany : nd.shape.any isSym with
    | false => exact sameOut_stuck s
    | true =>
      refine sameOut_bind (D := Host.Mlx.Ffi.dProd nd.shape) (NativeLawful.dProd_l _) fun d => ?_
      cases d <;> exact sameOut_ok s _

theorem callSym_size_out (s : NSt) {name : Name} (hsym : Host.Mlx.Ffi.symOf name = some .arraySize) (a : Arg) :
    SameOut s (callSym s name [a]) := by
  cases hnd : (Host.Mlx.Ffi.argNat a).bind s.node? with
  | none =>
    have hc : Host.Mlx.Ffi.call s name [a] = Host.Mlx.Ffi.stuck := by
      unfold Host.Mlx.Ffi.call
      rw [hsym]
      simp only [hnd]
    rw [G.callSym_stuck hc]
    exact symShape_size_out s hsym a
  | some nd =>
    cases hn : Host.Mlx.Ffi.natsOfDims nd.shape with
    | some ns =>
      rw [G.callSym_some (fun γ k => by rw [G.call_size_some s hsym hnd hn]; rfl), G.call_size_some s hsym hnd hn]
      exact sameOut_ok s _
    | none =>
      rw [G.callSym_stuck (G.call_size_none s hsym hnd hn)]
      exact symShape_size_out s hsym a

theorem loadCallSym_size_runS {l l' : Host.Load.LSt} {name : Name} (hsym : Host.Mlx.Ffi.symOf name = some .arraySize)
    {a : Arg} {S S1 : SSrv} {r : Ret} {ws : List (Nat × Nat × List Byte)}
    (h : interpS (loadCallSym l name [a]).run S = some (some (l', r, ws), S1)) : l' = l := by
  unfold loadCallSym at h
  rw [run_bindS (callSym_l l.mlx name [a])] at h
  cases hr : interpS (callSym l.mlx name [a]).run S with
  | none => rw [hr] at h; cases h
  | some p =>
    obtain ⟨o, S0⟩ := p
    rw [hr] at h
    rcases o with _ | ⟨m, r0, ws0⟩
    · have h' : some ((none : Res Host.Load.LSt), S0) = some (some (l', r, ws), S1) := h
      simp at h'
    · have em : m = l.mlx := (callSym_size_out l.mlx hsym a).1 S _ S0 hr
      subst em
      have h' : some (some (({ l with mlx := l.mlx } : Host.Load.LSt), r0, ws0), S0) = some (some (l', r, ws), S1) := h
      simp only [Option.some.injEq, Prod.mk.injEq] at h'
      exact h'.1.1.symm

theorem loadCallSym_size_runC {l l' : Host.Load.LSt} {name : Name} (hsym : Host.Mlx.Ffi.symOf name = some .arraySize)
    {a : Arg} {C C1 : CSrv} {r : Ret} {ws : List (Nat × Nat × List Byte)}
    (h : interpC (loadCallSym l name [a]).run C = some (some (l', r, ws), C1)) : l' = l := by
  unfold loadCallSym at h
  rw [run_bindC (callSym_l l.mlx name [a])] at h
  cases hr : interpC (callSym l.mlx name [a]).run C with
  | none => rw [hr] at h; cases h
  | some p =>
    obtain ⟨o, C0⟩ := p
    rw [hr] at h
    rcases o with _ | ⟨m, r0, ws0⟩
    · have h' : some ((none : Res Host.Load.LSt), C0) = some (some (l', r, ws), C1) := h
      simp at h'
    · have em : m = l.mlx := (callSym_size_out l.mlx hsym a).2 C _ C0 hr
      subst em
      have h' : some (some (({ l with mlx := l.mlx } : Host.Load.LSt), r0, ws0), C0) = some (some (l', r, ws), C1) := h
      simp only [Option.some.injEq, Prod.mk.injEq] at h'
      exact h'.1.1.symm

/-! ## The simulation -/

/-- The layers after a size call, at any bridge relation. -/
theorem full_size_postX {BR BR' : Map → FF.S → FF.S → Prop} {P : LoadP} {NB : Nat} {M M' : Map} {ν : Nat → F64}
    {S S' : SSrv} {C C' : CSrv} {x y : FF.S} {name : Name} {args : List Arg} {l l' : Host.Load.LSt} {r r' : Ret}
    {A : Nat → Prop} {b1 b1' : BSt} (hsym : Host.Mlx.Ffi.symOf name = some .arraySize)
    (hr : FullRB BR P NB M S.tab.length x y) (hgr : Grow M ν S C M' S' C')
    (hcr : Disp.SizeR (F := Host.Load.ffi) (G.LoadR P NB) M' S'.tab.length A (some (l, r, [])) (some (l', r', [])))
    (kx : Keep (mlxOf x) l.mlx) (ky : Keep (mlxOf y) l'.mlx)
    (hsupp : ∀ a ∈ args, Supp.arg (fun _ => True) S.tab.length a)
    (hbr : ∀ e e' k k', BR' M' (((⟨l, b1⟩ : Host.Load.Ane.ASt), e), k) (((⟨l', b1'⟩ : Host.Load.Ane.ASt), e'), k')) :
    MSim (fun M'' S'' C'' r r' => Grow M ν S C M'' S'' C'' ∧
      Disp.SizeR (F := FF) (FullRB BR' P NB) M'' S''.tab.length A r r') S' C'
      (Host.Ts.M.pure (liftF x name args (some (⟨l, b1⟩, r, []))))
      (Host.Ts.M.pure (liftF y name (args.map M.arg) (some (⟨l', b1'⟩, r', [])))) := by
  obtain ⟨hlr, -, -, v, hv, hv', hsv⟩ := hcr
  have hob : ObsPost P NB M M' S.tab.length S'.tab.length (mlxOf x) (mlxOf y) l.mlx l'.mlx :=
    ⟨hr.load.mlx, hlr.mlx, hgr.ext, hgr.len, kx, ky⟩
  have hobs : obsOk (mlxOf x) name args = true := by
    unfold obsOk; rw [hsym]; rcases args with _ | ⟨a, _ | ⟨b, rest⟩⟩ <;> rfl
  have hka : KernAcc P (mlxOf x) name args := by
    intro s hs; rw [hsym] at hs; cases hs
    exact ⟨(fun h => nomatch h), (fun h => by rcases h with h | h | h <;> cases h)⟩
  have hk := kern_step (r := r) hr.kern hob hsupp hka (fun hs => by rw [hsym] at hs; cases hs)
    (fun hs => by rw [hsym] at hs; cases hs)
  have ko : ∀ (e : KRec) (m : Host.Mlx.Ffi.St) (as : List Arg) (q : Ret), kernCall e m name as q = some e :=
    fun e m as q => kernCall_other e m name as q hsym (by decide) (by decide) (by decide) (by decide) (by decide)
  simp only [ko] at hk
  rw [liftF_some, liftF_some]
  refine MSim.pure ⟨hgr, ⟨hlr, hbr _ _ _ _, ?_, ?_, hr.pend.step hr.load.mlx hlr.mlx hgr.ext kx⟩, rfl, rfl, v, hv, hv', hsv⟩
  · exact live_step hr.live hob hobs (fun hs => by rw [hsym] at hs; cases hs)
  · simp only [ko]; exact hk

/-- **B-size's native side with the bridge active.** -/
theorem fullSizeCallSimA (P : LoadP) (NB : Nat) {name : Name} (hsym : Host.Mlx.Ffi.symOf name = some .arraySize)
    (hm : Host.Load.isMlx name = true) (hp : nameEq name Host.Mlx.FfiAne.payloadName = false) (A : Nat → Prop)
    {M : Map} {ν : Nat → F64} {S : SSrv} {C : CSrv} {x y : FF.S} {as : List Arg} (hsrv : Srv M ν S C)
    (hr : FullRX P NB M S.tab.length x y) (hsupp : ∀ a ∈ as, Supp.arg A S.tab.length a) (hpre : SizePre ν S x as)
    (hact : (bridgeOf x).active = true) :
    MSim (fun M' S' C' r r' => Grow M ν S C M' S' C' ∧
      Disp.SizeR (F := FF) (FullRX P NB) M' S'.tab.length A r r') S C
      (FF.call x name as) (FF.call y name (as.map M.arg)) := by
  obtain ⟨a, nd, rfl, ha, hnd, vo, po, hsm⟩ := hpre
  have hbA := hr.bridge.active hact
  have hacty : (bridgeOf y).active = true := by rw [hbA.rel.active]; exact hact
  have hg := mlx_liftSize A hr.load (G.sim_arraySizeS hsrv hr.load.mlx hsym ha hnd vo po hsm)
  have hxrun := fullCall_runS x name [a] hm hp hact (S := S) fun l r ws S1 e => by
    have el := loadCallSym_size_runS hsym e
    subst el
    have : Host.Mlx.FfiAne.after x.1.1.bridge x.1.1.base.mlx x.1.1.base.mlx name [a] = some x.1.1.bridge :=
      after_size hsym _ _ _
    show (Host.Mlx.FfiAne.after x.1.1.bridge x.1.1.base.mlx x.1.1.base.mlx name [a]).isSome = true
    rw [this]; rfl
  have hyrun := fullCall_runC y name [M.arg a] hm hp hacty (C := C) fun l r ws C1 e => by
    have el := loadCallSym_size_runC hsym e
    subst el
    have : Host.Mlx.FfiAne.after y.1.1.bridge y.1.1.base.mlx y.1.1.base.mlx name [M.arg a] = some y.1.1.bridge :=
      after_size hsym _ _ _
    show (Host.Mlx.FfiAne.after y.1.1.bridge y.1.1.base.mlx y.1.1.base.mlx name [M.arg a]).isSome = true
    rw [this]; rfl
  refine MSim.of_run (fullLawful.call _ _ _) (fullLawful.call _ _ _) ?_
  intro o S' hu
  rw [hxrun] at hu
  show ∃ M' b C', _
  rw [run_bindS (loadCallSym_l _ _ _)] at hu
  cases hrx : interpS (loadCallSym (toLoad x) name [a]).run S with
  | none => rw [hrx] at hu; cases hu
  | some p0 =>
    obtain ⟨a0, S0⟩ := p0
    rw [hrx] at hu
    obtain ⟨M', b, C', hcy, hgr, hcr⟩ := MSim.run hg _ S0 hrx
    have hy0 : interpC (FF.call y name ([a].map M.arg)).run C = some (fullResA y name [M.arg a] b, C') := by
      show interpC (FF.call y name [M.arg a]).run C = _
      have hcy' : interpC (loadCallSym (toLoad y) name [M.arg a]).run C = some (b, C') := hcy
      rw [hyrun, run_bindC (loadCallSym_l _ _ _), hcy']
      rfl
    rcases a0 with _ | ⟨l, r, ws⟩
    · have hu' : some (fullResA x name [a] none, S0) = some (o, S') := hu
      simp only [Option.some.injEq, Prod.mk.injEq] at hu'
      obtain ⟨rfl, rfl⟩ := hu'
      refine ⟨M', _, C', hy0, hgr, ?_⟩
      have hn : fullResA x name [a] none = none := by simp only [fullResA]
      rw [hn]
      trivial
    · rcases b with _ | ⟨l', r', ws'⟩
      · exact hcr.elim
      · obtain ⟨hl1, rfl, rfl, hv4⟩ := hcr
        have kx := keepS_of_run hrx
        have ky := keepS_of_runC hcy
        have ex := loadCallSym_size_runS hsym hrx
        have ey := loadCallSym_size_runC hsym hcy
        subst ex ey
        have hsupp' : ∀ b ∈ [a], Supp.arg (fun _ => True) S.tab.length b :=
          fun b hb => Supp.arg_mono (fun _ _ => trivial) (Nat.le_refl _) (hsupp b hb)
        have hpost := full_size_postX (b1 := x.1.1.bridge) (b1' := y.1.1.bridge) (BR' := BridgeX) hsym hr hgr
          ⟨hl1, rfl, rfl, hv4⟩ kx ky hsupp'
          (fun _ _ _ _ => .inr ⟨hact, ⟨hbA.rel.names hgr.ext.node, hbA.dense, hbA.qord.names hgr.ext.node⟩⟩)
        have hres : fullResA x name [a] (some (toLoad x, r, [])) =
            liftF x name [a] (some (⟨toLoad x, x.1.1.bridge⟩, r, [])) := by
          have : Host.Mlx.FfiAne.after x.1.1.bridge x.1.1.base.mlx (toLoad x).mlx name [a] = some x.1.1.bridge :=
            after_size hsym _ _ _
          simp only [fullResA, this]
        have hres' : fullResA y name [M.arg a] (some (toLoad y, r', [])) =
            liftF y name [M.arg a] (some (⟨toLoad y, y.1.1.bridge⟩, r', [])) := by
          have : Host.Mlx.FfiAne.after y.1.1.bridge y.1.1.base.mlx (toLoad y).mlx name [M.arg a] = some y.1.1.bridge :=
            after_size hsym _ _ _
          simp only [fullResA, this]
        obtain ⟨M2, b2, C2, hc2, hp2⟩ := MSim.run hpost _ S0 rfl
        have hu' : some (fullResA x name [a] (some (toLoad x, r, [])), S0) = some (o, S') := hu
        rw [hres] at hu'
        simp only [Option.some.injEq, Prod.mk.injEq] at hu'
        obtain ⟨rfl, rfl⟩ := hu'
        refine ⟨M2, b2, C2, ?_, hp2⟩
        rw [hy0]
        have hc2' : some (liftF y name [M.arg a] (some (⟨toLoad y, y.1.1.bridge⟩, r', [])), C') = some (b2, C2) := hc2
        rw [← hres'] at hc2'
        exact hc2'

/-- **B-size's native side with the Neural Engine bridge**: active or not, the same premise. -/
theorem fullSizeCallSimX (P : LoadP) (NB : Nat) {name : Name} (hsym : Host.Mlx.Ffi.symOf name = some .arraySize)
    (hm : Host.Load.isMlx name = true) (hp : nameEq name Host.Mlx.FfiAne.payloadName = false) (A : Nat → Prop) :
    Disp.SizeCallSim FF (FullRX P NB) name A SizePre := by
  intro M ν S C x y as hsrv hr hsupp hpre
  cases hact : (bridgeOf x).active with
  | true => exact fullSizeCallSimA P NB hsym hm hp A hsrv hr hsupp hpre hact
  | false =>
    refine MSim.mono (fullSizeCallSim P NB hsym hm hp A M ν S C x y as hsrv (hr.toR hact) hsupp hpre) ?_
    intro M' S' C' r r' h
    exact ⟨h.1, sizeR_mono (fun _ _ q => FullR.toX q) h.2⟩

/-- **B-size's native side with the Neural Engine bridge at a raise.** -/
theorem fullSizeCallSimXD (P : LoadP) (NB : Nat) {name : Name} (hsym : Host.Mlx.Ffi.symOf name = some .arraySize)
    (hm : Host.Load.isMlx name = true) (hp : nameEq name Host.Mlx.FfiAne.payloadName = false) (A : Nat → Prop) :
    Disp.SizeCallSim FF (FullRXD P NB) name A SizePre := by
  intro M ν S C x y as hsrv hr hsupp hpre
  obtain ⟨P', hP, hr⟩ := hr
  refine MSim.mono (fullSizeCallSimX P' NB hsym hm hp A M ν S C x y as hsrv hr hsupp hpre) ?_
  intro M' S' C' r r' h
  exact ⟨h.1, sizeR_mono (fun _ _ hx => ⟨P', hP, hx⟩) h.2⟩

/-! ## The frame -/

theorem sizeR_frame {FR : Map → Nat → FF.S → FF.S → Prop} {L : List Effect} {ps : List Host.Mlx.FfiAne.Program}
    {M : Map} {n : Nat} {A : Nat → Prop} {r r' : Res FF.S} (h : Disp.SizeR (F := FF) FR M n A r r')
    (hs : ∀ y' q ws, r' = some (y', q, ws) → SameP ps (bridgeOf y')) :
    Disp.SizeR (F := FF) (FRL L FR) M n A r (mapF L ps r') := by
  rcases r with _ | ⟨x', r1, ws⟩ <;> rcases r' with _ | ⟨y', r2, ws'⟩
  · trivial
  · trivial
  · exact h
  · exact ⟨⟨y', ps, rfl, hs _ _ _ rfl, h.1⟩, h.2⟩

/-- **A size call's simulation with a log base.** -/
theorem sizeCallSim_frame {FR : Map → Nat → FF.S → FF.S → Prop} {name : Name} {A : Nat → Prop}
    {Pre : (Nat → F64) → SSrv → FF.S → List Arg → Prop} (h : Disp.SizeCallSim FF FR name A Pre)
    (hm : Host.Load.isMlx name = true) (L : List Effect) : Disp.SizeCallSim FF (FRL L FR) name A Pre := by
  rintro M ν S C x y as hsrv ⟨y0, ps, rfl, hps, hr⟩ hsupp hpre
  have hs := h M ν S C x y0 as hsrv hr hsupp hpre
  rw [full_call_fF hps hm]
  refine MSim.map_right (MSim.both hs (fullLawful.call _ _ _) (fullLawful.call _ _ _)) ?_
  rintro M' S' C' a b ⟨⟨hg, hc⟩, -, hb⟩
  refine ⟨hg, sizeR_frame hc ?_⟩
  rintro y' q ws rfl
  show ps.map stripP = (bridgeOf y').programs.map stripP
  rw [full_call_programsC hm hb]
  exact hps

/-! ## The bridges -/

section
variable {P : LoadP} {NB : Nat} {W : Nat → Option WFrame} {stk : List Frame} {M : Map} {ν : Nat → F64} {K : Ctx}
  {s t : St FF.S} {S : SSrv} {C : CSrv} {fsym ta nf : Nat} {name rt : Name} {tys args : List Val}

/-- **B-size under the JS-pointer law with the bridge active or not.** -/
theorem fullBridgeSizeJX (h : RelB FF (Disp.FRJ (FullRXD P NB)) W stk M ν K s S t C)
    (hp : Disp.sizeParts s = some (fsym, ta, nf, name, rt, tys, args)) (hargs : Disp.sizeArgsOk s = true)
    (hsym : Host.Mlx.Ffi.symOf name = some .arraySize) (hm : Host.Load.isMlx name = true)
    (hpay : nameEq name Host.Mlx.FfiAne.payloadName = false) (hfr : K.fr ta = none)
    (hpre : ∀ asR S1, interpS (decodeArgs FF s tys args).run S = some (some asR, S1) → SizePre ν S1 s.ffi asR) :
    MSim (fun M' S' C' s1 t1 => Grow M ν S C M' S' C' ∧
      RelB FF (Disp.FRJ (FullRXD P NB)) W stk M' ν ⟨K.fr, s1.trace, t1.trace, K.D, K.lo, K.hi⟩ s1 S' t1 C' ∧
      ∃ asR ret asR' ret' v, s1.trace = ⟨name, asR, ret⟩ :: s.trace ∧ t1.trace = ⟨name, asR', ret'⟩ :: t.trace ∧
        Disp.numRet ret = some v ∧ Disp.numRet ret' = some (M'.val v)) S C
      (Disp.sizeS FF s) (Disp.sizeS FF t) := by
  refine MSim.mono (Disp.bridge_size_at h.ofJ (fullRXD_laws P NB) (fullFfiSimXD P NB) hp hargs hfr hpre
    (fullSizeCallSimXD P NB hsym hm hpay (Present s))) ?_
  intro M' S' C' s1 t1 hx
  exact ⟨hx.1, hx.2.1.toJ (h.ffi.2.ext hx.1.ext), hx.2.2⟩

/-- **B-size under the JS-pointer law with a log base.** -/
theorem fullBridgeSizeJL (L : List Effect) (h : RelB FF (Disp.FRJ (FRL L (FullRXD P NB))) W stk M ν K s S t C)
    (hp : Disp.sizeParts s = some (fsym, ta, nf, name, rt, tys, args)) (hargs : Disp.sizeArgsOk s = true)
    (hsym : Host.Mlx.Ffi.symOf name = some .arraySize) (hm : Host.Load.isMlx name = true)
    (hpay : nameEq name Host.Mlx.FfiAne.payloadName = false) (hfr : K.fr ta = none)
    (hpre : ∀ asR S1, interpS (decodeArgs FF s tys args).run S = some (some asR, S1) → SizePre ν S1 s.ffi asR) :
    MSim (fun M' S' C' s1 t1 => Grow M ν S C M' S' C' ∧
      RelB FF (Disp.FRJ (FRL L (FullRXD P NB))) W stk M' ν ⟨K.fr, s1.trace, t1.trace, K.D, K.lo, K.hi⟩ s1 S' t1 C' ∧
      ∃ asR ret asR' ret' v, s1.trace = ⟨name, asR, ret⟩ :: s.trace ∧ t1.trace = ⟨name, asR', ret'⟩ :: t.trace ∧
        Disp.numRet ret = some v ∧ Disp.numRet ret' = some (M'.val v)) S C
      (Disp.sizeS FF s) (Disp.sizeS FF t) := by
  refine MSim.mono (Disp.bridge_size_at h.ofJ (FRLaws.frame (fullRXD_laws P NB) L)
    (FfiSim.frameFalse (fullFfiSimXD P NB) L) hp hargs hfr hpre
    (sizeCallSim_frame (fullSizeCallSimXD P NB hsym hm hpay (Present s)) hm L)) ?_
  intro M' S' C' s1 t1 hx
  exact ⟨hx.1, hx.2.1.toJ (h.ffi.2.ext hx.1.ext), hx.2.2⟩

end

end Host.Ts.Sim.Full
