import host.route.cert.Row.R1.Data
import host.simgraph.iter.InputsPrefix
import host.sim.compose.a4b.GraphColdCert
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
set_option autoImplicit false
namespace Host.Route.Cert.Row.R1
open Host.Ts Host.Mlx Host.Mlx.SimGraph Host.Mlx.SimGraph.Iter Host.Mlx.FfiEval

/-! # POST row `r1`: its input table, in bounded pieces -/

/-- The caches the row starts from. -/
def ps : List (Option Nat × Option Nat) :=
  Host.Load.Run.Full.Expected.cacheOutputs.map fun q =>
    (some (certAt Host.Ts.Sim.Compose.ColdGraph.choice.cert q.1), some (certAt Host.Ts.Sim.Compose.ColdGraph.choice.cert q.2))

kernel_rfl inputs_part0 : InputsOkAt 15235 ((choice.inputs.drop 0).take 64) ps 17777 = true
kernel_rfl inputs_part1 : InputsOkAt 15235 ((choice.inputs.drop 64).take 64) ps 17777 = true
kernel_rfl inputs_part2 : InputsOkAt 15235 ((choice.inputs.drop 128).take 64) ps 17777 = true
kernel_rfl inputs_part3 : InputsOkAt 15235 ((choice.inputs.drop 192).take 64) ps 17777 = true
kernel_rfl inputs_part4 : InputsOkAt 15235 ((choice.inputs.drop 256).take 64) ps 17777 = true
kernel_rfl inputs_part5 : InputsOkAt 15235 ((choice.inputs.drop 320).take 64) ps 17777 = true
kernel_rfl inputs_part6 : InputsOkAt 15235 ((choice.inputs.drop 384).take 64) ps 17777 = true
kernel_rfl inputs_part7 : InputsOkAt 15235 ((choice.inputs.drop 448).take 64) ps 17777 = true
kernel_rfl inputs_part8 : InputsOkAt 15235 ((choice.inputs.drop 512).take 64) ps 17777 = true
kernel_rfl inputs_part9 : InputsOkAt 15235 ((choice.inputs.drop 576).take 64) ps 17777 = true
kernel_rfl inputs_part10 : InputsOkAt 15235 ((choice.inputs.drop 640).take 64) ps 17777 = true
kernel_rfl inputs_part11 : InputsOkAt 15235 ((choice.inputs.drop 704).take 64) ps 17777 = true
kernel_rfl inputs_part12 : InputsOkAt 15235 ((choice.inputs.drop 768).take 64) ps 17777 = true
kernel_rfl inputs_part13 : InputsOkAt 15235 ((choice.inputs.drop 832).take 64) ps 17777 = true
kernel_rfl inputs_part14 : InputsOkAt 15235 ((choice.inputs.drop 896).take 64) ps 17777 = true
kernel_rfl inputs_part15 : InputsOkAt 15235 ((choice.inputs.drop 960).take 64) ps 17777 = true
kernel_rfl inputs_part16 : InputsOkAt 15235 ((choice.inputs.drop 1024).take 64) ps 17777 = true
kernel_rfl inputs_part17 : InputsOkAt 15235 ((choice.inputs.drop 1088).take 64) ps 17777 = true
kernel_rfl inputs_part18 : InputsOkAt 15235 ((choice.inputs.drop 1152).take 64) ps 17777 = true
kernel_rfl inputs_part19 : InputsOkAt 15235 ((choice.inputs.drop 1216).take 64) ps 17777 = true
kernel_rfl inputs_part20 : InputsOkAt 15235 ((choice.inputs.drop 1280).take 64) ps 17777 = true
kernel_rfl inputs_part21 : InputsOkAt 15235 ((choice.inputs.drop 1344).take 64) ps 17777 = true
kernel_rfl inputs_part22 : InputsOkAt 15235 ((choice.inputs.drop 1408).take 64) ps 17777 = true
kernel_rfl inputs_part23 : InputsOkAt 15235 ((choice.inputs.drop 1472).take 64) ps 17777 = true
kernel_rfl inputs_part24 : InputsOkAt 15235 ((choice.inputs.drop 1536).take 64) ps 17777 = true
kernel_rfl inputs_part25 : InputsOkAt 15235 ((choice.inputs.drop 1600).take 64) ps 17777 = true
kernel_rfl inputs_part26 : InputsOkAt 15235 ((choice.inputs.drop 1664).take 64) ps 17777 = true
kernel_rfl inputs_part27 : InputsOkAt 15235 ((choice.inputs.drop 1728).take 64) ps 17777 = true
kernel_rfl inputs_part28 : InputsOkAt 15235 ((choice.inputs.drop 1792).take 64) ps 17777 = true
kernel_rfl inputs_part29 : InputsOkAt 15235 (choice.inputs.drop 1856) ps 17777 = true

theorem inputs_tail29 : InputsOkAt 15235 (choice.inputs.drop 1856) ps 17777 = true := inputs_part29

theorem inputs_tail28 : InputsOkAt 15235 (choice.inputs.drop 1792) ps 17777 = true := by
  apply inputsOkAt_of_take_drop 15235 64
  · exact inputs_part28
  · simpa only [List.drop_drop] using inputs_tail29

theorem inputs_tail27 : InputsOkAt 15235 (choice.inputs.drop 1728) ps 17777 = true := by
  apply inputsOkAt_of_take_drop 15235 64
  · exact inputs_part27
  · simpa only [List.drop_drop] using inputs_tail28

theorem inputs_tail26 : InputsOkAt 15235 (choice.inputs.drop 1664) ps 17777 = true := by
  apply inputsOkAt_of_take_drop 15235 64
  · exact inputs_part26
  · simpa only [List.drop_drop] using inputs_tail27

theorem inputs_tail25 : InputsOkAt 15235 (choice.inputs.drop 1600) ps 17777 = true := by
  apply inputsOkAt_of_take_drop 15235 64
  · exact inputs_part25
  · simpa only [List.drop_drop] using inputs_tail26

theorem inputs_tail24 : InputsOkAt 15235 (choice.inputs.drop 1536) ps 17777 = true := by
  apply inputsOkAt_of_take_drop 15235 64
  · exact inputs_part24
  · simpa only [List.drop_drop] using inputs_tail25

theorem inputs_tail23 : InputsOkAt 15235 (choice.inputs.drop 1472) ps 17777 = true := by
  apply inputsOkAt_of_take_drop 15235 64
  · exact inputs_part23
  · simpa only [List.drop_drop] using inputs_tail24

theorem inputs_tail22 : InputsOkAt 15235 (choice.inputs.drop 1408) ps 17777 = true := by
  apply inputsOkAt_of_take_drop 15235 64
  · exact inputs_part22
  · simpa only [List.drop_drop] using inputs_tail23

theorem inputs_tail21 : InputsOkAt 15235 (choice.inputs.drop 1344) ps 17777 = true := by
  apply inputsOkAt_of_take_drop 15235 64
  · exact inputs_part21
  · simpa only [List.drop_drop] using inputs_tail22

theorem inputs_tail20 : InputsOkAt 15235 (choice.inputs.drop 1280) ps 17777 = true := by
  apply inputsOkAt_of_take_drop 15235 64
  · exact inputs_part20
  · simpa only [List.drop_drop] using inputs_tail21

theorem inputs_tail19 : InputsOkAt 15235 (choice.inputs.drop 1216) ps 17777 = true := by
  apply inputsOkAt_of_take_drop 15235 64
  · exact inputs_part19
  · simpa only [List.drop_drop] using inputs_tail20

theorem inputs_tail18 : InputsOkAt 15235 (choice.inputs.drop 1152) ps 17777 = true := by
  apply inputsOkAt_of_take_drop 15235 64
  · exact inputs_part18
  · simpa only [List.drop_drop] using inputs_tail19

theorem inputs_tail17 : InputsOkAt 15235 (choice.inputs.drop 1088) ps 17777 = true := by
  apply inputsOkAt_of_take_drop 15235 64
  · exact inputs_part17
  · simpa only [List.drop_drop] using inputs_tail18

theorem inputs_tail16 : InputsOkAt 15235 (choice.inputs.drop 1024) ps 17777 = true := by
  apply inputsOkAt_of_take_drop 15235 64
  · exact inputs_part16
  · simpa only [List.drop_drop] using inputs_tail17

theorem inputs_tail15 : InputsOkAt 15235 (choice.inputs.drop 960) ps 17777 = true := by
  apply inputsOkAt_of_take_drop 15235 64
  · exact inputs_part15
  · simpa only [List.drop_drop] using inputs_tail16

theorem inputs_tail14 : InputsOkAt 15235 (choice.inputs.drop 896) ps 17777 = true := by
  apply inputsOkAt_of_take_drop 15235 64
  · exact inputs_part14
  · simpa only [List.drop_drop] using inputs_tail15

theorem inputs_tail13 : InputsOkAt 15235 (choice.inputs.drop 832) ps 17777 = true := by
  apply inputsOkAt_of_take_drop 15235 64
  · exact inputs_part13
  · simpa only [List.drop_drop] using inputs_tail14

theorem inputs_tail12 : InputsOkAt 15235 (choice.inputs.drop 768) ps 17777 = true := by
  apply inputsOkAt_of_take_drop 15235 64
  · exact inputs_part12
  · simpa only [List.drop_drop] using inputs_tail13

theorem inputs_tail11 : InputsOkAt 15235 (choice.inputs.drop 704) ps 17777 = true := by
  apply inputsOkAt_of_take_drop 15235 64
  · exact inputs_part11
  · simpa only [List.drop_drop] using inputs_tail12

theorem inputs_tail10 : InputsOkAt 15235 (choice.inputs.drop 640) ps 17777 = true := by
  apply inputsOkAt_of_take_drop 15235 64
  · exact inputs_part10
  · simpa only [List.drop_drop] using inputs_tail11

theorem inputs_tail9 : InputsOkAt 15235 (choice.inputs.drop 576) ps 17777 = true := by
  apply inputsOkAt_of_take_drop 15235 64
  · exact inputs_part9
  · simpa only [List.drop_drop] using inputs_tail10

theorem inputs_tail8 : InputsOkAt 15235 (choice.inputs.drop 512) ps 17777 = true := by
  apply inputsOkAt_of_take_drop 15235 64
  · exact inputs_part8
  · simpa only [List.drop_drop] using inputs_tail9

theorem inputs_tail7 : InputsOkAt 15235 (choice.inputs.drop 448) ps 17777 = true := by
  apply inputsOkAt_of_take_drop 15235 64
  · exact inputs_part7
  · simpa only [List.drop_drop] using inputs_tail8

theorem inputs_tail6 : InputsOkAt 15235 (choice.inputs.drop 384) ps 17777 = true := by
  apply inputsOkAt_of_take_drop 15235 64
  · exact inputs_part6
  · simpa only [List.drop_drop] using inputs_tail7

theorem inputs_tail5 : InputsOkAt 15235 (choice.inputs.drop 320) ps 17777 = true := by
  apply inputsOkAt_of_take_drop 15235 64
  · exact inputs_part5
  · simpa only [List.drop_drop] using inputs_tail6

theorem inputs_tail4 : InputsOkAt 15235 (choice.inputs.drop 256) ps 17777 = true := by
  apply inputsOkAt_of_take_drop 15235 64
  · exact inputs_part4
  · simpa only [List.drop_drop] using inputs_tail5

theorem inputs_tail3 : InputsOkAt 15235 (choice.inputs.drop 192) ps 17777 = true := by
  apply inputsOkAt_of_take_drop 15235 64
  · exact inputs_part3
  · simpa only [List.drop_drop] using inputs_tail4

theorem inputs_tail2 : InputsOkAt 15235 (choice.inputs.drop 128) ps 17777 = true := by
  apply inputsOkAt_of_take_drop 15235 64
  · exact inputs_part2
  · simpa only [List.drop_drop] using inputs_tail3

theorem inputs_tail1 : InputsOkAt 15235 (choice.inputs.drop 64) ps 17777 = true := by
  apply inputsOkAt_of_take_drop 15235 64
  · exact inputs_part1
  · simpa only [List.drop_drop] using inputs_tail2

theorem inputs_tail0 : InputsOkAt 15235 (choice.inputs.drop 0) ps 17777 = true := by
  apply inputsOkAt_of_take_drop 15235 64
  · exact inputs_part0
  · simpa only [List.drop_drop] using inputs_tail1

theorem inputs_prefix : InputsOkAt 15235 choice.inputs ps 17777 = true := by
  simpa only [List.drop_zero] using inputs_tail0

end Host.Route.Cert.Row.R1
