import host.sim.full.BridgeWrap

/-! # The full world's native calls with the Neural Engine bridge

`fullCallSimX2`: the full world's native-call simulation for `FullRX` (the bridge inactive and equal, or
active under the map). A surface wrap (`okCallFW`) starts or continues the active relation
(`fullWrapSim`). Otherwise, with the bridge inactive, it is `fullCallSimS`'s. With the bridge active,
for a band-free `P` (every node fully corresponds), the accepted calls (`okCallFA`) are the MLX calls the
load world's simulations accept (`G.okCallSX`, the compiled-closure calls `cloOk`) under the bridge's
checks (`afterOk`), and the bridge's own calls (`bridgeOp`); the numeric premise (`smallFA`) adds, for
the three calls the symbolic-shape layer completes, that the template's Neural Engine world runs them
(decided by evaluation, `aneRunOk`). -/

namespace Host.Ts.Sim.Full
open Host.Ts Host.Ts.Sim Host.Load.Layers

/-- **The accepted surface wraps**: the bridge active, or clean with the template's nodes present. -/
def okCallFW (P : LoadP) (x : FF.S) (name : Name) (args : List Arg) : Bool :=
  Host.Load.isMlx name && nameEq name Host.Mlx.FfiAne.payloadName && (Host.Mlx.Ffi.symOf name).isNone &&
    wrapOk P (mlxOf x) args && ((bridgeOf x).active || (bridgeClean (bridgeOf x) && denseB (mlxOf x)))

/-- **The accepted calls with the bridge active.** -/
def okCallFA (P : LoadP) (x : FF.S) (name : Name) (args : List Arg) : Bool :=
  (bridgeOf x).active && decide (P.NL = P.N0) &&
    ((Host.Load.isMlx name && !nameEq name Host.Mlx.FfiAne.payloadName &&
        (G.okCallSX P (toLoad x) name args || cloOk P (mlxOf x) name args) && obsOk (mlxOf x) name args &&
        afterOk (bridgeOf x) (mlxOf x) name args) ||
      (!Host.Load.isMlx name && !nameEq name chars!"mbane_program_create" && (Host.Mlx.Ffi.symOf name).isNone &&
        (bridgeOp name args).isSome && bridgeOpOk P name args))

/-- **The accepted calls with the bridge inactive or active.** -/
def okCallFX2 (P : LoadP) (x : FF.S) (name : Name) (args : List Arg) : Bool :=
  okCallFW P x name args || bif (bridgeOf x).active then okCallFA P x name args else okCallFS P x name args

/-- The template's Neural Engine world's run of a call has a result (where it runs). -/
@[irreducible] def aneRunOk (S : SSrv) (x : FF.S) (name : Name) (args : List Arg) : Bool :=
  match interpS (Host.Load.Ane.call x.1.1 name args).run S with
  | some (a, _) => a.isSome
  | none => true

theorem aneRunOk_sound {S : SSrv} {x : FF.S} {name : Name} {args : List Arg} (h : aneRunOk S x name args = true) :
    ∀ a S', interpS (Host.Load.Ane.call x.1.1 name args).run S = some (a, S') → a.isSome = true := by
  intro a S' ha
  unfold aneRunOk at h
  rw [ha] at h
  exact h

/-- The numeric premise with the bridge active. -/
def smallFA (ν : Nat → F64) (S : SSrv) (x : FF.S) (name : Name) (args : List Arg) : Prop :=
  smallFX ν S x name args ∧ (isSymShape name = true → aneRunOk S x name args = true)

/-- **The numeric premise with the bridge inactive or active.** -/
def smallFX2 (ν : Nat → F64) (S : SSrv) (x : FF.S) (name : Name) (args : List Arg) : Prop :=
  ((bridgeOf x).active = false → smallFS ν S x name args) ∧ ((bridgeOf x).active = true → smallFA ν S x name args)

/-- The decider of `smallFX2`. -/
@[irreducible] def smallFX2B (VB : Nat → Nat) (S : SSrv) (x : FF.S) (name : Name) (args : List Arg) : Bool :=
  bif (bridgeOf x).active then smallFXB VB S x name args && (!isSymShape name || aneRunOk S x name args)
  else smallFSB VB S x name args

theorem smallFX2B_sound {VB : Nat → Nat} {ν : Nat → F64} {S : SSrv} {x : FF.S} {name : Name} {args : List Arg}
    (hν : ∀ v, ∃ k ≤ VB v, ν v = F64.ofNat k) (h : smallFX2B VB S x name args = true) : smallFX2 ν S x name args := by
  unfold smallFX2B at h
  constructor
  · intro ha; rw [ha, Bool.cond_false] at h; exact smallFSB_sound hν h
  · intro ha
    rw [ha, Bool.cond_true, Bool.and_eq_true] at h
    refine ⟨smallFXB_sound hν h.1, fun hs => ?_⟩
    have := h.2
    rw [hs] at this
    simpa using this

/-- **An MLX call with the bridge active**, accepted by the load world's simulations. -/
theorem fullCallSimA_mlx {P : LoadP} {NB : Nat} {M : Map} {ν : Nat → F64} {S : SSrv} {C : CSrv} {x y : FF.S}
    {name : Name} {args : List Arg} (hsrv : Srv M ν S C) (hr : FullRX P NB M S.tab.length x y) (hF : ∀ i, Full P i)
    (hm : Host.Load.isMlx name = true) (hp : nameEq name Host.Mlx.FfiAne.payloadName = false)
    (hact : (bridgeOf x).active = true)
    (hok : (G.okCallSX P (toLoad x) name args || cloOk P (mlxOf x) name args) = true)
    (hobs : obsOk (mlxOf x) name args = true) (haft : afterOk (bridgeOf x) (mlxOf x) name args = true)
    (hsupp : ∀ a ∈ args, Supp.arg (fun _ => True) S.tab.length a) (hsm : smallFA ν S x name args) :
    MSim (fun M' S' C' r r' => Grow M ν S C M' S' C' ∧ CallR (F := FF) (FullRX P NB) M' S'.tab.length r r') S C
      (FF.call x name args) (FF.call y name (args.map M.arg)) := by
  have hsA : isSymShape name = true → ∀ a S', interpS (Host.Load.Ane.call x.1.1 name args).run S = some (a, S') →
      a.isSome = true := fun hs => aneRunOk_sound (hsm.2 hs)
  rw [Bool.or_eq_true] at hok
  rcases hok with hsx | hcl
  · exact fullCallOfA hr hF hm hp hact haft hobs hsupp (kernAccX_of hsx) (arrAccX_of hsx) hsA
      ((G.loadFfiCallSimX P NB).call M ν S C (toLoad x) (toLoad y) name args hsrv hr.load hsx hsupp hsm.1.1)
  · unfold cloOk at hcl
    split at hcl
    · rename_i sy hsym
      have hg := G.mlx_lift hr.load hm (G.sim_clo hsrv hr.load.mlx hsym hcl hsupp hr.pend)
      have hkl := G.NativeOkX.clo_kern hcl
      obtain ⟨n1, n2, n3, n4, -, n6, n7, n8⟩ := G.NativeOkX.clo_not hcl
      have hss : isSymShape name = false := by
        unfold isSymShape; rw [hsym]; cases sy <;> first | rfl | contradiction
      refine fullCallOfA hr hF hm hp hact haft hobs hsupp ?_ ?_ (fun h => by rw [hss] at h; cases h) hg
      · intro s hs; rw [hsym] at hs; cases hs
        exact ⟨hkl, fun h => by rcases h with rfl | rfl | rfl <;> contradiction⟩
      · intro hs; rw [hsym] at hs; cases hs; exact absurd rfl n4
    · cases hcl

/-- **The full world's native-call simulation with the Neural Engine bridge.** -/
theorem fullCallSimX2 (P : LoadP) (NB : Nat) : FfiCallSim FF (FullRX P NB) (okCallFX2 P) smallFX2 where
  call := by
    intro M ν S C x y name args hsrv hr hok hsupp hsm
    unfold okCallFX2 at hok
    rw [Bool.or_eq_true] at hok
    rcases hok with hw | hok
    · simp only [okCallFW, Bool.and_eq_true, Bool.or_eq_true] at hw
      obtain ⟨⟨⟨⟨hm, hp⟩, hsym⟩, hwk⟩, hst⟩ := hw
      exact fullWrapSim hsrv hr hm hp (Option.isNone_iff_eq_none.mp hsym) hwk hst
    cases hact : (bridgeOf x).active
    · rw [hact, Bool.cond_false] at hok
      refine MSim.mono ((fullCallSimS P NB).call M ν S C x y name args hsrv (hr.toR hact) hok hsupp (hsm.1 hact)) ?_
      intro M' S' C' r r' h
      obtain ⟨hg, hc⟩ := h
      refine ⟨hg, ?_⟩
      rcases r with _ | ⟨x', r1, ws⟩ <;> rcases r' with _ | ⟨y', r2, ws'⟩
      · trivial
      · trivial
      · exact hc
      · exact ⟨hc.1.toX, hc.2⟩
    · rw [hact, Bool.cond_true] at hok
      unfold okCallFA at hok
      simp only [Bool.and_eq_true, Bool.or_eq_true, decide_eq_true_eq, Bool.not_eq_true'] at hok
      obtain ⟨⟨-, hb⟩, hok⟩ := hok
      have hF : ∀ i, Full P i := fun i => by show i < P.NL ∨ P.N0 ≤ i; omega
      rcases hok with ⟨⟨⟨⟨hm, hp⟩, hsx⟩, hobs⟩, haft⟩ | ⟨⟨⟨⟨hm, hc⟩, hsym⟩, hop⟩, hok⟩
      · exact fullCallSimA_mlx hsrv hr hF hm hp hact (by rw [Bool.or_eq_true]; exact hsx) hobs haft hsupp (hsm.2 hact)
      · obtain ⟨⟨h, F⟩, hb⟩ := Option.isSome_iff_exists.mp hop
        exact fullOpSim hsrv hr hact hm hc (Option.isNone_iff_eq_none.mp hsym) hok hb

end Host.Ts.Sim.Full
