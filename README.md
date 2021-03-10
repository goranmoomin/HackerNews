#  HackerNews.app

![Screenshot of main window](https://user-images.githubusercontent.com/37990858/110665546-d2ee0f00-820b-11eb-86f2-290395bcd2ba.png)

---

I couldn't find a HackerNews client that runs on macOS, built with native technologies (AppKit), and has all of the
features I was interested in: up/downvote features, commenting, hiding/favoriting, etc...

So I'm building on my own. 

## ⚠️ Warning

This app is still highly WIP, and it's not the best code in the world.
If you have any ideas to make the code cleaner, Swiftier, or really have any idea, PRs are welcomed!

Also welcomed is trivial bug reports, I would like to fix bugs that are lying on the ground but
as I use the app daily, it's hard for me to find out very obvious bugs because I'm so used to it.
Every bug report helps, including very trivial ones. Thanks in advance.

### Pre release

I did a pre release, you might want to try it out by downloading it from the
[releases tab](https://github.com/goranmoomin/HackerNews/releases).

## Development

I wrote the [HNAPI](https://github.com/goranmoomin/HNAPI) package for interfacing with HN. It handles
communicating with both the [HN official API](https://github.com/HackerNews/API), the
[Algolia HN API](https://hn.algolia.com/api), and the [HackerNews site](https://news.ycombinator.com).

If you're writing a new HN client (for any platform), you might want to gleam the code, I've put in a lot of thoughts in
the design. There's probably a bit more design aspects that I have to think about, but it's pretty much the fastest and 
the most robust approach to interfacing HN that I could think.

## Features

### Voting stories and comments

A surprising amount of HackerNews clients don't have any functionality related to accounts.
That's mostly because the [official API](https://github.com/HackerNews/API) only provides methods to view items.
In contrast, HackerNews.app loads the HN site, parses it and allows users to vote, favorite, or hide items.

### [Mac-assed Mac app](https://inessential.com/2020/03/19/proxyman)

This app tries to be a [Mac-assed Mac app](https://inessential.com/2020/03/19/proxyman).
It is developed using the AppKit APIs, and doesn't use webviews or Catalyst.

