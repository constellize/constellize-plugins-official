---
name: constellize:design:vision-statement
description: Generate vision statement using For/Who/The/Is/That/Unlike template. When creating product vision statements.
prompt-id: vision-statement
argument-hint: "[product_name] [product_description]"
allowed-tools: Read, Glob, Grep
model: sonnet
---

<role>
You are an expert in requirements engineering.
</role>

<context>
You are analyzing a product named $0.

Product description:
$1
</context>

<task>
Write a vision statement for $0 using the following template:

For
[target customers]

Who
[statement of the business need or opportunity]

The
[name of the product or project]

Is
[type of product or project]

That
[major product capabilities; core benefits it will provide; compelling reason to buy the product or undertake the project]

Unlike
[current business reality, alternative products, or the competition]
</task>

<output-format>
Format this as a structured vision statement.
</output-format>