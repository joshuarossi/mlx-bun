import host.sim.template.a4pre_d1_body.TraceStep
import host.sim.template.a4pre_d1_body.m.B00
import host.sim.Chunk
import host.sim.template.a4pre_d1_body.m.B07
import host.sim.template.a4pre_d1_body.SizeLift

section -- SN482
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

kernel_rfl D1BodySized.fuel482 : nth? D1BodySized.ks 482 = some 2570
kernel_rfl D1BodySized.checked482 :
  (fun bs : List Byte => runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 2570 D1BodySized.s482 D1BodySized.S482) =
    fun _ => some (D1BodySized.s483, D1BodySized.S483)

theorem D1BodySized.k482 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 2570 D1BodySized.s482 D1BodySized.S482 =
      some (D1BodySized.s483, D1BodySized.S483) := congrFun D1BodySized.checked482 bs

end Host.Load.Run.Tpl
end

section -- SB141
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.segment141 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 12570 D1BodySized.s481 D1BodySized.S481 =
      some (D1BodySized.s483, D1BodySized.S483) := runOk_trans D1BodySized.F (D1BodyTrace.checkedOk bs) 10000 2570 D1BodySized.s481 D1BodySized.s482 D1BodySized.s483 D1BodySized.S481 D1BodySized.S482 D1BodySized.S483 (D1BodySized.k481 bs) (D1BodySized.k482 bs)

kernel_rfl D1BodySized.accepted141 : (fun bs : List Byte =>
  D1BodyTrace.checkedOk bs D1BodySized.s481 D1BodySized.S481) = fun _ => true
kernel_rfl D1BodySized.oracle141 : goodEnum final_cold.r0.ps
  (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S481.oracle = true
kernel_rfl D1BodySized.fuelA142 : nth? D1BodySized.ks 483 = some 1
kernel_rfl D1BodySized.fuelB142 : nth? D1BodySized.ks 484 = some 3
kernel_rfl D1BodySized.stepA142 : interpS (step D1BodySized.F D1BodySized.s483).run D1BodySized.S483 =
  some (D1BodySized.s484, D1BodySized.S484)
kernel_rfl D1BodySized.patchB142 : interpS (Disp.sizeS D1BodySized.F D1BodySized.s484).run D1BodySized.S484 =
  some (D1BodySized.s485, D1BodySized.S485)
kernel_rfl D1BodySized.acceptedP142 : (fun bs : List Byte => D1BodyTrace.checkedOk bs
  D1BodySized.s483 D1BodySized.S483) = fun _ => true
kernel_rfl D1BodySized.haltP142 : isHalt D1BodySized.s483.ctl = false
kernel_rfl D1BodySized.topA142 : Host.Ts.Sim.Compose.noRetBlock D1BodySized.s484 = true
kernel_rfl D1BodySized.inactive142 : (Host.Ts.Sim.Full.bridgeOf D1BodySized.s484.ffi).active = false
/-- Bridge 142's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def D1BodySized.sizeTys142 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s484 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def D1BodySized.sizeArgs142 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s484 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl D1BodySized.sizeA142 : Host.Ts.Sim.Disp.sizeParts D1BodySized.s484 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", D1BodySized.sizeTys142, D1BodySized.sizeArgs142)
kernel_rfl D1BodySized.sizeArgsA142 : Host.Ts.Sim.Disp.sizeArgsOk D1BodySized.s484 = true
kernel_rfl D1BodySized.sizeSymA142 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl D1BodySized.sizeMlxA142 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl D1BodySized.sizePayA142 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl D1BodySized.sizeTaA142 : [2665, 2673479, 2673484, 2673485].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def D1BodySized.sizeDec142 := interpS (decodeArgs D1BodySized.F D1BodySized.s484 D1BodySized.sizeTys142 D1BodySized.sizeArgs142).run D1BodySized.S484
noncomputable def D1BodySized.sizeAs142 : List Arg := match D1BodySized.sizeDec142 with | some (some xs, _) => xs | _ => []
noncomputable def D1BodySized.sizeS0142 : SSrv := match D1BodySized.sizeDec142 with | some (_, S) => S | none => D1BodySized.S484
kernel_rfl D1BodySized.sizeDecA142 : interpS (decodeArgs D1BodySized.F D1BodySized.s484 D1BodySized.sizeTys142 D1BodySized.sizeArgs142).run D1BodySized.S484 =
  some (some D1BodySized.sizeAs142, D1BodySized.sizeS0142)
kernel_rfl D1BodySized.sizePreA142 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB D1BodySized.sizeS0142 D1BodySized.s484.ffi D1BodySized.sizeAs142 = true

end Host.Load.Run.Tpl
end

section -- SN485
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

kernel_rfl D1BodySized.fuel485 : nth? D1BodySized.ks 485 = some 2542
kernel_rfl D1BodySized.checked485 :
  (fun bs : List Byte => runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 2542 D1BodySized.s485 D1BodySized.S485) =
    fun _ => some (D1BodySized.s486, D1BodySized.S486)

theorem D1BodySized.k485 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 2542 D1BodySized.s485 D1BodySized.S485 =
      some (D1BodySized.s486, D1BodySized.S486) := congrFun D1BodySized.checked485 bs

end Host.Load.Run.Tpl
end

section -- SB142
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.segment142 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 2542 D1BodySized.s485 D1BodySized.S485 =
      some (D1BodySized.s486, D1BodySized.S486) := D1BodySized.k485 bs

kernel_rfl D1BodySized.accepted142 : (fun bs : List Byte =>
  D1BodyTrace.checkedOk bs D1BodySized.s485 D1BodySized.S485) = fun _ => true
kernel_rfl D1BodySized.oracle142 : goodEnum final_cold.r0.ps
  (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S485.oracle = true
kernel_rfl D1BodySized.fuelA143 : nth? D1BodySized.ks 486 = some 1
kernel_rfl D1BodySized.fuelB143 : nth? D1BodySized.ks 487 = some 3
kernel_rfl D1BodySized.stepA143 : interpS (step D1BodySized.F D1BodySized.s486).run D1BodySized.S486 =
  some (D1BodySized.s487, D1BodySized.S487)
kernel_rfl D1BodySized.patchB143 : interpS (Disp.sizeS D1BodySized.F D1BodySized.s487).run D1BodySized.S487 =
  some (D1BodySized.s488, D1BodySized.S488)
kernel_rfl D1BodySized.acceptedP143 : (fun bs : List Byte => D1BodyTrace.checkedOk bs
  D1BodySized.s486 D1BodySized.S486) = fun _ => true
kernel_rfl D1BodySized.haltP143 : isHalt D1BodySized.s486.ctl = false
kernel_rfl D1BodySized.topA143 : Host.Ts.Sim.Compose.noRetBlock D1BodySized.s487 = true
kernel_rfl D1BodySized.inactive143 : (Host.Ts.Sim.Full.bridgeOf D1BodySized.s487.ffi).active = false
/-- Bridge 143's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def D1BodySized.sizeTys143 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s487 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def D1BodySized.sizeArgs143 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s487 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl D1BodySized.sizeA143 : Host.Ts.Sim.Disp.sizeParts D1BodySized.s487 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", D1BodySized.sizeTys143, D1BodySized.sizeArgs143)
kernel_rfl D1BodySized.sizeArgsA143 : Host.Ts.Sim.Disp.sizeArgsOk D1BodySized.s487 = true
kernel_rfl D1BodySized.sizeSymA143 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl D1BodySized.sizeMlxA143 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl D1BodySized.sizePayA143 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl D1BodySized.sizeTaA143 : [2665, 2673479, 2673484, 2673485].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def D1BodySized.sizeDec143 := interpS (decodeArgs D1BodySized.F D1BodySized.s487 D1BodySized.sizeTys143 D1BodySized.sizeArgs143).run D1BodySized.S487
noncomputable def D1BodySized.sizeAs143 : List Arg := match D1BodySized.sizeDec143 with | some (some xs, _) => xs | _ => []
noncomputable def D1BodySized.sizeS0143 : SSrv := match D1BodySized.sizeDec143 with | some (_, S) => S | none => D1BodySized.S487
kernel_rfl D1BodySized.sizeDecA143 : interpS (decodeArgs D1BodySized.F D1BodySized.s487 D1BodySized.sizeTys143 D1BodySized.sizeArgs143).run D1BodySized.S487 =
  some (some D1BodySized.sizeAs143, D1BodySized.sizeS0143)
kernel_rfl D1BodySized.sizePreA143 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB D1BodySized.sizeS0143 D1BodySized.s487.ffi D1BodySized.sizeAs143 = true

end Host.Load.Run.Tpl
end

section -- SN488
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

kernel_rfl D1BodySized.fuel488 : nth? D1BodySized.ks 488 = some 7762
kernel_rfl D1BodySized.checked488 :
  (fun bs : List Byte => runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 7762 D1BodySized.s488 D1BodySized.S488) =
    fun _ => some (D1BodySized.s489, D1BodySized.S489)

theorem D1BodySized.k488 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 7762 D1BodySized.s488 D1BodySized.S488 =
      some (D1BodySized.s489, D1BodySized.S489) := congrFun D1BodySized.checked488 bs

end Host.Load.Run.Tpl
end

section -- SB143
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.segment143 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 7762 D1BodySized.s488 D1BodySized.S488 =
      some (D1BodySized.s489, D1BodySized.S489) := D1BodySized.k488 bs

kernel_rfl D1BodySized.accepted143 : (fun bs : List Byte =>
  D1BodyTrace.checkedOk bs D1BodySized.s488 D1BodySized.S488) = fun _ => true
kernel_rfl D1BodySized.oracle143 : goodEnum final_cold.r0.ps
  (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S488.oracle = true
kernel_rfl D1BodySized.fuelA144 : nth? D1BodySized.ks 489 = some 1
kernel_rfl D1BodySized.fuelB144 : nth? D1BodySized.ks 490 = some 3
kernel_rfl D1BodySized.stepA144 : interpS (step D1BodySized.F D1BodySized.s489).run D1BodySized.S489 =
  some (D1BodySized.s490, D1BodySized.S490)
kernel_rfl D1BodySized.patchB144 : interpS (Disp.sizeS D1BodySized.F D1BodySized.s490).run D1BodySized.S490 =
  some (D1BodySized.s491, D1BodySized.S491)
kernel_rfl D1BodySized.acceptedP144 : (fun bs : List Byte => D1BodyTrace.checkedOk bs
  D1BodySized.s489 D1BodySized.S489) = fun _ => true
kernel_rfl D1BodySized.haltP144 : isHalt D1BodySized.s489.ctl = false
kernel_rfl D1BodySized.topA144 : Host.Ts.Sim.Compose.noRetBlock D1BodySized.s490 = true
kernel_rfl D1BodySized.inactive144 : (Host.Ts.Sim.Full.bridgeOf D1BodySized.s490.ffi).active = false
/-- Bridge 144's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def D1BodySized.sizeTys144 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s490 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def D1BodySized.sizeArgs144 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s490 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl D1BodySized.sizeA144 : Host.Ts.Sim.Disp.sizeParts D1BodySized.s490 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", D1BodySized.sizeTys144, D1BodySized.sizeArgs144)
kernel_rfl D1BodySized.sizeArgsA144 : Host.Ts.Sim.Disp.sizeArgsOk D1BodySized.s490 = true
kernel_rfl D1BodySized.sizeSymA144 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl D1BodySized.sizeMlxA144 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl D1BodySized.sizePayA144 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl D1BodySized.sizeTaA144 : [2665, 2673479, 2673484, 2673485].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def D1BodySized.sizeDec144 := interpS (decodeArgs D1BodySized.F D1BodySized.s490 D1BodySized.sizeTys144 D1BodySized.sizeArgs144).run D1BodySized.S490
noncomputable def D1BodySized.sizeAs144 : List Arg := match D1BodySized.sizeDec144 with | some (some xs, _) => xs | _ => []
noncomputable def D1BodySized.sizeS0144 : SSrv := match D1BodySized.sizeDec144 with | some (_, S) => S | none => D1BodySized.S490
kernel_rfl D1BodySized.sizeDecA144 : interpS (decodeArgs D1BodySized.F D1BodySized.s490 D1BodySized.sizeTys144 D1BodySized.sizeArgs144).run D1BodySized.S490 =
  some (some D1BodySized.sizeAs144, D1BodySized.sizeS0144)
kernel_rfl D1BodySized.sizePreA144 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB D1BodySized.sizeS0144 D1BodySized.s490.ffi D1BodySized.sizeAs144 = true

end Host.Load.Run.Tpl
end

section -- SN491
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

kernel_rfl D1BodySized.fuel491 : nth? D1BodySized.ks 491 = some 1936
kernel_rfl D1BodySized.checked491 :
  (fun bs : List Byte => runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 1936 D1BodySized.s491 D1BodySized.S491) =
    fun _ => some (D1BodySized.s492, D1BodySized.S492)

theorem D1BodySized.k491 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 1936 D1BodySized.s491 D1BodySized.S491 =
      some (D1BodySized.s492, D1BodySized.S492) := congrFun D1BodySized.checked491 bs

end Host.Load.Run.Tpl
end

section -- SB144
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.segment144 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 1936 D1BodySized.s491 D1BodySized.S491 =
      some (D1BodySized.s492, D1BodySized.S492) := D1BodySized.k491 bs

kernel_rfl D1BodySized.accepted144 : (fun bs : List Byte =>
  D1BodyTrace.checkedOk bs D1BodySized.s491 D1BodySized.S491) = fun _ => true
kernel_rfl D1BodySized.oracle144 : goodEnum final_cold.r0.ps
  (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S491.oracle = true
kernel_rfl D1BodySized.fuelA145 : nth? D1BodySized.ks 492 = some 1
kernel_rfl D1BodySized.fuelB145 : nth? D1BodySized.ks 493 = some 3
kernel_rfl D1BodySized.stepA145 : interpS (step D1BodySized.F D1BodySized.s492).run D1BodySized.S492 =
  some (D1BodySized.s493, D1BodySized.S493)
kernel_rfl D1BodySized.patchB145 : interpS (Disp.sizeS D1BodySized.F D1BodySized.s493).run D1BodySized.S493 =
  some (D1BodySized.s494, D1BodySized.S494)
kernel_rfl D1BodySized.acceptedP145 : (fun bs : List Byte => D1BodyTrace.checkedOk bs
  D1BodySized.s492 D1BodySized.S492) = fun _ => true
kernel_rfl D1BodySized.haltP145 : isHalt D1BodySized.s492.ctl = false
kernel_rfl D1BodySized.topA145 : Host.Ts.Sim.Compose.noRetBlock D1BodySized.s493 = true
kernel_rfl D1BodySized.inactive145 : (Host.Ts.Sim.Full.bridgeOf D1BodySized.s493.ffi).active = false
/-- Bridge 145's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def D1BodySized.sizeTys145 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s493 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def D1BodySized.sizeArgs145 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s493 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl D1BodySized.sizeA145 : Host.Ts.Sim.Disp.sizeParts D1BodySized.s493 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", D1BodySized.sizeTys145, D1BodySized.sizeArgs145)
kernel_rfl D1BodySized.sizeArgsA145 : Host.Ts.Sim.Disp.sizeArgsOk D1BodySized.s493 = true
kernel_rfl D1BodySized.sizeSymA145 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl D1BodySized.sizeMlxA145 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl D1BodySized.sizePayA145 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl D1BodySized.sizeTaA145 : [2665, 2673479, 2673484, 2673485].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def D1BodySized.sizeDec145 := interpS (decodeArgs D1BodySized.F D1BodySized.s493 D1BodySized.sizeTys145 D1BodySized.sizeArgs145).run D1BodySized.S493
noncomputable def D1BodySized.sizeAs145 : List Arg := match D1BodySized.sizeDec145 with | some (some xs, _) => xs | _ => []
noncomputable def D1BodySized.sizeS0145 : SSrv := match D1BodySized.sizeDec145 with | some (_, S) => S | none => D1BodySized.S493
kernel_rfl D1BodySized.sizeDecA145 : interpS (decodeArgs D1BodySized.F D1BodySized.s493 D1BodySized.sizeTys145 D1BodySized.sizeArgs145).run D1BodySized.S493 =
  some (some D1BodySized.sizeAs145, D1BodySized.sizeS0145)
kernel_rfl D1BodySized.sizePreA145 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB D1BodySized.sizeS0145 D1BodySized.s493.ffi D1BodySized.sizeAs145 = true

end Host.Load.Run.Tpl
end

section -- SN494
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

kernel_rfl D1BodySized.fuel494 : nth? D1BodySized.ks 494 = some 10000
kernel_rfl D1BodySized.checked494 :
  (fun bs : List Byte => runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 10000 D1BodySized.s494 D1BodySized.S494) =
    fun _ => some (D1BodySized.s495, D1BodySized.S495)

theorem D1BodySized.k494 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 10000 D1BodySized.s494 D1BodySized.S494 =
      some (D1BodySized.s495, D1BodySized.S495) := congrFun D1BodySized.checked494 bs

end Host.Load.Run.Tpl
end

section -- SN495
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

kernel_rfl D1BodySized.fuel495 : nth? D1BodySized.ks 495 = some 2570
kernel_rfl D1BodySized.checked495 :
  (fun bs : List Byte => runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 2570 D1BodySized.s495 D1BodySized.S495) =
    fun _ => some (D1BodySized.s496, D1BodySized.S496)

theorem D1BodySized.k495 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 2570 D1BodySized.s495 D1BodySized.S495 =
      some (D1BodySized.s496, D1BodySized.S496) := congrFun D1BodySized.checked495 bs

end Host.Load.Run.Tpl
end

section -- SB145
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.segment145 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 12570 D1BodySized.s494 D1BodySized.S494 =
      some (D1BodySized.s496, D1BodySized.S496) := runOk_trans D1BodySized.F (D1BodyTrace.checkedOk bs) 10000 2570 D1BodySized.s494 D1BodySized.s495 D1BodySized.s496 D1BodySized.S494 D1BodySized.S495 D1BodySized.S496 (D1BodySized.k494 bs) (D1BodySized.k495 bs)

kernel_rfl D1BodySized.accepted145 : (fun bs : List Byte =>
  D1BodyTrace.checkedOk bs D1BodySized.s494 D1BodySized.S494) = fun _ => true
kernel_rfl D1BodySized.oracle145 : goodEnum final_cold.r0.ps
  (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S494.oracle = true
kernel_rfl D1BodySized.fuelA146 : nth? D1BodySized.ks 496 = some 1
kernel_rfl D1BodySized.fuelB146 : nth? D1BodySized.ks 497 = some 3
kernel_rfl D1BodySized.stepA146 : interpS (step D1BodySized.F D1BodySized.s496).run D1BodySized.S496 =
  some (D1BodySized.s497, D1BodySized.S497)
kernel_rfl D1BodySized.patchB146 : interpS (Disp.sizeS D1BodySized.F D1BodySized.s497).run D1BodySized.S497 =
  some (D1BodySized.s498, D1BodySized.S498)
kernel_rfl D1BodySized.acceptedP146 : (fun bs : List Byte => D1BodyTrace.checkedOk bs
  D1BodySized.s496 D1BodySized.S496) = fun _ => true
kernel_rfl D1BodySized.haltP146 : isHalt D1BodySized.s496.ctl = false
kernel_rfl D1BodySized.topA146 : Host.Ts.Sim.Compose.noRetBlock D1BodySized.s497 = true
kernel_rfl D1BodySized.inactive146 : (Host.Ts.Sim.Full.bridgeOf D1BodySized.s497.ffi).active = false
/-- Bridge 146's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def D1BodySized.sizeTys146 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s497 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def D1BodySized.sizeArgs146 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s497 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl D1BodySized.sizeA146 : Host.Ts.Sim.Disp.sizeParts D1BodySized.s497 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", D1BodySized.sizeTys146, D1BodySized.sizeArgs146)
kernel_rfl D1BodySized.sizeArgsA146 : Host.Ts.Sim.Disp.sizeArgsOk D1BodySized.s497 = true
kernel_rfl D1BodySized.sizeSymA146 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl D1BodySized.sizeMlxA146 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl D1BodySized.sizePayA146 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl D1BodySized.sizeTaA146 : [2665, 2673479, 2673484, 2673485].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def D1BodySized.sizeDec146 := interpS (decodeArgs D1BodySized.F D1BodySized.s497 D1BodySized.sizeTys146 D1BodySized.sizeArgs146).run D1BodySized.S497
noncomputable def D1BodySized.sizeAs146 : List Arg := match D1BodySized.sizeDec146 with | some (some xs, _) => xs | _ => []
noncomputable def D1BodySized.sizeS0146 : SSrv := match D1BodySized.sizeDec146 with | some (_, S) => S | none => D1BodySized.S497
kernel_rfl D1BodySized.sizeDecA146 : interpS (decodeArgs D1BodySized.F D1BodySized.s497 D1BodySized.sizeTys146 D1BodySized.sizeArgs146).run D1BodySized.S497 =
  some (some D1BodySized.sizeAs146, D1BodySized.sizeS0146)
kernel_rfl D1BodySized.sizePreA146 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB D1BodySized.sizeS0146 D1BodySized.s497.ffi D1BodySized.sizeAs146 = true

end Host.Load.Run.Tpl
end

section -- SN498
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

kernel_rfl D1BodySized.fuel498 : nth? D1BodySized.ks 498 = some 2542
kernel_rfl D1BodySized.checked498 :
  (fun bs : List Byte => runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 2542 D1BodySized.s498 D1BodySized.S498) =
    fun _ => some (D1BodySized.s499, D1BodySized.S499)

theorem D1BodySized.k498 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 2542 D1BodySized.s498 D1BodySized.S498 =
      some (D1BodySized.s499, D1BodySized.S499) := congrFun D1BodySized.checked498 bs

end Host.Load.Run.Tpl
end

section -- SB146
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.segment146 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 2542 D1BodySized.s498 D1BodySized.S498 =
      some (D1BodySized.s499, D1BodySized.S499) := D1BodySized.k498 bs

kernel_rfl D1BodySized.accepted146 : (fun bs : List Byte =>
  D1BodyTrace.checkedOk bs D1BodySized.s498 D1BodySized.S498) = fun _ => true
kernel_rfl D1BodySized.oracle146 : goodEnum final_cold.r0.ps
  (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S498.oracle = true
kernel_rfl D1BodySized.fuelA147 : nth? D1BodySized.ks 499 = some 1
kernel_rfl D1BodySized.fuelB147 : nth? D1BodySized.ks 500 = some 3
kernel_rfl D1BodySized.stepA147 : interpS (step D1BodySized.F D1BodySized.s499).run D1BodySized.S499 =
  some (D1BodySized.s500, D1BodySized.S500)
kernel_rfl D1BodySized.patchB147 : interpS (Disp.sizeS D1BodySized.F D1BodySized.s500).run D1BodySized.S500 =
  some (D1BodySized.s501, D1BodySized.S501)
kernel_rfl D1BodySized.acceptedP147 : (fun bs : List Byte => D1BodyTrace.checkedOk bs
  D1BodySized.s499 D1BodySized.S499) = fun _ => true
kernel_rfl D1BodySized.haltP147 : isHalt D1BodySized.s499.ctl = false
kernel_rfl D1BodySized.topA147 : Host.Ts.Sim.Compose.noRetBlock D1BodySized.s500 = true
kernel_rfl D1BodySized.inactive147 : (Host.Ts.Sim.Full.bridgeOf D1BodySized.s500.ffi).active = false
/-- Bridge 147's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def D1BodySized.sizeTys147 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s500 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def D1BodySized.sizeArgs147 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s500 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl D1BodySized.sizeA147 : Host.Ts.Sim.Disp.sizeParts D1BodySized.s500 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", D1BodySized.sizeTys147, D1BodySized.sizeArgs147)
kernel_rfl D1BodySized.sizeArgsA147 : Host.Ts.Sim.Disp.sizeArgsOk D1BodySized.s500 = true
kernel_rfl D1BodySized.sizeSymA147 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl D1BodySized.sizeMlxA147 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl D1BodySized.sizePayA147 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl D1BodySized.sizeTaA147 : [2665, 2673479, 2673484, 2673485].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def D1BodySized.sizeDec147 := interpS (decodeArgs D1BodySized.F D1BodySized.s500 D1BodySized.sizeTys147 D1BodySized.sizeArgs147).run D1BodySized.S500
noncomputable def D1BodySized.sizeAs147 : List Arg := match D1BodySized.sizeDec147 with | some (some xs, _) => xs | _ => []
noncomputable def D1BodySized.sizeS0147 : SSrv := match D1BodySized.sizeDec147 with | some (_, S) => S | none => D1BodySized.S500
kernel_rfl D1BodySized.sizeDecA147 : interpS (decodeArgs D1BodySized.F D1BodySized.s500 D1BodySized.sizeTys147 D1BodySized.sizeArgs147).run D1BodySized.S500 =
  some (some D1BodySized.sizeAs147, D1BodySized.sizeS0147)
kernel_rfl D1BodySized.sizePreA147 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB D1BodySized.sizeS0147 D1BodySized.s500.ffi D1BodySized.sizeAs147 = true

end Host.Load.Run.Tpl
end

section -- SN501
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

kernel_rfl D1BodySized.fuel501 : nth? D1BodySized.ks 501 = some 10000
kernel_rfl D1BodySized.checked501 :
  (fun bs : List Byte => runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 10000 D1BodySized.s501 D1BodySized.S501) =
    fun _ => some (D1BodySized.s502, D1BodySized.S502)

theorem D1BodySized.k501 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 10000 D1BodySized.s501 D1BodySized.S501 =
      some (D1BodySized.s502, D1BodySized.S502) := congrFun D1BodySized.checked501 bs

end Host.Load.Run.Tpl
end

section -- SN502
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

kernel_rfl D1BodySized.fuel502 : nth? D1BodySized.ks 502 = some 10000
kernel_rfl D1BodySized.checked502 :
  (fun bs : List Byte => runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 10000 D1BodySized.s502 D1BodySized.S502) =
    fun _ => some (D1BodySized.s503, D1BodySized.S503)

theorem D1BodySized.k502 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 10000 D1BodySized.s502 D1BodySized.S502 =
      some (D1BodySized.s503, D1BodySized.S503) := congrFun D1BodySized.checked502 bs

end Host.Load.Run.Tpl
end

section -- SN503
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

kernel_rfl D1BodySized.fuel503 : nth? D1BodySized.ks 503 = some 2333
kernel_rfl D1BodySized.checked503 :
  (fun bs : List Byte => runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 2333 D1BodySized.s503 D1BodySized.S503) =
    fun _ => some (D1BodySized.s504, D1BodySized.S504)

theorem D1BodySized.k503 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 2333 D1BodySized.s503 D1BodySized.S503 =
      some (D1BodySized.s504, D1BodySized.S504) := congrFun D1BodySized.checked503 bs

end Host.Load.Run.Tpl
end

section -- SB147
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.segment147 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 22333 D1BodySized.s501 D1BodySized.S501 =
      some (D1BodySized.s504, D1BodySized.S504) := runOk_trans D1BodySized.F (D1BodyTrace.checkedOk bs) 20000 2333 D1BodySized.s501 D1BodySized.s503 D1BodySized.s504 D1BodySized.S501 D1BodySized.S503 D1BodySized.S504 (runOk_trans D1BodySized.F (D1BodyTrace.checkedOk bs) 10000 10000 D1BodySized.s501 D1BodySized.s502 D1BodySized.s503 D1BodySized.S501 D1BodySized.S502 D1BodySized.S503 (D1BodySized.k501 bs) (D1BodySized.k502 bs)) (D1BodySized.k503 bs)

kernel_rfl D1BodySized.accepted147 : (fun bs : List Byte =>
  D1BodyTrace.checkedOk bs D1BodySized.s501 D1BodySized.S501) = fun _ => true
kernel_rfl D1BodySized.oracle147 : goodEnum final_cold.r0.ps
  (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S501.oracle = true
kernel_rfl D1BodySized.fuelA148 : nth? D1BodySized.ks 504 = some 1
kernel_rfl D1BodySized.fuelB148 : nth? D1BodySized.ks 505 = some 3
kernel_rfl D1BodySized.stepA148 : interpS (step D1BodySized.F D1BodySized.s504).run D1BodySized.S504 =
  some (D1BodySized.s505, D1BodySized.S505)
kernel_rfl D1BodySized.patchB148 : interpS (Disp.sizeS D1BodySized.F D1BodySized.s505).run D1BodySized.S505 =
  some (D1BodySized.s506, D1BodySized.S506)
kernel_rfl D1BodySized.acceptedP148 : (fun bs : List Byte => D1BodyTrace.checkedOk bs
  D1BodySized.s504 D1BodySized.S504) = fun _ => true
kernel_rfl D1BodySized.haltP148 : isHalt D1BodySized.s504.ctl = false
kernel_rfl D1BodySized.topA148 : Host.Ts.Sim.Compose.noRetBlock D1BodySized.s505 = true
kernel_rfl D1BodySized.inactive148 : (Host.Ts.Sim.Full.bridgeOf D1BodySized.s505.ffi).active = false
/-- Bridge 148's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def D1BodySized.sizeTys148 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s505 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def D1BodySized.sizeArgs148 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s505 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl D1BodySized.sizeA148 : Host.Ts.Sim.Disp.sizeParts D1BodySized.s505 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", D1BodySized.sizeTys148, D1BodySized.sizeArgs148)
kernel_rfl D1BodySized.sizeArgsA148 : Host.Ts.Sim.Disp.sizeArgsOk D1BodySized.s505 = true
kernel_rfl D1BodySized.sizeSymA148 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl D1BodySized.sizeMlxA148 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl D1BodySized.sizePayA148 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl D1BodySized.sizeTaA148 : [2665, 2673479, 2673484, 2673485].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def D1BodySized.sizeDec148 := interpS (decodeArgs D1BodySized.F D1BodySized.s505 D1BodySized.sizeTys148 D1BodySized.sizeArgs148).run D1BodySized.S505
noncomputable def D1BodySized.sizeAs148 : List Arg := match D1BodySized.sizeDec148 with | some (some xs, _) => xs | _ => []
noncomputable def D1BodySized.sizeS0148 : SSrv := match D1BodySized.sizeDec148 with | some (_, S) => S | none => D1BodySized.S505
kernel_rfl D1BodySized.sizeDecA148 : interpS (decodeArgs D1BodySized.F D1BodySized.s505 D1BodySized.sizeTys148 D1BodySized.sizeArgs148).run D1BodySized.S505 =
  some (some D1BodySized.sizeAs148, D1BodySized.sizeS0148)
kernel_rfl D1BodySized.sizePreA148 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB D1BodySized.sizeS0148 D1BodySized.s505.ffi D1BodySized.sizeAs148 = true

end Host.Load.Run.Tpl
end

section -- SN506
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

kernel_rfl D1BodySized.fuel506 : nth? D1BodySized.ks 506 = some 7980
kernel_rfl D1BodySized.checked506 :
  (fun bs : List Byte => runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 7980 D1BodySized.s506 D1BodySized.S506) =
    fun _ => some (D1BodySized.s507, D1BodySized.S507)

theorem D1BodySized.k506 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 7980 D1BodySized.s506 D1BodySized.S506 =
      some (D1BodySized.s507, D1BodySized.S507) := congrFun D1BodySized.checked506 bs

end Host.Load.Run.Tpl
end

section -- SB148
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.segment148 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 7980 D1BodySized.s506 D1BodySized.S506 =
      some (D1BodySized.s507, D1BodySized.S507) := D1BodySized.k506 bs

kernel_rfl D1BodySized.accepted148 : (fun bs : List Byte =>
  D1BodyTrace.checkedOk bs D1BodySized.s506 D1BodySized.S506) = fun _ => true
kernel_rfl D1BodySized.oracle148 : goodEnum final_cold.r0.ps
  (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S506.oracle = true
kernel_rfl D1BodySized.fuelA149 : nth? D1BodySized.ks 507 = some 1
kernel_rfl D1BodySized.fuelB149 : nth? D1BodySized.ks 508 = some 3
kernel_rfl D1BodySized.stepA149 : interpS (step D1BodySized.F D1BodySized.s507).run D1BodySized.S507 =
  some (D1BodySized.s508, D1BodySized.S508)
kernel_rfl D1BodySized.patchB149 : interpS (Disp.sizeS D1BodySized.F D1BodySized.s508).run D1BodySized.S508 =
  some (D1BodySized.s509, D1BodySized.S509)
kernel_rfl D1BodySized.acceptedP149 : (fun bs : List Byte => D1BodyTrace.checkedOk bs
  D1BodySized.s507 D1BodySized.S507) = fun _ => true
kernel_rfl D1BodySized.haltP149 : isHalt D1BodySized.s507.ctl = false
kernel_rfl D1BodySized.topA149 : Host.Ts.Sim.Compose.noRetBlock D1BodySized.s508 = true
kernel_rfl D1BodySized.inactive149 : (Host.Ts.Sim.Full.bridgeOf D1BodySized.s508.ffi).active = false
/-- Bridge 149's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def D1BodySized.sizeTys149 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s508 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def D1BodySized.sizeArgs149 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s508 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl D1BodySized.sizeA149 : Host.Ts.Sim.Disp.sizeParts D1BodySized.s508 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", D1BodySized.sizeTys149, D1BodySized.sizeArgs149)
kernel_rfl D1BodySized.sizeArgsA149 : Host.Ts.Sim.Disp.sizeArgsOk D1BodySized.s508 = true
kernel_rfl D1BodySized.sizeSymA149 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl D1BodySized.sizeMlxA149 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl D1BodySized.sizePayA149 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl D1BodySized.sizeTaA149 : [2665, 2673479, 2673484, 2673485].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def D1BodySized.sizeDec149 := interpS (decodeArgs D1BodySized.F D1BodySized.s508 D1BodySized.sizeTys149 D1BodySized.sizeArgs149).run D1BodySized.S508
noncomputable def D1BodySized.sizeAs149 : List Arg := match D1BodySized.sizeDec149 with | some (some xs, _) => xs | _ => []
noncomputable def D1BodySized.sizeS0149 : SSrv := match D1BodySized.sizeDec149 with | some (_, S) => S | none => D1BodySized.S508
kernel_rfl D1BodySized.sizeDecA149 : interpS (decodeArgs D1BodySized.F D1BodySized.s508 D1BodySized.sizeTys149 D1BodySized.sizeArgs149).run D1BodySized.S508 =
  some (some D1BodySized.sizeAs149, D1BodySized.sizeS0149)
kernel_rfl D1BodySized.sizePreA149 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB D1BodySized.sizeS0149 D1BodySized.s508.ffi D1BodySized.sizeAs149 = true

end Host.Load.Run.Tpl
end

section -- SN509
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

kernel_rfl D1BodySized.fuel509 : nth? D1BodySized.ks 509 = some 1936
kernel_rfl D1BodySized.checked509 :
  (fun bs : List Byte => runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 1936 D1BodySized.s509 D1BodySized.S509) =
    fun _ => some (D1BodySized.s510, D1BodySized.S510)

theorem D1BodySized.k509 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 1936 D1BodySized.s509 D1BodySized.S509 =
      some (D1BodySized.s510, D1BodySized.S510) := congrFun D1BodySized.checked509 bs

end Host.Load.Run.Tpl
end

section -- SB149
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.segment149 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 1936 D1BodySized.s509 D1BodySized.S509 =
      some (D1BodySized.s510, D1BodySized.S510) := D1BodySized.k509 bs

kernel_rfl D1BodySized.accepted149 : (fun bs : List Byte =>
  D1BodyTrace.checkedOk bs D1BodySized.s509 D1BodySized.S509) = fun _ => true
kernel_rfl D1BodySized.oracle149 : goodEnum final_cold.r0.ps
  (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S509.oracle = true
kernel_rfl D1BodySized.fuelA150 : nth? D1BodySized.ks 510 = some 1
kernel_rfl D1BodySized.fuelB150 : nth? D1BodySized.ks 511 = some 3
kernel_rfl D1BodySized.stepA150 : interpS (step D1BodySized.F D1BodySized.s510).run D1BodySized.S510 =
  some (D1BodySized.s511, D1BodySized.S511)
kernel_rfl D1BodySized.patchB150 : interpS (Disp.sizeS D1BodySized.F D1BodySized.s511).run D1BodySized.S511 =
  some (D1BodySized.s512, D1BodySized.S512)
kernel_rfl D1BodySized.acceptedP150 : (fun bs : List Byte => D1BodyTrace.checkedOk bs
  D1BodySized.s510 D1BodySized.S510) = fun _ => true
kernel_rfl D1BodySized.haltP150 : isHalt D1BodySized.s510.ctl = false
kernel_rfl D1BodySized.topA150 : Host.Ts.Sim.Compose.noRetBlock D1BodySized.s511 = true
kernel_rfl D1BodySized.inactive150 : (Host.Ts.Sim.Full.bridgeOf D1BodySized.s511.ffi).active = false
/-- Bridge 150's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def D1BodySized.sizeTys150 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s511 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def D1BodySized.sizeArgs150 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s511 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl D1BodySized.sizeA150 : Host.Ts.Sim.Disp.sizeParts D1BodySized.s511 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", D1BodySized.sizeTys150, D1BodySized.sizeArgs150)
kernel_rfl D1BodySized.sizeArgsA150 : Host.Ts.Sim.Disp.sizeArgsOk D1BodySized.s511 = true
kernel_rfl D1BodySized.sizeSymA150 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl D1BodySized.sizeMlxA150 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl D1BodySized.sizePayA150 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl D1BodySized.sizeTaA150 : [2665, 2673479, 2673484, 2673485].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def D1BodySized.sizeDec150 := interpS (decodeArgs D1BodySized.F D1BodySized.s511 D1BodySized.sizeTys150 D1BodySized.sizeArgs150).run D1BodySized.S511
noncomputable def D1BodySized.sizeAs150 : List Arg := match D1BodySized.sizeDec150 with | some (some xs, _) => xs | _ => []
noncomputable def D1BodySized.sizeS0150 : SSrv := match D1BodySized.sizeDec150 with | some (_, S) => S | none => D1BodySized.S511
kernel_rfl D1BodySized.sizeDecA150 : interpS (decodeArgs D1BodySized.F D1BodySized.s511 D1BodySized.sizeTys150 D1BodySized.sizeArgs150).run D1BodySized.S511 =
  some (some D1BodySized.sizeAs150, D1BodySized.sizeS0150)
kernel_rfl D1BodySized.sizePreA150 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB D1BodySized.sizeS0150 D1BodySized.s511.ffi D1BodySized.sizeAs150 = true

end Host.Load.Run.Tpl
end

section -- SN512
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

kernel_rfl D1BodySized.fuel512 : nth? D1BodySized.ks 512 = some 10000
kernel_rfl D1BodySized.checked512 :
  (fun bs : List Byte => runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 10000 D1BodySized.s512 D1BodySized.S512) =
    fun _ => some (D1BodySized.s513, D1BodySized.S513)

theorem D1BodySized.k512 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 10000 D1BodySized.s512 D1BodySized.S512 =
      some (D1BodySized.s513, D1BodySized.S513) := congrFun D1BodySized.checked512 bs

end Host.Load.Run.Tpl
end

section -- SN513
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

kernel_rfl D1BodySized.fuel513 : nth? D1BodySized.ks 513 = some 2570
kernel_rfl D1BodySized.checked513 :
  (fun bs : List Byte => runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 2570 D1BodySized.s513 D1BodySized.S513) =
    fun _ => some (D1BodySized.s514, D1BodySized.S514)

theorem D1BodySized.k513 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 2570 D1BodySized.s513 D1BodySized.S513 =
      some (D1BodySized.s514, D1BodySized.S514) := congrFun D1BodySized.checked513 bs

end Host.Load.Run.Tpl
end

section -- SB150
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.segment150 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 12570 D1BodySized.s512 D1BodySized.S512 =
      some (D1BodySized.s514, D1BodySized.S514) := runOk_trans D1BodySized.F (D1BodyTrace.checkedOk bs) 10000 2570 D1BodySized.s512 D1BodySized.s513 D1BodySized.s514 D1BodySized.S512 D1BodySized.S513 D1BodySized.S514 (D1BodySized.k512 bs) (D1BodySized.k513 bs)

kernel_rfl D1BodySized.accepted150 : (fun bs : List Byte =>
  D1BodyTrace.checkedOk bs D1BodySized.s512 D1BodySized.S512) = fun _ => true
kernel_rfl D1BodySized.oracle150 : goodEnum final_cold.r0.ps
  (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S512.oracle = true
kernel_rfl D1BodySized.fuelA151 : nth? D1BodySized.ks 514 = some 1
kernel_rfl D1BodySized.fuelB151 : nth? D1BodySized.ks 515 = some 3
kernel_rfl D1BodySized.stepA151 : interpS (step D1BodySized.F D1BodySized.s514).run D1BodySized.S514 =
  some (D1BodySized.s515, D1BodySized.S515)
kernel_rfl D1BodySized.patchB151 : interpS (Disp.sizeS D1BodySized.F D1BodySized.s515).run D1BodySized.S515 =
  some (D1BodySized.s516, D1BodySized.S516)
kernel_rfl D1BodySized.acceptedP151 : (fun bs : List Byte => D1BodyTrace.checkedOk bs
  D1BodySized.s514 D1BodySized.S514) = fun _ => true
kernel_rfl D1BodySized.haltP151 : isHalt D1BodySized.s514.ctl = false
kernel_rfl D1BodySized.topA151 : Host.Ts.Sim.Compose.noRetBlock D1BodySized.s515 = true
kernel_rfl D1BodySized.inactive151 : (Host.Ts.Sim.Full.bridgeOf D1BodySized.s515.ffi).active = false
/-- Bridge 151's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def D1BodySized.sizeTys151 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s515 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def D1BodySized.sizeArgs151 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s515 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl D1BodySized.sizeA151 : Host.Ts.Sim.Disp.sizeParts D1BodySized.s515 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", D1BodySized.sizeTys151, D1BodySized.sizeArgs151)
kernel_rfl D1BodySized.sizeArgsA151 : Host.Ts.Sim.Disp.sizeArgsOk D1BodySized.s515 = true
kernel_rfl D1BodySized.sizeSymA151 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl D1BodySized.sizeMlxA151 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl D1BodySized.sizePayA151 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl D1BodySized.sizeTaA151 : [2665, 2673479, 2673484, 2673485].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def D1BodySized.sizeDec151 := interpS (decodeArgs D1BodySized.F D1BodySized.s515 D1BodySized.sizeTys151 D1BodySized.sizeArgs151).run D1BodySized.S515
noncomputable def D1BodySized.sizeAs151 : List Arg := match D1BodySized.sizeDec151 with | some (some xs, _) => xs | _ => []
noncomputable def D1BodySized.sizeS0151 : SSrv := match D1BodySized.sizeDec151 with | some (_, S) => S | none => D1BodySized.S515
kernel_rfl D1BodySized.sizeDecA151 : interpS (decodeArgs D1BodySized.F D1BodySized.s515 D1BodySized.sizeTys151 D1BodySized.sizeArgs151).run D1BodySized.S515 =
  some (some D1BodySized.sizeAs151, D1BodySized.sizeS0151)
kernel_rfl D1BodySized.sizePreA151 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB D1BodySized.sizeS0151 D1BodySized.s515.ffi D1BodySized.sizeAs151 = true

end Host.Load.Run.Tpl
end

section -- SN516
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

kernel_rfl D1BodySized.fuel516 : nth? D1BodySized.ks 516 = some 2542
kernel_rfl D1BodySized.checked516 :
  (fun bs : List Byte => runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 2542 D1BodySized.s516 D1BodySized.S516) =
    fun _ => some (D1BodySized.s517, D1BodySized.S517)

theorem D1BodySized.k516 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 2542 D1BodySized.s516 D1BodySized.S516 =
      some (D1BodySized.s517, D1BodySized.S517) := congrFun D1BodySized.checked516 bs

end Host.Load.Run.Tpl
end

section -- SB151
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.segment151 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 2542 D1BodySized.s516 D1BodySized.S516 =
      some (D1BodySized.s517, D1BodySized.S517) := D1BodySized.k516 bs

kernel_rfl D1BodySized.accepted151 : (fun bs : List Byte =>
  D1BodyTrace.checkedOk bs D1BodySized.s516 D1BodySized.S516) = fun _ => true
kernel_rfl D1BodySized.oracle151 : goodEnum final_cold.r0.ps
  (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S516.oracle = true
kernel_rfl D1BodySized.fuelA152 : nth? D1BodySized.ks 517 = some 1
kernel_rfl D1BodySized.fuelB152 : nth? D1BodySized.ks 518 = some 3
kernel_rfl D1BodySized.stepA152 : interpS (step D1BodySized.F D1BodySized.s517).run D1BodySized.S517 =
  some (D1BodySized.s518, D1BodySized.S518)
kernel_rfl D1BodySized.patchB152 : interpS (Disp.sizeS D1BodySized.F D1BodySized.s518).run D1BodySized.S518 =
  some (D1BodySized.s519, D1BodySized.S519)
kernel_rfl D1BodySized.acceptedP152 : (fun bs : List Byte => D1BodyTrace.checkedOk bs
  D1BodySized.s517 D1BodySized.S517) = fun _ => true
kernel_rfl D1BodySized.haltP152 : isHalt D1BodySized.s517.ctl = false
kernel_rfl D1BodySized.topA152 : Host.Ts.Sim.Compose.noRetBlock D1BodySized.s518 = true
kernel_rfl D1BodySized.inactive152 : (Host.Ts.Sim.Full.bridgeOf D1BodySized.s518.ffi).active = false
/-- Bridge 152's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def D1BodySized.sizeTys152 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s518 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def D1BodySized.sizeArgs152 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s518 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl D1BodySized.sizeA152 : Host.Ts.Sim.Disp.sizeParts D1BodySized.s518 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", D1BodySized.sizeTys152, D1BodySized.sizeArgs152)
kernel_rfl D1BodySized.sizeArgsA152 : Host.Ts.Sim.Disp.sizeArgsOk D1BodySized.s518 = true
kernel_rfl D1BodySized.sizeSymA152 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl D1BodySized.sizeMlxA152 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl D1BodySized.sizePayA152 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl D1BodySized.sizeTaA152 : [2665, 2673479, 2673484, 2673485].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def D1BodySized.sizeDec152 := interpS (decodeArgs D1BodySized.F D1BodySized.s518 D1BodySized.sizeTys152 D1BodySized.sizeArgs152).run D1BodySized.S518
noncomputable def D1BodySized.sizeAs152 : List Arg := match D1BodySized.sizeDec152 with | some (some xs, _) => xs | _ => []
noncomputable def D1BodySized.sizeS0152 : SSrv := match D1BodySized.sizeDec152 with | some (_, S) => S | none => D1BodySized.S518
kernel_rfl D1BodySized.sizeDecA152 : interpS (decodeArgs D1BodySized.F D1BodySized.s518 D1BodySized.sizeTys152 D1BodySized.sizeArgs152).run D1BodySized.S518 =
  some (some D1BodySized.sizeAs152, D1BodySized.sizeS0152)
kernel_rfl D1BodySized.sizePreA152 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB D1BodySized.sizeS0152 D1BodySized.s518.ffi D1BodySized.sizeAs152 = true

end Host.Load.Run.Tpl
end

section -- SN519
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

kernel_rfl D1BodySized.fuel519 : nth? D1BodySized.ks 519 = some 7762
kernel_rfl D1BodySized.checked519 :
  (fun bs : List Byte => runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 7762 D1BodySized.s519 D1BodySized.S519) =
    fun _ => some (D1BodySized.s520, D1BodySized.S520)

theorem D1BodySized.k519 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 7762 D1BodySized.s519 D1BodySized.S519 =
      some (D1BodySized.s520, D1BodySized.S520) := congrFun D1BodySized.checked519 bs

end Host.Load.Run.Tpl
end

section -- SB152
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.segment152 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 7762 D1BodySized.s519 D1BodySized.S519 =
      some (D1BodySized.s520, D1BodySized.S520) := D1BodySized.k519 bs

kernel_rfl D1BodySized.accepted152 : (fun bs : List Byte =>
  D1BodyTrace.checkedOk bs D1BodySized.s519 D1BodySized.S519) = fun _ => true
kernel_rfl D1BodySized.oracle152 : goodEnum final_cold.r0.ps
  (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S519.oracle = true
kernel_rfl D1BodySized.fuelA153 : nth? D1BodySized.ks 520 = some 1
kernel_rfl D1BodySized.fuelB153 : nth? D1BodySized.ks 521 = some 3
kernel_rfl D1BodySized.stepA153 : interpS (step D1BodySized.F D1BodySized.s520).run D1BodySized.S520 =
  some (D1BodySized.s521, D1BodySized.S521)
kernel_rfl D1BodySized.patchB153 : interpS (Disp.sizeS D1BodySized.F D1BodySized.s521).run D1BodySized.S521 =
  some (D1BodySized.s522, D1BodySized.S522)
kernel_rfl D1BodySized.acceptedP153 : (fun bs : List Byte => D1BodyTrace.checkedOk bs
  D1BodySized.s520 D1BodySized.S520) = fun _ => true
kernel_rfl D1BodySized.haltP153 : isHalt D1BodySized.s520.ctl = false
kernel_rfl D1BodySized.topA153 : Host.Ts.Sim.Compose.noRetBlock D1BodySized.s521 = true
kernel_rfl D1BodySized.inactive153 : (Host.Ts.Sim.Full.bridgeOf D1BodySized.s521.ffi).active = false
/-- Bridge 153's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def D1BodySized.sizeTys153 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s521 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def D1BodySized.sizeArgs153 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s521 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl D1BodySized.sizeA153 : Host.Ts.Sim.Disp.sizeParts D1BodySized.s521 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", D1BodySized.sizeTys153, D1BodySized.sizeArgs153)
kernel_rfl D1BodySized.sizeArgsA153 : Host.Ts.Sim.Disp.sizeArgsOk D1BodySized.s521 = true
kernel_rfl D1BodySized.sizeSymA153 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl D1BodySized.sizeMlxA153 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl D1BodySized.sizePayA153 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl D1BodySized.sizeTaA153 : [2665, 2673479, 2673484, 2673485].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def D1BodySized.sizeDec153 := interpS (decodeArgs D1BodySized.F D1BodySized.s521 D1BodySized.sizeTys153 D1BodySized.sizeArgs153).run D1BodySized.S521
noncomputable def D1BodySized.sizeAs153 : List Arg := match D1BodySized.sizeDec153 with | some (some xs, _) => xs | _ => []
noncomputable def D1BodySized.sizeS0153 : SSrv := match D1BodySized.sizeDec153 with | some (_, S) => S | none => D1BodySized.S521
kernel_rfl D1BodySized.sizeDecA153 : interpS (decodeArgs D1BodySized.F D1BodySized.s521 D1BodySized.sizeTys153 D1BodySized.sizeArgs153).run D1BodySized.S521 =
  some (some D1BodySized.sizeAs153, D1BodySized.sizeS0153)
kernel_rfl D1BodySized.sizePreA153 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB D1BodySized.sizeS0153 D1BodySized.s521.ffi D1BodySized.sizeAs153 = true

end Host.Load.Run.Tpl
end

section -- SN522
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

kernel_rfl D1BodySized.fuel522 : nth? D1BodySized.ks 522 = some 1936
kernel_rfl D1BodySized.checked522 :
  (fun bs : List Byte => runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 1936 D1BodySized.s522 D1BodySized.S522) =
    fun _ => some (D1BodySized.s523, D1BodySized.S523)

theorem D1BodySized.k522 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 1936 D1BodySized.s522 D1BodySized.S522 =
      some (D1BodySized.s523, D1BodySized.S523) := congrFun D1BodySized.checked522 bs

end Host.Load.Run.Tpl
end

section -- SB153
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.segment153 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 1936 D1BodySized.s522 D1BodySized.S522 =
      some (D1BodySized.s523, D1BodySized.S523) := D1BodySized.k522 bs

kernel_rfl D1BodySized.accepted153 : (fun bs : List Byte =>
  D1BodyTrace.checkedOk bs D1BodySized.s522 D1BodySized.S522) = fun _ => true
kernel_rfl D1BodySized.oracle153 : goodEnum final_cold.r0.ps
  (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S522.oracle = true
kernel_rfl D1BodySized.fuelA154 : nth? D1BodySized.ks 523 = some 1
kernel_rfl D1BodySized.fuelB154 : nth? D1BodySized.ks 524 = some 3
kernel_rfl D1BodySized.stepA154 : interpS (step D1BodySized.F D1BodySized.s523).run D1BodySized.S523 =
  some (D1BodySized.s524, D1BodySized.S524)
kernel_rfl D1BodySized.patchB154 : interpS (Disp.sizeS D1BodySized.F D1BodySized.s524).run D1BodySized.S524 =
  some (D1BodySized.s525, D1BodySized.S525)
kernel_rfl D1BodySized.acceptedP154 : (fun bs : List Byte => D1BodyTrace.checkedOk bs
  D1BodySized.s523 D1BodySized.S523) = fun _ => true
kernel_rfl D1BodySized.haltP154 : isHalt D1BodySized.s523.ctl = false
kernel_rfl D1BodySized.topA154 : Host.Ts.Sim.Compose.noRetBlock D1BodySized.s524 = true
kernel_rfl D1BodySized.inactive154 : (Host.Ts.Sim.Full.bridgeOf D1BodySized.s524.ffi).active = false
/-- Bridge 154's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def D1BodySized.sizeTys154 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s524 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def D1BodySized.sizeArgs154 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s524 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl D1BodySized.sizeA154 : Host.Ts.Sim.Disp.sizeParts D1BodySized.s524 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", D1BodySized.sizeTys154, D1BodySized.sizeArgs154)
kernel_rfl D1BodySized.sizeArgsA154 : Host.Ts.Sim.Disp.sizeArgsOk D1BodySized.s524 = true
kernel_rfl D1BodySized.sizeSymA154 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl D1BodySized.sizeMlxA154 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl D1BodySized.sizePayA154 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl D1BodySized.sizeTaA154 : [2665, 2673479, 2673484, 2673485].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def D1BodySized.sizeDec154 := interpS (decodeArgs D1BodySized.F D1BodySized.s524 D1BodySized.sizeTys154 D1BodySized.sizeArgs154).run D1BodySized.S524
noncomputable def D1BodySized.sizeAs154 : List Arg := match D1BodySized.sizeDec154 with | some (some xs, _) => xs | _ => []
noncomputable def D1BodySized.sizeS0154 : SSrv := match D1BodySized.sizeDec154 with | some (_, S) => S | none => D1BodySized.S524
kernel_rfl D1BodySized.sizeDecA154 : interpS (decodeArgs D1BodySized.F D1BodySized.s524 D1BodySized.sizeTys154 D1BodySized.sizeArgs154).run D1BodySized.S524 =
  some (some D1BodySized.sizeAs154, D1BodySized.sizeS0154)
kernel_rfl D1BodySized.sizePreA154 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB D1BodySized.sizeS0154 D1BodySized.s524.ffi D1BodySized.sizeAs154 = true

end Host.Load.Run.Tpl
end

section -- SN525
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

kernel_rfl D1BodySized.fuel525 : nth? D1BodySized.ks 525 = some 10000
kernel_rfl D1BodySized.checked525 :
  (fun bs : List Byte => runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 10000 D1BodySized.s525 D1BodySized.S525) =
    fun _ => some (D1BodySized.s526, D1BodySized.S526)

theorem D1BodySized.k525 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 10000 D1BodySized.s525 D1BodySized.S525 =
      some (D1BodySized.s526, D1BodySized.S526) := congrFun D1BodySized.checked525 bs

end Host.Load.Run.Tpl
end

section -- SN526
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

kernel_rfl D1BodySized.fuel526 : nth? D1BodySized.ks 526 = some 2570
kernel_rfl D1BodySized.checked526 :
  (fun bs : List Byte => runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 2570 D1BodySized.s526 D1BodySized.S526) =
    fun _ => some (D1BodySized.s527, D1BodySized.S527)

theorem D1BodySized.k526 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 2570 D1BodySized.s526 D1BodySized.S526 =
      some (D1BodySized.s527, D1BodySized.S527) := congrFun D1BodySized.checked526 bs

end Host.Load.Run.Tpl
end

section -- SB154
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.segment154 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 12570 D1BodySized.s525 D1BodySized.S525 =
      some (D1BodySized.s527, D1BodySized.S527) := runOk_trans D1BodySized.F (D1BodyTrace.checkedOk bs) 10000 2570 D1BodySized.s525 D1BodySized.s526 D1BodySized.s527 D1BodySized.S525 D1BodySized.S526 D1BodySized.S527 (D1BodySized.k525 bs) (D1BodySized.k526 bs)

kernel_rfl D1BodySized.accepted154 : (fun bs : List Byte =>
  D1BodyTrace.checkedOk bs D1BodySized.s525 D1BodySized.S525) = fun _ => true
kernel_rfl D1BodySized.oracle154 : goodEnum final_cold.r0.ps
  (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S525.oracle = true
kernel_rfl D1BodySized.fuelA155 : nth? D1BodySized.ks 527 = some 1
kernel_rfl D1BodySized.fuelB155 : nth? D1BodySized.ks 528 = some 3
kernel_rfl D1BodySized.stepA155 : interpS (step D1BodySized.F D1BodySized.s527).run D1BodySized.S527 =
  some (D1BodySized.s528, D1BodySized.S528)
kernel_rfl D1BodySized.patchB155 : interpS (Disp.sizeS D1BodySized.F D1BodySized.s528).run D1BodySized.S528 =
  some (D1BodySized.s529, D1BodySized.S529)
kernel_rfl D1BodySized.acceptedP155 : (fun bs : List Byte => D1BodyTrace.checkedOk bs
  D1BodySized.s527 D1BodySized.S527) = fun _ => true
kernel_rfl D1BodySized.haltP155 : isHalt D1BodySized.s527.ctl = false
kernel_rfl D1BodySized.topA155 : Host.Ts.Sim.Compose.noRetBlock D1BodySized.s528 = true
kernel_rfl D1BodySized.inactive155 : (Host.Ts.Sim.Full.bridgeOf D1BodySized.s528.ffi).active = false
/-- Bridge 155's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def D1BodySized.sizeTys155 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s528 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def D1BodySized.sizeArgs155 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s528 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl D1BodySized.sizeA155 : Host.Ts.Sim.Disp.sizeParts D1BodySized.s528 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", D1BodySized.sizeTys155, D1BodySized.sizeArgs155)
kernel_rfl D1BodySized.sizeArgsA155 : Host.Ts.Sim.Disp.sizeArgsOk D1BodySized.s528 = true
kernel_rfl D1BodySized.sizeSymA155 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl D1BodySized.sizeMlxA155 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl D1BodySized.sizePayA155 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl D1BodySized.sizeTaA155 : [2665, 2673479, 2673484, 2673485].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def D1BodySized.sizeDec155 := interpS (decodeArgs D1BodySized.F D1BodySized.s528 D1BodySized.sizeTys155 D1BodySized.sizeArgs155).run D1BodySized.S528
noncomputable def D1BodySized.sizeAs155 : List Arg := match D1BodySized.sizeDec155 with | some (some xs, _) => xs | _ => []
noncomputable def D1BodySized.sizeS0155 : SSrv := match D1BodySized.sizeDec155 with | some (_, S) => S | none => D1BodySized.S528
kernel_rfl D1BodySized.sizeDecA155 : interpS (decodeArgs D1BodySized.F D1BodySized.s528 D1BodySized.sizeTys155 D1BodySized.sizeArgs155).run D1BodySized.S528 =
  some (some D1BodySized.sizeAs155, D1BodySized.sizeS0155)
kernel_rfl D1BodySized.sizePreA155 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB D1BodySized.sizeS0155 D1BodySized.s528.ffi D1BodySized.sizeAs155 = true

end Host.Load.Run.Tpl
end

section -- SN529
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

kernel_rfl D1BodySized.fuel529 : nth? D1BodySized.ks 529 = some 2542
kernel_rfl D1BodySized.checked529 :
  (fun bs : List Byte => runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 2542 D1BodySized.s529 D1BodySized.S529) =
    fun _ => some (D1BodySized.s530, D1BodySized.S530)

theorem D1BodySized.k529 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 2542 D1BodySized.s529 D1BodySized.S529 =
      some (D1BodySized.s530, D1BodySized.S530) := congrFun D1BodySized.checked529 bs

end Host.Load.Run.Tpl
end

section -- SB155
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.segment155 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 2542 D1BodySized.s529 D1BodySized.S529 =
      some (D1BodySized.s530, D1BodySized.S530) := D1BodySized.k529 bs

kernel_rfl D1BodySized.accepted155 : (fun bs : List Byte =>
  D1BodyTrace.checkedOk bs D1BodySized.s529 D1BodySized.S529) = fun _ => true
kernel_rfl D1BodySized.oracle155 : goodEnum final_cold.r0.ps
  (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S529.oracle = true
kernel_rfl D1BodySized.fuelA156 : nth? D1BodySized.ks 530 = some 1
kernel_rfl D1BodySized.fuelB156 : nth? D1BodySized.ks 531 = some 3
kernel_rfl D1BodySized.stepA156 : interpS (step D1BodySized.F D1BodySized.s530).run D1BodySized.S530 =
  some (D1BodySized.s531, D1BodySized.S531)
kernel_rfl D1BodySized.patchB156 : interpS (Disp.sizeS D1BodySized.F D1BodySized.s531).run D1BodySized.S531 =
  some (D1BodySized.s532, D1BodySized.S532)
kernel_rfl D1BodySized.acceptedP156 : (fun bs : List Byte => D1BodyTrace.checkedOk bs
  D1BodySized.s530 D1BodySized.S530) = fun _ => true
kernel_rfl D1BodySized.haltP156 : isHalt D1BodySized.s530.ctl = false
kernel_rfl D1BodySized.topA156 : Host.Ts.Sim.Compose.noRetBlock D1BodySized.s531 = true
kernel_rfl D1BodySized.inactive156 : (Host.Ts.Sim.Full.bridgeOf D1BodySized.s531.ffi).active = false
/-- Bridge 156's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def D1BodySized.sizeTys156 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s531 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def D1BodySized.sizeArgs156 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s531 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl D1BodySized.sizeA156 : Host.Ts.Sim.Disp.sizeParts D1BodySized.s531 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", D1BodySized.sizeTys156, D1BodySized.sizeArgs156)
kernel_rfl D1BodySized.sizeArgsA156 : Host.Ts.Sim.Disp.sizeArgsOk D1BodySized.s531 = true
kernel_rfl D1BodySized.sizeSymA156 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl D1BodySized.sizeMlxA156 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl D1BodySized.sizePayA156 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl D1BodySized.sizeTaA156 : [2665, 2673479, 2673484, 2673485].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def D1BodySized.sizeDec156 := interpS (decodeArgs D1BodySized.F D1BodySized.s531 D1BodySized.sizeTys156 D1BodySized.sizeArgs156).run D1BodySized.S531
noncomputable def D1BodySized.sizeAs156 : List Arg := match D1BodySized.sizeDec156 with | some (some xs, _) => xs | _ => []
noncomputable def D1BodySized.sizeS0156 : SSrv := match D1BodySized.sizeDec156 with | some (_, S) => S | none => D1BodySized.S531
kernel_rfl D1BodySized.sizeDecA156 : interpS (decodeArgs D1BodySized.F D1BodySized.s531 D1BodySized.sizeTys156 D1BodySized.sizeArgs156).run D1BodySized.S531 =
  some (some D1BodySized.sizeAs156, D1BodySized.sizeS0156)
kernel_rfl D1BodySized.sizePreA156 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB D1BodySized.sizeS0156 D1BodySized.s531.ffi D1BodySized.sizeAs156 = true

end Host.Load.Run.Tpl
end

section -- SN532
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

kernel_rfl D1BodySized.fuel532 : nth? D1BodySized.ks 532 = some 7762
kernel_rfl D1BodySized.checked532 :
  (fun bs : List Byte => runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 7762 D1BodySized.s532 D1BodySized.S532) =
    fun _ => some (D1BodySized.s533, D1BodySized.S533)

theorem D1BodySized.k532 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 7762 D1BodySized.s532 D1BodySized.S532 =
      some (D1BodySized.s533, D1BodySized.S533) := congrFun D1BodySized.checked532 bs

end Host.Load.Run.Tpl
end

section -- SB156
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.segment156 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 7762 D1BodySized.s532 D1BodySized.S532 =
      some (D1BodySized.s533, D1BodySized.S533) := D1BodySized.k532 bs

kernel_rfl D1BodySized.accepted156 : (fun bs : List Byte =>
  D1BodyTrace.checkedOk bs D1BodySized.s532 D1BodySized.S532) = fun _ => true
kernel_rfl D1BodySized.oracle156 : goodEnum final_cold.r0.ps
  (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S532.oracle = true
kernel_rfl D1BodySized.fuelA157 : nth? D1BodySized.ks 533 = some 1
kernel_rfl D1BodySized.fuelB157 : nth? D1BodySized.ks 534 = some 3
kernel_rfl D1BodySized.stepA157 : interpS (step D1BodySized.F D1BodySized.s533).run D1BodySized.S533 =
  some (D1BodySized.s534, D1BodySized.S534)
kernel_rfl D1BodySized.patchB157 : interpS (Disp.sizeS D1BodySized.F D1BodySized.s534).run D1BodySized.S534 =
  some (D1BodySized.s535, D1BodySized.S535)
kernel_rfl D1BodySized.acceptedP157 : (fun bs : List Byte => D1BodyTrace.checkedOk bs
  D1BodySized.s533 D1BodySized.S533) = fun _ => true
kernel_rfl D1BodySized.haltP157 : isHalt D1BodySized.s533.ctl = false
kernel_rfl D1BodySized.topA157 : Host.Ts.Sim.Compose.noRetBlock D1BodySized.s534 = true
kernel_rfl D1BodySized.inactive157 : (Host.Ts.Sim.Full.bridgeOf D1BodySized.s534.ffi).active = false
/-- Bridge 157's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def D1BodySized.sizeTys157 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s534 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def D1BodySized.sizeArgs157 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s534 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl D1BodySized.sizeA157 : Host.Ts.Sim.Disp.sizeParts D1BodySized.s534 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", D1BodySized.sizeTys157, D1BodySized.sizeArgs157)
kernel_rfl D1BodySized.sizeArgsA157 : Host.Ts.Sim.Disp.sizeArgsOk D1BodySized.s534 = true
kernel_rfl D1BodySized.sizeSymA157 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl D1BodySized.sizeMlxA157 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl D1BodySized.sizePayA157 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl D1BodySized.sizeTaA157 : [2665, 2673479, 2673484, 2673485].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def D1BodySized.sizeDec157 := interpS (decodeArgs D1BodySized.F D1BodySized.s534 D1BodySized.sizeTys157 D1BodySized.sizeArgs157).run D1BodySized.S534
noncomputable def D1BodySized.sizeAs157 : List Arg := match D1BodySized.sizeDec157 with | some (some xs, _) => xs | _ => []
noncomputable def D1BodySized.sizeS0157 : SSrv := match D1BodySized.sizeDec157 with | some (_, S) => S | none => D1BodySized.S534
kernel_rfl D1BodySized.sizeDecA157 : interpS (decodeArgs D1BodySized.F D1BodySized.s534 D1BodySized.sizeTys157 D1BodySized.sizeArgs157).run D1BodySized.S534 =
  some (some D1BodySized.sizeAs157, D1BodySized.sizeS0157)
kernel_rfl D1BodySized.sizePreA157 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB D1BodySized.sizeS0157 D1BodySized.s534.ffi D1BodySized.sizeAs157 = true

end Host.Load.Run.Tpl
end

section -- SN535
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

kernel_rfl D1BodySized.fuel535 : nth? D1BodySized.ks 535 = some 1936
kernel_rfl D1BodySized.checked535 :
  (fun bs : List Byte => runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 1936 D1BodySized.s535 D1BodySized.S535) =
    fun _ => some (D1BodySized.s536, D1BodySized.S536)

theorem D1BodySized.k535 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 1936 D1BodySized.s535 D1BodySized.S535 =
      some (D1BodySized.s536, D1BodySized.S536) := congrFun D1BodySized.checked535 bs

end Host.Load.Run.Tpl
end

section -- SB157
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.segment157 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 1936 D1BodySized.s535 D1BodySized.S535 =
      some (D1BodySized.s536, D1BodySized.S536) := D1BodySized.k535 bs

kernel_rfl D1BodySized.accepted157 : (fun bs : List Byte =>
  D1BodyTrace.checkedOk bs D1BodySized.s535 D1BodySized.S535) = fun _ => true
kernel_rfl D1BodySized.oracle157 : goodEnum final_cold.r0.ps
  (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S535.oracle = true
kernel_rfl D1BodySized.fuelA158 : nth? D1BodySized.ks 536 = some 1
kernel_rfl D1BodySized.fuelB158 : nth? D1BodySized.ks 537 = some 3
kernel_rfl D1BodySized.stepA158 : interpS (step D1BodySized.F D1BodySized.s536).run D1BodySized.S536 =
  some (D1BodySized.s537, D1BodySized.S537)
kernel_rfl D1BodySized.patchB158 : interpS (Disp.sizeS D1BodySized.F D1BodySized.s537).run D1BodySized.S537 =
  some (D1BodySized.s538, D1BodySized.S538)
kernel_rfl D1BodySized.acceptedP158 : (fun bs : List Byte => D1BodyTrace.checkedOk bs
  D1BodySized.s536 D1BodySized.S536) = fun _ => true
kernel_rfl D1BodySized.haltP158 : isHalt D1BodySized.s536.ctl = false
kernel_rfl D1BodySized.topA158 : Host.Ts.Sim.Compose.noRetBlock D1BodySized.s537 = true
kernel_rfl D1BodySized.inactive158 : (Host.Ts.Sim.Full.bridgeOf D1BodySized.s537.ffi).active = false
/-- Bridge 158's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def D1BodySized.sizeTys158 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s537 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def D1BodySized.sizeArgs158 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s537 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl D1BodySized.sizeA158 : Host.Ts.Sim.Disp.sizeParts D1BodySized.s537 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", D1BodySized.sizeTys158, D1BodySized.sizeArgs158)
kernel_rfl D1BodySized.sizeArgsA158 : Host.Ts.Sim.Disp.sizeArgsOk D1BodySized.s537 = true
kernel_rfl D1BodySized.sizeSymA158 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl D1BodySized.sizeMlxA158 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl D1BodySized.sizePayA158 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl D1BodySized.sizeTaA158 : [2665, 2673479, 2673484, 2673485].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def D1BodySized.sizeDec158 := interpS (decodeArgs D1BodySized.F D1BodySized.s537 D1BodySized.sizeTys158 D1BodySized.sizeArgs158).run D1BodySized.S537
noncomputable def D1BodySized.sizeAs158 : List Arg := match D1BodySized.sizeDec158 with | some (some xs, _) => xs | _ => []
noncomputable def D1BodySized.sizeS0158 : SSrv := match D1BodySized.sizeDec158 with | some (_, S) => S | none => D1BodySized.S537
kernel_rfl D1BodySized.sizeDecA158 : interpS (decodeArgs D1BodySized.F D1BodySized.s537 D1BodySized.sizeTys158 D1BodySized.sizeArgs158).run D1BodySized.S537 =
  some (some D1BodySized.sizeAs158, D1BodySized.sizeS0158)
kernel_rfl D1BodySized.sizePreA158 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB D1BodySized.sizeS0158 D1BodySized.s537.ffi D1BodySized.sizeAs158 = true

end Host.Load.Run.Tpl
end

section -- SN538
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

kernel_rfl D1BodySized.fuel538 : nth? D1BodySized.ks 538 = some 10000
kernel_rfl D1BodySized.checked538 :
  (fun bs : List Byte => runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 10000 D1BodySized.s538 D1BodySized.S538) =
    fun _ => some (D1BodySized.s539, D1BodySized.S539)

theorem D1BodySized.k538 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 10000 D1BodySized.s538 D1BodySized.S538 =
      some (D1BodySized.s539, D1BodySized.S539) := congrFun D1BodySized.checked538 bs

end Host.Load.Run.Tpl
end

section -- SN539
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

kernel_rfl D1BodySized.fuel539 : nth? D1BodySized.ks 539 = some 2570
kernel_rfl D1BodySized.checked539 :
  (fun bs : List Byte => runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 2570 D1BodySized.s539 D1BodySized.S539) =
    fun _ => some (D1BodySized.s540, D1BodySized.S540)

theorem D1BodySized.k539 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 2570 D1BodySized.s539 D1BodySized.S539 =
      some (D1BodySized.s540, D1BodySized.S540) := congrFun D1BodySized.checked539 bs

end Host.Load.Run.Tpl
end

section -- SB158
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.segment158 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 12570 D1BodySized.s538 D1BodySized.S538 =
      some (D1BodySized.s540, D1BodySized.S540) := runOk_trans D1BodySized.F (D1BodyTrace.checkedOk bs) 10000 2570 D1BodySized.s538 D1BodySized.s539 D1BodySized.s540 D1BodySized.S538 D1BodySized.S539 D1BodySized.S540 (D1BodySized.k538 bs) (D1BodySized.k539 bs)

kernel_rfl D1BodySized.accepted158 : (fun bs : List Byte =>
  D1BodyTrace.checkedOk bs D1BodySized.s538 D1BodySized.S538) = fun _ => true
kernel_rfl D1BodySized.oracle158 : goodEnum final_cold.r0.ps
  (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S538.oracle = true
kernel_rfl D1BodySized.fuelA159 : nth? D1BodySized.ks 540 = some 1
kernel_rfl D1BodySized.fuelB159 : nth? D1BodySized.ks 541 = some 3
kernel_rfl D1BodySized.stepA159 : interpS (step D1BodySized.F D1BodySized.s540).run D1BodySized.S540 =
  some (D1BodySized.s541, D1BodySized.S541)
kernel_rfl D1BodySized.patchB159 : interpS (Disp.sizeS D1BodySized.F D1BodySized.s541).run D1BodySized.S541 =
  some (D1BodySized.s542, D1BodySized.S542)
kernel_rfl D1BodySized.acceptedP159 : (fun bs : List Byte => D1BodyTrace.checkedOk bs
  D1BodySized.s540 D1BodySized.S540) = fun _ => true
kernel_rfl D1BodySized.haltP159 : isHalt D1BodySized.s540.ctl = false
kernel_rfl D1BodySized.topA159 : Host.Ts.Sim.Compose.noRetBlock D1BodySized.s541 = true
kernel_rfl D1BodySized.inactive159 : (Host.Ts.Sim.Full.bridgeOf D1BodySized.s541.ffi).active = false
/-- Bridge 159's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def D1BodySized.sizeTys159 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s541 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def D1BodySized.sizeArgs159 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s541 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl D1BodySized.sizeA159 : Host.Ts.Sim.Disp.sizeParts D1BodySized.s541 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", D1BodySized.sizeTys159, D1BodySized.sizeArgs159)
kernel_rfl D1BodySized.sizeArgsA159 : Host.Ts.Sim.Disp.sizeArgsOk D1BodySized.s541 = true
kernel_rfl D1BodySized.sizeSymA159 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl D1BodySized.sizeMlxA159 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl D1BodySized.sizePayA159 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl D1BodySized.sizeTaA159 : [2665, 2673479, 2673484, 2673485].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def D1BodySized.sizeDec159 := interpS (decodeArgs D1BodySized.F D1BodySized.s541 D1BodySized.sizeTys159 D1BodySized.sizeArgs159).run D1BodySized.S541
noncomputable def D1BodySized.sizeAs159 : List Arg := match D1BodySized.sizeDec159 with | some (some xs, _) => xs | _ => []
noncomputable def D1BodySized.sizeS0159 : SSrv := match D1BodySized.sizeDec159 with | some (_, S) => S | none => D1BodySized.S541
kernel_rfl D1BodySized.sizeDecA159 : interpS (decodeArgs D1BodySized.F D1BodySized.s541 D1BodySized.sizeTys159 D1BodySized.sizeArgs159).run D1BodySized.S541 =
  some (some D1BodySized.sizeAs159, D1BodySized.sizeS0159)
kernel_rfl D1BodySized.sizePreA159 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB D1BodySized.sizeS0159 D1BodySized.s541.ffi D1BodySized.sizeAs159 = true

end Host.Load.Run.Tpl
end

section -- SN542
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

kernel_rfl D1BodySized.fuel542 : nth? D1BodySized.ks 542 = some 2542
kernel_rfl D1BodySized.checked542 :
  (fun bs : List Byte => runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 2542 D1BodySized.s542 D1BodySized.S542) =
    fun _ => some (D1BodySized.s543, D1BodySized.S543)

theorem D1BodySized.k542 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 2542 D1BodySized.s542 D1BodySized.S542 =
      some (D1BodySized.s543, D1BodySized.S543) := congrFun D1BodySized.checked542 bs

end Host.Load.Run.Tpl
end

section -- SB159
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.segment159 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 2542 D1BodySized.s542 D1BodySized.S542 =
      some (D1BodySized.s543, D1BodySized.S543) := D1BodySized.k542 bs

kernel_rfl D1BodySized.accepted159 : (fun bs : List Byte =>
  D1BodyTrace.checkedOk bs D1BodySized.s542 D1BodySized.S542) = fun _ => true
kernel_rfl D1BodySized.oracle159 : goodEnum final_cold.r0.ps
  (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S542.oracle = true
kernel_rfl D1BodySized.fuelA160 : nth? D1BodySized.ks 543 = some 1
kernel_rfl D1BodySized.fuelB160 : nth? D1BodySized.ks 544 = some 3
kernel_rfl D1BodySized.stepA160 : interpS (step D1BodySized.F D1BodySized.s543).run D1BodySized.S543 =
  some (D1BodySized.s544, D1BodySized.S544)
kernel_rfl D1BodySized.patchB160 : interpS (Disp.sizeS D1BodySized.F D1BodySized.s544).run D1BodySized.S544 =
  some (D1BodySized.s545, D1BodySized.S545)
kernel_rfl D1BodySized.acceptedP160 : (fun bs : List Byte => D1BodyTrace.checkedOk bs
  D1BodySized.s543 D1BodySized.S543) = fun _ => true
kernel_rfl D1BodySized.haltP160 : isHalt D1BodySized.s543.ctl = false
kernel_rfl D1BodySized.topA160 : Host.Ts.Sim.Compose.noRetBlock D1BodySized.s544 = true
kernel_rfl D1BodySized.inactive160 : (Host.Ts.Sim.Full.bridgeOf D1BodySized.s544.ffi).active = false
/-- Bridge 160's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def D1BodySized.sizeTys160 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s544 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def D1BodySized.sizeArgs160 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s544 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl D1BodySized.sizeA160 : Host.Ts.Sim.Disp.sizeParts D1BodySized.s544 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", D1BodySized.sizeTys160, D1BodySized.sizeArgs160)
kernel_rfl D1BodySized.sizeArgsA160 : Host.Ts.Sim.Disp.sizeArgsOk D1BodySized.s544 = true
kernel_rfl D1BodySized.sizeSymA160 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl D1BodySized.sizeMlxA160 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl D1BodySized.sizePayA160 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl D1BodySized.sizeTaA160 : [2665, 2673479, 2673484, 2673485].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def D1BodySized.sizeDec160 := interpS (decodeArgs D1BodySized.F D1BodySized.s544 D1BodySized.sizeTys160 D1BodySized.sizeArgs160).run D1BodySized.S544
noncomputable def D1BodySized.sizeAs160 : List Arg := match D1BodySized.sizeDec160 with | some (some xs, _) => xs | _ => []
noncomputable def D1BodySized.sizeS0160 : SSrv := match D1BodySized.sizeDec160 with | some (_, S) => S | none => D1BodySized.S544
kernel_rfl D1BodySized.sizeDecA160 : interpS (decodeArgs D1BodySized.F D1BodySized.s544 D1BodySized.sizeTys160 D1BodySized.sizeArgs160).run D1BodySized.S544 =
  some (some D1BodySized.sizeAs160, D1BodySized.sizeS0160)
kernel_rfl D1BodySized.sizePreA160 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB D1BodySized.sizeS0160 D1BodySized.s544.ffi D1BodySized.sizeAs160 = true

end Host.Load.Run.Tpl
end

section -- SN545
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

kernel_rfl D1BodySized.fuel545 : nth? D1BodySized.ks 545 = some 10000
kernel_rfl D1BodySized.checked545 :
  (fun bs : List Byte => runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 10000 D1BodySized.s545 D1BodySized.S545) =
    fun _ => some (D1BodySized.s546, D1BodySized.S546)

theorem D1BodySized.k545 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 10000 D1BodySized.s545 D1BodySized.S545 =
      some (D1BodySized.s546, D1BodySized.S546) := congrFun D1BodySized.checked545 bs

end Host.Load.Run.Tpl
end
