# Pre-compiled Admonitions CSS

These CSS files are pre-compiled from the SCSS sources in `assets/sass/vendors/` so the module works on standard Hugo without Dart Sass.

## How rendering decides which CSS to use

`layouts/_default/_markup/render-blockquote-alert.html` loads the pre-compiled CSS by default. Users who explicitly enable SCSS customization compile the source with Dart Sass instead.

| File | Source | Used when |
| --- | --- | --- |
| `admonitions.css` / `admonitions.min.css` | `_admonitions.scss` | default (`darkMode = "selector"`) |
| `admonitions-auto.css` / `admonitions-auto.min.css` | `admonitions-auto.scss` | `darkMode = "auto"` |

The `.min.css` files are used in production; the expanded ones are used in development.

## Regenerating the pre-compiled CSS

Whenever the SCSS changes, regenerate all four files with Dart Sass (`brew install sass/sass/sass`):

```bash
V=assets/sass/vendors C=assets/css/vendors
sass --no-source-map --style=expanded   $V/_admonitions.scss       $C/admonitions.css
sass --no-source-map --style=compressed $V/_admonitions.scss       $C/admonitions.min.css
sass --no-source-map --style=expanded   $V/admonitions-auto.scss   $C/admonitions-auto.css
sass --no-source-map --style=compressed $V/admonitions-auto.scss   $C/admonitions-auto.min.css
```

`bash tests/hugo-compat/test.sh scss` fails if any of these files is out of date.
