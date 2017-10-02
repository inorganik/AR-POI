# AR-POI
Use ARKit to view points of interest

![demo](demo.GIF)

AR-POI uses the Google maps api to search places and presents them in an AR view. The main value you'll get from this lib is probably 1 or more of the following:

 1. AR-POI does the work of placing the node anchor at the correct heading.
 2. Use Google maps api data to show tooltips in virtual space
 3. AR-POI creates great looking POI tooltips that handle varying amounts of text, which also display the distance.
 
The tooltips are customizable and the [PaintCode](https://www.paintcodeapp.com/) file with which they were generated is included in the project. So you can customize the tooltip to your heart's content.

## Setup

I recommend cloning this project and customizing it rather than adding it as a dependency within your project. To use the Google maps api **[you must get an api key](https://support.google.com/googleapi/answer/6158862)**. Set your key somewhere, I did it in a gitignore'd file.

```swift
let googleApiKey = "YOUR_KEY_HERE"
```
Then change the **bundle identifier** and **code signing** and you should be good to go.

## Customizing

- Edit the place search term, or create a mechanism for user input. The search term is set in `ARViewController`, inside the `getAndDisplayItemsAroundLocation` method.
- `ARAnnotation.swift` is the file/class that you can use to customize the tooltip label. 
- The tooltip design is controlled by the drawing code in `ARPOIUI.swift` which was generated with PaintCode. You can rexport the drawing code from the included PaintCode file, then alter the drawing method if needed, which is used in `ARAnnotation.swift`.
- `ARViewController.swift` contains the code for the _placement_ of the tooltips. Properties of note include:
  - `anchorDistNearest`, `anchorDistFarthest` - for the distance in meters where the closest and farthest POIs will be placed in virtual space - this affects the size appearance, which helps convey distance
  - `anchorDegreesNearest` and `anchorDegreesFarthest` for the degrees up from the horizon the POI will be placed at, also to help convey distance, and to make POIs visible to help with overlapping.
- `ContainerViewController.swift` is a container view that holds `ARViewController`, which holds `Scene.sks`. The advantage of the container view is that you can use regular UIKit controls over top of the AR view without having to do anything with SpriteKit. You can also add more views in the container view to toggle between views, for instance with a segmented control or toolbar.
