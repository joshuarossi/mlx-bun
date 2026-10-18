import host.load.stop.Oracles
set_option Elab.async false
set_option maxRecDepth 1000000
namespace Host.Load.Stop
open Host.Ts

def statsField (s : St LSt) (env : Env) (key : List Char) : Option Val := do
  let generation ← bindingOf s env chars!"generation"
  let stats ← Extract.own s generation chars!"stats"
  Extract.own s stats key

def cacheTokens (s : St LSt) (server : SSrv) (env : Env) : Option (List SymE) :=
  (statsField s env chars!"cacheTokens").bind (symsOf s server)

end Host.Load.Stop

namespace Host.Load.Run.Full
open Host.Ts Host.Load

theorem OneToken.cache_tokens :
    Stop.cacheTokens OneToken.s7 OneToken.S7 (entryEnv P.s0) =
      some [.lit (F64.ofNat 9707)] := by rfl

theorem OneEos.cache_tokens :
    Stop.cacheTokens OneEos.s6 OneEos.S6 (entryEnv P.s0) =
      some [.lit (F64.ofNat 9707)] := by rfl

theorem EosToken.cache_tokens :
    Stop.cacheTokens EosToken.s2 EosToken.S2 (entryEnv P.s0) =
      some [.lit (F64.ofNat 9707), .var 1, .var 2] := by rfl

theorem FinalEos.cache_tokens :
    Stop.cacheTokens FinalEos.s3 FinalEos.S3 (entryEnv P.s0) =
      some [.lit (F64.ofNat 9707), .var 1, .var 2, .var 3, .var 4] := by rfl

theorem FirstEos.cache_tokens :
    Stop.cacheTokens FirstEos.s150 FirstEos.S150 (entryEnv P.s0) =
      some [.lit (F64.ofNat 9707), .var 1] := by rfl

theorem BudgetEnd.cache_tokens :
    Stop.cacheTokens P.s3575 P.S3575 (entryEnv P.s0) =
      some [.lit (F64.ofNat 9707), .var 1, .var 2, .var 3, .var 4] := by rfl

kernel_rfl OneEos.finish_reason :
    Stop.statsField OneEos.s6 (entryEnv P.s0) chars!"finishReason" =
      some (.str chars!"stop")

kernel_rfl EosToken.finish_reason :
    Stop.statsField EosToken.s2 (entryEnv P.s0) chars!"finishReason" =
      some (.str chars!"stop")

kernel_rfl FinalEos.finish_reason :
    Stop.statsField FinalEos.s3 (entryEnv P.s0) chars!"finishReason" =
      some (.str chars!"stop")

kernel_rfl FirstEos.finish_reason :
    Stop.statsField FirstEos.s150 (entryEnv P.s0) chars!"finishReason" =
      some (.str chars!"stop")

end Host.Load.Run.Full
