import host.load.Micro
import host.load.Compose

namespace Host.Load.Tests.Micro
open Host.Ts Host.Load
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

def source : String := "export let out = 0; let i = 0; while (i < 4) { out += i; i++; }"
source_parse source
source_ast

def world : LSt := ⟨Host.Mlx.Ffi.init [] [] [] [], HostSt.init [] [] [] 0 [] []⟩
def initial : Option (St LSt) := boot world [⟨chars!"main.ts", ast⟩] [] chars!"main.ts"

host_chain P : Host.Load.ffi, initial, (⟨[], []⟩ : SSrv), [80]
host_micro_chunk P 0, 13 refine 26, 29, 1

host_chain Q : Host.Load.ffi, initial, (⟨[], []⟩ : SSrv), [80]
host_micro_states Q 0, 17
host_chunk Q.micro0 0
host_chunk Q.micro0 1
host_chunk Q.micro0 2
host_chunk Q.micro0 3
host_chunk Q.micro0 4
host_micro_run Q 0

theorem fused : runS P.F 80 P.s0 P.S0 = some (P.s1, P.S1) := P.c0
theorem separate : runS Q.F 80 Q.s0 Q.S0 = some (Q.s1, Q.S1) := Q.c0

host_chain R : Host.Load.ffi, initial, (⟨[], []⟩ : SSrv), [20, 20, 40]
host_chunk R 0
host_chunk R 1
host_chunk R 2
host_chain_run_staged R

theorem staged : runS R.F 80 R.s0 R.S0 = some (R.s3, R.S3) := R.run

end Host.Load.Tests.Micro
