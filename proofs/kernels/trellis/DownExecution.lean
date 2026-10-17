import kernels.trellis.DownCodebook

namespace Inference.Kernels.Trellis.DownExecution
open Contracts.Mlx.M1Max DownCodebook

/- Arithmetic translation of the single-row down kernel at R=17408, C=5120.
   Inputs are already widened to binary32. Words are indexed by row, block,
   word; DownCodebook proves the row-major/interleaved storage addressing.
   The reference is a rounded matrix-vector product with the source's explicit
   128-way partition, four-split sums, and final SIMD reduction. It does not
   replace rounded sums with an associative real-number sum.

   The final SIMD instruction and output conversion remain explicit primitive
   parameters: these theorems do not assert an undocumented reduction tree or
   a floating-point error bound for an arbitrary reduction primitive. -/

abbrev PackedMatrix := Nat → Nat → Nat → BitVec 32

def coefficient (words : PackedMatrix) (k row col : Nat) : Float32 :=
  CodebookLoad.mathematicalCode
    (Codebook.PackedState.read (words row (col/256)) k (col%256))

def splitSum (words : PackedMatrix) (k : Nat) (scale input : Nat → Float32)
    (split col : Nat) : Float32 :=
  scalarRows (fun row acc => Float32.fma (coefficient words k row col * scale row)
    (input row) acc) (split*136) 136 0

def laneColumn (ty sg lane i : Nat) : Nat :=
  (2*(ty/32)+sg/4)*512+(lane/16)*256+255-(lane%16)*16-i

def laneSum (load : ThreadgroupLoad) (memory : WordMemory) (base : Nat)
    (words : PackedMatrix) (k : Nat) (scale input : Nat → Float32)
    (ty sg lane i : Nat) : Float32 :=
  let block := (2*(ty/32)+sg/4)*2+lane/16
  pairedRows (fun row acc => Float32.fma
    (CodebookLoad.read load memory base
      (Lane.alignedWord (words row block) k (lane%16)) (i*k) * scale row)
    (input row) acc) ((ty%32+32*(sg%4))*136) 68 0

theorem lane_column (ty sg lane i : Nat) (hl : lane<32) (hi : i<16) :
    laneColumn ty sg lane i / 256 = (2*(ty/32)+sg/4)*2+lane/16 ∧
    laneColumn ty sg lane i % 256 = 255-(lane%16*16+i) := by
  unfold laneColumn
  omega

theorem laneSum_correct (load : ThreadgroupLoad) (hardware : LoadContract load)
    (memory : WordMemory) (base : Nat) (ha : base%4=0) (hn : base+16384 ≤ 2^64)
    (initialized : CodebookLoad.Initialized memory base)
    (words : PackedMatrix) (k : Nat) (hk : k=2 ∨ k=3 ∨ k=4)
    (scale input : Nat → Float32) (ty sg lane i : Nat) (hl : lane<32) (hi : i<16) :
    laneSum load memory base words k scale input ty sg lane i =
      splitSum words k scale input (ty%32+32*(sg%4)) (laneColumn ty sg lane i) := by
  unfold laneSum splitSum
  rw [pairedRows_correct]
  have hc := lane_column ty sg lane i hl hi
  have he : (fun row acc => Float32.fma
      (CodebookLoad.read load memory base
        (Lane.alignedWord (words row ((2*(ty/32)+sg/4)*2+lane/16)) k (lane%16)) (i*k) * scale row)
      (input row) acc) =
      (fun row acc => Float32.fma (coefficient words k row (laneColumn ty sg lane i) * scale row)
        (input row) acc) := by
    funext row acc
    rw [load_correct load hardware memory base ha hn initialized _ k (lane%16) i hk (by omega) hi]
    unfold coefficient
    rw [hc.1, hc.2]
  rw [he]

-- Post-barrier scratch contents use the unique writer inverse. The following
-- two theorems prove both the stores and the subsequent reads agree with it.
def scratchMemory (values : Nat → Nat → Nat → Float32) (j : Nat) : Float32 :=
  values (j/512) ((j%512)/256*16+(255-j%256)/16) ((255-j%256)%16)

theorem scratch_store (values : Nat → Nat → Nat → Float32) (sg lane i : Nat)
    (hs : sg<8) (hl : lane<32) (hi : i<16) :
    scratchMemory values (scratch sg lane i) = values sg lane i := by
  obtain ⟨hs, hl, hi⟩ := scratch_inverse sg lane i hs hl hi
  unfold scratchMemory
  rw [hs, hl, hi]

theorem scratch_read (load : ThreadgroupLoad) (hardware : LoadContract load)
    (memory : WordMemory) (base : Nat) (ha : base%4=0) (hn : base+16384 ≤ 2^64)
    (initialized : CodebookLoad.Initialized memory base)
    (words : PackedMatrix) (k : Nat) (hk : k=2 ∨ k=3 ∨ k=4)
    (scale input : Nat → Float32) (ty j : Nat) (_hj : j<4096) :
    scratchMemory (laneSum load memory base words k scale input ty) j =
      splitSum words k scale input (ty%32+32*(j/512%4))
        ((2*(ty/32)+j/512/4)*512+j%512) := by
  unfold scratchMemory
  rw [laneSum_correct load hardware memory base ha hn initialized words k hk scale input
    ty _ _ _ (by omega) (by omega)]
  congr 1
  unfold laneColumn
  omega

theorem scalarRows_congr {α : Type} (f g : Nat → α → α) (start count : Nat) (acc : α)
    (h : ∀ row, start ≤ row → row < start+count → ∀ a, f row a = g row a) :
    scalarRows f start count acc = scalarRows g start count acc := by
  induction count generalizing start acc with
  | zero => rfl
  | succ count ih =>
    simp only [scalarRows]
    rw [h start (by omega) (by omega) acc]
    exact ih (start+1) (g start acc) (fun row hlo hhi a => h row (by omega) (by omega) a)

def firstStage (scratch : Nat → Float32) (c : Nat) : Float32 :=
  scalarRows (fun s acc => scratch ((c/512*4+s)*512+c%512) + acc) 0 4 0

def partialSum (words : PackedMatrix) (k : Nat) (scale input : Nat → Float32)
    (y col : Nat) : Float32 :=
  scalarRows (fun s acc => splitSum words k scale input (y+32*s) col + acc) 0 4 0

theorem firstStage_correct (load : ThreadgroupLoad) (hardware : LoadContract load)
    (memory : WordMemory) (base : Nat) (ha : base%4=0) (hn : base+16384 ≤ 2^64)
    (initialized : CodebookLoad.Initialized memory base)
    (words : PackedMatrix) (k : Nat) (hk : k=2 ∨ k=3 ∨ k=4)
    (scale input : Nat → Float32) (ty c : Nat) (hc : c<1024) :
    firstStage (scratchMemory (laneSum load memory base words k scale input ty)) c =
      partialSum words k scale input (ty%32) (column ty c) := by
  unfold firstStage partialSum
  apply scalarRows_congr
  intro s _hs hs acc
  rw [scratch_read load hardware memory base ha hn initialized words k hk scale input
    ty _ (by omega)]
  have hsplit : ((c/512*4+s)*512+c%512)/512%4 = s := by omega
  have hcol : (2*(ty/32)+((c/512*4+s)*512+c%512)/512/4)*512+
      ((c/512*4+s)*512+c%512)%512 = column ty c := by unfold column; omega
  rw [hsplit, hcol]

def writtenPartials (load : ThreadgroupLoad) (memory : WordMemory) (base : Nat)
    (words : PackedMatrix) (k : Nat) (scale input : Nat → Float32) (y col : Nat) : Float32 :=
  firstStage (scratchMemory (laneSum load memory base words k scale input (32*(col/1024)+y)))
    (col%1024)

theorem writtenPartials_correct (load : ThreadgroupLoad) (hardware : LoadContract load)
    (memory : WordMemory) (base : Nat) (ha : base%4=0) (hn : base+16384 ≤ 2^64)
    (initialized : CodebookLoad.Initialized memory base)
    (words : PackedMatrix) (k : Nat) (hk : k=2 ∨ k=3 ∨ k=4)
    (scale input : Nat → Float32) (y col : Nat) (hy : y<32) (hc : col<5120) :
    writtenPartials load memory base words k scale input y col = partialSum words k scale input y col := by
  unfold writtenPartials
  rw [firstStage_correct load hardware memory base ha hn initialized words k hk scale input
    _ _ (by omega)]
  obtain ⟨_, _, hy, hc⟩ := partial_coverage y col hy hc
  rw [hy, hc]

abbrev SimdReduction := (Fin 32 → Float32) → Float32

def fold (reduce : SimdReduction) (cast : Float32 → Float32)
    (partials : Nat → Nat → Float32) (col : Nat) : Float32 :=
  cast (reduce (fun lane => partials lane.val col))

theorem output_correct (load : ThreadgroupLoad) (hardware : LoadContract load)
    (memory : WordMemory) (base : Nat) (ha : base%4=0) (hn : base+16384 ≤ 2^64)
    (initialized : CodebookLoad.Initialized memory base)
    (words : PackedMatrix) (k : Nat) (hk : k=2 ∨ k=3 ∨ k=4)
    (scale input : Nat → Float32) (reduce : SimdReduction) (cast : Float32 → Float32)
    (col : Nat) (hc : col<5120) :
    fold reduce cast (writtenPartials load memory base words k scale input) col =
      fold reduce cast (partialSum words k scale input) col := by
  unfold fold
  congr 2
  funext lane
  exact writtenPartials_correct load hardware memory base ha hn initialized words k hk scale input
    lane.val col lane.isLt hc

end Inference.Kernels.Trellis.DownExecution
