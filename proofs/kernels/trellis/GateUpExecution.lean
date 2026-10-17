import kernels.trellis.GateUpCodebook
import kernels.trellis.DownExecution

namespace Inference.Kernels.Trellis.GateUpExecution
open Contracts.Mlx.M1Max DownCodebook GateUpCodebook
set_option maxRecDepth 10000

/- The staged bf16 loads and dual accumulators of gate-up-codebook.ts.
   This reference preserves lane and even/odd accumulation order, including
   each rounded binary32 multiplication and FMA. Exp and final dtype casts
   are not replaced by real-number operations. -/

def pack (lo hi : BitVec 16) : BitVec 32 := lo.setWidth 32 ||| (hi.setWidth 32 <<< 16)
def widened (x : BitVec 16) : BitVec 32 := x.setWidth 32 <<< 16

theorem unpack_low (lo hi : BitVec 16) : pack lo hi <<< 16 = widened lo := by
  apply BitVec.eq_of_getLsbD_eq
  intro j hj
  simp only [pack, widened, BitVec.getLsbD_shiftLeft, BitVec.getLsbD_or]
  by_cases h : j<16
  · simp [h]
  · have hj' : j-16<16 := by omega
    simp [h, hj, hj']

theorem unpack_high (lo hi : BitVec 16) : pack lo hi &&& 0xffff0000#32 = widened hi := by
  apply BitVec.eq_of_getLsbD_eq
  intro j hj
  simp only [pack, widened, BitVec.getLsbD_and, BitVec.getLsbD_or,
    BitVec.getLsbD_shiftLeft, BitVec.getLsbD_setWidth]
  have hm : (0xffff0000#32).getLsbD j = decide (16 ≤ j) := by
    have he : (0xffff0000#32) = (0xffff#32 <<< 16) := by decide
    rw [he, BitVec.getLsbD_shiftLeft]
    by_cases h : j<16
    · simp [h]
    · have hb : j-16<16 := by omega
      have ho : (0xffff#32).getLsbD (j-16) = true := by
        have allBits : ∀ b : Fin 16, (0xffff#32).getLsbD b.val = true := by decide
        exact allBits ⟨j-16, hb⟩
      simp [h, hj, ho, show 16 ≤ j by omega]
  rw [hm]
  by_cases h : j<16
  · simp [h, show ¬16 ≤ j by omega]
  · simp [h, hj, show 16 ≤ j by omega]

def asFloat (x : BitVec 32) : Float32 := Float32.ofBits ⟨x⟩
def widen (x : BitVec 16) : Float32 := asFloat (widened x)

def stagedRead (x : Nat → BitVec 16) (run q p : Nat) : Float32 :=
  let address := stagedChunk (q*160+run)*8+(p/2)*2
  let chunk := pack (x address) (x (address+1))
  asFloat (if p%2=1 then chunk &&& 0xffff0000#32 else chunk <<< 16)

theorem stagedRead_correct (x : Nat → BitVec 16) (run q p : Nat)
    (hr : run<160) (_hq : q<4) (_hp : p<8) :
    stagedRead x run q p = widen (x (run*32+q*8+p)) := by
  unfold stagedRead widen
  dsimp only
  split
  next h =>
    rw [unpack_high]
    have ha : stagedChunk (q*160+run)*8+p/2*2+1 = run*32+q*8+p := by
      unfold stagedChunk
      omega
    rw [ha]
  next h =>
    rw [unpack_low]
    have ha : stagedChunk (q*160+run)*8+p/2*2 = run*32+q*8+p := by
      unfold stagedChunk
      omega
    rw [ha]

theorem scalarRows_add {α : Type} (step : Nat → α → α) (start a b : Nat) (acc : α) :
    scalarRows step start (a+b) acc =
      scalarRows step (start+a) b (scalarRows step start a acc) := by
  induction a generalizing start acc with
  | zero => simp [scalarRows]
  | succ a ih =>
    simpa only [Nat.succ_add, scalarRows, show start+1+a=start+(a+1) by omega] using
      ih (start+1) (step start acc)

def tiledRows {α : Type} (step : Nat → α → α) : Nat → Nat → Nat → α → α
  | _, 0, _, acc => acc
  | start, tiles+1, width, acc =>
      tiledRows step (start+width) tiles width (scalarRows step start width acc)

theorem tiledRows_correct {α : Type} (step : Nat → α → α)
    (start tiles width : Nat) (acc : α) :
    tiledRows step start tiles width acc = scalarRows step start (tiles*width) acc := by
  induction tiles generalizing start acc with
  | zero => simp [tiledRows, scalarRows]
  | succ tiles ih =>
    simp only [tiledRows, Nat.succ_mul, Nat.add_comm (tiles*width) width]
    rw [scalarRows_add]
    exact ih (start+width) (scalarRows step start width acc)

abbrev Accumulators := Float32 × Float32

def accumulate (j : Nat) (weight input : Float32) (acc : Accumulators) : Accumulators :=
  if j%2=1 then (acc.1, Float32.fma weight input acc.2)
  else (Float32.fma weight input acc.1, acc.2)

def sourceStep (load : ThreadgroupLoad) (memory : WordMemory) (base : Nat)
    (words : DownExecution.PackedMatrix) (k : Nat) (scale : Nat → Float32)
    (input : Nat → BitVec 16) (row run j : Nat) (acc : Accumulators) : Accumulators :=
  accumulate j
    (CodebookLoad.read load memory base (runWords (words row (run/8)) run k) ((31-j)*k) * scale row)
    (stagedRead input run (j/8) (j%8)) acc

def referenceStep (words : DownExecution.PackedMatrix) (k : Nat) (scale : Nat → Float32)
    (input : Nat → BitVec 16) (row run j : Nat) (acc : Accumulators) : Accumulators :=
  accumulate j (DownExecution.coefficient words k row (run*32+j) * scale row)
    (widen (input (run*32+j))) acc

theorem sourceStep_correct (load : ThreadgroupLoad) (hardware : LoadContract load)
    (memory : WordMemory) (base : Nat) (ha : base%4=0) (hn : base+16384 ≤ 2^64)
    (initialized : CodebookLoad.Initialized memory base)
    (words : DownExecution.PackedMatrix) (k : Nat) (hk : k=2 ∨ k=3 ∨ k=4)
    (scale : Nat → Float32) (input : Nat → BitVec 16) (row run j : Nat)
    (hr : run<160) (hj : j<32) (acc : Accumulators) :
    sourceStep load memory base words k scale input row run j acc =
      referenceStep words k scale input row run j acc := by
  unfold sourceStep referenceStep
  rw [load_correct load hardware memory base ha hn initialized _ run k j hk hj]
  rw [stagedRead_correct input run (j/8) (j%8) hr (by omega) (by omega)]
  have hb : (run*32+j)/256=run/8 := by omega
  have ht : (run*32+j)%256=run%8*32+j := by omega
  have hj' : run*32+j/8*8+j%8=run*32+j := by omega
  rw [hj']
  unfold DownExecution.coefficient
  rw [hb, ht]

def sourceRun (load : ThreadgroupLoad) (memory : WordMemory) (base : Nat)
    (words : DownExecution.PackedMatrix) (k : Nat) (scale : Nat → Float32)
    (input : Nat → BitVec 16) (row run : Nat) (acc : Accumulators) : Accumulators :=
  tiledRows (sourceStep load memory base words k scale input row run) 0 4 8 acc

def referenceRun (words : DownExecution.PackedMatrix) (k : Nat) (scale : Nat → Float32)
    (input : Nat → BitVec 16) (row run : Nat) (acc : Accumulators) : Accumulators :=
  scalarRows (referenceStep words k scale input row run) 0 32 acc

theorem sourceRun_correct (load : ThreadgroupLoad) (hardware : LoadContract load)
    (memory : WordMemory) (base : Nat) (ha : base%4=0) (hn : base+16384 ≤ 2^64)
    (initialized : CodebookLoad.Initialized memory base)
    (words : DownExecution.PackedMatrix) (k : Nat) (hk : k=2 ∨ k=3 ∨ k=4)
    (scale : Nat → Float32) (input : Nat → BitVec 16) (row run : Nat)
    (hr : run<160) (acc : Accumulators) :
    sourceRun load memory base words k scale input row run acc =
      referenceRun words k scale input row run acc := by
  unfold sourceRun referenceRun
  rw [tiledRows_correct]
  apply DownExecution.scalarRows_congr
  intro j _hj hj a
  exact sourceStep_correct load hardware memory base ha hn initialized words k hk scale input row run j
    hr hj a

def sourceLane (load : ThreadgroupLoad) (memory : WordMemory) (base : Nat)
    (words : DownExecution.PackedMatrix) (k : Nat) (scale : Nat → Float32)
    (input : Nat → BitVec 16) (row lane : Nat) : Float32 :=
  let acc := scalarRows (fun i => sourceRun load memory base words k scale input row (lane+32*i))
    0 5 (0, 0)
  acc.1 + acc.2

def referenceLane (words : DownExecution.PackedMatrix) (k : Nat) (scale : Nat → Float32)
    (input : Nat → BitVec 16) (row lane : Nat) : Float32 :=
  let acc := scalarRows (fun i => referenceRun words k scale input row (lane+32*i)) 0 5 (0, 0)
  acc.1 + acc.2

theorem sourceLane_correct (load : ThreadgroupLoad) (hardware : LoadContract load)
    (memory : WordMemory) (base : Nat) (ha : base%4=0) (hn : base+16384 ≤ 2^64)
    (initialized : CodebookLoad.Initialized memory base)
    (words : DownExecution.PackedMatrix) (k : Nat) (hk : k=2 ∨ k=3 ∨ k=4)
    (scale : Nat → Float32) (input : Nat → BitVec 16) (row lane : Nat) (hl : lane<32) :
    sourceLane load memory base words k scale input row lane = referenceLane words k scale input row lane := by
  have h := DownExecution.scalarRows_congr
    (fun i => sourceRun load memory base words k scale input row (lane+32*i))
    (fun i => referenceRun words k scale input row (lane+32*i)) 0 5 (0, 0)
    (fun i _hi hi acc => sourceRun_correct load hardware memory base ha hn initialized words k hk scale input
      row (lane+32*i) (by omega) acc)
  exact congrArg (fun acc : Accumulators => acc.1 + acc.2) h

theorem projection_correct (load : ThreadgroupLoad) (hardware : LoadContract load)
    (memory : WordMemory) (base : Nat) (ha : base%4=0) (hn : base+16384 ≤ 2^64)
    (initialized : CodebookLoad.Initialized memory base)
    (words : DownExecution.PackedMatrix) (k : Nat) (hk : k=2 ∨ k=3 ∨ k=4)
    (scale : Nat → Float32) (input : Nat → BitVec 16) (row : Nat)
    (reduce : DownExecution.SimdReduction) :
    reduce (fun lane => sourceLane load memory base words k scale input row lane.val) =
      reduce (fun lane => referenceLane words k scale input row lane.val) := by
  congr 1
  funext lane
  exact sourceLane_correct load hardware memory base ha hn initialized words k hk scale input row lane.val lane.isLt

end Inference.Kernels.Trellis.GateUpExecution
