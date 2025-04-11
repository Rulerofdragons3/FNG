shader_type canvas_item;
uniform int mode = 6;
uniform float hueShiftDegrees : hint_range(0.0,360.0) = 0;
uniform vec4 modulate : source_color = vec4(1,1,1,1);

vec4 luminaceConservingColorInversion(vec4 color) {
	float transparency = color.a;
	//Conversion into YIQ colorspace
	//Ty chatgpt for walking mw thru this
	//https://en.wikipedia.org/wiki/YIQ
	//Conversion into YIQ Values
	float Y = 0.299 * color.r + 0.587 * color.g + 0.114 * color.b;
	float I = 0.596 * color.r - 0.275 * color.g - 0.321 * color.b;
	float Q = 0.212 * color.r - 0.523 * color.g + 0.311 * color.b;
	//Invert I and Q components
	I = -I;
	Q = -Q;
	//Convert back to RGB
	color.r = Y + 0.956 * I + 0.621 * Q;
	color.g = Y - 0.272 * I - 0.647 * Q;
	color.b = Y - 1.106 * I + 1.703 * Q;
	//How did anyone figure this out???
	return vec4(color.rgb, transparency);
}

vec4 trueInvert(vec4 color) {
	color.r = 1.0 - color.r;
	color.g = 1.0 - color.g;
	color.b = 1.0 - color.b;
	return color;
}
// https://stackoverflow.com/a/8509802
// Ty Jacob Eggers <3
vec4 doHueShift(vec4 color) {
	float U = cos(hueShiftDegrees * (PI/180.0));
	float W = sin(hueShiftDegrees * (PI/180.0));
	vec4 newColor = vec4(0,0,0,color.a);
	newColor.r = (.299 + .701 * U + .168 * W ) * color.r
    + (.587 - .587 * U + .330 * W) * color.g
    + (.114 - .114 * U -.497 * W) * color.b;
  	newColor.g = (.299-.299*U-.328*W)*color.r
    + (.587+.413*U+.035*W)*color.g
    + (.114-.114*U+.292*W)*color.b;
  	newColor.b = (.299-.3*U+1.25*W)*color.r
    + (.587-.588*U-1.05*W)*color.g
    + (.114+.886*U-.203*W)*color.b;
	return newColor;
}

vec4 doModulate(vec4 color) {
	return color * modulate;
}

void fragment() {
	vec4 pixelColor = texture(TEXTURE,UV);
	switch (mode) {
		case 0:
			COLOR = luminaceConservingColorInversion(pixelColor);
			break;
		case 1:
			COLOR = trueInvert(pixelColor);
			break;
		case 2:
			COLOR = doHueShift(pixelColor);
			break;
		case 3:
			COLOR = doModulate(pixelColor);
			break;
		default:
			COLOR = pixelColor;
			break;
	}
	
}