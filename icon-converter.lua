img = {
--[[ 
image goes here
  
use piskel and set dimentions to 16x16 and only use colors 0x00000000, or 0xffffffff. use hex color system and export a C. Paste table into here.

--]]
}
newImg={}
for i=1,#img do
	if img[i] > 0 then
		table.insert(newImg,1)
	else
		table.insert(newImg,0)
	end
end

text = "{"
for i=1,#newImg do
	text = text .. newImg[i] .. ", "
end
text = text .. "},"

print(text)
