import state.KvAllocation

namespace Inference.Models.Qwen.AttentionKvCallerSelection
open Contracts.Mlx State
set_option maxRecDepth 10000

-- Reviewed translation of the selected L=1, paired-null/paired-retained
-- KVCache.updateAndFetch caller. Extracting the actual object state and array
-- shapes remains an explicit frontend/descriptor boundary.
inductive Storage where
  | empty
  | retained : Nat → Storage
  deriving DecidableEq, Repr

inductive Route where
  | initial
  | existing : Nat → Route
  | growth : Nat → Route
  deriving DecidableEq, Repr

def select (offset length : Nat) (storage : Storage) : Option Route :=
  if length=1 then
    match storage with
    | .empty => if offset=0 then some .initial else none
    | .retained capacity =>
      if offset≤capacity ∧ capacity%256=0 ∧ 0<capacity then
        if offset+1>capacity then some (.growth capacity) else some (.existing capacity)
      else none
  else none

def model (offset : Nat) : Storage :=
  if offset=0 then .empty else .retained (KvAllocation.capacity offset)

theorem initial : select 0 1 (model 0)=some .initial := by decide +kernel

theorem existing (offset : Nat) (positive : 0<offset)
    (room : offset+1≤KvAllocation.capacity offset) :
    select offset 1 (model offset)=some (.existing (KvAllocation.capacity offset)) := by
  have bounded := (KvAllocation.capacity_bounds offset).1
  have capPositive : 0<KvAllocation.capacity offset := by omega
  simp [select,model,ne_of_gt positive,bounded,KvAllocation.capacity_multiple,capPositive,Nat.not_lt.mpr room]

theorem growth (offset : Nat) (positive : 0<offset)
    (full : KvAllocation.capacity offset<offset+1) :
    select offset 1 (model offset)=some (.growth offset) ∧ offset%256=0 := by
  have equal := KvAllocation.growth_full offset full
  have multiple := KvAllocation.capacity_multiple offset
  rw [equal] at multiple
  constructor
  · simp [select,model,ne_of_gt positive,equal,multiple,positive]
  · exact multiple

def zeroShape : List Nat := [1,4,256,256]

def concatenate (route : Route) : Bool :=
  match route with | .growth _ => true | _ => false

theorem initial_direct : zeroShape=[1,4,256,256] ∧ concatenate .initial=false := ⟨rfl,rfl⟩

theorem positive_growth (offset : Nat) (positive : 0<offset)
    (full : KvAllocation.capacity offset<offset+1) :
    0<offset ∧ offset%256=0 ∧ concatenate (.growth offset)=true :=
  ⟨positive,(growth offset positive full).2,rfl⟩

def callerSource : String := r#"updateAndFetch(k: MlxArray, v: MlxArray): [MlxArray, MlxArray] {
    const prev = this.offset;
    const L = k.shape[2]!;
    if (!this.keys || prev + L > this.keys.shape[2]!) {
      const [B, H, , D] = k.shape as [number, number, number, number];
      const vD = v.shape[3]!;
      const nSteps = Math.floor((KVCache.STEP + L - 1) / KVCache.STEP);
      const newK = ops.zeros([B, H, nSteps * KVCache.STEP, D], k.dtype);
      const newV = ops.zeros([B, H, nSteps * KVCache.STEP, vD], v.dtype);
      if (this.keys && this.values) {
        let oldK = this.keys;
        let oldV = this.values;
        if (prev % KVCache.STEP !== 0) {
          const trimK = oldK.slice([0, 0, 0, 0], [B, H, prev, D]);
          const trimV = oldV.slice([0, 0, 0, 0], [B, H, prev, vD]);
          oldK.dispose();
          oldV.dispose();
          oldK = trimK;
          oldV = trimV;
        }
        this.keys = ops.concatAxis([oldK, newK], 2);
        this.values = ops.concatAxis([oldV, newV], 2);
        for (const a of [oldK, oldV, newK, newV]) a.dispose();
      } else {
        this.keys = newK;
        this.values = newV;
      }
    }

    this.offset += L;
    const [B, H, S, D] = this.keys!.shape as [number, number, number, number];
    const vD = this.values!.shape[3]!;
    const k2 = ops.sliceUpdate(this.keys!, k, [0, 0, prev, 0], [B, H, this.offset, D]);
    const v2 = ops.sliceUpdate(this.values!, v, [0, 0, prev, 0], [B, H, this.offset, vD]);
    this.keys!.dispose();
    this.values!.dispose();
    this.keys = k2;
    this.values = v2;
    return [
      this.keys.slice([0, 0, 0, 0], [B, H, this.offset, D]),
      this.values.slice([0, 0, 0, 0], [B, H, this.offset, vD]),
    ];
  }"#

end Inference.Models.Qwen.AttentionKvCallerSelection
