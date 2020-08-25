#  HackerNews.app

![Screenshot of main window](https://user-images.githubusercontent.com/37990858/91111480-93baff00-e6bb-11ea-8e00-d11790f9720c.png)

---

I couldn't find a HackerNews client that runs on macOS, built with native technologies (AppKit), and has all of the
features I was interested in: up/downvote features, commenting, hiding/favoriting, etc...

So I'm building on my own. 

## ⚠️ Warning

This app is still highly WIP, and it's not the best code in the world.
If you have any ideas to make the code cleaner, Swiftier, or really have any idea, PRs or issues are welcomed!

### Rewrite

I did a rewrite of this app, partially because I didn't want to spend days to find out why my old storyboard broke
working in Big Sur, and partially because I really wanted to replace my terrible code to less terrible code.
Thankfully, the rewrite was successful and you can see the commit 96db15a now!

The new app has a few features that the old app didn't have like comment colors, and now have more reliable 
upvoting/unvoting!

### Pre release

I did a pre release, you might want to try it out by downloading it from the
[releases tab](https://github.com/pcr910303/HackerNews/releases).

The app currently has a lot of basic features disabled - for example,
the commenting code is already written but I couldn't decide the optimal UI for commenting, so I removed it for now.
The comment was once selectable, but due to a Big Sur bug I disabled selecting, which means you won't be able to
copy text from comments (which will be a dealbreaker I guess?).
All-in-all, this pre release only is able to view HN, login and upvote/downvote, and has a non-optimal UI,
but it'll gain more features and a better UI as development proceeds.

## Development

I wrote a new [HNAPI](https://github.com/pcr910303/HNAPI) package for interfacing with HN. It handles
communicating with both the [HN official API](https://github.com/HackerNews/API), the
[Algolia HN API](https://hn.algolia.com/api), and the [HackerNews site](https://news.ycombinator.com).

If you're writing a new HN client (for any platform), you might want to gleam the code, I've put in a lot of thoughts in
the design. It's IMO the fastest & most robust approach to interfacing HN.

## Features

### Voting stories and comments

A surprising amount of HackerNews clients don't have any functionality related to accounts.
That's mostly because the [official API](https://github.com/HackerNews/API) only provides methods to view items.
In contrast, HackerNews.app loads the HN site, parses it and allows users to vote, favorite, or hide items.

### [Mac-assed Mac app](https://inessential.com/2020/03/19/proxyman)

This app tries to be a [Mac-assed Mac app](https://inessential.com/2020/03/19/proxyman).
It is developed using the AppKit APIs, and doesn't use webviews or Catalyst.

