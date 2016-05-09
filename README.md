# CIFilter
a CoreImage Filter app for iOS

## Overview

![Alt Text](https://github.com/jmade/jmade.github.io/blob/master/cifilter.png?raw=true)

You can add, edit, layer, All of the `CoreImage` filters availible on iOS.

Working on my own projects I have come accross the need for custom controls, some I can reuse but most customized. I also wanted to make use of protocols. 
iOS ships with quite a few `CoreImage` filters. So I thought what else would be better to build this custom-controller object that I could tell it to create and it would tell me how I needed to respond. 

## Filter List

The app's main view is a `UITableView` with a `UIImageView` as a header. The tableView is filled with all the filters availible, it is created live at run time. There are method calls that allow you to get back a list and informaion about each `CIFilter`. *Its almost like they WANT you to use them ;)*

Tap the image above the tableView to add your own.

## Edit View

Tapping on one the filters takes you to the filter edit view. The controls are dynamically created and are placed into the bottom half, the top view is backed by the GPU meaing all edits are visible live realtime. 

![Alt Text](https://github.com/jmade/jmade.github.io/blob/master/line_screen.gif?raw=true)

Tapping on the image will take you back to the filter list view, image unchanged. 

Tapping on the star icon will keep the applied effect when you tap on the image to return to the filter list view . this will also be saved to your camera roll.

![Alt Text](https://github.com/jmade/jmade.github.io/blob/master/hue_adjust_save.gif?raw=true)

Thats pretty much the whole app. The fun in it is creating an object that will create a controller for each type of `CIAttributeType`: point, rectangle, amount, time, color, etc. and then based off of the filter's availible controls, create a controller view and set it up for proper editing. 

## Adaptive Controller

Most of the controls are intuituve. *Some don't work.* All are custom made. Each filter has what is called `CIAttribute`.

When you are changing a control the control will highlight and show emphasis on the editable area.
 
I noticed a few of the filters need to be inside of a scrollview as there are too many controls that the filter offers to fit in the provided space. 
The drawing space for `CIAttribute` Type is not the same as `UIKit` the scale could be off along with the coordinate system. 

**Perspective Adjustment**

![Alt Text](https://github.com/jmade/jmade.github.io/blob/master/perspective_adjustment.gif?raw=true)

**Temperature Tint**

![Alt Text](https://github.com/jmade/jmade.github.io/blob/master/temp_tint.gif?raw=true)

**Tone Curve**

![Alt Text](https://github.com/jmade/jmade.github.io/blob/master/tone_curve.gif?raw=true)


 
