title=$1

echo "---
layout: post
title: '$title'
date: `date +%Y-%m-%d`
---" > _posts/`date +%Y-%m-%d-`"${title}".md 
