---
title: "Hugo Admonitions"
toc: true
---

Every callout on this page is plain Markdown, rendered by [hugo-admonitions](https://github.com/KKKZOZ/hugo-admonitions). Use the theme toggle in the header to check both color schemes.

## Basics

The syntax is the same as GitHub and Obsidian alerts:

```markdown
> [!NOTE]
> Useful information that users should know, even when skimming content.
```

> [!NOTE]
> Useful information that users should know, even when skimming content.

GitHub's five alert types all work:

> [!TIP]
> Helpful advice for doing things better or more easily.

> [!IMPORTANT]
> Key information users need to know to achieve their goal.

> [!WARNING]
> Urgent info that needs immediate user attention to avoid problems.

> [!CAUTION]
> Advises about risks or negative outcomes of certain actions.

## All 21 types

> [!ABSTRACT]
> Abstract: This paper discusses the advantages and challenges of microservice architecture.

> [!CAUTION]
> Advises about risks or negative outcomes of certain actions.

> [!CODE]
> Code snippet:
>
> ```javascript
> function fetchData() {
>     return axios.get('/api/data');
> }
> ```

> [!CONCLUSION]
> Conclusion: Based on the analysis above, we've decided to implement Docker containerization.

> [!DANGER]
> Danger! Critical security vulnerability detected in the system. Immediate action required.

> [!ERROR]
> Error: Unable to connect to database. Please check your connection settings.

> [!EXAMPLE]
> Example:
>
> ```python
> def hello_world():
>     print("Hello, World!")
> ```

> [!EXPERIMENT]
> Experiment: Testing the impact of new caching strategies on system performance.

> [!GOAL]
> Goal: Reduce service response time by 30% by the end of this quarter.

> [!IDEA]
> Idea: Implement a machine learning-based code quality detection system.

> [!IMPORTANT]
> Key information users need to know to achieve their goal.

> [!INFO]
> System status: All services are operating normally. Current uptime: 99.99%.

> [!MEMO]
> Memo: Technical review meeting scheduled for next Tuesday at 2:00 PM.

> [!NOTE]
> Useful information that users should know, even when skimming content.

> [!NOTIFY]
> System notification: Your password will expire in 30 days.

> [!QUESTION]
> Question: How can we optimize database query performance?

> [!QUOTE]
> "Code is like humor. When you have to explain it, it's bad." - Cory House

> [!SUCCESS]
> Congratulations! Your code has been successfully deployed to production.

> [!TASK]
> To-do list:
>
> - Update documentation
> - Deploy new version

> [!TIP]
> Helpful advice for doing things better or more easily.

> [!WARNING]
> Urgent info that needs immediate user attention to avoid problems.

## Custom titles

Put any text after the type:

```markdown
> [!IDEA] A custom title
> Any callout type can take its own title.
```

> [!IDEA] A custom title
> Any callout type can take its own title.

> [!TIP] Pro tip
> Run `hugo server -D` to preview drafts while you write.

## Header only

Leave out the body for a compact, single-line callout:

```markdown
> [!SUCCESS] Congratulations! Your code has been successfully deployed to production
```

> [!ABSTRACT] This paper discusses the advantages of microservice architecture

> [!CAUTION] Ensure all tests pass before merging to main branch

> [!CODE] Execute `npm install` to install all dependencies

> [!CONCLUSION] We've decided to implement Docker containerization

> [!DANGER] Critical security vulnerability detected in the system

> [!ERROR] Error: Unable to connect to database. Please check your connection settings

> [!EXAMPLE] Git commit message format: "feat: add user authentication"

> [!EXPERIMENT] Testing new caching strategy with Redis

> [!GOAL] Reduce service response time by 30% by the end of this quarter

> [!IDEA] Implement a machine learning-based code quality detection system

> [!IMPORTANT] Please review and update your security settings

> [!INFO] Current system status: All services are operating normally with 99.9% uptime

> [!MEMO] Technical review meeting scheduled for next Tuesday at 2:00 PM

> [!NOTE] Always backup your data before performing system updates

> [!NOTIFY] System notification: Your password will expire in 30 days

> [!QUESTION] How can we optimize database query performance?

> [!QUOTE] "Code is like humor. When you have to explain it, it's bad." - Cory House

> [!SUCCESS] Congratulations! Your code has been successfully deployed to production

> [!TASK] Review and update API documentation by Friday

> [!TIP] Use `Ctrl + C` to quickly terminate a running program

> [!WARNING] Warning: This operation will delete all data

## Headless

Set an empty title (double or single quotes) to show only the body:

```markdown
> [!TIP] ""
> This is a body-only callout without a header.
```

> [!TIP] ""
> This is a body-only callout without a header.

> [!INFO] ''
> You can still use any callout type, but the header will be hidden.

## Foldable

Add `-` (starts collapsed) or `+` (starts expanded) after the type:

```markdown
> [!NOTE]- Here are the details regarding API usage

> [!TIP]+ This one starts expanded
```

> [!NOTE]- Here are the details regarding API usage
>
> - **Endpoint**: `/api/v1/users` is used to fetch the user list.
> - **Authentication**: A valid `Bearer` token must be provided in the request header.
> - **Rate Limiting**: 100 requests are allowed per minute.

> [!TIP]+ This one starts expanded
> Click the header to fold it away.

## Nested

```markdown
> [!QUESTION] Can admonitions be nested?
> > [!TIP] Yes, they can.
> > > [!EXAMPLE] You can even use multiple layers of nesting.
```

> [!QUESTION] Can admonitions be nested?
> > [!TIP] Yes, they can.
> > > [!EXAMPLE] You can even use multiple layers of nesting.

## Obsidian aliases

Obsidian's alias names render as their canonical type:

```markdown
> [!TLDR]
> Renders as ABSTRACT.
```

> [!TLDR]
> `TLDR` renders as `ABSTRACT`.

> [!TODO]
> `TODO` renders as `TASK`.

> [!BUG]
> `BUG` renders as `ERROR`.

> [!FAQ]
> `FAQ` renders as `QUESTION`.

## Unknown types

Unsupported types fall back to `NOTE`, so a typo never breaks your build:

```markdown
> [!NOSUPPORT]
> This renders as a NOTE.
```

> [!NOSUPPORT]
> This renders as a NOTE.
