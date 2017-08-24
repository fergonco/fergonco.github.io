title=$1

echo "---
layout: post
title: '$title'
date: `date +%Y-%m-%d`
---" > _drafts/`date +%Y-%m-%d-`"${title}".md 
