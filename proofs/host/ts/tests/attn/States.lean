import host.ts.tests.AttnSrc
import host.ts.Chunk
namespace Host.Ts.Tests.AttnChain
open Host.Ts Host.Ts.Tests

def nPlus1 : SymE := .bin .add (.var 0) (.lit (F64.fin false 1 0))
def oracle : List Ans := [⟨.lt, .lit (F64.ofNat 256), nPlus1, false⟩]

host_chain P : Mock.ffi, attnBoot, ⟨[.var 0], oracle⟩, [6000, 6000, 6000]

end Host.Ts.Tests.AttnChain
