---
layout: section
title: BUILT BY SHAWNA
permalink: /built/
---

# BUILT

{% for item in site.built %}
- [{{ item.title }}]({{ item.url }})
{% endfor %}