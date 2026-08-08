# Pre-compiled Admonitions CSS

These CSS files are pre-compiled from `assets/sass/vendors/_admonitions.scss` so the module works on standard Hugo without Dart Sass.

## How rendering decides which CSS to use

`layouts/_default/_markup/render-blockquote-alert.html` loads the pre-compiled CSS by default. Users who explicitly enable SCSS customization compile the source with Dart Sass instead.

- `admonitions.css` - expanded (development)
- `admonitions.min.css` - compressed (production)

## Regenerating the pre-compiled CSS

Whenever `_admonitions.scss` changes, regenerate both files. Either install Dart Sass (`brew install sass/sass/sass`) and run:

```bash
sass --no-source-map --style=expanded \
  assets/sass/vendors/_admonitions.scss \
  assets/css/vendors/admonitions.css

sass --no-source-map --style=compressed \
  assets/sass/vendors/_admonitions.scss \
  assets/css/vendors/admonitions.min.css
```

Or enable the module's Dart Sass build, run `hugo` once, and copy the output from `public/css/vendors/`.
