---
layout: default
title: 'Letting people query my work journal over MCP'
date: 2026-10-27
---

In this post I'll present you my journals, my job search and the tool I built
to bring them together.

## My work journal

Since 2019 I have been keeping a journal of my work activities. It is
unstructured Markdown with each day's date followed by whatever analysis,
commands, or ideas came to my mind that day. For example:

```
08 Jul 2024
===========

Analyzed Thomas ticket and processed the data again. Will compare later.

---

Got dragged to the configuration changes from PG 11 to 15.

    diff --git a/pg11-sorted b/pg15-sorted
    index a778f19..5a6266e 100644
    --- a/pg11-sorted
    +++ b/pg15-sorted
    @@ -1,9 +1,11 @@

    This was changed from default in PG11. Can help the server to breath [sic] if autovacuum is consuming too many resources.

    - autovacuum_vacuum_cost_delay | 20ms
    + autovacuum_vacuum_cost_delay | 2ms

    We have duplicated autovacuum work mem 1Gb (-1 = maintenance_work_mem = 1Gb) to 2Gb

    - autovacuum_work_mem | -1
    + autovacuum_work_mem | 2029088kB
...
```

Or recently, something I'm proud of:

```
17 Aug 2026
===========

Ran an optimization loop during the weekend.

The baseline was a 190Mb zip from production that took 3h20. now takes 27min.

I need to review that PR and ask for human review.
```

The journal is very useful in itself as a reference whenever I need to find a
command I already ran. It also helps me slow down and focus on the days when
that is not so easy.

## My job search

Whenever I had to search for a job I found it very frustrating that I needed to
build trust and reputation from scratch. It does not matter if you saved the
day every time in your previous company. They would ask trivial questions, as
if you just landed in the world and all the things you did in the past didn't
exist.

I often said to myself "If they knew what I did, they wouldn't be so clueless
interviewing me". In some cultures you can place references in your CV and they
actually get called. But this is not something that happened to me. I was never
asked for references.

And then came LLMs, which made matters worse. I don't want to talk much about
the state of affairs in recruiting. It seems we went from lying on the CV to
hiding prompts in the CV. I just want to focus on technical problems, not on
gaming whatever process we built around work.

But LLMs can also be used positively. Can't we use them to fix the problem
instead of making it worse? What if I allow LLMs to query my journals? That
would benefit everybody:

* For me, it is good because I don't need to sell myself, which I do not do
  well.
* For the recruiting side, it is a reliable source to evaluate what type of
  engineer I am.

So I found myself building a tool to reverse the job search process: instead of
getting my CV filtered out by a machine, I'll offer these machines a way to see
what I did in the past.

I know few people will use such a tool. But they will also be very
special and I'm hoping, probably naively, this will bring me very interesting
projects.

## Problem 1: journal exposure

I faced two problems. First, I can't expose the journals for agents to search
because they have a lot of details that I don't want to share. Service names,
UUIDs. I don't put sensitive information in the journals, but I am also not
100% sure of what is there: it's a lot of information dumped there on a daily
basis.

I solved that by getting an LLM to generate weekly summaries containing these
points:

* Main problems worked on
* Technologies used
* Type of engineering work
* Level of ownership
* Ways of working
* Cross-team or integration aspects
* Notable outcomes or decisions

## Problem 2: journal search

The second problem was how to search. I could expose those summaries and let
LLMs search. But the quality of that search depends a lot on the agent/model.
And I don't think they do a good job in this specific task. I could control the
agent/model by creating a service that does the search on my side, but that
would increase costs.

I gave Lucene a quick try and was not satisfied. In retrospect, it might have
worked, but my naive (and vibe-coded) attempt didn't.

I ended up creating embeddings using `ONNX` and
`sentence-transformers/all-MiniLM-L6-v2`. The idea was to encode as vectors
both the journal weeks and the input job description. Then get the nearest
neighbours to the job description. This worked very well: the model can run
locally in a very small server and the response is very quick, so the user
doesn't wait long while the job description embedding is computed.

## Interface

And finally, I put all this behind an MCP server. I haven't used MCP servers
myself so far. I use `pi.dev` and I ask the model to build whatever tooling I
need as skills. But in this case it seemed like the right place because it
guides the user LLM to the flow I want.

Essentially it's an MCP tool that takes a job description as input and returns
weekly summaries from my journal as output.

In a different world, we wouldn't need all this. An HTTP form, where somebody
pastes the job description and some week summaries are shown in response would
be enough. But that would output a dry weekly summary. Instead, this solution
turns my dry weekly summaries into something like:

> "Fernando is indeed a strong fit — it is not what he knows, it is how he
> approaches engineering"

and some more slop yada yada.

Just remember, behind all that slop, there are the real notes of an engineer
who loved his work before LLMs.

If you want to give it a try, visit:
[https://hire-me.fergonco.org/](https://hire-me.fergonco.org/)
