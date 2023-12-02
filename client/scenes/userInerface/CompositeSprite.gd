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
	"000" : preload("res://assets/character/creation/body/000.png"),
	"001" : preload("res://assets/character/creation/body/001.png"),
	"002" : preload("res://assets/character/creation/body/002.png"),
	"003" : preload("res://assets/character/creation/body/003.png"),
	"004" : preload("res://assets/character/creation/body/004.png"),
	"005" : preload("res://assets/character/creation/body/005.png"),
	"006" : preload("res://assets/character/creation/body/006.png"),
	"007" : preload("res://assets/character/creation/body/007.png"),
	"008" : preload("res://assets/character/creation/body/008.png"),
	"010" : preload("res://assets/character/creation/body/010.png"),
	"011" : preload("res://assets/character/creation/body/011.png"),
	"012" : preload("res://assets/character/creation/body/012.png"),
	"013" : preload("res://assets/character/creation/body/013.png"),
	"014" : preload("res://assets/character/creation/body/014.png"),
	"015" : preload("res://assets/character/creation/body/015.png"),
	"016" : preload("res://assets/character/creation/body/016.png"),
	"017" : preload("res://assets/character/creation/body/017.png"),
	"018" : preload("res://assets/character/creation/body/018.png"),
	"020" : preload("res://assets/character/creation/body/020.png"),
	"021" : preload("res://assets/character/creation/body/021.png"),
	"022" : preload("res://assets/character/creation/body/022.png"),
	"023" : preload("res://assets/character/creation/body/023.png"),
	"024" : preload("res://assets/character/creation/body/024.png"),
	"025" : preload("res://assets/character/creation/body/025.png"),
	"026" : preload("res://assets/character/creation/body/026.png"),
	"027" : preload("res://assets/character/creation/body/027.png"),
	"028" : preload("res://assets/character/creation/body/028.png"),
	"030" : preload("res://assets/character/creation/body/030.png"),
	"031" : preload("res://assets/character/creation/body/031.png"),
	"032" : preload("res://assets/character/creation/body/032.png"),
	"033" : preload("res://assets/character/creation/body/033.png"),
	"034" : preload("res://assets/character/creation/body/034.png"),
	"035" : preload("res://assets/character/creation/body/035.png"),
	"036" : preload("res://assets/character/creation/body/036.png"),
	"037" : preload("res://assets/character/creation/body/037.png"),
	"038" : preload("res://assets/character/creation/body/038.png"),
	"040" : preload("res://assets/character/creation/body/040.png"),
	"041" : preload("res://assets/character/creation/body/041.png"),
	"042" : preload("res://assets/character/creation/body/042.png"),
	"043" : preload("res://assets/character/creation/body/043.png"),
	"044" : preload("res://assets/character/creation/body/044.png"),
	"045" : preload("res://assets/character/creation/body/045.png"),
	"046" : preload("res://assets/character/creation/body/046.png"),
	"047" : preload("res://assets/character/creation/body/047.png"),
	"048" : preload("res://assets/character/creation/body/048.png"),
	"050" : preload("res://assets/character/creation/body/050.png"),
	"051" : preload("res://assets/character/creation/body/051.png"),
	"052" : preload("res://assets/character/creation/body/052.png"),
	"053" : preload("res://assets/character/creation/body/053.png"),
	"054" : preload("res://assets/character/creation/body/054.png"),
	"055" : preload("res://assets/character/creation/body/055.png"),
	"056" : preload("res://assets/character/creation/body/056.png"),
	"057" : preload("res://assets/character/creation/body/057.png"),
	"058" : preload("res://assets/character/creation/body/058.png"),
	"100" : preload("res://assets/character/creation/body/100.png"),
	"101" : preload("res://assets/character/creation/body/101.png"),
	"102" : preload("res://assets/character/creation/body/102.png"),
	"103" : preload("res://assets/character/creation/body/103.png"),
	"104" : preload("res://assets/character/creation/body/104.png"),
	"105" : preload("res://assets/character/creation/body/105.png"),
	"106" : preload("res://assets/character/creation/body/106.png"),
	"107" : preload("res://assets/character/creation/body/107.png"),
	"108" : preload("res://assets/character/creation/body/108.png"),
	"110" : preload("res://assets/character/creation/body/110.png"),
	"111" : preload("res://assets/character/creation/body/111.png"),
	"112" : preload("res://assets/character/creation/body/112.png"),
	"113" : preload("res://assets/character/creation/body/113.png"),
	"114" : preload("res://assets/character/creation/body/114.png"),
	"115" : preload("res://assets/character/creation/body/115.png"),
	"116" : preload("res://assets/character/creation/body/116.png"),
	"117" : preload("res://assets/character/creation/body/117.png"),
	"118" : preload("res://assets/character/creation/body/118.png"),
	"120" : preload("res://assets/character/creation/body/120.png"),
	"121" : preload("res://assets/character/creation/body/121.png"),
	"122" : preload("res://assets/character/creation/body/122.png"),
	"123" : preload("res://assets/character/creation/body/123.png"),
	"124" : preload("res://assets/character/creation/body/124.png"),
	"125" : preload("res://assets/character/creation/body/125.png"),
	"126" : preload("res://assets/character/creation/body/126.png"),
	"127" : preload("res://assets/character/creation/body/127.png"),
	"128" : preload("res://assets/character/creation/body/128.png"),
	"130" : preload("res://assets/character/creation/body/130.png"),
	"131" : preload("res://assets/character/creation/body/131.png"),
	"132" : preload("res://assets/character/creation/body/132.png"),
	"133" : preload("res://assets/character/creation/body/133.png"),
	"134" : preload("res://assets/character/creation/body/134.png"),
	"135" : preload("res://assets/character/creation/body/135.png"),
	"136" : preload("res://assets/character/creation/body/136.png"),
	"137" : preload("res://assets/character/creation/body/137.png"),
	"138" : preload("res://assets/character/creation/body/138.png"),
	"140" : preload("res://assets/character/creation/body/140.png"),
	"141" : preload("res://assets/character/creation/body/141.png"),
	"142" : preload("res://assets/character/creation/body/142.png"),
	"143" : preload("res://assets/character/creation/body/143.png"),
	"144" : preload("res://assets/character/creation/body/144.png"),
	"145" : preload("res://assets/character/creation/body/145.png"),
	"146" : preload("res://assets/character/creation/body/146.png"),
	"147" : preload("res://assets/character/creation/body/147.png"),
	"148" : preload("res://assets/character/creation/body/148.png"),
	"150" : preload("res://assets/character/creation/body/150.png"),
	"151" : preload("res://assets/character/creation/body/151.png"),
	"152" : preload("res://assets/character/creation/body/152.png"),
	"153" : preload("res://assets/character/creation/body/153.png"),
	"154" : preload("res://assets/character/creation/body/154.png"),
	"155" : preload("res://assets/character/creation/body/155.png"),
	"156" : preload("res://assets/character/creation/body/156.png"),
	"157" : preload("res://assets/character/creation/body/157.png"),
	"158" : preload("res://assets/character/creation/body/158.png"),
}

"""
hair pigment hex:
Yellow:
Brown:
Black:
Orange:
"""
const hair_spritesheet = {
	
}

"""
eyes pigment hex:
Black: 0
"""
const eye_spritesheet = {
	
}
