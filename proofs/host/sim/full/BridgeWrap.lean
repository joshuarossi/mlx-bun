import host.sim.full.BridgeOpsSim

/-! # A surface wrap under the map

`mlx_array_new_data_managed_payload` on a surface's base address wraps the surface whole
(`FfiAne.wrap`): a node of the surface's shape and dtype, an array for it, the node recorded as the
surface's wrap, the bridge active. On related states the target wraps the same surface (the bridges'
surfaces are equal, the address and the literal shape are fixed by the map) with the image node
(`wrap_rel`). The first wrap starts the active relation from the inactive one: the template's bridge
records nothing yet (`bridgeClean`) and its nodes below the counter are present (`denseB`), both
decided once. -/

namespace Host.Ts.Sim.Full
open Host.Ts Host.Ts.Sim Host.Load.Layers
open Host.Mlx.Ffi.FullKeep (Keep)
open Host.Mlx.Ffi (Node Dim)

/-- A trie with no root. -/
def isNilT {α : Type} (t : PTrie α) : Bool :=
  match t.root with
  | .nil => true
  | _ => false

theorem get_of_isNilT {α : Type} {t : PTrie α} (h : isNilT t = true) (n : Nat) : t.get n = none := by
  obtain ⟨r⟩ := t
  cases r with
  | nil => rfl
  | node _ _ _ _ _ => cases h

/-- No `.gpu` effect. -/
def noGpu (e : Host.Mlx.FfiAne.Effect) : Bool :=
  match e with
  | .gpu _ => false
  | _ => true

/-- The bridge records no node: no alias, touch, queue or evaluation. -/
def bridgeClean (b : BSt) : Bool :=
  isNilT b.aliases && isNilT b.touch && b.unscheduled.isEmpty && b.running.isEmpty && b.log.all noGpu

/-- The template's nodes below its counter are present, decided. -/
def denseB (x : NSt) : Bool := (List.range x.nnext).all fun i => (x.nodes.get i).isSome

theorem denseB_sound {x : NSt} (h : denseB x = true) : ∀ i, i < x.nnext → PN x i := fun i hi =>
  List.all_eq_true.mp h i (List.mem_range.mpr hi)

/-- A clean bridge is related to itself under any map. -/
theorem BRel.ofClean {b : BSt} (h : bridgeClean b = true) (M : Map) (nx ny : Nat) : BRel M nx ny b b := by
  simp only [bridgeClean, Bool.and_eq_true] at h
  obtain ⟨⟨⟨⟨ha, ht⟩, hu⟩, hr⟩, hl⟩ := h
  have hu' : b.unscheduled = [] := List.isEmpty_iff.mp hu
  have hr' : b.running = [] := List.isEmpty_iff.mp hr
  have hlog : b.log = b.log.map M.effect := by
    conv => lhs; rw [← List.map_id b.log]
    exact List.map_congr_left fun e he => by
      have := List.all_eq_true.mp hl e he
      cases e with
      | gpu _ => cases this
      | start _ => rfl
      | join _ => rfl
  exact
    { surfaces := rfl
      programs := rfl
      handles := rfl
      active := rfl
      aliases := fun n _ => by rw [get_of_isNilT ha, get_of_isNilT ha]
      aliasX := fun n hn => by rw [get_of_isNilT ha] at hn; cases hn
      aliasY := fun m hm => by rw [get_of_isNilT ha] at hm; cases hm
      touch := fun n _ => by rw [get_of_isNilT ht, get_of_isNilT ht]
      touchX := fun n hn => by rw [get_of_isNilT ht] at hn; cases hn
      touchY := fun m hm => by rw [get_of_isNilT ht] at hm; cases hm
      unscheduled := by rw [hu']; rfl
      running := by rw [hr']; rfl
      queued := fun n hn => by rw [hu', hr'] at hn; cases hn
      log := hlog }

/-- The bridge after a wrap of surface `sid` at node `X` (the template's counter) and its image `Y`. -/
theorem BRel.wrapSet {M : Map} {X Y : Nat} {b b' : BSt} (h : BRel M X Y b b') (hfr : ∀ i, M.node (X + i) = Y + i)
    (hlt : ∀ m, m < X → M.node m < Y) (hX : X < 2 ^ 62) (hY : Y < 2 ^ 62) (sid : Nat) :
    BRel M (X + 1) (Y + 1) { b with active := true, aliases := b.aliases.set X (.wrap sid) }
      { b' with active := true, aliases := b'.aliases.set Y (.wrap sid) } := by
  have hw := h.widen (Nat.le_succ X) (Nat.le_succ Y) hfr
  have hX0 : M.node X = Y := by simpa using hfr 0
  exact { hw with
    active := rfl
    aliases := fun m hm => by
      show (b'.aliases.set Y _).get (M.node m) = (b.aliases.set X _).get m
      by_cases e : m = X
      · subst e
        rw [hX0, get_set_eq_of_lt _ _ hY, get_set_eq_of_lt _ _ hX]
      · have hm' : m < X := by omega
        have e' : M.node m ≠ Y := by have := hlt m hm'; omega
        rw [PTrie.get_set_ne' _ _ _ _ e', PTrie.get_set_ne' _ _ _ _ e]
        exact h.aliases m hm'
    aliasX := fun m hm => by
      rcases isSome_set_cases _ _ _ _ hm with e | e
      · exact Nat.lt_succ_of_lt (h.aliasX m e)
      · rw [e]; exact Nat.lt_succ_self X
    aliasY := fun m hm => by
      rcases isSome_set_cases _ _ _ _ hm with e | e
      · exact Nat.lt_succ_of_lt (h.aliasY m e)
      · rw [e]; exact Nat.lt_succ_self Y }

/-- The template's checks of a wrap: a fixed address, a literal shape, a fixed dtype, room. -/
def wrapOk (P : LoadP) (x : NSt) (args : List Arg) : Bool :=
  match args with
  | [p, sh, nd, dt, _, _] => natOk P p && dimsOk P sh nd && dimsLitOk sh nd && natOk P dt &&
      decide (x.nnext + 1 ≤ P.NE) && decide (x.next + 1 ≤ P.E)
  | _ => false

theorem surfaceOf_map {P : LoadP} {NB : Nat} {M : Map} {n : Nat} {x y : NSt} (hr : G.MR P NB M n x y) {b b' : BSt}
    (hs : b'.surfaces = b.surfaces) {p : Arg} (hp : natOk P p = true) :
    Host.Mlx.FfiAne.surfaceOf b' (M.arg p) = Host.Mlx.FfiAne.surfaceOf b p := by
  have e : Host.Mlx.FfiAne.sidOf b' = Host.Mlx.FfiAne.sidOf b := by
    funext a; unfold Host.Mlx.FfiAne.sidOf; rw [hs]
  have ha : Host.Mlx.Ffi.argInt (M.arg p) = Host.Mlx.Ffi.argInt p := G.MR.natOk_argInt hr hp
  cases p with
  | big i =>
    have : M.arg (.big i) = .big i := by
      have := ha; simp only [Host.Mlx.Ffi.argInt] at this; show Arg.big (M.big i) = _; rw [Option.some.inj this]
    rw [this]; unfold Host.Mlx.FfiAne.surfaceOf; rw [e]
  | num v =>
    cases v with
    | lit f => show Host.Mlx.FfiAne.surfaceOf b' (.num (.lit f)) = _; unfold Host.Mlx.FfiAne.surfaceOf; rw [e]
    | ref _ => cases hp
  | null => rfl
  | _ => cases hp

/-- **A wrap under the map.** -/
theorem wrap_rel {P : LoadP} {NB : Nat} {M : Map} {n : Nat} {x y : NSt} (hr : G.MR P NB M n x y)
    (hd : ∀ i, i < x.nnext → PN x i) {b b' : BSt} (hb : BRel M x.nnext y.nnext b b') {args : List Arg}
    (hok : wrapOk P x args = true) {x' : NSt} {b1 : BSt} {r : Ret}
    (e : Host.Mlx.FfiAne.wrap b x args = some (x', b1, r)) :
    ∃ y' b1', Host.Mlx.FfiAne.wrap b' y (args.map M.arg) = some (y', b1', M.ret r) ∧ G.MR P NB M n x' y' ∧
      BRel M x'.nnext y'.nnext b1 b1' ∧ b1.active = true ∧ Keep x x' ∧ Keep y y' := by
  unfold wrapOk at hok
  match args, hok, e with
  | [p, sh, nd, dt, a5, a6], hok, e =>
    simp only [Bool.and_eq_true, decide_eq_true_eq] at hok
    obtain ⟨⟨⟨⟨⟨hp, hdk⟩, hlit⟩, hdt⟩, hNE⟩, hE⟩ := hok
    simp only [List.map_cons, List.map_nil]
    unfold Host.Mlx.FfiAne.wrap at e ⊢
    dsimp only at e ⊢
    rw [surfaceOf_map hr hb.surfaces hp, G.MR.natOk_argNat hr hdt]
    cases hsf : Host.Mlx.FfiAne.surfaceOf b p with
    | none => rw [hsf] at e; simp at e
    | some sid =>
      cases hds : Host.Mlx.Ffi.dimsArg sh nd with
      | none => rw [hsf, hds] at e; simp at e
      | some shape =>
        have hl : shape.all dimLit = true := by simp only [dimsLitOk, hds] at hlit; exact hlit
        rw [G.MR.dimsArg_map hr hdk hds, dims_lit M hl]
        cases hdn : Host.Mlx.Ffi.argNat dt with
        | none => rw [hsf, hds, hdn] at e; simp at e
        | some d =>
          rw [hsf, hds, hdn] at e
          dsimp only at e ⊢
          cases hnd : Host.Mlx.Ffi.natsOfDims shape with
          | none => rw [hnd] at e; simp at e
          | some ds =>
            rw [hnd] at e
            dsimp only at e ⊢
            have hsz : b'.surfaceSize sid = b.surfaceSize sid := by
              unfold Host.Mlx.FfiAne.St.surfaceSize; rw [hb.surfaces]
            rw [hsz]
            cases hc : Nat.beq (ds.foldr (· * ·) 1 * Host.Mlx.Ffi.dtSize d) (b.surfaceSize sid)
            · rw [hc, Bool.cond_false] at e; cases e
            · rw [hc, Bool.cond_true] at e
              rw [Bool.cond_true]
              simp only [Host.Mlx.Ffi.St.addNode, Host.Mlx.Ffi.St.setArr, Nat.beq_refl, Bool.cond_true] at e ⊢
              simp only [Option.some.injEq, Prod.mk.injEq] at e
              obtain ⟨rfl, rfl, rfl⟩ := e
              let nd0 : Node := ⟨.unary (Host.Mlx.FfiAne.surfaceName sid), [], shape, d⟩
              have h1 := hr.addNode nd0 hNE ⟨trivial, SDs.of_lit hl⟩ (fun e he => dimCanon_lit M (List.all_eq_true.mp hl e he))
              have h2 := h1.newArr x.nnext hE
              have hnn : M.nnode nd0 = nd0 := by simp only [nd0, Map.nnode, Map.prim, dims_lit M hl, List.map_nil]
              rw [hnn, hr.node_next] at h2
              have hbig : M.big (Int.ofNat x.next) = Int.ofNat y.next := (hr.fresh0 (by omega)).1
              have hlt : ∀ m, m < x.nnext → M.node m < y.nnext := fun m hm => hr.nimg m (hd m hm)
              have hret : M.ret (Ret.big ((x.next : Nat) : Int)) = Ret.big ((y.next : Nat) : Int) := by
                show Ret.big (M.big (Int.ofNat x.next)) = _; rw [hbig]; rfl
              refine ⟨_, _, by rw [hret], h2, ?_, rfl, ?_, ?_⟩
              · exact hb.wrapSet hr.nfresh hlt hr.xnnext_lt hr.ynnext_lt sid
              · exact ((Keep.refl x).addNode nd0).setArr 0 x.nnext
              · exact ((Keep.refl y).addNode nd0).setArr 0 y.nnext

theorem full_call_wrap (p : FF.S) {name : Name} {args : List Arg} (hm : Host.Load.isMlx name = true)
    (hp : nameEq name Host.Mlx.FfiAne.payloadName = true) :
    FF.call p name args = .pure (liftF p name args ((Host.Mlx.FfiAne.wrap p.1.1.bridge p.1.1.base.mlx args).map
      fun q => ((⟨{ p.1.1.base with mlx := q.1 }, q.2.1⟩ : Host.Load.Ane.ASt), q.2.2, []))) := by
  rw [full_call_eq]
  funext γ k
  show symCall p.1.1 name args γ _ = _
  unfold symCall Host.Load.Ane.call
  simp only [hm, Bool.cond_true, Host.Mlx.FfiAne.mlxCall, hp]
  cases Host.Mlx.FfiAne.wrap p.1.1.bridge p.1.1.base.mlx args with
  | none => simp only [Option.map_none, hp, Bool.not_true, Bool.and_false, Bool.cond_false]; rfl
  | some q => rfl

/-- **A surface wrap in the full world**: from the active relation, or from the inactive one with a clean
bridge and the template's nodes present (the first wrap). -/
theorem fullWrapSim {P : LoadP} {NB : Nat} {M : Map} {ν : Nat → F64} {S : SSrv} {C : CSrv} {x y : FF.S}
    {name : Name} {args : List Arg} (hsrv : Srv M ν S C) (hr : FullRX P NB M S.tab.length x y)
    (hm : Host.Load.isMlx name = true) (hp : nameEq name Host.Mlx.FfiAne.payloadName = true)
    (hsym : Host.Mlx.Ffi.symOf name = none) (hok : wrapOk P (mlxOf x) args = true)
    (hst : (bridgeOf x).active = true ∨ (bridgeClean (bridgeOf x) = true ∧ denseB (mlxOf x) = true)) :
    MSim (fun M' S' C' r r' => Grow M ν S C M' S' C' ∧ CallR (F := FF) (FullRX P NB) M' S'.tab.length r r') S C
      (FF.call x name args) (FF.call y name (args.map M.arg)) := by
  have hpre : BRel M (mlxOf x).nnext (mlxOf y).nnext (bridgeOf x) (bridgeOf y) ∧
      ∀ i, i < (mlxOf x).nnext → PN (mlxOf x) i := by
    rcases hr.bridge with hb | ⟨-, hb⟩
    · rcases hst with ha | ⟨hc, hdn⟩
      · rw [hb.2] at ha; cases ha
      · rw [hb.1]; exact ⟨BRel.ofClean hc M _ _, denseB_sound hdn⟩
    · exact ⟨hb.rel, hb.dense⟩
  obtain ⟨hbr, hd⟩ := hpre
  rw [full_call_wrap x hm hp, full_call_wrap y hm hp]
  cases e : Host.Mlx.FfiAne.wrap (bridgeOf x) (mlxOf x) args with
  | none =>
    rw [show Host.Mlx.FfiAne.wrap x.1.1.bridge x.1.1.base.mlx args = none from e]
    exact MSim.pure ⟨Grow.refl hsrv, trivial⟩
  | some q =>
    obtain ⟨x', b1, r⟩ := q
    obtain ⟨y', b1', e', hmr', hb1, ha1, kx, ky⟩ := wrap_rel hr.load.mlx hd hbr hok e
    rw [show Host.Mlx.FfiAne.wrap x.1.1.bridge x.1.1.base.mlx args = some (x', b1, r) from e,
      show Host.Mlx.FfiAne.wrap y.1.1.bridge y.1.1.base.mlx (args.map M.arg) = some (y', b1', M.ret r) from e']
    simp only [Option.map_some, liftF_some]
    have hob : ObsPost P NB M M S.tab.length S.tab.length (mlxOf x) (mlxOf y) x' y' :=
      ⟨hr.load.mlx, hmr', Ext.refl _ _, Nat.le_refl _, kx, ky⟩
    have hd' : ∀ i, i < x'.nnext → PN x' i := fun i hi => by
      by_cases e2 : i < (mlxOf x).nnext
      · show (x'.nodes.get i).isSome = true
        rw [kx.nodes i e2]; exact hd i e2
      · exact kx.dense i (Nat.not_lt.mp e2) hi (by have := hmr'.xnnext_lt; omega)
    refine MSim.pure ⟨Grow.refl hsrv, ⟨?_, rfl, rfl⟩⟩
    refine ⟨⟨hr.load.host, hr.load.hostReg, hr.load.hostLt, hr.load.cbr, hmr'⟩, .inr ⟨ha1, ⟨hb1, hd'⟩⟩, ?_, ?_,
      hr.pend.step hr.load.mlx hmr' (Ext.refl _ _) kx⟩
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
        obtain ⟨fy, hy, hf⟩ := hr.live fx hxe
        exact ⟨fy, by rw [show y.1.2 = some fy from hy, Option.bind_some], hf.keep hob⟩
    · rw [show (fun k => kernCall k x.1.1.base.mlx name args r) = some from
        funext fun k => kernCall_none k _ _ _ _ hsym]
      rw [show (fun k => kernCall k y.1.1.base.mlx name (args.map M.arg) (M.ret r)) = some from
        funext fun k => kernCall_none k _ _ _ _ hsym]
      intro kx0 hx
      cases hxe : x.2 with
      | none => rw [hxe] at hx; cases hx
      | some k0 =>
        rw [hxe, Option.bind_some] at hx
        cases hx
        obtain ⟨ky, hy, hk⟩ := hr.kern kx0 hxe
        exact ⟨ky, by rw [show y.2 = some ky from hy, Option.bind_some], hk.keep hob⟩

end Host.Ts.Sim.Full
