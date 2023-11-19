# BitmapMaker.luau

[Roblox Creator Marketplace](https://create.roblox.com/marketplace/asset/15399657068/BitmapMaker)

Library for creating .bmp images in Luau

## Types

```luau
type BitmapInputRow = {Color3}

type BitmapInputData = {
	rows: {BitmapInputRow},
	width: number,
	height: number,
}

-- if used outside Roblox, Color3 is represented as 3 numbers in the range [0, 1]. 
type Color3 = {
  R: number,
  G: number,
  B: number,
}
```

## API

### `BitmapMaker.createBitmapFile(data: BitmapInputData): string`

Given `data`, returns a binary string representing the file. 
