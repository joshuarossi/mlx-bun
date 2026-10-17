import kernels.delta.GatedPointerSyntax
import kernels.delta.GatedStepSource
import kernels.delta.GatedShared

namespace Inference.Kernels.Delta.GatedPointerSource
open Contracts.Mlx GatedPointerSyntax
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange
set_option maxRecDepth 2000
attribute [local irreducible] parseHeader parseQuery parseValue parseThread parseState parseInitial parseGate

-- The selected native specialization has B=T=1, Dk=Dv=128, Hk=16,
-- Hv=48 and 32 SIMD lanes. These are descriptor/dispatch premises.
def batch (head : Fin 48) : Nat := head.val/48
def valueHead (head : Fin 48) : Nat := head.val%48
def keyHead (head : Fin 48) : Nat := valueHead head/(48/16)
def stateOffset (head : Fin 48) (row key : Fin 128) : Nat := (head.val*128+row.val)*128+key.val
def queryOffset (head : Fin 48) (key : Fin 128) : Nat := batch head*1*16*128+keyHead head*128+key.val
def valueOffset (head : Fin 48) (row : Fin 128) : Nat := batch head*1*48*128+valueHead head*128+row.val
def gateOffset (head : Fin 48) : Nat := batch head*1*48+valueHead head
def slot (lane : Fin 32) (i : Fin 4) : Nat := (128/32)*lane.val+i.val

theorem heads (head : Fin 48) : batch head=0 ∧ valueHead head=head.val ∧ keyHead head=(Layout.keyHead head).val := by
  refine ⟨Nat.div_eq_of_lt head.isLt,Nat.mod_eq_of_lt head.isLt,?_⟩
  unfold keyHead valueHead Layout.keyHead
  rw [Nat.mod_eq_of_lt head.isLt]

theorem query_index (head : Fin 48) (key : Fin 128) :
    queryOffset head key=(GatedInputs.index (Layout.keyHead head) key).val := by
  simp only [queryOffset,(heads head).1,(heads head).2.2,GatedInputs.index,Nat.zero_mul,Nat.zero_add]
theorem value_index (head : Fin 48) (row : Fin 128) :
    valueOffset head row=(GatedInputs.index head row).val := by
  simp only [valueOffset,(heads head).1,(heads head).2.1,GatedInputs.index,Nat.zero_mul,Nat.zero_add]
theorem gate_index (head : Fin 48) : gateOffset head=head.val := by
  simp only [gateOffset,(heads head).1,(heads head).2.1,Nat.zero_mul,Nat.zero_add]
theorem slot_index (lane : Fin 32) (i : Fin 4) : slot lane i=(Gated.laneIndex lane i).val := by
  dsimp [slot,Gated.laneIndex]
  omega
theorem state_index (head : Fin 48) (row key : Fin 128) : stateOffset head row key=GatedStores.stateIndex head row key := rfl

theorem offset_ranges (head : Fin 48) (row key : Fin 128) (lane : Fin 32) (i : Fin 4) :
    stateOffset head row key<786432 ∧ queryOffset head key<2048 ∧ valueOffset head row<6144 ∧
      gateOffset head<48 ∧ slot lane i<128 := by
  rw [state_index,query_index,value_index,gate_index,slot_index]
  exact ⟨GatedStores.state_bounds head row key,(GatedInputs.index (Layout.keyHead head) key).isLt,
    (GatedInputs.index head row).isLt,head.isLt,(Gated.laneIndex lane i).isLt⟩

-- All integer element offsets in the selected specialization fit uint32.
theorem integer_no_wrap (head : Fin 48) (row key : Fin 128) (lane : Fin 32) (i : Fin 4) :
    stateOffset head row key%2^32=stateOffset head row key ∧
    queryOffset head key%2^32=queryOffset head key ∧ valueOffset head row%2^32=valueOffset head row ∧
    gateOffset head%2^32=gateOffset head ∧ slot lane i%2^32=slot lane i := by
  obtain ⟨a,b,c,d,e⟩ := offset_ranges head row key lane i
  exact ⟨Nat.mod_eq_of_lt (by omega),Nat.mod_eq_of_lt (by omega),Nat.mod_eq_of_lt (by omega),
    Nat.mod_eq_of_lt (by omega),Nat.mod_eq_of_lt (by omega)⟩

variable {initial : GatedDevice.State} {values : GatedInputs.Values}

def stateLoad (input : GatedShared.Input initial values) (head : Fin 48) (row key : Fin 128) : Float32 :=
  FloatMemory.load input.state.bytes (input.state.base+4*stateOffset head row key)

def operands (input : GatedShared.Input initial values) (head : Fin 48) (row : Fin 128) : Recurrence.Inputs Float32 where
  key key := BFloat16.widen (Model.ofBits (HalfMemory.load input.state.bytes (input.operands.key.base+2*queryOffset head key)))
  query key := BFloat16.widen (Model.ofBits (HalfMemory.load input.state.bytes (input.operands.query.base+2*queryOffset head key)))
  value := BFloat16.widen (Model.ofBits (HalfMemory.load input.state.bytes (input.operands.value.base+2*valueOffset head row)))
  decay := FloatMemory.load input.state.bytes (input.operands.decay.base+4*gateOffset head)
  beta := BFloat16.widen (Model.ofBits (HalfMemory.load input.state.bytes (input.operands.beta.base+2*gateOffset head)))

theorem state_load (input : GatedShared.Input initial values) (head : Fin 48) (row key : Fin 128) :
    stateLoad input head row key=input.state.read head row key := rfl

theorem operand_loads (input : GatedShared.Input initial values) (head : Fin 48) (row : Fin 128) :
    operands input head row=input.operands.inputs head row := by
  unfold operands GatedInputs.Storage.inputs ArrayStorage.BFBuffer.read ArrayStorage.FloatBuffer.read
  simp only [query_index,value_index,gate_index,input.keyShared,input.queryShared,input.valueShared,input.decayShared,input.betaShared]

def initialRegisters (input : GatedShared.Input initial values) (head : Fin 48) (row : Fin 128)
    (lane : Fin 32) (before : GatedLaneSource.Bank) : GatedLaneSource.Bank :=
  (List.finRange 4).foldl
    (GatedLaneSource.visit (fun i _ => stateLoad input head row (Gated.laneIndex lane i)) (fun _ _ sum => sum)) before

theorem initial_registers (input : GatedShared.Input initial values) (head : Fin 48) (row : Fin 128)
    (lane : Fin 32) (before : GatedLaneSource.Bank) :
    (initialRegisters input head row lane before).state=
      fun i => input.state.read head row (Gated.laneIndex lane i) :=
  (GatedLaneSource.four_visits _ _ before).1

def captured (input : GatedShared.Input initial values) (head : Fin 48) (row : Fin 128) : Nat → Float32 :=
  Recurrence.bind (stateLoad input head row) (operands input head row)

theorem captured_current (input : GatedShared.Input initial values) (head : Fin 48) (row : Fin 128) :
    captured input head row=Recurrence.bind (input.state.read head row) (input.operands.inputs head row) := by
  unfold captured
  rw [operand_loads]
  rfl

def source (input : GatedShared.Input initial values) (head : Fin 48) (row : Fin 128) : Option (Nat → Float32) := do
  let _ ←parseHeader headerSource
  let _ ←parseQuery querySource
  let _ ←parseValue valueSource
  let _ ←parseThread threadSource
  let _ ←parseState stateSource
  let _ ←parseInitial initialSource
  let _ ←parseGate gateSource
  pure (captured input head row)

theorem source_execution (input : GatedShared.Input initial values) (head : Fin 48) (row : Fin 128) :
    source input head row=some (Recurrence.bind (input.state.read head row) (input.operands.inputs head row)) := by
  unfold source
  rw [parsed_header,parsed_query,parsed_value,parsed_thread,parsed_state,parsed_initial,parsed_gate]
  change some (captured input head row)=_
  rw [captured_current]

theorem current_state_address (input : GatedShared.Input initial values) (head : Fin 48) (row key : Fin 128) :
    (input.state.base+4*stateOffset head row key)%4=0 ∧
      input.state.base+4*stateOffset head row key+4≤2^64 := by
  have := input.state.aligned
  have := input.state.bounded
  have := GatedStores.state_bounds head row key
  rw [state_index]
  omega

end Inference.Kernels.Delta.GatedPointerSource
