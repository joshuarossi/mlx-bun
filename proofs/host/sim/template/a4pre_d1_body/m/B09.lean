import host.sim.template.a4pre_d1_body.m.B00
import host.sim.template.a4pre_d1_body.TraceStep
import host.sim.Chunk
import host.sim.template.a4pre_d1_body.m.B08
import host.sim.template.a4pre_d1_body.SizeLift

section -- SN546
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

kernel_rfl D1BodySized.fuel546 : nth? D1BodySized.ks 546 = some 10000
kernel_rfl D1BodySized.checked546 :
  (fun bs : List Byte => runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 10000 D1BodySized.s546 D1BodySized.S546) =
    fun _ => some (D1BodySized.s547, D1BodySized.S547)

theorem D1BodySized.k546 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 10000 D1BodySized.s546 D1BodySized.S546 =
      some (D1BodySized.s547, D1BodySized.S547) := congrFun D1BodySized.checked546 bs

end Host.Load.Run.Tpl
end

section -- SN547
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

kernel_rfl D1BodySized.fuel547 : nth? D1BodySized.ks 547 = some 2292
kernel_rfl D1BodySized.checked547 :
  (fun bs : List Byte => runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 2292 D1BodySized.s547 D1BodySized.S547) =
    fun _ => some (D1BodySized.s548, D1BodySized.S548)

theorem D1BodySized.k547 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 2292 D1BodySized.s547 D1BodySized.S547 =
      some (D1BodySized.s548, D1BodySized.S548) := congrFun D1BodySized.checked547 bs

end Host.Load.Run.Tpl
end

section -- SB160
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.segment160 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 22292 D1BodySized.s545 D1BodySized.S545 =
      some (D1BodySized.s548, D1BodySized.S548) := runOk_trans D1BodySized.F (D1BodyTrace.checkedOk bs) 20000 2292 D1BodySized.s545 D1BodySized.s547 D1BodySized.s548 D1BodySized.S545 D1BodySized.S547 D1BodySized.S548 (runOk_trans D1BodySized.F (D1BodyTrace.checkedOk bs) 10000 10000 D1BodySized.s545 D1BodySized.s546 D1BodySized.s547 D1BodySized.S545 D1BodySized.S546 D1BodySized.S547 (D1BodySized.k545 bs) (D1BodySized.k546 bs)) (D1BodySized.k547 bs)

kernel_rfl D1BodySized.accepted160 : (fun bs : List Byte =>
  D1BodyTrace.checkedOk bs D1BodySized.s545 D1BodySized.S545) = fun _ => true
kernel_rfl D1BodySized.oracle160 : goodEnum final_cold.r0.ps
  (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S545.oracle = true
kernel_rfl D1BodySized.fuelA161 : nth? D1BodySized.ks 548 = some 1
kernel_rfl D1BodySized.fuelB161 : nth? D1BodySized.ks 549 = some 3
kernel_rfl D1BodySized.stepA161 : interpS (step D1BodySized.F D1BodySized.s548).run D1BodySized.S548 =
  some (D1BodySized.s549, D1BodySized.S549)
kernel_rfl D1BodySized.patchB161 : interpS (Disp.sizeS D1BodySized.F D1BodySized.s549).run D1BodySized.S549 =
  some (D1BodySized.s550, D1BodySized.S550)
kernel_rfl D1BodySized.acceptedP161 : (fun bs : List Byte => D1BodyTrace.checkedOk bs
  D1BodySized.s548 D1BodySized.S548) = fun _ => true
kernel_rfl D1BodySized.haltP161 : isHalt D1BodySized.s548.ctl = false
kernel_rfl D1BodySized.topA161 : Host.Ts.Sim.Compose.noRetBlock D1BodySized.s549 = true
kernel_rfl D1BodySized.inactive161 : (Host.Ts.Sim.Full.bridgeOf D1BodySized.s549.ffi).active = false
/-- Bridge 161's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def D1BodySized.sizeTys161 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s549 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def D1BodySized.sizeArgs161 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s549 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl D1BodySized.sizeA161 : Host.Ts.Sim.Disp.sizeParts D1BodySized.s549 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", D1BodySized.sizeTys161, D1BodySized.sizeArgs161)
kernel_rfl D1BodySized.sizeArgsA161 : Host.Ts.Sim.Disp.sizeArgsOk D1BodySized.s549 = true
kernel_rfl D1BodySized.sizeSymA161 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl D1BodySized.sizeMlxA161 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl D1BodySized.sizePayA161 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl D1BodySized.sizeTaA161 : [2665, 2673479, 2673484, 2673485].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def D1BodySized.sizeDec161 := interpS (decodeArgs D1BodySized.F D1BodySized.s549 D1BodySized.sizeTys161 D1BodySized.sizeArgs161).run D1BodySized.S549
noncomputable def D1BodySized.sizeAs161 : List Arg := match D1BodySized.sizeDec161 with | some (some xs, _) => xs | _ => []
noncomputable def D1BodySized.sizeS0161 : SSrv := match D1BodySized.sizeDec161 with | some (_, S) => S | none => D1BodySized.S549
kernel_rfl D1BodySized.sizeDecA161 : interpS (decodeArgs D1BodySized.F D1BodySized.s549 D1BodySized.sizeTys161 D1BodySized.sizeArgs161).run D1BodySized.S549 =
  some (some D1BodySized.sizeAs161, D1BodySized.sizeS0161)
kernel_rfl D1BodySized.sizePreA161 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB D1BodySized.sizeS0161 D1BodySized.s549.ffi D1BodySized.sizeAs161 = true

end Host.Load.Run.Tpl
end

section -- SN550
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

kernel_rfl D1BodySized.fuel550 : nth? D1BodySized.ks 550 = some 7939
kernel_rfl D1BodySized.checked550 :
  (fun bs : List Byte => runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 7939 D1BodySized.s550 D1BodySized.S550) =
    fun _ => some (D1BodySized.s551, D1BodySized.S551)

theorem D1BodySized.k550 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 7939 D1BodySized.s550 D1BodySized.S550 =
      some (D1BodySized.s551, D1BodySized.S551) := congrFun D1BodySized.checked550 bs

end Host.Load.Run.Tpl
end

section -- SB161
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.segment161 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 7939 D1BodySized.s550 D1BodySized.S550 =
      some (D1BodySized.s551, D1BodySized.S551) := D1BodySized.k550 bs

kernel_rfl D1BodySized.accepted161 : (fun bs : List Byte =>
  D1BodyTrace.checkedOk bs D1BodySized.s550 D1BodySized.S550) = fun _ => true
kernel_rfl D1BodySized.oracle161 : goodEnum final_cold.r0.ps
  (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S550.oracle = true
kernel_rfl D1BodySized.fuelA162 : nth? D1BodySized.ks 551 = some 1
kernel_rfl D1BodySized.fuelB162 : nth? D1BodySized.ks 552 = some 3
kernel_rfl D1BodySized.stepA162 : interpS (step D1BodySized.F D1BodySized.s551).run D1BodySized.S551 =
  some (D1BodySized.s552, D1BodySized.S552)
kernel_rfl D1BodySized.patchB162 : interpS (Disp.sizeS D1BodySized.F D1BodySized.s552).run D1BodySized.S552 =
  some (D1BodySized.s553, D1BodySized.S553)
kernel_rfl D1BodySized.acceptedP162 : (fun bs : List Byte => D1BodyTrace.checkedOk bs
  D1BodySized.s551 D1BodySized.S551) = fun _ => true
kernel_rfl D1BodySized.haltP162 : isHalt D1BodySized.s551.ctl = false
kernel_rfl D1BodySized.topA162 : Host.Ts.Sim.Compose.noRetBlock D1BodySized.s552 = true
kernel_rfl D1BodySized.inactive162 : (Host.Ts.Sim.Full.bridgeOf D1BodySized.s552.ffi).active = false
/-- Bridge 162's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def D1BodySized.sizeTys162 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s552 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def D1BodySized.sizeArgs162 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s552 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl D1BodySized.sizeA162 : Host.Ts.Sim.Disp.sizeParts D1BodySized.s552 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", D1BodySized.sizeTys162, D1BodySized.sizeArgs162)
kernel_rfl D1BodySized.sizeArgsA162 : Host.Ts.Sim.Disp.sizeArgsOk D1BodySized.s552 = true
kernel_rfl D1BodySized.sizeSymA162 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl D1BodySized.sizeMlxA162 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl D1BodySized.sizePayA162 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl D1BodySized.sizeTaA162 : [2665, 2673479, 2673484, 2673485].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def D1BodySized.sizeDec162 := interpS (decodeArgs D1BodySized.F D1BodySized.s552 D1BodySized.sizeTys162 D1BodySized.sizeArgs162).run D1BodySized.S552
noncomputable def D1BodySized.sizeAs162 : List Arg := match D1BodySized.sizeDec162 with | some (some xs, _) => xs | _ => []
noncomputable def D1BodySized.sizeS0162 : SSrv := match D1BodySized.sizeDec162 with | some (_, S) => S | none => D1BodySized.S552
kernel_rfl D1BodySized.sizeDecA162 : interpS (decodeArgs D1BodySized.F D1BodySized.s552 D1BodySized.sizeTys162 D1BodySized.sizeArgs162).run D1BodySized.S552 =
  some (some D1BodySized.sizeAs162, D1BodySized.sizeS0162)
kernel_rfl D1BodySized.sizePreA162 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB D1BodySized.sizeS0162 D1BodySized.s552.ffi D1BodySized.sizeAs162 = true

end Host.Load.Run.Tpl
end

section -- SN553
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

kernel_rfl D1BodySized.fuel553 : nth? D1BodySized.ks 553 = some 1936
kernel_rfl D1BodySized.checked553 :
  (fun bs : List Byte => runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 1936 D1BodySized.s553 D1BodySized.S553) =
    fun _ => some (D1BodySized.s554, D1BodySized.S554)

theorem D1BodySized.k553 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 1936 D1BodySized.s553 D1BodySized.S553 =
      some (D1BodySized.s554, D1BodySized.S554) := congrFun D1BodySized.checked553 bs

end Host.Load.Run.Tpl
end

section -- SB162
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.segment162 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 1936 D1BodySized.s553 D1BodySized.S553 =
      some (D1BodySized.s554, D1BodySized.S554) := D1BodySized.k553 bs

kernel_rfl D1BodySized.accepted162 : (fun bs : List Byte =>
  D1BodyTrace.checkedOk bs D1BodySized.s553 D1BodySized.S553) = fun _ => true
kernel_rfl D1BodySized.oracle162 : goodEnum final_cold.r0.ps
  (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S553.oracle = true
kernel_rfl D1BodySized.fuelA163 : nth? D1BodySized.ks 554 = some 1
kernel_rfl D1BodySized.fuelB163 : nth? D1BodySized.ks 555 = some 3
kernel_rfl D1BodySized.stepA163 : interpS (step D1BodySized.F D1BodySized.s554).run D1BodySized.S554 =
  some (D1BodySized.s555, D1BodySized.S555)
kernel_rfl D1BodySized.patchB163 : interpS (Disp.sizeS D1BodySized.F D1BodySized.s555).run D1BodySized.S555 =
  some (D1BodySized.s556, D1BodySized.S556)
kernel_rfl D1BodySized.acceptedP163 : (fun bs : List Byte => D1BodyTrace.checkedOk bs
  D1BodySized.s554 D1BodySized.S554) = fun _ => true
kernel_rfl D1BodySized.haltP163 : isHalt D1BodySized.s554.ctl = false
kernel_rfl D1BodySized.topA163 : Host.Ts.Sim.Compose.noRetBlock D1BodySized.s555 = true
kernel_rfl D1BodySized.inactive163 : (Host.Ts.Sim.Full.bridgeOf D1BodySized.s555.ffi).active = false
/-- Bridge 163's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def D1BodySized.sizeTys163 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s555 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def D1BodySized.sizeArgs163 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s555 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl D1BodySized.sizeA163 : Host.Ts.Sim.Disp.sizeParts D1BodySized.s555 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", D1BodySized.sizeTys163, D1BodySized.sizeArgs163)
kernel_rfl D1BodySized.sizeArgsA163 : Host.Ts.Sim.Disp.sizeArgsOk D1BodySized.s555 = true
kernel_rfl D1BodySized.sizeSymA163 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl D1BodySized.sizeMlxA163 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl D1BodySized.sizePayA163 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl D1BodySized.sizeTaA163 : [2665, 2673479, 2673484, 2673485].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def D1BodySized.sizeDec163 := interpS (decodeArgs D1BodySized.F D1BodySized.s555 D1BodySized.sizeTys163 D1BodySized.sizeArgs163).run D1BodySized.S555
noncomputable def D1BodySized.sizeAs163 : List Arg := match D1BodySized.sizeDec163 with | some (some xs, _) => xs | _ => []
noncomputable def D1BodySized.sizeS0163 : SSrv := match D1BodySized.sizeDec163 with | some (_, S) => S | none => D1BodySized.S555
kernel_rfl D1BodySized.sizeDecA163 : interpS (decodeArgs D1BodySized.F D1BodySized.s555 D1BodySized.sizeTys163 D1BodySized.sizeArgs163).run D1BodySized.S555 =
  some (some D1BodySized.sizeAs163, D1BodySized.sizeS0163)
kernel_rfl D1BodySized.sizePreA163 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB D1BodySized.sizeS0163 D1BodySized.s555.ffi D1BodySized.sizeAs163 = true

end Host.Load.Run.Tpl
end

section -- SN556
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

kernel_rfl D1BodySized.fuel556 : nth? D1BodySized.ks 556 = some 10000
kernel_rfl D1BodySized.checked556 :
  (fun bs : List Byte => runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 10000 D1BodySized.s556 D1BodySized.S556) =
    fun _ => some (D1BodySized.s557, D1BodySized.S557)

theorem D1BodySized.k556 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 10000 D1BodySized.s556 D1BodySized.S556 =
      some (D1BodySized.s557, D1BodySized.S557) := congrFun D1BodySized.checked556 bs

end Host.Load.Run.Tpl
end

section -- SN557
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

kernel_rfl D1BodySized.fuel557 : nth? D1BodySized.ks 557 = some 2570
kernel_rfl D1BodySized.checked557 :
  (fun bs : List Byte => runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 2570 D1BodySized.s557 D1BodySized.S557) =
    fun _ => some (D1BodySized.s558, D1BodySized.S558)

theorem D1BodySized.k557 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 2570 D1BodySized.s557 D1BodySized.S557 =
      some (D1BodySized.s558, D1BodySized.S558) := congrFun D1BodySized.checked557 bs

end Host.Load.Run.Tpl
end

section -- SB163
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.segment163 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 12570 D1BodySized.s556 D1BodySized.S556 =
      some (D1BodySized.s558, D1BodySized.S558) := runOk_trans D1BodySized.F (D1BodyTrace.checkedOk bs) 10000 2570 D1BodySized.s556 D1BodySized.s557 D1BodySized.s558 D1BodySized.S556 D1BodySized.S557 D1BodySized.S558 (D1BodySized.k556 bs) (D1BodySized.k557 bs)

kernel_rfl D1BodySized.accepted163 : (fun bs : List Byte =>
  D1BodyTrace.checkedOk bs D1BodySized.s556 D1BodySized.S556) = fun _ => true
kernel_rfl D1BodySized.oracle163 : goodEnum final_cold.r0.ps
  (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S556.oracle = true
kernel_rfl D1BodySized.fuelA164 : nth? D1BodySized.ks 558 = some 1
kernel_rfl D1BodySized.fuelB164 : nth? D1BodySized.ks 559 = some 3
kernel_rfl D1BodySized.stepA164 : interpS (step D1BodySized.F D1BodySized.s558).run D1BodySized.S558 =
  some (D1BodySized.s559, D1BodySized.S559)
kernel_rfl D1BodySized.patchB164 : interpS (Disp.sizeS D1BodySized.F D1BodySized.s559).run D1BodySized.S559 =
  some (D1BodySized.s560, D1BodySized.S560)
kernel_rfl D1BodySized.acceptedP164 : (fun bs : List Byte => D1BodyTrace.checkedOk bs
  D1BodySized.s558 D1BodySized.S558) = fun _ => true
kernel_rfl D1BodySized.haltP164 : isHalt D1BodySized.s558.ctl = false
kernel_rfl D1BodySized.topA164 : Host.Ts.Sim.Compose.noRetBlock D1BodySized.s559 = true
kernel_rfl D1BodySized.inactive164 : (Host.Ts.Sim.Full.bridgeOf D1BodySized.s559.ffi).active = false
/-- Bridge 164's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def D1BodySized.sizeTys164 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s559 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def D1BodySized.sizeArgs164 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s559 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl D1BodySized.sizeA164 : Host.Ts.Sim.Disp.sizeParts D1BodySized.s559 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", D1BodySized.sizeTys164, D1BodySized.sizeArgs164)
kernel_rfl D1BodySized.sizeArgsA164 : Host.Ts.Sim.Disp.sizeArgsOk D1BodySized.s559 = true
kernel_rfl D1BodySized.sizeSymA164 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl D1BodySized.sizeMlxA164 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl D1BodySized.sizePayA164 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl D1BodySized.sizeTaA164 : [2665, 2673479, 2673484, 2673485].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def D1BodySized.sizeDec164 := interpS (decodeArgs D1BodySized.F D1BodySized.s559 D1BodySized.sizeTys164 D1BodySized.sizeArgs164).run D1BodySized.S559
noncomputable def D1BodySized.sizeAs164 : List Arg := match D1BodySized.sizeDec164 with | some (some xs, _) => xs | _ => []
noncomputable def D1BodySized.sizeS0164 : SSrv := match D1BodySized.sizeDec164 with | some (_, S) => S | none => D1BodySized.S559
kernel_rfl D1BodySized.sizeDecA164 : interpS (decodeArgs D1BodySized.F D1BodySized.s559 D1BodySized.sizeTys164 D1BodySized.sizeArgs164).run D1BodySized.S559 =
  some (some D1BodySized.sizeAs164, D1BodySized.sizeS0164)
kernel_rfl D1BodySized.sizePreA164 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB D1BodySized.sizeS0164 D1BodySized.s559.ffi D1BodySized.sizeAs164 = true

end Host.Load.Run.Tpl
end

section -- SN560
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

kernel_rfl D1BodySized.fuel560 : nth? D1BodySized.ks 560 = some 2542
kernel_rfl D1BodySized.checked560 :
  (fun bs : List Byte => runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 2542 D1BodySized.s560 D1BodySized.S560) =
    fun _ => some (D1BodySized.s561, D1BodySized.S561)

theorem D1BodySized.k560 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 2542 D1BodySized.s560 D1BodySized.S560 =
      some (D1BodySized.s561, D1BodySized.S561) := congrFun D1BodySized.checked560 bs

end Host.Load.Run.Tpl
end

section -- SB164
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.segment164 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 2542 D1BodySized.s560 D1BodySized.S560 =
      some (D1BodySized.s561, D1BodySized.S561) := D1BodySized.k560 bs

kernel_rfl D1BodySized.accepted164 : (fun bs : List Byte =>
  D1BodyTrace.checkedOk bs D1BodySized.s560 D1BodySized.S560) = fun _ => true
kernel_rfl D1BodySized.oracle164 : goodEnum final_cold.r0.ps
  (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S560.oracle = true
kernel_rfl D1BodySized.fuelA165 : nth? D1BodySized.ks 561 = some 1
kernel_rfl D1BodySized.fuelB165 : nth? D1BodySized.ks 562 = some 3
kernel_rfl D1BodySized.stepA165 : interpS (step D1BodySized.F D1BodySized.s561).run D1BodySized.S561 =
  some (D1BodySized.s562, D1BodySized.S562)
kernel_rfl D1BodySized.patchB165 : interpS (Disp.sizeS D1BodySized.F D1BodySized.s562).run D1BodySized.S562 =
  some (D1BodySized.s563, D1BodySized.S563)
kernel_rfl D1BodySized.acceptedP165 : (fun bs : List Byte => D1BodyTrace.checkedOk bs
  D1BodySized.s561 D1BodySized.S561) = fun _ => true
kernel_rfl D1BodySized.haltP165 : isHalt D1BodySized.s561.ctl = false
kernel_rfl D1BodySized.topA165 : Host.Ts.Sim.Compose.noRetBlock D1BodySized.s562 = true
kernel_rfl D1BodySized.inactive165 : (Host.Ts.Sim.Full.bridgeOf D1BodySized.s562.ffi).active = false
/-- Bridge 165's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def D1BodySized.sizeTys165 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s562 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def D1BodySized.sizeArgs165 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s562 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl D1BodySized.sizeA165 : Host.Ts.Sim.Disp.sizeParts D1BodySized.s562 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", D1BodySized.sizeTys165, D1BodySized.sizeArgs165)
kernel_rfl D1BodySized.sizeArgsA165 : Host.Ts.Sim.Disp.sizeArgsOk D1BodySized.s562 = true
kernel_rfl D1BodySized.sizeSymA165 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl D1BodySized.sizeMlxA165 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl D1BodySized.sizePayA165 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl D1BodySized.sizeTaA165 : [2665, 2673479, 2673484, 2673485].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def D1BodySized.sizeDec165 := interpS (decodeArgs D1BodySized.F D1BodySized.s562 D1BodySized.sizeTys165 D1BodySized.sizeArgs165).run D1BodySized.S562
noncomputable def D1BodySized.sizeAs165 : List Arg := match D1BodySized.sizeDec165 with | some (some xs, _) => xs | _ => []
noncomputable def D1BodySized.sizeS0165 : SSrv := match D1BodySized.sizeDec165 with | some (_, S) => S | none => D1BodySized.S562
kernel_rfl D1BodySized.sizeDecA165 : interpS (decodeArgs D1BodySized.F D1BodySized.s562 D1BodySized.sizeTys165 D1BodySized.sizeArgs165).run D1BodySized.S562 =
  some (some D1BodySized.sizeAs165, D1BodySized.sizeS0165)
kernel_rfl D1BodySized.sizePreA165 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB D1BodySized.sizeS0165 D1BodySized.s562.ffi D1BodySized.sizeAs165 = true

end Host.Load.Run.Tpl
end

section -- SN563
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

kernel_rfl D1BodySized.fuel563 : nth? D1BodySized.ks 563 = some 7716
kernel_rfl D1BodySized.checked563 :
  (fun bs : List Byte => runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 7716 D1BodySized.s563 D1BodySized.S563) =
    fun _ => some (D1BodySized.s564, D1BodySized.S564)

theorem D1BodySized.k563 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 7716 D1BodySized.s563 D1BodySized.S563 =
      some (D1BodySized.s564, D1BodySized.S564) := congrFun D1BodySized.checked563 bs

end Host.Load.Run.Tpl
end

section -- SB165
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.segment165 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 7716 D1BodySized.s563 D1BodySized.S563 =
      some (D1BodySized.s564, D1BodySized.S564) := D1BodySized.k563 bs

kernel_rfl D1BodySized.accepted165 : (fun bs : List Byte =>
  D1BodyTrace.checkedOk bs D1BodySized.s563 D1BodySized.S563) = fun _ => true
kernel_rfl D1BodySized.oracle165 : goodEnum final_cold.r0.ps
  (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S563.oracle = true
kernel_rfl D1BodySized.fuelA166 : nth? D1BodySized.ks 564 = some 1
kernel_rfl D1BodySized.fuelB166 : nth? D1BodySized.ks 565 = some 3
kernel_rfl D1BodySized.stepA166 : interpS (step D1BodySized.F D1BodySized.s564).run D1BodySized.S564 =
  some (D1BodySized.s565, D1BodySized.S565)
kernel_rfl D1BodySized.patchB166 : interpS (Disp.sizeS D1BodySized.F D1BodySized.s565).run D1BodySized.S565 =
  some (D1BodySized.s566, D1BodySized.S566)
kernel_rfl D1BodySized.acceptedP166 : (fun bs : List Byte => D1BodyTrace.checkedOk bs
  D1BodySized.s564 D1BodySized.S564) = fun _ => true
kernel_rfl D1BodySized.haltP166 : isHalt D1BodySized.s564.ctl = false
kernel_rfl D1BodySized.topA166 : Host.Ts.Sim.Compose.noRetBlock D1BodySized.s565 = true
kernel_rfl D1BodySized.inactive166 : (Host.Ts.Sim.Full.bridgeOf D1BodySized.s565.ffi).active = false
/-- Bridge 166's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def D1BodySized.sizeTys166 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s565 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def D1BodySized.sizeArgs166 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s565 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl D1BodySized.sizeA166 : Host.Ts.Sim.Disp.sizeParts D1BodySized.s565 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", D1BodySized.sizeTys166, D1BodySized.sizeArgs166)
kernel_rfl D1BodySized.sizeArgsA166 : Host.Ts.Sim.Disp.sizeArgsOk D1BodySized.s565 = true
kernel_rfl D1BodySized.sizeSymA166 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl D1BodySized.sizeMlxA166 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl D1BodySized.sizePayA166 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl D1BodySized.sizeTaA166 : [2665, 2673479, 2673484, 2673485].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def D1BodySized.sizeDec166 := interpS (decodeArgs D1BodySized.F D1BodySized.s565 D1BodySized.sizeTys166 D1BodySized.sizeArgs166).run D1BodySized.S565
noncomputable def D1BodySized.sizeAs166 : List Arg := match D1BodySized.sizeDec166 with | some (some xs, _) => xs | _ => []
noncomputable def D1BodySized.sizeS0166 : SSrv := match D1BodySized.sizeDec166 with | some (_, S) => S | none => D1BodySized.S565
kernel_rfl D1BodySized.sizeDecA166 : interpS (decodeArgs D1BodySized.F D1BodySized.s565 D1BodySized.sizeTys166 D1BodySized.sizeArgs166).run D1BodySized.S565 =
  some (some D1BodySized.sizeAs166, D1BodySized.sizeS0166)
kernel_rfl D1BodySized.sizePreA166 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB D1BodySized.sizeS0166 D1BodySized.s565.ffi D1BodySized.sizeAs166 = true

end Host.Load.Run.Tpl
end

section -- SN566
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

kernel_rfl D1BodySized.fuel566 : nth? D1BodySized.ks 566 = some 10000
kernel_rfl D1BodySized.checked566 :
  (fun bs : List Byte => runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 10000 D1BodySized.s566 D1BodySized.S566) =
    fun _ => some (D1BodySized.s567, D1BodySized.S567)

theorem D1BodySized.k566 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 10000 D1BodySized.s566 D1BodySized.S566 =
      some (D1BodySized.s567, D1BodySized.S567) := congrFun D1BodySized.checked566 bs

end Host.Load.Run.Tpl
end

section -- SN567
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

kernel_rfl D1BodySized.fuel567 : nth? D1BodySized.ks 567 = some 3407
kernel_rfl D1BodySized.checked567 :
  (fun bs : List Byte => runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 3407 D1BodySized.s567 D1BodySized.S567) =
    fun _ => some (D1BodySized.s568, D1BodySized.S568)

theorem D1BodySized.k567 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 3407 D1BodySized.s567 D1BodySized.S567 =
      some (D1BodySized.s568, D1BodySized.S568) := congrFun D1BodySized.checked567 bs

end Host.Load.Run.Tpl
end

section -- SB166
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.segment166 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 13407 D1BodySized.s566 D1BodySized.S566 =
      some (D1BodySized.s568, D1BodySized.S568) := runOk_trans D1BodySized.F (D1BodyTrace.checkedOk bs) 10000 3407 D1BodySized.s566 D1BodySized.s567 D1BodySized.s568 D1BodySized.S566 D1BodySized.S567 D1BodySized.S568 (D1BodySized.k566 bs) (D1BodySized.k567 bs)

kernel_rfl D1BodySized.accepted166 : (fun bs : List Byte =>
  D1BodyTrace.checkedOk bs D1BodySized.s566 D1BodySized.S566) = fun _ => true
kernel_rfl D1BodySized.oracle166 : goodEnum final_cold.r0.ps
  (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S566.oracle = true
kernel_rfl D1BodySized.fuelA167 : nth? D1BodySized.ks 568 = some 1
kernel_rfl D1BodySized.fuelB167 : nth? D1BodySized.ks 569 = some 3
kernel_rfl D1BodySized.stepA167 : interpS (step D1BodySized.F D1BodySized.s568).run D1BodySized.S568 =
  some (D1BodySized.s569, D1BodySized.S569)
kernel_rfl D1BodySized.patchB167 : interpS (Disp.sizeS D1BodySized.F D1BodySized.s569).run D1BodySized.S569 =
  some (D1BodySized.s570, D1BodySized.S570)
kernel_rfl D1BodySized.acceptedP167 : (fun bs : List Byte => D1BodyTrace.checkedOk bs
  D1BodySized.s568 D1BodySized.S568) = fun _ => true
kernel_rfl D1BodySized.haltP167 : isHalt D1BodySized.s568.ctl = false
kernel_rfl D1BodySized.topA167 : Host.Ts.Sim.Compose.noRetBlock D1BodySized.s569 = true
kernel_rfl D1BodySized.inactive167 : (Host.Ts.Sim.Full.bridgeOf D1BodySized.s569.ffi).active = false
/-- Bridge 167's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def D1BodySized.sizeTys167 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s569 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def D1BodySized.sizeArgs167 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s569 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl D1BodySized.sizeA167 : Host.Ts.Sim.Disp.sizeParts D1BodySized.s569 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", D1BodySized.sizeTys167, D1BodySized.sizeArgs167)
kernel_rfl D1BodySized.sizeArgsA167 : Host.Ts.Sim.Disp.sizeArgsOk D1BodySized.s569 = true
kernel_rfl D1BodySized.sizeSymA167 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl D1BodySized.sizeMlxA167 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl D1BodySized.sizePayA167 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl D1BodySized.sizeTaA167 : [2665, 2673479, 2673484, 2673485].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def D1BodySized.sizeDec167 := interpS (decodeArgs D1BodySized.F D1BodySized.s569 D1BodySized.sizeTys167 D1BodySized.sizeArgs167).run D1BodySized.S569
noncomputable def D1BodySized.sizeAs167 : List Arg := match D1BodySized.sizeDec167 with | some (some xs, _) => xs | _ => []
noncomputable def D1BodySized.sizeS0167 : SSrv := match D1BodySized.sizeDec167 with | some (_, S) => S | none => D1BodySized.S569
kernel_rfl D1BodySized.sizeDecA167 : interpS (decodeArgs D1BodySized.F D1BodySized.s569 D1BodySized.sizeTys167 D1BodySized.sizeArgs167).run D1BodySized.S569 =
  some (some D1BodySized.sizeAs167, D1BodySized.sizeS0167)
kernel_rfl D1BodySized.sizePreA167 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB D1BodySized.sizeS0167 D1BodySized.s569.ffi D1BodySized.sizeAs167 = true

end Host.Load.Run.Tpl
end

section -- SN570
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

kernel_rfl D1BodySized.fuel570 : nth? D1BodySized.ks 570 = some 2542
kernel_rfl D1BodySized.checked570 :
  (fun bs : List Byte => runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 2542 D1BodySized.s570 D1BodySized.S570) =
    fun _ => some (D1BodySized.s571, D1BodySized.S571)

theorem D1BodySized.k570 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 2542 D1BodySized.s570 D1BodySized.S570 =
      some (D1BodySized.s571, D1BodySized.S571) := congrFun D1BodySized.checked570 bs

end Host.Load.Run.Tpl
end

section -- SB167
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.segment167 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 2542 D1BodySized.s570 D1BodySized.S570 =
      some (D1BodySized.s571, D1BodySized.S571) := D1BodySized.k570 bs

kernel_rfl D1BodySized.accepted167 : (fun bs : List Byte =>
  D1BodyTrace.checkedOk bs D1BodySized.s570 D1BodySized.S570) = fun _ => true
kernel_rfl D1BodySized.oracle167 : goodEnum final_cold.r0.ps
  (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S570.oracle = true
kernel_rfl D1BodySized.fuelA168 : nth? D1BodySized.ks 571 = some 1
kernel_rfl D1BodySized.fuelB168 : nth? D1BodySized.ks 572 = some 3
kernel_rfl D1BodySized.stepA168 : interpS (step D1BodySized.F D1BodySized.s571).run D1BodySized.S571 =
  some (D1BodySized.s572, D1BodySized.S572)
kernel_rfl D1BodySized.patchB168 : interpS (Disp.sizeS D1BodySized.F D1BodySized.s572).run D1BodySized.S572 =
  some (D1BodySized.s573, D1BodySized.S573)
kernel_rfl D1BodySized.acceptedP168 : (fun bs : List Byte => D1BodyTrace.checkedOk bs
  D1BodySized.s571 D1BodySized.S571) = fun _ => true
kernel_rfl D1BodySized.haltP168 : isHalt D1BodySized.s571.ctl = false
kernel_rfl D1BodySized.topA168 : Host.Ts.Sim.Compose.noRetBlock D1BodySized.s572 = true
kernel_rfl D1BodySized.inactive168 : (Host.Ts.Sim.Full.bridgeOf D1BodySized.s572.ffi).active = false
/-- Bridge 168's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def D1BodySized.sizeTys168 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s572 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def D1BodySized.sizeArgs168 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s572 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl D1BodySized.sizeA168 : Host.Ts.Sim.Disp.sizeParts D1BodySized.s572 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", D1BodySized.sizeTys168, D1BodySized.sizeArgs168)
kernel_rfl D1BodySized.sizeArgsA168 : Host.Ts.Sim.Disp.sizeArgsOk D1BodySized.s572 = true
kernel_rfl D1BodySized.sizeSymA168 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl D1BodySized.sizeMlxA168 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl D1BodySized.sizePayA168 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl D1BodySized.sizeTaA168 : [2665, 2673479, 2673484, 2673485].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def D1BodySized.sizeDec168 := interpS (decodeArgs D1BodySized.F D1BodySized.s572 D1BodySized.sizeTys168 D1BodySized.sizeArgs168).run D1BodySized.S572
noncomputable def D1BodySized.sizeAs168 : List Arg := match D1BodySized.sizeDec168 with | some (some xs, _) => xs | _ => []
noncomputable def D1BodySized.sizeS0168 : SSrv := match D1BodySized.sizeDec168 with | some (_, S) => S | none => D1BodySized.S572
kernel_rfl D1BodySized.sizeDecA168 : interpS (decodeArgs D1BodySized.F D1BodySized.s572 D1BodySized.sizeTys168 D1BodySized.sizeArgs168).run D1BodySized.S572 =
  some (some D1BodySized.sizeAs168, D1BodySized.sizeS0168)
kernel_rfl D1BodySized.sizePreA168 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB D1BodySized.sizeS0168 D1BodySized.s572.ffi D1BodySized.sizeAs168 = true

end Host.Load.Run.Tpl
end

section -- SN573
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

kernel_rfl D1BodySized.fuel573 : nth? D1BodySized.ks 573 = some 10000
kernel_rfl D1BodySized.checked573 :
  (fun bs : List Byte => runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 10000 D1BodySized.s573 D1BodySized.S573) =
    fun _ => some (D1BodySized.s574, D1BodySized.S574)

theorem D1BodySized.k573 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 10000 D1BodySized.s573 D1BodySized.S573 =
      some (D1BodySized.s574, D1BodySized.S574) := congrFun D1BodySized.checked573 bs

end Host.Load.Run.Tpl
end

section -- SN574
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

kernel_rfl D1BodySized.fuel574 : nth? D1BodySized.ks 574 = some 10000
kernel_rfl D1BodySized.checked574 :
  (fun bs : List Byte => runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 10000 D1BodySized.s574 D1BodySized.S574) =
    fun _ => some (D1BodySized.s575, D1BodySized.S575)

theorem D1BodySized.k574 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 10000 D1BodySized.s574 D1BodySized.S574 =
      some (D1BodySized.s575, D1BodySized.S575) := congrFun D1BodySized.checked574 bs

end Host.Load.Run.Tpl
end

section -- SN575
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

kernel_rfl D1BodySized.fuel575 : nth? D1BodySized.ks 575 = some 1472
kernel_rfl D1BodySized.checked575 :
  (fun bs : List Byte => runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 1472 D1BodySized.s575 D1BodySized.S575) =
    fun _ => some (D1BodySized.s576, D1BodySized.S576)

theorem D1BodySized.k575 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 1472 D1BodySized.s575 D1BodySized.S575 =
      some (D1BodySized.s576, D1BodySized.S576) := congrFun D1BodySized.checked575 bs

end Host.Load.Run.Tpl
end

section -- SB168
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.segment168 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 21472 D1BodySized.s573 D1BodySized.S573 =
      some (D1BodySized.s576, D1BodySized.S576) := runOk_trans D1BodySized.F (D1BodyTrace.checkedOk bs) 20000 1472 D1BodySized.s573 D1BodySized.s575 D1BodySized.s576 D1BodySized.S573 D1BodySized.S575 D1BodySized.S576 (runOk_trans D1BodySized.F (D1BodyTrace.checkedOk bs) 10000 10000 D1BodySized.s573 D1BodySized.s574 D1BodySized.s575 D1BodySized.S573 D1BodySized.S574 D1BodySized.S575 (D1BodySized.k573 bs) (D1BodySized.k574 bs)) (D1BodySized.k575 bs)

kernel_rfl D1BodySized.accepted168 : (fun bs : List Byte =>
  D1BodyTrace.checkedOk bs D1BodySized.s573 D1BodySized.S573) = fun _ => true
kernel_rfl D1BodySized.oracle168 : goodEnum final_cold.r0.ps
  (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S573.oracle = true
kernel_rfl D1BodySized.fuelA169 : nth? D1BodySized.ks 576 = some 1
kernel_rfl D1BodySized.fuelB169 : nth? D1BodySized.ks 577 = some 3
kernel_rfl D1BodySized.stepA169 : interpS (step D1BodySized.F D1BodySized.s576).run D1BodySized.S576 =
  some (D1BodySized.s577, D1BodySized.S577)
kernel_rfl D1BodySized.patchB169 : interpS (Disp.sizeS D1BodySized.F D1BodySized.s577).run D1BodySized.S577 =
  some (D1BodySized.s578, D1BodySized.S578)
kernel_rfl D1BodySized.acceptedP169 : (fun bs : List Byte => D1BodyTrace.checkedOk bs
  D1BodySized.s576 D1BodySized.S576) = fun _ => true
kernel_rfl D1BodySized.haltP169 : isHalt D1BodySized.s576.ctl = false
kernel_rfl D1BodySized.topA169 : Host.Ts.Sim.Compose.noRetBlock D1BodySized.s577 = true
kernel_rfl D1BodySized.inactive169 : (Host.Ts.Sim.Full.bridgeOf D1BodySized.s577.ffi).active = false
/-- Bridge 169's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def D1BodySized.sizeTys169 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s577 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def D1BodySized.sizeArgs169 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s577 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl D1BodySized.sizeA169 : Host.Ts.Sim.Disp.sizeParts D1BodySized.s577 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", D1BodySized.sizeTys169, D1BodySized.sizeArgs169)
kernel_rfl D1BodySized.sizeArgsA169 : Host.Ts.Sim.Disp.sizeArgsOk D1BodySized.s577 = true
kernel_rfl D1BodySized.sizeSymA169 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl D1BodySized.sizeMlxA169 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl D1BodySized.sizePayA169 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl D1BodySized.sizeTaA169 : [2665, 2673479, 2673484, 2673485].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def D1BodySized.sizeDec169 := interpS (decodeArgs D1BodySized.F D1BodySized.s577 D1BodySized.sizeTys169 D1BodySized.sizeArgs169).run D1BodySized.S577
noncomputable def D1BodySized.sizeAs169 : List Arg := match D1BodySized.sizeDec169 with | some (some xs, _) => xs | _ => []
noncomputable def D1BodySized.sizeS0169 : SSrv := match D1BodySized.sizeDec169 with | some (_, S) => S | none => D1BodySized.S577
kernel_rfl D1BodySized.sizeDecA169 : interpS (decodeArgs D1BodySized.F D1BodySized.s577 D1BodySized.sizeTys169 D1BodySized.sizeArgs169).run D1BodySized.S577 =
  some (some D1BodySized.sizeAs169, D1BodySized.sizeS0169)
kernel_rfl D1BodySized.sizePreA169 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB D1BodySized.sizeS0169 D1BodySized.s577.ffi D1BodySized.sizeAs169 = true

end Host.Load.Run.Tpl
end

section -- SN578
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

kernel_rfl D1BodySized.fuel578 : nth? D1BodySized.ks 578 = some 10000
kernel_rfl D1BodySized.checked578 :
  (fun bs : List Byte => runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 10000 D1BodySized.s578 D1BodySized.S578) =
    fun _ => some (D1BodySized.s579, D1BodySized.S579)

theorem D1BodySized.k578 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 10000 D1BodySized.s578 D1BodySized.S578 =
      some (D1BodySized.s579, D1BodySized.S579) := congrFun D1BodySized.checked578 bs

end Host.Load.Run.Tpl
end

section -- SN579
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

kernel_rfl D1BodySized.fuel579 : nth? D1BodySized.ks 579 = some 10000
kernel_rfl D1BodySized.checked579 :
  (fun bs : List Byte => runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 10000 D1BodySized.s579 D1BodySized.S579) =
    fun _ => some (D1BodySized.s580, D1BodySized.S580)

theorem D1BodySized.k579 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 10000 D1BodySized.s579 D1BodySized.S579 =
      some (D1BodySized.s580, D1BodySized.S580) := congrFun D1BodySized.checked579 bs

end Host.Load.Run.Tpl
end

section -- SN580
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

kernel_rfl D1BodySized.fuel580 : nth? D1BodySized.ks 580 = some 2340
kernel_rfl D1BodySized.checked580 :
  (fun bs : List Byte => runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 2340 D1BodySized.s580 D1BodySized.S580) =
    fun _ => some (D1BodySized.s581, D1BodySized.S581)

theorem D1BodySized.k580 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 2340 D1BodySized.s580 D1BodySized.S580 =
      some (D1BodySized.s581, D1BodySized.S581) := congrFun D1BodySized.checked580 bs

end Host.Load.Run.Tpl
end

section -- SB169
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.segment169 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 22340 D1BodySized.s578 D1BodySized.S578 =
      some (D1BodySized.s581, D1BodySized.S581) := runOk_trans D1BodySized.F (D1BodyTrace.checkedOk bs) 20000 2340 D1BodySized.s578 D1BodySized.s580 D1BodySized.s581 D1BodySized.S578 D1BodySized.S580 D1BodySized.S581 (runOk_trans D1BodySized.F (D1BodyTrace.checkedOk bs) 10000 10000 D1BodySized.s578 D1BodySized.s579 D1BodySized.s580 D1BodySized.S578 D1BodySized.S579 D1BodySized.S580 (D1BodySized.k578 bs) (D1BodySized.k579 bs)) (D1BodySized.k580 bs)

kernel_rfl D1BodySized.accepted169 : (fun bs : List Byte =>
  D1BodyTrace.checkedOk bs D1BodySized.s578 D1BodySized.S578) = fun _ => true
kernel_rfl D1BodySized.oracle169 : goodEnum final_cold.r0.ps
  (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S578.oracle = true
kernel_rfl D1BodySized.fuelA170 : nth? D1BodySized.ks 581 = some 1
kernel_rfl D1BodySized.fuelB170 : nth? D1BodySized.ks 582 = some 3
kernel_rfl D1BodySized.stepA170 : interpS (step D1BodySized.F D1BodySized.s581).run D1BodySized.S581 =
  some (D1BodySized.s582, D1BodySized.S582)
kernel_rfl D1BodySized.patchB170 : interpS (Disp.sizeS D1BodySized.F D1BodySized.s582).run D1BodySized.S582 =
  some (D1BodySized.s583, D1BodySized.S583)
kernel_rfl D1BodySized.acceptedP170 : (fun bs : List Byte => D1BodyTrace.checkedOk bs
  D1BodySized.s581 D1BodySized.S581) = fun _ => true
kernel_rfl D1BodySized.haltP170 : isHalt D1BodySized.s581.ctl = false
kernel_rfl D1BodySized.topA170 : Host.Ts.Sim.Compose.noRetBlock D1BodySized.s582 = true
kernel_rfl D1BodySized.inactive170 : (Host.Ts.Sim.Full.bridgeOf D1BodySized.s582.ffi).active = false
/-- Bridge 170's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def D1BodySized.sizeTys170 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s582 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def D1BodySized.sizeArgs170 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s582 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl D1BodySized.sizeA170 : Host.Ts.Sim.Disp.sizeParts D1BodySized.s582 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", D1BodySized.sizeTys170, D1BodySized.sizeArgs170)
kernel_rfl D1BodySized.sizeArgsA170 : Host.Ts.Sim.Disp.sizeArgsOk D1BodySized.s582 = true
kernel_rfl D1BodySized.sizeSymA170 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl D1BodySized.sizeMlxA170 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl D1BodySized.sizePayA170 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl D1BodySized.sizeTaA170 : [2665, 2673479, 2673484, 2673485].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def D1BodySized.sizeDec170 := interpS (decodeArgs D1BodySized.F D1BodySized.s582 D1BodySized.sizeTys170 D1BodySized.sizeArgs170).run D1BodySized.S582
noncomputable def D1BodySized.sizeAs170 : List Arg := match D1BodySized.sizeDec170 with | some (some xs, _) => xs | _ => []
noncomputable def D1BodySized.sizeS0170 : SSrv := match D1BodySized.sizeDec170 with | some (_, S) => S | none => D1BodySized.S582
kernel_rfl D1BodySized.sizeDecA170 : interpS (decodeArgs D1BodySized.F D1BodySized.s582 D1BodySized.sizeTys170 D1BodySized.sizeArgs170).run D1BodySized.S582 =
  some (some D1BodySized.sizeAs170, D1BodySized.sizeS0170)
kernel_rfl D1BodySized.sizePreA170 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB D1BodySized.sizeS0170 D1BodySized.s582.ffi D1BodySized.sizeAs170 = true

end Host.Load.Run.Tpl
end

section -- SN583
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

kernel_rfl D1BodySized.fuel583 : nth? D1BodySized.ks 583 = some 10000
kernel_rfl D1BodySized.checked583 :
  (fun bs : List Byte => runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 10000 D1BodySized.s583 D1BodySized.S583) =
    fun _ => some (D1BodySized.s584, D1BodySized.S584)

theorem D1BodySized.k583 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 10000 D1BodySized.s583 D1BodySized.S583 =
      some (D1BodySized.s584, D1BodySized.S584) := congrFun D1BodySized.checked583 bs

end Host.Load.Run.Tpl
end

section -- SN584
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

kernel_rfl D1BodySized.fuel584 : nth? D1BodySized.ks 584 = some 10000
kernel_rfl D1BodySized.checked584 :
  (fun bs : List Byte => runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 10000 D1BodySized.s584 D1BodySized.S584) =
    fun _ => some (D1BodySized.s585, D1BodySized.S585)

theorem D1BodySized.k584 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 10000 D1BodySized.s584 D1BodySized.S584 =
      some (D1BodySized.s585, D1BodySized.S585) := congrFun D1BodySized.checked584 bs

end Host.Load.Run.Tpl
end

section -- SN585
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

kernel_rfl D1BodySized.fuel585 : nth? D1BodySized.ks 585 = some 1738
kernel_rfl D1BodySized.checked585 :
  (fun bs : List Byte => runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 1738 D1BodySized.s585 D1BodySized.S585) =
    fun _ => some (D1BodySized.s586, D1BodySized.S586)

theorem D1BodySized.k585 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 1738 D1BodySized.s585 D1BodySized.S585 =
      some (D1BodySized.s586, D1BodySized.S586) := congrFun D1BodySized.checked585 bs

end Host.Load.Run.Tpl
end

section -- SB170
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.segment170 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 21738 D1BodySized.s583 D1BodySized.S583 =
      some (D1BodySized.s586, D1BodySized.S586) := runOk_trans D1BodySized.F (D1BodyTrace.checkedOk bs) 20000 1738 D1BodySized.s583 D1BodySized.s585 D1BodySized.s586 D1BodySized.S583 D1BodySized.S585 D1BodySized.S586 (runOk_trans D1BodySized.F (D1BodyTrace.checkedOk bs) 10000 10000 D1BodySized.s583 D1BodySized.s584 D1BodySized.s585 D1BodySized.S583 D1BodySized.S584 D1BodySized.S585 (D1BodySized.k583 bs) (D1BodySized.k584 bs)) (D1BodySized.k585 bs)

kernel_rfl D1BodySized.accepted170 : (fun bs : List Byte =>
  D1BodyTrace.checkedOk bs D1BodySized.s583 D1BodySized.S583) = fun _ => true
kernel_rfl D1BodySized.oracle170 : goodEnum final_cold.r0.ps
  (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S583.oracle = true
kernel_rfl D1BodySized.fuelA171 : nth? D1BodySized.ks 586 = some 1
kernel_rfl D1BodySized.fuelB171 : nth? D1BodySized.ks 587 = some 3
kernel_rfl D1BodySized.stepA171 : interpS (step D1BodySized.F D1BodySized.s586).run D1BodySized.S586 =
  some (D1BodySized.s587, D1BodySized.S587)
kernel_rfl D1BodySized.patchB171 : interpS (Disp.sizeS D1BodySized.F D1BodySized.s587).run D1BodySized.S587 =
  some (D1BodySized.s588, D1BodySized.S588)
kernel_rfl D1BodySized.acceptedP171 : (fun bs : List Byte => D1BodyTrace.checkedOk bs
  D1BodySized.s586 D1BodySized.S586) = fun _ => true
kernel_rfl D1BodySized.haltP171 : isHalt D1BodySized.s586.ctl = false
kernel_rfl D1BodySized.topA171 : Host.Ts.Sim.Compose.noRetBlock D1BodySized.s587 = true
kernel_rfl D1BodySized.inactive171 : (Host.Ts.Sim.Full.bridgeOf D1BodySized.s587.ffi).active = false
/-- Bridge 171's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def D1BodySized.sizeTys171 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s587 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def D1BodySized.sizeArgs171 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s587 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl D1BodySized.sizeA171 : Host.Ts.Sim.Disp.sizeParts D1BodySized.s587 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", D1BodySized.sizeTys171, D1BodySized.sizeArgs171)
kernel_rfl D1BodySized.sizeArgsA171 : Host.Ts.Sim.Disp.sizeArgsOk D1BodySized.s587 = true
kernel_rfl D1BodySized.sizeSymA171 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl D1BodySized.sizeMlxA171 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl D1BodySized.sizePayA171 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl D1BodySized.sizeTaA171 : [2665, 2673479, 2673484, 2673485].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def D1BodySized.sizeDec171 := interpS (decodeArgs D1BodySized.F D1BodySized.s587 D1BodySized.sizeTys171 D1BodySized.sizeArgs171).run D1BodySized.S587
noncomputable def D1BodySized.sizeAs171 : List Arg := match D1BodySized.sizeDec171 with | some (some xs, _) => xs | _ => []
noncomputable def D1BodySized.sizeS0171 : SSrv := match D1BodySized.sizeDec171 with | some (_, S) => S | none => D1BodySized.S587
kernel_rfl D1BodySized.sizeDecA171 : interpS (decodeArgs D1BodySized.F D1BodySized.s587 D1BodySized.sizeTys171 D1BodySized.sizeArgs171).run D1BodySized.S587 =
  some (some D1BodySized.sizeAs171, D1BodySized.sizeS0171)
kernel_rfl D1BodySized.sizePreA171 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB D1BodySized.sizeS0171 D1BodySized.s587.ffi D1BodySized.sizeAs171 = true

end Host.Load.Run.Tpl
end

section -- SN588
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

kernel_rfl D1BodySized.fuel588 : nth? D1BodySized.ks 588 = some 10000
kernel_rfl D1BodySized.checked588 :
  (fun bs : List Byte => runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 10000 D1BodySized.s588 D1BodySized.S588) =
    fun _ => some (D1BodySized.s589, D1BodySized.S589)

theorem D1BodySized.k588 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 10000 D1BodySized.s588 D1BodySized.S588 =
      some (D1BodySized.s589, D1BodySized.S589) := congrFun D1BodySized.checked588 bs

end Host.Load.Run.Tpl
end

section -- SN589
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

kernel_rfl D1BodySized.fuel589 : nth? D1BodySized.ks 589 = some 10000
kernel_rfl D1BodySized.checked589 :
  (fun bs : List Byte => runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 10000 D1BodySized.s589 D1BodySized.S589) =
    fun _ => some (D1BodySized.s590, D1BodySized.S590)

theorem D1BodySized.k589 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 10000 D1BodySized.s589 D1BodySized.S589 =
      some (D1BodySized.s590, D1BodySized.S590) := congrFun D1BodySized.checked589 bs

end Host.Load.Run.Tpl
end

section -- SN590
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

kernel_rfl D1BodySized.fuel590 : nth? D1BodySized.ks 590 = some 1525
kernel_rfl D1BodySized.checked590 :
  (fun bs : List Byte => runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 1525 D1BodySized.s590 D1BodySized.S590) =
    fun _ => some (D1BodySized.s591, D1BodySized.S591)

theorem D1BodySized.k590 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 1525 D1BodySized.s590 D1BodySized.S590 =
      some (D1BodySized.s591, D1BodySized.S591) := congrFun D1BodySized.checked590 bs

end Host.Load.Run.Tpl
end

section -- SB171
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.segment171 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 21525 D1BodySized.s588 D1BodySized.S588 =
      some (D1BodySized.s591, D1BodySized.S591) := runOk_trans D1BodySized.F (D1BodyTrace.checkedOk bs) 20000 1525 D1BodySized.s588 D1BodySized.s590 D1BodySized.s591 D1BodySized.S588 D1BodySized.S590 D1BodySized.S591 (runOk_trans D1BodySized.F (D1BodyTrace.checkedOk bs) 10000 10000 D1BodySized.s588 D1BodySized.s589 D1BodySized.s590 D1BodySized.S588 D1BodySized.S589 D1BodySized.S590 (D1BodySized.k588 bs) (D1BodySized.k589 bs)) (D1BodySized.k590 bs)

kernel_rfl D1BodySized.accepted171 : (fun bs : List Byte =>
  D1BodyTrace.checkedOk bs D1BodySized.s588 D1BodySized.S588) = fun _ => true
kernel_rfl D1BodySized.oracle171 : goodEnum final_cold.r0.ps
  (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S588.oracle = true
kernel_rfl D1BodySized.fuelA172 : nth? D1BodySized.ks 591 = some 1
kernel_rfl D1BodySized.fuelB172 : nth? D1BodySized.ks 592 = some 3
kernel_rfl D1BodySized.stepA172 : interpS (step D1BodySized.F D1BodySized.s591).run D1BodySized.S591 =
  some (D1BodySized.s592, D1BodySized.S592)
kernel_rfl D1BodySized.patchB172 : interpS (Disp.sizeS D1BodySized.F D1BodySized.s592).run D1BodySized.S592 =
  some (D1BodySized.s593, D1BodySized.S593)
kernel_rfl D1BodySized.acceptedP172 : (fun bs : List Byte => D1BodyTrace.checkedOk bs
  D1BodySized.s591 D1BodySized.S591) = fun _ => true
kernel_rfl D1BodySized.haltP172 : isHalt D1BodySized.s591.ctl = false
kernel_rfl D1BodySized.topA172 : Host.Ts.Sim.Compose.noRetBlock D1BodySized.s592 = true
kernel_rfl D1BodySized.inactive172 : (Host.Ts.Sim.Full.bridgeOf D1BodySized.s592.ffi).active = false
/-- Bridge 172's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def D1BodySized.sizeTys172 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s592 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def D1BodySized.sizeArgs172 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s592 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl D1BodySized.sizeA172 : Host.Ts.Sim.Disp.sizeParts D1BodySized.s592 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", D1BodySized.sizeTys172, D1BodySized.sizeArgs172)
kernel_rfl D1BodySized.sizeArgsA172 : Host.Ts.Sim.Disp.sizeArgsOk D1BodySized.s592 = true
kernel_rfl D1BodySized.sizeSymA172 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl D1BodySized.sizeMlxA172 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl D1BodySized.sizePayA172 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl D1BodySized.sizeTaA172 : [2665, 2673479, 2673484, 2673485].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def D1BodySized.sizeDec172 := interpS (decodeArgs D1BodySized.F D1BodySized.s592 D1BodySized.sizeTys172 D1BodySized.sizeArgs172).run D1BodySized.S592
noncomputable def D1BodySized.sizeAs172 : List Arg := match D1BodySized.sizeDec172 with | some (some xs, _) => xs | _ => []
noncomputable def D1BodySized.sizeS0172 : SSrv := match D1BodySized.sizeDec172 with | some (_, S) => S | none => D1BodySized.S592
kernel_rfl D1BodySized.sizeDecA172 : interpS (decodeArgs D1BodySized.F D1BodySized.s592 D1BodySized.sizeTys172 D1BodySized.sizeArgs172).run D1BodySized.S592 =
  some (some D1BodySized.sizeAs172, D1BodySized.sizeS0172)
kernel_rfl D1BodySized.sizePreA172 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB D1BodySized.sizeS0172 D1BodySized.s592.ffi D1BodySized.sizeAs172 = true

end Host.Load.Run.Tpl
end

section -- SN593
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

kernel_rfl D1BodySized.fuel593 : nth? D1BodySized.ks 593 = some 8606
kernel_rfl D1BodySized.checked593 :
  (fun bs : List Byte => runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 8606 D1BodySized.s593 D1BodySized.S593) =
    fun _ => some (D1BodySized.s594, D1BodySized.S594)

theorem D1BodySized.k593 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 8606 D1BodySized.s593 D1BodySized.S593 =
      some (D1BodySized.s594, D1BodySized.S594) := congrFun D1BodySized.checked593 bs

end Host.Load.Run.Tpl
end

section -- SB172
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.segment172 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 8606 D1BodySized.s593 D1BodySized.S593 =
      some (D1BodySized.s594, D1BodySized.S594) := D1BodySized.k593 bs

kernel_rfl D1BodySized.accepted172 : (fun bs : List Byte =>
  D1BodyTrace.checkedOk bs D1BodySized.s593 D1BodySized.S593) = fun _ => true
kernel_rfl D1BodySized.oracle172 : goodEnum final_cold.r0.ps
  (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S593.oracle = true
kernel_rfl D1BodySized.fuelA173 : nth? D1BodySized.ks 594 = some 1
kernel_rfl D1BodySized.fuelB173 : nth? D1BodySized.ks 595 = some 3
kernel_rfl D1BodySized.stepA173 : interpS (step D1BodySized.F D1BodySized.s594).run D1BodySized.S594 =
  some (D1BodySized.s595, D1BodySized.S595)
kernel_rfl D1BodySized.patchB173 : interpS (Disp.sizeS D1BodySized.F D1BodySized.s595).run D1BodySized.S595 =
  some (D1BodySized.s596, D1BodySized.S596)
kernel_rfl D1BodySized.acceptedP173 : (fun bs : List Byte => D1BodyTrace.checkedOk bs
  D1BodySized.s594 D1BodySized.S594) = fun _ => true
kernel_rfl D1BodySized.haltP173 : isHalt D1BodySized.s594.ctl = false
kernel_rfl D1BodySized.topA173 : Host.Ts.Sim.Compose.noRetBlock D1BodySized.s595 = true
kernel_rfl D1BodySized.inactive173 : (Host.Ts.Sim.Full.bridgeOf D1BodySized.s595.ffi).active = false
/-- Bridge 173's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def D1BodySized.sizeTys173 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s595 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def D1BodySized.sizeArgs173 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s595 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl D1BodySized.sizeA173 : Host.Ts.Sim.Disp.sizeParts D1BodySized.s595 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", D1BodySized.sizeTys173, D1BodySized.sizeArgs173)
kernel_rfl D1BodySized.sizeArgsA173 : Host.Ts.Sim.Disp.sizeArgsOk D1BodySized.s595 = true
kernel_rfl D1BodySized.sizeSymA173 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl D1BodySized.sizeMlxA173 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl D1BodySized.sizePayA173 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl D1BodySized.sizeTaA173 : [2665, 2673479, 2673484, 2673485].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def D1BodySized.sizeDec173 := interpS (decodeArgs D1BodySized.F D1BodySized.s595 D1BodySized.sizeTys173 D1BodySized.sizeArgs173).run D1BodySized.S595
noncomputable def D1BodySized.sizeAs173 : List Arg := match D1BodySized.sizeDec173 with | some (some xs, _) => xs | _ => []
noncomputable def D1BodySized.sizeS0173 : SSrv := match D1BodySized.sizeDec173 with | some (_, S) => S | none => D1BodySized.S595
kernel_rfl D1BodySized.sizeDecA173 : interpS (decodeArgs D1BodySized.F D1BodySized.s595 D1BodySized.sizeTys173 D1BodySized.sizeArgs173).run D1BodySized.S595 =
  some (some D1BodySized.sizeAs173, D1BodySized.sizeS0173)
kernel_rfl D1BodySized.sizePreA173 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB D1BodySized.sizeS0173 D1BodySized.s595.ffi D1BodySized.sizeAs173 = true

end Host.Load.Run.Tpl
end

section -- SN596
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

kernel_rfl D1BodySized.fuel596 : nth? D1BodySized.ks 596 = some 10000
kernel_rfl D1BodySized.checked596 :
  (fun bs : List Byte => runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 10000 D1BodySized.s596 D1BodySized.S596) =
    fun _ => some (D1BodySized.s597, D1BodySized.S597)

theorem D1BodySized.k596 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 10000 D1BodySized.s596 D1BodySized.S596 =
      some (D1BodySized.s597, D1BodySized.S597) := congrFun D1BodySized.checked596 bs

end Host.Load.Run.Tpl
end

section -- SN597
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

kernel_rfl D1BodySized.fuel597 : nth? D1BodySized.ks 597 = some 2570
kernel_rfl D1BodySized.checked597 :
  (fun bs : List Byte => runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 2570 D1BodySized.s597 D1BodySized.S597) =
    fun _ => some (D1BodySized.s598, D1BodySized.S598)

theorem D1BodySized.k597 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 2570 D1BodySized.s597 D1BodySized.S597 =
      some (D1BodySized.s598, D1BodySized.S598) := congrFun D1BodySized.checked597 bs

end Host.Load.Run.Tpl
end

section -- SB173
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem D1BodySized.segment173 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 12570 D1BodySized.s596 D1BodySized.S596 =
      some (D1BodySized.s598, D1BodySized.S598) := runOk_trans D1BodySized.F (D1BodyTrace.checkedOk bs) 10000 2570 D1BodySized.s596 D1BodySized.s597 D1BodySized.s598 D1BodySized.S596 D1BodySized.S597 D1BodySized.S598 (D1BodySized.k596 bs) (D1BodySized.k597 bs)

kernel_rfl D1BodySized.accepted173 : (fun bs : List Byte =>
  D1BodyTrace.checkedOk bs D1BodySized.s596 D1BodySized.S596) = fun _ => true
kernel_rfl D1BodySized.oracle173 : goodEnum final_cold.r0.ps
  (varsOf final_cold.r0.V [(9, .L)]) D1BodySized.S596.oracle = true
kernel_rfl D1BodySized.fuelA174 : nth? D1BodySized.ks 598 = some 1
kernel_rfl D1BodySized.fuelB174 : nth? D1BodySized.ks 599 = some 3
kernel_rfl D1BodySized.stepA174 : interpS (step D1BodySized.F D1BodySized.s598).run D1BodySized.S598 =
  some (D1BodySized.s599, D1BodySized.S599)
kernel_rfl D1BodySized.patchB174 : interpS (Disp.sizeS D1BodySized.F D1BodySized.s599).run D1BodySized.S599 =
  some (D1BodySized.s600, D1BodySized.S600)
kernel_rfl D1BodySized.acceptedP174 : (fun bs : List Byte => D1BodyTrace.checkedOk bs
  D1BodySized.s598 D1BodySized.S598) = fun _ => true
kernel_rfl D1BodySized.haltP174 : isHalt D1BodySized.s598.ctl = false
kernel_rfl D1BodySized.topA174 : Host.Ts.Sim.Compose.noRetBlock D1BodySized.s599 = true
kernel_rfl D1BodySized.inactive174 : (Host.Ts.Sim.Full.bridgeOf D1BodySized.s599.ffi).active = false
/-- Bridge 174's B-size call: the signature's argument types and the call's arguments. -/
noncomputable def D1BodySized.sizeTys174 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s599 with | some (_, _, _, _, _, tys, args) => tys | none => []
noncomputable def D1BodySized.sizeArgs174 : List Val := match Host.Ts.Sim.Disp.sizeParts D1BodySized.s599 with | some (_, _, _, _, _, tys, args) => args | none => []
kernel_rfl D1BodySized.sizeA174 : Host.Ts.Sim.Disp.sizeParts D1BodySized.s599 =
  some (4643, 4277, 135, chars!"mlx_array_size", chars!"u64", D1BodySized.sizeTys174, D1BodySized.sizeArgs174)
kernel_rfl D1BodySized.sizeArgsA174 : Host.Ts.Sim.Disp.sizeArgsOk D1BodySized.s599 = true
kernel_rfl D1BodySized.sizeSymA174 : Host.Mlx.Ffi.symOf chars!"mlx_array_size" = some .arraySize
kernel_rfl D1BodySized.sizeMlxA174 : Host.Load.isMlx chars!"mlx_array_size" = true
kernel_rfl D1BodySized.sizePayA174 : nameEq chars!"mlx_array_size" Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (`K.fr 4277 = none` at the segment's frames)
kernel_rfl D1BodySized.sizeTaA174 : [2665, 2673479, 2673484, 2673485].contains 4277 = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def D1BodySized.sizeDec174 := interpS (decodeArgs D1BodySized.F D1BodySized.s599 D1BodySized.sizeTys174 D1BodySized.sizeArgs174).run D1BodySized.S599
noncomputable def D1BodySized.sizeAs174 : List Arg := match D1BodySized.sizeDec174 with | some (some xs, _) => xs | _ => []
noncomputable def D1BodySized.sizeS0174 : SSrv := match D1BodySized.sizeDec174 with | some (_, S) => S | none => D1BodySized.S599
kernel_rfl D1BodySized.sizeDecA174 : interpS (decodeArgs D1BodySized.F D1BodySized.s599 D1BodySized.sizeTys174 D1BodySized.sizeArgs174).run D1BodySized.S599 =
  some (some D1BodySized.sizeAs174, D1BodySized.sizeS0174)
kernel_rfl D1BodySized.sizePreA174 : Host.Ts.Sim.Full.sizePreB Host.Ts.Sim.loopVB D1BodySized.sizeS0174 D1BodySized.s599.ffi D1BodySized.sizeAs174 = true

end Host.Load.Run.Tpl
end

section -- SN600
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

kernel_rfl D1BodySized.fuel600 : nth? D1BodySized.ks 600 = some 2542
kernel_rfl D1BodySized.checked600 :
  (fun bs : List Byte => runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 2542 D1BodySized.s600 D1BodySized.S600) =
    fun _ => some (D1BodySized.s601, D1BodySized.S601)

theorem D1BodySized.k600 (bs : List Byte) :
    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 2542 D1BodySized.s600 D1BodySized.S600 =
      some (D1BodySized.s601, D1BodySized.S601) := congrFun D1BodySized.checked600 bs

end Host.Load.Run.Tpl
end
