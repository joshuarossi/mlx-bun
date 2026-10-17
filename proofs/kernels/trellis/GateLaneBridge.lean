import kernels.trellis.GateLoopSource
namespace Inference.Kernels.Trellis.GateLaneBridge
open Contracts.Mlx Contracts.Mlx.M1Max PackedArrayMaterialization GateLoopSource GateUpExecution DownCodebook
set_option maxRecDepth 10000

-- These are identities of sequential state transitions. No arithmetic
-- associativity, distributivity, contraction or reduction tree is assumed.
theorem fold_range {α : Type} (step : Nat → α → α) (start count : Nat) (initial : α) :
    (List.range count).foldl (fun acc i => step (start+i) acc) initial=scalarRows step start count initial := by
  induction count generalizing start initial with
  | zero => rfl
  | succ count ih =>
    rw [List.range_succ_eq_map,List.foldl_cons,List.foldl_map]
    simpa only [Nat.add_zero,Nat.add_succ,Nat.succ_add,scalarRows] using ih (start+1) (step start initial)

theorem fold_congr {α β : Type} (points : List α) (first second : α → β → β)
    (same : ∀ point ∈ points, ∀ acc, first point acc=second point acc) (initial : β) :
    points.foldl (fun acc point => first point acc) initial=points.foldl (fun acc point => second point acc) initial := by
  induction points generalizing initial with
  | nil => rfl
  | cons point rest ih =>
    simp only [List.foldl_cons]
    rw [same point (by simp)]
    exact ih (fun p member => same p (by simp [member])) (second point initial)

theorem fold_pair {α β γ : Type} (points : List α) (first : α → β → β) (second : α → γ → γ)
    (a : β) (b : γ) :
    points.foldl (fun state point => (first point state.1,second point state.2)) (a,b)=
      (points.foldl (fun state point => first point state) a,points.foldl (fun state point => second point state) b) := by
  induction points generalizing a b with
  | nil => rfl
  | cons point rest ih => exact ih (first point a) (second point b)

theorem fold_tiles {α : Type} (step : Nat → α → α) (start count width : Nat) (initial : α) :
    scalarRows (fun q acc => scalarRows step (q*width) width acc) start count initial=
      tiledRows step (start*width) count width initial := by
  induction count generalizing start initial with
  | zero => rfl
  | succ count ih =>
    simpa only [scalarRows,tiledRows,Nat.add_mul,Nat.one_mul] using
      ih (start+1) (scalarRows step (start*width) width initial)

theorem qp_fold {α : Type} (step : Nat → α → α) (initial : α) :
    (List.range 4).foldl (fun acc q => (List.range 8).foldl (fun acc p => step (q*8+p) acc) acc) initial=
      scalarRows step 0 32 initial := by
  have chunks : (fun acc q => (List.range 8).foldl (fun acc p => step (q*8+p) acc) acc)=
      (fun acc q => scalarRows step (q*8) 8 acc) := by
    funext acc q
    exact fold_range step (q*8) 8 acc
  rw [chunks]
  calc
    _ = scalarRows (fun q acc => scalarRows step (q*8) 8 acc) 0 4 initial := by
      simpa only [Nat.zero_add] using fold_range (fun q acc => scalarRows step (q*8) 8 acc) 0 4 initial
    _ = tiledRows step 0 4 8 initial := fold_tiles step 0 4 8 initial
    _ = scalarRows step 0 32 initial := tiledRows_correct step 0 4 8 initial

def scale (input : GateInput kg ku) (isUp : Bool) : Nat → Float32 := GateWeightSource.scaleValue input isUp

theorem weight_value (input : GateInput kg ku) (row run j : Nat) (isUp : Bool) (column : j<32) :
    GateWeightSource.value input row run j isUp=
      DownExecution.coefficient (input.matrix isUp) (if isUp then ku else kg) row (run*32+j)*scale input isUp row := by
  have block : (run*32+j)/256=run/8 := by omega
  have position : (run*32+j)%256=run%8*32+j := by omega
  simp only [GateWeightSource.value,GateWeightSource.coefficient,DownExecution.coefficient,block,position,scale]

variable {activation : Fin 5120 → ArrayStorage.BF}

def projectionStep (input : GateInput kg ku) (row : Nat) (isUp : Bool)
    (point : Nat × Nat × Nat) : Accumulators → Accumulators :=
  GateUpExecution.referenceStep (input.matrix isUp) (if isUp then ku else kg) (scale input isUp)
    (ArrayStorage.bfWords activation) row point.1 (point.2.1*8+point.2.2)

theorem reference_step (input : GateInput kg ku) (row : Nat) (point : Nat × Nat × Nat)
    (qBound : point.2.1<4) (pBound : point.2.2<8) (acc : GateAccumulateSource.Dual) :
    GateLoopSource.referenceStep (activation:=activation) input row point acc=
      (projectionStep (activation:=activation) input row false point acc.1,
       projectionStep (activation:=activation) input row true point acc.2) := by
  unfold GateLoopSource.referenceStep projectionStep GateUpExecution.referenceStep
  dsimp only
  rw [weight_value input row point.1 (point.2.1*8+point.2.2) false (by omega),
      weight_value input row point.1 (point.2.1*8+point.2.2) true (by omega)]

-- FlatMap/fold identities expose exactly run-major, then q-major, then p-major
-- traversal. Each chunk is eight original FMA transitions in source order.
theorem projection_fold (input : GateInput kg ku) (row lane : Nat) (isUp : Bool) (initial : Accumulators) :
    (orderedEvents lane).foldl (fun acc point => projectionStep (activation:=activation) input row isUp point acc) initial=
      scalarRows (fun i => referenceRun (input.matrix isUp) (if isUp then ku else kg) (scale input isUp)
        (ArrayStorage.bfWords activation) row (lane+32*i)) 0 5 initial := by
  simp only [orderedEvents,List.foldl_flatMap,List.foldl_map,projectionStep]
  have chunks : (fun acc i => (List.range 4).foldl (fun acc q => (List.range 8).foldl
      (fun acc p => GateUpExecution.referenceStep (input.matrix isUp) (if isUp then ku else kg) (scale input isUp)
        (ArrayStorage.bfWords activation) row (lane+32*i) (q*8+p) acc) acc) acc)=
      (fun acc i => referenceRun (input.matrix isUp) (if isUp then ku else kg) (scale input isUp)
        (ArrayStorage.bfWords activation) row (lane+32*i) acc) := by
    funext acc i
    exact qp_fold (GateUpExecution.referenceStep (input.matrix isUp) (if isUp then ku else kg) (scale input isUp)
      (ArrayStorage.bfWords activation) row (lane+32*i)) acc
  rw [chunks]
  simpa only [Nat.zero_add] using fold_range (fun i => referenceRun (input.matrix isUp) (if isUp then ku else kg) (scale input isUp)
    (ArrayStorage.bfWords activation) row (lane+32*i)) 0 5 initial

variable {source : ArrayStorage.BFBuffer activation} {tableBase inputBase : Nat}

def laneSums (input : GateInput kg ku) (actual : GateInputSource.Execution source tableBase inputBase)
    (row lane : Nat) (load : ThreadgroupLoad) : Option (Float32 × Float32) :=
  (memoryLane input actual row lane load ((0,0),(0,0))).map (fun acc => (acc.1.1+acc.1.2,acc.2.1+acc.2.2))

theorem lane_sums (input : GateInput kg ku) (actual : GateInputSource.Execution source tableBase inputBase)
    (row lane : Nat) (rowBound : row<17408) (laneBound : lane<32)
    (load : ThreadgroupLoad) (hardware : LoadContract load) :
    laneSums input actual row lane load=some
      (referenceLane (input.matrix false) kg (scale input false) (ArrayStorage.bfWords activation) row lane,
       referenceLane (input.matrix true) ku (scale input true) (ArrayStorage.bfWords activation) row lane) := by
  unfold laneSums
  rw [memory_lane input actual row lane rowBound laneBound load hardware]
  have same := fold_congr (orderedEvents lane)
    (fun point acc => GateLoopSource.referenceStep (activation:=activation) input row point acc)
    (fun point acc => (projectionStep (activation:=activation) input row false point acc.1,
      projectionStep (activation:=activation) input row true point acc.2))
    (fun point member acc => reference_step input row point
      (event_bounds lane laneBound point member).2.1 (event_bounds lane laneBound point member).2.2 acc)
    ((0,0),(0,0))
  rw [same,fold_pair,projection_fold,projection_fold]
  rfl
end Inference.Kernels.Trellis.GateLaneBridge
