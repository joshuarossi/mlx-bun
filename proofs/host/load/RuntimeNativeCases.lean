import host.load.RuntimeDriver
import host.mlx.OrdinaryVectorStates
import host.mlx.OrdinaryConcatStates
import host.mlx.OrdinaryFreeStates
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
namespace Host.Load.Run.Full.Ordinary.SourceNativeCases
host_source_step P.F, P.RestStream.micro0.micro2.s23 using P.RestStream.micro0.micro2.S23
  to P.RestStream.micro0.micro2.s24 using P.RestStream.micro0.micro2.S24 as Handles223
host_source_step P.F, P.RestStream.micro0.micro2.s47 using P.RestStream.micro0.micro2.S47
  to P.RestStream.micro0.micro2.s48 using P.RestStream.micro0.micro2.S48 as BigInt247
host_source_step P.F, P.RestStream.micro0.micro2.s49 using P.RestStream.micro0.micro2.S49
  to P.RestStream.micro0.micro2.s50 using P.RestStream.micro0.micro2.S50 as Vector249
host_source_step P.F, P.RestStream.micro0.micro2.s54 using P.RestStream.micro0.micro2.S54
  to P.RestStream.micro0.micro2.s55 using P.RestStream.micro0.micro2.S55 as Try254
host_source_step P.F, P.RestStream.micro0.micro2.s77 using P.RestStream.micro0.micro2.S77
  to P.RestStream.micro0.micro2.s78 using P.RestStream.micro0.micro2.S78 as Missing277
host_source_step P.F, P.RestStream.micro0.micro2.s84 using P.RestStream.micro0.micro2.S84
  to P.RestStream.micro0.micro2.s85 using P.RestStream.micro0.micro2.S85 as Undefined284
host_source_step P.F, P.RestStream.micro0.micro2.s95 using P.RestStream.micro0.micro2.S95
  to P.RestStream.micro0.micro2.s96 using P.RestStream.micro0.micro2.S96 as Null295
host_source_step P.F, P.RestStream.micro0.micro2.s98 using P.RestStream.micro0.micro2.S98
  to P.RestStream.micro0.micro2.s99 using P.RestStream.micro0.micro2.S99 as Zero298
host_source_step P.F, P.RestStream.micro0.micro3.s9 using P.RestStream.micro0.micro3.S9
  to P.RestStream.micro0.micro3.s10 using P.RestStream.micro0.micro3.S10 as Pointer309
host_source_step P.F, P.RestStream.micro0.micro3.s36 using P.RestStream.micro0.micro3.S36
  to P.RestStream.micro0.micro3.s37 using P.RestStream.micro0.micro3.S37 as Concat336
host_source_step P.F, P.RestStream.micro0.micro3.s52 using P.RestStream.micro0.micro3.S52
  to P.RestStream.micro0.micro3.s53 using P.RestStream.micro0.micro3.S53 as Read352
host_source_step P.F, P.RestStream.micro0.micro3.s72 using P.RestStream.micro0.micro3.S72
  to P.RestStream.micro0.micro3.s73 using P.RestStream.micro0.micro3.S73 as Class372
host_source_step P.F, P.RestStream.micro0.micro3.s73 using P.RestStream.micro0.micro3.S73
  to P.RestStream.micro0.micro3.s74 using P.RestStream.micro0.micro3.S74 as Fields373
host_source_step P.F, P.RestStream.micro0.micro3.s75 using P.RestStream.micro0.micro3.S75
  to P.RestStream.micro0.micro3.s76 using P.RestStream.micro0.micro3.S76 as Field375
host_source_step P.F, P.RestStream.micro0.micro3.s77 using P.RestStream.micro0.micro3.S77
  to P.RestStream.micro0.micro3.s78 using P.RestStream.micro0.micro3.S78 as Field377
host_source_step P.F, P.RestStream.micro0.micro3.s79 using P.RestStream.micro0.micro3.S79
  to P.RestStream.micro0.micro3.s80 using P.RestStream.micro0.micro3.S80 as Field379
host_source_step P.F, P.RestStream.micro0.micro3.s80 using P.RestStream.micro0.micro3.S80
  to P.RestStream.micro0.micro3.s81 using P.RestStream.micro0.micro3.S81 as Constructor380
host_source_step P.F, P.RestStream.micro0.micro3.s86 using P.RestStream.micro0.micro3.S86
  to P.RestStream.micro0.micro3.s87 using P.RestStream.micro0.micro3.S87 as PrivateDescent386
host_source_step P.F, P.RestStream.micro0.micro3.s88 using P.RestStream.micro0.micro3.S88
  to P.RestStream.micro0.micro3.s89 using P.RestStream.micro0.micro3.S89 as PrivateReceiver388
host_source_step P.F, P.RestStream.micro0.micro3.s90 using P.RestStream.micro0.micro3.S90
  to P.RestStream.micro0.micro3.s91 using P.RestStream.micro0.micro3.S91 as PrivateStore390
host_source_step P.F, P.RestStream.micro0.micro3.s95 using P.RestStream.micro0.micro3.S95
  to P.RestStream.micro0.micro3.s96 using P.RestStream.micro0.micro3.S96 as Register395

open Host.Ts Host.Ts.Owned.Parametric in
theorem register_receiver : Register395.output.stack =
    .c (.method (.obj Register395.sourceAddress) Register395.sourceArgs Register395.sourceEnv Register395.sourceOptCall)::Register395.sourceTail := by
  host_kernel_rfl

open Lean Elab Command in
run_cmd do
  let saved : Lean.Elab.Command.State ← get
  let mut rejected := false
  try Host.Ts.Owned.Parametric.Driver.emit "open Host.Ts Host.Ts.Owned.Parametric in theorem wrong_register_receiver : Register395.output.stack = .c (.method (.obj Register395.path1Address) Register395.sourceArgs Register395.sourceEnv Register395.sourceOptCall)::Register395.sourceTail := by host_kernel_rfl"
  catch exception =>
    let message ← exception.toMessageData.toString
    rejected := (message.splitOn "kernel").length > 1
  for message in (← get).messages.toList do
    let rendered ← message.data.toString
    if (rendered.splitOn "kernel").length > 1 then rejected := true
  set saved
  unless rejected do throwError "prototype lookup replaced the original register receiver"

host_source_step P.F, P.RestStream.micro0.micro4.s5 using P.RestStream.micro0.micro4.S5
  to P.RestStream.micro0.micro4.s6 using P.RestStream.micro0.micro4.S6 as Registry405
host_source_step P.F, P.RestStream.micro0.micro4.s8 using P.RestStream.micro0.micro4.S8
  to P.RestStream.micro0.micro4.s9 using P.RestStream.micro0.micro4.S9 as ConstructorReturn408
host_source_step P.F, P.RestStream.micro0.micro4.s12 using P.RestStream.micro0.micro4.S12
  to P.RestStream.micro0.micro4.s13 using P.RestStream.micro0.micro4.S13 as Finally412
host_source_step P.F, P.RestStream.micro0.micro4.s21 using P.RestStream.micro0.micro4.S21
  to P.RestStream.micro0.micro4.s22 using P.RestStream.micro0.micro4.S22 as Free421
host_source_step P.F, P.RestStream.micro0.micro4.s24 using P.RestStream.micro0.micro4.S24
  to P.RestStream.micro0.micro4.s25 using P.RestStream.micro0.micro4.S25 as Resume424
host_source_step P.F, P.RestStream.micro0.micro4.s84 using P.RestStream.micro0.micro4.S84
  to P.RestStream.micro0.micro4.s85 using P.RestStream.micro0.micro4.S85 as Rank484
host_source_step P.F, P.RestStream.micro0.micro4.s86 using P.RestStream.micro0.micro4.S86
  to P.RestStream.micro0.micro4.s87 using P.RestStream.micro0.micro4.S87 as Number486
host_source_step P.F, P.RestStream.micro0.micro5.s29 using P.RestStream.micro0.micro5.S29
  to P.RestStream.micro0.micro5.s30 using P.RestStream.micro0.micro5.S30 as Shape529
host_source_step P.F, P.RestStream.micro0.micro5.s35 using P.RestStream.micro0.micro5.S35
  to P.RestStream.micro0.micro5.s36 using P.RestStream.micro0.micro5.S36 as Spread535
end Host.Load.Run.Full.Ordinary.SourceNativeCases
