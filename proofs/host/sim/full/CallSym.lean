import host.sim.full.CallX
import host.sim.full.SymLayer
import host.sim.full.Closure

/-! # The full world's calls the symbolic-shape layer completes

With the bridge inactive, the full world's mlx call is the model's call completed by the
symbolic-shape layer (`full_call_sym`: `SymShape.callSym` on the load-world projection, then the
observers). `fullCallSymSim`: for the calls the layer completes (`G.symPath`) and `G.symShapeOk`
accepts, the template's and the target's completed calls simulate (`G.mlx_simSS`), each side
through whichever of the model and the layer it reaches. `fullCallSimS`: the full world's
native-call simulation with these calls and the forward's operations over symbolic shapes
(`okCallFS`, `smallFS`), `fullCallSimX` elsewhere. -/

namespace Host.Mlx.Ffi.FullKeep
open Host.Ts Host.Ts.Sim.BufSim

theorem opOutSym_k {s₀ s : St} (h : Keep s₀ s) (o : Arg) (p : Prim) (ins : List Nat) :
    AllX (KRes s₀) (Host.Mlx.Ffi.SymShape.opOutSym s o p ins) := by
  unfold Host.Mlx.Ffi.SymShape.opOutSym
  repeat' (first
    | with_reducible refine AllX.bind' (Host.Load.LayerLift.inferSym_l _ _) fun _ => ?_
    | keep_base)

/-- The symbolic-shape layer keeps the model's objects. -/
theorem symShapeCall_k (s : St) (name : Name) (args : List Arg) :
    AllX (KRes s) (Host.Mlx.Ffi.SymShape.symShapeCall s name args) := by
  unfold Host.Mlx.Ffi.SymShape.symShapeCall
  split
  · split
    · refine AllX.cond _ (AllX.bind' (Host.Ts.Sim.NativeLawful.dProd_l _) fun d => ?_) AllX_stuck
      cases d <;> exact AllX_ok (Keep.refl s)
    · exact AllX_stuck
  · split
    · exact opOutSym_k (Keep.refl s) _ _ _
    · exact AllX_stuck
  · split
    · exact opOutSym_k (Keep.refl s) _ _ _
    · exact AllX_stuck
  · exact AllX_stuck

/-- The model's call completed by the layer keeps the model's objects. -/
theorem callSym_k (s : St) (name : Name) (args : List Arg) :
    AllX (KRes s) (Host.Mlx.Ffi.SymShape.callSym s name args) := by
  unfold Host.Mlx.Ffi.SymShape.callSym
  refine AllX.bind (Host.Ts.Sim.NativeLawful.mlx_call_l _ _ _) (call_k s name args) fun o ho => ?_
  rcases o with _ | r
  · exact symShapeCall_k s name args
  · exact AllX.pure ho

end Host.Mlx.Ffi.FullKeep

namespace Host.Ts.Sim.Full
open Host.Ts Host.Ts.Sim Host.Load.Layers
open Host.Mlx.Ffi.FullKeep (Keep AllX KRes)
open Host.Ts.Sim.BufSim (Lawful)
open Host.Mlx.Ffi.SymShape (callSym symShapeCall)

/-! ## The load world's call completed by the layer -/

/-- The load world's mlx call completed by the symbolic-shape layer. -/
def loadCallSym (l : Host.Load.LSt) (name : Name) (args : List Arg) : Host.Ts.M (Res Host.Load.LSt) :=
  Host.Ts.M.bind (callSym l.mlx name args) fun
    | some (m, r, ws) => Host.Ts.M.pure (some ({ l with mlx := m }, r, ws))
    | none => Host.Ts.M.pure none

theorem callSym_l (s : Host.Mlx.Ffi.St) (name : Name) (args : List Arg) : Lawful (callSym s name args) := by
  unfold callSym
  refine BufSim.Lawful.bind (NativeLawful.mlx_call_l _ _ _) fun o => ?_
  rcases o with _ | r
  · exact Host.Load.LayerLift.symShapeCall_l _ _ _
  · exact BufSim.Lawful.pure _

theorem loadCallSym_l (l : Host.Load.LSt) (name : Name) (args : List Arg) : Lawful (loadCallSym l name args) := by
  unfold loadCallSym
  refine BufSim.Lawful.bind (callSym_l _ _ _) fun o => ?_
  rcases o with _ | ⟨m, r, ws⟩ <;> exact BufSim.Lawful.pure _

theorem loadCallSym_keep (x : Host.Load.LSt) (name : Name) (args : List Arg) :
    AllX (fun o => ∀ l r ws, o = some (l, r, ws) → Keep x.mlx l.mlx) (loadCallSym x name args) := by
  unfold loadCallSym
  refine Host.Mlx.Ffi.FullKeep.AllX.bind (callSym_l _ _ _) (Host.Mlx.Ffi.FullKeep.callSym_k _ _ _) fun o ho => ?_
  rcases o with _ | ⟨m, r, ws⟩
  · exact Host.Mlx.Ffi.FullKeep.AllX.pure fun _ _ _ e => by cases e
  · exact Host.Mlx.Ffi.FullKeep.AllX.pure fun _ _ _ e => by cases e; exact ho _ rfl

/-- **Lift** of the layer's completed calls to the load world. -/
theorem mlx_liftS {P : LoadP} {NB : Nat} {M : Map} {ν : Nat → F64} {S : SSrv} {C : CSrv} {x y : Host.Load.LSt}
    {name : Name} {args args' : List Arg} (hr : G.LoadR P NB M S.tab.length x y)
    (h : MSim (G.MPost P NB M ν S C) S C (callSym x.mlx name args) (callSym y.mlx name args')) :
    MSim (G.LPost P NB M ν S C) S C (loadCallSym x name args) (loadCallSym y name args') := by
  unfold loadCallSym
  refine MSim.bind h fun M' S' C' a b hab => ?_
  obtain ⟨hg, hc⟩ := hab
  cases a with
  | none =>
    cases b with
    | none => exact MSim.pure ⟨hg, trivial⟩
    | some q => obtain ⟨_, _, _⟩ := q; exact MSim.pure ⟨hg, trivial⟩
  | some p =>
    obtain ⟨m, r, ws⟩ := p
    cases b with
    | none => exact hc.elim
    | some q =>
      obtain ⟨m', r', ws'⟩ := q
      obtain ⟨hmr, hr', hws⟩ := hc
      refine MSim.pure ⟨hg, ⟨?_, hr', hws⟩⟩
      exact ⟨hr.host, fun k hk => by rw [hg.ext.region]; exact hr.hostReg k hk, hr.hostLt,
        fun a => by rw [hg.ext.region, hg.ext.a]; exact hr.cbr a, hmr⟩

/-- A load-world result with the start's bridge. -/
def addB (p : FF.S) : Res Host.Load.LSt → Res Host.Load.Ane.ASt
  | some (l, r, ws) => some (⟨l, bridgeOf p⟩, r, ws)
  | none => none

/-- **With the bridge inactive, an mlx call other than a wrap is the model's call completed by the
symbolic-shape layer, followed by the observers.** -/
theorem full_call_sym (p : FF.S) (name : Name) (args : List Arg) (hm : Host.Load.isMlx name = true)
    (hp : nameEq name Host.Mlx.FfiAne.payloadName = false) (ha : (bridgeOf p).active = false) :
    FF.call p name args =
      Host.Ts.M.bind (loadCallSym (toLoad p) name args) fun o => Host.Ts.M.pure (liftF p name args (addB p o)) := by
  rw [full_call_mlx p name args hm hp ha, Host.Load.call_mlx _ _ _ hm]
  unfold loadCallSym callSym fullCont
  simp only [G.mbind_assoc]
  congr 1
  funext o
  rcases o with _ | ⟨m, r, ws⟩
  · simp only [G.mbind_pure, symK, G.mbind_assoc]
    congr 1
    funext q
    rcases q with _ | ⟨m', r', ws'⟩ <;> rfl
  · rfl

/-! ## The simulation -/

theorem keepS_of_run {x : Host.Load.LSt} {name : Name} {args : List Arg} {S S' : SSrv} {l : Host.Load.LSt}
    {r : Ret} {ws : List (Nat × Nat × List Byte)}
    (h : interpS (loadCallSym x name args).run S = some (some (l, r, ws), S')) : Keep x.mlx l.mlx :=
  (loadCallSym_keep x name args).1 S _ S' h l r ws rfl

theorem keepS_of_runC {x : Host.Load.LSt} {name : Name} {args : List Arg} {C C' : CSrv} {l : Host.Load.LSt}
    {r : Ret} {ws : List (Nat × Nat × List Byte)}
    (h : interpC (loadCallSym x name args).run C = some (some (l, r, ws), C')) : Keep x.mlx l.mlx :=
  (loadCallSym_keep x name args).2 C _ C' h l r ws rfl

theorem symShapeOk_sym {P : LoadP} {x : NSt} {name : Name} {args : List Arg}
    (h : G.symShapeOk P x name args = true) :
    Host.Mlx.Ffi.symOf name = some .conv1d ∨ Host.Mlx.Ffi.symOf name = some .reshape := by
  unfold G.symShapeOk at h
  split at h
  · rename_i hs; exact .inl hs
  · rename_i hs; exact .inr hs
  · cases h

/-- **The calls the symbolic-shape layer completes, simulated.** -/
theorem fullCallSymSim {P : LoadP} {NB : Nat} {M : Map} {ν : Nat → F64} {S : SSrv} {C : CSrv} {x y : FF.S}
    {name : Name} {args : List Arg} (hsrv : Srv M ν S C) (hr : FullR P NB M S.tab.length x y)
    (hm : Host.Load.isMlx name = true) (hp : nameEq name Host.Mlx.FfiAne.payloadName = false)
    (hact : (bridgeOf x).active = false) (hok : G.symShapeOk P (mlxOf x) name args = true)
    (hobs : obsOk (mlxOf x) name args = true) (hsupp : ∀ a ∈ args, Supp.arg (fun _ => True) S.tab.length a)
    (hsm : G.symShapeSmall ν S (mlxOf x) name args) :
    MSim (fun M' S' C' r r' => Grow M ν S C M' S' C' ∧ CallR (F := FF) (FullR P NB) M' S'.tab.length r r') S C
      (FF.call x name args) (FF.call y name (args.map M.arg)) := by
  have hacty : (bridgeOf y).active = false := by rw [hr.bridge.1]; exact hact
  rw [full_call_sym x name args hm hp hact, full_call_sym y name _ hm hp hacty]
  have hg := mlx_liftS hr.load (G.mlx_simSS hsrv hr.load.mlx args hok hsm)
  have hg2 := MSim.both hg (loadCallSym_l _ _ _) (loadCallSym_l _ _ _)
  refine MSim.bind hg2 fun M' S' C' a b hab => ?_
  obtain ⟨⟨hgr, hcr⟩, hra, hrb⟩ := hab
  have hs := symShapeOk_sym hok
  rcases a with _ | ⟨l, r, ws⟩
  · exact MSim.pure ⟨hgr, trivial⟩
  · rcases b with _ | ⟨l', r', ws'⟩
    · exact hcr.elim
    · refine full_some_post hr hgr hcr (keepS_of_run hra) (keepS_of_runC hrb) hobs hsupp ?_ ?_ ?_ ?_
      · intro s' hs'
        rcases hs with e | e <;> rw [e] at hs' <;> cases hs' <;>
          exact ⟨(fun h => nomatch h), (fun h => by rcases h with h | h | h <;> cases h)⟩
      · intro hs'
        rcases hs with e | e <;> rw [e] at hs' <;> cases hs'
      · intro hs'
        rcases hs with e | e <;> rw [e] at hs' <;> cases hs'
      · intro hs'
        rcases hs with e | e <;> rw [e] at hs' <;> cases hs'

/-! ## The full world's acceptance with the layer's calls -/

/-- The compiled-closure calls (`G.NativeOkX.clo`): `mlx_vector_array_set_data` into a pending
trace's result, a trace recording, a closure's life and the kernels' name vectors. -/
def cloOk (P : LoadP) (x : NSt) (name : Name) (args : List Arg) : Bool :=
  match Host.Mlx.Ffi.symOf name with
  | some s => G.NativeOkX.clo P x s args
  | none => false

/-- **The compiled-closure calls in the full world**: the pending traces' regions are the
relation's (`FullR.pend`). -/
theorem fullCloSim {P : LoadP} {NB : Nat} {M : Map} {ν : Nat → F64} {S : SSrv} {C : CSrv} {x y : FF.S}
    {name : Name} {args : List Arg} (hsrv : Srv M ν S C) (hr : FullR P NB M S.tab.length x y)
    (hm : Host.Load.isMlx name = true) (hp : nameEq name Host.Mlx.FfiAne.payloadName = false)
    (hact : (bridgeOf x).active = false) (hok : cloOk P (mlxOf x) name args = true)
    (hobs : obsOk (mlxOf x) name args = true) (hsupp : ∀ a ∈ args, Supp.arg (fun _ => True) S.tab.length a) :
    MSim (fun M' S' C' r r' => Grow M ν S C M' S' C' ∧ CallR (F := FF) (FullR P NB) M' S'.tab.length r r') S C
      (FF.call x name args) (FF.call y name (args.map M.arg)) := by
  unfold cloOk at hok
  split at hok
  · rename_i sy hsym
    have hg := G.mlx_lift hr.load hm (G.sim_clo hsrv hr.load.mlx hsym hok hsupp hr.pend)
    have hkl := G.NativeOkX.clo_kern hok
    obtain ⟨n1, n2, n3, n4, -, n6, n7, n8⟩ := G.NativeOkX.clo_not hok
    have hss : isSymShape name = false := by
      unfold isSymShape; rw [hsym]; cases sy <;> first | rfl | contradiction
    refine fullCallOf hr hm hp hact hobs hsupp ?_ ?_ (fun h => by rw [hss] at h; cases h) hg
    · intro s hs; rw [hsym] at hs; cases hs
      exact ⟨hkl, fun h => by rcases h with rfl | rfl | rfl <;> contradiction⟩
    · intro hs; rw [hsym] at hs; cases hs; exact absurd rfl n4
  · cases hok

/-- **The accepted calls** with the bridge inactive: the calls the layer completes by `G.symShapeOk`,
the others by `okCallSX` (the forward's operations over symbolic shapes). -/
def okCallFS (P : LoadP) (x : FF.S) (name : Name) (args : List Arg) : Bool :=
  Host.Load.isMlx name && !nameEq name Host.Mlx.FfiAne.payloadName && !(bridgeOf x).active &&
    (bif G.symPath (mlxOf x) name args then G.symShapeOk P (mlxOf x) name args
      else G.okCallSX P (toLoad x) name args || cloOk P (mlxOf x) name args) && obsOk (mlxOf x) name args

/-- **The numeric premise**, by the same split. -/
def smallFS (ν : Nat → F64) (S : SSrv) (x : FF.S) (name : Name) (args : List Arg) : Prop :=
  (G.symPath (mlxOf x) name args = true → G.symShapeSmall ν S (mlxOf x) name args) ∧
    (G.symPath (mlxOf x) name args = false → smallFX ν S x name args)

/-- The decider of `smallFS` (irreducible, as `smallFB`). -/
@[irreducible] def smallFSB (VB : Nat → Nat) (S : SSrv) (x : FF.S) (name : Name) (args : List Arg) : Bool :=
  bif G.symPath (mlxOf x) name args then G.symShapeSmallB VB S (mlxOf x) name args else smallFXB VB S x name args

theorem smallFSB_sound {VB : Nat → Nat} {ν : Nat → F64} {S : SSrv} {x : FF.S} {name : Name} {args : List Arg}
    (hν : ∀ v, ∃ k ≤ VB v, ν v = F64.ofNat k) (h : smallFSB VB S x name args = true) : smallFS ν S x name args := by
  unfold smallFSB at h
  constructor
  · intro hp; rw [hp, Bool.cond_true] at h; exact G.symShapeSmallB_sound h hν
  · intro hp; rw [hp, Bool.cond_false] at h; exact smallFXB_sound hν h

/-- **The full world's native-call simulation** with the calls the symbolic-shape layer completes and
the forward's operations over symbolic shapes, the bridge inactive. -/
theorem fullCallSimS (P : LoadP) (NB : Nat) : FfiCallSim FF (FullR P NB) (okCallFS P) smallFS where
  call := by
    intro M ν S C x y name args hsrv hr hok hsupp hsm
    cases hpath : G.symPath (mlxOf x) name args
    · unfold okCallFS at hok
      rw [hpath, Bool.cond_false] at hok
      simp only [Bool.and_eq_true, Bool.or_eq_true, Bool.not_eq_true'] at hok
      obtain ⟨⟨⟨⟨hm, hp⟩, hact⟩, hsx | hvs⟩, hobs⟩ := hok
      · have hok' : okCallFX P x name args = true := by
          unfold okCallFX; simp only [hm, hp, hact, hsx, hobs, Bool.not_false, Bool.and_self]
        exact (fullCallSimX P NB).call M ν S C x y name args hsrv hr hok' hsupp (hsm.2 hpath)
      · exact fullCloSim hsrv hr hm hp hact hvs hobs hsupp
    · unfold okCallFS at hok
      rw [hpath] at hok
      simp only [Bool.cond_true, Bool.and_eq_true, Bool.not_eq_true'] at hok
      obtain ⟨⟨⟨⟨hm, hp⟩, hact⟩, hsk⟩, hobs⟩ := hok
      exact fullCallSymSim hsrv hr hm hp hact hsk hobs hsupp (hsm.1 hpath)

theorem symShapeOk_rest (P : LoadP) (r : List NumV) : G.symShapeOk { P with rest := r } = G.symShapeOk P := by
  funext x name args
  unfold G.symShapeOk
  split <;> rfl

theorem cloOk_rest (P : LoadP) (r : List NumV) : cloOk { P with rest := r } = cloOk P := by
  funext x name args
  unfold cloOk
  split
  · unfold G.NativeOkX.clo
    split
    · unfold G.NativeOkX.vset
      split <;> rfl
    · unfold G.NativeOkX.clRecord
      split <;> rfl
    · unfold G.NativeOkX.life
      split <;> rfl
  · rfl

theorem okCallFS_rest (P : LoadP) (r : List NumV) : okCallFS { P with rest := r } = okCallFS P := by
  funext x name args
  unfold okCallFS
  rw [G.okCallSX_rest, symShapeOk_rest, cloOk_rest]

end Host.Ts.Sim.Full
