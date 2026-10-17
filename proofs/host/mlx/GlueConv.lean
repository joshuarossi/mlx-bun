import host.mlx.Ops
import models.qwen.InitialState

namespace Host.Mlx.GlueConv
open Inference Inference.Models.Qwen Inference.Kernels.Delta

/-! Gap 3: ssm.ts convolve/convTail for one decode token (S = 1) and the
first-step zero states. -/

-- f32 [1,a,b,c] tensors (the recurrent state).
def F32Tensor4 (v : Value) (a b c : Nat) (f : Fin a → Fin b → Fin c → Float32) : Prop :=
  v.dtype = .float32 ∧ v.shape = [1,a,b,c] ∧ ∀ x y z, f32 (v.get [0,x.val,y.val,z.val]) = f x y z

-- conv1d.weight as loaded: bf16 [10240,4,1].
def ConvWeight (w : Value) (weight : Fin 10240 → Fin 4 → BF) : Prop :=
  w.dtype = .bfloat16 ∧ w.shape = [10240,4,1] ∧ ∀ c tap, bf (w.get [c.val, tap.val, 0]) = weight c tap

-- materialize.ts: MlxArray.fromInt32([0], []).
def zeroIndex : Value := ⟨.int32, [], fun _ => 0⟩

-- ssm.ts:184: zeros([1,3,10240], bf16) is InitialState.delta's history.
theorem initial_history :
    Tensor3 (zeros [1,3,10240] .bfloat16) 3 10240 (fun i c => InitialState.delta.history i c) :=
  ⟨rfl, rfl, fun _ _ => (by decide : bf 0 = InitialState.delta.history 0 0)⟩

-- gated.ts:295: zeros([1,48,128,128], f32) is InitialState.delta's recurrence.
theorem initial_recurrent :
    F32Tensor4 (zeros [1,48,128,128] .float32) 48 128 128 (fun h v k => InitialState.delta.recurrent h v k) :=
  ⟨rfl, rfl, fun _ _ _ => (by decide +kernel : f32 0 = (0 : Float32))⟩

-- input = concatenate_axis([state, qkv], 1); tail = slice_dynamic(slice(input,
-- [0,1,0], [1,4,10240]), 0, [0], [1,3,10240]); conv = conv1d(input, w, 1, 0, 1, 10240).
theorem convolve {C : Contracts.Mlx.M1Max.Contract} (M : MlxContract C) (state qkv w : Value)
    (history : Fin 3 → Fin 10240 → BF) (input : Nat → Fin 10240 → BF) (weight : Fin 10240 → Fin 4 → BF)
    (hs : Tensor3 state 3 10240 history) (hq : Row qkv 10240 (input 0)) (hw : ConvWeight w weight) :
    ∃ joined view tail conv, concatenate state qkv 1 = some joined ∧ slice joined [0,1,0] [1,4,10240] = some view ∧
      sliceDynamic view zeroIndex [0] [1,3,10240] = some tail ∧ conv1d M joined w 1 0 1 10240 = some conv ∧
      Tensor3 tail 3 10240 (fun i c => Convolution.tail (fun j => history j c) (fun t => input t c) 1 i) ∧
      Row conv 10240 (fun c => Convolution.value M.convContracted
        (Convolution.window (fun j => history j c) (fun t => input t c) 0) (weight c)) := by
  obtain ⟨sd, ss, se⟩ := hs
  obtain ⟨qd, qs, qe⟩ := hq
  obtain ⟨j, hj⟩ := concatenate_defined state qkv 1
    (by rw [ss, qs, sd, qd]; refine ⟨rfl, rfl, by decide, by decide⟩)
  obtain ⟨jd, js, jget⟩ := concatenate_spec _ _ _ _ hj
  rw [ss, qs] at js
  norm_num [List.getD, List.set] at js
  have joinedAt : ∀ (t : Fin 4) (c : Fin 10240),
      bf (j.get [0, t.val, c.val]) = Convolution.joined (fun i => history i c) (fun s => input s c) t.val := by
    intro t c
    rw [jget _ (by rw [js]; exact within3 Nat.zero_lt_one t.isLt c.isLt), ss]
    unfold Convolution.joined
    by_cases ht : t.val < 3
    · simp [ht]; exact se ⟨t.val, ht⟩ c
    · have h3 : t.val = 3 := by omega
      simp [h3]; exact qe 0 c
  obtain ⟨view, hv⟩ := slice_defined j [0,1,0] [1,4,10240] (by rw [js]; exact ⟨rfl, rfl, rfl⟩)
  obtain ⟨vd, vs, vget⟩ := slice_spec _ _ _ _ hv
  norm_num [List.zipWith] at vs
  have tailDefined : sliceDynamic view zeroIndex [0] [1,3,10240] = slice view [0,0,0] [1,3,10240] := by
    unfold sliceDynamic; rw [ite_eq_left (by rw [vs]; exact ⟨rfl, rfl, rfl⟩), vs]; rfl
  obtain ⟨tail, ht⟩ := slice_defined view [0,0,0] [1,3,10240] (by rw [vs]; exact ⟨rfl, rfl, rfl⟩)
  obtain ⟨td, ts, tget⟩ := slice_spec _ _ _ _ ht
  norm_num [List.zipWith] at ts
  have convDefined : conv1d M j w 1 0 1 10240 = some { dtype := .bfloat16, shape := [1, 1, 10240], elems := (fun i =>
      bfWord (Convolution.value M.convContracted
        (fun tap => bf (j.get [0, tap.val, i])) (fun tap => bf (w.get [i, tap.val, 0])))) } := by
    unfold conv1d; rw [js]
    exact ite_eq_left (show j.dtype = .bfloat16 ∧ w.dtype = .bfloat16 ∧ w.shape = [10240,4,1] ∧
      Convolution.depthwiseSelected 10240 10240 10240 1 1 1 0 false = true from ⟨jd.trans sd, hw.1, hw.2.1, by decide⟩)
  refine ⟨j, view, tail, _, hj, hv, tailDefined.trans ht, convDefined, ⟨td.trans (vd.trans (jd.trans sd)), ts, ?_⟩, ?_⟩
  · intro i c
    rw [tget _ (by rw [ts]; exact within3 Nat.zero_lt_one i.isLt c.isLt)]
    simp only [List.zipWith, Nat.zero_add]
    rw [vget _ (by rw [vs]; exact within3 Nat.zero_lt_one i.isLt c.isLt)]
    simp only [List.zipWith, Nat.zero_add]
    have := joinedAt ⟨1 + i.val, by omega⟩ c
    simpa [Convolution.tail, Nat.add_comm] using this
  · apply Row.mk rfl rfl
    intro c
    rw [bf_word]
    congr 1
    · funext tap
      simpa [Convolution.window] using joinedAt tap c
    · funext tap
      exact hw.2.2 c tap

end Host.Mlx.GlueConv
