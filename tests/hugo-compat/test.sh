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
fi

HUGO_CACHEDIR="$output_dir/cache" \
HUGO_RESOURCEDIR="$output_dir/resources" \
hugo \
  --source "$site_dir" \
  --config "$config_files" \
  --destination "$output_dir" \
  --environment production \
  --noBuildLock \
  --cleanDestinationDir

html_file="$output_dir/test/index.html"
if [[ ! -f "$html_file" ]]; then
  echo "Rendered page not found: $html_file" >&2
  exit 1
fi

grep -q 'class="admonition note"' "$html_file"
grep -q '<details class="admonition tip">' "$html_file"
grep -q 'Compatibility title' "$html_file"

stylesheet_count="$(grep -o 'rel="stylesheet"' "$html_file" | wc -l | tr -d ' ')"
if [[ "$stylesheet_count" != "1" ]]; then
  echo "Expected one stylesheet link, found $stylesheet_count" >&2
  exit 1
fi

css_href="$(grep -o 'href="[^"]*admonitions[^"]*\.css"' "$html_file" | head -n 1 | cut -d '"' -f 2)"
css_file="$output_dir$css_href"
if [[ -z "$css_href" || ! -f "$css_file" ]]; then
  echo "Generated admonitions CSS not found: $css_file" >&2
  exit 1
fi

grep -q '.admonition.note' "$css_file"

if [[ "$mode" == "scss" ]]; then
  grep -qi '#123456' "$css_file"
else
  if grep -qi '#123456' "$css_file"; then
    echo "SCSS override leaked into the pre-compiled CSS path" >&2
    exit 1
  fi
  cmp "$repo_root/assets/css/vendors/admonitions.min.css" "$css_file"
fi

echo "Compatibility test passed: $mode"
