---
name: business-problem
description: Generate business problem statement using SPIIBV template. When documenting business problems and opportunities.
allowed-tools: Read, Glob, Grep
metadata:
  prompt-id: business-problem
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
Write a business problem statement for $0 following the SPIIBV template:

Situation
Describe the background, context, and environment.

Problem
Describe the business problems or opportunities as you now understand them.

Implication
Describe the likely results if the problem isn't solved.

Benefit
State the business value of solving the problem.

Vision
Describe what the desired future state would look like.
</task>

<output-format>
Format this description as a markdown document.
</output-format>