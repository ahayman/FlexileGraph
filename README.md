FlexileGraph
============

### Low level Graphing Framework (unfinished)

Flexile Graph is a low level graphing framework designed to be efficient at handling and animating large amounts of data.  It's somewhat similar to Core-Plot in it's design (which I took inspiration from) with the exception that I use low-level primitives and pointers to keep memory pressure as low as possible.  I also use filtering algorithms to only display those points that can be displayed at present (meaning, if the screen can only display 1024 pixels, I don't draw out 10,000 points in Core Graphics).

It does require knowledge of "vanilla" `C`, pointers, and c-arrays.  Data is passed in using `Double` typed c-array pointers. Wherever possible, "slicing" is used instead of memcpy, meaning I pass in a reference and count instead of copying the array.  This drastically reduces the memory pressure from the NSArray of NSDecimalNumber that Core-Plot uses, which balloons the memory foot print when dealing with thousands of values.

This framework relies on `CAShapeLayer` to perform it's drawing instead of redrawing the screen for each animation.  So, yeah, no fancy graphics here.  You're limited to flat colors and outlines.  However, the performance gain is almost atronomical.  With a line-graph of 10,000 points in Core-Plot, animations were near 1-2 FPS on an iPad 3 and half the time the app would crash due to memory pressure.  In FlexileGraph, the memory pressure was negligable with 20-50 FPS.  

### Status

The framework is still under development, but since Swift came out I've begun porting the framework over to Swift instead.  Completed:

 - Line, Scatter Plots and Range Plots
 - Axis, Tick and Label Generation

Need to do:

 - Bar graphs
 - Overlays

Likely I will port the framework over to Swift and finish it there.  At that point I will decide whether I want to finish it's objective-c counterpart or not.  

