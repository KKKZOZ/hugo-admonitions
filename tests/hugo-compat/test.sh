#!/usr/bin/env bash

set -euo pipefail

mode="${1:-precompiled}"
case "$mode" in
  precompiled|scss) ;;
  *)
    echo "Unknown test mode: $mode" >&2
    exit 2
    ;;
esac

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
site_dir="$repo_root/tests/hugo-compat/site"
output_dir="$(mktemp -d "${TMPDIR:-/tmp}/hugo-admonitions-test.XXXXXX")"
trap 'rm -rf "$output_dir"' EXIT

config_files="hugo.toml"
if [[ "$mode" == "scss" ]]; then
  config_files="hugo.toml,hugo-sass.toml"
fi

echo "Testing mode: $mode"
hugo_version="$(hugo version)"
echo "$hugo_version"

case "${EXPECTED_HUGO_EDITION:-}" in
  standard)
    if [[ "$hugo_version" == *extended* ]]; then
      echo "Expected standard Hugo, got: $hugo_version" >&2
      exit 1
    fi
    ;;
  extended)
    if [[ "$hugo_version" != *extended* ]]; then
      echo "Expected Hugo Extended, got: $hugo_version" >&2
      exit 1
    fi
    ;;
  "") ;;
  *)
    echo "Unknown expected Hugo edition: $EXPECTED_HUGO_EDITION" >&2
    exit 2
    ;;
esac

if [[ "$mode" == "scss" ]]; then
  sass --version

  for entry in admonitions admonitions-auto; do
    source_file="$repo_root/assets/sass/vendors/$entry.scss"
    if [[ "$entry" == "admonitions" ]]; then
      source_file="$repo_root/assets/sass/vendors/_admonitions.scss"
    fi

    sass --no-source-map --style=expanded "$source_file" "$output_dir/$entry.css"
    cmp "$output_dir/$entry.css" "$repo_root/assets/css/vendors/$entry.css"

    sass --no-source-map --style=compressed "$source_file" "$output_dir/$entry.min.css"
    cmp "$output_dir/$entry.min.css" "$repo_root/assets/css/vendors/$entry.min.css"
  done
fi

# Builds the test site and checks the rendered page.
#   $1: dark mode variant ("selector" or "auto")
run_build() {
  local dark_mode="$1"
  local build_configs="$config_files"
  local style_name="admonitions"
  if [[ "$dark_mode" == "auto" ]]; then
    build_configs="$build_configs,hugo-auto.toml"
    style_name="admonitions-auto"
  fi

  local public_dir="$output_dir/public-$dark_mode"
  echo "Building with darkMode=$dark_mode"

  HUGO_CACHEDIR="$output_dir/cache" \
  HUGO_RESOURCEDIR="$output_dir/resources-$dark_mode" \
  hugo \
    --source "$site_dir" \
    --config "$build_configs" \
    --destination "$public_dir" \
    --environment production \
    --noBuildLock \
    --cleanDestinationDir

  local html_file="$public_dir/test/index.html"
  if [[ ! -f "$html_file" ]]; then
    echo "Rendered page not found: $html_file" >&2
    exit 1
  fi

  grep -q 'class="admonition note"' "$html_file"
  grep -q 'Compatibility title' "$html_file"
  # "-" starts collapsed, "+" starts expanded.
  grep -q '<details class="admonition tip">' "$html_file"
  grep -q '<details class="admonition tip" open>' "$html_file"
  # [!TODO] is an alias of task.
  grep -q 'class="admonition task"' "$html_file"
  if grep -q 'admonition todo' "$html_file"; then
    echo "Alias type leaked into the rendered class" >&2
    exit 1
  fi
  # Every icon is decorative and has a default size, even before CSS loads.
  if grep -o '<svg[^>]*>' "$html_file" | grep -v 'aria-hidden="true"' | grep -q .; then
    echo "Found an icon without aria-hidden" >&2
    exit 1
  fi
  if grep -o '<svg[^>]*>' "$html_file" | grep -v 'width="1em" height="1em"' | grep -q .; then
    echo "Found an icon without a default size" >&2
    exit 1
  fi
  # A site-provided icon defines a custom type colored through --adm-rocket.
  grep -q '<div class="admonition rocket" style="--adm-type-color: var(--adm-rocket, var(--adm-note)); --adm-type-header: var(--adm-rocket-header, var(--adm-type-color))">' "$html_file"
  grep -q 'Custom type' "$html_file"

  local stylesheet_count
  stylesheet_count="$(grep -o 'rel="stylesheet"' "$html_file" | wc -l | tr -d ' ')"
  if [[ "$stylesheet_count" != "1" ]]; then
    echo "Expected one stylesheet link, found $stylesheet_count" >&2
    exit 1
  fi

  local css_href css_file
  css_href="$(grep -o "href=\"[^\"]*/$style_name\.[^\"]*css\"" "$html_file" | head -n 1 | cut -d '"' -f 2)"
  css_file="$public_dir$css_href"
  if [[ -z "$css_href" || ! -f "$css_file" ]]; then
    echo "Generated $style_name CSS not found in $html_file" >&2
    exit 1
  fi

  grep -q '.admonition.note' "$css_file"
  grep -q 'color-mix(in srgb' "$css_file"
  if grep -q -- '-rgb' "$css_file"; then
    echo "Legacy -rgb variables are still generated" >&2
    exit 1
  fi

  if [[ "$dark_mode" == "auto" ]]; then
    grep -q 'prefers-color-scheme:[[:space:]]*dark' "$css_file"
  elif grep -q 'prefers-color-scheme' "$css_file"; then
    echo "prefers-color-scheme leaked into the selector-only stylesheet" >&2
    exit 1
  fi

  if [[ "$mode" == "scss" ]]; then
    # Light override appears once per palette: light and dark, plus the
    # prefers-color-scheme copies of both in auto mode.
    local expected_overrides=2
    [[ "$dark_mode" == "auto" ]] && expected_overrides=4
    local override_count
    override_count="$(grep -oi '#123456' "$css_file" | wc -l | tr -d ' ')"
    if [[ "$override_count" != "$expected_overrides" ]]; then
      echo "Expected the user color $expected_overrides times, found $override_count occurrences" >&2
      exit 1
    fi
    # Custom types added through $admonition-colors-overrides get a class rule.
    grep -q '\.admonition\.rocket' "$css_file"
  else
    if grep -qi '#123456' "$css_file"; then
      echo "SCSS override leaked into the pre-compiled CSS path" >&2
      exit 1
    fi
    cmp "$repo_root/assets/css/vendors/$style_name.min.css" "$css_file"
    grep -qi '#2062ce' "$css_file"
    grep -qi '#84b2fd' "$css_file"
  fi
}

run_build selector
run_build auto

echo "Compatibility test passed: $mode"
