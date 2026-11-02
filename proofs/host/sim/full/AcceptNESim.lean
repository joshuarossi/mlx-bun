import host.sim.full.AcceptNE

/-! # The simulation of a Neural Engine row's acceptance

With the bridge active the full world's call is the load world's call, then the bridge's update, the
symbolic-shape layer where that is stuck, then the bridge's update (`symCall`, `fullContA`). When the
template's completed call reaches a result the bridge classifies (`symAfterB`), every run of the full
world's call on either side is the completed call followed by the bridge's update (`fullCall_runS`,
`fullCall_runC`), so the completed calls' simulation (`G.mlx_simSS`) gives the full world's
(`fullCallSymSimA`). With the bridge inactive a bridge call acts on equal bridges (`fullOpSimI`).
`fullCallSimND` is `okCallFND`'s simulation and `fullStepSimXLBN` the checked runs' one-step theorem at
`okJSF`. -/

set_option maxRecDepth 100000
namespace Host.Ts.Sim.Full
open Host.Ts Host.Ts.Sim Host.Load.Layers
open Host.Mlx.Ffi.FullKeep (Keep)
open Host.Ts.Sim.BufSim (Lawful)
open Host.Mlx.Ffi.SymShape (callSym symShapeCall)

/-- A simulation of a lawful pair's runs is a simulation of the computations. -/
theorem MSim.of_run {α β : Type} {P : Map → SSrv → CSrv → α → β → Prop} {S : SSrv} {C : CSrv}
    {m : Host.Ts.M α} {m' : Host.Ts.M β} (hs : Lawful m) (ht : Lawful m') (h : FSim P S C m.run m'.run) :
    MSim P S C m m' := by
  intro γ δ Q k k' hk r S2 hu
  rw [hs.1] at hu
  cases hrun : interpS m.run S with
  | none => rw [hrun] at hu; cases hu
  | some p =>
    obtain ⟨a, S1⟩ := p
    rw [hrun] at hu
    obtain ⟨M1, b, C1, hc, hp⟩ := h a S1 hrun
    obtain ⟨M2, r', C2, hc', hq⟩ := hk M1 S1 C1 a b hp r S2 hu
    exact ⟨M2, r', C2, by rw [ht.2, hc]; exact hc', hq⟩

theorem run_congrS {α β : Type} {m : Host.Ts.M α} {f g : α → Host.Ts.M β} {S : SSrv} (hm : Lawful m)
    (h : ∀ a S', interpS m.run S = some (a, S') → f a = g a) :
    interpS (Host.Ts.M.bind m f).run S = interpS (Host.Ts.M.bind m g).run S := by
  show interpS (m β fun a => (f a).run) S = interpS (m β fun a => (g a).run) S
  rw [hm.1, hm.1]
  cases hrun : interpS m.run S with
  | none => rfl
  | some p =>
    obtain ⟨a, S1⟩ := p
    simp only [Option.bind_some]
    rw [h a S1 hrun]

theorem run_congrC {α β : Type} {m : Host.Ts.M α} {f g : α → Host.Ts.M β} {C : CSrv} (hm : Lawful m)
    (h : ∀ a C', interpC m.run C = some (a, C') → f a = g a) :
    interpC (Host.Ts.M.bind m f).run C = interpC (Host.Ts.M.bind m g).run C := by
  show interpC (m β fun a => (f a).run) C = interpC (m β fun a => (g a).run) C
  rw [hm.2, hm.2]
  cases hrun : interpC m.run C with
  | none => rfl
  | some p =>
    obtain ⟨a, C1⟩ := p
    simp only [Option.bind_some]
    rw [h a C1 hrun]

theorem run_bindS {α β : Type} {m : Host.Ts.M α} {f : α → Host.Ts.M β} {S : SSrv} (hm : Lawful m) :
    interpS (Host.Ts.M.bind m f).run S = (interpS m.run S).bind fun p => interpS (f p.1).run p.2 := by
  show interpS (m β fun a => (f a).run) S = _
  rw [hm.1]

theorem run_bindC {α β : Type} {m : Host.Ts.M α} {f : α → Host.Ts.M β} {C : CSrv} (hm : Lawful m) :
    interpC (Host.Ts.M.bind m f).run C = (interpC m.run C).bind fun p => interpC (f p.1).run p.2 := by
  show interpC (m β fun a => (f a).run) C = _
  rw [hm.2]

/-- The symbolic-shape layer where the load world's call is stuck, at the load world. -/
def symL (l : Host.Load.LSt) (name : Name) (args : List Arg) : Res Host.Load.LSt → Host.Ts.M (Res Host.Load.LSt)
  | some q => .pure (some q)
  | none => .bind (symShapeCall l.mlx name args) fun
    | some (m, r, ws) => .pure (some ({ l with mlx := m }, r, ws))
    | none => .pure none

theorem symL_l (l : Host.Load.LSt) (name : Name) (args : List Arg) (o : Res Host.Load.LSt) :
    Lawful (symL l name args o) := by
  rcases o with _ | q
  · show Lawful (Host.Ts.M.bind (symShapeCall l.mlx name args) _)
    refine BufSim.Lawful.bind (Host.Load.LayerLift.symShapeCall_l _ _ _) fun o => ?_
    rcases o with _ | ⟨m, r, ws⟩ <;> exact BufSim.Lawful.pure _
  · exact BufSim.Lawful.pure _

/-- **The load world's call completed by the layer** is the load world's call, then the layer. -/
theorem loadCallSym_eq (l : Host.Load.LSt) (name : Name) (args : List Arg) (hm : Host.Load.isMlx name = true) :
    loadCallSym l name args = Host.Ts.M.bind (Host.Load.call l name args) (symL l name args) := by
  rw [Host.Load.call_mlx _ _ _ hm]
  unfold loadCallSym callSym
  simp only [G.mbind_assoc]
  congr 1
  funext o
  rcases o with _ | ⟨m, r, ws⟩
  · simp only [symL, G.mbind_pure]
    congr 1
  · simp only [symL, G.mbind_pure]

/-- The continuation of the load world's completed call with the bridge active. -/
def contA (p : FF.S) (name : Name) (args : List Arg) (o : Res Host.Load.LSt) : Host.Ts.M (Res FF.S) :=
  .pure (fullResA p name args o)

theorem fullContA_none (p : FF.S) (name : Name) (args : List Arg) (hm : Host.Load.isMlx name = true)
    (hp : nameEq name Host.Mlx.FfiAne.payloadName = false) (ha : (bridgeOf p).active = true) :
    fullContA p name args none =
      Host.Ts.M.bind (symL (toLoad p) name args none) (contA p name args) := by
  have hb : p.1.1.bridge.active = true := ha
  unfold fullContA contA
  simp only [aneK, symFB, symL, G.mbind_pure, G.mbind_assoc, hm, hp, Bool.not_false, Bool.and_self, Bool.cond_true, toLoad]
  congr 1
  funext o
  rcases o with _ | ⟨m, r, ws⟩
  · simp only [G.mbind_pure, fullResA, liftF_none]
  · simp only [G.mbind_pure, hb, Bool.cond_true]
    cases he : Host.Mlx.FfiAne.after p.1.1.bridge p.1.1.base.mlx m name args with
    | none => simp only [Option.map_none, fullResA, he, liftF_none]
    | some b => simp only [Option.map_some, fullResA, he]

/-- The continuations agree where the load world's call is stuck or its result is classified. -/
theorem fullContA_eq (p : FF.S) (name : Name) (args : List Arg) (hm : Host.Load.isMlx name = true)
    (hp : nameEq name Host.Mlx.FfiAne.payloadName = false) (ha : (bridgeOf p).active = true) {o : Res Host.Load.LSt}
    (ho : ∀ l r ws, o = some (l, r, ws) →
      (Host.Mlx.FfiAne.after p.1.1.bridge p.1.1.base.mlx l.mlx name args).isSome = true) :
    fullContA p name args o = Host.Ts.M.bind (symL (toLoad p) name args o) (contA p name args) := by
  rcases o with _ | ⟨l, r, ws⟩
  · exact fullContA_none p name args hm hp ha
  · obtain ⟨b, hb⟩ := Option.isSome_iff_exists.mp (ho l r ws rfl)
    rw [fullContA_some p name args hb]
    funext γ k
    show _ = k (fullResA p name args _)
    simp only [fullResA, hb]
    rfl

theorem loadCallSym_runS {l : Host.Load.LSt} {name : Name} {args : List Arg} {S S1 : SSrv} {q}
    (hm : Host.Load.isMlx name = true) (h : interpS (Host.Load.call l name args).run S = some (some q, S1)) :
    interpS (loadCallSym l name args).run S = some (some q, S1) := by
  rw [loadCallSym_eq l name args hm]
  have hl : Lawful (Host.Load.call l name args) := loadFfiLawful.call l name args
  rw [run_bindS hl, h]
  rfl

theorem loadCallSym_runC {l : Host.Load.LSt} {name : Name} {args : List Arg} {C C1 : CSrv} {q}
    (hm : Host.Load.isMlx name = true) (h : interpC (Host.Load.call l name args).run C = some (some q, C1)) :
    interpC (loadCallSym l name args).run C = some (some q, C1) := by
  rw [loadCallSym_eq l name args hm]
  have hl : Lawful (Host.Load.call l name args) := loadFfiLawful.call l name args
  rw [run_bindC hl, h]
  rfl

/-- **The full world's run with the bridge active**, when the completed call's results are classified. -/
theorem fullCall_runS (p : FF.S) (name : Name) (args : List Arg) (hm : Host.Load.isMlx name = true)
    (hp : nameEq name Host.Mlx.FfiAne.payloadName = false) (ha : (bridgeOf p).active = true) {S : SSrv}
    (h : ∀ l r ws S1, interpS (loadCallSym (toLoad p) name args).run S = some (some (l, r, ws), S1) →
      (Host.Mlx.FfiAne.after p.1.1.bridge p.1.1.base.mlx l.mlx name args).isSome = true) :
    interpS (FF.call p name args).run S =
      interpS (Host.Ts.M.bind (loadCallSym (toLoad p) name args) (contA p name args)).run S := by
  rw [full_call_active p name args hm hp ha, loadCallSym_eq _ _ _ hm, G.mbind_assoc]
  have hl : Lawful (Host.Load.call (toLoad p) name args) := loadFfiLawful.call _ _ _
  refine run_congrS hl fun o S1 hrun => fullContA_eq p name args hm hp ha fun l r ws e => ?_
  subst e
  exact h l r ws S1 (loadCallSym_runS hm hrun)

theorem fullCall_runC (p : FF.S) (name : Name) (args : List Arg) (hm : Host.Load.isMlx name = true)
    (hp : nameEq name Host.Mlx.FfiAne.payloadName = false) (ha : (bridgeOf p).active = true) {C : CSrv}
    (h : ∀ l r ws C1, interpC (loadCallSym (toLoad p) name args).run C = some (some (l, r, ws), C1) →
      (Host.Mlx.FfiAne.after p.1.1.bridge p.1.1.base.mlx l.mlx name args).isSome = true) :
    interpC (FF.call p name args).run C =
      interpC (Host.Ts.M.bind (loadCallSym (toLoad p) name args) (contA p name args)).run C := by
  rw [full_call_active p name args hm hp ha, loadCallSym_eq _ _ _ hm, G.mbind_assoc]
  have hl : Lawful (Host.Load.call (toLoad p) name args) := loadFfiLawful.call _ _ _
  refine run_congrC hl fun o C1 hrun => fullContA_eq p name args hm hp ha fun l r ws e => ?_
  subst e
  exact h l r ws C1 (loadCallSym_runC hm hrun)

/-- **The calls the symbolic-shape layer completes, simulated with the bridge active.** -/
theorem fullCallSymSimA {P : LoadP} {NB : Nat} {M : Map} {ν : Nat → F64} {S : SSrv} {C : CSrv} {x y : FF.S}
    {name : Name} {args : List Arg} (hsrv : Srv M ν S C) (hr : FullRX P NB M S.tab.length x y) (hF : ∀ i, Full P i)
    (hm : Host.Load.isMlx name = true) (hp : nameEq name Host.Mlx.FfiAne.payloadName = false)
    (hact : (bridgeOf x).active = true) (hok : G.symShapeOk P (mlxOf x) name args = true)
    (hobs : obsOk (mlxOf x) name args = true) (haft : afterOk (bridgeOf x) (mlxOf x) name args = true)
    (hsupp : ∀ a ∈ args, Supp.arg (fun _ => True) S.tab.length a) (hsm : G.symShapeSmall ν S (mlxOf x) name args)
    (hrun : symAfterB S x name args = true) :
    MSim (fun M' S' C' r r' => Grow M ν S C M' S' C' ∧ CallR (F := FF) (FullRX P NB) M' S'.tab.length r r') S C
      (FF.call x name args) (FF.call y name (args.map M.arg)) := by
  have hbA := hr.bridge.active hact
  have hacty : (bridgeOf y).active = true := by rw [hbA.rel.active]; exact hact
  have hg := mlx_liftS hr.load (G.mlx_simSS hsrv hr.load.mlx args hok hsm)
  have hs := symShapeOk_sym hok
  unfold symAfterB at hrun
  have hxrun := fullCall_runS x name args hm hp hact (S := S) fun l r ws S1 e => by
    rw [e] at hrun; exact hrun
  refine MSim.of_run (fullLawful.call _ _ _) (fullLawful.call _ _ _) ?_
  intro a S' hu
  rw [hxrun] at hu
  show ∃ M' b C', _
  rw [run_bindS (loadCallSym_l _ _ _)] at hu
  cases hrx : interpS (loadCallSym (toLoad x) name args).run S with
  | none => rw [hrx] at hu; cases hu
  | some p0 =>
    obtain ⟨a0, S0⟩ := p0
    rw [hrx] at hrun hu
    rcases a0 with _ | ⟨l, r, ws⟩
    · cases hrun
    · obtain ⟨b1, haf⟩ := Option.isSome_iff_exists.mp hrun
      have haf0 : Host.Mlx.FfiAne.after x.1.1.bridge x.1.1.base.mlx l.mlx name args = some b1 := haf
      simp only [Option.bind_some, contA] at hu
      obtain ⟨M', b, C', hcy, hgr, hcr⟩ := MSim.run hg _ S0 hrx
      rcases b with _ | ⟨l', r', ws'⟩
      · exact hcr.elim
      · have kx := keepS_of_run hrx
        have ky := keepS_of_runC hcy
        have hmx' := hcr.1.mlx
        have hd' : DenseN l.mlx := hbA.dense.keep kx hmx'.xnnext_lt
        obtain ⟨b1', haf', hrel⟩ := BRel.after hr.load.mlx hmx' hgr.ext.node hF hbA.dense hd' kx.nnext hbA.rel hbA.qord haft haf
        have hyrun := fullCall_runC y name (args.map M.arg) hm hp hacty (C := C) fun l2 r2 ws2 C1 e => by
          rw [hcy] at e
          simp only [Option.some.injEq, Prod.mk.injEq] at e
          obtain ⟨⟨rfl, rfl, rfl⟩, -⟩ := e
          have : Host.Mlx.FfiAne.after y.1.1.bridge y.1.1.base.mlx l'.mlx name (args.map M.arg) = some b1' := haf'
          rw [this]; rfl
        have hpost := full_some_postX hr hgr hcr kx ky hobs hsupp
          (by
            intro s' hs'
            rcases hs with e | e <;> rw [e] at hs' <;> cases hs' <;>
              exact ⟨(fun h => nomatch h), (fun h => by rcases h with h | h | h <;> cases h)⟩)
          (by intro hs'; rcases hs with e | e <;> rw [e] at hs' <;> cases hs')
          (by intro hs'; rcases hs with e | e <;> rw [e] at hs' <;> cases hs')
          (by intro hs'; rcases hs with e | e <;> rw [e] at hs' <;> cases hs')
          (b1 := b1) (b1' := b1') (BR' := BridgeX)
          (fun _ _ _ _ => .inr ⟨(after_active haf).trans hact, ⟨hrel, hd',
            QOrd.grow hr.load.mlx hgr.ext.node hbA.qord hbA.rel.queued (after_pend haf)⟩⟩)
        have hres : fullResA x name args (some (l, r, ws)) = liftF x name args (some (⟨l, b1⟩, r, ws)) := by
          simp only [fullResA, haf0]
        obtain ⟨M2, b2, C2, hc2, hp2⟩ := MSim.run hpost _ S0 rfl
        rw [hres] at hu
        simp only [Host.Ts.M.pure, Host.Ts.M.run, interpS_pure, Option.some.injEq, Prod.mk.injEq] at hu
        obtain ⟨rfl, rfl⟩ := hu
        refine ⟨M2, b2, C2, ?_, hp2⟩
        rw [hyrun, run_bindC (loadCallSym_l _ _ _), hcy]
        have hres' : fullResA y name (args.map M.arg) (some (l', r', ws')) =
            liftF y name (args.map M.arg) (some (⟨l', b1'⟩, r', ws')) := by
          have : Host.Mlx.FfiAne.after y.1.1.bridge y.1.1.base.mlx l'.mlx name (args.map M.arg) = some b1' := haf'
          simp only [fullResA, this]
        simp only [Option.bind_some, contA, hres']
        exact hc2


/-! ## A bridge call with the bridge inactive -/

theorem bridgeOp_same {P : LoadP} {NB : Nat} {M : Map} {k : Nat} {x y : NSt} (hr : G.MR P NB M k x y) {name : Name}
    {args : List Arg} (hok : bridgeOpOk P name args = true) {h : Arg} {F : BSt → Nat → Option (BSt × Ret)}
    (e : bridgeOp name args = some (h, F)) :
    ∃ F', bridgeOp name (args.map M.arg) = some (M.arg h, F') ∧ (∀ b n, F' b n = F b n) ∧
      ∀ b n b1 r, F b n = some (b1, r) → b1.active = b.active ∧ ∀ M' : Map, M'.ret r = r := by
  unfold bridgeOp at e ⊢
  unfold bridgeOpOk at hok
  cases h1 : nameEq name chars!"mbane_input"
  · simp only [h1, Bool.cond_false] at e ⊢
    cases h2 : nameEq name chars!"mbane_output" <;> simp only [h2, Bool.cond_false, Bool.cond_true] at e ⊢
    · cases h3 : nameEq name chars!"mbane_eval_async" <;> simp only [h3, Bool.cond_false, Bool.cond_true] at e ⊢
      · cases h4 : nameEq name chars!"mbane_wait" <;> simp only [h4, Bool.cond_false, Bool.cond_true] at e ⊢
        · cases h5 : nameEq name chars!"mbane_free" <;> simp only [h5, Bool.cond_false, Bool.cond_true] at e ⊢
          · cases e
          · match args, e with
            | [a], e => cases e; exact ⟨_, rfl, fun _ _ => rfl, fun _ _ _ _ e => free_fixed e⟩
        · match args, e with
          | [a, _, _], e => cases e; exact ⟨_, rfl, fun _ _ => rfl, fun _ _ _ _ e => wait_fixed e⟩
      · match args, e with
        | [a], e => cases e; exact ⟨_, rfl, fun _ _ => rfl, fun _ _ _ _ e => evalAsync_fixed e⟩
    · match args, e with
      | [a], e => cases e; exact ⟨_, rfl, fun _ _ => rfl, fun _ _ _ _ e => output_fixed e⟩
  · simp only [h1, Bool.cond_true] at e hok ⊢
    match args, e, hok with
    | [a, i], e, hok =>
      cases e
      refine ⟨_, rfl, fun b n => ?_, fun _ _ _ _ e => input_fixed e⟩
      unfold Host.Mlx.FfiAne.input
      rw [G.MR.natOk_argInt hr hok]

/-- **A bridge call with the bridge inactive**: both sides act on equal bridges. -/
theorem fullOpSimI {P : LoadP} {NB : Nat} {M : Map} {ν : Nat → F64} {S : SSrv} {C : CSrv} {x y : FF.S}
    {name : Name} {args : List Arg} (hsrv : Srv M ν S C) (hr : FullRX P NB M S.tab.length x y)
    (hact : (bridgeOf x).active = false) (hm : Host.Load.isMlx name = false)
    (hc : nameEq name chars!"mbane_program_create" = false) (hsym : Host.Mlx.Ffi.symOf name = none)
    (hok : bridgeOpOk P name args = true) {h : Arg} {F : BSt → Nat → Option (BSt × Ret)}
    (hb : bridgeOp name args = some (h, F)) :
    MSim (fun M' S' C' r r' => Grow M ν S C M' S' C' ∧ CallR (F := FF) (FullRX P NB) M' S'.tab.length r r') S C
      (FF.call x name args) (FF.call y name (args.map M.arg)) := by
  have hbI := (hr.toR hact).bridge
  obtain ⟨F', hb', hFe, hFx⟩ := bridgeOp_same hr.load.mlx hok hb
  rw [full_call_op x hm hc hb, full_call_op y hm hc hb']
  unfold opRes
  cases hn : Host.Load.Ane.handleN x.1.1.base.host h with
  | none => exact MSim.pure ⟨Grow.refl hsrv, trivial⟩
  | some n =>
    rw [show Host.Load.Ane.handleN y.1.1.base.host (M.arg h) = some n from handleN_map hr.load hn]
    dsimp only
    cases e : F x.1.1.bridge n with
    | none => exact MSim.pure ⟨Grow.refl hsrv, trivial⟩
    | some q =>
      obtain ⟨b1, r⟩ := q
      have hy : y.1.1.bridge = x.1.1.bridge := hbI.1
      have e' : F' y.1.1.bridge n = some (b1, r) := by rw [hFe, hy]; exact e
      rw [e']
      obtain ⟨ha1, hret⟩ := hFx _ n b1 r e
      simp only [Option.map_some, liftF_some]
      refine MSim.pure ⟨Grow.refl hsrv, ⟨?_, (hret M).symm, rfl⟩⟩
      refine ⟨hr.load, .inl ⟨rfl, ha1.trans hact⟩, ?_, ?_, hr.pend⟩
      · rw [show (fun e => liveCall e x.1.1.base.mlx name args) = some from
          funext fun e => liveCall_other e _ _ _ fun s _ hs _ => by rw [hsym] at hs; cases hs]
        rw [show (fun e => liveCall e y.1.1.base.mlx name (args.map M.arg)) = some from
          funext fun e => liveCall_other e _ _ _ fun s _ hs _ => by rw [hsym] at hs; cases hs]
        intro fx hx
        cases hxe : x.1.2 with
        | none => rw [hxe] at hx; cases hx
        | some fx0 =>
          rw [hxe, Option.bind_some] at hx
          cases hx
          obtain ⟨fy, hy', hf⟩ := hr.live fx hxe
          exact ⟨fy, by rw [show y.1.2 = some fy from hy', Option.bind_some], hf⟩
      · rw [show (fun k => kernCall k x.1.1.base.mlx name args r) = some from
          funext fun k => kernCall_none k _ _ _ _ hsym]
        rw [show (fun k => kernCall k y.1.1.base.mlx name (args.map M.arg) r) = some from
          funext fun k => kernCall_none k _ _ _ _ hsym]
        intro kx hx
        cases hxe : x.2 with
        | none => rw [hxe] at hx; cases hx
        | some k0 =>
          rw [hxe, Option.bind_some] at hx
          cases hx
          obtain ⟨ky, hy', hk⟩ := hr.kern kx hxe
          exact ⟨ky, by rw [show y.2 = some ky from hy', Option.bind_some], hk⟩

/-! ## The acceptance's simulation -/

/-- **The numeric premise of a Neural Engine row.** -/
def smallFN2 (ν : Nat → F64) (S : SSrv) (x : FF.S) (name : Name) (args : List Arg) : Prop :=
  (((bridgeOf x).active && G.symPath (mlxOf x) name args) = true ∧
      G.symShapeSmall ν S (mlxOf x) name args ∧ symAfterB S x name args = true) ∨
    (((bridgeOf x).active && G.symPath (mlxOf x) name args) = false ∧ smallFX2 ν S x name args)

theorem smallFN2B_sound {VB : Nat → Nat} {ν : Nat → F64} {S : SSrv} {x : FF.S} {name : Name} {args : List Arg}
    (hν : ∀ v, ∃ k ≤ VB v, ν v = F64.ofNat k) (h : smallFN2B VB S x name args = true) : smallFN2 ν S x name args := by
  unfold smallFN2B at h
  cases hc : ((bridgeOf x).active && G.symPath (mlxOf x) name args)
  · rw [hc, Bool.cond_false] at h
    exact .inr ⟨hc, smallFX2B_sound hν h⟩
  · rw [hc, Bool.cond_true, Bool.and_eq_true] at h
    exact .inl ⟨hc, G.symShapeSmallB_sound h.1 hν, h.2⟩

/-- **The native-call simulation of a Neural Engine row.** -/
theorem fullCallSimN2 (P : LoadP) (NB : Nat) : FfiCallSim FF (FullRX P NB) (okCallFN2 P) smallFN2 where
  call := by
    intro M ν S C x y name args hsrv hr hok hsupp hsm
    unfold okCallFN2 at hok
    rw [Bool.or_eq_true, Bool.or_eq_true] at hok
    rcases hok with (hw | hi) | hrest
    · simp only [okCallFW1, Bool.and_eq_true, Bool.or_eq_true] at hw
      obtain ⟨⟨⟨⟨hm, hp⟩, hsym⟩, hwk⟩, hst⟩ := hw
      exact fullWrapSim hsrv hr hm hp (Option.isNone_iff_eq_none.mp hsym) hwk hst
    · simp only [okCallFOpI, Bool.and_eq_true, Bool.not_eq_true'] at hi
      obtain ⟨⟨⟨⟨⟨hact, hm⟩, hc⟩, hsym⟩, hop⟩, hok⟩ := hi
      obtain ⟨⟨h, F⟩, hb⟩ := Option.isSome_iff_exists.mp hop
      exact fullOpSimI hsrv hr hact hm hc (Option.isNone_iff_eq_none.mp hsym) hok hb
    · cases hact : (bridgeOf x).active
      · rw [hact, Bool.cond_false] at hrest
        have hok2 : okCallFX2 P x name args = true := by
          unfold okCallFX2; rw [hact, Bool.cond_false, hrest]; simp
        rcases hsm with ⟨hc, -⟩ | ⟨-, hs⟩
        · rw [hact] at hc; cases hc
        · exact (fullCallSimX2 P NB).call M ν S C x y name args hsrv hr hok2 hsupp hs
      · rw [hact, Bool.cond_true] at hrest
        cases hpath : G.symPath (mlxOf x) name args
        · rw [hpath, Bool.cond_false] at hrest
          have hok2 : okCallFX2 P x name args = true := by
            unfold okCallFX2; rw [hact, Bool.cond_true, hrest]; simp
          rcases hsm with ⟨hc, -⟩ | ⟨-, hs⟩
          · rw [hact, hpath] at hc; cases hc
          · exact (fullCallSimX2 P NB).call M ν S C x y name args hsrv hr hok2 hsupp hs
        · rw [hpath, Bool.cond_true] at hrest
          simp only [okCallFAS, Bool.and_eq_true, decide_eq_true_eq, Bool.not_eq_true'] at hrest
          obtain ⟨⟨⟨⟨⟨⟨-, hb⟩, hm⟩, hp⟩, hso⟩, hobs⟩, haft⟩ := hrest
          have hF : ∀ i, Full P i := fun i => by show i < P.NL ∨ P.N0 ≤ i; omega
          rcases hsm with ⟨-, hs, hae⟩ | ⟨hc, -⟩
          · exact fullCallSymSimA hsrv hr hF hm hp hact hso hobs haft hsupp hs hae
          · rw [hact, hpath] at hc; cases hc

/-- **The native-call simulation of a Neural Engine row at a raise.** -/
theorem fullCallSimND (P : LoadP) (NB : Nat) : FfiCallSim FF (FullRXD P NB) (okCallFND P) smallFN2 where
  call := by
    intro M ν S C x y name args hsrv hr hok hsupp hsm
    unfold okCallFND at hok
    by_cases hb : P.NL = P.N0
    · rw [show decide (P.NL = P.N0) = true from decide_eq_true hb, Bool.cond_true] at hok
      obtain ⟨hrr, hP⟩ := hr.top hb
      refine MSim.mono ((fullCallSimN2 _ NB).call M ν S C x y name args hsrv hrr hok hsupp hsm) ?_
      exact fun M' S' C' r r' h => ⟨h.1, callR_mono (fun _ _ _ _ h => ⟨_, hP, h⟩) h.2⟩
    · rw [show decide (P.NL = P.N0) = false from decide_eq_false hb, Bool.cond_false] at hok
      refine MSim.mono ((fullCallSimN2 P NB).call M ν S C x y name args hsrv (hr.self hb) hok hsupp hsm) ?_
      exact fun M' S' C' r r' h => ⟨h.1, callR_mono (fun _ _ _ _ h => FullRX.toXD h) h.2⟩

/-- **The checked runs' one-step theorem of a Neural Engine row** at `okJSF`. -/
theorem fullStepSimXLBN (P : LoadP) (NB : Nat) (VB : Nat → Nat) (J : Disp.JSP FF) (D0 : Nat)
    (hJ : J.okCall = okCallFND P) (hsm : J.smallB = smallFN2B VB) (hsb : J.smallBackB = smallBackFB VB)
    (hlo : J.lo = P.lo) (hh : J.isHandle = fullIsHandle) (hg : J.isRegion = fullIsRegion)
    {W : Nat → Option WFrame} (stk : List Frame) (hW : Disp.Wp J W) :
    Disp.StepSimXLB FF (Disp.FRJ (FullRXD P NB)) (Disp.okJSF J (okBackFXS P) D0) (Disp.KpJ J D0) W stk (VBOkF VB) :=
  Disp.stepSimXLBJF (fullFfiSimXD P NB) (fullBackSimXDS P NB) (by rw [hJ]; exact fullCallSimND P NB)
    (fun _ _ _ _ _ hν hb => smallFN2B_sound hν (by rw [hsm] at hb; exact hb))
    (fun _ _ _ _ hν hb => smallBackFB_sound hν (by rw [hsb] at hb; exact hb))
    (fullRXD_laws P NB) fullLawful (fullNativeFactsXD P NB J hlo hh hg) hW

/-- A row-bounded valuation from the route's, with the row count at variable 10. -/
theorem vbOkF_rowVB {ν : Nat → F64} {R k : Nat} (h : VBOkF loopVB ν) (h10 : ν 10 = F64.ofNat k) (hk : k ≤ R) :
    VBOkF (rowVB R) ν := by
  intro v
  by_cases hv : v = 10
  · subst hv
    exact ⟨k, by simpa [rowVB] using hk, h10⟩
  · have e : Nat.beq v 10 = false := by
      cases hb : Nat.beq v 10 with
      | false => rfl
      | true => exact absurd (Nat.eq_of_beq_eq_true hb) hv
    obtain ⟨j, hj, hjv⟩ := h v
    exact ⟨j, by simpa [rowVB, e, loopVB] using hj, hjv⟩

end Host.Ts.Sim.Full
