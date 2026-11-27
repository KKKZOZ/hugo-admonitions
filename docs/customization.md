# Customization Guide

[← Back to README](../README.md)

`hugo-admonitions` gives you three levels of customization. Pick the lightest one that does what you need:

| Level | Good for | Needs Dart Sass | Survives module updates |
| --- | --- | :---: | :---: |
| [1. CSS custom properties](#1-css-custom-properties) | Colors, opacity | No | Yes |
| [2. Sass variable overrides](#2-sass-variable-overrides) | Colors, opacity, dark-mode selectors | Yes | Yes |
| [3. Full SCSS override](#3-full-scss-override) | Layout, spacing, animations, new rules | Yes | No (you merge upstream changes) |

- [1. CSS custom properties](#1-css-custom-properties)
- [2. Sass variable overrides](#2-sass-variable-overrides)
  - [Global theme colors](#global-theme-colors)
  - [Per-type base colors](#per-type-base-colors)
  - [Per-type header text and icon colors](#per-type-header-text-and-icon-colors)
- [Dark mode](#dark-mode)
- [Custom types](#custom-types)
- [3. Full SCSS override](#3-full-scss-override)

---

## 1. CSS custom properties

The module ships pre-compiled CSS by default, so it works with **standard Hugo** (no Sass needed). To change colors, override its CSS custom properties in a stylesheet that loads **after** the module styles.

```css
/* Light mode */
:root {
  --adm-bg: #ffffff;               /* content background */
  --adm-header-bg-opacity: 0.15;   /* header tint strength, 0–1 */

  /* Each type has two variables: */
  --adm-note: #2563eb;             /* left border, header tint, icon & header text */
  --adm-note-header: #1d4ed8;      /* optional: header text & icon only */
}

/* Dark mode: use the selector your theme uses (see "Dark mode" below) */
html[data-theme="dark"] {
  --adm-note: #93c5fd;
}
```

> [!NOTE]
> Older versions also needed `--adm-<type>-rgb` for the header tint. The tint is now derived from `--adm-<type>` with `color-mix()`, so you can delete any `-rgb` variables you set.

<details>
<summary>All available variables</summary>

**Global:** `--adm-bg`, `--adm-text`, `--adm-code-bg`, `--adm-code-text`, `--adm-blockquote-border`, `--adm-header-bg-opacity`

**Per type:** `--adm-<type>`, `--adm-<type>-header`, where `<type>` is one of the following or a [custom type](#custom-types):
`abstract` `caution` `code` `conclusion` `danger` `error` `example` `experiment` `goal` `idea` `important` `info` `memo` `note` `notify` `question` `quote` `success` `task` `tip` `warning`

</details>

---

## 2. Sass variable overrides

This option is update-friendly and has more control than CSS variables (for example, the dark-mode selector list). You need **Dart Sass** in every environment that builds your site, both locally and in CI/CD.

**Step 1: enable Sass compilation** in your site config:

```toml
[params.hugoAdmonitions]
enableSass = true
```

With this option disabled (the default), the module does not compile SCSS and uses the pre-compiled CSS instead.

**Step 2: create the settings file** at the root of your Hugo project:

```shell
mkdir -p assets/sass/vendors
touch assets/sass/vendors/_admonitions-user-settings.scss
```

```text
your-hugo-project/
└── assets/
    └── sass/
        └── vendors/
            └── _admonitions-user-settings.scss  <-- your settings
```

**Step 3: override the variables you need.** See [the bundled example file](../assets/sass/vendors/_admonitions-user-settings.scss) for a minimal starting point.

> [!IMPORTANT]
> **Do not use `!default`** in this file. Your values automatically take precedence over the module's defaults.

### Global theme colors

```scss
// assets/sass/vendors/_admonitions-user-settings.scss

// Light mode
$admonition-light-bg: #ffffff;                 // Content background
$admonition-light-text: #000000;               // Content text
$admonition-light-code-bg: #f5f5f5;            // Inline code & code block background
$admonition-light-code-text: #24292e;          // Inline code & code block text
$admonition-light-blockquote-border: #e0e0e0;  // Blockquote left border

// Dark mode
$admonition-dark-bg: #1d1e20;
$admonition-dark-text: #e6e6e6;
$admonition-dark-code-bg: #313244;
$admonition-dark-code-text: #cdd6f4;
$admonition-dark-blockquote-border: #45475a;

// Header tint opacity (0 = transparent, 1 = opaque)
$admonition-light-header-bg-opacity: 0.1;
$admonition-dark-header-bg-opacity: 0.1;
```

### Per-type base colors

The base color is used for the left border, the tinted header background and, by default, the header text and icon. Your map is merged with the module's defaults (`$admonition-colors-base` in [`_admonitions.scss`](../assets/sass/vendors/_admonitions.scss)), and your values win.

```scss
$admonition-colors-overrides: (
  note: #007bff,
  tip: #28a745,
  warning: #ffc107,
  danger: #dc3545
);
```

### Per-type header text and icon colors

Use these maps when a base color doesn't have enough contrast against its own tinted header.

```scss
$admonition-light-header-text-overrides: (
  // Yellow (#ffc107) is too light for text on a light background
  warning: #a37100
);

$admonition-dark-header-text-overrides: (
  danger: #ff9e8f,
  note: #ffffff
);
```

---

## Dark mode

By default the module does **not** follow `prefers-color-scheme` (to make it, see [Following the system setting](#following-the-system-setting)). It matches your theme's dark-mode toggle by looking for common selectors on `<html>` or `<body>`:

| Pattern | Selectors |
| --- | --- |
| `data-theme` | `html[data-theme="dark"]`, `body[data-theme="dark"]` |
| Bootstrap | `html[data-bs-theme="dark"]` |
| `data-scheme` | `html[data-scheme="dark"]`, `body[data-scheme="dark"]` |
| `data-color-mode` | `html[data-color-mode="dark"]`, `body[data-color-mode="dark"]` |
| Classes | `.dark`, `.dark-mode`, `.dark-theme`, `.theme-dark` on `html` or `body` |

If your theme uses something else, callouts will stay light when the site goes dark. You can fix this in either of two ways:

- **Without Sass:** copy the dark-mode variables onto your theme's selector (see the [CSS example](#1-css-custom-properties) above).
- **With Sass:** override `$admonition-dark-selector` in `_admonitions-user-settings.scss`:

  ```scss
  $admonition-dark-selector: (
    'html[data-mode="night"]',
    'body.is-dark'
  );
  ```

> [!NOTE]
> Still stuck? [Open an issue](https://github.com/KKKZOZ/hugo-admonitions/issues/new) with your theme's name. Adding more default selectors is easy.

### Following the system setting

If your site has no theme toggle and simply follows the OS, or if it does both, turn on automatic mode. It works with the pre-compiled CSS as well as with Sass:

```toml
[params.hugoAdmonitions]
darkMode = "auto"   # default: "selector"
```

In automatic mode, callouts turn dark when the reader's system prefers dark (`@media (prefers-color-scheme: dark)`). Explicit markers still win:

- The dark selectors above always force dark.
- The matching light selectors force light, even when the system is dark. These are `html[data-theme="light"]`, `.light`, `.light-mode`, `.light-theme`, `.theme-light` and the other light counterparts of the table above.

With Sass you can set `$admonition-dark-mode-auto: true` in `_admonitions-user-settings.scss` instead. You can also change the light markers with `$admonition-light-selector`.

---

## Custom types

Any type name becomes a callout type once your site provides an icon for it. For example, to add `> [!ROCKET]`:

**1. Add the icon** at `layouts/partials/admonitions/icons/rocket.svg` in your site. Any single-color SVG works. The module colors it with `currentColor`, and it adds `aria-hidden="true"` and a default size if the file doesn't set them.

**2. Give it a color.** Without a color it uses the `note` color.

- **With CSS:** define `--adm-rocket`, plus `--adm-rocket-header` if you want a different header color. Define them once per mode, like the built-in types:

  ```css
  :root { --adm-rocket: #c2410c; }
  html[data-theme="dark"] { --adm-rocket: #fdba74; }
  ```

- **With Sass:** add it to the color maps in `_admonitions-user-settings.scss`:

  ```scss
  $admonition-colors-overrides: (rocket: #c2410c);
  $admonition-dark-colors-overrides: (rocket: #fdba74);
  ```

**3. Optional: give it a localized title** by adding `admonitions.rocket` to your site's `i18n/<lang>.yaml`. Otherwise the title is the type name in title case ("Rocket").

Type names must start with a letter and may contain lowercase letters, digits, `-` and `_`. A custom icon whose name matches an [alias](../README.md#callout-types), such as `bug.svg`, takes precedence over that alias. Built-in type names always use the built-in icon. To change a built-in icon, override its file in `layouts/partials/admonitions/icons/` instead.

---

## 3. Full SCSS override

For changes that variables can't express (structure, spacing, animations, new rules), replace the module's main stylesheet.

> [!CAUTION]
> After you do this, you are responsible for merging upstream changes to `_admonitions.scss` into your copy if you want future fixes and features.

1. Enable Sass compilation (see [step 1 above](#2-sass-variable-overrides)).
2. Create `assets/sass/vendors/_admonitions.scss` in your project.
3. Copy the contents of the [source file](../assets/sass/vendors/_admonitions.scss) into it.
4. Edit as needed.
