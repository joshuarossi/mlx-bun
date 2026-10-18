import host.load.CacheCarriersCommand
namespace Host.Load.CacheCarriers.Tests
open Host.Load.Extract Host.Mlx.FfiEval
private def tensor (n : Nat) : Tensor := ⟨0,n,{prim := .zeros,ins := [],shape := [],dtype := 12}⟩
private def caches : List Cache :=
  [⟨chars!"SSMCache",1,some (tensor 7),some (tensor 8)⟩,
   ⟨chars!"KVCache",1,some (tensor 9),some (tensor 10)⟩]
load_cache_carriers checked : caches, [(0,1),(2,3)], [7,8,9,10]
/-- error: (kernel) declaration type mismatch, 'Host.Load.CacheCarriers.Tests.bad.head0' has type
  cacheNodePair
      { operation := ['S', 'S', 'M', 'C', 'a', 'c', 'h', 'e'], offset := 1, first := some (tensor 7),
        second := some (tensor 8) } =
    cacheNodePair
      { operation := ['S', 'S', 'M', 'C', 'a', 'c', 'h', 'e'], offset := 1, first := some (tensor 7),
        second := some (tensor 8) }
but it is expected to have type
  cacheNodePair
      { operation := ['S', 'S', 'M', 'C', 'a', 'c', 'h', 'e'], offset := 1, first := some (tensor 7),
        second := some (tensor 8) } =
    certifiedCachePair [7, 0, 9, 10] (0, 1)
-/
#guard_msgs in
load_cache_carriers bad : caches, [(0,1),(2,3)], [7,0,9,10]
end Host.Load.CacheCarriers.Tests
