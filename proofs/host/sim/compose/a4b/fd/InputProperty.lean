import host.sim.compose.a4b.fd.TypedData
import host.simgraph.family.FoldedData
import host.sim.full.TargetGrowD
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.FDVW
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Mlx.FfiEval Host.Mlx.SimGraph

def InputAt (π : List Nat) (j : Nat) (t : St FF.S) (C : CSrv) : Prop :=
  j < (mlxOf t.ffi).nnext ∧
    HostInt32 (concrete C.val) (mlxOf t.ffi) j (π.map Int.ofNat) [1, π.length]

private theorem mapM_keep {α β : Type} {f g : α → Option β}
    (h : ∀ a b, f a = some b → g a = some b) :
    ∀ {xs : List α} {ys : List β}, xs.mapM f = some ys → xs.mapM g = some ys
  | [], _, e => e
  | x :: xs, ys, e => by
    simp only [List.mapM_cons] at e ⊢
    obtain ⟨y, hy, e⟩ := Option.bind_eq_some_iff.mp e
    obtain ⟨ys', hys, e⟩ := Option.bind_eq_some_iff.mp e
    rw [h x y hy, mapM_keep h hys]
    exact e

theorem InputAt.grow {π : List Nat} {j : Nat} {t t' : St FF.S} {C C' : CSrv}
    (h : InputAt π j t C) (hg : Host.Mlx.Ffi.NGrow (mlxOf t.ffi) (mlxOf t'.ffi))
    (hc : CSrv.Le C C') : InputAt π j t' C' := by
  obtain ⟨hj, bytes, shape, hn, hb, hs⟩ := h
  refine ⟨Nat.lt_of_lt_of_le hj hg.nnext, bytes, shape, (hg.nodes j hj).trans hn, ?_, ?_⟩
  · have eq : ∀ b v, (concrete C.val).byte b = some v → (concrete C'.val).byte b = some v := by
      intro b v h
      cases b with
      | lit n => exact h
      | part k c i =>
        cases c with
        | big n => exact h
        | num x =>
          simp only [concrete, concreteByte, concreteCell] at h ⊢
          cases hx : C.val x with
          | none => simp [hx] at h
          | some f => rw [hc.val hx]; simpa only [hx] using h
    exact mapM_keep eq hb
  · have eq : ∀ d v, (concrete C.val).d d = some v → (concrete C'.val).d d = some v := by
      intro d v h
      cases d with
      | lit i => exact h
      | sym x =>
        change (C.val x).bind F64.toInt? = some v at h
        change (C'.val x).bind F64.toInt? = some v
        obtain ⟨f, hf, hv⟩ := Option.bind_eq_some_iff.mp h
        rw [hc.val hf]; exact hv
    exact mapM_keep eq hs
end Host.Ts.Sim.Compose.FDVW
