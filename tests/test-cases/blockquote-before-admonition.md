---
title: "Blockquote Before Admonition Test"
---

## Test Case 1: Blockquote immediately before Admonition (Issue #43)

> Testing

> [!NOTE] This is an awesome admonition
> The rest of the details here

## Test Case 2: Blockquote with text between (Issue #43)

> Testing

Lorum ipsum

> [!NOTE] This is an awesome admonition
> The rest of the details here

## Test Case 3: Multiple blockquotes before Admonition

> First blockquote

> Second blockquote

> [!WARNING] This should still render correctly
> Even with multiple preceding blockquotes

## Test Case 4: Blockquote with blank line before Admonition

> Testing

> [!TIP] This should work fine
> With a blank line separation

## Test Case 5: Admonition without preceding blockquote (baseline)

> [!NOTE] This is a normal admonition
> It should render correctly

