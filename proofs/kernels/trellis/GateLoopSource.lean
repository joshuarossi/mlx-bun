import kernels.trellis.GateWeightSource
namespace Inference.Kernels.Trellis.GateLoopSource
open Copy.ScalarCopySyntax (Tokens Parser accept nameToken)
open Contracts.Mlx
set_option maxRecDepth 10000
structure Loop where
  counter : String
  start : PackedArraySyntax.Expr
  test : String
  bound : PackedArraySyntax.Expr
  step : String
  increment : PackedArraySyntax.Expr
  deriving Repr
structure Column where
  target : String
  expression : PackedArraySyntax.Expr
  deriving Repr

def loopTokens : Parser Loop := fun ts => do
  let ts ←accept "for" ts
  let ts ←accept "(" ts
  let ts ←accept "uint" ts
  let (counter,ts) ←nameToken ts
  let ts ←accept "=" ts
  let (start,ts) ←PackedArraySyntax.expression 8 0 ts
  let ts ←accept ";" ts
  let (test,ts) ←nameToken ts
  let ts ←accept "<" ts
  let (bound,ts) ←PackedArraySyntax.expression 8 0 ts
  let ts ←accept ";" ts
  let (step,increment,ts) ←match ts with
    | "++"::rest => do
      let (step,rest) ←nameToken rest
      pure (step,PackedArraySyntax.Expr.literal .unsigned 1,rest)
    | rest => do
      let (step,rest) ←nameToken rest
      let rest ←accept "+=" rest
      let (increment,rest) ←PackedArraySyntax.expression 8 0 rest
      pure (step,increment,rest)
  let ts ←accept ")" ts
  let ts ←accept "{" ts
  pure (⟨counter,start,test,bound,step,increment⟩,ts)

def columnTokens : Parser Column := fun ts => do
  let ts ←accept "const" ts
  let ts ←accept "uint" ts
  let (target,ts) ←nameToken ts
  let ts ←accept "=" ts
  let (value,ts) ←PackedArraySyntax.expression 8 0 ts
  let ts ←accept ";" ts
  pure (⟨target,value⟩,ts)

def parseLoop (source : String) : Option Loop := do
  let (actual,rest) ←loopTokens (←PackedArraySyntax.tokenize source)
  if rest=[] then some actual else none

def parseColumn (source : String) : Option Column := do
  let (actual,rest) ←columnTokens (←PackedArraySyntax.tokenize source)
  if rest=[] then some actual else none

def runSource : String := "for (uint run = lane; run < N_RUNS; run += 32u) {"
def qSource : String := "for (uint q = 0; q < 4u; ++q) {"
def pSource : String := "for (uint p = 0; p < 8u; ++p) {"
def columnSource : String := "const uint j = q * 8u + p;"
def runAST : Loop := ⟨"run",.variable "lane","run",.variable "N_RUNS","run",.literal .unsigned 32⟩
def qAST : Loop := ⟨"q",.literal .signed 0,"q",.literal .unsigned 4,"q",.literal .unsigned 1⟩
def pAST : Loop := ⟨"p",.literal .signed 0,"p",.literal .unsigned 8,"p",.literal .unsigned 1⟩
def columnAST : Column := ⟨"j",.add (.multiply (.variable "q") (.literal .unsigned 8)) (.variable "p")⟩
theorem parsed_run : parseLoop runSource=some runAST := rfl
theorem parsed_q : parseLoop qSource=some qAST := rfl
theorem parsed_p : parseLoop pSource=some pAST := rfl
theorem parsed_column : parseColumn columnSource=some columnAST := rfl

def integer (lane q p : Nat) : PackedArraySyntax.Expr → Option (BitVec 32)
  | .variable name => if name="lane" then some (BitVec.ofNat 32 lane)
    else if name="q" then some (BitVec.ofNat 32 q) else if name="p" then some (BitVec.ofNat 32 p)
    else if name="N_RUNS" then some 160 else none
  | .literal _ n => if n<2^31 then some (BitVec.ofNat 32 n) else none
  | .add a b => do pure ((←integer lane q p a)+(←integer lane q p b))
  | .multiply a b => do pure ((←integer lane q p a)*(←integer lane q p b))
  | _ => none

-- The uint32 counter increments and tests are executed, including the final
-- false test. Fuel exhaustion fails rather than truncating a loop's events.
def iterations : Nat → BitVec 32 → BitVec 32 → BitVec 32 → Option (List Nat)
  | 0,_,_,_ => none
  | fuel+1,current,bound,step =>
    if current.toNat<bound.toNat then do
      pure (current.toNat::(←iterations fuel (current+step) bound step))
    else some []

def runs (lane : Nat) (code : Loop) : Option (List Nat) := do
  if code.counter=code.test ∧ code.counter=code.step then
    iterations 9 (←integer lane 0 0 code.start) (←integer lane 0 0 code.bound) (←integer lane 0 0 code.increment)
  else none

theorem run_iterations : ∀ lane : Fin 32, runs lane.val runAST=some ((List.range 5).map (fun i => lane.val+32*i)) := by decide +kernel
theorem q_iterations : runs 0 qAST=some (List.range 4) := by decide +kernel
theorem p_iterations : runs 0 pAST=some (List.range 8) := by decide +kernel

def column (q p : Nat) (code : Column) : Option Nat := do
  if code.target="j" then pure (←integer 0 q p code.expression).toNat else none

theorem column_selected : ∀ q : Fin 4, ∀ p : Fin 8, column q.val p.val columnAST=some (q.val*8+p.val) := by decide +kernel

def events (lane : Nat) : Option (List (Nat × Nat × Nat)) := do
  let rs ←runs lane (←parseLoop runSource)
  let qs ←runs 0 (←parseLoop qSource)
  let ps ←runs 0 (←parseLoop pSource)
  pure (rs.flatMap (fun run => qs.flatMap (fun q => ps.map (fun p => (run,q,p)))))

def orderedEvents (lane : Nat) : List (Nat × Nat × Nat) :=
  ((List.range 5).map (fun i => lane+32*i)).flatMap (fun run =>
    (List.range 4).flatMap (fun q => (List.range 8).map (fun p => (run,q,p))))

attribute [local irreducible] runs parseLoop

theorem events_selected (lane : Nat) (bound : lane<32) : events lane=some (orderedEvents lane) := by
  unfold events
  rw [parsed_run]
  change (runs lane runAST).bind _=_
  rw [run_iterations ⟨lane,bound⟩]
  change (parseLoop qSource).bind _=_
  rw [parsed_q]
  change (runs 0 qAST).bind _=_
  rw [q_iterations]
  change (parseLoop pSource).bind _=_
  rw [parsed_p]
  change (runs 0 pAST).bind _=_
  rw [p_iterations]
  rfl

-- Operational event order, without reassociating any floating-point update.
def execute {α : Type} (lane : Nat) (step : Nat → Nat → Nat → α → α) (initial : α) : Option α := do
  let actual ←events lane
  pure (actual.foldl (fun state point => step point.1 point.2.1 point.2.2 state) initial)

theorem execute_order {α : Type} (lane : Nat) (bound : lane<32)
    (step : Nat → Nat → Nat → α → α) (initial : α) :
    execute lane step initial=some ((orderedEvents lane).foldl
      (fun state point => step point.1 point.2.1 point.2.2 state) initial) := by
  unfold execute
  rw [events_selected lane bound]
  rfl

-- The environment value is discharged by the parsed constexpr declaration.
theorem run_bound_from_source : GateInputContext.constantAST.target="N_RUNS" ∧
    GateInputSemantics.uint GateInputSyntax.loopAST 0 GateInputContext.constantAST.value=some 160 :=
  GateInputContext.constant_selected

theorem event_bounds (lane : Nat) (laneBound : lane<32) (point : Nat × Nat × Nat)
    (member : point ∈ orderedEvents lane) : point.1<160 ∧ point.2.1<4 ∧ point.2.2<8 := by
  simp only [orderedEvents,List.mem_flatMap,List.mem_map,List.mem_range] at member
  obtain ⟨run,⟨i,hi,runEq⟩,q,hq,p,hp,pointEq⟩:=member
  subst run
  subst point
  exact ⟨by omega,hq,hp⟩

variable {activation : Fin 5120 → ArrayStorage.BF} {source : ArrayStorage.BFBuffer activation}
  {tableBase inputBase : Nat}

def pointStep (input : PackedArrayMaterialization.GateInput kg ku)
    (actual : GateInputSource.Execution source tableBase inputBase) (row : Nat)
    (load : M1Max.ThreadgroupLoad) (point : Nat × Nat × Nat) (acc : GateAccumulateSource.Dual) : Option GateAccumulateSource.Dual := do
  let j ←column point.2.1 point.2.2 (←parseColumn columnSource)
  if j=point.2.1*8+point.2.2 then
    GateWeightSource.memoryStep input actual row point.1 point.2.1 point.2.2 load acc
  else none

def referenceStep (input : PackedArrayMaterialization.GateInput kg ku) (row : Nat)
    (point : Nat × Nat × Nat) (acc : GateAccumulateSource.Dual) : GateAccumulateSource.Dual :=
  let run:=point.1
  let j:=point.2.1*8+point.2.2
  let xv:=GateUpExecution.widen (ArrayStorage.bfWords activation (run*32+j))
  (GateUpExecution.accumulate j (GateWeightSource.value input row run j false) xv acc.1,
   GateUpExecution.accumulate j (GateWeightSource.value input row run j true) xv acc.2)

attribute [local irreducible] GateWeightSource.memoryStep column parseColumn

theorem point_step (input : PackedArrayMaterialization.GateInput kg ku)
    (actual : GateInputSource.Execution source tableBase inputBase) (row : Nat) (rowBound : row<17408)
    (load : M1Max.ThreadgroupLoad) (hardware : M1Max.LoadContract load)
    (point : Nat × Nat × Nat) (bounds : point.1<160 ∧ point.2.1<4 ∧ point.2.2<8) (acc : GateAccumulateSource.Dual) :
    pointStep input actual row load point acc=some (referenceStep (activation:=activation) input row point acc) := by
  unfold pointStep
  rw [parsed_column]
  change (column point.2.1 point.2.2 columnAST).bind _=_
  rw [column_selected ⟨point.2.1,bounds.2.1⟩ ⟨point.2.2,bounds.2.2⟩]
  rw [Option.bind_some,ite_eq_left rfl]
  have result:=GateWeightSource.memory_step input actual row point.1 point.2.1 point.2.2 rowBound bounds.1 bounds.2.1 bounds.2.2 load hardware acc
  simpa only [referenceStep,Nat.add_assoc] using result

-- Generic sequential fold: every event has a successful parsed memory step.
theorem fold_exact {α β : Type} (points : List α) (sourceStep : α → β → Option β)
    (referenceStep : α → β → β) (success : ∀ point ∈ points, ∀ acc, sourceStep point acc=some (referenceStep point acc))
    (initial : β) : points.foldlM (fun acc point => sourceStep point acc) initial=some
      (points.foldl (fun acc point => referenceStep point acc) initial) := by
  induction points generalizing initial with
  | nil => rfl
  | cons point rest ih =>
    simp only [List.foldlM_cons,List.foldl_cons]
    rw [success point (by simp)]
    exact ih (fun p member => success p (by simp [member])) (referenceStep point initial)

def memoryLane (input : PackedArrayMaterialization.GateInput kg ku)
    (actual : GateInputSource.Execution source tableBase inputBase) (row lane : Nat)
    (load : M1Max.ThreadgroupLoad) (initial : GateAccumulateSource.Dual) : Option GateAccumulateSource.Dual := do
  let points ←events lane
  points.foldlM (fun acc point => pointStep input actual row load point acc) initial

theorem memory_lane (input : PackedArrayMaterialization.GateInput kg ku)
    (actual : GateInputSource.Execution source tableBase inputBase) (row lane : Nat)
    (rowBound : row<17408) (laneBound : lane<32) (load : M1Max.ThreadgroupLoad) (hardware : M1Max.LoadContract load)
    (initial : GateAccumulateSource.Dual) :
    memoryLane input actual row lane load initial=some ((orderedEvents lane).foldl
      (fun acc point => referenceStep (activation:=activation) input row point acc) initial) := by
  unfold memoryLane
  rw [events_selected lane laneBound]
  exact fold_exact (orderedEvents lane) (pointStep input actual row load)
    (referenceStep (activation:=activation) input row)
    (fun point member acc => point_step input actual row rowBound load hardware point (event_bounds lane laneBound point member) acc) initial
end Inference.Kernels.Trellis.GateLoopSource
