--!native

local BitmapMaker = {}

type BitmapInputRow = {Color3}

type BitmapInputData = {
	rows: {BitmapInputRow},
	width: number,
	height: number,
}

function BitmapMaker.createBitmapFile(data: BitmapInputData)
	local header = {
		-- header, 3-6 == total size, 11-14 == offset for pixel data
		0x42, 0x4D, 0xFF, 0xFF, 0xFF, 0xFF, 0x00, 0x00, 0x00, 0x00, 0xFF, 0xFF, 0xFF, 0xFF,
	}
	
	local widthBytes = string.split(string.pack("<I4", data.width), "")
	local heightBytes = string.split(string.pack("<I4", data.height), "")
	local dibHeader = {
		-- 4 bytes for size of dib header
		0x28, 0x00, 0x00, 0x00,
		-- width
		string.byte(widthBytes[1]), string.byte(widthBytes[2]), string.byte(widthBytes[3]), string.byte(widthBytes[4]),
		-- height (bottom to top)
		string.byte(heightBytes[1]), string.byte(heightBytes[2]), string.byte(heightBytes[3]), string.byte(heightBytes[4]),
		-- color plane
		0x01, 0x00,
		-- 24 bit
		0x18, 0x00,
		-- no compression
		0x00, 0x00, 0x00, 0x00,
		-- size of bitmap data
		0x00, 0x00, 0x00, 0x00,
		-- print resolution x
		0x13, 0x0B, 0x00, 0x00,
		-- print resolution y
		0x13, 0x0B, 0x00, 0x00,
		-- 0 colors in pallete
		0x00, 0x00, 0x00, 0x00,
		-- all colors important
		0x00, 0x00, 0x00, 0x00,
	}
	
	local pixelRows = {}
	for i=#data.rows, 1, -1 do
		local rowData = data.rows[i]
		local pixelRow = {}
		for _, pixelColor in rowData do
			local r, g, b = math.round(pixelColor.R * 255), math.round(pixelColor.G * 255), math.round(pixelColor.B * 255)
			r, g, b = math.clamp(r, 0, 255), math.clamp(g, 0, 255), math.clamp(b, 0, 255)
			table.insert(pixelRow, b)
			table.insert(pixelRow, g)
			table.insert(pixelRow, r)
		end
		local extra = 4 - (#pixelRow % 4)
		if extra == 4 then
			extra = 0
		end
		for i=1, extra do
			table.insert(pixelRow, 0x00)
		end
		table.insert(pixelRows, pixelRow)
	end
	
	local pixelData = {}
	for _, pixelRow in pixelRows do
		for _, pixelByte in pixelRow do
			table.insert(pixelData, pixelByte)
		end
	end
	
	local finalArray = {}
	
	for _, v in header do
		table.insert(finalArray, v)
	end
	for _, v in dibHeader do
		table.insert(finalArray, v)
	end
	for _, v in pixelData do
		table.insert(finalArray, v)
	end
	
	local totalBytes = #finalArray
	local sizeBytes = string.split(string.pack("<I4", totalBytes), "")
	finalArray[3] = string.byte(sizeBytes[1]) :: number
	finalArray[4] = string.byte(sizeBytes[2]) :: number
	finalArray[5] = string.byte(sizeBytes[3]) :: number
	finalArray[6] = string.byte(sizeBytes[4]) :: number
	
	local bytesForHeaders = #header + #dibHeader
	local pixelOffset = string.split(string.pack("<I4", bytesForHeaders), "")
	finalArray[11] = string.byte(pixelOffset[1]) :: number
	finalArray[12] = string.byte(pixelOffset[2]) :: number
	finalArray[13] = string.byte(pixelOffset[3]) :: number
	finalArray[14] = string.byte(pixelOffset[4]) :: number
	
	for i, v in finalArray do
		finalArray[i] = string.char(v)
	end
	
	local binary = table.concat(finalArray)
	return binary
end

return BitmapMaker
