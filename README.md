# simple-rtmp-broadcaster

A simple flash rtmp broadcaster implemented in Haxe.

Tested using a [Red5](https://www.red5pro.com) server, though the implementation should be generic enough to also support [Flash Media Server](http://www.adobe.com/ca/products/adobe-media-server-family.html).

## How to use

Just add the compiled `broadcaster.swf` file to your page using the method of your choice.

The following **flashvars** are required:

- **streamname**: String, an unique id for the publishing video
- **host**: String, your rtmp host address
- **context**: String, the rmtp host context

## Compiling

Get the latest version of [Haxe](http://haxe.org/) for the platform of your choice.

If using linux/osx you may use `bash ./compile` in order to compile the **swf** file.

## License

MIT © [Ruy Adorno](http://ruyadorno.com/)

