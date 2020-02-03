# Yolo

I stole this from [the internet](https://gist.github.com/jmhobbs/b6ba8f5d1f816506e5b671c1bd89c723)

# Install
imagemagick `brew install imagemagick`

gifsicle `brew install gifsicle`

I've only tried this on a mac

# Usage

usage: `yolo.sh [options] <message>`

## Options:

`-h` Show this help message

`-o <output.gif>` Path to output gif. Default: yolo.gif

`-c <color>` Choose color set, valid options are: red, orange, yellow, green, blue, purple, pink, black, white.  Default: blue

`-w` Force white text color

# Example

```
sh yolo.sh -o test.gif -c blue hello
```

creates a scrolly blue text that says "hello" in a file called `test.gif` in `/output`
