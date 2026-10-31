import host.sim.compose.a4b.GraphColdCacheValues
import host.sim.compose.a4b.GraphColdInputBase
import host.sim.compose.a4b.GraphColdInputRange0
import host.sim.compose.a4b.GraphColdInputRange1
import host.sim.compose.a4b.GraphColdInputRange2
import host.sim.compose.a4b.GraphColdInputRange3
import host.sim.compose.a4b.GraphColdEndpoint0
import host.sim.compose.a4b.GraphColdEndpoint1
import host.sim.compose.a4b.GraphColdEndpoint2
import host.sim.compose.a4b.GraphColdEndpoint3
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
namespace Host.Ts.Sim.Compose.ColdGraph
open _root_.Host.Ts _root_.Host.Ts.Sim _root_.Host.Load _root_.Host.Load.Extract
open _root_.Host.Load.Run.Full _root_.Host.Mlx _root_.Host.Mlx.FfiEval _root_.Host.Mlx.SimGraph
open _root_.Host.Mlx.SimGraph.Iter

theorem inputs_tail28 : InputsOkAt 15235 (choice.inputs.drop 1792) cacheInputs tokenNode = true := by
  apply inputsOkAt_of_take_drop 15235 64
  · exact inputs_part28
  · simpa only [List.drop_drop] using inputs_tail29
theorem inputs_tail27 : InputsOkAt 15235 (choice.inputs.drop 1728) cacheInputs tokenNode = true := by
  apply inputsOkAt_of_take_drop 15235 64
  · exact inputs_part27
  · simpa only [List.drop_drop] using inputs_tail28
theorem inputs_tail26 : InputsOkAt 15235 (choice.inputs.drop 1664) cacheInputs tokenNode = true := by
  apply inputsOkAt_of_take_drop 15235 64
  · exact inputs_part26
  · simpa only [List.drop_drop] using inputs_tail27
theorem inputs_tail25 : InputsOkAt 15235 (choice.inputs.drop 1600) cacheInputs tokenNode = true := by
  apply inputsOkAt_of_take_drop 15235 64
  · exact inputs_part25
  · simpa only [List.drop_drop] using inputs_tail26
theorem inputs_tail24 : InputsOkAt 15235 (choice.inputs.drop 1536) cacheInputs tokenNode = true := by
  apply inputsOkAt_of_take_drop 15235 64
  · exact inputs_part24
  · simpa only [List.drop_drop] using inputs_tail25
theorem inputs_tail23 : InputsOkAt 15235 (choice.inputs.drop 1472) cacheInputs tokenNode = true := by
  apply inputsOkAt_of_take_drop 15235 64
  · exact inputs_part23
  · simpa only [List.drop_drop] using inputs_tail24
theorem inputs_tail22 : InputsOkAt 15235 (choice.inputs.drop 1408) cacheInputs tokenNode = true := by
  apply inputsOkAt_of_take_drop 15235 64
  · exact inputs_part22
  · simpa only [List.drop_drop] using inputs_tail23
theorem inputs_tail21 : InputsOkAt 15235 (choice.inputs.drop 1344) cacheInputs tokenNode = true := by
  apply inputsOkAt_of_take_drop 15235 64
  · exact inputs_part21
  · simpa only [List.drop_drop] using inputs_tail22
theorem inputs_tail20 : InputsOkAt 15235 (choice.inputs.drop 1280) cacheInputs tokenNode = true := by
  apply inputsOkAt_of_take_drop 15235 64
  · exact inputs_part20
  · simpa only [List.drop_drop] using inputs_tail21
theorem inputs_tail19 : InputsOkAt 15235 (choice.inputs.drop 1216) cacheInputs tokenNode = true := by
  apply inputsOkAt_of_take_drop 15235 64
  · exact inputs_part19
  · simpa only [List.drop_drop] using inputs_tail20
theorem inputs_tail18 : InputsOkAt 15235 (choice.inputs.drop 1152) cacheInputs tokenNode = true := by
  apply inputsOkAt_of_take_drop 15235 64
  · exact inputs_part18
  · simpa only [List.drop_drop] using inputs_tail19
theorem inputs_tail17 : InputsOkAt 15235 (choice.inputs.drop 1088) cacheInputs tokenNode = true := by
  apply inputsOkAt_of_take_drop 15235 64
  · exact inputs_part17
  · simpa only [List.drop_drop] using inputs_tail18
theorem inputs_tail16 : InputsOkAt 15235 (choice.inputs.drop 1024) cacheInputs tokenNode = true := by
  apply inputsOkAt_of_take_drop 15235 64
  · exact inputs_part16
  · simpa only [List.drop_drop] using inputs_tail17
theorem inputs_tail15 : InputsOkAt 15235 (choice.inputs.drop 960) cacheInputs tokenNode = true := by
  apply inputsOkAt_of_take_drop 15235 64
  · exact inputs_part15
  · simpa only [List.drop_drop] using inputs_tail16
theorem inputs_tail14 : InputsOkAt 15235 (choice.inputs.drop 896) cacheInputs tokenNode = true := by
  apply inputsOkAt_of_take_drop 15235 64
  · exact inputs_part14
  · simpa only [List.drop_drop] using inputs_tail15
theorem inputs_tail13 : InputsOkAt 15235 (choice.inputs.drop 832) cacheInputs tokenNode = true := by
  apply inputsOkAt_of_take_drop 15235 64
  · exact inputs_part13
  · simpa only [List.drop_drop] using inputs_tail14
theorem inputs_tail12 : InputsOkAt 15235 (choice.inputs.drop 768) cacheInputs tokenNode = true := by
  apply inputsOkAt_of_take_drop 15235 64
  · exact inputs_part12
  · simpa only [List.drop_drop] using inputs_tail13
theorem inputs_tail11 : InputsOkAt 15235 (choice.inputs.drop 704) cacheInputs tokenNode = true := by
  apply inputsOkAt_of_take_drop 15235 64
  · exact inputs_part11
  · simpa only [List.drop_drop] using inputs_tail12
theorem inputs_tail10 : InputsOkAt 15235 (choice.inputs.drop 640) cacheInputs tokenNode = true := by
  apply inputsOkAt_of_take_drop 15235 64
  · exact inputs_part10
  · simpa only [List.drop_drop] using inputs_tail11
theorem inputs_tail9 : InputsOkAt 15235 (choice.inputs.drop 576) cacheInputs tokenNode = true := by
  apply inputsOkAt_of_take_drop 15235 64
  · exact inputs_part9
  · simpa only [List.drop_drop] using inputs_tail10
theorem inputs_tail8 : InputsOkAt 15235 (choice.inputs.drop 512) cacheInputs tokenNode = true := by
  apply inputsOkAt_of_take_drop 15235 64
  · exact inputs_part8
  · simpa only [List.drop_drop] using inputs_tail9
theorem inputs_tail7 : InputsOkAt 15235 (choice.inputs.drop 448) cacheInputs tokenNode = true := by
  apply inputsOkAt_of_take_drop 15235 64
  · exact inputs_part7
  · simpa only [List.drop_drop] using inputs_tail8
theorem inputs_tail6 : InputsOkAt 15235 (choice.inputs.drop 384) cacheInputs tokenNode = true := by
  apply inputsOkAt_of_take_drop 15235 64
  · exact inputs_part6
  · simpa only [List.drop_drop] using inputs_tail7
theorem inputs_tail5 : InputsOkAt 15235 (choice.inputs.drop 320) cacheInputs tokenNode = true := by
  apply inputsOkAt_of_take_drop 15235 64
  · exact inputs_part5
  · simpa only [List.drop_drop] using inputs_tail6
theorem inputs_tail4 : InputsOkAt 15235 (choice.inputs.drop 256) cacheInputs tokenNode = true := by
  apply inputsOkAt_of_take_drop 15235 64
  · exact inputs_part4
  · simpa only [List.drop_drop] using inputs_tail5
theorem inputs_tail3 : InputsOkAt 15235 (choice.inputs.drop 192) cacheInputs tokenNode = true := by
  apply inputsOkAt_of_take_drop 15235 64
  · exact inputs_part3
  · simpa only [List.drop_drop] using inputs_tail4
theorem inputs_tail2 : InputsOkAt 15235 (choice.inputs.drop 128) cacheInputs tokenNode = true := by
  apply inputsOkAt_of_take_drop 15235 64
  · exact inputs_part2
  · simpa only [List.drop_drop] using inputs_tail3
theorem inputs_tail1 : InputsOkAt 15235 (choice.inputs.drop 64) cacheInputs tokenNode = true := by
  apply inputsOkAt_of_take_drop 15235 64
  · exact inputs_part1
  · simpa only [List.drop_drop] using inputs_tail2
theorem inputs_tail0 : InputsOkAt 15235 (choice.inputs.drop 0) cacheInputs tokenNode = true := by
  apply inputsOkAt_of_take_drop 15235 64
  · exact inputs_part0
  · simpa only [List.drop_drop] using inputs_tail1

theorem inputs_prefix : InputsOkAt 15235 choice.inputs cacheInputs tokenNode = true := by
  simpa only [List.drop_zero] using inputs_tail0

/-- Every input carrier, with a fixed parameter prefix and moving token input. -/
theorem input_carriers (σ : Nat → Nat) (hfix : ∀ j, j < 15235 → σ j = j) :
    ∀ key j, insT key = some j →
      inputNode (loadedAt σ cacheInputs) (tensorAt (σ tokenNode)) key = some (σ j) :=
  inputs_at_bound 15235 choice.inputs cacheInputs tokenNode inputs_prefix σ hfix

/-- Source event bytes are those of the arbitrary singleton token sequence. This
is a byte equality, not an assumption that shape-only native data has exact values. -/
theorem incoming_token_bytes {π : List Nat} {K0 : Host.Ts.Sim.Ctx} {x : SegInst Host.Ts.Sim.Full.FF}
    (h : Host.Ts.Sim.Compose.SetupD1.ForwardBook π K0 x) :
    Host.Load.Run.Tpl.D1Typed.bytes π = cellBytes .i32 (π.map (fun k => Cell.num (.lit (F64.ofNat k)))) :=
  h.tokenBytes
end Host.Ts.Sim.Compose.ColdGraph
