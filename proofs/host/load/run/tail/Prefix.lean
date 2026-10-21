import host.load.run.tail.C0
import host.load.run.tail.C1
import host.load.run.tail.C2
import host.load.run.tail.C3
import host.load.run.tail.C4
import host.load.run.tail.C5
import host.load.run.tail.C6
import host.load.run.tail.C7
import host.load.run.tail.C8
import host.load.run.tail.C9
import host.load.run.tail.C10
import host.load.run.tail.C11
import host.load.run.tail.C12
import host.load.run.tail.C13
import host.load.run.tail.C14
import host.load.run.tail.C15
import host.load.run.tail.C16
import host.load.run.tail.C17
import host.load.run.tail.C18
import host.load.run.tail.C19
import host.load.run.tail.C20
import host.load.run.tail.C21
import host.load.run.tail.C22
import host.load.run.tail.C23
import host.load.run.tail.C24
import host.load.run.tail.C25
import host.load.run.tail.C26
import host.load.run.tail.C27
import host.load.run.tail.C28
import host.load.run.tail.C29
import host.load.run.tail.C30
import host.load.run.tail.C31
import host.load.run.tail.C32
import host.load.run.tail.C33
import host.load.run.tail.C34
import host.load.run.tail.C35
import host.load.run.tail.C36
import host.load.run.tail.C37
import host.load.run.tail.C38
import host.load.run.tail.C39
import host.load.run.tail.C40
import host.load.run.tail.C41
import host.load.run.tail.C42
import host.load.run.tail.C43
import host.load.run.tail.C44
import host.load.run.tail.C45
import host.load.run.tail.C46
import host.load.run.tail.C47
import host.load.run.tail.C48
import host.load.run.tail.C49
import host.load.run.tail.C50
import host.load.run.tail.C51
import host.load.run.tail.C52
import host.load.run.tail.C53
import host.load.run.tail.C54
import host.load.run.tail.C55
import host.load.run.tail.C56
import host.load.run.tail.C57
import host.load.run.tail.C58
import host.load.run.tail.C59
import host.load.run.tail.C60
import host.load.run.tail.C61
import host.load.run.tail.C62
import host.load.run.tail.C63
import host.load.run.tail.C64
import host.load.run.tail.C65
import host.load.run.tail.C66
import host.load.run.tail.C67
import host.load.run.tail.C68
import host.load.run.tail.C69
import host.load.run.tail.C70
import host.load.run.tail.C71
import host.load.run.tail.C72
import host.load.run.tail.C73
import host.load.run.tail.C74
import host.load.run.tail.C75
import host.load.run.tail.C76
import host.load.run.tail.C77
import host.load.run.tail.C78
import host.load.run.tail.C79
import host.load.run.tail.C80
import host.load.run.tail.C81
import host.load.run.tail.C82
import host.load.run.tail.C83
import host.load.run.tail.C84
import host.load.run.tail.C85
import host.load.run.tail.C86
import host.load.run.tail.C87
import host.load.run.tail.C88
import host.load.run.tail.C89
import host.load.run.tail.C90
import host.load.run.tail.C91
import host.load.run.tail.C92
import host.load.run.tail.C93
import host.load.run.tail.C94
import host.load.run.tail.C95
import host.load.run.tail.C96
import host.load.run.tail.C97
import host.load.run.tail.C98
import host.load.run.tail.C99
import host.load.run.tail.C100
import host.load.run.tail.C101
import host.load.run.tail.C102
import host.load.run.tail.Command
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
namespace Host.Load.Run.Full

tail_compose P P.tailPrefix :=
  P.tailGroup0 P.tailGroup1 P.tailGroup2 P.tailGroup3 P.tailGroup4 P.tailGroup5
  P.tailGroup6 P.tailGroup7 P.tailGroup8 P.tailGroup9 P.tailGroup10 P.tailGroup11
  P.tailGroup12 P.tailGroup13 P.tailGroup14 P.tailGroup15 P.tailGroup16 P.tailGroup17
  P.tailGroup18 P.tailGroup19 P.tailGroup20 P.tailGroup21 P.tailGroup22 P.tailGroup23
  P.tailGroup24 P.tailGroup25 P.tailGroup26 P.tailGroup27 P.tailGroup28 P.tailGroup29
  P.tailGroup30 P.tailGroup31 P.tailGroup32 P.tailGroup33 P.tailGroup34 P.tailGroup35
  P.tailGroup36 P.tailGroup37 P.tailGroup38 P.tailGroup39 P.tailGroup40 P.tailGroup41
  P.tailGroup42 P.tailGroup43 P.tailGroup44 P.tailGroup45 P.tailGroup46 P.tailGroup47
  P.tailGroup48 P.tailGroup49 P.tailGroup50 P.tailGroup51 P.tailGroup52 P.tailGroup53
  P.tailGroup54 P.tailGroup55 P.tailGroup56 P.tailGroup57 P.tailGroup58 P.tailGroup59
  P.tailGroup60 P.tailGroup61 P.tailGroup62 P.tailGroup63 P.tailGroup64 P.tailGroup65
  P.tailGroup66 P.tailGroup67 P.tailGroup68 P.tailGroup69 P.tailGroup70 P.tailGroup71
  P.tailGroup72 P.tailGroup73 P.tailGroup74 P.tailGroup75 P.tailGroup76 P.tailGroup77
  P.tailGroup78 P.tailGroup79 P.tailGroup80 P.tailGroup81 P.tailGroup82 P.tailGroup83
  P.tailGroup84 P.tailGroup85 P.tailGroup86 P.tailGroup87 P.tailGroup88 P.tailGroup89
  P.tailGroup90 P.tailGroup91 P.tailGroup92 P.tailGroup93 P.tailGroup94 P.tailGroup95
  P.tailGroup96 P.tailGroup97 P.tailGroup98 P.tailGroup99 P.tailGroup100 P.tailGroup101
  P.tailGroup102

end Host.Load.Run.Full

namespace Host.Load.Run.Tail
open Host.Ts Host.Load.Run.Full

/-- Decode boundary 0 to the first ordinary readback cut, boundary 3272 (about
to read `.ref 2`), for every unread native token suffix `τ`. -/
theorem tail_prefix (τ : List NumV) :
    runS P.F 32711604 (P.ta0 τ) P.S0 = some (P.ta3272 τ, P.S3272) :=
  P.tailPrefix τ

end Host.Load.Run.Tail
