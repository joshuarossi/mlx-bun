import host.load.stop.first_eos.CG0
import host.load.stop.first_eos.CG1
import host.load.stop.first_eos.CG2
import host.load.stop.first_eos.CG3
import host.load.stop.first_eos.CG4
import host.load.stop.first_eos.CG5
import host.load.stop.first_eos.CG6
import host.load.stop.first_eos.CG7
import host.load.stop.first_eos.CG8
import host.load.stop.first_eos.CG9
import host.load.stop.first_eos.CG10
import host.load.stop.first_eos.CG11
import host.load.stop.first_eos.CG12
import host.load.stop.first_eos.CG13
import host.load.stop.first_eos.CG14
import host.load.stop.first_eos.CG15
import host.load.stop.first_eos.CG16
import host.load.stop.first_eos.CG17
import host.load.stop.first_eos.CG18
import host.load.stop.first_eos.CG19
import host.load.stop.first_eos.CG20
import host.load.stop.first_eos.CG21
import host.load.stop.first_eos.CG22
import host.load.stop.first_eos.CG23
import host.load.stop.first_eos.CG24
import host.load.stop.first_eos.CG25
import host.load.stop.first_eos.CG26
import host.load.stop.first_eos.CG27
import host.load.stop.first_eos.CG28
import host.load.stop.first_eos.CG29
import host.load.stop.first_eos.CG30
import host.load.stop.first_eos.CG31
import host.load.stop.first_eos.CG32
import host.load.stop.first_eos.CG33
import host.load.stop.first_eos.CG34
import host.load.stop.first_eos.CG35
import host.load.stop.first_eos.CG36
import host.load.stop.first_eos.CG37
import host.load.Compose
import host.load.run.full.H97
set_option Elab.async false
set_option maxRecDepth 1000000
namespace Host.Load.Run.Full
open Host.Ts Host.Load
host_chain_run_staged FirstEos

theorem FirstEos.execution : runS Host.Load.ffi 1495111 P.s2973 FirstEos.srv = some (FirstEos.s150, FirstEos.S150) := FirstEos.run

kernel_rfl FirstEos.completed :
    Stop.summary FirstEos.s150 FirstEos.S150 (entryEnv P.s0) =
      some ⟨[], .lit (F64.ofNat 1), .lit (F64.ofNat 2),
        [.lit (F64.ofNat 1), .lit (F64.ofNat 4), .lit (F64.ofNat 256), .lit (F64.ofNat 256)],
        .lit (F64.ofNat 2), .lit (F64.ofNat 0), true⟩

theorem FirstEos.normal_halt : ∃ v, FirstEos.s150.ctl = .halt (.normal v) := by exact ⟨_, rfl⟩

kernel_rfl FirstEos.lookahead_graph : FirstEos.s150.ffi.mlx.nodes = P.s3123.ffi.mlx.nodes

kernel_rfl FirstEos.model_preserved :
    bindingOf FirstEos.s150 (entryEnv P.s0) chars!"model" = bindingOf P.s2973 (entryEnv P.s0) chars!"model"

kernel_rfl FirstEos.cache_root_preserved :
    bindingOf FirstEos.s150 (entryEnv P.s0) chars!"cache" = bindingOf P.s2973 (entryEnv P.s0) chars!"cache"

end Host.Load.Run.Full
