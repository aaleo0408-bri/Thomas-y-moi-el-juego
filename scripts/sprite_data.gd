# Datos generados desde la versión web (index.html). No editar a mano.
const HERO_ROWS := [
	".....KKKKKK.....",
	"....KHHHHHHKKK..",
	"...KHHHHHHHHHHK.",
	"..KHHHHHHHHHHHK.",
	"..KHHHHHSSSSRHK.",
	"..KHHHHSSHHSHK..",
	"..KHHHHSSSHSK...",
	"..KHSSHSSSSSK...",
	"...KSSSSSSSSSK..",
	"....KHSSSSSSSK..",
	".....KSSSSSSK...",
	"...KKHSSRRRK....",
	"..KRRRRSSSRRK...",
	".KRRRRRRRRRRR...",
	".RRRRRRRRRRKRK..",
	"KSRRKRRYYYRKRK..",
	"KSSKRRRRYRRKKK..",
	"KSSKRRRRYRRKSK..",
	"KSSKRRRRYRRKSR..",
	"KSSSKRRRRRRKSSS.",
	"KSSSSBBBBBBBRRS.",
	".SSSBBBBBBBBKS..",
	"..KBBBBKKBBBBK..",
	"..KBBBBKKBBBBK..",
	".KKBBBK.KKBBBK..",
	".KGBBKK.KKBBWK..",
	".KGGGGK.KGGGG.W.",
	".KGWWWW.KGGGWWWK",
	".KKKKKK.KKKKKKKK"
]
const HERO_PAL := {"K": "20,16,24", "S": "240,192,160", "H": "96,48,24", "R": "200,40,40", "Y": "240,192,48", "B": "48,96,168", "G": "60,160,70", "W": "240,240,240"}
const SPR := {
	"slime": {"grid": [".........bbbbbb.........", ".......bbffffffbb.......", "......bhcaaaaaaceb......", ".....bcgggaaaaaaceb.....", "....bcggiaaaaaaaaceb....", "....bjggaaaaaaaaaacf....", "...baaaaaaaaaaaaaaacb...", "..baaaaddddaaaddddaaeb..", "..baaaadddbdaadbbddacb..", "bbaaaaadddbdaadbbddaacb.", "bbaaaaadddbdaadbddaaacb.", "bbaaccaadddaaaadddaaaab.", "bbaceeeaaaaaaaaaaaeeeab.", "bbaceeecaaacccaaceeeeab.", ".baaeeccccccccccceeeaab.", "..baaaaccccccccccccaab..", "..bbaaaaaaaaaaaaaaabb...", "...bbbbbbbbbbbbbbbbb...."], "pal": {"a": "96,160,64", "b": "0,0,0", "c": "64,128,64", "d": "256,256,256", "e": "32,64,32", "f": "0,32,32", "g": "192,224,128", "h": "32,96,64", "i": "192,224,96", "j": "128,160,64"}},
	"star": {"grid": ["...........b...........", "..........bkb..........", ".........bbdeb.........", ".........bdaab.........", ".........bdaab.........", "........bidaacb........", "........bdfaacb........", "bbbbbbbbbdaaaaebbbbbbbb", "bgladddddfaaaaaaaaaaacb", ".bcaaaaagaaaaaaaaaaacb.", "..bmaaaaaaaaaaaaaachb..", "...bhaaaaaaaaaaaaehb...", "....bbaaaaaaaaaaebb....", ".....bifaaaaaaaccb.....", ".....bfaaaaaaaaacb.....", ".....bfaaaaaaaaacb.....", ".....bfaaacccaaacc.....", "....bgaaeebbbcaaacb....", "....bfacebj.jbccacb....", "....bgchb.....bbccc....", "....bcbb.......bbcc....", "....bb...........bb...."], "pal": {"a": "256,192,64", "b": "0,0,0", "c": "192,96,32", "d": "256,256,224", "e": "160,96,32", "f": "256,224,128", "g": "224,192,64", "h": "64,32,32", "i": "32,32,32", "j": "64,64,64", "k": "224,160,64", "l": "256,224,96", "m": "128,64,32"}},
	"heart": {"grid": ["...bbb.....bbb...", "...bbbb...bbbb...", "..badeab.bbgeab..", "bbaddeaabhaeaaccb", "bbadaaaabaaaaafcb", "bbaaaaaaaaaaaaccb", "bbaaaaaaaaaaaaccb", "bbaaaaaaaaaaaafcb", "..baaaaaaaaaacb..", "..baaaaaaaaaacb..", "...bbaaaaaafcb...", "....baaaaaacb....", ".....baaaacb.....", "......bbccb......", ".......bcb.......", "........b........"], "pal": {"a": "224,32,32", "b": "32,0,0", "c": "128,32,32", "d": "256,160,160", "e": "224,96,96", "f": "160,32,32", "g": "224,64,96", "h": "192,32,32"}},
	"spike": {"grid": [".....a.......aa.......a.....", ".....aa......aa......aa.....", "....aha.....ahb......ada....", "....adba....adba....ahda....", "...adgia...ahdca....aefba...", "...adgci...ahfcb....aegba...", "...aegcba..aefcba..afdgba...", "...aegcba.akegcba..aedgba...", "..acedcbaaakedcbaaaaefcbba..", "..aeefcbbaaeefcbiaadedfbba..", "..aeegcbbaaeedcbbaadedcbba..", "jjaeedcbaaaeedcbbaacedcbbajj", "aafhhdfbaadllccbcacmfcbbbaaa", "aafhhgfdgffffdccccccibbbbbba", ".afddffdcdffffaccccaibbabbaa", "..aaaaaaaaaaaaaaaaaaaaaaaaa."], "pal": {"a": "0,0,0", "b": "96,96,128", "c": "128,128,160", "d": "160,160,192", "e": "256,256,256", "f": "192,192,192", "g": "192,160,192", "h": "224,224,224", "i": "96,96,96", "j": "32,32,32", "k": "160,160,160", "l": "192,192,224", "m": "128,128,128"}},
	"portal": {"grid": ["........fffff.......", "......baaaaaaff.....", "....baeegggggeaf....", "...fadhgdaaaggda....", "...fdhaabbnacdgda...", "..baiabbbbbbcadhdc..", "..aiabbeeeecbcadea..", ".faibjdaaaaecbacdab.", ".aekbabjdccilcacidc.", ".cecbbjjdddcmdbckdc.", ".cicbjjgcadahdcacia.", "faaccjghcccdcecdcddb", "faebjgaccbbdcecdcdda", "feebdhkcbbbbcekdceda", "feecdhaabbbbceadccea", "feecdehabbbbcdcdbeea", "feecdaedbbbbdcddbaea", "faecdaeecbbddcdbcadc", "fddacaegcaadkdjbamdb", ".cdacadgecccdcldcma.", ".fdacbahggcccadcaha.", ".fahacaleggeedacgab.", ".badacbadddddabagdb.", "..adgacbbaaaabagda..", "..bcdhacbbbbbaheab..", "...bddiaabbcaeeab...", "....badiiaaaejab....", ".....bbdddiiabb.....", ".......ffcccb......."], "pal": {"a": "32,96,160", "b": "0,0,32", "c": "32,32,96", "d": "64,160,192", "e": "96,192,224", "f": "0,0,0", "g": "256,256,256", "h": "160,224,224", "i": "128,224,224", "j": "32,128,192", "k": "32,64,128", "l": "96,192,192", "m": "128,192,224", "n": "32,32,64"}}
}
const WORLDS := [
	{"enemy":"#ef6f5e","accent":"#7ee8b0","glow":"#ffd45e","plat":{"top":"#7ed957","body":"#a57a4c","shade":"#6e4f30","rivet":"#4a301c"},"tile":{"top":"#7ed957","topD":"#4fae3a","dirt":"#7a5a3c","dirtD":"#5a4029","dirtL":"#9a7650","pebble":"#4a301c","glow":""}},
	{"enemy":"#ff8a5c","accent":"#ffb86b","glow":"#ffd27a","plat":{"top":"#c5d3ef","body":"#5b6785","shade":"#3c4560","rivet":"#2a3350"},"tile":{"top":"#9fb3d9","topD":"#5f7198","dirt":"#3c4256","dirtD":"#2a2e3f","dirtL":"#4a5068","pebble":"#23263a","glow":"#ffe27a"}},
	{"enemy":"#ff4f8b","accent":"#c77dff","glow":"#6fffd8","plat":{"top":"#b57ad8","body":"#4a3560","shade":"#2e2040","rivet":"#1e1528"},"tile":{"top":"#9b5cc0","topD":"#5e3b6e","dirt":"#2e2233","dirtD":"#1a1420","dirtL":"#4a3550","pebble":"#120e16","glow":"#6fffd8"}}
]
