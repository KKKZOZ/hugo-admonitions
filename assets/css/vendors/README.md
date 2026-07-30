# Pre-compiled Admonitions CSS

These CSS files are pre-compiled from `assets/sass/vendors/_admonitions.scss` so the module works on standard Hugo (without Hugo Extended or Dart Sass).

## How rendering decides which CSS to use

`layouts/_default/_markup/render-blockquote-alert.html` tries to compile the SCSS first. If Hugo Extended is available the user gets full SCSS-variable customisation. If not, the template falls back to the pre-compiled CSS in this directory.

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

Or run `hugo` once with Hugo Extended in this directory and copy the output from `public/css/vendors/`.
