extends Node

func createShiny(img,type = "default"):
	var imagePixels = img.get_data()
	for i in range(0, len(imagePixels), 4):
		#Gets inverted color for each pixel
		if type == "default":
			var invertedColor = luminaceConservingColorInversion(
				imagePixels[i],imagePixels[i+1],imagePixels[i+2])
			
			imagePixels[i+0] = invertedColor[0]
			imagePixels[i+1] = invertedColor[1]
			imagePixels[i+2] = invertedColor[2]
		elif type == "trueInvert":
			imagePixels[i+0] = clamp(255 - imagePixels[i+0],0,255)
			imagePixels[i+1] = clamp(255 - imagePixels[i+1],0,255)
			imagePixels[i+2] = clamp(255 - imagePixels[i+2],0,255)
		elif type == "none":
			pass
		
	img.set_data(
		img.get_size()[0],
		img.get_size()[1],
		false,
		Image.FORMAT_RGBA8,
		imagePixels
	) #RAHHH
	
	#Creates a new ImageTexture, with content of the previous image
	return ImageTexture.create_from_image(img)
	
func luminaceConservingColorInversion(R,G,B):
	#Conversion into YIQ colorspace
	#Ty chatgpt for walking mw thru this
	#https://en.wikipedia.org/wiki/YIQ
	#Conversion of colors to a ratio of one
	#R /= 255
	#G /= 255
	#B /= 255
	#Conversion into YIQ Values
	var Y = 0.299 * R + 0.587 * G + 0.114 * B
	var I = 0.596 * R - 0.275 * G - 0.321 * B
	var Q = 0.212 * R - 0.523 * G + 0.311 * B
	#Invert I and Q components
	I = -I
	Q = -Q
	#Convert back to RGB
	R = Y + 0.956 * I + 0.621 * Q
	G = Y - 0.272 * I - 0.647 * Q
	B = Y - 1.106 * I + 1.703 * Q
	var RGB = [
		clamp(R, 0, 255),
		clamp(G, 0, 255),
		clamp(B, 0, 255)
	]
	#How did anyone figure this out???
	return RGB


