= Mapel

Mapel is a dead-simple, chainable image-rendering DSL for ImageMagick.
Still very much an experiment-in-progress, it supports a dozen or so essential
commands.


== Usage

Mapel supports chaining various commands to perform image transformations.
The basic format is:

    Mapel.render("input.jpg").<commands>.to("output.jpg").run

=== Example

    Mapel.render("image.jpg").resize("100x").to("resized_image.jpg").run

=== Supported commands

Some commands support ImageMagick geometry. For a complete list of geometry options,
visit http://www.imagemagick.org/script/command-line-processing.php#geometry.

    crop(<geometry>)    # Crops an image
    gravity(<type>)     # Sets the current gravity suggestion
    orient              # Automatically rotates an image with EXIF Orientation
    repage              # Resets the virtual canvas meta-data on the image
    resize(<geometry>)  # Resizes an image
    resize!(<geometry>) # Crop-resizes an image: performs resize + crop + repage
    scale(<geometry>)   # Scales an image, which is faster than resizing it
    strip               # Removes any profiles or comments from the image
    grayscale           # Grayscales an image

For more information on the available methods and how they are translated to ImageMagick options, please read the source.

== Getting image information

    Mapel.info("input.jpg")  # { path: ..., format: ..., dimensions: ..., depth: ..., size: ...}

== Getting EXIF meta data

    Mapel.exif("input.jpg")

== Meta

Written by Aleks Williams (http://github.com/akdubya)

Released under the MIT License: www.opensource.org/licenses/mit-license.php

github.com/akdubya/mapel

Fun Fact: Mapel is named after a tortoiseshell cat.