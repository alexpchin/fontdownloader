[![Code Climate](https://codeclimate.com/github/alexpchin/fontdownloader/badges/gpa.svg)](https://codeclimate.com/github/alexpchin/fontdownloader)

[![Test Coverage](https://codeclimate.com/github/alexpchin/fontdownloader/badges/coverage.svg)](https://codeclimate.com/github/alexpchin/fontdownloader)

Font Downloader
===============

Font Downloader allows you to input any url and download the fonts that are embedded in that website's stylesheet. Font Downloader should only be used to download fonts that you are allowed to access.

## What will I get?

Once Font Downloader has looked through the URL, it will download them, zip them up and send them to you. 

## How to include the fonts?
Once you have downloaded the zip file of the fonts from the URL (if there are any), then this is the most common way to include a custom font in CSS:

```
@font-face {
  font-family: 'MyWebFont';
  src: url('webfont.eot'); /* IE9 Compat Modes */
  src: url('webfont.eot?#iefix') format('embedded-opentype'), /* IE6-IE8 */
       url('webfont.woff') format('woff'), /* Modern Browsers */
       url('webfont.ttf')  format('truetype'), /* Safari, Android, iOS */
       url('webfont.svg#svgFontName') format('svg'); /* Legacy iOS */
  }
```

Things are shifting heavily toward WOFF though, so you can probably get away with:

```
@font-face {
  font-family: 'MyWebFont';
  src: url('myfont.woff') format('woff'), /* Chrome 6+, Firefox 3.6+, IE 9+, Safari 5.1+ */
       url('myfont.ttf') format('truetype'); /* Chrome 4+, Firefox 3.5, Opera 10+, Safari 3—5 */
}
```