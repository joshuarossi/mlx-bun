import kernels.trellis.CodebookLoad

namespace Inference.Kernels.Trellis.GateUpCodebook
/- Qwen single-row gate/up geometry: C=5120, R=17408, T=256, L=12,
   160 threadgroups of 32 SIMD groups, 32 lanes. No SIMD reduction or
   exp/SwiGLU accuracy claim is made by these indexing proofs. -/

def row (group sg iteration : Nat) := group*32+sg+5120*iteration

theorem row_coverage (r : Nat) (hr : r<17408) :
    r%5120/32 < 160 ∧ r%32 < 32 ∧ r/5120 < 4 ∧
    row (r%5120/32) (r%32) (r/5120) = r := by unfold row; omega

theorem row_inverse (group sg iteration : Nat) (hg : group<160) (hs : sg<32) :
    row group sg iteration%5120/32=group ∧ row group sg iteration%32=sg ∧
    row group sg iteration/5120=iteration := by unfold row; omega

theorem run_coverage (r : Nat) (hr : r<160) :
    r%32 < 32 ∧ r/32 < 5 ∧ r%32+32*(r/32)=r := by omega

theorem run_bounds (lane iteration : Nat) (hl : lane<32) (hi : iteration<5) :
    lane+32*iteration<160 ∧ (lane+32*iteration)%32=lane ∧
    (lane+32*iteration)/32=iteration := by omega

-- The transposed uint4 staging array restores each original activation chunk.
def stagedChunk (c : Nat) := (c%160)*4+c/160

theorem staged_bounds (c : Nat) (hc : c<640) : stagedChunk c < 640 := by
  unfold stagedChunk
  omega

theorem staged_read (q run p : Nat) (hq : q<4) (hr : run<160) (hp : p<8) :
    q*160+run < 640 ∧ stagedChunk (q*160+run)*8+p = run*32+q*8+p ∧
    run*32+q*8+p < 5120 := by unfold stagedChunk; omega

theorem staged_coverage (c : Nat) (hc : c<5120) :
    c/32<160 ∧ c%32/8<4 ∧ c%8<8 ∧ c/32*32+c%32/8*8+c%8=c := by omega

def firstWord (run k : Nat) := (224-(run%8)*32)*k/32

def runWords (w : Nat → BitVec 32) (run k i : Nat) :=
  w (((7-run%8)*k+i)%(8*k))

theorem word_loads (run k i : Nat) (hk : k=2 ∨ k=3 ∨ k=4) (hi : i<k) :
    firstWord run k=(7-run%8)*k ∧ firstWord run k+i < 8*k ∧
    ((7-run%8)*k+i)%(8*k) = firstWord run k+i ∧
    ((7-run%8)*k+k)%(8*k) = (if run%8=0 then 0 else firstWord run k+k) := by
  unfold firstWord
  rcases hk with hk | hk | hk <;> subst k <;> split <;> omega

theorem window_bounds (k j : Nat) (hk : k=2 ∨ k=3 ∨ k=4) (hj : j<32) :
    (31-j)*k ≤ 124 ∧ ((31-j)*k-2)/32 < k+1 ∧ ((31-j)*k+14)/32 < k+1 := by
  rcases hk with hk | hk | hk <;> subst k <;> omega

theorem window_state_bits (w : Nat → BitVec 32) (run k j b : Nat)
    (hk : k=2 ∨ k=3 ∨ k=4) (hj : j<32) (hb : b<12) :
    (Codebook.CodebookWindow.byteOffset (runWords w run k) ((31-j)*k) >>> 2).getLsbD b =
      (Codebook.PackedState.read w k (run%8*32+j)).getLsbD b := by
  rw [Codebook.CodebookWindow.correct _ _ _ (window_bounds k j hk hj).1 hb]
  rw [Codebook.PackedState.cyclic_correct w k _ b hk (by omega) hb]
  unfold runWords
  have hw : ((7-run%8)*k+((31-j)*k+b)/32)%(8*k) =
      (((255-(run%8*32+j))*k+b)%(256*k))/32 := by
    rcases hk with hk | hk | hk <;> subst k <;> omega
  have hbit : ((31-j)*k+b)%32 = ((255-(run%8*32+j))*k+b)%32 := by
    rcases hk with hk | hk | hk <;> subst k <;> omega
  exact congr (congrArg BitVec.getLsbD (congrArg w hw)) hbit

theorem window_state (w : Nat → BitVec 32) (run k j : Nat)
    (hk : k=2 ∨ k=3 ∨ k=4) (hj : j<32) :
    Codebook.CodebookWindow.byteOffset (runWords w run k) ((31-j)*k) >>> 2 =
      Codebook.PackedState.read w k (run%8*32+j) := by
  apply CodebookLoad.eq_of_low_bits _ _
    (Codebook.CodebookWindow.index_bound _ _) (CodebookLoad.packedState_bound _ _ _)
  exact fun b hb => window_state_bits w run k j b hk hj hb

theorem load_correct (load : Contracts.Mlx.M1Max.ThreadgroupLoad)
    (hardware : Contracts.Mlx.M1Max.LoadContract load)
    (memory : Contracts.Mlx.M1Max.WordMemory) (base : Nat)
    (ha : base%4=0) (hn : base+16384 ≤ 2^64)
    (initialized : CodebookLoad.Initialized memory base)
    (w : Nat → BitVec 32) (run k j : Nat)
    (hk : k=2 ∨ k=3 ∨ k=4) (hj : j<32) :
    CodebookLoad.read load memory base (runWords w run k) ((31-j)*k) =
      CodebookLoad.mathematicalCode (Codebook.PackedState.read w k (run%8*32+j)) := by
  rw [CodebookLoad.read_correct load hardware memory base ha hn initialized]
  rw [window_state w run k j hk hj]

theorem code_address_bounds (r run k i : Nat)
    (hr : r<17408) (hRun : run<160) (hk : k=2 ∨ k=3 ∨ k=4) (hi : i<8*k) :
    r*(20*(8*k))+run/8*(8*k)+i < 17408*20*(8*k) ∧
    r*(20*(8*k))+run/8*(8*k)+i < 2^32 := by
  rcases hk with hk | hk | hk <;> subst k <;> omega

end Inference.Kernels.Trellis.GateUpCodebook
