---
name: ecosystem-map
description: Generate linear ecosystem map. When mapping stakeholders and actors.
allowed-tools: Read, Glob, Grep
metadata:
  prompt-id: ecosystem-map
  argument-hint: "[product_name] [product_description]"
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
Write a linear ecosystem map for $0 (Beatty and Chen 2012).

Include multiple internal and external actors affecting $0.
</task>

<output-format>
Format this description as a markdown document.
</output-format>

<reference>
Beatty, J., and Chen, A. 2012. Visual Models for Software Requirements. Redmond, WA: Microsoft Press.
</reference>