import host.simgraph.iter.Inv
namespace Host.Mlx.SimGraph.Iter

/-! The template start's inputs: the 64 cache input node pairs (`after3.cache`, the
caches extracted at the first ordinary readback cut `P.s3272`), the readback node
`20157` and the fed token node `22538`. -/

def tplCaches : List (Option Nat × Option Nat) := [
    (some 20171, some 20186), (some 20208, some 20223), (some 20245, some 20260), (some 20291, some 20292),
    (some 20319, some 20334), (some 20356, some 20371), (some 20393, some 20408), (some 20439, some 20440),
    (some 20467, some 20482), (some 20504, some 20519), (some 20541, some 20556), (some 20587, some 20588),
    (some 20615, some 20630), (some 20652, some 20667), (some 20689, some 20704), (some 20735, some 20736),
    (some 20763, some 20778), (some 20800, some 20815), (some 20837, some 20852), (some 20883, some 20884),
    (some 20911, some 20926), (some 20948, some 20963), (some 20985, some 21000), (some 21031, some 21032),
    (some 21059, some 21074), (some 21096, some 21111), (some 21133, some 21148), (some 21179, some 21180),
    (some 21207, some 21222), (some 21244, some 21259), (some 21281, some 21296), (some 21327, some 21328),
    (some 21355, some 21370), (some 21392, some 21407), (some 21429, some 21444), (some 21475, some 21476),
    (some 21503, some 21518), (some 21540, some 21555), (some 21577, some 21592), (some 21623, some 21624),
    (some 21651, some 21666), (some 21688, some 21703), (some 21725, some 21740), (some 21771, some 21772),
    (some 21799, some 21814), (some 21836, some 21851), (some 21873, some 21888), (some 21919, some 21920),
    (some 21947, some 21962), (some 21984, some 21999), (some 22021, some 22036), (some 22067, some 22068),
    (some 22095, some 22110), (some 22132, some 22147), (some 22169, some 22184), (some 22215, some 22216),
    (some 22243, some 22258), (some 22280, some 22295), (some 22317, some 22332), (some 22363, some 22364),
    (some 22391, some 22406), (some 22428, some 22443), (some 22465, some 22480), (some 22511, some 22512)]

def tplInputs : TplInputs := ⟨tplCaches, 20157, 22538⟩

end Host.Mlx.SimGraph.Iter
