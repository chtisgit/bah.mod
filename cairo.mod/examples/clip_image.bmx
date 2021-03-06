SuperStrict

Import BaH.Cairo

Local cairo:TCairo = TCairo.Create(TCairoImageSurface.CreateForPixmap(256,256))


Local normalizeMat:TCairoMatrix = TCairoMatrix.CreateScale(256.0,256.0)
cairo.SetMatrix(normalizeMat)
cairo.SetLineWidth(0.05)

'
Local photo:TPixmap = LoadPixmap("romedalen.png")
'photo = photo.Convert(PF_RGBA8888)

Local photosurf:TCairoSurface = TCairoImageSurface.CreateFromPixmap(photo)

cairo.Arc(0.5, 0.5, 0.3, 0, 360)
cairo.Clip()
cairo.NewPath() ' path not consumed by clip()

cairo.Scale(1.0/PixmapWidth(photo), 1.0/PixmapHeight(photo))

cairo.SetSourceSurface(photosurf, 0, 0);
cairo.Paint()

photosurf.Destroy()

'

cairo.Destroy()

Local image:TImage = LoadImage(TCairoImageSurface(cairo.getTarget()).pixmap())

Graphics 640,480,0

SetBlend ALPHABLEND

SetClsColor 255,255,255

Repeat
	Cls
	DrawImage image,MouseX() - 128,MouseY() - 128
	Flip
Until KeyHit(key_escape)

End
