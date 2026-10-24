import host.sim.full.BridgeCall
import host.sim.full.World

/-! # The target's bridge framed

A template whose Neural Engine bridge is inactive (the decode template, from a short prompt) runs
against targets whose bridge is inactive or active (after a Neural Engine prefill). The decode route
never calls the bridge (its acceptance takes only MLX calls other than a wrap), so its relation frames
the target's bridge instead of relating it (`BridgeF`): inactive, or `Quiet` — nothing scheduled or
running, and no alias at the images of the template's nodes, every alias below the target's counter.
Then the bridge's update after every MLX call the template's run relates is the identity
(`after_quiet`): the evaluations schedule nothing, and the new nodes, images of the template's whose
inputs are images, register nothing. The relation is `FullRF`, its world `fullWorldF` (the restart
with the bridge kept by the shift, `shiftComp_F`). -/

namespace Host.Ts.Sim.Full
open Host.Ts Host.Ts.Sim Host.Load.Layers
open Host.Mlx.Ffi.FullKeep (Keep)

/-- **A quiet bridge** for the template's node map: nothing scheduled or running, no alias at the images
of the template's nodes below its counter `x.nnext`, every alias below the target's counter. -/
structure Quiet (M : Map) (x y : NSt) (b : BSt) : Prop where
  unscheduled : b.unscheduled = []
  running : b.running = []
  img : ∀ j, j < x.nnext → b.aliases.get (M.node j) = none
  bound : ∀ m, (b.aliases.get m).isSome = true → m < y.nnext

/-- **The target's bridge framed**: the template's inactive, the target's inactive or quiet. -/
def BridgeF (M : Map) (x y : FF.S) : Prop :=
  (bridgeOf x).active = false ∧ ((bridgeOf y).active = false ∨ Quiet M (mlxOf x) (mlxOf y) (bridgeOf y))

/-- **The full world's native relation with the target's bridge framed.** -/
abbrev FullRF : LoadP → Nat → Map → Nat → FF.S → FF.S → Prop := FullRB BridgeF

/-- `FullRF` with the target's remaining readbacks `r`. -/
abbrev FLRF (P : LoadP) (NB : Nat) (r : List NumV) : Map → Nat → FF.S → FF.S → Prop :=
  FullRF { P with rest := r } NB

theorem Quiet.names {M M' : Map} {x y : NSt} {b : BSt} (h : Quiet M x y b) (hn : M'.node = M.node) :
    Quiet M' x y b :=
  { h with img := fun j hj => by rw [hn]; exact h.img j hj }

theorem bridgeF_names : BridgeNames BridgeF := fun _ _ _ _ h hn =>
  ⟨h.1, h.2.imp id fun hq => hq.names hn⟩

theorem bridgeF_push : BridgePush BridgeF := fun _ _ _ _ _ h =>
  ⟨h.1, h.2.imp id fun hq => ⟨hq.unscheduled, hq.running, hq.img, hq.bound⟩⟩

/-- The shift keeping the template's bridge composes with the frame. -/
theorem shiftComp_F : ShiftComp BSI BridgeF := fun σ M x0 x1 z hs hall hb => by
  have hs' : bridgeOf x1 = bridgeOf x0 := hs
  refine ⟨by rw [← hs']; exact hb.1, hb.2.imp id fun hq => ?_⟩
  exact { hq with img := fun j hj => hq.img (σ.node j) (hall j hj) }

theorem BridgeI.toF {M : Map} {x y : FF.S} (h : BridgeI M x y) : BridgeF M x y :=
  ⟨h.2, .inl (by rw [h.1]; exact h.2)⟩

theorem FullR.toF {P : LoadP} {NB : Nat} {M : Map} {n : Nat} {x y : FF.S} (h : FullR P NB M n x y) :
    FullRF P NB M n x y :=
  h.mapBridge BridgeI.toF

/-- **The full world with the target's bridge framed.** -/
def fullWorldF (NB : Nat) : World :=
  fullWorldB BridgeF BSI FullShift bridgeF_names shiftComp_F (fun _ _ _ _ _ h => h.toB) bridgeF_push NB

theorem fullWorldF_end (NB : Nat) : (fullWorldF NB).EndLaws :=
  fullWorldB_end bridgeF_names shiftComp_F (fun _ _ _ _ _ h => h.toB) bridgeF_push NB

/-! ## The target's bridge pinned

The frame with the target's bridge fixed to `b0` (`BridgeFb`): the decode route keeps the target's
bridge exactly (every accepted call's update is the identity), so its relation can pin it, and the
Neural Engine memory, which reads only the bridge's log, is the hand-off's along decode. -/

/-- The frame with the target's bridge `b0`. -/
def BridgeFb (b0 : BSt) (M : Map) (x y : FF.S) : Prop := BridgeF M x y ∧ bridgeOf y = b0

/-- **The full world's native relation with the target's bridge framed and pinned to `b0`.** -/
abbrev FullRFb (b0 : BSt) : LoadP → Nat → Map → Nat → FF.S → FF.S → Prop := FullRB (BridgeFb b0)

theorem bridgeFb_names (b0 : BSt) : BridgeNames (BridgeFb b0) := fun M M' x y h hn =>
  ⟨bridgeF_names M M' x y h.1 hn, h.2⟩

theorem bridgeFb_push (b0 : BSt) : BridgePush (BridgeFb b0) := fun M x y n w h => ⟨bridgeF_push M x y n w h.1, h.2⟩

theorem shiftComp_Fb (b0 : BSt) : ShiftComp BSI (BridgeFb b0) := fun σ M x0 x1 z hs hall hb =>
  ⟨shiftComp_F σ M x0 x1 z hs hall hb.1, hb.2⟩

theorem FullRF.pin {P : LoadP} {NB : Nat} {M : Map} {n : Nat} {x y : FF.S} (h : FullRF P NB M n x y) :
    FullRFb (bridgeOf y) P NB M n x y :=
  h.mapBridge fun hb => ⟨hb, rfl⟩

/-- The pinned target bridge is the same at every cut, its log in particular (`aneDec_keep`). -/
theorem BridgeFb.log_keep {b0 : BSt} {M M' : Map} {x y x' y' : FF.S} (h : BridgeFb b0 M x y) (h' : BridgeFb b0 M' x' y') :
    (bridgeOf y').log = (bridgeOf y).log := by
  rw [h'.2, h.2]

/-- **The full world with the target's bridge framed and pinned to `b0`.** -/
def fullWorldFb (b0 : BSt) (NB : Nat) : World :=
  fullWorldB (BridgeFb b0) BSI FullShift (bridgeFb_names b0) (shiftComp_Fb b0) (fun _ _ _ _ _ h => h.toB)
    (bridgeFb_push b0) NB

theorem fullWorldFb_end (b0 : BSt) (NB : Nat) : (fullWorldFb b0 NB).EndLaws :=
  fullWorldB_end (bridgeFb_names b0) (shiftComp_Fb b0) (fun _ _ _ _ _ h => h.toB) (bridgeFb_push b0) NB

/-! ## The bridge's update is the identity -/

section
variable {b : BSt}

theorem aliasIns_nil : ∀ {ins : List Nat}, (∀ i ∈ ins, b.aliases.get i = none) → Host.Mlx.FfiAne.aliasIns b ins = []
  | [], _ => rfl
  | i :: is, h => by
    unfold Host.Mlx.FfiAne.aliasIns
    rw [show Host.Mlx.FfiAne.St.aliasOf b i = none from h i (List.mem_cons_self ..)]
    exact aliasIns_nil fun j hj => h j (List.mem_cons_of_mem _ hj)

theorem classifyNode_nil {s : Host.Mlx.Ffi.St} {n : Nat}
    (h : ∀ nd, s.nodes.get n = some nd → ∀ i ∈ nd.ins, b.aliases.get i = none) :
    Host.Mlx.FfiAne.classifyNode b s n = some b := by
  unfold Host.Mlx.FfiAne.classifyNode
  cases hn : s.nodes.get n with
  | none => rfl
  | some nd => dsimp only; rw [aliasIns_nil (h nd hn)]

theorem classify_nil {s : Host.Mlx.Ffi.St} :
    ∀ (f n : Nat), (∀ m, n ≤ m → m < n + f → m < s.nnext → ∀ nd, s.nodes.get m = some nd →
      ∀ i ∈ nd.ins, b.aliases.get i = none) → Host.Mlx.FfiAne.classify b s f n = some b
  | 0, _, _ => rfl
  | f + 1, n, h => by
    unfold Host.Mlx.FfiAne.classify
    cases hlt : Nat.blt n s.nnext
    · rfl
    · rw [Bool.cond_true]
      have hl : n < s.nnext := by rw [Nat.blt_eq] at hlt; exact hlt
      rw [classifyNode_nil (h n (Nat.le_refl _) (by omega) hl), Option.bind_some]
      exact classify_nil f (n + 1) fun m h1 h2 h3 => h m (by omega) (by omega) h3

theorem schedule_quiet (hu : b.unscheduled = []) (hrun : b.running = []) (s : Host.Mlx.Ffi.St) (ns : List Nat)
    (bl : Bool) : Host.Mlx.FfiAne.schedule b s ns bl = some b := by
  unfold Host.Mlx.FfiAne.schedule
  rw [hu, hrun]
  cases bl <;> rfl

end

/-- **The bridge's update after a related call is the identity** on a quiet bridge: the template's new
nodes present (`Keep`), the native relations before and after. -/
theorem after_quiet {P : LoadP} {NB : Nat} {M M' : Map} {n n' : Nat} {x y x' y' : NSt} {b : BSt}
    (hr : G.MR P NB M n x y) (hr' : G.MR P NB M' n' x' y') (hn : M'.node = M.node) (kx : Keep x x')
    (hq : Quiet M x y b) (name : Name) (args : List Arg) :
    Host.Mlx.FfiAne.after b y y' name args = some b := by
  unfold Host.Mlx.FfiAne.after
  cases Host.Mlx.FfiAne.evalCall y name args with
  | roots ns bl => exact schedule_quiet hq.unscheduled hq.running y ns bl
  | all =>
    show some { b with running := [] } = some b
    have := hq.running
    cases b; cases this; rfl
  | other =>
    show Host.Mlx.FfiAne.classify b y' (y'.nnext - y.nnext) y.nnext = some b
    have hxx := kx.nnext
    have hY : y'.nnext = y.nnext + (x'.nnext - x.nnext) := by
      have e1 := hr'.nfresh 0
      have e0 := hr.nfresh (x'.nnext - x.nnext)
      rw [hn] at e1
      simp only [Nat.add_zero] at e1
      rw [show x.nnext + (x'.nnext - x.nnext) = x'.nnext by omega, e1] at e0
      exact e0
    refine classify_nil _ _ fun m h1 h2 h3 nd hnd i hi => ?_
    obtain ⟨k, rfl⟩ : ∃ k, m = y.nnext + k := ⟨m - y.nnext, by omega⟩
    have hk : x.nnext + k < x'.nnext := by omega
    have hpx : (x'.nodes.get (x.nnext + k)).isSome = true :=
      kx.dense _ (Nat.le_add_right _ _) hk (by have := hr'.xnnext_lt; omega)
    obtain ⟨nd0, hnd0⟩ := Option.isSome_iff_exists.mp hpx
    obtain ⟨nd', h1', -, -, -, hf⟩ := hr'.nodes _ nd0 hnd0
    have hF : Full P (x.nnext + k) := by
      show x.nnext + k < P.NL ∨ P.N0 ≤ x.nnext + k
      have := hr.nband; omega
    obtain ⟨-, hins⟩ := hf hF
    have hm : M'.node (x.nnext + k) = y.nnext + k := by rw [hn]; exact hr.nfresh k
    rw [hm, hnd] at h1'
    cases h1'
    rw [hins] at hi
    obtain ⟨j, -, rfl⟩ := List.mem_map.mp hi
    rw [hn]
    by_cases hj : j < x.nnext
    · exact hq.img j hj
    · have e : M.node j = y.nnext + (j - x.nnext) := by
        have := hr.nfresh (j - x.nnext); rwa [show x.nnext + (j - x.nnext) = j by omega] at this
      rw [e]
      cases hg : b.aliases.get (y.nnext + (j - x.nnext)) with
      | none => rfl
      | some _ => have := hq.bound _ (by rw [hg]; rfl); omega

/-- A quiet bridge stays quiet along a related call. -/
theorem Quiet.step {P : LoadP} {NB : Nat} {M M' : Map} {n : Nat} {x y x' y' : NSt} {b : BSt}
    (hr : G.MR P NB M n x y) (hn : M'.node = M.node) (ky : Keep y y') (hq : Quiet M x y b) : Quiet M' x' y' b where
  unscheduled := hq.unscheduled
  running := hq.running
  img j hj := by
    rw [hn]
    by_cases h : j < x.nnext
    · exact hq.img j h
    · have e : M.node j = y.nnext + (j - x.nnext) := by
        have := hr.nfresh (j - x.nnext); rwa [show x.nnext + (j - x.nnext) = j by omega] at this
      rw [e]
      cases hg : b.aliases.get (y.nnext + (j - x.nnext)) with
      | none => rfl
      | some _ => have := hq.bound _ (by rw [hg]; rfl); omega
  bound m hm := Nat.lt_of_lt_of_le (hq.bound m hm) ky.nnext

end Host.Ts.Sim.Full
