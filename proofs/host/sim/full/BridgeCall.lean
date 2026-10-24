import host.sim.full.BridgeAfter
import host.sim.full.TargetGrow

/-! # The full world's MLX calls with the bridge active

With a surface wrapped, an MLX call other than a wrap is the load world's call followed by the
bridge's update (`FfiAne.after`) and, where the Neural Engine world is stuck, the symbolic-shape
layer's (`symCall_active`). For the calls the load world's simulation accepts, the target's call
simulates the template's (`fullCallOfA`): the load world's results are related, the bridges after
them are related (`BRel.after`, under the template's checks `afterOk` and every node fully
corresponding), the template's nodes below its counter stay present (`Keep`), and the observers
follow as with the bridge inactive. The symbolic-shape layer is reached only where the template's
Neural Engine world is stuck: outside `mlx_array_size`, `mlx_reshape` and `mlx_conv1d` it is stuck
as well, and for those three the template's call runs through the Neural Engine world (decided by
evaluation, `smallFA`). -/

namespace Host.Ts.Sim.Full
open Host.Ts Host.Ts.Sim Host.Load.Layers
open Host.Mlx.Ffi.FullKeep (Keep AllX KRes)
open Host.Ts.Sim.BufSim (Lawful)

/-- The bridge's update after the load world's call. -/
def aneK (a : Host.Load.Ane.ASt) (name : Name) (args : List Arg) :
    Res Host.Load.LSt → Host.Ts.M (Res Host.Load.Ane.ASt)
  | some (l, r, ws) => .pure ((Host.Mlx.FfiAne.after a.bridge a.base.mlx l.mlx name args).map fun b => (⟨l, b⟩, r, ws))
  | none => .pure none

/-- The symbolic-shape layer where the Neural Engine world is stuck. -/
def symFB (a : Host.Load.Ane.ASt) (name : Name) (args : List Arg) :
    Res Host.Load.Ane.ASt → Host.Ts.M (Res Host.Load.Ane.ASt)
  | some r => .pure (some r)
  | none => bif Host.Load.isMlx name && !nameEq name Host.Mlx.FfiAne.payloadName then
      .bind (Host.Mlx.Ffi.SymShape.symShapeCall a.base.mlx name args) fun
        | some (m, r, ws) => .pure (bif a.bridge.active then
            (Host.Mlx.FfiAne.after a.bridge a.base.mlx m name args).map fun b => (⟨{ a.base with mlx := m }, b⟩, r, ws)
          else some (⟨{ a.base with mlx := m }, a.bridge⟩, r, ws))
        | none => .pure none
    else .pure none

theorem ane_call_active (a : Host.Load.Ane.ASt) (name : Name) (args : List Arg) (hm : Host.Load.isMlx name = true)
    (hp : nameEq name Host.Mlx.FfiAne.payloadName = false) (ha : a.bridge.active = true) :
    Host.Load.Ane.call a name args = Host.Ts.M.bind (Host.Load.call a.base name args) (aneK a name args) := by
  funext γ k
  simp only [Host.Load.Ane.call, hm, Bool.cond_true, Host.Mlx.FfiAne.mlxCall, hp, Bool.cond_false, Host.Load.call,
    Host.Ts.M.bind]
  congr 1
  funext o
  rcases o with _ | ⟨m, r, ws⟩
  · rfl
  · simp only [ha, Bool.cond_true, aneK]
    show _ = k (Option.map (fun b => (⟨{ a.base with mlx := m }, b⟩, r, ws)) (Host.Mlx.FfiAne.after a.bridge a.base.mlx m name args))
    cases Host.Mlx.FfiAne.after a.bridge a.base.mlx m name args <;> rfl

/-- The full world's call with the bridge active: the load world's call, then the bridge's update,
the symbolic-shape layer where that is stuck, and the observers. -/
def fullContA (p : FF.S) (name : Name) (args : List Arg) (o : Res Host.Load.LSt) : Host.Ts.M (Res FF.S) :=
  .bind (.bind (aneK p.1.1 name args o) (symFB p.1.1 name args)) fun o' => .pure (liftF p name args o')

theorem full_call_active (p : FF.S) (name : Name) (args : List Arg) (hm : Host.Load.isMlx name = true)
    (hp : nameEq name Host.Mlx.FfiAne.payloadName = false) (ha : (bridgeOf p).active = true) :
    FF.call p name args = Host.Ts.M.bind (Host.Load.call (toLoad p) name args) (fullContA p name args) := by
  rw [full_call_eq]
  funext γ k
  show symCall p.1.1 name args γ _ = _
  unfold symCall
  rw [ane_call_active p.1.1 name args hm hp ha]
  rfl

/-! ## The bridge stays active -/

theorem classifyNode_active {b b1 : BSt} {s : Host.Mlx.Ffi.St} {n : Nat}
    (e : Host.Mlx.FfiAne.classifyNode b s n = some b1) : b1.active = b.active := by
  unfold Host.Mlx.FfiAne.classifyNode at e
  repeat' (first | (cases e; rfl) | (simp only [Option.some.injEq] at e; subst e; rfl) | split at e)
  all_goals (try simp only [Bool.cond_eq_ite] at e)
  all_goals (try split at e)
  all_goals first | (cases e; rfl) | (simp only [Option.some.injEq] at e; subst e; rfl) | simp at e

theorem classify_active {s : Host.Mlx.Ffi.St} : ∀ (f n : Nat) {b b1 : BSt},
    Host.Mlx.FfiAne.classify b s f n = some b1 → b1.active = b.active
  | 0, _, _, _, e => by cases e; rfl
  | f + 1, n, b, b1, e => by
    unfold Host.Mlx.FfiAne.classify at e
    cases h : Nat.blt n s.nnext
    · rw [h, Bool.cond_false] at e; cases e; rfl
    · rw [h, Bool.cond_true] at e
      cases e2 : Host.Mlx.FfiAne.classifyNode b s n with
      | none => rw [e2] at e; cases e
      | some b2 =>
        rw [e2] at e
        exact (classify_active f (n + 1) e).trans (classifyNode_active e2)

theorem schedule_active {b b1 : BSt} {s : Host.Mlx.Ffi.St} {roots : List Nat} {bl : Bool}
    (e : Host.Mlx.FfiAne.schedule b s roots bl = some b1) : b1.active = b.active := by
  unfold Host.Mlx.FfiAne.schedule at e
  simp only [Bool.cond_eq_ite] at e
  repeat' (first | (cases e; rfl) | (simp only [Option.some.injEq] at e; subst e; rfl) | split at e | simp at e)

theorem after_active {b b1 : BSt} {s s' : Host.Mlx.Ffi.St} {name : Name} {args : List Arg}
    (e : Host.Mlx.FfiAne.after b s s' name args = some b1) : b1.active = b.active := by
  unfold Host.Mlx.FfiAne.after at e
  split at e
  · exact schedule_active e
  · cases e; rfl
  · exact classify_active _ _ e

/-! ## The layers after the load world's call -/

/-- The full world's result after the load world's call, outside the symbolic-shape layer. -/
def fullResA (p : FF.S) (name : Name) (args : List Arg) : Res Host.Load.LSt → Res FF.S
  | some (l, r, ws) => match Host.Mlx.FfiAne.after p.1.1.bridge p.1.1.base.mlx l.mlx name args with
    | some b => liftF p name args (some (⟨l, b⟩, r, ws))
    | none => none
  | none => none

theorem fullContA_some (p : FF.S) (name : Name) (args : List Arg) {l : Host.Load.LSt} {r : Ret}
    {ws : List (Nat × Nat × List Byte)} {b1 : BSt}
    (hb : Host.Mlx.FfiAne.after p.1.1.bridge p.1.1.base.mlx l.mlx name args = some b1) :
    fullContA p name args (some (l, r, ws)) = .pure (liftF p name args (some (⟨l, b1⟩, r, ws))) := by
  funext γ k
  simp only [fullContA, aneK, hb, Option.map_some]
  rfl

theorem fullContA_stuck (p : FF.S) (name : Name) (args : List Arg) (hss : isSymShape name = false)
    (o : Res Host.Load.LSt) : fullContA p name args o = .pure (fullResA p name args o) := by
  funext γ k
  rcases o with _ | ⟨l, r, ws⟩
  · show symFB p.1.1 name args none γ _ = _
    unfold symFB
    rw [symShapeCall_stuck _ _ _ hss]
    cases (Host.Load.isMlx name && !nameEq name Host.Mlx.FfiAne.payloadName) <;> rfl
  · simp only [fullContA, aneK]
    cases hb : Host.Mlx.FfiAne.after p.1.1.bridge p.1.1.base.mlx l.mlx name args with
    | some b => simp only [Option.map_some]; rw [fullResA, hb]; rfl
    | none =>
      simp only [Option.map_none]
      show symFB p.1.1 name args none γ _ = _
      unfold symFB
      rw [symShapeCall_stuck _ _ _ hss]
      rw [fullResA, hb]
      cases (Host.Load.isMlx name && !nameEq name Host.Mlx.FfiAne.payloadName) <;> rfl

/-- The template's Neural Engine world's run from the load world's run. -/
theorem ane_run_some {a : Host.Load.Ane.ASt} {name : Name} {args : List Arg} (hm : Host.Load.isMlx name = true)
    (hp : nameEq name Host.Mlx.FfiAne.payloadName = false) (ha : a.bridge.active = true) {S S' : SSrv}
    {o : Res Host.Load.LSt} (h : interpS (Host.Load.call a.base name args).run S = some (o, S')) :
    interpS (Host.Load.Ane.call a name args).run S = interpS (aneK a name args o).run S' := by
  rw [ane_call_active a name args hm hp ha]
  show interpS (Host.Load.call a.base name args _ fun o => aneK a name args o _ Free.pure) S = _
  have hl : Lawful (Host.Load.call a.base name args) := loadFfiLawful.call a.base name args
  rw [hl.1, h]
  rfl

theorem fullResA_none (p : FF.S) (name : Name) (args : List Arg) {l : Host.Load.LSt} {r : Ret}
    {ws : List (Nat × Nat × List Byte)}
    (hb : Host.Mlx.FfiAne.after p.1.1.bridge p.1.1.base.mlx l.mlx name args = none) :
    fullResA p name args (some (l, r, ws)) = none := by
  simp only [fullResA, hb]

/-- **The layers after related load-world results and related bridges.** -/
theorem full_some_postX {BR BR' : Map → FF.S → FF.S → Prop} {P : LoadP} {NB : Nat} {M M' : Map} {ν : Nat → F64}
    {S S' : SSrv} {C C' : CSrv} {x y : FF.S} {name : Name} {args : List Arg} {l l' : Host.Load.LSt} {r r' : Ret}
    {ws ws' : List (Nat × Nat × List Byte)} {b1 b1' : BSt}
    (hr : FullRB BR P NB M S.tab.length x y) (hgr : Grow M ν S C M' S' C')
    (hcr : CallR (F := Host.Load.ffi) (G.LoadR P NB) M' S'.tab.length (some (l, r, ws)) (some (l', r', ws')))
    (kx : Keep (mlxOf x) l.mlx) (ky : Keep (mlxOf y) l'.mlx) (hobs : obsOk (mlxOf x) name args = true)
    (hsupp : ∀ a ∈ args, Supp.arg (fun _ => True) S.tab.length a) (hka : KernAcc P (mlxOf x) name args)
    (haa : Host.Mlx.Ffi.symOf name = some .arrayFree → ∀ a, args = [a] → hdOk (mlxOf x) a = true)
    (hnew : Host.Mlx.Ffi.symOf name = some .cfgNew → args = [] →
      r = .big (Int.ofNat (mlxOf x).next) ∧ (l.mlx.objs.get (mlxOf x).next).isSome = true)
    (hnewK : Host.Mlx.Ffi.symOf name = some .kernelNew → args.length = 7 →
      r = .big (Int.ofNat (mlxOf x).next) ∧ (l.mlx.objs.get (mlxOf x).next).isSome = true)
    (hbr : ∀ e e' k k', BR' M' (((⟨l, b1⟩ : Host.Load.Ane.ASt), e), k) (((⟨l', b1'⟩ : Host.Load.Ane.ASt), e'), k')) :
    MSim (fun M'' S'' C'' r r' => Grow M ν S C M'' S'' C'' ∧ CallR (F := FF) (FullRB BR' P NB) M'' S''.tab.length r r')
      S' C' (Host.Ts.M.pure (liftF x name args (some (⟨l, b1⟩, r, ws))))
      (Host.Ts.M.pure (liftF y name (args.map M.arg) (some (⟨l', b1'⟩, r', ws')))) := by
  obtain ⟨hlr, hr', hws⟩ := hcr
  have hob : ObsPost P NB M M' S.tab.length S'.tab.length (mlxOf x) (mlxOf y) l.mlx l'.mlx :=
    ⟨hr.load.mlx, hlr.mlx, hgr.ext, hgr.len, kx, ky⟩
  rw [liftF_some, liftF_some]
  refine MSim.pure ⟨hgr, ⟨hlr, hbr _ _ _ _, ?_, ?_, hr.pend.step hr.load.mlx hlr.mlx hgr.ext kx⟩, hr', hws⟩
  · exact live_step hr.live hob hobs haa
  · rw [hr']
    exact kern_step hr.kern hob hsupp hka hnew hnewK

/-- A configuration's and a kernel's creation return the template's counter and leave an object there. -/
theorem call_newFacts {x : Host.Load.LSt} {name : Name} {args : List Arg} {S S' : SSrv} {l : Host.Load.LSt}
    {r : Ret} {ws : List (Nat × Nat × List Byte)} (hm : Host.Load.isMlx name = true) (hb : x.mlx.next < 2 ^ 64)
    (hra : interpS (Host.Load.call x name args).run S = some (some (l, r, ws), S')) :
    (Host.Mlx.Ffi.symOf name = some .cfgNew → args = [] →
      r = .big (Int.ofNat x.mlx.next) ∧ (l.mlx.objs.get x.mlx.next).isSome = true) ∧
    (Host.Mlx.Ffi.symOf name = some .kernelNew → args.length = 7 →
      r = .big (Int.ofNat x.mlx.next) ∧ (l.mlx.objs.get x.mlx.next).isSome = true) := by
  refine ⟨fun hs ha => ?_, fun hs hl => ?_⟩
  · subst ha
    have hra' : interpS (Host.Load.call x name []).run S = some (some (l, r, ws), S') := hra
    rw [load_call_cfgNew _ _ hm hs] at hra'
    simp only [Host.Ts.M.run, Host.Ts.M.pure, interpS_pure, Option.some.injEq, Prod.mk.injEq] at hra'
    obtain ⟨⟨rfl, rfl, -⟩, -⟩ := hra'
    refine ⟨rfl, ?_⟩
    show (((x.mlx.objs.set x.mlx.next _)).get x.mlx.next).isSome = true
    rw [PTrie.get_set_u64 _ _ _ hb]
    simp
  · rcases args with _ | ⟨a0, _ | ⟨a1, _ | ⟨a2, _ | ⟨a3, _ | ⟨a4, _ | ⟨rc, _ | ⟨ao, _ | ⟨_, _⟩⟩⟩⟩⟩⟩⟩⟩ <;>
      try (simp only [List.length_cons, List.length_nil] at hl; omega)
    exact (load_kernelNew_res x hm hs hb a0 a1 a2 a3 a4 rc ao).1 S _ S' hra l r ws rfl

theorem BridgeX.active {M : Map} {x y : FF.S} (h : BridgeX M x y) (ha : (bridgeOf x).active = true) : BridgeA M x y := by
  rcases h with h | ⟨-, h⟩
  · rw [h.2] at ha; cases ha
  · exact h

/-- **An MLX call with the bridge active**, over a load-world call simulation `hg` the observers read
(`hka`, `haa`), the bridge's checks (`haft`) and the Neural Engine world's run for the three calls the
symbolic-shape layer completes (`hsm`). -/
theorem fullCallOfA {P : LoadP} {NB : Nat} {M : Map} {ν : Nat → F64} {S : SSrv} {C : CSrv} {x y : FF.S}
    {name : Name} {args : List Arg} (hr : FullRX P NB M S.tab.length x y) (hF : ∀ i, Full P i)
    (hm : Host.Load.isMlx name = true) (hp : nameEq name Host.Mlx.FfiAne.payloadName = false)
    (hact : (bridgeOf x).active = true) (haft : afterOk (bridgeOf x) (mlxOf x) name args = true)
    (hobs : obsOk (mlxOf x) name args = true)
    (hsupp : ∀ a ∈ args, Supp.arg (fun _ => True) S.tab.length a) (hka : KernAcc P (mlxOf x) name args)
    (haa : Host.Mlx.Ffi.symOf name = some .arrayFree → ∀ a, args = [a] → hdOk (mlxOf x) a = true)
    (hsm : isSymShape name = true → ∀ a S', interpS (Host.Load.Ane.call x.1.1 name args).run S = some (a, S') →
      a.isSome = true)
    (hg : MSim (G.LPost P NB M ν S C) S C (Host.Load.call (toLoad x) name args)
      (Host.Load.call (toLoad y) name (args.map M.arg))) :
    MSim (fun M' S' C' r r' => Grow M ν S C M' S' C' ∧ CallR (F := FF) (FullRX P NB) M' S'.tab.length r r') S C
      (FF.call x name args) (FF.call y name (args.map M.arg)) := by
  have hbA := hr.bridge.active hact
  have hacty : (bridgeOf y).active = true := by rw [hbA.rel.active]; exact hact
  rw [full_call_active x name args hm hp hact, full_call_active y name _ hm hp hacty]
  have hg2 := MSim.both hg (loadFfiLawful.call _ _ _) (loadFfiLawful.call _ _ _)
  refine MSim.bind hg2 fun M' S' C' a b hab => ?_
  obtain ⟨⟨hgr, hcr⟩, hra, hrb⟩ := hab
  rcases a with _ | ⟨l, r, ws⟩
  · cases hss : isSymShape name
    · rw [fullContA_stuck x _ _ hss, fullContA_stuck y _ _ hss]
      exact MSim.pure ⟨hgr, trivial⟩
    · exfalso
      have := hsm hss _ _ ((ane_run_some hm hp hact hra).trans (interpS_pure _ _))
      cases this
  · rcases b with _ | ⟨l', r', ws'⟩
    · exact hcr.elim
    · have kx := keep_of_run hm hra
      have ky := keep_of_runC hm hrb
      have hlr := hcr.1
      cases haf : Host.Mlx.FfiAne.after (bridgeOf x) (mlxOf x) l.mlx name args with
      | none =>
        cases hss : isSymShape name
        · rw [fullContA_stuck x _ _ hss, fullContA_stuck y _ _ hss, fullResA_none x name args haf]
          exact MSim.pure ⟨hgr, trivial⟩
        · exfalso
          have e1 := ane_run_some hm hp hact hra
          have e2 : interpS (aneK x.1.1 name args (some (l, r, ws))).run S' = some (none, S') := by
            show interpS (Host.Ts.M.pure ((Host.Mlx.FfiAne.after x.1.1.bridge x.1.1.base.mlx l.mlx name args).map
              fun b => ((⟨l, b⟩ : Host.Load.Ane.ASt), r, ws))).run S' = _
            rw [show Host.Mlx.FfiAne.after x.1.1.bridge x.1.1.base.mlx l.mlx name args = none from haf]
            rfl
          have := hsm hss _ _ (e1.trans e2)
          cases this
      | some b1 =>
        have hmx' := hlr.mlx
        have hd' : ∀ i, i < l.mlx.nnext → PN l.mlx i := fun i hi => by
          by_cases e : i < (mlxOf x).nnext
          · show (l.mlx.nodes.get i).isSome = true
            rw [kx.nodes i e]; exact hbA.dense i e
          · exact kx.dense i (Nat.not_lt.mp e) hi (by have := hmx'.xnnext_lt; omega)
        obtain ⟨b1', haf', hrel⟩ := BRel.after hr.load.mlx hmx' hgr.ext.node hF hbA.dense hd' kx.nnext hbA.rel haft haf
        rw [fullContA_some x name args haf, fullContA_some y name _ haf']
        have hb : (toLoad x).mlx.next < 2 ^ 64 := by
          have := hr.load.mlx.hnext; have := hr.load.mlx.hroom; omega
        obtain ⟨hnew, hnewK⟩ := call_newFacts hm hb hra
        exact full_some_postX hr hgr hcr kx ky hobs hsupp hka haa hnew hnewK
          (fun _ _ _ _ => .inr ⟨(after_active haf).trans hact, ⟨hrel, hd'⟩⟩)

end Host.Ts.Sim.Full
