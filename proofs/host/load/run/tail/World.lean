import host.load.Decode
namespace Host.Load.Run.Tail
open Host.Ts Host.Load

/-- `Decode.world` whose native readback queue is `.ref 1, .ref 2` followed by
an arbitrary unread suffix `τ`. -/
def worldTail (τ : List NumV) : LSt :=
  { Decode.world with mlx := { Decode.world.mlx with tokens := [.ref 1, .ref 2] ++ τ } }

/-- The original world is the instance with the suffix `.ref 3, …, .ref 8`. -/
theorem worldTail_reads : worldTail [.ref 3, .ref 4, .ref 5, .ref 6, .ref 7, .ref 8] = Decode.world := rfl

end Host.Load.Run.Tail
