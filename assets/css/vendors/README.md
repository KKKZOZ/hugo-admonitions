# Pre-compiled CSS

These CSS files are pre-compiled from the SCSS sources for use with standard Hugo (non-extended).

## Files

- `admonitions.css` - Expanded version for development
- `admonitions.min.css` - Minified version for production

## Regenerating CSS

When the SCSS source files in `assets/sass/vendors/` are modified, regenerate these CSS files:

```bash
# From repository root
sass assets/sass/vendors/_admonitions.scss assets/css/vendors/admonitions.css --style=expanded --no-source-map --load-path=assets/sass/vendors

sass assets/sass/vendors/_admonitions.scss assets/css/vendors/admonitions.min.css --style=compressed --no-source-map --load-path=assets/sass/vendors
```

Requires [Dart Sass](https://sass-lang.com/install) to be installed.

## How It Works

The module automatically detects whether Hugo Extended is available:
- **Hugo Extended**: Compiles SCSS on-the-fly with customisation support
- **Standard Hugo**: Uses these pre-compiled CSS files

This ensures the module works for all users regardless of their Hugo installation.
