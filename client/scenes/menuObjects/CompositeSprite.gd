extends Node
"""
body pigment hex:
Paler: F7D9ADFF
Pale: FFC878FF
Tan: E5B166FF
Tanner: 8B6229FF
Dark: 67502FFF
Darker:45351FFF
"""
const body_spritesheet = {
	#color-body
	"00" : preload("res://assets/character/creation/body/00.png"),
	"10" : preload("res://assets/character/creation/body/10.png"),
	"20" : preload("res://assets/character/creation/body/20.png"),
	"30" : preload("res://assets/character/creation/body/30.png"),
	"40" : preload("res://assets/character/creation/body/40.png"),
	"50" : preload("res://assets/character/creation/body/50.png"),
	"01" : preload("res://assets/character/creation/body/01.png"),
	"11" : preload("res://assets/character/creation/body/11.png"),
	"21" : preload("res://assets/character/creation/body/21.png"),
	"31" : preload("res://assets/character/creation/body/31.png"),
	"41" : preload("res://assets/character/creation/body/41.png"),
	"51" : preload("res://assets/character/creation/body/51.png"),

}

const head_spritesheet = {
	#color-head
	"00" : preload("res://assets/character/creation/head/00.png"),
	"01" : preload("res://assets/character/creation/head/01.png"),
	"02" : preload("res://assets/character/creation/head/02.png"),
	"03" : preload("res://assets/character/creation/head/03.png"),
	"04" : preload("res://assets/character/creation/head/04.png"),
	"05" : preload("res://assets/character/creation/head/05.png"),
	"06" : preload("res://assets/character/creation/head/06.png"),
	"07" : preload("res://assets/character/creation/head/07.png"),
	
	"10" : preload("res://assets/character/creation/head/10.png"),
	"11" : preload("res://assets/character/creation/head/11.png"),
	"12" : preload("res://assets/character/creation/head/12.png"),
	"13" : preload("res://assets/character/creation/head/13.png"),
	"14" : preload("res://assets/character/creation/head/14.png"),
	"15" : preload("res://assets/character/creation/head/15.png"),
	"16" : preload("res://assets/character/creation/head/16.png"),
	"17" : preload("res://assets/character/creation/head/17.png"),
	
	"20" : preload("res://assets/character/creation/head/20.png"),
	"21" : preload("res://assets/character/creation/head/21.png"),
	"22" : preload("res://assets/character/creation/head/22.png"),
	"23" : preload("res://assets/character/creation/head/23.png"),
	"24" : preload("res://assets/character/creation/head/24.png"),
	"25" : preload("res://assets/character/creation/head/25.png"),
	"26" : preload("res://assets/character/creation/head/26.png"),
	"27" : preload("res://assets/character/creation/head/27.png"),
	
	"30" : preload("res://assets/character/creation/head/30.png"),
	"31" : preload("res://assets/character/creation/head/31.png"),
	"32" : preload("res://assets/character/creation/head/32.png"),
	"33" : preload("res://assets/character/creation/head/33.png"),
	"34" : preload("res://assets/character/creation/head/34.png"),
	"35" : preload("res://assets/character/creation/head/35.png"),
	"36" : preload("res://assets/character/creation/head/36.png"),
	"37" : preload("res://assets/character/creation/head/37.png"),
	
	"40" : preload("res://assets/character/creation/head/40.png"),
	"41" : preload("res://assets/character/creation/head/41.png"),
	"42" : preload("res://assets/character/creation/head/42.png"),
	"43" : preload("res://assets/character/creation/head/43.png"),
	"44" : preload("res://assets/character/creation/head/44.png"),
	"45" : preload("res://assets/character/creation/head/45.png"),
	"46" : preload("res://assets/character/creation/head/46.png"),
	"47" : preload("res://assets/character/creation/head/47.png"),
	
	"50" : preload("res://assets/character/creation/head/50.png"),
	"51" : preload("res://assets/character/creation/head/51.png"),
	"52" : preload("res://assets/character/creation/head/52.png"),
	"53" : preload("res://assets/character/creation/head/53.png"),
	"54" : preload("res://assets/character/creation/head/54.png"),
	"55" : preload("res://assets/character/creation/head/55.png"),
	"56" : preload("res://assets/character/creation/head/56.png"),
	"57" : preload("res://assets/character/creation/head/57.png"),

	}

"""
hair pigment hex:
Black: 0: 202020FF
Brown: 1: 963200FF
Yellow: 2: F5E077FF
Orange: 3: EEA830FF

hair stylke:
0: broflow
1: frenchcrop
2: shorttail
3: type17
"""
const hair_spritesheet = {
	"00" : preload("res://assets/character/creation/hair/00.png"),
	"01" : preload("res://assets/character/creation/hair/01.png"),
	"02" : preload("res://assets/character/creation/hair/02.png"),
	"03" : preload("res://assets/character/creation/hair/03.png"),
	"10" : preload("res://assets/character/creation/hair/10.png"),
	"11" : preload("res://assets/character/creation/hair/11.png"),
	"12" : preload("res://assets/character/creation/hair/12.png"),
	"13" : preload("res://assets/character/creation/hair/13.png"),
	"20" : preload("res://assets/character/creation/hair/20.png"),
	"21" : preload("res://assets/character/creation/hair/21.png"),
	"22" : preload("res://assets/character/creation/hair/22.png"),
	"23" : preload("res://assets/character/creation/hair/23.png"),
	"30" : preload("res://assets/character/creation/hair/30.png"),
	"31" : preload("res://assets/character/creation/hair/31.png"),
	"32" : preload("res://assets/character/creation/hair/32.png"),
	"33" : preload("res://assets/character/creation/hair/33.png"),
}


"""
eyes pigment hex:
Black: 0: 151616FF
hazel: 1: D8A900FF
Blue: 2: 00C4F9FF

eye:
0: asian
1: type03
2: girl03
"""
const eye_spritesheet = {
	"00" : preload("res://assets/character/creation/eyes/00.png"),
	"01" : preload("res://assets/character/creation/eyes/01.png"),
	"02" : preload("res://assets/character/creation/eyes/02.png"),
	"10" : preload("res://assets/character/creation/eyes/10.png"),
	"11" : preload("res://assets/character/creation/eyes/11.png"),
	"12" : preload("res://assets/character/creation/eyes/12.png"),
	"20" : preload("res://assets/character/creation/eyes/20.png"),
	"21" : preload("res://assets/character/creation/eyes/21.png"),
	"22" : preload("res://assets/character/creation/eyes/22.png"),
	
}

"""
brow:
"""
const brow_spritesheet = {
	"0" : preload("res://assets/character/creation/brow/0.png"),
	"1" : preload("res://assets/character/creation/brow/1.png"),
	"2" : preload("res://assets/character/creation/brow/2.png"),
	"3" : preload("res://assets/character/creation/brow/3.png"),
	
}

"""
outfit consists of top and bottoms:
	0:basic armor robe
	1: leather tunic
	2: wood cutter clothing
"""
const outfit_spritesheet = {
	"0" : preload("res://assets/character/creation/outfit/0.png"),
	"1" : preload("res://assets/character/creation/outfit/1.png"),
	"2" : preload("res://assets/character/creation/outfit/2.png"),
}

"""
Paler: F7D9ADFF
Pale: FFC878FF
Tan: E5B166FF
Tanner: 8B6229FF
Dark: 67502FFF
Darker:45351FFF

ear:
0: human
1:elf
"""
const ear_spritesheet = {
	#color + ear
	"00" : preload("res://assets/character/creation/ears/00.png"),
	"10" : preload("res://assets/character/creation/ears/10.png"),
	"20" : preload("res://assets/character/creation/ears/20.png"),
	"30" : preload("res://assets/character/creation/ears/30.png"),
	"40" : preload("res://assets/character/creation/ears/40.png"),
	"50" : preload("res://assets/character/creation/ears/50.png"),
	"01" : preload("res://assets/character/creation/ears/01.png"),
	"11" : preload("res://assets/character/creation/ears/11.png"),
	"21" : preload("res://assets/character/creation/ears/21.png"),
	"31" : preload("res://assets/character/creation/ears/31.png"),
	"41" : preload("res://assets/character/creation/ears/41.png"),
	"51" : preload("res://assets/character/creation/ears/51.png"),
}

const mouth_spritesheet = {
	"0" : preload("res://assets/character/creation/mouth/0.png"),
	"1" : preload("res://assets/character/creation/mouth/1.png"),
	"2" : preload("res://assets/character/creation/mouth/2.png"),
}
