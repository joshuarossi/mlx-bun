import kernels.trellis.CodebookLoad

namespace Inference.Kernels.Trellis.DownCodebook
/- Indexing obligations for down-codebook.ts with the pinned Qwen dimensions:
   R = 17408, C = 5120, SPLITS = 128, P = 16, U = 2, THREADS = 256.
   These theorems establish indexing, packed-window alignment, and preservation
   of per-row multiply/FMA order. They do not establish the final reduction,
   synchronization, or simd_sum semantics. The numerical load theorem uses
   the explicit M1Max.LoadContract hypothesis. -/

def scratch (sg lane i : Nat) : Nat := sg*512 + ((lane/16)*256+255-lane%16*16)-i
def column (ty c : Nat) : Nat := (2*(ty/32)+c/512)*512+c%512
def splitRow (y sg r : Nat) : Nat := (y+32*(sg%4))*136+r

theorem scratch_bounds (sg lane i : Nat) (hs : sg<8) (hl : lane<32) (hi : i<16) :
    scratch sg lane i < 4096 := by unfold scratch; omega

-- Each of the eight SIMD groups, 32 lanes, and 16 entries writes a distinct
-- scratch location; the inverse also shows all 4096 locations are written.
theorem scratch_inverse (sg lane i : Nat) (hs : sg<8) (hl : lane<32) (hi : i<16) :
    scratch sg lane i / 512 = sg ∧
    (scratch sg lane i % 512)/256*16 + (255-scratch sg lane i%256)/16 = lane ∧
    (255-scratch sg lane i%256)%16 = i := by unfold scratch; omega

theorem scratch_coverage (j : Nat) (hj : j<4096) :
    scratch (j/512) ((j%512)/256*16+(255-j%256)/16) ((255-j%256)%16) = j := by
  unfold scratch
  omega

theorem partial_bounds (ty c : Nat) (ht : ty<160) (hc : c<1024) :
    ty%32 < 32 ∧ column ty c < 5120 ∧ ty%32*5120+column ty c < 32*5120 := by
  unfold column
  omega

theorem partial_inverse (ty c : Nat) (_ht : ty<160) (hc : c<1024) :
    32*(column ty c / 1024)+ty%32 = ty ∧ column ty c % 1024 = c := by
  unfold column
  omega

theorem partial_coverage (y col : Nat) (hy : y<32) (hc : col<5120) :
    (32*(col/1024)+y) < 160 ∧ col%1024 < 1024 ∧
    (32*(col/1024)+y)%32 = y ∧ column (32*(col/1024)+y) (col%1024) = col := by
  unfold column
  omega

theorem row_bounds (y sg r : Nat) (hy : y<32) (_hs : sg<8) (hr : r<136) :
    splitRow y sg r < 17408 := by unfold splitRow; omega

theorem row_coverage (r : Nat) (hr : r<17408) :
    r/136%32 < 32 ∧ r/136/32 < 4 ∧ r%136 < 136 ∧
    splitRow (r/136%32) (r/136/32) (r%136) = r := by
  unfold splitRow
  omega

theorem row_pair (pair u : Nat) (hp : pair<68) (hu : u<2) :
    2*pair+u < 136 ∧ (2*pair+u)/2=pair ∧ (2*pair+u)%2=u := by omega

def rowMajor (row block word k : Nat) := row*(20*(8*k))+block*(8*k)+word
def interleaved (row block word : Nat) := (block/2)*17408*48+(block%2)*24+row*48+word

theorem rowMajor_bounds (row block word k : Nat) (hr : row<17408) (hb : block<20)
    (hk : k=2 ∨ k=4) (hw : word<8*k) : rowMajor row block word k < 17408*20*(8*k) := by
  unfold rowMajor
  rcases hk with hk | hk <;> subst k <;> omega

theorem interleaved_bounds (row block word : Nat)
    (hr : row<17408) (hb : block<20) (hw : word<24) : interleaved row block word < 10*17408*48 := by
  unfold interleaved
  omega

theorem interleaved_inverse (row block word : Nat)
    (hr : row<17408) (_hb : block<20) (hw : word<24) :
    interleaved row block word % (17408*48) / 48 = row ∧
    interleaved row block word / (17408*48)*2 + interleaved row block word % 48 / 24 = block ∧
    interleaved row block word % 24 = word := by
  unfold interleaved
  omega

theorem fold_bounds (group sg lane i : Nat)
    (hg : group<160) (hs : sg<8) (hl : lane<32) (hi : i<4) :
    group*32+sg*4+i < 5120 ∧ lane*5120+group*32+sg*4+i < 32*5120 := by omega

namespace Lane

def alignedWord (w : Nat → BitVec 32) (k li i : Nat) : BitVec 32 :=
  let first := li*(16*k)/32
  let a := w ((first+i)%(8*k))
  if k=3 ∧ li%2=1 then (a >>> 16) ||| (w ((first+i+1)%(8*k)) <<< 16) else a

theorem correct (w : Nat → BitVec 32) (k li i j : Nat)
    (hk : k=2 ∨ k=3 ∨ k=4) (_hl : li<16) (_hi : i<3) (hj : j<32) :
    (alignedWord w k li i).getLsbD j =
      (w (((li*(16*k)+i*32+j)%(256*k))/32)).getLsbD ((li*(16*k)+i*32+j)%32) := by
  unfold alignedWord
  dsimp only
  split
  next hs =>
    obtain ⟨rfl, hs⟩ := hs
    simp only [BitVec.getLsbD_or, BitVec.getLsbD_ushiftRight, BitVec.getLsbD_shiftLeft]
    by_cases hb : j<16
    · simp only [hb, decide_true, Bool.not_true, Bool.and_false, Bool.false_and, Bool.or_false]
      have hw : (li*(16*3)/32+i)%(8*3) = ((li*(16*3)+i*32+j)%(256*3))/32 := by omega
      have hbit : 16+j = (li*(16*3)+i*32+j)%32 := by omega
      exact congr (congrArg BitVec.getLsbD (congrArg w hw)) hbit
    · have hge : 32 ≤ 16+j := by omega
      simp only [BitVec.getLsbD_of_ge _ _ hge, Bool.false_or,
        hb, decide_false, Bool.not_false, hj, decide_true, Bool.true_and]
      have hw : (li*(16*3)/32+i+1)%(8*3) = ((li*(16*3)+i*32+j)%(256*3))/32 := by omega
      have hbit : j-16 = (li*(16*3)+i*32+j)%32 := by omega
      exact congr (congrArg BitVec.getLsbD (congrArg w hw)) hbit
  next hs =>
    have hb : li*(16*k)%32=0 := by
      rcases hk with hk | hk | hk <;> subst k <;> omega
    have hw : (li*(16*k)/32+i)%(8*k) = ((li*(16*k)+i*32+j)%(256*k))/32 := by
      rcases hk with hk | hk | hk <;> subst k <;> omega
    have hbit : j = (li*(16*k)+i*32+j)%32 := by omega
    exact congr (congrArg BitVec.getLsbD (congrArg w hw)) hbit
end Lane


def scalarRows {α : Type} (step : Nat → α → α) : Nat → Nat → α → α
  | _, 0, acc => acc
  | start, count+1, acc => scalarRows step (start+1) count (step start acc)

def pairedRows {α : Type} (step : Nat → α → α) : Nat → Nat → α → α
  | _, 0, acc => acc
  | start, pairs+1, acc => pairedRows step (start+2) pairs (step (start+1) (step start acc))

-- No associativity or real-number rewrite: holds even when step rounds at
-- every multiplication/FMA. The two-row loop preserves the scalar row order.
theorem pairedRows_correct {α : Type} (step : Nat → α → α) (pairs start : Nat) (acc : α) :
    pairedRows step start pairs acc = scalarRows step start (2*pairs) acc := by
  induction pairs generalizing start acc with
  | zero => rfl
  | succ pairs ih =>
    simp only [Nat.mul_succ, Nat.add_assoc, scalarRows, pairedRows]
    exact ih (start+2) (step (start+1) (step start acc))

def accumulate (code scale input : Nat → Float32) (row : Nat) (acc : Float32) : Float32 :=
  Float32.fma (code row * scale row) (input row) acc

theorem accumulation_order (code scale input : Nat → Float32) (split : Nat) :
    (pairedRows (accumulate code scale input) (split*136) 68 0).toBits =
      (scalarRows (accumulate code scale input) (split*136) 136 0).toBits := by
  rw [pairedRows_correct]

namespace Lane

theorem window_correct (w : Nat → BitVec 32) (k li i j : Nat)
    (hk : k=2 ∨ k=3 ∨ k=4) (hl : li<16) (hi : i<16) (hj : j<12) :
    (Codebook.CodebookWindow.byteOffset (alignedWord w k li) (i*k) >>> 2).getLsbD j =
      (w ((((li*16+i)*k+j)%(256*k))/32)).getLsbD (((li*16+i)*k+j)%32) := by
  have ho : i*k ≤ 60 := (Codebook.CodebookWindow.lane_geometry k i hk hi).1
  rw [Codebook.CodebookWindow.correct _ _ _ (by omega) hj]
  have hw : (i*k+j)/32 < 3 := by omega
  rw [correct w k li _ _ hk hl hw (by omega)]
  have he : li*(16*k)+(i*k+j)/32*32+(i*k+j)%32 = (li*16+i)*k+j := by
    rcases hk with hk | hk | hk <;> subst k <;> omega
  rw [he]

theorem window_state_bits (w : Nat → BitVec 32) (k li i j : Nat)
    (hk : k=2 ∨ k=3 ∨ k=4) (hl : li<16) (hi : i<16) (hj : j<12) :
    (Codebook.CodebookWindow.byteOffset (alignedWord w k li) (i*k) >>> 2).getLsbD j =
      (Codebook.PackedState.read w k (255-(li*16+i))).getLsbD j := by
  rw [window_correct w k li i j hk hl hi hj]
  rw [Codebook.PackedState.cyclic_correct w k _ j hk (by omega) hj]
  have he : 255-(255-(li*16+i)) = li*16+i := by omega
  rw [he]

end Lane

theorem window_state (w : Nat → BitVec 32) (k li i : Nat)
    (hk : k=2 ∨ k=3 ∨ k=4) (hl : li<16) (hi : i<16) :
    Codebook.CodebookWindow.byteOffset (Lane.alignedWord w k li) (i*k) >>> 2 =
      Codebook.PackedState.read w k (255-(li*16+i)) := by
  apply CodebookLoad.eq_of_low_bits _ _
    (Codebook.CodebookWindow.index_bound _ _) (CodebookLoad.packedState_bound _ _ _)
  exact fun j hj => Lane.window_state_bits w k li i j hk hl hi hj

theorem load_correct (load : Contracts.Mlx.M1Max.ThreadgroupLoad)
    (hardware : Contracts.Mlx.M1Max.LoadContract load)
    (memory : Contracts.Mlx.M1Max.WordMemory) (base : Nat)
    (ha : base%4=0) (hn : base+16384 ≤ 2^64)
    (initialized : CodebookLoad.Initialized memory base)
    (w : Nat → BitVec 32) (k li i : Nat)
    (hk : k=2 ∨ k=3 ∨ k=4) (hl : li<16) (hi : i<16) :
    CodebookLoad.read load memory base (Lane.alignedWord w k li) (i*k) =
      CodebookLoad.mathematicalCode (Codebook.PackedState.read w k (255-(li*16+i))) := by
  rw [CodebookLoad.read_correct load hardware memory base ha hn initialized]
  rw [window_state w k li i hk hl hi]

theorem all_lanes_active (ty sg lane : Nat) (ht : ty<160) (hs : sg<8) (hl : lane<32) :
    2*(ty/32)+sg/4 < 10 ∧ (2*(ty/32)+sg/4)*2+lane/16 < 20 := by omega

theorem codebook_initialization (thread iteration : Nat) (ht : thread<256) (hi : iteration<16) :
    thread+256*iteration < 4096 ∧ (thread+256*iteration)%256=thread ∧
    (thread+256*iteration)/256=iteration := by omega

theorem codebook_initialization_coverage (state : Nat) (hs : state<4096) :
    state%256 < 256 ∧ state/256 < 16 ∧ state%256+256*(state/256)=state := by omega

end Inference.Kernels.Trellis.DownCodebook
