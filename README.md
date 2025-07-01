# jekyll-post-guard

The repository hosts code for a plugin for [Jekyll based sites](https://jekyllrb.com/) that adds a lock feature to articles.

<!--TODO purpose-->

## How to use

### 1. Import the plugin 

Copy the plugin folder `jekyll-post-gaurd` from this repository `lib` directory into your site's `_plugin` folder.

### 2. Copy the `_locks` directory from this repository to your site's root folder. 

### 3. In your site's root `_config.yml`, specify the directory of the newly added `_locks` folder via `lock_dir: _locks`.

### 4. Choose one of your posts in your site's `_post` directory (e.g. `2022-11-12-welcome-to-jekyll.md`. To the post's text that you want to be locked off ,append a new line with `<!--lock_start-->` followed by `<!--lock:{"data":"sudoku"}-->` and then close of the section with `<!--lock_end-->`

```
---
layout: post
title:  "Welcome to Jekyll!"
date:   2022-11-12 16:27:06 -0600
categories: jekyll update
---

Introductory, non locked off text.

<!--lock_start-->
<!--lock:{"data":"sudoku"}-->

Text that will now be locked off in your blog post.

<!--lock_end-->
```

The resulting rendered page will look like the following:

<!--TODO: image-->

<!--TODO: explain the various lock sections -->

### 5. Optionally, you can also modify your site header to specify `locked: true` as in the following example:

```
---
layout: post
title:  "Welcome to Jekyll!"
date:   2022-11-12 16:27:06 -0600
categories: jekyll update
locked: true <- all values work TODO?
---
```

This will alert users as to which ...

Modify `_layouts` `home.html` to have:

```
<head>
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/4.7.0/css/font-awesome.min.css">
</head>
```

and

```
            <div style="display: inline">
                <div style="display: inline-block;">
                    {% if post.locked %}
                    <i class="fa fa-lock" color="black"></i>
                    {% endif %}
                </div>
                <div style="display: inline-block;">
                    <a class="post-link" href="{{ post.url | relative_url }}">
                        {{ post.title | escape }}
                    </a>
                </div>
            </div>
```

## Creating your own lock


## Features and demonstrations

To get a live demonstration then go to the `test_site` directory and run jekyll serve in the terminal.

<!--TODO images-->
