---
title: "Edge Cases Test"
---

## Test Case 1: Invalid AlertType fallback

> [!INVALIDTYPE] This should fallback to regular blockquote
> When AlertType is not recognized

## Test Case 2: Empty AlertType

> This should render as regular blockquote
> When Type is alert but AlertType is empty

## Test Case 3: All valid admonition types

> [!NOTE] Note admonition
> This is a note

> [!TIP] Tip admonition
> This is a tip

> [!WARNING] Warning admonition
> This is a warning

> [!IMPORTANT] Important admonition
> This is important

> [!CAUTION] Caution admonition
> This is a caution

> [!DANGER] Danger admonition
> This is dangerous

## Test Case 4: Foldable admonitions

> [!NOTE]- Foldable closed
> This is a foldable note that starts closed

> [!TIP]+ Foldable open
> This is a foldable tip that starts open

## Test Case 5: Admonitions with custom titles

> [!IDEA] Custom Title
> This admonition has a custom title

> [!SUCCESS] Another Custom Title
> This success admonition also has a custom title

